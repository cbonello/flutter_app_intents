/// Category for app intents, used to map to platform-specific capabilities
///
/// On Android, these map to Google Built-in Intents (BII).
/// On iOS, these provide semantic meaning for Siri integration.
///
/// See PRD Appendix A for complete Android BII mapping.
enum IntentCategory {
  /// General app feature (default fallback)
  general('actions.intent.OPEN_APP_FEATURE', 'General'),

  /// Fitness and exercise activities
  ///
  /// Examples: "Start a workout", "Begin running"
  fitness('actions.intent.START_EXERCISE', 'Fitness & Exercise'),

  /// Messaging and communication
  ///
  /// Examples: "Send a message to John", "Text Alice"
  messaging('actions.intent.SEND_MESSAGE', 'Messaging'),

  /// Phone calls
  ///
  /// Examples: "Call Mom", "Phone the office"
  calling('actions.intent.CREATE_CALL', 'Phone Calls'),

  /// Music playback
  ///
  /// Examples: "Play my workout playlist", "Play jazz"
  music('actions.intent.PLAY_MUSIC', 'Music'),

  /// Video playback
  ///
  /// Examples: "Play my favorite show", "Watch action movies"
  video('actions.intent.PLAY_VIDEO', 'Video'),

  /// Note taking
  ///
  /// Examples: "Create a note", "Take a note about the meeting"
  notes('actions.intent.CREATE_NOTE', 'Notes'),

  /// Task management
  ///
  /// Examples: "Create a task", "Add to my to-do list"
  tasks('actions.intent.CREATE_TASK', 'Tasks'),

  /// Calendar events
  ///
  /// Examples: "Schedule a meeting", "Create event for tomorrow"
  calendar('actions.intent.CREATE_CALENDAR_EVENT', 'Calendar'),

  /// Navigation and directions
  ///
  /// Examples: "Navigate to work", "Get directions to the cafe"
  navigation('actions.intent.GET_DIRECTIONS', 'Navigation'),

  /// Ride sharing and taxis
  ///
  /// Examples: "Get a ride", "Call a taxi"
  taxi('actions.intent.GET_TAXI', 'Ride Sharing'),

  /// Food ordering
  ///
  /// Examples: "Order pizza", "Get food from my favorite restaurant"
  ordering('actions.intent.ORDER_MENU_ITEM', 'Food Ordering'),

  /// Shopping cart operations
  ///
  /// Examples: "Add to cart", "Add this item"
  cart('actions.intent.ADD_TO_CART', 'Shopping'),

  /// Smart home and device control
  ///
  /// Examples: "Turn on the lights", "Set thermostat to 70"
  deviceControl('actions.intent.OPEN_APP_FEATURE', 'Device Control'),

  /// Nutrition and food tracking
  ///
  /// Examples: "Log my meal", "Track calories"
  nutrition('actions.intent.GET_FOOD_OBSERVATION', 'Nutrition'),

  /// Timer management
  ///
  /// Examples: "Set a timer", "Start a 5 minute timer"
  timer('actions.intent.CREATE_TIMER', 'Timers'),

  /// Alarm management
  ///
  /// Examples: "Set an alarm", "Wake me up at 7am"
  alarm('actions.intent.CREATE_ALARM', 'Alarms'),

  /// Reminders
  ///
  /// Examples: "Remind me to call John", "Set a reminder"
  reminder('actions.intent.CREATE_REMINDER', 'Reminders'),

  /// Weather information
  ///
  /// Examples: "What's the weather", "Will it rain today"
  weather('actions.intent.GET_WEATHER', 'Weather'),

  /// News and articles
  ///
  /// Examples: "Read the news", "Get sports updates"
  news('actions.intent.GET_NEWS_ARTICLE', 'News');

  const IntentCategory(this.androidBII, this.displayName);

  final String androidBII;
  final String displayName;
}
