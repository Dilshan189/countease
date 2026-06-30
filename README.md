# CountEase 📅

A beautiful and intuitive Flutter countdown app for tracking important events, birthdays, exams, and special occasions. Built with modern Flutter architecture and GetX state management.

## ✨ Features

### 🎯 Event Management
- **Multiple Event Types**: Birthday 🎂, Exam 📚, Poya 🌕, and Custom 📅 events
- **Smart Notifications**: Push notifications with customizable timing
- **Yearly Recurring**: Automatic yearly repeat for birthdays and holidays
- **Rich Descriptions**: Add detailed notes and descriptions to events

### 🏠 Home Screen Experience
- **Featured Countdown**: Large, beautiful countdown card for selected or next upcoming event
- **Today's Events**: Compact view of events happening today
- **Quick Filters**: Easy-to-use filter chips for event types and past events visibility
- **Smart Search**: Find events by name or description
- **Pull-to-Refresh**: Easy data synchronization

### 📊 Statistics & Insights
- **Event Analytics**: Track event types and patterns
- **Visual Charts**: Beautiful charts showing your event distribution
- **Progress Tracking**: Monitor upcoming events and milestones

### 🎨 User Experience
- **Modern UI**: Clean, Material Design 3 interface
- **Dark/Light Theme**: Automatic theme adaptation
- **Responsive Design**: Optimized for all screen sizes
- **Smooth Animations**: Delightful micro-interactions
- **Compact Mode**: Smaller tiles for today's events

### 🔧 Advanced Features
- **Data Export/Import**: Backup and restore your events
- **Offline Support**: Works without internet connection
- **Local Storage**: Secure Hive database for data persistence
- **Debug Tools**: Built-in debugging for development

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/countease.git
   cd countease
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

### Home Screen
- Featured countdown card with gradient backgrounds
- Today's events in compact tiles
- Quick filter chips for easy navigation
- Floating action button for adding events

### Event Management
- Beautiful add/edit event forms
- Event type selection with emojis
- Date and time pickers
- Notification settings

### Statistics
- Visual charts and analytics
- Event distribution insights
- Progress tracking

## 🏗️ Architecture

### State Management
- **Riverpod**: Reactive state management
- **Controllers**: EventController, NavigationController
- **Observables**: Reactive lists and variables

### Data Layer
- **Hive**: Local NoSQL database
- **Models**: Event model with type adapters
- **Services**: DatabaseService, NotificationService

### UI Components
- **Screens**: Home, Add Event, Event Detail, Statistics, Settings
- **Widgets**: CountdownCard, EventTile, CustomButton
- **Navigation**: Bottom navigation with GetX routing

## 📂 Project Structure

```
lib/
├── controllers/          # Riverpod statemanagemat controllers
│   ├── event_controller.dart
│   └── navigation_controller.dart
├── models/              # Data models
│   ├── event_model.dart
│   └── event_model.g.dart
├── screens/             # UI screens
│   ├── home_screen.dart
│   ├── add_event_screen.dart
│   ├── event_detail_screen.dart
│   ├── events_list_screen.dart
│   ├── statistics_screen.dart
│   └── settings_screen.dart
├── services/            # Business logic
│   ├── db_service.dart
│   └── notification_service.dart
├── widgets/             # Reusable widgets
│   ├── countdown_card.dart
│   ├── event_tile.dart
│   ├── custom_button.dart
│   └── custom_bottom_navigation.dart
└── main.dart           # App entry point
```

## 🔧 Configuration

### Notification Permissions
The app requests notification permissions when adding events with notifications enabled.

### Database
Uses Hive for local storage. Database is automatically initialized on first run.

### Themes
Supports both light and dark themes with Material Design 3.

## 🚀 Recent Updates

### UX Improvements (Latest)
- ✅ Added FloatingActionButton for quick event creation
- ✅ Enhanced featured countdown card visibility
- ✅ Implemented quick filter chips for better navigation
- ✅ Added compact mode for today's events
- ✅ Improved empty state with clear call-to-action
- ✅ Enhanced filter dialog with past events toggle

### Performance Optimizations
- ✅ Optimized list rendering with proper separators
- ✅ Implemented pull-to-refresh functionality
- ✅ Added smart filtering and search capabilities

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX for reactive state management
- Hive for local database
- Material Design for UI guidelines

## 📞 Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the documentation
- Review the code comments

---

**Made with ❤️ using Flutter**
