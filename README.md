# Plant-Identifier
![Plant Identifier](https://github.com/thearsalanqureshi/Plant-Identifier/raw/badf304f62d8522c528c366710ec9bde01d22f1b/mockup%20plant%20identifier.png)

# Project-Overview
A Flutter-based plant recognition application that helps users identify plants, diagnose issues, calculate water needs, and measure light conditions using AI technology.

### Problem Statement
Plant enthusiasts struggle to identify unknown plants, diagnose health issues, determine proper watering schedules, and assess light conditions for optimal plant care.

### Solution
Developed a comprehensive 4-feature mobile app leveraging Google's Gemini AI for visual recognition and analysis.

### Key Feature
1. **Identify** - Instant plant species recognition from photos
2. **Diagnose** - Plant health issue detection and treatment recommendations
3. **Water Calculator** - Personalized watering schedules based on plant type
4. **Light Meter** - Ambient light measurement for optimal placement

### Frontend:
- Flutter 

### Backend
- Firebase (Analytics, Crashlytics, Push Notifications, In-App Messaging) 
- AI/ML: Google Gemini API 
- Local Storage: Hive 
- State Management: Provider 
- Architecture: MVVM (Model-View-ViewModel)

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

