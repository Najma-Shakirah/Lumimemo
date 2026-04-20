# 🧠 LumiMemo

> AI Memory Companion for Dementia Patients
> **Project 2030: MyAI Future Hackathon** — Track 3: Vital Signs (Healthcare & Wellbeing)

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?logo=firebase)
![Gemini](https://img.shields.io/badge/Google-Gemini_Pro-4285F4?logo=google)
![Cloud Run](https://img.shields.io/badge/Google_Cloud-Cloud_Run-4285F4?logo=googlecloud)

---

## 📌 Problem

Malaysia is heading toward **Aged Society status** by 2030. Over 200,000 Malaysians
live with dementia today — a number expected to triple by 2050. Existing solutions
are too clinical, too expensive, or not built for the local context.

Key gaps:
- No affordable tool for families to **capture and replay memories** at home
- Patients lose connection with identity and loved ones
- Caregivers are overwhelmed with no AI support

---

## 💡 Solution

**LumiMemo** lets family members record memories through natural conversation.
A **3D AI avatar companion** — powered by Google Gemini — recalls those memories
back to the patient in a warm, familiar voice with real-time lip sync.

---

## ✨ Features

- 🤖 Realistic 3D AI avatar companion (Convai)
- 🎙️ Voice memory recording via LiveKit
- 🧠 Gemini Pro extracts people, places, dates & emotions from conversations
- 📚 Memory library stored in Firestore
- 🔍 Semantic memory search via Vertex AI RAG
- 🔐 Firebase Authentication
- 📱 Flutter — Android & iOS

---

## 🏗️ Architecture

```
Flutter App
    ├── Firebase Auth
    ├── Convai 3D Avatar (WebView)
    └── LiveKit Audio Capture
            ↓
    Node.js + Firebase Genkit
    (Google Cloud Run)
            ↓
    ┌───────────────────────┐
    │   Gemini Flash        │ ← transcription
    │   Gemini Pro          │ ← extraction + narration
    │   Vertex AI Search    │ ← RAG memory retrieval
    └───────────────────────┘
            ↓
    Cloud Firestore
    (structured memory storage)
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.x |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| AI Extraction & Narration | Google Gemini Pro |
| Real-time Transcription | Google Gemini Flash |
| AI Orchestration | Firebase Genkit |
| Semantic Search | Vertex AI Search (RAG) |
| 3D Avatar + Lip Sync | Convai |
| Audio Capture | LiveKit |
| Backend | Node.js on Google Cloud Run |
| Prototyping | Google AI Studio |

---

## 📁 Project Structure

```
lumimemo/
├── lib/
│   ├── main.dart
│   ├── apptheme.dart
│   └── screens/
│       ├── loginscreen.dart
│       ├── dashboard_screen.dart
│       ├── avatar_screen.dart
│       └── record_screen.dart
├── assets/
│   └── avatar/
│       └── avatar.html
├── backend/
│   ├── index.js
│   ├── flows/
│   │   ├── extractMemory.js
│   │   ├── retrieveMemory.js
│   │   └── narrateMemory.js
│   └── Dockerfile
├── .env                  # never committed
├── .gitignore
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.x
- Node.js 18.x+
- Firebase CLI — `npm i -g firebase-tools`
- gcloud CLI — cloud.google.com/sdk

### Clone & Install

```bash
git clone https://github.com/YOUR_USERNAME/lumimemo.git
cd lumimemo
flutter pub get
```

---

## 🔐 Environment Variables

Create `.env` in project root:

```env
CONVAI_API_KEY=your_convai_api_key
CONVAI_CHARACTER_ID=your_convai_character_id
GEMINI_API_KEY=your_gemini_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
LIVEKIT_URL=your_livekit_url
LIVEKIT_API_KEY=your_livekit_api_key
LIVEKIT_API_SECRET=your_livekit_api_secret
```

Create `.env` in `backend/`:

```env
GEMINI_API_KEY=your_gemini_api_key
FIREBASE_PROJECT_ID=your_firebase_project_id
PORT=3000
```

> ⚠️ `.env` files are listed in `.gitignore` and never committed.

---

## 📱 Running the App

```bash
flutter run -d android
```

---

## ⚙️ Backend

```bash
cd backend
npm install
node index.js
```

---

## ☁️ Deployment

```bash
cd backend

gcloud run deploy lumimemo-backend \
  --source . \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --set-env-vars GEMINI_API_KEY=your_key,FIREBASE_PROJECT_ID=your_id
```

**Live URL:** `https://lumimemo-backend-xxxx-as.a.run.app`

---

## 🤖 AI Tools Disclosure

As required by Section 4, Point 2 of the hackathon rules:

| Tool | Usage |
|---|---|
| Google Gemini Pro | Memory extraction & narration |
| Google Gemini Flash | Real-time transcription |
| Firebase Genkit | Pipeline orchestration |
| Vertex AI Search | Semantic RAG retrieval |
| Convai | 3D avatar & lip sync |
| Claude (Anthropic) | Development assistance |

All team members understand and can explain the full codebase.

---

## 👥 Team

| Name | Role |
|---|---|
| [Name] | Flutter & AI Integration |
| [Name] | Backend & Genkit |
| [Name] | UI/UX |
| [Name] | DevOps & Cloud Run |

**Institution:** [Your University]
**Category:** Student / Open

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

*Built for Malaysia's aging population*
*Advancing the Nation by Building Solutions with Google AI* 🇲🇾
```
