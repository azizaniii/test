# Aplikasi Mobile BPS Kabupaten Lombok Utara

Aplikasi Flutter untuk petugas lapangan BPS (Badan Pusat Statistik) Kabupaten Lombok Utara.

## Fitur Utama

1. **Pencarian KBLI & KBJI** - Mencari kode klasifikasi baku lapangan usaha dan jabatan Indonesia (offline-first dengan Drift SQLite)
2. **Estimasi Biaya BPJS** - Menghitung estimasi biaya perawatan RS/Puskesmas berdasarkan tarif INA-CBG
3. **Konsep & Definisi + AI** - Mencari definisi survei dan tanya-jawab AI dengan fallback Gemini → Groq
4. **SAKERNAS** - Bantuan pelaksanaan Survei Angkatan Kerja Nasional (akan datang)
5. **SUSENAS** - Bantuan pelaksanaan Survei Sosial Ekonomi Nasional dengan OCR (akan datang)
6. **Laporan Perjalanan** - Membuat laporan kegiatan petugas dengan export PDF (akan datang)

## Arsitektur

- **Offline-first**: Local DB (Drift + Hive) adalah sumber kebenaran utama saat di lapangan
- **Sync Engine**: Antrian sinkronisasi ke Firestore saat online
- **AI Gateway**: Cloud Function dengan rolling API keys dan fallback provider
- **Repository Pattern**: Semua akses data melalui repository layer

## Tech Stack

| Layer | Teknologi |
|-------|-----------|
| Framework | Flutter (Android first) |
| Cloud DB | Firebase Firestore |
| Auth | Firebase Auth (custom claims untuk role) |
| Local DB | Drift (SQLite) + Hive |
| OCR | Google ML Kit Text Recognition |
| PDF | pdf + printing package |
| State Management | Riverpod |
| AI Provider | Gemini API (primary) → Groq API (fallback) |
| Server Logic | Firebase Cloud Functions (TypeScript) |

## Struktur Folder

```
lib/
├── main.dart                    # Entry point
├── app/                         # App-level config (router, theme)
├── core/                        # Core utilities
│   ├── constants/               # App constants
│   ├── network/                 # Connectivity, AI gateway
│   ├── local_db/                # Drift + Hive setup
│   └── sync/                    # Sync engine
├── features/                    # Feature modules
│   ├── auth/                    # Login, logout
│   ├── kbli_kbji/               # Pencarian KBLI/KBJI
│   ├── bpjs_cost_estimation/    # Estimasi biaya BPJS
│   ├── concept_search_ai/       # Konsep + AI
│   ├── sakernas/                # SAKERNAS helper
│   ├── susenas/                 # SUSENAS + OCR
│   └── field_report_pdf/        # Laporan PDF
└── shared_widgets/              # Reusable widgets

functions/                       # Cloud Functions
├── src/
│   ├── index.ts                 # Main entry
│   ├── askAI.ts                 # AI Gateway handler
│   └── middleware/
│       └── authCheck.ts         # Auth middleware
```

## Setup Development

### Prerequisites

- Flutter SDK 3.x
- Node.js 20+
- Firebase CLI
- Android Studio / VS Code

### Langkah Setup

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd bps-lu-field-app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase**
   - Buat project di Firebase Console
   - Download `google-services.json` untuk Android
   - Letakkan di `android/app/google-services.json`
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Enable Cloud Storage

4. **Setup Cloud Functions**
   ```bash
   cd functions
   npm install
   ```

5. **Generate Drift database**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. **Run app**
   ```bash
   flutter run
   ```

## Environment Variables (Cloud Functions)

Set environment variables di Firebase:

```bash
firebase functions:secrets:set GEMINI_API_KEY_1
firebase functions:secrets:set GEMINI_API_KEY_2
firebase functions:secrets:set GROQ_API_KEY_1
firebase functions:secrets:set GROQ_API_KEY_2
```

## Deployment

### Flutter App

```bash
flutter build apk --release
# atau untuk App Bundle
flutter build appbundle --release
```

### Cloud Functions

```bash
cd functions
npm run deploy
```

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users hanya bisa baca/tulis dokumen sendiri
    match /survei_sakernas/{docId} {
      allow read, write: if request.auth != null && 
                          request.auth.uid == resource.data.petugas_id;
    }
    
    match /survei_susenas/{docId} {
      allow read, write: if request.auth != null && 
                          request.auth.uid == resource.data.petugas_id;
    }
    
    match /laporan_perjalanan/{docId} {
      allow read, write: if request.auth != null && 
                          request.auth.uid == resource.data.petugas_id;
    }
    
    // Master data hanya bisa ditulis admin, dibaca semua authenticated user
    match /master_{collection}/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                   get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin_kantor';
    }
  }
}
```

## Catatan Penting

- **API Keys**: Jangan pernah menaruh API key AI di client-side code
- **Offline Mode**: Pastikan semua fitur inti berfungsi tanpa internet
- **Image Compression**: Foto dikompresi sebelum disimpan (~500KB max)
- **Backup Manual**: Upload ke Firebase Storage hanya saat user menekan tombol backup

## License

© 2024 BPS Kabupaten Lombok Utara

## Contact

Untuk pertanyaan teknis, hubungi tim developer BPS LU.
