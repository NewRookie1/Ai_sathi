# Artisan AI Business Manager

AI-Driven Market Linkage & Smart Cataloging Mobile Application for Marginalized Artisans.

## Overview

Artisan AI is a voice-first mobile application that helps marginalized artisans and micro-entrepreneurs manage their business using AI. The app supports multilingual voice commands, AI-powered product analysis, smart cataloging, dynamic pricing, and market analysis.

## Features

- **Voice-First Interface**: Speak in your language (English, Marathi, Hindi, Gujarati, Bengali, Tamil, Telugu, Kannada, Malayalam, Punjabi)
- **AI Product Scanner**: Take a photo and AI analyzes your product
- **Smart Cataloging**: Create product listings using voice + camera
- **Dynamic Pricing**: AI-powered price suggestions based on market data
- **Market Analysis**: Track trends and product demand
- **Order Management**: Manage orders with voice commands
- **Image Enhancement**: Professional product photography assistance

## Architecture

```
Flutter Android App
        ↓
    Backend API (FastAPI)
        ↓
    AI Agent Orchestrator
        ↓
┌───────────────────────┐
│ Speech-to-Text         │
│ Translation            │
│ Intent Detection       │
│ Computer Vision        │
│ Product Analysis       │
│ Market Analysis        │
│ Pricing                │
│ AI Reasoning           │
└───────────────────────┘
        ↓
    Database / Market Data
        ↓
    AI Response
        ↓
    Translation
        ↓
    Flutter
        ↓
    Text + Voice
```

## Tech Stack

### Mobile
- Flutter 3.x
- Dart
- Provider (State Management)
- GoRouter (Navigation)

### Backend
- Python 3.11+
- FastAPI
- SQLAlchemy
- PostgreSQL (production) / SQLite (development)

### AI Providers
- OpenAI (GPT-4 Vision, Whisper, GPT-3.5-turbo)
- Provider abstraction for easy switching

## Project Structure

```
ai_saathi/                    # Flutter app
├── lib/
│   ├── main.dart
│   ├── core/                 # Constants, config, utilities
│   ├── models/               # Data models
│   ├── services/             # API and business services
│   ├── agent/                # AI agent system
│   ├── screens/              # UI screens
│   └── widgets/              # Reusable widgets

backend/                      # FastAPI backend
├── app/
│   ├── core/                 # Config, database, security
│   ├── models/               # Database models
│   ├── schemas/              # Pydantic schemas
│   ├── routers/              # API endpoints
│   ├── providers/            # AI provider implementations
│   └── agent/                # Agent tool registry
```

## Setup

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env  # Add your API keys
uvicorn app.main:app --reload
```

### Flutter

```bash
cd ai_saathi
flutter pub get
flutter run
```

## Environment Variables

Create `.env` file in backend directory:

```
DATABASE_URL=postgresql://user:password@localhost:5432/artisan_ai
SECRET_KEY=your-secret-key
OPENAI_API_KEY=your-openai-key
```

## API Endpoints

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login
- `POST /api/speech/transcribe` - Transcribe audio
- `POST /api/translate` - Translate text
- `POST /api/voice-chat` - Process voice command
- `POST /api/image/analyze` - Analyze image
- `GET /api/products` - Get products
- `POST /api/products` - Create product
- `GET /api/orders` - Get orders
- `GET /api/market/trends` - Get market trends

## License

MIT
"# Ai_sathi" 
