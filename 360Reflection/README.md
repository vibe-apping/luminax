# 360Reflection iOS App

This project implements the Core App Infrastructure (Requirement 1) for the 360Reflection app.

## Project Structure

The app follows the MVVM (Model-View-ViewModel) architecture pattern with Combine for reactive programming.

### Key Components:

- **Application Layer**: Contains AppDelegate, SceneDelegate, and AppCoordinator for app initialization and navigation
- **Core Layer**: Contains extensions, protocols, utilities, and constants
- **Data Layer**: Contains local storage (CoreData, UserDefaults), models, and repositories

## How to Build and Run

1. Open Terminal and navigate to the project directory
2. Run the following command to create an Xcode project:

```
xcodegen generate
```

Alternatively, you can create a new Xcode project and add these files to it:

1. Open Xcode
2. Create a new iOS App project
3. Select "App" as the template
4. Name the project "360Reflection"
5. Choose "UIKit App Delegate" for the interface
6. Select "Storyboard" for the interface
7. Make sure "Core Data" is checked
8. Copy all the files from this directory into your Xcode project

## Features Implemented

- Tab-based navigation with 5 main sections: Dashboard, Journal, Reports, Goals, and Settings
- Core Data infrastructure for local data persistence
- UserDefaults manager for app settings
- Basic UI components and utilities
- Repository pattern for data access

## Next Steps

This implementation covers only Requirement 1: Core App Infrastructure. Future requirements will build upon this foundation.
