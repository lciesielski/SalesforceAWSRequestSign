public abstract without sharing class EnumUtils {

	public static String getNameWithDashes(Object enumValue) {
		return String.valueOf(enumValue).replaceAll('_', '-');
	} 

	public static String getHttpMethod(AmazonWebServicesHelper.HttpMethod enumValue) {
		return enumValue.name().removeStart('HTTP_');
	} 

}