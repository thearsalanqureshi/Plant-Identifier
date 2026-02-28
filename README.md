# Plant-Identifier
A Flutter-based plant recognition application that helps users identify plants, diagnose issues, calculate water needs, and measure light conditions using AI technology.

# Tech Stack

# Frontend:
- Flutter 

# Backend
- Firebase (Analytics, Crashlytics, Push Notifications, In-App Messaging) 
- AI/ML: Google Gemini API 
- Local Storage: Hive 
- State Management: Provider 
- Architecture: MVVM (Model-View-ViewModel)



### Project Overview
A plant care application that uses Google's Gemini AI to identify plant species, diagnose health issues, calculate watering needs, and measure light conditions through image recognition and analysis. The app provides instant, accurate plant information to help users properly care for their plants. Built with local Hive storage for offline history and Firebase for analytics and crash reporting.

### Problem Statement
Plant enthusiasts struggle to identify unknown plants, diagnose health issues, determine proper watering schedules, and assess light conditions for optimal plant care.

### Solution
Developed a comprehensive 4-feature mobile app leveraging Google's Gemini AI for visual recognition and analysis.

### Key Feature
1. **Identify** - Instant plant species recognition from photos
2. **Diagnose** - Plant health issue detection and treatment recommendations
3. **Water Calculator** - Personalized watering schedules based on plant type
4. **Light Meter** - Ambient light measurement for optimal placement

### **Technical Architecture**
- **MVVM Architecture** - Clean separation of UI, logic, and data
- **Local Storage** - Hive database for offline history (13+ scans)
- **Cloud Services** - Firebase for analytics, crash reporting, and backend
- **AI Integration** - Gemini 2.5 Flash API for image-to-text analysis

### **Development Timeline**
- **Phase 1:** Core features & UI implementation
- **Phase 2:** Provider State Management
- **Phase 3:** Gemini API integration & testing  
- **Phase 4:** Hive database & offline support
- **Phase 5:** Firebase services & analytics
- **Phase 6:** Play Store deployment preparation


### Challenges & Solutions
 Challenge | Solution 
-----------|----------
 Image decoding errors | Graceful error handling with fallbacks 
 API latency | Optimized image compression (894KB) 
 Permission complexity | Runtime permission handling for Android 13+ 
 Data persistence | Hive with corruption recovery 


### Key Learnings
- Hive provides excellent offline capabilities
- Gemini API delivers accurate plant identification
- Proper permission handling is critical for Android
- Analytics tracking invaluable for user behavior insights

- Add community features
- Expand plant database
- Implement AR plant placement
- Add social sharing capabilities

### **Conclusion**
Successfully delivered a production-ready Flutter application with robust AI integration, offline capabilities, and comprehensive analytics - now prepared for Play Store deployment.
