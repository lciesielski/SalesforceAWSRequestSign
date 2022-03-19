public virtual without sharing class AmazonWebServicesHelper {

	public final Integer maxTimeout = 2 * 60 * 1000;

	@SuppressWarnings('PMD.FieldNamingConventions')
	public enum AmazonSpecific {
		aws4_request,
		X_Amz_Algorithm,
		X_Amz_Credential,
		X_Amz_Date,
		X_Amz_Expires,
		X_Amz_Signature,
		X_Amz_SignedHeaders,
		AWS4,
		UNSIGNED_PAYLOAD
	}

	@SuppressWarnings('PMD.FieldNamingConventions')
	public enum HashAlgorithm {
		AWS4_HMAC_SHA256,
		hmacSHA256,
		SHA256
	}

	public enum Encoding {
		UTF_8
	}

	public enum HttpMethod {
		HTTP_GET,
		HTTP_POST,
		HTTP_PUT,
		HTTP_DELETE
	}

	protected String getSignatureWithoutPayload(AmazonData awsData) {
		final DateTime now = System.now();
		final String nowDate = now.format('yyyyMMdd');
		final String nowDateTime = now.format('yyyyMMdd\'T\'HHmmss\'Z\'');
		final String hostHeader = 'host';
		final String request = nowDate + '/' + awsData.serviceRegion + '/' + awsData.serviceName + '/' + AmazonSpecific.aws4_request.name();

		final String credential = encodeString(
			awsData.awsKey + '/' + request,
			true
		);

		final String requiredSignatureQueryParameters = 
			AmazonSpecific.X_Amz_Algorithm.name().replaceAll('_', '-') + '=' + 
				HashAlgorithm.AWS4_HMAC_SHA256.name().replaceAll('_', '-') + '&' +
			AmazonSpecific.X_Amz_Credential.name().replaceAll('_', '-') + '=' + credential + '&' +
			AmazonSpecific.X_Amz_Date.name().replaceAll('_', '-') + '=' + nowDateTime + '&' +
			AmazonSpecific.X_Amz_Expires.name().replaceAll('_', '-') + '=' + maxTimeout + '&' +
			AmazonSpecific.X_Amz_SignedHeaders.name().replaceAll('_', '-') + '=' + hostHeader;

		final String canonicalRequest = 
			awsData.httpMethod.name().removeStart('HTTP_') + '\n' +
			'/' + awsData.path + '\n' +
			requiredSignatureQueryParameters + '\n' +
			hostHeader + ':' + awsData.host + '\n\n' + 
			hostHeader + '\n' +
			AmazonSpecific.UNSIGNED_PAYLOAD.name().replaceAll('_', '-');

		final String toSign = 
			HashAlgorithm.AWS4_HMAC_SHA256.name().replaceAll('_', '-') + '\n' +
			nowDateTime + '\n' +
			request + '\n' + 
			EncodingUtil.convertToHex(
				Crypto.generateDigest(HashAlgorithm.SHA256.name(), 
				Blob.valueOf(canonicalRequest))
			);

		final Blob signingKey = 
			Crypto.generateMac(
				HashAlgorithm.hmacSHA256.name(), 
				Blob.valueOf(AmazonSpecific.aws4_request.name()), 
				Crypto.generateMac(
					HashAlgorithm.hmacSHA256.name(), 
					Blob.valueOf(awsData.serviceName), 
					Crypto.generateMac(
						HashAlgorithm.hmacSHA256.name(), 
						Blob.valueOf(awsData.serviceRegion), 
						Crypto.generateMac(
							HashAlgorithm.hmacSHA256.name(), 
							Blob.valueOf(nowDate), 
							Blob.valueOf(AmazonSpecific.AWS4.name() + awsData.awsSecret
						)
					)
				)
			)
		);

		final String signature = EncodingUtil.convertToHex(
			Crypto.generateMac(
				HashAlgorithm.hmacSHA256.name(), 
				Blob.valueOf(toSign), signingKey
			)
		);

		return '?' + requiredSignatureQueryParameters + '&' +
			AmazonSpecific.X_Amz_Signature.name().replaceAll('_', '-') + '=' + signature;
	}

	protected String encodeString(String toEncode, Boolean encodeSlash) {
		final String space = ' ';
		final String plus = '\\+';
		final String tilde = '~';
		final String slash = '/';

		String result = 
			EncodingUtil.urlEncode(toEncode, Encoding.UTF_8.name().replace('_', '-'))
				.replaceAll(
					EncodingUtil.urlEncode(tilde, Encoding.UTF_8.name().replace('_', '-')), 
					tilde
				)
				.replaceAll(
					plus, 
					EncodingUtil.urlEncode(space, Encoding.UTF_8.name().replace('_', '-'))
				);

		if (!encodeSlash) {
			result = result.replaceAll(
				EncodingUtil.urlEncode(slash, Encoding.UTF_8.name().replace('_', '-')), 
				slash
			);
		}

		return result;
	}

	public virtual class AmazonData {
		public HttpMethod httpMethod;
		
		public String awsKey;
		public String awsSecret;

		public String host;
		public String path;
		public String serviceName;
		public String serviceRegion;
		public String payload = '';
	}

}