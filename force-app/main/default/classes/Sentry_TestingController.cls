
public with sharing class Sentry_TestingController {
    public PageReference triggerCapturedException() {
        try {
            Sentry_TestingMiddleware.doThing();
        } catch (Sentry_Exception e) {
            Sentry.record(e);
            throw e;
        }

        return null;
    }
    
    public PageReference triggerCustomException() 
    {
        List<Sentry_LogMessage> lExtraMessages = new List<Sentry_LogMessage>();
     	lExtraMessages.add(new Sentry_LogMessage(Sentry_LogMessage.LEVEL_INFO, Sentry_LogMessage.LEVEL_DEBUG, Sentry_LogMessage.LEVEL_DEBUG,'Testing debug 1', new Map<String, String>()));   
        Sentry.record('Custom Issue Title',new SYS_CustomException('Custom Exception'), lExtraMessages);
        return null;
    }
}