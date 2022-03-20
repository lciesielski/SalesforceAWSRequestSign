public virtual without sharing class AmazonWebServicesHelper {

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

	public enum Config {
		AWS_KEY,
		AWS_SECRET
	}

	public enum Encoding {
		UTF_8
	}

	@SuppressWarnings('PMD.FieldNamingConventions')
	public enum HashAlgorithm {
		AWS4_HMAC_SHA256,
		hmacSHA256,
		SHA256
	}

	public enum HttpMethod {
		HTTP_GET,
		HTTP_POST,
		HTTP_PUT,
		HTTP_DELETE
	}

	public final Integer presignURLExpiration = 30;

	protected String getPresignedURLSignature(RequestData requestData) {
		final DateTime now = System.now();
		final String nowDate = now.format('yyyyMMdd');
		final String nowDateTime = now.format('yyyyMMdd\'T\'HHmmss\'Z\'');
		final String hostHeader = 'host';
		final String request = 
			nowDate + '/' + requestData.serviceRegion + '/' + requestData.serviceName + '/' + AmazonSpecific.aws4_request.name();

		final String credential = encodeString(
			requestData.key + '/' + request,
			true
		);

		final String requiredSignatureQueryParameters = 
			EnumUtils.getNameWithDashes(AmazonSpecific.X_Amz_Algorithm) + '=' + 
				EnumUtils.getNameWithDashes(HashAlgorithm.AWS4_HMAC_SHA256) + '&' +
			EnumUtils.getNameWithDashes(AmazonSpecific.X_Amz_Credential) + '=' + credential + '&' +
			EnumUtils.getNameWithDashes(AmazonSpecific.X_Amz_Date) + '=' + nowDateTime + '&' +
			EnumUtils.getNameWithDashes(AmazonSpecific.X_Amz_Expires) + '=' + presignURLExpiration + '&' +
			EnumUtils.getNameWithDashes(AmazonSpecific.X_Amz_SignedHeaders) + '=' + hostHeader;

		final String canonicalRequest = 
			EnumUtils.getHttpMethod(requestData.httpMethod) + '\n' +
			'/' + requestData.path + '\n' +
			requiredSignatureQueryParameters + '\n' +
			hostHeader + ':' + requestData.host + '\n\n' + 
			hostHeader + '\n' +
			EnumUtils.getNameWithDashes(AmazonSpecific.UNSIGNED_PAYLOAD);

		final String toSign = 
			EnumUtils.getNameWithDashes(HashAlgorithm.AWS4_HMAC_SHA256) + '\n' +
			nowDateTime + '\n' +
			request + '\n' + 
			EncodingUtil.convertToHex(
				Crypto.generateDigest(
					HashAlgorithm.SHA256.name(), 
					Blob.valueOf(canonicalRequest)
				)
			);

		final Blob signingKey = Crypto.generateMac(
			HashAlgorithm.hmacSHA256.name(), 
			Blob.valueOf(AmazonSpecific.aws4_request.name()), 
			Crypto.generateMac(
				HashAlgorithm.hmacSHA256.name(), 
				Blob.valueOf(requestData.serviceName), 
				Crypto.generateMac(
					HashAlgorithm.hmacSHA256.name(), 
					Blob.valueOf(requestData.serviceRegion), 
					Crypto.generateMac(
						HashAlgorithm.hmacSHA256.name(), 
						Blob.valueOf(nowDate), 
						Blob.valueOf(AmazonSpecific.AWS4.name() + requestData.secret)
					)
				)
			)
		);

		final String signature = EncodingUtil.convertToHex(
			Crypto.generateMac(
				HashAlgorithm.hmacSHA256.name(), 
				Blob.valueOf(toSign), 
				signingKey
			)
		);

		return '?' + requiredSignatureQueryParameters + '&' +
			EnumUtils.getNameWithDashes(AmazonSpecific.X_Amz_Signature) + '=' + signature;
	}

	protected String encodeString(String toEncode, Boolean encodeSlash) {
		final String space = ' ';
		final String plus = '\\+';
		final String tilde = '~';
		final String slash = '/';

		String result = 
			EncodingUtil.urlEncode(toEncode, EnumUtils.getNameWithDashes(Encoding.UTF_8))
				.replaceAll(
					EncodingUtil.urlEncode(tilde, EnumUtils.getNameWithDashes(Encoding.UTF_8)), 
					tilde
				)
				.replaceAll(
					plus, 
					EncodingUtil.urlEncode(space, EnumUtils.getNameWithDashes(Encoding.UTF_8))
				);

		if (!encodeSlash) {
			result = result.replaceAll(
				EncodingUtil.urlEncode(slash, EnumUtils.getNameWithDashes(Encoding.UTF_8)), 
				slash
			);
		}

		return result;
	}

	public abstract class RequestData {
		public HttpMethod httpMethod;
		
		public String key;
		public String secret;

		public String host;
		public String path;
		public String serviceName;
		public String serviceRegion;
	}

}