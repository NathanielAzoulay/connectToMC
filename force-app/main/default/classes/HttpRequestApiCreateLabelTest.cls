@isTest
private class HttpRequestApiCreateLabelTest {
    @isTest
    public static void testPostDataCallout() {
      string endpoint = 'https://v4/test'; 

      string data = '{"test":"45897"}';

      string responseBody = '{"id":"1323"}';
      // Créez un objet HttpRequestApiCreateLabel pour tester
      HttpRequestApiCreateLabel api = new HttpRequestApiCreateLabel();
      SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', responseBody, null);
      Test.setMock(HttpCalloutMock.class, fakeResponse);

      HTTPResponse res = HttpRequestApiCreateLabel.postData(endpoint, data);
      HttpRequestApiCreateLabel.addHeader('Content-Type', 'application/json');
    }
}