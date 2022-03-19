public without sharing class AmazonBucketHelper extends AmazonWebServicesHelper {

	public void deleteBucketObject(String awsKey, String awsSecret) {
		final AmazunBucketData awsBucketData = new AmazunBucketData();

		awsBucketData.awsKey = awsKey;
		awsBucketData.awsSecret = awsSecret;

		awsBucketData.bucketName = 'asgard-0';
		awsBucketData.objectKey = ':~~.jpg';

		awsBucketData.httpMethod = HttpMethod.HTTP_DELETE;
		awsBucketData.path = encodeString(awsBucketData.objectKey, false);
		awsBucketData.serviceName = 's3';
		awsBucketData.serviceRegion = 'eu-central-1';
		awsBucketData.host = 
			awsBucketData.bucketName + '.' + 
			awsBucketData.serviceName + '.' + 
			awsBucketData.serviceRegion + '.amazonaws.com';

		final HttpRequest request = new HttpRequest();	
		request.setMethod(awsBucketData.httpMethod.name().removeStart('HTTP_'));
		request.setEndpoint(
			'https://' + awsBucketData.host + '/' + awsBucketData.path + getSignatureWithoutPayload(awsBucketData)
		);
		
		new Http().send(request);
	}

	public class AmazunBucketData extends AmazonData {
		public String bucketName;
		public String objectKey;
	}

}