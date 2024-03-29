public without sharing class AmazonBucketHelper extends AmazonWebServicesHelper {

	private final ExtendedRequestData awsBucketData;

	public AmazonBucketHelper(ExtendedRequestData awsBucketData) {
		this.awsBucketData = awsBucketData;
	}

	public HttpResponse sendRequestParamAuthorization() {
		awsBucketData.path = encodeString(awsBucketData.bucketName + '/' + awsBucketData.objectKey, false);
		awsBucketData.host = 
			awsBucketData.serviceName + '.' + 
			awsBucketData.serviceRegion + '.amazonaws.com';

		final HttpRequest request = new HttpRequest();	
		request.setMethod(awsBucketData.httpMethod.name().removeStart('HTTP_'));
		request.setEndpoint(
			'https://' + awsBucketData.host + '/' + awsBucketData.path + getPresignedURLSignature(awsBucketData)
		);

		if (awsBucketData.binaryPayload != null) {
			request.setBodyAsBlob(awsBucketData.binaryPayload);
		}

		if (!awsBucketData.headers.isEmpty()) {
			for (String key : awsBucketData.headers.keySet()) {
				request.setHeader(key, awsBucketData.headers.get(key));
			}
		}

		return HttpWrapper.CLIENT.send(request);
	}

	public HttpResponse sendRequestHeaderAuthorization() {
		awsBucketData.path = encodeString(awsBucketData.bucketName + '/' + awsBucketData.objectKey, false);
		awsBucketData.host = 
			awsBucketData.serviceName + '.' + 
			awsBucketData.serviceRegion + '.amazonaws.com';

		final HttpRequest request = new HttpRequest();	
		request.setMethod(awsBucketData.httpMethod.name().removeStart('HTTP_'));
		request.setEndpoint(
			'https://' + awsBucketData.host + '/' + awsBucketData.path
		);

		if (awsBucketData.binaryPayload != null) {
			request.setBodyAsBlob(awsBucketData.binaryPayload);
		}

		if (!awsBucketData.headers.isEmpty()) {
			for (String key : awsBucketData.headers.keySet()) {
				request.setHeader(key, awsBucketData.headers.get(key));
			}
		}

		final Map<String, String> authorizationHeaders = getHeadersSignature(awsBucketData);

		for (String authorizationHeader : authorizationHeaders.keySet()) {
			request.setHeader(
				authorizationHeader, 
				authorizationHeaders.get(authorizationHeader)
			);
		}

		return HttpWrapper.CLIENT.send(request);
	}

	public class ExtendedRequestData extends RequestData {
		public Map<String, String> headers = new Map<String, String>();
		
		public Blob binaryPayload;
		public String bucketName;
		public String objectKey;
	}

}