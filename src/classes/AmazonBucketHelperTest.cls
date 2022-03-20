@IsTest
private class AmazonBucketHelperTest {

	private static final String FILE_NAME = '3032248';
	private static final String FILE_EXTENSION = '.jpg';

	@TestSetup
	private static void setup() {
		insert new List<Configuration__c>{
			new Configuration__c(
				Name = AmazonWebServicesHelper.Config.AWS_KEY.name(),
				Value__c = AmazonWebServicesHelper.Config.AWS_KEY.name()
			), 
			new Configuration__c(
				Name = AmazonWebServicesHelper.Config.AWS_SECRET.name(),
				Value__c = AmazonWebServicesHelper.Config.AWS_SECRET.name()
			)
		};

		insert new ContentVersion(
			Title = FILE_NAME,
			PathOnClient = FILE_NAME + FILE_EXTENSION,
			VersionData = Blob.valueOf('FAKE_DATA'),
			IsMajorVersion = true
		);
	}

	@IsTest
	private static void itShouldDeleteObjectQueryAuth() {
		// Given
		final AmazonBucketHelper.ExtendedRequestData awsBucketData = initBucketData();
		awsBucketData.objectKey = FILE_NAME + FILE_EXTENSION;
		awsBucketData.httpMethod = AmazonWebServicesHelper.HttpMethod.HTTP_DELETE;

		Test.setMock(HttpCalloutMock.class, new AmazonBucketHelperMock());

		// When
		Test.startTest();
		final HttpResponse response = 
			new AmazonBucketHelper(awsBucketData).sendRequestParamAuthorization();

		// Then
		System.assertEquals(
			200,
			response.getStatusCode()
		);
		Test.stopTest();
	}

	@IsTest
	private static void itShouldPutObjectQueryAuth() {
		// Given
		final ContentVersion document = [
			SELECT ContentSize, FileExtension, Title, VersionData 
			FROM ContentVersion 
			WHERE Title = :FILE_NAME
		];

		final AmazonBucketHelper.ExtendedRequestData awsBucketData = initBucketData();
		awsBucketData.objectKey = document.Title + '.' + document.FileExtension;
		awsBucketData.binaryPayload = document.VersionData;
		awsBucketData.httpMethod = AmazonWebServicesHelper.HttpMethod.HTTP_PUT;
		awsBucketData.headers.put('Content-Length', String.valueOf(document.ContentSize));

		Test.setMock(HttpCalloutMock.class, new AmazonBucketHelperMock());

		// When
		Test.startTest();
		final HttpResponse response = 
			new AmazonBucketHelper(awsBucketData).sendRequestParamAuthorization();

		// Then
		System.assertEquals(
			200,
			response.getStatusCode()
		);
		Test.stopTest();
	}

	@IsTest
	private static void itShouldDeleteObjectHeaderAuth() {
		// Given
		final AmazonBucketHelper.ExtendedRequestData awsBucketData = initBucketData();
		awsBucketData.objectKey = FILE_NAME + FILE_EXTENSION;
		awsBucketData.httpMethod = AmazonWebServicesHelper.HttpMethod.HTTP_DELETE;

		Test.setMock(HttpCalloutMock.class, new AmazonBucketHelperMock());

		// When
		Test.startTest();
		final HttpResponse response = 
			new AmazonBucketHelper(awsBucketData).sendRequestHeaderAuthorization();

		// Then
		System.assertEquals(
			200,
			response.getStatusCode()
		);
		Test.stopTest();
	}

	private static AmazonBucketHelper.ExtendedRequestData initBucketData() {
		final AmazonBucketHelper.ExtendedRequestData result = 
			new AmazonBucketHelper.ExtendedRequestData();

		result.key = Configuration__c.getInstance(
			AmazonWebServicesHelper.Config.AWS_KEY.name()
		).Value__c;
		result.secret = Configuration__c.getInstance(
			AmazonWebServicesHelper.Config.AWS_SECRET.name()
		).Value__c;

		result.serviceName = 's3';
		result.serviceRegion = 'eu-central-1';
		result.bucketName = 'asgard-0';

		return result;
	}

}