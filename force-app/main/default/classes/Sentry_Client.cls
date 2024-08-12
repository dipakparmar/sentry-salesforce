public with sharing class Sentry_Client {
  private static Sentry_Dsn dsn = Sentry_Config.getDsn();
  private static final String SENTRY_API_VERSION = '7';
  private static Sentry_SdkInfo sdkInfo = new Sentry_SdkInfo();
  public static String orgDomainUrl = URL.getOrgDomainUrl().toExternalForm();
  public static String currentRequestUrl = URL.getCurrentRequestUrl()
    .toExternalForm();

  static {
    sdkInfo.name = 'salesforce-apex';
    sdkInfo.version = '0.0.1-beta';
  }

  public class Sentry_SdkInfo {
    public String name { get; set; }
    public String version { get; set; }
  }

  public static String getBaseApiEndpoint() {
    String baseEndpoint = dsn.protocol + '://' + dsn.sentryHost + '/api/';
    System.debug('Sentry BaseEndpoint: ' + baseEndpoint);
    return baseEndpoint;
  }

  public static String getIngestApiEndpoint() {
    String ingestEndpoint = getBaseApiEndpoint() + dsn.projectId + '/envelope/';
    System.debug('Sentry IngestEndpoint: ' + ingestEndpoint);
    return ingestEndpoint;
  }

  public static String getEncodedAuth(Sentry_SdkInfo sdkInfo) {
    Map<String, String> authParams = new Map<String, String>{
      'sentry_key' => dsn.publicKey,
      'sentry_version' => SENTRY_API_VERSION,
      'sentry_client' => sdkInfo.name +
      '/' +
      sdkInfo.version
    };

    return urlEncode(authParams);
  }

  private static String urlEncode(Map<String, String> params) {
    List<String> encodedParams = new List<String>();
    for (String key : params.keySet()) {
      String encodedKey = EncodingUtil.urlEncode(key, 'UTF-8');
      String encodedValue = EncodingUtil.urlEncode(params.get(key), 'UTF-8');
      encodedParams.add(encodedKey + '=' + encodedValue);
    }
    return String.join(encodedParams, '&');
  }

  public static String getEnvelopeEndpointWithUrlEncodedAuth(
    String tunnel,
    Sentry_SdkInfo sdkInfo
  ) {
    if (String.isNotBlank(tunnel)) {
      return tunnel;
    } else {
      return getIngestApiEndpoint() + '?' + getEncodedAuth(sdkInfo);
    }
  }

  public static void sendTestEnvelope() {
    String envelope = generateTestEnvelope();
    sendEnvelopeToSentry(envelope);
  }

  public static void sendTestEnvelope2() {
    String envelope = generateTestEnvelopeFromSalesforce();
    sendEnvelopeToSentry(envelope);
  }

  private static String generateTestEnvelope() {
    String eventId = generateEventId();
    String timestamp = DateTime.now()
      .formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
    String envelopeHeader =
      '{"event_id":"' +
      eventId +
      '","sent_at":"' +
      timestamp +
      '","sdk":' +
      JSON.serialize(sdkInfo) +
      '}';
    String eventHeader = '{"type":"event","length":';
    String eventPayload =
      '{' +
      '"event_id":"' +
      eventId +
      '",' +
      '"level":"error",' +
      '"exception":{' +
      '"values":[{' +
      '"type":"TestException",' +
      '"value":"Test error message",' +
      '"stacktrace":{' +
      '"frames":[{' +
      '"filename":"TestClass.cls",' +
      '"lineno":42,' +
      '"in_app":true,' +
      '"function":"testMethod"' +
      '}]' +
      '}' +
      '}]' +
      '},' +
      '"timestamp":"' +
      timestamp +
      '",' +
      '"platform":"apex",' +
      '"environment":"production",' +
      '"release":"myapp@1.0.0",' +
      '"sdk":' +
      JSON.serialize(sdkInfo) +
      '}';

    eventHeader += eventPayload.length() + '}';
    return envelopeHeader + '\n' + eventHeader + '\n' + eventPayload;
  }

  private static String generateTestEnvelopeFromSalesforce() {
    String eventId = generateEventId();
    String timestamp = DateTime.now()
      .formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');

    // Envelope header
    String envelopeHeader = JSON.serialize(
      new Map<String, Object>{
        'event_id' => eventId,
        'sent_at' => timestamp,
        'sdk' => new Map<String, String>{
          'name' => sdkInfo.name,
          'version' => sdkInfo.version
        }
      }
    );

    // Event payload
    Map<String, Object> eventPayload = new Map<String, Object>{
      'event_id' => eventId,
      'message' => 'Test error from Salesforce',
      'timestamp' => timestamp,
      'level' => 'error',
      'logger' => 'apex',
      'platform' => 'salesforce',
      'exception' => new Map<String, Object>{
        'values' => new List<Object>{
          new Map<String, Object>{
            'type' => 'TestException',
            'value' => 'Test error message',
            'module' => 'Sentry_Client',
            'stacktrace' => new Map<String, Object>{
              'frames' => new List<Object>{
                new Map<String, Object>{
                  'filename' => 'Sentry_Client.cls',
                  'function' => 'sendTestEnvelope',
                  'lineno' => 42,
                  'in_app' => true
                }
              }
            }
          }
        }
      },
      'request' => getRequestInfo(),
      'user' => getUserInfo(),
      'tags' => getTags(),
      'extra' => getExtraInfo()
    };

    String serializedEventPayload = JSON.serialize(eventPayload);

    // Event header
    String eventHeader = JSON.serialize(
      new Map<String, Object>{
        'type' => 'event',
        'length' => serializedEventPayload.length()
      }
    );

    // Combine all parts
    return envelopeHeader + '\n' + eventHeader + '\n' + serializedEventPayload;
  }

  private static Map<String, Object> getRequestInfo() {
    Map<String, Object> requestInfo = new Map<String, Object>{
      'url' => 'https://example.salesforce.com',
      'method' => 'GET'
    };

    try {
      requestInfo.put('url', currentRequestUrl);
      if (ApexPages.currentPage() != null) {
        requestInfo.put(
          'headers',
          new Map<String, String>{
            'User-Agent' => ApexPages.currentPage()
              .getHeaders()
              .get('User-Agent')
          }
        );
      }
    } catch (Exception e) {
      // If we can't get the real URL or headers, we'll use the default values
    }

    return requestInfo;
  }

  private static Map<String, String> getUserInfo() {
    return new Map<String, String>{
      'id' => UserInfo.getUserId(),
      'username' => UserInfo.getUserName(),
      'email' => UserInfo.getUserEmail()
    };
  }

  private static Map<String, String> getTags() {
    Map<String, String> tags = new Map<String, String>{
      'environment' => 'unknown',
      'release' => '1.0.0' // You might want to store this in a custom setting
    };

    try {
      Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1]
      .IsSandbox;
      tags.put('environment', isSandbox ? 'sandbox' : 'production');
    } catch (Exception e) {
      // If we can't determine the environment, we'll use the default 'unknown'
    }

    return tags;
  }

  private static Map<String, Object> getExtraInfo() {
    Map<String, Object> extraInfo = new Map<String, Object>{
      'server_name' => 'unknown',
      'apex_limit_usage' => new Map<String, Object>{
        'cpu_time' => Limits.getCpuTime(),
        'heap_size' => Limits.getHeapSize()
      }
    };

    try {
      extraInfo.put('server_name', orgDomainUrl);
    } catch (Exception e) {
      // If we can't get the real hostname, we'll use the default 'unknown'
    }

    return extraInfo;
  }

  public static void sendEnvelopeToSentry(String envelope) {

    System.debug('Got envelope: ' + envelope);
    HttpRequest req = new HttpRequest();
    String endpoint = getEnvelopeEndpointWithUrlEncodedAuth(null, sdkInfo);
    req.setEndpoint(endpoint);
    req.setHeader('Content-Type', 'application/x-sentry-envelope');
    req.setMethod('POST');
    req.setBody(envelope);

    Sentry_Log.logSentry(
      '[Sentry_Client.sendEnvelopeToSentry] Request Endpoint: ' + endpoint
    );
    Sentry_Log.logSentry(
      '[Sentry_Client.sendEnvelopeToSentry] Request Method: ' + req.getMethod()
    );
    Sentry_Log.logSentry(
      '[Sentry_Client.sendEnvelopeToSentry] Request Body: ' + envelope
    );

    try {
      HttpResponse resp = new Http().send(req);

      Sentry_Log.logSentry(
        '[Sentry_Client.sendEnvelopeToSentry] Response Status: ' +
        resp.getStatus()
      );
      Sentry_Log.logSentry(
        '[Sentry_Client.sendEnvelopeToSentry] Response Status Code: ' +
        resp.getStatusCode()
      );
      Sentry_Log.logSentry(
        '[Sentry_Client.sendEnvelopeToSentry] Response Body: ' + resp.getBody()
      );
      Sentry_Log.logSentry(
        '[Sentry_Client.sendEnvelopeToSentry] Response Headers: ' +
        resp.getHeaderKeys()
      );

      // Print curl command for debugging
      // System.debug(
      //   'curl -X POST ' +
      //     endpoint +
      //     ' -H "Content-Type: application/x-sentry-envelope" -d \'' +
      //     envelope +
      //     '\' -v'
      // );
      // Encode curl command for logging in base64 then system debug print it
      String curlCommand = 'curl -X POST ' +
        endpoint +
        ' -H "Content-Type: application/x-sentry-envelope" -d \'' +
        envelope +
        '\' -v';

      Blob curlCommandBlob = Blob.valueOf(curlCommand);
      String curlCommandBase64 = EncodingUtil.base64Encode(curlCommandBlob);
      System.debug('Curl command: ' + curlCommandBase64);
    } catch (Exception e) {
      System.debug('Error sending request to Sentry: ' + e.getMessage());
    }
  }

  public static void sendEventToSentry(String serializedEvent) {
    // String eventId = generateEventId();
    // String timestamp = DateTime.now()
    //   .formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
    // String envelopeHeader =
    //   '{"event_id":"' +
    //   eventId +
    //   '","sent_at":"' +
    //   timestamp +
    //   '","sdk":' +
    //   JSON.serialize(sdkInfo) +
    //   '}';
    // String eventHeader =
    //   '{"type":"event","length":' +
    //   serializedEvent.length() +
    //   '}';
    // String envelope =
    //   envelopeHeader +
    //   '\n' +
    //   eventHeader +
    //   '\n' +
    //   serializedEvent;

    String testEnvelope = generateTestEnvelope();
    String testEnvelope2 = generateTestEnvelopeFromSalesforce();

    System.debug(testEnvelope);
    System.debug('Salesforce envelope' + testEnvelope2);

    sendEnvelopeToSentry(testEnvelope2);
  
  }

  private static String generateEventId() {
    return EncodingUtil.convertToHex(Crypto.generateAesKey(128))
      .substring(0, 32)
      .toLowerCase();
  }
}
