# Technical Design Document: 360-Degree Reflection iOS Application

## 1. Requirements Breakdown

Based on the PRD, I've broken down the application into the following incremental requirements that can be released in phases:

1. **Core App Infrastructure**: Basic app setup with data storage structure and navigation
2. **Data Acquisition - Phone Usage**: Tracking screen time, app usage, and device unlocks
3. **Data Acquisition - Apple Watch Integration**: Health metrics from Apple Watch
4. **Data Acquisition - User Input**: Journal entries and mood tracking
5. **Data Analysis - Health Metrics**: Analysis of activity, sleep, and heart rate data
6. **Data Analysis - Productivity Assessment**: Analysis of phone usage patterns
7. **Data Analysis - Correlation Engine**: Finding relationships between different data points
8. **Report Generation - Daily Summary**: Basic daily reflection report
9. **Report Generation - Data Visualization**: Enhanced visualizations of user data
10. **Goal Setting and Tracking**: Creating and managing life goals
11. **Report-Goal Integration**: Connecting daily insights to goal progress
12. **Personalization and Settings**: UI customization and preference management

## 2. Requirement 1: Core App Infrastructure

### 2.1 Details and Target

This requirement establishes the foundation of the application, including:
- Core data storage architecture
- Basic navigation structure
- Essential data models
- Settings management
- Local persistence

**Target**: Create a functional app shell that will support all future requirements with a scalable architecture.

### 2.2 UI Design and User Interactions

The initial UI will consist of a tab-based navigation system with the following main sections:

1. **Dashboard Tab**: Will eventually show daily summary and insights
2. **Journal Tab**: For user input of thoughts and reflections
3. **Reports Tab**: For viewing generated reports
4. **Goals Tab**: For setting and tracking goals
5. **Settings Tab**: For app configuration

![Tab Bar Navigation](placeholder)

For the initial release, these tabs will contain placeholder content with explanations of upcoming features.

### 2.3 Code Structure

The application will follow the MVVM (Model-View-ViewModel) architecture pattern with Combine for reactive programming.

#### Project Structure:
```
360Reflection/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── AppCoordinator.swift
├── Core/
│   ├── Extensions/
│   ├── Protocols/
│   ├── Utilities/
│   └── Constants/
├── Data/
│   ├── LocalStorage/
│   │   ├── CoreDataManager.swift
│   │   └── UserDefaultsManager.swift
│   ├── Models/
│   │   ├── CoreData/
│   │   └── DTO/
│   └── Repositories/
├── Features/
│   ├── Dashboard/
│   ├── Journal/
│   ├── Reports/
│   ├── Goals/
│   └── Settings/
├── Resources/
│   ├── Assets.xcassets
│   └── LaunchScreen.storyboard
└── Views/
    ├── Components/
    └── Helpers/
```

### 2.4 Entities and Functions

#### Entities

1. **User**
   - Properties: id, name, birthdate, gender, height, weight, onboardingCompleted
   - Dependencies: None

2. **AppSettings**
   - Properties: id, notificationsEnabled, dailyReportTime, theme, privacySettings
   - Dependencies: User

#### Core Data Models

```swift
// CoreDataModels.swift
extension User {
    @NSManaged public var id: UUID
    @NSManaged public var name: String?
    @NSManaged public var birthdate: Date?
    @NSManaged public var gender: String?
    @NSManaged public var height: Double
    @NSManaged public var weight: Double
    @NSManaged public var onboardingCompleted: Bool
    @NSManaged public var settings: AppSettings?
}

extension AppSettings {
    @NSManaged public var id: UUID
    @NSManaged public var notificationsEnabled: Bool
    @NSManaged public var dailyReportTime: Date
    @NSManaged public var theme: String
    @NSManaged public var privacySettings: Data? // JSON serialized settings
    @NSManaged public var user: User?
}
```

#### Key Functions

1. **CoreDataManager**
   ```swift
   protocol CoreDataManaging {
       func saveContext()
       func fetch<T: NSManagedObject>(entityName: String, predicate: NSPredicate?) -> [T]
       func create<T: NSManagedObject>(entityName: String) -> T
       func delete(object: NSManagedObject)
   }
   
   class CoreDataManager: CoreDataManaging {
       static let shared = CoreDataManager()
       var persistentContainer: NSPersistentContainer
       
       // Implementation of protocol methods
   }
   ```
   Dependencies: None

2. **UserDefaultsManager**
   ```swift
   protocol UserDefaultsManaging {
       func set<T>(value: T, forKey key: String)
       func get<T>(forKey key: String) -> T?
       func remove(forKey key: String)
   }
   
   class UserDefaultsManager: UserDefaultsManaging {
       static let shared = UserDefaultsManager()
       
       // Implementation of protocol methods
   }
   ```
   Dependencies: None

3. **AppCoordinator**
   ```swift
   protocol Coordinating {
       func start()
       func showDashboard()
       func showJournal()
       func showReports()
       func showGoals()
       func showSettings()
   }
   
   class AppCoordinator: Coordinating {
       private let window: UIWindow
       private let tabBarController = UITabBarController()
       
       // Implementation of protocol methods
   }
   ```
   Dependencies: TabBarController, ViewControllers for each tab

4. **UserRepository**
   ```swift
   protocol UserRepositoryProtocol {
       func getCurrentUser() -> User?
       func createUser(name: String?, birthdate: Date?, gender: String?, height: Double, weight: Double) -> User
       func updateUser(_ user: User)
       func deleteUser(_ user: User)
   }
   
   class UserRepository: UserRepositoryProtocol {
       private let coreDataManager: CoreDataManaging
       
       // Implementation of protocol methods
   }
   ```
   Dependencies: CoreDataManager

## 3. Requirement 2: Data Acquisition - Phone Usage

### 3.1 Details and Target

This requirement focuses on collecting phone usage data using Apple's ScreenTime API, including:
- Total screen time
- App usage duration by category
- Number of device unlocks
- Notifications received

**Target**: Collect user's phone usage data for analysis and reporting.

### 3.2 UI Design and User Interactions

The UI will include:

1. **Onboarding Screen**: Explaining what data will be collected and requesting necessary permissions
2. **Dashboard Widget**: Showing summary of today's phone usage
3. **Detail View**: Accessible from the dashboard, showing detailed breakdown of usage

User interactions:
- Grant permission for screen time access
- View current day's usage statistics
- Navigate to detailed breakdown by app category

### 3.3 Code Structure

We'll add new components to the existing architecture:

```
Features/
├── PhoneUsage/
│   ├── ViewModels/
│   │   ├── PhoneUsageViewModel.swift
│   │   └── AppCategoryViewModel.swift
│   ├── Views/
│   │   ├── PhoneUsageSummaryView.swift
│   │   ├── PhoneUsageDetailView.swift
│   │   └── AppCategoryBreakdownView.swift
│   └── Services/
│       └── ScreenTimeService.swift
Data/
├── Models/
│   └── PhoneUsage/
│       ├── PhoneUsageData.swift
│       ├── AppUsage.swift
│       └── AppCategory.swift
└── Repositories/
    └── PhoneUsageRepository.swift
```

### 3.4 Entities and Functions

#### Entities

1. **PhoneUsageData**
   ```swift
   struct PhoneUsageData: Codable {
       let id: UUID
       let date: Date
       let totalScreenTime: TimeInterval
       let unlockCount: Int
       let notificationCount: Int
       let appUsages: [AppUsage]
   }
   ```
   Dependencies: AppUsage

2. **AppUsage**
   ```swift
   struct AppUsage: Codable {
       let bundleIdentifier: String
       let appName: String
       let category: AppCategory
       let usageDuration: TimeInterval
       let launchCount: Int
   }
   ```
   Dependencies: AppCategory

3. **AppCategory**
   ```swift
   enum AppCategory: String, Codable {
       case productivity
       case social
       case entertainment
       case education
       case health
       case games
       case utility
       case other
   }
   ```
   Dependencies: None

#### Core Data Models

```swift
extension PhoneUsageDataEntity {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var totalScreenTime: Double
    @NSManaged public var unlockCount: Int32
    @NSManaged public var notificationCount: Int32
    @NSManaged public var appUsages: Data // JSON serialized [AppUsage]
}
```

#### Key Functions

1. **ScreenTimeService**
   ```swift
   protocol ScreenTimeServiceProtocol {
       func requestAuthorization() async -> Bool
       func fetchTodayUsage() async -> PhoneUsageData?
       func fetchUsageForDate(_ date: Date) async -> PhoneUsageData?
       func fetchUsageForDateRange(start: Date, end: Date) async -> [PhoneUsageData]
   }
   
   class ScreenTimeService: ScreenTimeServiceProtocol {
       // Implementation using Apple's ScreenTime API
   }
   ```
   Dependencies: Apple ScreenTime API

2. **PhoneUsageRepository**
   ```swift
   protocol PhoneUsageRepositoryProtocol {
       func savePhoneUsageData(_ data: PhoneUsageData)
       func getPhoneUsageData(for date: Date) -> PhoneUsageData?
       func getPhoneUsageDataRange(from: Date, to: Date) -> [PhoneUsageData]
   }
   
   class PhoneUsageRepository: PhoneUsageRepositoryProtocol {
       private let coreDataManager: CoreDataManaging
       
       // Implementation of protocol methods
   }
   ```
   Dependencies: CoreDataManager, PhoneUsageDataEntity

3. **PhoneUsageViewModel**
   ```swift
   class PhoneUsageViewModel: ObservableObject {
       @Published var todayUsage: PhoneUsageData?
       @Published var isLoading: Bool = false
       @Published var error: Error?
       
       private let screenTimeService: ScreenTimeServiceProtocol
       private let phoneUsageRepository: PhoneUsageRepositoryProtocol
       
       func refreshTodayUsage() async
       func fetchHistoricalData(days: Int) async -> [PhoneUsageData]
       func getProductivityRatio(from data: PhoneUsageData) -> Double
   }
   ```
   Dependencies: ScreenTimeService, PhoneUsageRepository

## 4. Requirement 3: Data Acquisition - Apple Watch Integration

### 4.1 Details and Target

This requirement focuses on integrating with Apple Watch and HealthKit to collect health and activity data, including:
- Step count
- Heart rate (resting and active)
- Sleep data (duration and stages)
- Workout data
- Stand hours and active energy

**Target**: Collect comprehensive health data from the user's Apple Watch for analysis and reporting.

### 4.2 UI Design and User Interactions

The UI will include:

1. **Health Data Permission Screen**: Request access to HealthKit data
2. **Dashboard Widgets**: 
   - Activity rings showing progress
   - Heart rate summary
   - Sleep summary
3. **Detailed Health Views**:
   - Activity detail view with charts
   - Heart rate tracking view
   - Sleep analysis view

User interactions:
- Grant HealthKit permissions
- View health data summaries
- Tap on widgets to see detailed views with historical data

### 4.3 Code Structure

```
Features/
├── HealthData/
│   ├── ViewModels/
│   │   ├── HealthDataViewModel.swift
│   │   ├── ActivityViewModel.swift
│   │   ├── HeartRateViewModel.swift
│   │   └── SleepViewModel.swift
│   ├── Views/
│   │   ├── HealthDataSummaryView.swift
│   │   ├── ActivityDetailView.swift
│   │   ├── HeartRateDetailView.swift
│   │   └── SleepDetailView.swift
│   └── Services/
│       └── HealthKitService.swift
Data/
├── Models/
│   └── HealthData/
│       ├── ActivityData.swift
│       ├── HeartRateData.swift
│       ├── SleepData.swift
│       └── WorkoutData.swift
└── Repositories/
    └── HealthDataRepository.swift
WatchExtension/
├── ComplicationController.swift
├── ExtensionDelegate.swift
└── HealthDataProvider.swift
```

### 4.4 Entities and Functions

#### Entities

1. **ActivityData**
   ```swift
   struct ActivityData: Codable {
       let id: UUID
       let date: Date
       let activeEnergyBurned: Double // in calories
       let steps: Int
       let distance: Double // in meters
       let flightsClimbed: Int
       let standHours: Int
       let exerciseMinutes: Int
   }
   ```
   Dependencies: None

2. **HeartRateData**
   ```swift
   struct HeartRateData: Codable {
       let id: UUID
       let date: Date
       let readings: [HeartRateReading]
       let averageHeartRate: Double
       let restingHeartRate: Double?
       let maxHeartRate: Double?
       let minHeartRate: Double?
   }
   
   struct HeartRateReading: Codable {
       let timestamp: Date
       let value: Double // in BPM
       let motionContext: MotionContext
   }
   
   enum MotionContext: String, Codable {
       case active
       case sedentary
       case unknown
   }
   ```
   Dependencies: None

3. **SleepData**
   ```swift
   struct SleepData: Codable {
       let id: UUID
       let date: Date // the night of the sleep (starting date)
       let bedTime: Date
       let wakeTime: Date
       let totalSleepTime: TimeInterval
       let deepSleepTime: TimeInterval
       let remSleepTime: TimeInterval
       let lightSleepTime: TimeInterval
       let awakeTime: TimeInterval
       let sleepQualityScore: Int? // 0-100 (optional, derived)
   }
   ```
   Dependencies: None

4. **WorkoutData**
   ```swift
   struct WorkoutData: Codable {
       let id: UUID
       let startDate: Date
       let endDate: Date
       let workoutType: WorkoutType
       let duration: TimeInterval
       let energyBurned: Double? // in calories
       let distance: Double? // in meters
       let averageHeartRate: Double?
       let maxHeartRate: Double?
   }
   
   enum WorkoutType: String, Codable {
       case running, walking, cycling, swimming, hiking, yoga, strength, functional
       case other
   }
   ```
   Dependencies: None

#### Core Data Models

```swift
// These entities will be created in the Core Data model
extension ActivityDataEntity {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var activeEnergyBurned: Double
    @NSManaged public var steps: Int32
    @NSManaged public var distance: Double
    @NSManaged public var flightsClimbed: Int32
    @NSManaged public var standHours: Int32
    @NSManaged public var exerciseMinutes: Int32
}

// Similar extensions for HeartRateDataEntity, SleepDataEntity, and WorkoutDataEntity
```

#### Key Functions

1. **HealthKitService**
   ```swift
   protocol HealthKitServiceProtocol {
       func requestAuthorization() async -> Bool
       func fetchTodayActivity() async -> ActivityData?
       func fetchHeartRateData(for date: Date) async -> HeartRateData?
       func fetchSleepData(for date: Date) async -> SleepData?
       func fetchWorkouts(from startDate: Date, to endDate: Date) async -> [WorkoutData]
       func observeHealthData(types: [HKSampleType]) -> AnyPublisher<HKObserverQuery, Never>
   }
   
   class HealthKitService: HealthKitServiceProtocol {
       private let healthStore = HKHealthStore()
       
       // Implementation of protocol methods
   }
   ```
   Dependencies: HealthKit framework

2. **HealthDataRepository**
   ```swift
   protocol HealthDataRepositoryProtocol {
       func saveActivityData(_ data: ActivityData)
       func saveHeartRateData(_ data: HeartRateData)
       func saveSleepData(_ data: SleepData)
       func saveWorkoutData(_ data: WorkoutData)
       
       func getActivityData(for date: Date) -> ActivityData?
       func getHeartRateData(for date: Date) -> HeartRateData?
       func getSleepData(for date: Date) -> SleepData?
       func getWorkouts(from startDate: Date, to endDate: Date) -> [WorkoutData]
   }
   
   class HealthDataRepository: HealthDataRepositoryProtocol {
       private let coreDataManager: CoreDataManaging
       
       // Implementation of protocol methods
   }
   ```
   Dependencies: CoreDataManager, Core Data entities for health data

3. **HealthDataViewModel**
   ```swift
   class HealthDataViewModel: ObservableObject {
       @Published var todayActivity: ActivityData?
       @Published var todayHeartRate: HeartRateData?
       @Published var lastNightSleep: SleepData?
       @Published var recentWorkouts: [WorkoutData] = []
       @Published var isLoading: Bool = false
       @Published var error: Error?
       
       private let healthKitService: HealthKitServiceProtocol
       private let healthDataRepository: HealthDataRepositoryProtocol
       
       func requestHealthKitPermissions() async
       func refreshHealthData() async
       func fetchHistoricalActivityData(days: Int) async -> [ActivityData]
       func calculateActivityTrends() -> ActivityTrends
   }
   ```
   Dependencies: HealthKitService, HealthDataRepository

## 5. Requirement 4: Data Acquisition - User Input

### 5.1 Details and Target

This requirement focuses on allowing users to record their thoughts, reflections, and mood through:
- Journal entries (text and potentially voice)
- Mood tracking
- Manual recording of activities not captured by sensors
- Tagging and categorization of entries

**Target**: Enable users to input subjective data to complement the objective data collected from the device.

### 5.2 UI Design and User Interactions

The UI will include:

1. **Journal Tab**: 
   - List of past journal entries
   - Create new entry button
   - Calendar view for navigating past entries

2. **New Entry View**:
   - Text editor for thoughts
   - Mood selector (emoji scale)
   - Activity tagging interface
   - Category selection

3. **Entry Detail View**:
   - Full journal entry
   - Associated mood and activities
   - Edit option

User interactions:
- Create, edit, and delete journal entries
- Record daily mood
- Tag entries with categories
- Record activities not tracked automatically

### 5.3 Code Structure

```
Features/
├── Journal/
│   ├── ViewModels/
│   │   ├── JournalViewModel.swift
│   │   ├── EntryViewModel.swift
│   │   └── MoodTrackingViewModel.swift
│   ├── Views/
│   │   ├── JournalListView.swift
│   │   ├── NewEntryView.swift
│   │   ├── EntryDetailView.swift
│   │   ├── MoodSelectorView.swift
│   │   └── ActivityTaggingView.swift
│   └── Services/
│       └── TextAnalysisService.swift
Data/
├── Models/
│   └── Journal/
│       ├── JournalEntry.swift
│       ├── Mood.swift
│       ├── Activity.swift
│       └── EntryCategory.swift
└── Repositories/
    └── JournalRepository.swift
```

### 5.4 Entities and Functions

#### Entities

1. **JournalEntry**
   ```swift
   struct JournalEntry: Codable, Identifiable {
       let id: UUID
       let timestamp: Date
       var title: String
       var content: String
       var mood: Mood?
       var activities: [Activity]
       var categories: [EntryCategory]
       var audioRecordingURL: URL?
   }
   ```
   Dependencies: Mood, Activity, EntryCategory

2. **Mood**
   ```swift
   struct Mood: Codable {
       let value: Int // 1-5 scale
       let emoji: String
       let label: String
       
       static let veryNegative = Mood(value: 1, emoji: "😞", label: "Very Bad")
       static let negative = Mood(value: 2, emoji: "😕", label: "Bad")
       static let neutral = Mood(value: 3, emoji: "😐", label: "Neutral")
       static let positive = Mood(value: 4, emoji: "🙂", label: "Good")
       static let veryPositive = Mood(value: 5, emoji: "😃", label: "Very Good")
   }
   ```
   Dependencies: None

3. **Activity**
   ```swift
   struct Activity: Codable, Identifiable {
       let id: UUID
       let name: String
       let category: ActivityCategory
       let duration: TimeInterval?
       let isManuallyLogged: Bool
   }
   
   enum ActivityCategory: String, Codable {
       case work
       case exercise
       case leisure
       case socializing
       case learning
       case selfCare
       case chores
       case other
   }
   ```
   Dependencies: None

4. **EntryCategory**
   ```swift
   struct EntryCategory: Codable, Identifiable {
       let id: UUID
       let name: String
       let color: String // Hex color code
       
       static let gratitude = EntryCategory(id: UUID(), name: "Gratitude", color: "#FFD700")
       static let challenge = EntryCategory(id: UUID(), name: "Challenge", color: "#FF6347")
       static let accomplishment = EntryCategory(id: UUID(), name: "Accomplishment", color: "#4682B4")
       static let idea = EntryCategory(id: UUID(), name: "Idea", color: "#32CD32")
       // More predefined categories...
   }
   ```
   Dependencies: None

#### Core Data Models

```swift
extension JournalEntryEntity {
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var moodValue: Int16
    @NSManaged public var activities: Data // JSON serialized [Activity]
    @NSManaged public var categories: Data // JSON serialized [EntryCategory]
    @NSManaged public var audioRecordingPath: String?
}
```

#### Key Functions

1. **JournalRepository**
   ```swift
   protocol JournalRepositoryProtocol {
       func saveEntry(_ entry: JournalEntry)
       func getEntry(id: UUID) -> JournalEntry?
       func getEntries(for date: Date) -> [JournalEntry]
       func getEntries(from startDate: Date, to endDate: Date) -> [JournalEntry]
       func deleteEntry(id: UUID)
       func getEntriesByCategory(_ category: EntryCategory) -> [JournalEntry]
       func getEntriesByMoodValue(_ value: Int) -> [JournalEntry]
   }
   
   class JournalRepository: JournalRepositoryProtocol {
       private let coreDataManager: CoreDataManaging
       
       // Implementation of protocol methods
   }
   ```
   Dependencies: CoreDataManager, JournalEntryEntity

2. **TextAnalysisService**
   ```swift
   protocol TextAnalysisServiceProtocol {
       func analyzeSentiment(text: String) -> Double // -1.0 to 1.0 scale
       func extractKeywords(from text: String) -> [String]
       func suggestCategories(for text: String) -> [EntryCategory]
   }
   
   class TextAnalysisService: TextAnalysisServiceProtocol {
       // Implementation using Natural Language framework
   }
   ```
   Dependencies: Natural Language framework

3. **JournalViewModel**
   ```swift
   class JournalViewModel: ObservableObject {
       @Published var entries: [JournalEntry] = []
       @Published var selectedDate: Date = Date()
       @Published var isLoading: Bool = false
       
       private let journalRepository: JournalRepositoryProtocol
       
       func loadEntries(for date: Date)
       func loadEntries(from startDate: Date, to endDate: Date)
       func getMoodDistribution(from startDate: Date, to endDate: Date) -> [Int: Int]
       func getCategoryDistribution(from startDate: Date, to endDate: Date) -> [String: Int]
   }
   ```
   Dependencies: JournalRepository

4. **EntryViewModel**
   ```swift
   class EntryViewModel: ObservableObject {
       @Published var entry: JournalEntry
       @Published var isEditMode: Bool = false
       
       private let journalRepository: JournalRepositoryProtocol
       private let textAnalysisService: TextAnalysisServiceProtocol
       
       func saveEntry()
       func deleteEntry()
       func analyzeSentiment() -> Double
       func suggestCategories() -> [EntryCategory]
   }
   ```
   Dependencies: JournalRepository, TextAnalysisService

## 6. Requirement 5: Data Analysis - Health Metrics

### 6.1 Details and Target

This requirement focuses on analyzing the health data collected from Apple Watch to provide meaningful insights:
- Activity pattern analysis
- Sleep quality assessment
- Heart rate variability analysis
- Workout performance evaluation
- Trends and patterns identification

**Target**: Transform raw health data into actionable insights about physical well-being.

### 6.2 UI Design and User Interactions

The UI will include:

1. **Health Analysis Dashboard**:
   - Cards showing key health insights
   - Weekly and monthly trends
   - Highlight of significant changes

2. **Detailed Analysis Views**:
   - Sleep quality assessment with factors
   - Activity patterns with recommendations
   - Heart health metrics with context

User interactions:
- View health insights on dashboard
- Navigate to detailed analysis views
- Set targets for health metrics
- View historical trends

### 6.3 Code Structure

```
Features/
├── HealthAnalysis/
│   ├── ViewModels/
│   │   ├── HealthAnalysisViewModel.swift
│   │   ├── SleepAnalysisViewModel.swift
│   │   ├── ActivityAnalysisViewModel.swift
│   │   └── HeartRateAnalysisViewModel.swift
│   ├── Views/
│   │   ├── HealthInsightsView.swift
│   │   ├── SleepAnalysisDetailView.swift
│   │   ├── ActivityAnalysisDetailView.swift
│   │   └── HeartRateAnalysisDetailView.swift
│   └── Services/
│       └── HealthMetricsAnalyzer.swift
Data/
├── Models/
│   └── Analysis/
│       ├── HealthInsight.swift
│       ├── SleepQualityMetrics.swift
│       ├── ActivityPattern.swift
│       └── HeartHealthMetrics.swift
```

### 6.4 Entities and Functions

#### Entities

1. **HealthInsight**
   ```swift
   struct HealthInsight: Identifiable, Codable {
       let id: UUID
       let date: Date
       let title: String
       let description: String
       let insightType: InsightType
       let severity: InsightSeverity
       let relatedMetric: String
       let recommendation: String?
   }
   
   enum InsightType: String, Codable {
       case activity, sleep, heartRate, workout, general
   }
   
   enum InsightSeverity: String, Codable {
       case positive, neutral, suggestion, warning
   }
   ```
   Dependencies: None

2. **SleepQualityMetrics**
   ```swift
   struct SleepQualityMetrics: Codable {
       let date: Date
       let overallScore: Int // 0-100
       let deepSleepPercentage: Double
       let remSleepPercentage: Double
       let sleepContinuity: Double // 0-1 representing interruptions
       let sleepLatency: TimeInterval // time to fall asleep
       let sleepScheduleRegularity: Double // 0-1
       let factors: [SleepFactor]
   }
   
   struct SleepFactor: Codable {
       let factor: String
       let impact: Double // -1 to 1 scale
       let description: String
   }
   ```
   Dependencies: None

3. **ActivityPattern**
   ```swift
   struct ActivityPattern: Codable {
       let startDate: Date
       let endDate: Date
       let averageDailySteps: Int
       let averageActiveCalories: Double
       let mostActiveDay: Weekday
       let leastActiveDay: Weekday
       let mostActiveTimeOfDay: TimeRange
       let activityConsistency: Double // 0-1 scale
       let meetsDailyGoals: Bool
   }
   
   enum Weekday: Int, Codable {
       case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
   }
   
   struct TimeRange: Codable {
       let start: Date
       let end: Date
   }
   ```
   Dependencies: None

4. **HeartHealthMetrics**
   ```swift
   struct HeartHealthMetrics: Codable {
       let date: Date
       let averageRestingHR: Double
       let hrvScore: Double? // 0-100
       let recoveryRate: Double? // after exercise
       let cardioFitnessScore: Double? // VO2 max estimate
       let anomalies: [HeartRateAnomaly]
   }
   
   struct HeartRateAnomaly: Codable {
       let timestamp: Date
       let value: Double
       let type: AnomalyType
       let description: String
   }
   
   enum AnomalyType: String, Codable {
       case spike, dip, irregular, sustained
   }
   ```
   Dependencies: None

#### Key Functions

1. **HealthMetricsAnalyzer**
   ```swift
   protocol HealthMetricsAnalyzerProtocol {
       func analyzeSleepQuality(from data: SleepData) -> SleepQualityMetrics
       func analyzeActivityPatterns(from data: [ActivityData]) -> ActivityPattern
       func analyzeHeartHealth(from data: HeartRateData) -> HeartHealthMetrics
       func generateHealthInsights(sleepData: SleepData?, activityData: [ActivityData]?, heartRateData: HeartRateData?) -> [HealthInsight]
   }
   
   class HealthMetricsAnalyzer: HealthMetricsAnalyzerProtocol {
       // Implementation of analysis algorithms
   }
   ```
   Dependencies: Activity, Sleep, and Heart Rate data models

2. **HealthAnalysisViewModel**
   ```swift
   class HealthAnalysisViewModel: ObservableObject {
       @Published var insights: [HealthInsight] = []
       @Published var sleepQualityMetrics: SleepQualityMetrics?
       @Published var activityPattern: ActivityPattern?
       @Published var heartHealthMetrics: HeartHealthMetrics?
       @Published var isLoading: Bool = false
       
       private let healthMetricsAnalyzer: HealthMetricsAnalyzerProtocol
       private let healthDataRepository: HealthDataRepositoryProtocol
       
       func generateInsights()
       func analyzeSleepTrends(days: Int)
       func analyzeActivityTrends(days: Int)
       func analyzeHeartHealthTrends(days: Int)
   }
   ```
   Dependencies: HealthMetricsAnalyzer, HealthDataRepository

## 7. Requirement 6: Data Analysis - Productivity Assessment

### 7.1 Details and Target

This requirement focuses on analyzing phone usage data to assess productivity and digital habits:
- Productive vs. distracting app usage patterns
- Screen time trends and peak usage times
- Notification analysis
- App usage categorization
- Focus and distraction periods identification

**Target**: Provide insights on digital habits and productivity patterns to help users optimize their phone usage.

### 7.2 UI Design and User Interactions

The UI will include:

1. **Productivity Dashboard**:
   - Productivity score card
   - App usage distribution chart
   - Focus vs. distraction timeline
   - Top productivity detractors

2. **Detailed Analysis Views**:
   - App category breakdown
   - Hourly usage patterns
   - Notification impact analysis

User interactions:
- View productivity metrics
- Customize app categorizations (productive/neutral/distracting)
- Set productivity goals
- View detailed breakdown of usage

### 7.3 Code Structure

```
Features/
├── ProductivityAnalysis/
│   ├── ViewModels/
│   │   ├── ProductivityViewModel.swift
│   │   ├── AppUsageAnalysisViewModel.swift
│   │   └── DistractionAnalysisViewModel.swift
│   ├── Views/
│   │   ├── ProductivityDashboardView.swift
│   │   ├── AppCategoryBreakdownView.swift
│   │   ├── HourlyUsagePatternView.swift
│   │   └── NotificationImpactView.swift
│   └── Services/
│       └── ProductivityAnalyzer.swift
Data/
├── Models/
│   └── Productivity/
│       ├── ProductivityMetrics.swift
│       ├── AppCategoryUsage.swift
│       ├── HourlyUsagePattern.swift
│       └── DistractionEvent.swift
```

### 7.4 Entities and Functions

#### Entities

1. **ProductivityMetrics**
   ```swift
   struct ProductivityMetrics: Codable {
       let date: Date
       let productivityScore: Int // 0-100
       let focusTime: TimeInterval
       let distractionTime: TimeInterval
       let productiveAppTime: TimeInterval
       let distractingAppTime: TimeInterval
       let neutralAppTime: TimeInterval
       let unlockFrequency: Double // unlocks per hour while awake
       let longestFocusPeriod: TimeInterval
       let topProductiveApps: [String] // bundle IDs
       let topDistractingApps: [String] // bundle IDs
   }
   ```
   Dependencies: None

2. **AppCategoryUsage**
   ```swift
   struct AppCategoryUsage: Codable {
       let category: AppCategory
       let totalTime: TimeInterval
       let percentageOfTotal: Double
       let productivityImpact: ProductivityImpact
   }
   
   enum ProductivityImpact: String, Codable {
       case productive, neutral, distracting
   }
   ```
   Dependencies: AppCategory

3. **HourlyUsagePattern**
   ```swift
   struct HourlyUsagePattern: Codable {
       let date: Date
       let hourlyBreakdown: [HourData]
       let peakUsageHour: Int // 0-23
       let lowUsageHours: [Int] // 0-23
       let productivePeriods: [TimeRange]
       let distractingPeriods: [TimeRange]
   }
   
   struct HourData: Codable {
       let hour: Int // 0-23
       let screenTime: TimeInterval
       let unlockCount: Int
       let notificationCount: Int
       let dominantAppCategory: AppCategory
       let productivityScore: Int // 0-100
   }
   ```
   Dependencies: AppCategory, TimeRange

4. **DistractionEvent**
   ```swift
   struct DistractionEvent: Codable, Identifiable {
       let id: UUID
       let startTime: Date
       let duration: TimeInterval
       let triggerApp: String
       let triggerNotification: Bool
       let subsequentApps: [String]
       let context: DistractionContext?
   }
   
   enum DistractionContext: String, Codable {
       case workHours, evening, morning, weekend
       case scheduled, breakTime, unknown
   }
   ```
   Dependencies: None

#### Key Functions

1. **ProductivityAnalyzer**
   ```swift
   protocol ProductivityAnalyzerProtocol {
       func calculateProductivityMetrics(from phoneUsageData: PhoneUsageData) -> ProductivityMetrics
       func analyzeAppCategoryUsage(from phoneUsageData: PhoneUsageData) -> [AppCategoryUsage]
       func analyzeHourlyPatterns(from phoneUsageData: PhoneUsageData) -> HourlyUsagePattern
       func identifyDistractionEvents(from phoneUsageData: PhoneUsageData) -> [DistractionEvent]
   }
   
   class ProductivityAnalyzer: ProductivityAnalyzerProtocol {
       private let appCategoryClassification: [String: ProductivityImpact] // bundle ID to impact
       
       // Implementation of analysis algorithms
   }
   ```
   Dependencies: PhoneUsageData model

2. **ProductivityViewModel**
   ```swift
   class ProductivityViewModel: ObservableObject {
       @Published var productivityMetrics: ProductivityMetrics?
       @Published var appCategoryUsage: [AppCategoryUsage] = []
       @Published var hourlyPattern: HourlyUsagePattern?
       @Published var distractionEvents: [DistractionEvent] = []
       @Published var isLoading: Bool = false
       
       private let productivityAnalyzer: ProductivityAnalyzerProtocol
       private let phoneUsageRepository: PhoneUsageRepositoryProtocol
       
       func analyzeProductivity(for date: Date)
       func getProductivityTrend(days: Int) -> [ProductivityMetrics]
       func updateAppProductivityClassification(appBundle: String, impact: ProductivityImpact)
       func getTopProductivitySuggestions() -> [String]
   }
   ```
   Dependencies: ProductivityAnalyzer, PhoneUsageRepository

## 8. Requirement 7: Data Analysis - Correlation Engine

### 8.1 Details and Target

This requirement develops a correlation engine to identify relationships between different data points:
- Sleep quality vs. productivity
- Physical activity vs. mood
- App usage vs. health metrics
- Journal sentiment vs. physical metrics
- Discovery of unexpected correlations

**Target**: Identify meaningful patterns and relationships across different data sources to provide deeper insights.

### 8.2 UI Design and User Interactions

The UI will include:

1. **Correlation Dashboard**:
   - Key correlation cards
   - Strength indicators
   - Visual charts showing relationships

2. **Correlation Detail Views**:
   - Scatter plots showing relationships
   - Timeline comparison
   - Contextual explanations
   - Actionable suggestions

User interactions:
- Browse discovered correlations
- Dive into detailed correlation analysis
- Customize correlation tracking

### 8.3 Code Structure

```
Features/
├── CorrelationAnalysis/
│   ├── ViewModels/
│   │   ├── CorrelationViewModel.swift
│   │   └── CorrelationDetailViewModel.swift
│   ├── Views/
│   │   ├── CorrelationDashboardView.swift
│   │   ├── CorrelationDetailView.swift
│   │   └── CorrelationChartView.swift
│   └── Services/
│       └── CorrelationEngine.swift
Data/
├── Models/
│   └── Correlation/
│       ├── CorrelationResult.swift
│       ├── MetricRelationship.swift
│       └── CorrelationSuggestion.swift
```

### 8.4 Entities and Functions

#### Entities

1. **CorrelationResult**
   ```swift
   struct CorrelationResult: Identifiable, Codable {
       let id: UUID
       let dateGenerated: Date
       let metricX: DataMetric
       let metricY: DataMetric
       let correlationCoefficient: Double // -1 to 1
       let confidenceScore: Double // 0 to 1
       let sampleSize: Int
       let description: String
       let significance: CorrelationSignificance
   }
   
   enum CorrelationSignificance: String, Codable {
       case strong, moderate, weak, none
   }
   ```
   Dependencies: DataMetric

2. **DataMetric**
   ```swift
   struct DataMetric: Codable {
       let id: String
       let name: String
       let category: MetricCategory
       let unit: String?
       let extractionPath: String // Path to extract this metric from source data
   }
   
   enum MetricCategory: String, Codable {
       case health, sleep, activity, phoneUsage, mood, productivity
   }
   ```
   Dependencies: None

3. **MetricRelationship**
   ```swift
   struct MetricRelationship: Codable {
       let metricX: DataMetric
       let metricY: DataMetric
       let dataPoints: [DataPoint]
       let timeShift: TimeInterval? // For potential lagged correlations
   }
   
   struct DataPoint: Codable {
       let date: Date
       let valueX: Double
       let valueY: Double
   }
   ```
   Dependencies: DataMetric

4. **CorrelationSuggestion**
   ```swift
   struct CorrelationSuggestion: Identifiable, Codable {
       let id: UUID
       let correlationResult: CorrelationResult
       let actionableInsight: String
       let suggestedChange: String
       let expectedImpact: String
       let priority: Int // 1-5, 5 being highest
   }
   ```
   Dependencies: CorrelationResult

#### Key Functions

1. **CorrelationEngine**
   ```swift
   protocol CorrelationEngineProtocol {
       func findCorrelations(metrics: [DataMetric], minimumDays: Int) -> [CorrelationResult]
       func analyzeRelationship(metricX: DataMetric, metricY: DataMetric) -> MetricRelationship?
       func generateSuggestions(from correlations: [CorrelationResult]) -> [CorrelationSuggestion]
       func getAvailableMetrics() -> [DataMetric]
   }
   
   class CorrelationEngine: CorrelationEngineProtocol {
       private let healthDataRepository: HealthDataRepositoryProtocol
       private let phoneUsageRepository: PhoneUsageRepositoryProtocol
       private let journalRepository: JournalRepositoryProtocol
       
       // Implementation of correlation algorithms
   }
   ```
   Dependencies: HealthDataRepository, PhoneUsageRepository, JournalRepository

2. **CorrelationViewModel**
   ```swift
   class CorrelationViewModel: ObservableObject {
       @Published var correlations: [CorrelationResult] = []
       @Published var suggestions: [CorrelationSuggestion] = []
       @Published var selectedCorrelation: CorrelationResult?
       @Published var isLoading: Bool = false
       
       private let correlationEngine: CorrelationEngineProtocol
       
       func discoverCorrelations(minDays: Int = 7)
       func getDetailedRelationship(for correlation: CorrelationResult) -> MetricRelationship?
       func getTopCorrelations(limit: Int) -> [CorrelationResult]
       func getSuggestionsByPriority() -> [CorrelationSuggestion]
   }
   ```
   Dependencies: CorrelationEngine

## 9. Requirement 8: Report Generation - Daily Summary

### 9.1 Details and Target

This requirement focuses on generating comprehensive daily reflection reports that summarize:
- Health and activity summary
- Productivity assessment
- Journal entries and mood
- Insights and correlations
- Progress toward goals

**Target**: Provide users with a holistic daily summary that integrates all collected data and derived insights.

### 9.2 UI Design and User Interactions

The UI will include:

1. **Daily Report Dashboard**:
   - Daily summary card
   - Health highlights
   - Productivity snapshot
   - Mood and journal highlights
   - Key insights and correlations

2. **Report Detail Sections**:
   - Health details with metrics
   - Productivity breakdown
   - Journal entries for the day
   - Discovered correlations
   - Goal progress indicators

User interactions:
- View daily report summary
- Navigate between report sections
- Set preferred report generation time
- Save or share reports

### 9.3 Code Structure

```
Features/
├── DailyReport/
│   ├── ViewModels/
│   │   ├── DailyReportViewModel.swift
│   │   ├── ReportHealthSectionViewModel.swift
│   │   ├── ReportProductivitySectionViewModel.swift
│   │   └── ReportInsightSectionViewModel.swift
│   ├── Views/
│   │   ├── DailyReportView.swift
│   │   ├── ReportHealthSectionView.swift
│   │   ├── ReportProductivitySectionView.swift
│   │   ├── ReportJournalSectionView.swift
│   │   └── ReportInsightSectionView.swift
│   └── Services/
│       └── ReportGenerator.swift
Data/
├── Models/
│   └── Report/
│       ├── DailyReport.swift
│       ├── ReportSection.swift
│       └── ReportInsight.swift
```

### 9.4 Entities and Functions

#### Entities

1. **DailyReport**
   ```swift
   struct DailyReport: Identifiable, Codable {
       let id: UUID
       let date: Date
       let generatedAt: Date
       let overallScore: Int? // Optional overall day score (0-100)
       let healthSummary: HealthSummary
       let productivitySummary: ProductivitySummary
       let journalSummary: JournalSummary
       let insights: [ReportInsight]
       let goalProgress: [GoalProgress]?
   }
   ```
   Dependencies: HealthSummary, ProductivitySummary, JournalSummary, ReportInsight, GoalProgress

2. **HealthSummary**
   ```swift
   struct HealthSummary: Codable {
       let activeCalories: Double
       let steps: Int
       let exerciseMinutes: Int
       let standHours: Int
       let averageHeartRate: Double?
       let sleepDuration: TimeInterval?
       let sleepQuality: Int? // 0-100
       let restingHeartRate: Double?
       let workouts: [WorkoutBrief]
   }
   
   struct WorkoutBrief: Codable {
       let type: String
       let duration: TimeInterval
       let calories: Double?
   }
   ```
   Dependencies: None

3. **ProductivitySummary**
   ```swift
   struct ProductivitySummary: Codable {
       let productivityScore: Int // 0-100
       let screenTime: TimeInterval
       let unlockCount: Int
       let productiveAppTime: TimeInterval
       let distractingAppTime: TimeInterval
       let focusTime: TimeInterval
       let distractionTime: TimeInterval
       let topProductiveApp: String
       let topDistractingApp: String
   }
   ```
   Dependencies: None

4. **JournalSummary**
   ```swift
   struct JournalSummary: Codable {
       let entryCount: Int
       let mood: Mood?
       let dominantSentiment: Double? // -1 to 1
       let keywords: [String]
       let categories: [String]
   }
   ```
   Dependencies: Mood

5. **ReportInsight**
   ```swift
   struct ReportInsight: Identifiable, Codable {
       let id: UUID
       let title: String
       let description: String
       let category: InsightCategory
       let priority: Int // 1-5, 5 being highest
       let isActionable: Bool
       let suggestion: String?
   }
   
   enum InsightCategory: String, Codable {
       case health, productivity, correlation, mood, goal, habit
   }
   ```
   Dependencies: None

6. **GoalProgress**
   ```swift
   struct GoalProgress: Codable {
       let goalId: UUID
       let goalName: String
       let progress: Double // 0.0 to 1.0
       let currentValue: Double?
       let targetValue: Double?
       let unit: String?
       let contributionToday: Double? // How much progress was made today
   }
   ```
   Dependencies: None

#### Key Functions

1. **ReportGenerator**
   ```swift
   protocol ReportGeneratorProtocol {
       func generateDailyReport(for date: Date) -> DailyReport
       func generateHealthSummary(for date: Date) -> HealthSummary
       func generateProductivitySummary(for date: Date) -> ProductivitySummary
       func generateJournalSummary(for date: Date) -> JournalSummary
       func generateInsights(healthSummary: HealthSummary, productivitySummary: ProductivitySummary, journalSummary: JournalSummary) -> [ReportInsight]
   }
   
   class ReportGenerator: ReportGeneratorProtocol {
       private let healthDataRepository: HealthDataRepositoryProtocol
       private let phoneUsageRepository: PhoneUsageRepositoryProtocol
       private let journalRepository: JournalRepositoryProtocol
       private let correlationEngine: CorrelationEngineProtocol
       private let goalRepository: GoalRepositoryProtocol?
       
       // Implementation of report generation logic
   }
   ```
   Dependencies: HealthDataRepository, PhoneUsageRepository, JournalRepository, CorrelationEngine, GoalRepository

2. **DailyReportViewModel**
   ```swift
   class DailyReportViewModel: ObservableObject {
       @Published var report: DailyReport?
       @Published var selectedDate: Date = Date()
       @Published var isLoading: Bool = false
       @Published var selectedSection: ReportSection = .summary
       
       private let reportGenerator: ReportGeneratorProtocol
       private let reportRepository: ReportRepositoryProtocol
       
       func generateReport(for date: Date)
       func loadExistingReport(for date: Date)
       func getReportHistory(days: Int) -> [DailyReport]
       func shareReport() -> URL?
   }
   
   enum ReportSection: String, CaseIterable {
       case summary, health, productivity, journal, insights, goals
   }
   ```
   Dependencies: ReportGenerator, ReportRepository

## 10. Requirement 9: Report Generation - Data Visualization

### 10.1 Details and Target

This requirement focuses on creating compelling data visualizations to make reports more engaging and informative:
- Interactive charts and graphs
- Timeline visualizations
- Heat maps for patterns
- Progress indicators
- Comparative visualizations

**Target**: Transform data and insights into visually appealing and easily understandable graphics that enhance the user experience.

### 10.2 UI Design and User Interactions

The UI will include:

1. **Visualization Components**:
   - Line charts for trends
   - Bar charts for comparisons
   - Pie charts for distributions
   - Heat maps for patterns
   - Progress wheels and gauges

2. **Interactive Elements**:
   - Zoom and pan functionality
   - Tap for details
   - Time range selectors
   - Data point highlighting

User interactions:
- Interact with charts to explore data
- Customize visualization preferences
- Share visualizations
- Select different visualization types for the same data

### 10.3 Code Structure

```
Features/
├── DataVisualization/
│   ├── ViewModels/
│   │   ├── ChartViewModel.swift
│   │   ├── TimelineViewModel.swift
│   │   └── ComparisonViewModel.swift
│   ├── Views/
│   │   ├── LineChartView.swift
│   │   ├── BarChartView.swift
│   │   ├── PieChartView.swift
│   │   ├── HeatMapView.swift
│   │   ├── TimelineView.swift
│   │   └── ProgressIndicatorView.swift
│   └── Components/
│       ├── ChartAxesView.swift
│       ├── LegendView.swift
│       ├── TooltipView.swift
│       └── InteractionOverlayView.swift
Core/
├── Charts/
│   ├── ChartData.swift
│   ├── ChartConfiguration.swift
│   └── ChartAnimator.swift
```

### 10.4 Entities and Functions

#### Entities

1. **ChartData**
   ```swift
   struct ChartData: Codable {
       let title: String
       let description: String?
       let xAxisLabel: String?
       let yAxisLabel: String?
       let dataPoints: [DataPoint]
       let seriesName: String
       let color: String
   }
   
   struct MultiSeriesChartData: Codable {
       let title: String
       let description: String?
       let xAxisLabel: String?
       let yAxisLabel: String?
       let series: [ChartSeries]
   }
   
   struct ChartSeries: Codable {
       let name: String
       let color: String
       let dataPoints: [DataPoint]
   }
   
   struct DataPoint: Codable {
       let x: ChartValue
       let y: ChartValue
       let label: String?
   }
   
   enum ChartValue: Codable {
       case number(Double)
       case date(Date)
       case string(String)
   }
   ```
   Dependencies: None

2. **ChartConfiguration**
   ```swift
   struct ChartConfiguration: Codable {
       let chartType: ChartType
       let showLegend: Bool
       let showAxes: Bool
       let showGridLines: Bool
       let enableInteraction: Bool
       let animate: Bool
       let colorScheme: ColorScheme
       let customColors: [String]?
   }
   
   enum ChartType: String, Codable {
       case line, bar, pie, scatter, heatMap, area, timeline, gauge
   }
   
   enum ColorScheme: String, Codable {
       case standard, health, productivity, sequential, diverging, categorical
   }
   ```
   Dependencies: None

#### Key Functions

1. **ChartViewModel**
   ```swift
   class ChartViewModel: ObservableObject {
       @Published var chartData: ChartData?
       @Published var multiSeriesData: MultiSeriesChartData?
       @Published var configuration: ChartConfiguration
       @Published var isLoading: Bool = false
       
       func loadHealthDataChart(metric: HealthMetricType, timeRange: TimeRange)
       func loadProductivityChart(metric: ProductivityMetricType, timeRange: TimeRange)
       func loadComparisonChart(metricX: MetricType, metricY: MetricType, timeRange: TimeRange)
       func updateChartType(type: ChartType)
       func updateColorScheme(scheme: ColorScheme)
   }
   
   enum MetricType: String {
       case health(HealthMetricType)
       case productivity(ProductivityMetricType)
       case journal(JournalMetricType)
   }
   
   enum HealthMetricType: String {
       case steps, activeCalories, heartRate, sleepDuration, sleepQuality
   }
   
   enum ProductivityMetricType: String {
       case screenTime, productivityScore, focusTime, distractionTime, unlockCount
   }
   
   enum JournalMetricType: String {
       case mood, sentimentScore, entryCount, categoryCount
   }
   ```
   Dependencies: HealthDataRepository, PhoneUsageRepository, JournalRepository

2. **ChartAnimator**
   ```swift
   protocol ChartAnimating {
       func animateIn(duration: TimeInterval, delay: TimeInterval)
       func animateChange(duration: TimeInterval)
       func getCurrentAnimationState() -> Double
   }
   
   class ChartAnimator: ChartAnimating {
       // Implementation of animation logic
   }
   ```
   Dependencies: None

## 11. Requirement 10: Goal Setting and Tracking

### 11.1 Details and Target

This requirement focuses on allowing users to define and track personal goals:
- Short and long-term goal creation
- Goal categorization and prioritization
- Progress tracking
- Deadline management
- Goal breakdown into actionable steps

**Target**: Help users define meaningful life goals and track their progress over time.

### 11.2 UI Design and User Interactions

The UI will include:

1. **Goals Dashboard**:
   - Goal cards with progress indicators
   - Goal categories and filter options
   - Add new goal button
   - Timeline view of upcoming deadlines

2. **Goal Detail View**:
   - Goal description and target
   - Progress visualization
   - Sub-goals or steps
   - Related metrics tracking
   - Edit and update options

User interactions:
- Create, edit, and delete goals
- Track progress manually or automatically
- Set deadlines and reminders
- Break down goals into steps
- View goal history and achievements

### 11.3 Code Structure

```
Features/
├── Goals/
│   ├── ViewModels/
│   │   ├── GoalsViewModel.swift
│   │   ├── GoalDetailViewModel.swift
│   │   └── GoalCreationViewModel.swift
│   ├── Views/
│   │   ├── GoalsDashboardView.swift
│   │   ├── GoalDetailView.swift
│   │   ├── CreateGoalView.swift
│   │   ├── GoalProgressView.swift
│   │   └── GoalStepListView.swift
│   └── Services/
│       └── GoalTrackingService.swift
Data/
├── Models/
│   └── Goals/
│       ├── Goal.swift
│       ├── GoalStep.swift
│       ├── GoalCategory.swift
│       └── GoalMetricTracking.swift
└── Repositories/
    └── GoalRepository.swift
```

### 11.4 Entities and Functions

#### Entities

1. **Goal**
   ```swift
   struct Goal: Identifiable, Codable {
       let id: UUID
       var title: String
       var description: String
       var category: GoalCategory
       var priority: GoalPriority
       var targetDate: Date?
       var isCompleted: Bool
       var completedDate: Date?
       var createdDate: Date
       var progress: Double // 0.0 to 1.0
       var steps: [GoalStep]
       var metricTracking: GoalMetricTracking?
       var reminderFrequency: ReminderFrequency?
   }
   
   enum GoalPriority: Int, Codable {
       case low = 1, medium, high
   }
   
   enum ReminderFrequency: String, Codable {
       case daily, weekly, monthly, none
   }
   ```
   Dependencies: GoalCategory, GoalStep, GoalMetricTracking

2. **GoalCategory**
   ```swift
   struct GoalCategory: Identifiable, Codable {
       let id: UUID
       let name: String
       let color: String
       let icon: String
       
       static let health = GoalCategory(id: UUID(), name: "Health", color: "#4CAF50", icon: "heart.fill")
       static let career = GoalCategory(id: UUID(), name: "Career", color: "#2196F3", icon: "briefcase.fill")
       static let personal = GoalCategory(id: UUID(), name: "Personal", color: "#9C27B0", icon: "person.fill")
       static let learning = GoalCategory(id: UUID(), name: "Learning", color: "#FF9800", icon: "book.fill")
       static let financial = GoalCategory(id: UUID(), name: "Financial", color: "#607D8B", icon: "dollarsign.circle.fill")
       // More predefined categories...
   }
   ```
   Dependencies: None

3. **GoalStep**
   ```swift
   struct GoalStep: Identifiable, Codable {
       let id: UUID
       var title: String
       var isCompleted: Bool
       var completedDate: Date?
       var dueDate: Date?
       var order: Int
   }
   ```
   Dependencies: None

4. **GoalMetricTracking**
   ```swift
   struct GoalMetricTracking: Codable {
       let metricType: GoalMetricType
       let startValue: Double
       let currentValue: Double
       let targetValue: Double
       let unit: String?
       let dataSource: MetricDataSource
   }
   
   enum GoalMetricType: String, Codable {
       case steps, activeCalories, sleepHours, screenTime, focusTime
       case weight, workoutFrequency, readingTime, meditationMinutes
       case custom
   }
   
   enum MetricDataSource: String, Codable {
       case healthKit, appUsage, manual
   }
   ```
   Dependencies: None

#### Core Data Models

```swift
extension GoalEntity {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var goalDescription: String
    @NSManaged public var categoryID: UUID
    @NSManaged public var priority: Int16
    @NSManaged public var targetDate: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var completedDate: Date?
    @NSManaged public var createdDate: Date
    @NSManaged public var progress: Double
    @NSManaged public var steps: Data // JSON serialized [GoalStep]
    @NSManaged public var metricTracking: Data? // JSON serialized GoalMetricTracking
    @NSManaged public var reminderFrequency: String?
}
```

#### Key Functions

1. **GoalRepository**
   ```swift
   protocol GoalRepositoryProtocol {
       func saveGoal(_ goal: Goal)
       func getGoal(id: UUID) -> Goal?
       func getAllGoals() -> [Goal]
       func getGoalsByCategory(_ category: GoalCategory) -> [Goal]
       func getActiveGoals() -> [Goal]
       func getCompletedGoals() -> [Goal]
       func deleteGoal(id: UUID)
       func updateGoalProgress(id: UUID, progress: Double)
       func completeGoal(id: UUID)
   }
   
   class GoalRepository: GoalRepositoryProtocol {
       private let coreDataManager: CoreDataManaging
       
       // Implementation of protocol methods
   }
   ```
   Dependencies: CoreDataManager, GoalEntity

2. **GoalTrackingService**
   ```swift
   protocol GoalTrackingServiceProtocol {
       func calculateProgressForMetricGoal(_ goal: Goal) -> Double
       func updateGoalProgress(_ goal: inout Goal)
       func checkGoalCompletion(_ goal: inout Goal) -> Bool
       func createReminderForGoal(_ goal: Goal) -> Bool
       func getGoalsRequiringAttention() -> [Goal]
   }
   
   class GoalTrackingService: GoalTrackingServiceProtocol {
       private let healthDataRepository: HealthDataRepositoryProtocol
       private let phoneUsageRepository: PhoneUsageRepositoryProtocol
       private let goalRepository: GoalRepositoryProtocol
       
       // Implementation of protocol methods
   }
   ```
   Dependencies: HealthDataRepository, PhoneUsageRepository, GoalRepository

3. **GoalsViewModel**
   ```swift
   class GoalsViewModel: ObservableObject {
       @Published var goals: [Goal] = []
       @Published var activeGoals: [Goal] = []
       @Published var completedGoals: [Goal] = []
       @Published var filteredGoals: [Goal] = []
       @Published var selectedCategory: GoalCategory?
       @Published var isLoading: Bool = false
       
       private let goalRepository: GoalRepositoryProtocol
       private let goalTrackingService: GoalTrackingServiceProtocol
       
       func loadGoals()
       func filterGoals(by category: GoalCategory?)
       func sortGoals(by sortOption: GoalSortOption)
       func getGoalsRequiringAttention() -> [Goal]
       func getTodayGoalProgress() -> [Goal]
   }
   
   enum GoalSortOption: String {
       case priority, dueDate, progress, createdDate
   }
   ```
   Dependencies: GoalRepository, GoalTrackingService

## 12. Requirement 11: Report-Goal Integration

### 12.1 Details and Target

This requirement focuses on connecting daily insights to goal progress:
- Linking daily metrics to relevant goals
- Goal-focused insights in daily reports
- Actionable recommendations for goal advancement
- Visual integration of goal progress in reports

**Target**: Help users understand how their daily activities and habits contribute to their long-term goals.

### 12.2 UI Design and User Interactions

The UI will include:

1. **Goal-Focused Report Section**:
   - Goal progress summary in daily reports
   - Key metrics related to goals
   - Goal-specific recommendations

2. **Goal Detail Enhancements**:
   - Historical progress chart
   - Related daily insights
   - Contributing factors visualization

User interactions:
- View goal progress in daily reports
- Navigate from report to goal details
- See how daily activities impact specific goals
- Set metric thresholds for goal tracking

### 12.3 Code Structure

```
Features/
├── ReportGoalIntegration/
│   ├── ViewModels/
│   │   ├── GoalInsightViewModel.swift
│   │   └── ReportGoalSectionViewModel.swift
│   ├── Views/
│   │   ├── ReportGoalSectionView.swift
│   │   ├── GoalContributionView.swift
│   │   └── GoalRecommendationView.swift
│   └── Services/
│       └── GoalInsightService.swift
Data/
├── Models/
│   └── GoalInsight/
│       ├── GoalInsight.swift
│       ├── MetricContribution.swift
│       └── GoalRecommendation.swift
```

### 12.4 Entities and Functions

#### Entities

1. **GoalInsight**
   ```swift
   struct GoalInsight: Identifiable, Codable {
       let id: UUID
       let goalId: UUID
       let date: Date
       let title: String
       let description: String
       let contributions: [MetricContribution]
       let overallContribution: Double // 0.0 to 1.0, how much today contributed to goal
       let recommendations: [GoalRecommendation]
   }
   ```
   Dependencies: MetricContribution, GoalRecommendation

2. **MetricContribution**
   ```swift
   struct MetricContribution: Codable {
       let metricName: String
       let metricValue: Double
       let unit: String?
       let contribution: Double // -1.0 to 1.0, negative means detrimental
       let description: String
   }
   ```
   Dependencies: None

3. **GoalRecommendation**
   ```swift
   struct GoalRecommendation: Identifiable, Codable {
       let id: UUID
       let title: String
       let description: String
       let impact: RecommendationImpact
       let actionable: Bool
       let timeFrame: TimeFrame
   }
   
   enum RecommendationImpact: String, Codable {
       case high, medium, low
   }
   
   enum TimeFrame: String, Codable {
       case immediate, shortTerm, longTerm
   }
   ```
   Dependencies: None

#### Key Functions

1. **GoalInsightService**
   ```swift
   protocol GoalInsightServiceProtocol {
       func generateGoalInsights(for date: Date, goals: [Goal]) -> [GoalInsight]
       func calculateMetricContributions(goal: Goal, date: Date) -> [MetricContribution]
       func generateRecommendations(goal: Goal, contributions: [MetricContribution]) -> [GoalRecommendation]
       func getTopGoalInsight(for date: Date) -> GoalInsight?
   }
   
   class GoalInsightService: GoalInsightServiceProtocol {
       private let healthDataRepository: HealthDataRepositoryProtocol
       private let phoneUsageRepository: PhoneUsageRepositoryProtocol
       private let journalRepository: JournalRepositoryProtocol
       private let goalRepository: GoalRepositoryProtocol
       
       // Implementation of protocol methods
   }
   ```
   Dependencies: HealthDataRepository, PhoneUsageRepository, JournalRepository, GoalRepository

2. **GoalInsightViewModel**
   ```swift
   class GoalInsightViewModel: ObservableObject {
       @Published var goalInsights: [GoalInsight] = []
       @Published var selectedGoalId: UUID?
       @Published var selectedDate: Date = Date()
       @Published var isLoading: Bool = false
       
       private let goalInsightService: GoalInsightServiceProtocol
       private let goalRepository: GoalRepositoryProtocol
       
       func loadGoalInsights(for date: Date)
       func getInsightForGoal(goalId: UUID) -> GoalInsight?
       func getHistoricalContributions(goalId: UUID, days: Int) -> [Date: Double]
       func getTopRecommendations() -> [GoalRecommendation]
   }
   ```
   Dependencies: GoalInsightService, GoalRepository

3. **ReportGoalSectionViewModel**
   ```swift
   class ReportGoalSectionViewModel: ObservableObject {
       @Published var goalProgress: [GoalProgress] = []
       @Published var goalInsights: [GoalInsight] = []
       @Published var date: Date
       @Published var isLoading: Bool = false
       
       private let goalRepository: GoalRepositoryProtocol
       private let goalInsightService: GoalInsightServiceProtocol
       
       func loadGoalSection(for date: Date)
       func getTopGoalsByProgress() -> [GoalProgress]
       func getTopGoalInsight() -> GoalInsight?
   }
   ```
   Dependencies: GoalRepository, GoalInsightService

## 13. Requirement 12: Personalization and Settings

### 13.1 Details and Target

This requirement focuses on allowing users to customize the app experience:
- UI theme and appearance options
- Report customization preferences
- Notification and reminder settings
- Data visibility and privacy controls
- Export and backup options

**Target**: Provide a personalized experience that aligns with users' preferences and privacy concerns.

### 13.2 UI Design and User Interactions

The UI will include:

1. **Settings Dashboard**:
   - Category-based settings menu
   - Quick access to common settings
   - User profile section

2. **Settings Screens**:
   - Appearance settings with theme options
   - Notification preferences
   - Privacy controls
   - Report customization
   - Data management

User interactions:
- Toggle dark/light mode
- Set notification preferences
- Customize report sections
- Manage privacy settings
- Export or delete data

### 13.3 Code Structure

```
Features/
├── Settings/
│   ├── ViewModels/
│   │   ├── SettingsViewModel.swift
│   │   ├── AppearanceSettingsViewModel.swift
│   │   ├── NotificationSettingsViewModel.swift
│   │   ├── PrivacySettingsViewModel.swift
│   │   └── DataManagementViewModel.swift
│   ├── Views/
│   │   ├── SettingsView.swift
│   │   ├── AppearanceSettingsView.swift
│   │   ├── NotificationSettingsView.swift
│   │   ├── PrivacySettingsView.swift
│   │   ├── ReportCustomizationView.swift
│   │   └── DataManagementView.swift
│   └── Services/
│       ├── ThemeManager.swift
│       ├── NotificationManager.swift
│       └── DataExportManager.swift
Data/
├── Models/
│   └── Settings/
│       ├── AppSettings.swift
│       ├── ThemeSettings.swift
│       ├── NotificationSettings.swift
│       ├── PrivacySettings.swift
│       └── ReportSettings.swift
```

### 13.4 Entities and Functions

#### Entities

1. **AppSettings**
   ```swift
   struct AppSettings: Codable {
       var themeSettings: ThemeSettings
       var notificationSettings: NotificationSettings
       var privacySettings: PrivacySettings
       var reportSettings: ReportSettings
       var dataSettings: DataSettings
   }
   ```
   Dependencies: ThemeSettings, NotificationSettings, PrivacySettings, ReportSettings, DataSettings

2. **ThemeSettings**
   ```swift
   struct ThemeSettings: Codable {
       var colorTheme: ColorTheme
       var useDarkMode: Bool
       var useSystemSettings: Bool
       var accentColor: String
       var fontScale: Double
   }
   
   enum ColorTheme: String, Codable {
       case standard, nature, ocean, sunset, minimal
   }
   ```
   Dependencies: None

3. **NotificationSettings**
   ```swift
   struct NotificationSettings: Codable {
       var enableDailyReport: Bool
       var dailyReportTime: Date
       var enableGoalReminders: Bool
       var enableInsightAlerts: Bool
       var enableWeeklyReview: Bool
       var weeklyReviewDay: Weekday
       var weeklyReviewTime: Date
       var doNotDisturbStart: Date
       var doNotDisturbEnd: Date
       var doNotDisturbEnabled: Bool
   }
   ```
   Dependencies: Weekday

4. **PrivacySettings**
   ```swift
   struct PrivacySettings: Codable {
       var dataCollectionEnabled: [DataCategory: Bool]
       var dataRetentionPeriod: RetentionPeriod
       var biometricAuthRequired: Bool
       var exportIncludeHealthData: Bool
       var exportIncludeJournalEntries: Bool
   }
   
   enum DataCategory: String, Codable {
       case health, phoneUsage, journal, location
   }
   
   enum RetentionPeriod: String, Codable {
       case oneMonth, threeMonths, sixMonths, oneYear, indefinite
   }
   ```
   Dependencies: None

5. **ReportSettings**
   ```swift
   struct ReportSettings: Codable {
       var enabledSections: [ReportSection: Bool]
       var defaultTimeframe: ReportTimeframe
       var prioritizeInsights: Bool
       var showGoalProgress: Bool
       var insightCount: Int
   }
   
   enum ReportTimeframe: String, Codable {
       case daily, weekly, monthly
   }
   ```
   Dependencies: ReportSection

6. **DataSettings**
   ```swift
   struct DataSettings: Codable {
       var autoBackupEnabled: Bool
       var backupFrequency: BackupFrequency
       var lastBackupDate: Date?
       var backupIncludeImages: Bool
       var syncEnabled: Bool
   }
   
   enum BackupFrequency: String, Codable {
       case daily, weekly, monthly, never
   }
   ```
   Dependencies: None

#### Key Functions

1. **ThemeManager**
   ```swift
   protocol ThemeManagerProtocol {
       var currentTheme: ThemeSettings { get }
       func applyTheme(_ theme: ThemeSettings)
       func toggleDarkMode()
       func getColorPalette(for theme: ColorTheme) -> [String: UIColor]
       func getSystemTheme() -> ThemeSettings
   }
   
   class ThemeManager: ThemeManagerProtocol {
       // Implementation of protocol methods
   }
   ```
   Dependencies: UserDefaultsManager

2. **NotificationManager**
   ```swift
   protocol NotificationManagerProtocol {
       func requestNotificationPermissions() -> Bool
       func scheduleReportNotification(at time: Date)
       func scheduleGoalReminder(for goal: Goal)
       func cancelAllNotifications()
       func enableNotificationType(_ type: NotificationType, enabled: Bool)
   }
   
   class NotificationManager: NotificationManagerProtocol {
       // Implementation using UserNotifications framework
   }
   
   enum NotificationType: String {
       case dailyReport, goalReminder, insight, weeklyReview
   }
   ```
   Dependencies: UserNotifications framework, Goal

3. **DataExportManager**
   ```swift
   protocol DataExportManagerProtocol {
       func exportAllData() -> URL?
       func exportJournalEntries() -> URL?
       func exportHealthData() -> URL?
       func exportGoals() -> URL?
       func createDataBackup() -> URL?
       func restoreFromBackup(url: URL) -> Bool
       func deleteAllData() -> Bool
   }
   
   class DataExportManager: DataExportManagerProtocol {
       private let healthDataRepository: HealthDataRepositoryProtocol
       private let phoneUsageRepository: PhoneUsageRepositoryProtocol
       private let journalRepository: JournalRepositoryProtocol
       private let goalRepository: GoalRepositoryProtocol
       
       // Implementation of protocol methods
   }
   ```
   Dependencies: HealthDataRepository, PhoneUsageRepository, JournalRepository, GoalRepository

4. **SettingsViewModel**
   ```swift
   class SettingsViewModel: ObservableObject {
       @Published var appSettings: AppSettings
       @Published var userProfile: User?
       @Published var isLoading: Bool = false
       
       private let themeManager: ThemeManagerProtocol
       private let notificationManager: NotificationManagerProtocol
       private let dataExportManager: DataExportManagerProtocol
       private let userRepository: UserRepositoryProtocol
       
       func saveSettings()
       func resetToDefaults()
       func exportData() -> URL?
       func createBackup() -> URL?
       func deleteAllData() -> Bool
       func updateUserProfile(_ user: User)
   }
   ```
   Dependencies: ThemeManager, NotificationManager, DataExportManager, UserRepository

# Summary

This technical design document provides a comprehensive breakdown of the "360-Degree Reflection" app into 12 incremental requirements that can be implemented and released in phases. Each requirement includes detailed specifications for UI design, code structure, entity definitions, and function dependencies.

The app follows the MVVM architecture pattern with Core Data for local storage. It leverages Apple's HealthKit for health data collection and various iOS frameworks for data analysis and visualization. By implementing these requirements incrementally, users will gain increasing value from the app, starting with basic data collection and progressing to sophisticated analysis and insights.

Key architectural decisions include:
- Client-only architecture with all data stored locally
- Modular design with clear separation of concerns
- Protocol-oriented programming for better testability
- Comprehensive data models with well-defined relationships
- Reactive programming with Combine for UI updates

This technical design sets the foundation for a robust, user-friendly application that helps users gain deeper self-awareness through comprehensive data analysis.