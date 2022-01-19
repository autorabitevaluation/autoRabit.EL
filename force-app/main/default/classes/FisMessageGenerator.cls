public without sharing class FisMessageGenerator {
    
    @TestVisible 
	private class XFisChexMessageGenerationException extends Exception {}
	@TestVisible 
	private static String X_MISSING_REQUIRED_PROPERTY = 'Missing ChexSystems configured property';
	@TestVisible
	private static String X_USERINFO_QUERY_FAILED = 'Failed to query user info';
	@TestVisible
	private static String X_MISSING_FROM_FIELDSET = 'field missing from fieldset';
	@TestVisible
	private static String X_FIELD_EMPTY = 'field not filled out on Relationship';
	@TestVisible
	private static String X_FIELD_EMPTY_BRANCH = 'field not filled out on Branch, please also ensure the Branch is set on the Relationship';
	@TestVisible
	private static String X_NOT_NUMERIC = 'field should contain only numbers';
    @TestVisible
    private Map<String, String> configurationMap;
    @TestVisible
    private static Boolean forceUserError= false;

    public FisMessageGenerator(Map<String, String> configMap) {
        this.configurationMap = configMap;
    }
    
    @TestVisible    
	private Map<String,String> GetUserInfo(){
	
		return new Map<String,String>{
			'REQUESTEDBY_ID'=>UserInfo.getUserId(),
			'REQUESTEDBY_EMAIL'=>UserInfo.getUserEmail(),
			'REQUESTEDBY_FIRSTNAME'=>UserInfo.getFirstName(),
			'REQUESTEDBY_LASTNAME'=>UserInfo.getLastName(),
			'REQUESTEDBY_USERNAME'=>UserInfo.getUsername()
		};
	}
    
    public nFUSE.AMiddlewareMessage GenerateMessage(nFUSE.AMiddlewareMessage message){
		try{
			if(forceUserError){
				throw new XFisChexMessageGenerationException('forceUserError');
			}
			Map<String,String> userInfo = GetUserInfo();
			message.properties.put('REQUESTEDBY_ID', userInfo.get('REQUESTEDBY_ID'));
			message.properties.put('REQUESTEDBY_EMAIL', userInfo.get('REQUESTEDBY_EMAIL'));
			message.properties.put('REQUESTEDBY_FIRSTNAME', userInfo.get('REQUESTEDBY_FIRSTNAME'));
			message.properties.put('REQUESTEDBY_LASTNAME', userInfo.get('REQUESTEDBY_LASTNAME'));
			message.properties.put('REQUESTEDBY_USERNAME', userInfo.get('REQUESTEDBY_USERNAME'));
		}
		catch(Exception e){
			throw new XFisChexMessageGenerationException(X_USERINFO_QUERY_FAILED);
		}
	
		//Boiler Plate settings 
		message.properties.put('BUSINESS_DAYS_VALID', this.getProperty(FisChexCreditActivator.BUSINESS_DAYS_VALID));
		message.properties.put('CONSUMER_DAYS_VALID', this.getProperty(FisChexCreditActivator.CONSUMER_DAYS_VALID));	
		message.properties.put('COMMERCIAL_PLACEHOLDER_NAME', this.getProperty(FisChexCreditActivator.COMMERCIAL_PLACEHOLDER_NAME));
		message.properties.put('COMMERCIAL_APPEND_BUREAU_ID_TO_NAME', this.getProperty(FisChexCreditActivator.COMMERCIAL_APPEND_BUREAU_ID_TO_NAME));
		message.properties.put('CONSUMER_PLACEHOLDER_NAME', this.getProperty(FisChexCreditActivator.CONSUMER_PLACEHOLDER_NAME));
		message.properties.put('CONSUMER_APPEND_BUREAU_ID_TO_NAME', this.getProperty(FisChexCreditActivator.CONSUMER_APPEND_BUREAU_ID_TO_NAME));
		message.properties.put('PLACEHOLDER_CATEGORY', this.getProperty(FisChexCreditActivator.PLACEHOLDER_CATEGORY));
		message.properties.put('APPEND_DATE_TO_PLACEHOLDER_NAME', this.getProperty(FisChexCreditActivator.APPEND_DATE_TO_PLACEHOLDER_NAME));
		
		//FIS specific settings
		message.properties.put('CHEXSYSTEMS_USERNAME', this.getProperty(FisChexCreditActivator.CHEXSYSTEMS_USERNAME));
		message.properties.put('CHEXSYSTEMS_PASSWORD', this.getProperty(FisChexCreditActivator.CHEXSYSTEMS_PASSWORD));
		message.properties.put('STAGING_SERVER', this.getProperty(FisChexCreditActivator.STAGING_SERVER));
		message.properties.put('ACQUIRER_IDENTIFIER', this.getProperty(FisChexCreditActivator.ACQUIRER_IDENTIFIER));
		message.properties.put('PRODUCT_QUALIFILE', this.getProperty(FisChexCreditActivator.PRODUCT_QUALIFILE));
		message.properties.put('PRODUCT_CHEXSYSTEMS', this.getProperty(FisChexCreditActivator.PRODUCT_CHEXSYSTEMS));
		message.properties.put('PRODUCT_IDENTITY_MANAGER', this.getProperty(FisChexCreditActivator.PRODUCT_IDENTITY_MANAGER));
		message.properties.put('PRODUCT_OFAC', this.getProperty(FisChexCreditActivator.PRODUCT_OFAC));
		message.properties.put('QUALIFILE_VERSION_NUMBER', this.getProperty(FisChexCreditActivator.QUALIFILE_VERSION_NUMBER));
		message.properties.put('CHEXSYSTEMS_VERSION_NUMBER', this.getProperty(FisChexCreditActivator.CHEXSYSTEMS_VERSION_NUMBER));
		message.properties.put('REPORT_DATA_TYPE', this.getProperty(FisChexCreditActivator.REPORT_DATA_TYPE));


		message = addAddFieldsetProperties(message);

		return message;
	}
	@TestVisible
	private nFUSE.AMiddlewareMessage addAddFieldsetProperties(nFUSE.AMiddlewareMessage message){

		Map<String, Object> messageProps = new Map<String, Object>();

		messageProps = message.properties;

		for(String key : messageProps.keySet()) {

			if (key == 'record') {
				Object dataNode = messageProps.get(key);
				List<Object> objectList = (List<Object>) JSON.deserializeUntyped((String.valueOf(dataNode)));
				dataNode = objectList[0];

				Map<String, Object> dataNodeMap = (Map<String, Object>) dataNode;
				Object properties = dataNodeMap.get('properties');

				dataNodeMap = (Map<String, Object>) properties;

				message.properties.put('CHEXSYSTEMS_IDENTIFIER', getValueFromJSONData(dataNodeMap, 'ChexSystems_Identifier__c', true));

				message.properties.put('CHEXSYSTEMS_QUALIFILE_STRATEGY', getValueFromJSONData(dataNodeMap, 'ChexSystems_Qualifile_Strategy__c', false));
			}
		}

		return message;
	}
	@TestVisible
	private String getValueFromJSONData(Map<String, Object> dataNodeMap, String fieldAPIName, Boolean checkNumeric){
		Object dataNode = dataNodeMap.get(fieldAPIName);

		if(dataNode != null){
			dataNodeMap = (Map<String, Object>) dataNode;
			Object fieldValue = dataNodeMap.get('value');
			if(fieldValue != null && String.isNotEmpty(String.valueOf(fieldValue))){
				if(checkNumeric && !String.valueOf(fieldValue).isNumeric())
					throw new XFisChexMessageGenerationException(fieldAPIName + ' ' + X_NOT_NUMERIC);
				return String.valueOf(fieldValue);
			}
			else{
				if(fieldAPIName == 'ChexSystems_Identifier__c')
					throw new XFisChexMessageGenerationException(fieldAPIName + ' ' + X_FIELD_EMPTY_BRANCH);
				else
					throw new XFisChexMessageGenerationException(fieldAPIName + ' ' + X_FIELD_EMPTY);
			}
		}
		else
			throw new XFisChexMessageGenerationException(fieldAPIName + ' ' + X_MISSING_FROM_FIELDSET);
	}
	@TestVisible 
    private String getProperty(String propertyKey) {
        if(configurationMap == null || configurationMap.isEmpty()) return null;
        if(!configurationMap.containsKey(propertyKey)) {
            throw new XFisChexMessageGenerationException(
                    X_MISSING_REQUIRED_PROPERTY + ': ' + propertyKey
            );
        }
        return configurationMap.get(propertyKey);
    }
}