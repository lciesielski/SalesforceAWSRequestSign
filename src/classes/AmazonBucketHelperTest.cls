@IsTest
private class AmazonBucketHelperTest {

	private static final String FILE_NAME = '3032248';

	@TestSetup
	private static void setup() {
		insert new List<Configuration__c>{
			new Configuration__c(
				Name = 'AWS_KEY',
				Value__c = 'AWS_KEY'
			), 
			new Configuration__c(
				Name = 'AWS_SECRET',
				Value__c = 'AWS_SECRET'
			)
		};

		insert new ContentVersion(
			Title = FILE_NAME,
			PathOnClient = FILE_NAME + '.jpg',
			VersionData = Blob.valueOf('Test Content'),
			IsMajorVersion = true
		);
	}

	@IsTest
	private static void itShouldDeleteObject() {
		// Given
		final AmazonBucketHelper.ExtendedRequestData awsBucketData = 
			new AmazonBucketHelper.ExtendedRequestData();
		
		awsBucketData.key = Configuration__c.getInstance(
			AmazonWebServicesHelper.Config.AWS_KEY.name()
		).Value__c;
		awsBucketData.secret = Configuration__c.getInstance(
			AmazonWebServicesHelper.Config.AWS_SECRET.name()
		).Value__c;

		awsBucketData.serviceName = 's3';
		awsBucketData.serviceRegion = 'eu-central-1';
		awsBucketData.bucketName = 'asgard-0';
		awsBucketData.objectKey = '3032248.jpg';
		awsBucketData.httpMethod = AmazonWebServicesHelper.HttpMethod.HTTP_DELETE;

		Test.setMock(HttpCalloutMock.class, new AmazonBucketHelperMock());

		// When
		Test.startTest();
		final HttpResponse response = 
			new AmazonBucketHelper(awsBucketData).sendRequestToS3Bucket();

		// Then
		System.assertEquals(
			200,
			response.getStatusCode()
		);
		Test.stopTest();
	}

	@IsTest
	private static void itShouldPutObject() {
		// Given
		final ContentVersion document = [
			SELECT ContentSize, FileExtension, Title, VersionData 
			FROM ContentVersion 
			WHERE Title = :FILE_NAME
		];

		final AmazonBucketHelper.ExtendedRequestData awsBucketData = 
			new AmazonBucketHelper.ExtendedRequestData();

		awsBucketData.key = Configuration__c.getInstance(
			AmazonWebServicesHelper.Config.AWS_KEY.name()
		).Value__c;
		awsBucketData.secret = Configuration__c.getInstance(
			AmazonWebServicesHelper.Config.AWS_SECRET.name()
		).Value__c;

		awsBucketData.serviceName = 's3';
		awsBucketData.serviceRegion = 'eu-central-1';
		awsBucketData.bucketName = 'asgard-0';
		awsBucketData.objectKey = document.Title + '.' + document.FileExtension;
		awsBucketData.binaryPayload = document.VersionData;
		awsBucketData.httpMethod = AmazonWebServicesHelper.HttpMethod.HTTP_PUT;
		awsBucketData.headers.put('Content-Length', String.valueOf(document.ContentSize));

		Test.setMock(HttpCalloutMock.class, new AmazonBucketHelperMock());

		// When
		Test.startTest();
		final HttpResponse response = 
			new AmazonBucketHelper(awsBucketData).sendRequestToS3Bucket();

		// Then
		System.assertEquals(
			200,
			response.getStatusCode()
		);
		Test.stopTest();
	}

}