# Notecraft

[![Swift Version](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018.0+-blue.svg)](https://developer.apple.com/ios/)

Brief description of your project in 2-3 sentences. Explain what your app does and its core value proposition.

## 📱 Screenshots
![UI](https://github.com/user-attachments/assets/5063bf58-b663-4e31-83e8-14df43e1b78e)

## ✨ Features

- Music Theory (Lesson, Quiz, Interactive Experience Features)
- Basic Tools (Tuner, Metronome, Keyboard)
- Music Score documentation
- Any unique selling points

## 🔧 Requirements

- iOS 18.0+
- Xcode 14.0+
- Swift 5.0+

## 📲  Installation

1. Clone the repo
```bash
git clone https://github.com/username/project.git
```

2. Open the `.xcodeproj` file in Xcode

3. Build and run the project

# Project Name

[Previous sections remain the same...]

## 🏗 Architecture

### Frontend Stack
- **Swift 5.0+**: Core programming language
- **SwiftUI**: Modern declarative UI framework
- **UIKit**: Traditional UI framework for custom components
- **Observation**: For reactive programming and data flow
- **AVFoundation**: For audio input, output and manipulation
- **Swift Package Manager**: Dependency management

### Backend Stack
- **Supabase**
  - Real-time database
  - Authentication
  - Storage
  
- **FastAPI**
  - Optical Music Recognition ([oemer library](https://github.com/BreezeWhite/oemer)) 

> **Note**: The FastAPI backend is currently in experimental phase. Run the repo in local host for the optical music recognition feature
> https://github.com/wyattcheang/notecraft_fastapi



### Data Flow
1. UI Layer (SwiftUI/UIKit) ↔️ View Models
2. View Models ↔️ Services
3. Services ↔️ Supabase/FastAPI
4. FastAPI ↔️ Database

### Key Design Patterns
- **MVVM**: Main architecture pattern
- **Repository Pattern**: For data access
- **Dependency Injection**: For better testability
- **Observer Pattern**: Using Combine for reactive updates
- **Factory Pattern**: For creating complex objects

[Rest of the README remains the same...]

## 📚 Documentation
https://www.dropbox.com/scl/fi/qx3k41brvez6l5qwvg6ra/FYP_CHEANG-WAI-HOE_TP064280_APU3F2311CS.pdf?rlkey=swu20yv63z2o1xkpgy69b5s1q&st=ybt3wrib&dl=0

## 🎥 Demo
https://www.dropbox.com/scl/fi/sf8n4a6rc23pkll9xijmk/Notecraft_demo_video.mp4?rlkey=krebygpqpoc8okqnvue6zw5dl&st=rrm4pj8s&dl=0

## 🤝 Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 👥 Authors

- Your Name - Initial work - [@wyattcheang](https://github.com/wyattcheang)

## 📞 Support

- Create an issue
- Email: wyattcheangwaihoe@icloud.com
