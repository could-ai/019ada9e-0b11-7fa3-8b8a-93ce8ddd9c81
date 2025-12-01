class Chapter {
  final String title;
  final String description;
  final String content;

  const Chapter({
    required this.title,
    required this.description,
    required this.content,
  });
}

final List<Chapter> moduleChapters = [
  Chapter(
    title: "BAB 1: Pendahuluan",
    description: "Pengenalan Analisis Sentimen dan Studi Kasus YouTube.",
    content: """
# BAB 1: Pendahuluan

## 1.1 Latar Belakang
Media sosial, khususnya YouTube, telah menjadi sumber data yang sangat besar untuk memahami opini publik. Komentar pada video YouTube mengandung wawasan berharga mengenai persepsi penonton terhadap suatu konten, produk, atau isu terkini.

**Analisis Sentimen** (Sentiment Analysis) atau *Opinion Mining* adalah cabang dari Natural Language Processing (NLP) yang bertujuan untuk mengidentifikasi dan mengekstrak informasi subjektif dari teks.

## 1.2 Tujuan Pembelajaran
Setelah menyelesaikan modul ini, mahasiswa diharapkan mampu:
1. Memahami alur kerja proyek NLP dari awal hingga akhir.
2. Mengambil data komentar YouTube menggunakan YouTube Data API.
3. Melakukan preprocessing teks bahasa Indonesia.
4. Membangun model klasifikasi sentimen (Positif/Negatif).
5. Mengevaluasi performa model.

## 1.3 Alur Kerja (Pipeline)
1. **Data Acquisition**: Mengambil data komentar via API.
2. **Preprocessing**: Membersihkan data mentah.
3. **Labeling**: Memberi label sentimen (Manual/Otomatis).
4. **Feature Extraction**: Mengubah teks menjadi angka (TF-IDF).
5. **Modeling**: Melatih algoritma Machine Learning (Naive Bayes).
6. **Evaluation**: Mengukur akurasi.
""",
  ),
  Chapter(
    title: "BAB 2: Persiapan Lingkungan",
    description: "Instalasi Python dan Library yang dibutuhkan.",
    content: """
# BAB 2: Persiapan Lingkungan

Sebelum memulai, pastikan Anda telah menginstal Python (versi 3.8 ke atas) dan Jupyter Notebook atau Google Colab.

## 2.1 Instalasi Library
Kita akan menggunakan beberapa library populer Python. Jalankan perintah berikut di terminal atau sel notebook Anda:

```bash
pip install google-api-python-client
pip install pandas numpy
pip install nltk Sastrawi scikit-learn
pip install matplotlib seaborn
```

## 2.2 Penjelasan Library
*   **google-api-python-client**: Untuk berinteraksi dengan YouTube Data API v3.
*   **pandas**: Untuk manipulasi data dalam bentuk DataFrame.
*   **Sastrawi**: Library khusus untuk stemming bahasa Indonesia.
*   **scikit-learn**: Library utama untuk Machine Learning (TF-IDF, Naive Bayes, Evaluasi).
*   **nltk**: Natural Language Toolkit untuk tokenisasi dan stopwords.
""",
  ),
  Chapter(
    title: "BAB 3: Pengumpulan Data (Crawling)",
    description: "Mengambil komentar YouTube menggunakan API.",
    content: """
# BAB 3: Pengumpulan Data

Untuk mengambil data dari YouTube, kita memerlukan **API Key** dari Google Cloud Console.

## 3.1 Mendapatkan API Key
1. Buka [Google Cloud Console](https://console.cloud.google.com/).
2. Buat Project baru.
3. Cari "YouTube Data API v3" di Library dan aktifkan (Enable).
4. Masuk ke menu "Credentials" -> "Create Credentials" -> "API Key".
5. Salin API Key Anda.

## 3.2 Kode Python: Crawling Komentar
Berikut adalah skrip lengkap untuk mengambil komentar dari sebuah video. Ganti `VIDEO_ID` dengan ID video yang ingin dianalisis (bagian akhir URL video).

```python
import googleapiclient.discovery
import pandas as pd

# Konfigurasi
API_KEY = "MASUKKAN_API_KEY_ANDA_DISINI"
VIDEO_ID = "dQw4w9WgXcQ" # Contoh ID Video

def get_video_comments(video_id, api_key, max_results=100):
    # Inisialisasi Client
    youtube = googleapiclient.discovery.build(
        "youtube", "v3", developerKey=api_key
    )

    comments = []
    
    # Request pertama
    request = youtube.commentThreads().list(
        part="snippet",
        videoId=video_id,
        maxResults=100,
        textFormat="plainText"
    )

    while request and len(comments) < max_results:
        response = request.execute()

        for item in response['items']:
            comment = item['snippet']['topLevelComment']['snippet']
            text = comment['textDisplay']
            author = comment['authorDisplayName']
            date = comment['publishedAt']
            
            comments.append({
                'author': author,
                'date': date,
                'text': text
            })

        # Cek halaman berikutnya (pagination)
        if 'nextPageToken' in response:
            request = youtube.commentThreads().list(
                part="snippet",
                videoId=video_id,
                maxResults=100,
                textFormat="plainText",
                pageToken=response['nextPageToken']
            )
        else:
            break

    return pd.DataFrame(comments)

# Eksekusi
df = get_video_comments(VIDEO_ID, API_KEY, max_results=200)
print(f"Berhasil mengambil {len(df)} komentar.")
df.to_csv('youtube_comments.csv', index=False)
print(df.head())
```
""",
  ),
  Chapter(
    title: "BAB 4: Preprocessing Data",
    description: "Membersihkan teks agar siap diolah.",
    content: """
# BAB 4: Preprocessing Data

Data teks dari media sosial sangat kotor (banyak typo, emoji, singkatan). Kita perlu membersihkannya.

## 4.1 Tahapan Preprocessing
1.  **Case Folding**: Mengubah huruf menjadi kecil (lowercase).
2.  **Cleaning**: Menghapus angka, tanda baca, emoji, dan URL.
3.  **Tokenization**: Memecah kalimat menjadi kata.
4.  **Stopword Removal**: Menghapus kata umum yang tidak bermakna (contoh: "yang", "di", "ke").
5.  **Stemming**: Mengubah kata berimbuhan menjadi kata dasar (contoh: "memakan" -> "makan").

## 4.2 Kode Python: Preprocessing
Kita akan menggunakan library `Sastrawi` untuk Bahasa Indonesia.

```python
import re
import pandas as pd
from Sastrawi.Stemmer.StemmerFactory import StemmerFactory
from Sastrawi.StopWordRemover.StopWordRemoverFactory import StopWordRemoverFactory

# Load Data
df = pd.read_csv('youtube_comments.csv')

# 1. Inisialisasi Sastrawi
factory_stem = StemmerFactory()
stemmer = factory_stem.create_stemmer()

factory_stop = StopWordRemoverFactory()
stopword = factory_stop.create_stop_word_remover()

def clean_text(text):
    # Case Folding
    text = text.lower()
    
    # Remove URL
    text = re.sub(r'http\S+', '', text)
    
    # Remove Numbers & Punctuation
    text = re.sub(r'[^a-z\s]', '', text)
    
    # Remove Extra Whitespace
    text = text.strip()
    
    return text

def preprocess_pipeline(text):
    # 1. Cleaning
    text = clean_text(text)
    
    # 2. Stopword Removal
    text = stopword.remove(text)
    
    # 3. Stemming (Proses ini agak lama)
    text = stemmer.stem(text)
    
    return text

# Terapkan ke DataFrame
print("Sedang melakukan preprocessing...")
df['clean_text'] = df['text'].apply(preprocess_pipeline)

# Hapus data kosong setelah cleaning
df.dropna(subset=['clean_text'], inplace=True)
df = df[df['clean_text'] != '']

print(df[['text', 'clean_text']].head())
df.to_csv('comments_clean.csv', index=False)
```
""",
  ),
  Chapter(
    title: "BAB 5: Pelabelan (Labeling)",
    description: "Menentukan sentimen Positif atau Negatif.",
    content: """
# BAB 5: Pelabelan Data

Agar komputer bisa belajar, kita perlu memberitahu mana komentar yang **Positif** dan mana yang **Negatif**.

## 5.1 Metode Pelabelan
1.  **Manual**: Manusia membaca satu per satu (paling akurat, tapi lama).
2.  **Lexicon Based**: Menggunakan kamus kata positif/negatif (contoh: InSet Lexicon).
3.  **Rule Based**: Menggunakan library seperti VADER atau TextBlob (biasanya untuk B. Inggris, perlu translasi jika B. Indo).

Untuk modul ini, kita asumsikan kita menggunakan metode **Lexicon Sederhana** atau Anda bisa melabeli 50 data secara manual di Excel.

### Contoh Format Data Setelah Labeling:
| clean_text | label |
| :--- | :--- |
| video ini sangat bagus | positif |
| konten tidak mendidik | negatif |
| terima kasih tutorialnya | positif |

*Simpan file yang sudah dilabeli sebagai `labeled_data.csv`.*
""",
  ),
  Chapter(
    title: "BAB 6: Ekstraksi Fitur & Pemodelan",
    description: "TF-IDF dan Naive Bayes Classifier.",
    content: """
# BAB 6: Ekstraksi Fitur & Pemodelan

Komputer tidak mengerti teks, hanya angka. Kita akan mengubah teks menjadi vektor angka menggunakan **TF-IDF** dan mengklasifikasikannya dengan **Naive Bayes**.

## 6.1 TF-IDF (Term Frequency - Inverse Document Frequency)
Metode ini memberikan bobot pada kata. Kata yang jarang muncul di seluruh dokumen tapi sering muncul di satu dokumen akan memiliki nilai tinggi (dianggap kata kunci).

## 6.2 Naive Bayes
Algoritma klasifikasi probabilistik yang sederhana namun sangat efektif untuk klasifikasi teks.

## 6.3 Kode Python: Training Model

```python
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.metrics import classification_report, accuracy_score
import pandas as pd

# Load Data Terlabeli
df = pd.read_csv('labeled_data.csv')

# Pisahkan Data (X) dan Label (y)
X = df['clean_text']
y = df['label']

# Split Data Training (80%) dan Testing (20%)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# 1. Ekstraksi Fitur (TF-IDF)
vectorizer = TfidfVectorizer(max_features=1000) # Ambil 1000 kata teratas
X_train_tfidf = vectorizer.fit_transform(X_train)
X_test_tfidf = vectorizer.transform(X_test)

# 2. Modeling (Naive Bayes)
model = MultinomialNB()
model.fit(X_train_tfidf, y_train)

# 3. Prediksi
y_pred = model.predict(X_test_tfidf)

# 4. Evaluasi
print("Akurasi:", accuracy_score(y_test, y_pred))
print("\\nLaporan Klasifikasi:\\n", classification_report(y_test, y_pred))
```
""",
  ),
  Chapter(
    title: "BAB 7: Pengujian & Kesimpulan",
    description: "Menguji model dengan kalimat baru.",
    content: """
# BAB 7: Pengujian Model

Setelah model dilatih, kita bisa menggunakannya untuk memprediksi sentimen kalimat baru yang belum pernah dilihat model.

## 7.1 Kode Python: Prediksi Baru

```python
def predict_sentiment(text):
    # Preprocess text baru (harus sama dengan training)
    # Asumsikan fungsi preprocess_pipeline sudah ada
    clean = preprocess_pipeline(text) 
    
    # Transform ke TF-IDF
    text_vector = vectorizer.transform([clean])
    
    # Prediksi
    prediction = model.predict(text_vector)
    return prediction[0]

# Test
kalimat_1 = "Videonya sangat bermanfaat, terima kasih bang!"
kalimat_2 = "Suaranya kecil banget, gak jelas penjelasannya."

print(f"Kalimat: {kalimat_1} -> Sentimen: {predict_sentiment(kalimat_1)}")
print(f"Kalimat: {kalimat_2} -> Sentimen: {predict_sentiment(kalimat_2)}")
```

## 7.2 Kesimpulan
Dalam modul ini, kita telah mempelajari:
1.  Cara mengambil data real-time dari YouTube API.
2.  Pentingnya preprocessing untuk membersihkan noise pada data teks.
3.  Penggunaan TF-IDF untuk mengubah teks menjadi fitur numerik.
4.  Implementasi Naive Bayes untuk klasifikasi sentimen.

**Tugas Lanjutan:**
Cobalah ganti algoritma Naive Bayes dengan **Support Vector Machine (SVM)** atau **Random Forest** dan bandingkan akurasinya!
""",
  ),
];
