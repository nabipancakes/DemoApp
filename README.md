# The Book Diaries

A comprehensive iOS application for personal reading management, book discovery, and reading progress tracking. The app provides role-based functionality for both individual readers and library/bookstore staff members.

## Core Features

### Reading Management
- **Personal Reading Logs**: Track completed books with completion dates, ratings, and personal notes
- **Reading List Management**: Maintain a curated list of books to read
- **Collection Organization**: Create and manage custom book collections
- **Reading Goal Tracking**: Set and monitor annual reading targets

### Book Discovery
- **Daily Book Recommendations**: Algorithm-driven daily book suggestions from curated seed data
- **Monthly Reading Challenges**: Participation in community-wide monthly book selections
- **Search and Scan Integration**: ISBN-based book lookup with barcode scanning capability

### Staff Administration
- **Enhanced Barcode Scanner**: Batch book scanning with collection integration and CSV export
- **Monthly Pick Management**: Administrative interface for setting community reading challenges
- **Reading Analytics**: Dashboard with user engagement metrics and book catalog statistics
- **Seed Book Management**: Curation of the daily recommendation algorithm database

## Technical Architecture

### Data Persistence
- **Core Data Framework**: Local database management for reading logs, book metadata, and user collections
- **UserDefaults Integration**: Lightweight storage for user preferences and reading list data
- **Data Export Functionality**: CSV export capabilities for reading data and scan results

### External Integrations
- **OpenLibrary API**: Primary book metadata retrieval service
- **Google Books API**: Secondary book information source and cover image provider
- **Barcode Recognition**: AVFoundation-based ISBN scanning with EAN-13 and ISBN-10/13 support

### User Interface
- **SwiftUI Framework**: Modern declarative UI implementation
- **Role-Based Navigation**: Adaptive interface based on user role (reader/staff)
- **Theme System**: Multiple visual themes with persistent user preferences
- **Accessibility Support**: VoiceOver and accessibility identifier integration

## System Requirements

- iOS 17.0 or later
- Xcode 15.0 or later for development
- Swift 5.9 or later
- Camera access required for barcode scanning functionality

## Application Structure

### Reader Interface
- **Home Dashboard**: Reading statistics, recent activity, and quick actions
- **My Books**: Unified view of reading logs, reading list, and collections
- **Discover**: Daily recommendations and monthly challenges
- **Settings**: Theme preferences and data management

### Staff Interface  
- **Dashboard**: Analytics overview and administrative quick actions
- **Enhanced Scanner**: Batch book processing with collection management
- **Monthly Pick Editor**: Community reading challenge administration
- **Settings**: Role management and system configuration

## Data Management

### Local Storage
All user data is stored locally on the device using Core Data and UserDefaults. No personal reading information is transmitted to external servers.

### Data Clearing
Administrative function to reset all application data including reading logs, collections, user preferences, and cached book information.

### Export Capabilities
CSV export functionality for reading logs and scan results, compatible with spreadsheet applications and external data analysis tools.

## Security and Privacy

- Local-only data storage with no cloud transmission
- User-controlled data retention and deletion
- Role-based access control with password protection for staff functions
- Secure handling of external API requests

## Development Standards

The application follows iOS development best practices including:
- MVVM architectural pattern
- Combine framework for reactive programming
- Comprehensive unit and UI test coverage
- SwiftUI best practices and Human Interface Guidelines compliance
- Accessibility standards implementation

## Testing Framework

- Unit tests for core business logic and data services
- UI tests for user interaction flows and role switching
- Service layer testing for API integration and data persistence
- Performance testing for Core Data operations

This application demonstrates modern iOS development techniques while providing practical functionality for reading enthusiasts and book industry professionals.