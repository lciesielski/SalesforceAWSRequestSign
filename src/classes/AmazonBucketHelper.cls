public without sharing class AmazonBucketHelper extends AmazonWebServicesHelper {

	public HttpResponse deleteBucketObject(String awsKey, String awsSecret, String bucketName, String objectKey) {
		final AmazunBucketData awsBucketData = new AmazunBucketData();

		awsBucketData.awsKey = awsKey;
		awsBucketData.awsSecret = awsSecret;

		awsBucketData.bucketName = bucketName;
		awsBucketData.objectKey = objectKey;

		awsBucketData.httpMethod = HttpMethod.HTTP_DELETE;
		awsBucketData.path = encodeString(awsBucketData.bucketName + '/' + awsBucketData.objectKey, false);
		awsBucketData.serviceName = 's3';
		awsBucketData.serviceRegion = 'eu-central-1';
		awsBucketData.host = 
			awsBucketData.serviceName + '.' + 
			awsBucketData.serviceRegion + '.amazonaws.com';

		final HttpRequest request = new HttpRequest();	
		request.setMethod(awsBucketData.httpMethod.name().removeStart('HTTP_'));
		request.setEndpoint(
			'https://' + awsBucketData.host + '/' + awsBucketData.path + getSignatureWithoutPayload(awsBucketData)
		);

		return CLIENT.send(request);
	}

	public class AmazunBucketData extends AmazonData {
		public String bucketName;
		public String objectKey;
	}

}