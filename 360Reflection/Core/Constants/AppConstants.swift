import Foundation
import UIKit

struct AppConstants {
    struct Colors {
        static let primaryColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        static let secondaryColor = UIColor(red: 88.0/255.0, green: 86.0/255.0, blue: 214.0/255.0, alpha: 1.0)
        static let accentColor = UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        static let backgroundColor = UIColor.systemBackground
        static let textColor = UIColor.label
    }
    
    struct Fonts {
        static let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
        static let headingFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let bodyFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let captionFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    struct Animations {
        static let defaultDuration: TimeInterval = 0.3
        static let longDuration: TimeInterval = 0.5
    }
    
    struct API {
        static let baseURL = "https://api.example.com"
        static let timeout: TimeInterval = 30
    }
    
    struct UserDefaults {
        static let appGroupIdentifier = "group.com.yourcompany.360reflection"
    }
}
