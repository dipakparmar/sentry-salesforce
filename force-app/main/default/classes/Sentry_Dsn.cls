public with sharing class Sentry_Dsn {
  public String privateKey;
  public String publicKey;
  public String projectId;
  public string protocol;
  public Url url;
  public String sentryHost;

  public Sentry_Dsn(String dsn) {
    url = new Url(dsn);
    this.publicKey = getPublicKey(url);
    this.privateKey = getPrivateKey(url);
    this.projectId = getProjectId(url);
    this.protocol = url.getProtocol();
    this.sentryHost = url.getHost();
  }

  /**
   * Returns the project ID from the given URL.
   *
   * @param url The URL from which to extract the project ID.
   * @return The project ID extracted from the URL, or null if the URL is invalid.
   * @example https://add@sss.dd.ss.s.com/s123 -> s123
   */
  String getProjectId(URL url) {
    String[] pieces = url.getPath().split('/');

    if (pieces.size() == 0) {
      return null;
    }

    return pieces[pieces.size() - 1];
  }

  String getPublicKey(URL url) {
    String userInfo = url.getUserInfo();

    if (userInfo == null) {
      return null;
    }

    if (userInfo.contains(':')) {
      return userInfo.split(':')[0];
    }

    return userInfo;
  }

  String getPrivateKey(URL url) {
    String userInfo = url.getUserInfo();

    if (userInfo != null) {
      String[] pieces = userInfo.split(':');

      if (pieces.size() == 2) {
        return pieces[1];
      }
    }

    return null;
  }

}
