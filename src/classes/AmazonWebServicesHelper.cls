public without sharing class AmazonWebServicesHelper {

	public void DeleteObjectFromBucketSelfSigned() {
		final DateTime now = System.now();
		final String payload = '';
		final String hashedPayload = EncodingUtil.convertToHex(Crypto.generateDigest('SHA256', Blob.valueOf(payload))).toLowerCase();

		final String canonicalRequest = 
			'DELETE' + '\n' +
			'/dark-wanderer-bg-max.webm\n' +
			'X-Amz-Algorithm=AWS4-HMAC-SHA256&' +
			'X-Amz-Credential=%2F' + now.format('yyyyMMdd') + '%2Feu-central-1%2Fs3%2Faws4_request&' +
			'X-Amz-Date=' + now.format('yyyyMMdd\'T\'HHmmss\'Z\'') + '&' +
			'X-Amz-Expires=60&' +
			'X-Amz-SignedHeaders=host\n' +
			'host:asgard-0.s3.eu-central-1.amazonaws.com\n\n' + 
			'host\n' +
			'UNSIGNED-PAYLOAD';

		System.debug(canonicalRequest);

		final String toSign = 
			'AWS4-HMAC-SHA256\n' +
			now.format('yyyyMMdd\'T\'HHmmss\'Z\'') + '\n' +
			now.format('yyyyMMdd') + '/eu-central-1/s3/aws4_request\n' + 
			EncodingUtil.convertToHex(Crypto.generateDigest('SHA256', Blob.valueOf(canonicalRequest)));

		System.debug(toSign);

		Blob signingKey = 
			Crypto.generateMac('hmacSHA256', Blob.valueOf('aws4_request'), Crypto.generateMac(
				'hmacSHA256', Blob.valueOf('s3'), 
				Crypto.generateMac(
					'hmacSHA256', Blob.valueOf('eu-central-1'), 
					Crypto.generateMac(
						'hmacSHA256', 
						Blob.valueOf(now.format('yyyyMMdd')), 
						Blob.valueOf('AWS4')
					)
				)
			)
		);

		final String signature = EncodingUtil.convertToHex(
			Crypto.generateMac('hmacSHA256', Blob.valueOf(toSign), signingKey)
		);

		System.debug(signature);

		final HttpRequest request = new HttpRequest();
		request.setEndpoint(
			'https://asgard-0.s3.eu-central-1.amazonaws.com/dark-wanderer-bg-max.webm?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=' + 
				EncodingUtil.urlEncode('AKIA3YI7VWD5YGOEQ662/' + now.format('yyyyMMdd') + '/eu-central-1/s3/aws4_request', 'UTF-8') + 
				'&X-Amz-Date=' + now.format('yyyyMMdd\'T\'HHmmss\'Z\'') + 
				'&X-Amz-Expires=60&X-Amz-Signature=' + signature + '&X-Amz-SignedHeaders=host'
		);
		request.setMethod('DELETE');

		System.debug(new Http().send(request).getBody());
	}

}