/**
----------------------------------------------------------------------
-- - Name              :  MockHttpResponseGenerator
-- - Author            :  Bilal MOUSSI
-- - Description       :  Classe permettant la creation de fake response pour les HttpRequest

-- Maintenance History :    
--
-- Date                 Name                        Version          Remarks 
-- -----------          -----------                 --------         ------------------
-- 11-05-2021           Bilal MOUSSI                1.0              Initial version
---------------------------------------------------------------------------------------
*/
@IsTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"test":"good"}');
        res.setStatusCode(200);
        return res;
    }
}