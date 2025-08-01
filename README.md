# Book-Diaries Reader Companion App

A comprehensive iOS app for book lovers to track reading progress, discover new books, and participate in reading challenges.

## 🚀 Features Implemented

### 📅 Reading Calendar (Monthly Challenge)
- **CalendarChallengeService**: Singleton service managing monthly book selections
- **MonthlyBook**: Core Data entity for storing monthly picks
- **CalendarChallengeView**: UI for viewing and managing monthly challenges
- **MonthlyPickEditorView**: Staff interface for setting monthly picks

### 📖 Rotating Daily Book Recommendations
- **DailyBookService**: Service that returns different books every 24 hours based on date seed
- **SeedBooks.json**: Bundled JSON file with 10 classic books
- **DailyBookView**: UI for displaying daily book recommendations
- **SeedImporterView**: Staff interface for managing seed books

### 🏆 Reading Tracker
- **ReadingTrackerService**: Manages reading logs and progress tracking
- **ReadingLog**: Core Data entity for tracking completed books
- **ReadingTrackerView**: UI for viewing reading progress and logs
- **ChecklistProgress**: Struct for tracking completion percentages

### 🗂 Role-based Sections
- **UserRole**: Enum for `.reader` and `.staff` roles
- **AppStorage**: Persistence for role and theme preferences
- **Reader Tabs**: Calendar, Daily Pick, Tracker, Donate, Settings
- **Staff Tabs**: Book Scanner, Monthly Pick Editor, Seed Importer

### 📷 Staff Book Scanner
- **BarcodeScannerView**: Enhanced scanner with OpenLibrary API integration
- **OpenLibraryService**: Service for looking up books by ISBN
- **ScannerView**: Camera interface for barcode scanning
- **EAN-13, ISBN-10/13**: Supported barcode formats

### 💳 Direct Donation
- **DonationService**: Stub service with Apple Pay and Stripe integration
- **DonationView**: UI for donation amounts and payment methods
- **ApplePayView**: Apple Pay payment interface
- **StripePaymentView**: Credit card payment interface

### 🎨 Theme Support
- **AppTheme**: Enum with `.classic`, `.midnight`, `.sepia` themes
- **AppStorage**: Theme persistence
- **ColorScheme**: Dynamic theme switching
- **SettingsView**: Theme selection interface

### ✅ Books Checklist (Completion)
- **isRead**: Computed property for book completion status
- **ChecklistProgress**: Progress tracking structure
- **ReadingTrackerService**: Integration with reading logs

## 🗄️ Persistence

### Core Data Model
- **Book**: Main book entity with relationships to ReadingLog
- **ReadingLog**: Tracks when books were completed
- **MonthlyBook**: Stores monthly challenge selections

### Core Data Manager
- **CoreDataManager**: Singleton for all Core Data operations
- **CRUD Operations**: Full create, read, update, delete support
- **Migration Support**: Lightweight migration for schema changes

## 🔬 Testing

### Unit Tests
- **DailyBookServiceTests**: Tests rotation logic and deterministic selection
- **ReadingTrackerTests**: Tests progress calculation and reading logs
- **DonationServiceTests**: Tests payment processing and error handling

### UI Tests
- **RoleSwitchingUITests**: Tests role-based navigation and persistence
- **Theme Switching**: Tests theme selection and application
- **Tab Visibility**: Verifies correct tabs for each role

## 🏗️ Architecture

### Services (Singleton Pattern)
- `CalendarChallengeService`: Monthly book management
- `DailyBookService`: Daily book rotation
- `ReadingTrackerService`: Progress tracking
- `DonationService`: Payment processing
- `OpenLibraryService`: Book lookup API
- `CoreDataManager`: Data persistence

### Views (MVVM Pattern)
- **Reader Views**: Calendar, Daily Pick, Tracker, Donate, Settings
- **Staff Views**: Scanner, Monthly Pick Editor, Seed Importer
- **Shared Views**: Settings, Book Cards, Progress Indicators

### Models
- **Book**: Codable struct for API responses
- **UserRole**: Enum for role management
- **AppTheme**: Enum for theme management
- **Core Data Entities**: Book, ReadingLog, MonthlyBook

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Installation
1. Clone the repository
2. Open `DemoApp.xcodeproj` in Xcode
3. Build and run the project

### Core Data Setup
The app automatically creates the Core Data stack on first launch. No additional setup required.

### Testing
Run tests with `⌘+U` in Xcode:
- Unit tests verify service logic
- UI tests verify role switching and navigation

## 📱 Usage

### Reader Mode
1. **Calendar**: View and participate in monthly reading challenges
2. **Daily Pick**: Discover new books with daily recommendations
3. **Tracker**: Log completed books and track reading progress
4. **Donate**: Support the app with secure payments
5. **Settings**: Switch themes and manage preferences

### Staff Mode
1. **Scanner**: Scan book barcodes to add to catalog
2. **Monthly Pick**: Set monthly reading challenges
3. **Seed Books**: Manage daily recommendation books
4. **Settings**: Access staff-specific settings

## 🔧 Configuration

### Role Switching
- Navigate to Settings → User Role → Switch Role
- Choose between Reader and Staff roles
- Changes persist across app launches

### Theme Selection
- Navigate to Settings → Appearance → Theme
- Choose from Classic, Midnight, or Sepia themes
- Changes apply immediately

### API Integration
- **OpenLibrary API**: Book lookup by ISBN
- **Google Books API**: Fallback for book information
- **Stub Payment APIs**: Simulated Apple Pay and Stripe

## 📊 Data Flow

### Reading Progress
1. User marks book as read in Daily Pick or Tracker
2. `ReadingTrackerService` creates `ReadingLog` entry
3. Progress percentage updates automatically
4. Checklist completion status updates

### Monthly Challenges
1. Staff sets monthly book in Monthly Pick Editor
2. `CalendarChallengeService` stores in Core Data
3. Readers view challenge in Calendar tab
4. Progress tracked against monthly goal

### Daily Recommendations
1. `DailyBookService` loads seed books from JSON
2. Date-based hash determines daily book
3. Same date always returns same book
4. Staff can manage seed books via Seed Importer

## 🔒 Security

### Payment Processing
- Stub implementations for Apple Pay and Stripe
- No real payment processing in demo
- Secure token handling for payment methods

### Data Privacy
- All data stored locally on device
- No external data transmission
- User controls all personal reading data

## 🎯 Future Enhancements

### Planned Features
- **Cloud Sync**: iCloud integration for reading data
- **Social Features**: Share reading progress with friends
- **Advanced Analytics**: Detailed reading statistics
- **Book Recommendations**: AI-powered suggestions
- **Reading Groups**: Community book clubs

### Technical Improvements
- **Real Payment Processing**: Live Apple Pay and Stripe
- **Push Notifications**: Daily book reminders
- **Offline Support**: Enhanced offline functionality
- **Performance Optimization**: Faster Core Data queries

## 📄 License

This project is for demonstration purposes. All book data and APIs are used in accordance with their respective terms of service.

## 🤝 Contributing

This is a demo project showcasing iOS development best practices. The architecture demonstrates:

- **MVVM Pattern**: Clean separation of concerns
- **Combine Framework**: Reactive programming
- **Core Data**: Robust data persistence
- **SwiftUI**: Modern declarative UI
- **Unit Testing**: Comprehensive test coverage
- **UI Testing**: Automated user interface testing

The implementation follows Apple's Human Interface Guidelines and iOS development best practices. 