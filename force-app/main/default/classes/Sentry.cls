public with sharing class Sentry {
  public static void record(Exception e) {
    Sentry_Event err = convertExceptiontoError(e);
    sendEvent(err);
  }

  public static void record(
    String issueTitle,
    Exception e,
    List<Sentry_LogMessage> lExtraMessages
  ) {
    Sentry_Event err = convertExceptionToError(issueTitle, e, lExtraMessages);
    sendEvent(err);
  }

  private static Sentry_Event convertExceptionToError(Exception e) {
    return new Sentry_Event(e);
  }

  private static Sentry_Event convertExceptionToError(
    String issueTitle,
    Exception e,
    List<Sentry_LogMessage> lExtraMessages
  ) {
    return new Sentry_Event(issueTitle, e, lExtraMessages);
  }

  private static void sendEvent(Sentry_Event err) {
    Sentry_Log.logSentry(
      '[Sentry.sendEvent] event: ' + JSON.serializePretty(err)
    );
    Sentry_Log.logSentry(
      '[Sentry.sendEvent] message: ' + JSON.serializePretty(err.toMessage())
    );

    Sentry_Error__e e = new Sentry_Error__e(
      Content__c = JSON.serialize(err.toMessage())
    );
    EventBus.publish(e);
  }
}
