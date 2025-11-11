# 🕵️ SpyAI - Intelligent Surveillance System

> **⚠️ DEVELOPMENT STATUS NOTICE**: This application is currently under active development and is not yet ready for production use. Features are being implemented progressively and may be incomplete or subject to changes.

A sophisticated cross-platform application that captures, transcribes, and analyzes audio recordings using advanced AI technology. Built for discreet monitoring with powerful natural language querying capabilities.

## 🎯 Overview

SpyAI combines cutting-edge mobile recording technology with Google's Gemini AI to create an intelligent surveillance solution. The app captures high-quality audio in 3-minute chunks, automatically transcribes conversations in multiple languages, and stores everything in a queryable database for later analysis.

## 🏗️ Architecture

### Frontend (Flutter)
- **Cross-platform mobile app** supporting iOS and Android
- **Advanced audio recording** with optimized settings for distant voices
- **Chunked upload system** for reliable long-duration recordings
- **Modern dark UI** with secretive, professional design
- **Real-time recording monitoring** with duration tracking

### Backend (FastAPI)
- **RESTful API server** built with Python FastAPI
- **AI-powered transcription** using Google Gemini 2.5-flash
- **Multi-language support** (English, Hindi, Hinglish)
- **PostgreSQL database integration** via Supabase
- **Natural language querying** system for transcript search

## 🚀 Key Features

### 📱 Mobile App
- ✅ **High-quality audio recording** (WAV, 96kbps, 44.1kHz)
- ✅ **Long-duration support** with automatic 3-minute chunking
- ✅ **Smart permission handling** with user-friendly dialogs
- ✅ **Retry mechanism** for failed uploads with exponential backoff
- ✅ **Auto-cleanup** of temporary files to prevent storage issues

### 🤖 AI Processing
- ✅ **Advanced transcription** with speaker identification
- ✅ **Name inference** - automatically replaces "Person 1" with actual names
- ✅ **Preserves natural speech** including fillers and informal language
- ✅ **Handles Hinglish** and code-switching seamlessly
- ✅ **Timestamp tracking** for precise recording attribution

### 🗃️ Data Management
- ✅ **PostgreSQL database** for structured transcript storage
- ✅ **Supabase integration** for real-time capabilities
- ✅ **SQL query generation** from natural language requests
- ✅ **Transcript refinement** for contextual question answering

## 🛠️ Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Mobile Frontend** | Flutter (Dart) | Cross-platform UI and audio recording |
| **Backend API** | FastAPI (Python) | RESTful services and AI integration |
| **AI Engine** | Google Gemini 2.5-flash | Audio transcription and NLP |
| **Database** | PostgreSQL + Supabase | Transcript storage and querying |
| **Audio Processing** | Record package | High-quality mobile audio capture |
| **Environment** | Docker-ready | Containerized deployment support |

## 📋 Project Structure

```
SpyAI/
├── spyai/                    # Flutter mobile application
│   ├── lib/screens/         # UI screens (recording, chat, tabs)
│   ├── android/ios/         # Platform-specific configurations
│   └── pubspec.yaml         # Flutter dependencies
├── backend/                  # FastAPI server
│   ├── routers/             # API endpoints
│   ├── utils/               # AI and database utilities
│   ├── requirements.txt     # Python dependencies
│   └── main.py             # Server entry point
└── README.md               # This file
```

## ⚙️ Installation & Setup

### Prerequisites
- Flutter SDK (3.8.1+)
- Python 3.8+
- PostgreSQL database
- Google Gemini API key
- Supabase account (optional)

### Quick Start
```bash
# Clone repository
git clone https://github.com/AryanV-Coder/SpyAI.git
cd SpyAI

# Backend setup
cd backend
pip install -r requirements.txt
cp .env.example .env  # Configure your API keys

# Frontend setup
cd ../spyai
flutter pub get
flutter run

# Start backend server
cd ../backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## 🔧 Configuration

Create `.env` files with your credentials:

**Backend (.env):**
```env
GEMINI_API_KEY=your_gemini_api_key
user=your_db_user
password=your_db_password
host=your_db_host
port=5432
dbname=your_database_name
```

**Frontend (.env):**
```env
API_BASE_URL=http://127.0.0.1:8000
```

## 📊 Current Status: Work in Progress

### ✅ Completed Features
- [x] Audio recording with chunked uploads
- [x] AI-powered transcription system
- [x] Database integration and storage
- [x] Modern mobile UI with dark theme
- [x] Multi-language support (Hindi/English/Hinglish)
- [x] Speaker identification and name inference
- [x] Timestamp tracking and attribution

### 🚧 In Development
- [ ] **Advanced search functionality** with filters
- [ ] **Export capabilities** (PDF, Word, JSON)
- [ ] **User authentication** and multi-user support
- [ ] **Cloud storage integration** (AWS S3, Google Cloud)
- [ ] **Analytics dashboard** with insights and statistics
- [ ] **Notification system** for important conversations

### 📝 Planned Features
- [ ] **Voice activity detection** to reduce processing
- [ ] **Sentiment analysis** of conversations
- [ ] **Meeting summary generation** 
- [ ] **Integration with calendar apps**
- [ ] **Automated tagging** system
- [ ] **Multi-device synchronization**
- [ ] **Privacy controls** and data encryption
- [ ] **API rate limiting** and optimization

## 🔐 Privacy & Security

This application handles sensitive audio data. Please ensure:
- Secure API key management
- Encrypted database connections  
- Proper user consent for recordings
- Compliance with local privacy laws
- Regular security audits

## 🤝 Contributing

This project is actively being developed. Contributions are welcome! Please feel free to:
- Report bugs and suggest features
- Submit pull requests for improvements
- Help with documentation and testing
- Provide feedback on user experience

## 📄 License

This project is currently in development. Please contact the author for licensing information.

## 👨‍💻 Author

**Aryan Varshney** - *Lead Developer*
- GitHub: [@AryanV-Coder](https://github.com/AryanV-Coder)

---

> **Note**: This is an active development project. Features and functionality are continuously evolving. Some components may be incomplete or undergo significant changes. Please check back frequently for updates and new releases.
