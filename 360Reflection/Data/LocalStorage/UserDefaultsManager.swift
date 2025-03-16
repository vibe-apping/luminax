import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
    // Keys
    private enum Keys {
        static let isFirstLaunch = "isFirstLaunch"
        static let userPreferences = "userPreferences"
        static let lastSyncDate = "lastSyncDate"
        static let appTheme = "appTheme"
        static let notificationsEnabled = "notificationsEnabled"
    }
    
    private init() {}
    
    // MARK: - First Launch
    
    var isFirstLaunch: Bool {
        get {
            return defaults.bool(forKey: Keys.isFirstLaunch)
        }
        set {
            defaults.set(newValue, forKey: Keys.isFirstLaunch)
        }
    }
    
    // MARK: - User Preferences
    
    func saveUserPreferences(_ preferences: [String: Any]) {
        defaults.set(preferences, forKey: Keys.userPreferences)
    }
    
    func getUserPreferences() -> [String: Any]? {
        return defaults.dictionary(forKey: Keys.userPreferences)
    }
    
    // MARK: - Sync Date
    
    var lastSyncDate: Date? {
        get {
            return defaults.object(forKey: Keys.lastSyncDate) as? Date
        }
        set {
            defaults.set(newValue, forKey: Keys.lastSyncDate)
        }
    }
    
    // MARK: - App Theme
    
    enum AppTheme: String {
        case light
        case dark
        case system
    }
    
    var appTheme: AppTheme {
        get {
            if let themeString = defaults.string(forKey: Keys.appTheme),
               let theme = AppTheme(rawValue: themeString) {
                return theme
            }
            return .system
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.appTheme)
        }
    }
    
    // MARK: - Notifications
    
    var notificationsEnabled: Bool {
        get {
            return defaults.bool(forKey: Keys.notificationsEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.notificationsEnabled)
        }
    }
    
    // MARK: - Reset
    
    func resetAllSettings() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
    }
}
