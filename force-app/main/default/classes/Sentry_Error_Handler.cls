public with sharing class Sentry_Error_Handler {
    public void run() {
        List<String> errors = new List<String>();

        // for (Sentry_Error__e e : (List<Sentry_Error__e>) Trigger.new) {
        //     Sentry_Log.logSentry('[Sentry_Error_Handler.run] System event: ' + JSON.serializePretty(e));
        //     Sentry_Log.logSentry('[Sentry_Error_Handler.run] Sentry event: ' + e.Content__c);

        //     errors.add(e.Content__c);
        // }

        Object TempD;

        // {
        //     "event_id": "fc6d8c0c43fc4630ad850ee518f1b9d0",
        //     "culprit": "my.module.function_name",
        //     "timestamp": "2011-05-02T17:41:36",
        //     "message": "SyntaxError: Wattttt!",
        //     "exception": {
        //       "values": [
        //         {
        //           "type": "SyntaxError",
        //           "value": "Wattttt!",
        //           "module": "__builtins__"
        //         }
        //       ]
        //     }
        //   }

        // Generate Unique Event ID
        String eventId = String.valueOf(UUID.randomUUID());
        String ts;

        //ts needs to be in 2011-05-02T17:41:36 format
        ts = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');

        String GenerateRandomString = 'SyntaxError:' + String.valueOf(Math.random()).substring(0, 5) + '!';

        String ValueofException = 'Wattttt!' + String.valueOf(Math.random()).substring(0, 5) + '!';

        TempD = new Map<String, Object> {
            'event_id' => eventId,
            'culprit' => 'my.module.function_name',
            'timestamp' => ts,
            'message' => GenerateRandomString,
            'exception' => new Map<String, Object> {
                'values' => new List<Map<String, Object>> {
                    new Map<String, Object> {
                        'type' => 'SyntaxError',
                        'value' => ValueofException,
                        'module' => '__builtins__'
                    }
                }
            }
        };
          

        errors.add(JSON.serialize(TempD));

        if (errors.isEmpty() || Sentry_Config.canSendToSentry() == false) {
            if (Sentry_Config.canSendToSentry()) {
                Sentry_Log.logSentry('[Sentry_Error_Handler.run] no errors, exiting.');
            } else {
                Sentry_Log.logSentry('[Sentry_Error_Handler.run] sending to sentry is disabled. Not sending ' + errors.size() + ' errors.');
            }

            return;
        }

        Sentry_Log.logSentry('[Sentry_Error_Handler.run] calling sendErrors with ' + errors.size() + ' errors.');

        sendErrors(errors);
    }

    @Future(Callout=true)
    public static void sendErrors(List<String> errors) {
        for (String error : errors) {
            Sentry_Client.sendEventToSentry(error);
        }
    }
}