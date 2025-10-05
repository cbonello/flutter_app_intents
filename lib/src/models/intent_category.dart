/// Category for app intents, used to map to platform-specific capabilities
///
/// On Android, these map to Google Built-in Intents (BII).
/// On iOS, these provide semantic meaning for Siri integration.
///
/// See PRD Appendix A for complete Android BII mapping.
enum IntentCategory {
  /// General app feature (default fallback)
  ///
  /// Android BII: actions.intent.OPEN_APP_FEATURE
  general,

  /// Fitness and exercise activities
  ///
  /// Android BII: actions.intent.START_EXERCISE
  /// Examples: "Start a workout", "Begin running"
  fitness,

  /// Messaging and communication
  ///
  /// Android BII: actions.intent.SEND_MESSAGE
  /// Examples: "Send a message to John", "Text Alice"
  messaging,

  /// Phone calls
  ///
  /// Android BII: actions.intent.CREATE_CALL
  /// Examples: "Call Mom", "Phone the office"
  calling,

  /// Music playback
  ///
  /// Android BII: actions.intent.PLAY_MUSIC
  /// Examples: "Play my workout playlist", "Play jazz"
  music,

  /// Video playback
  ///
  /// Android BII: actions.intent.PLAY_VIDEO
  /// Examples: "Play my favorite show", "Watch action movies"
  video,

  /// Note taking
  ///
  /// Android BII: actions.intent.CREATE_NOTE
  /// Examples: "Create a note", "Take a note about the meeting"
  notes,

  /// Task management
  ///
  /// Android BII: actions.intent.CREATE_TASK
  /// Examples: "Create a task", "Add to my to-do list"
  tasks,

  /// Calendar events
  ///
  /// Android BII: actions.intent.CREATE_CALENDAR_EVENT
  /// Examples: "Schedule a meeting", "Create event for tomorrow"
  calendar,

  /// Navigation and directions
  ///
  /// Android BII: actions.intent.GET_DIRECTIONS
  /// Examples: "Navigate to work", "Get directions to the cafe"
  navigation,

  /// Ride sharing and taxis
  ///
  /// Android BII: actions.intent.GET_TAXI
  /// Examples: "Get a ride", "Call a taxi"
  taxi,

  /// Food ordering
  ///
  /// Android BII: actions.intent.ORDER_MENU_ITEM
  /// Examples: "Order pizza", "Get food from my favorite restaurant"
  ordering,

  /// Shopping cart operations
  ///
  /// Android BII: actions.intent.ADD_TO_CART
  /// Examples: "Add to cart", "Add this item"
  cart,

  /// Smart home and device control
  ///
  /// Android BII: actions.intent.OPEN_APP_FEATURE
  /// Examples: "Turn on the lights", "Set thermostat to 70"
  deviceControl,

  /// Nutrition and food tracking
  ///
  /// Android BII: actions.intent.GET_FOOD_OBSERVATION
  /// Examples: "Log my meal", "Track calories"
  nutrition,

  /// Timer management
  ///
  /// Android BII: actions.intent.CREATE_TIMER
  /// Examples: "Set a timer", "Start a 5 minute timer"
  timer,

  /// Alarm management
  ///
  /// Android BII: actions.intent.CREATE_ALARM
  /// Examples: "Set an alarm", "Wake me up at 7am"
  alarm,

  /// Reminders
  ///
  /// Android BII: actions.intent.CREATE_REMINDER
  /// Examples: "Remind me to call John", "Set a reminder"
  reminder,

  /// Weather information
  ///
  /// Android BII: actions.intent.GET_WEATHER
  /// Examples: "What's the weather", "Will it rain today"
  weather,

  /// News and articles
  ///
  /// Android BII: actions.intent.GET_NEWS_ARTICLE
  /// Examples: "Read the news", "Get sports updates"
  news,
}

/// Extension methods for IntentCategory
extension IntentCategoryExtension on IntentCategory {
  /// Get the Android Built-in Intent (BII) action string for this category
  ///
  /// This is used when generating shortcuts.xml for Android App Actions.
  String get androidBII {
    switch (this) {
      case IntentCategory.general:
        return 'actions.intent.OPEN_APP_FEATURE';
      case IntentCategory.fitness:
        return 'actions.intent.START_EXERCISE';
      case IntentCategory.messaging:
        return 'actions.intent.SEND_MESSAGE';
      case IntentCategory.calling:
        return 'actions.intent.CREATE_CALL';
      case IntentCategory.music:
        return 'actions.intent.PLAY_MUSIC';
      case IntentCategory.video:
        return 'actions.intent.PLAY_VIDEO';
      case IntentCategory.notes:
        return 'actions.intent.CREATE_NOTE';
      case IntentCategory.tasks:
        return 'actions.intent.CREATE_TASK';
      case IntentCategory.calendar:
        return 'actions.intent.CREATE_CALENDAR_EVENT';
      case IntentCategory.navigation:
        return 'actions.intent.GET_DIRECTIONS';
      case IntentCategory.taxi:
        return 'actions.intent.GET_TAXI';
      case IntentCategory.ordering:
        return 'actions.intent.ORDER_MENU_ITEM';
      case IntentCategory.cart:
        return 'actions.intent.ADD_TO_CART';
      case IntentCategory.deviceControl:
        return 'actions.intent.OPEN_APP_FEATURE';
      case IntentCategory.nutrition:
        return 'actions.intent.GET_FOOD_OBSERVATION';
      case IntentCategory.timer:
        return 'actions.intent.CREATE_TIMER';
      case IntentCategory.alarm:
        return 'actions.intent.CREATE_ALARM';
      case IntentCategory.reminder:
        return 'actions.intent.CREATE_REMINDER';
      case IntentCategory.weather:
        return 'actions.intent.GET_WEATHER';
      case IntentCategory.news:
        return 'actions.intent.GET_NEWS_ARTICLE';
    }
  }

  /// Get a human-readable display name for this category
  String get displayName {
    switch (this) {
      case IntentCategory.general:
        return 'General';
      case IntentCategory.fitness:
        return 'Fitness & Exercise';
      case IntentCategory.messaging:
        return 'Messaging';
      case IntentCategory.calling:
        return 'Phone Calls';
      case IntentCategory.music:
        return 'Music';
      case IntentCategory.video:
        return 'Video';
      case IntentCategory.notes:
        return 'Notes';
      case IntentCategory.tasks:
        return 'Tasks';
      case IntentCategory.calendar:
        return 'Calendar';
      case IntentCategory.navigation:
        return 'Navigation';
      case IntentCategory.taxi:
        return 'Ride Sharing';
      case IntentCategory.ordering:
        return 'Food Ordering';
      case IntentCategory.cart:
        return 'Shopping';
      case IntentCategory.deviceControl:
        return 'Device Control';
      case IntentCategory.nutrition:
        return 'Nutrition';
      case IntentCategory.timer:
        return 'Timers';
      case IntentCategory.alarm:
        return 'Alarms';
      case IntentCategory.reminder:
        return 'Reminders';
      case IntentCategory.weather:
        return 'Weather';
      case IntentCategory.news:
        return 'News';
    }
  }
}
