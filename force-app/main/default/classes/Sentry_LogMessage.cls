global with sharing class Sentry_LogMessage {
    global static final String LEVEL_ERROR = 'error';
    global static final String LEVEL_WARN = 'warn';
    global static final String LEVEL_INFO = 'info';
    global static final String LEVEL_DEBUG = 'debug';
    global static final String LEVEL_TRACE = 'trace';
    public static final String LEVEL_SENTRY_DEBUG = 'sys-debug';

    global String level { get; set; } { level = LEVEL_INFO; }
    global String type { get; set; } { type = LEVEL_DEBUG; }
    global String category { get; set; } { category = LEVEL_DEBUG; }
    global String message { get; set; }
    global Datetime ts { get; private set; } { ts = Datetime.now(); }
    global Map<String, String> data { get; set; } { data = new Map<String, String>(); }

    global Sentry_LogMessage(String level, String message) {
        this.level = (level == LEVEL_ERROR) ? LEVEL_ERROR : LEVEL_INFO;
        this.message = message;
    }

    global Sentry_LogMessage(String level, String type, String category, String message) 
    {
        this.level = (level == LEVEL_ERROR) ? LEVEL_ERROR : LEVEL_INFO;
        this.type = type;
        this.category = category;
        this.message = message;
    }

    global Sentry_LogMessage(String level, String message, Map<String, String> logData) {
        this(level, message);
        this.data = logData;
    }

    global Sentry_LogMessage(String level, String type, String category, String message, Map<String, String> logData) 
    {
        this(level, type, category, message);
        this.data = logData;
    }
}