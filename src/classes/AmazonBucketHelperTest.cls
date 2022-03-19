@IsTest
private class AmazonBucketHelperTest {

	@IsTest
	private static void itShouldDewleteObject() {
		// Given
		Test.setMock(HttpCalloutMock.class, new AmazonBucketHelperMock());

		// When
		final HttpResponse response = new AmazonBucketHelper().deleteBucketObject(
			'key', 'secret', 'bucketName', 'objectKey'
		);

		// Then
		System.assertEquals(
			200,
			response.getStatusCode()
		);
	}

}