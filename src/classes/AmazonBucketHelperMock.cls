@IsTest
public class AmazonBucketHelperMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest request) {
        final HttpResponse response = new HttpResponse();

        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"success":"true"}');
        response.setStatusCode(200);

        return response; 
    }

}