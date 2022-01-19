public without sharing class EquifaxMessageGenerator {
    
    @TestVisible private class XEquifaxMessageGenerationException extends Exception {}
    @TestVisible private Map<String, String> configurationMap;
    @TestVisible private static String X_MISSING_REQUIRED_PROPERTY = Label.X_MISSING_REQUIRED_PROPERTY;
    @TestVisible private static String X_USERINFO_QUERY_FAILED = Label.X_USERINFO_QUERY_FAILED;
    @TestVisible private static String X_PRODUCT_LIMIT_EXCEEDED = Label.X_PRODUCT_LIMIT_EXCEEDED;
    @TestVisible private static String X_MISSING_UNKNOWN_REPORT_TYPE = Label.X_MISSING_UNKNOWN_REPORT_TYPE;
    @TestVisible private static Boolean forceUserError= false;
    @TestVisible private static String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
    
    public EquifaxMessageGenerator(Map<String, String> configMap) {
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
	
	//Get URL properties to handle custom domains in link generation
	//Lines commented out below for lightning url generation are valid but not yet being utilized
	@TestVisible
	private Map<String,String> GetURLProperties(){
		Organization organizationObject = [select InstanceName, UISkin from Organization];
		String customDomain = '';
		String instanceURL = 'https://'+organizationObject.InstanceName.toLowerCase()+'.salesforce.com';
	    //String lightningInstanceURl = '';
		//String lightningCustomDomainURL = '';	
		
		//If sfdcURL isnt instanceURL, assign custom domain
		if(sfdcURL.toLowerCase().contains('--')){
			customDomain = sfdcURL.replace('--nfuse', '--c');
		}
			
		// //Assign lightning instance url
		// if(sfdcURL.toLowerCase().contains('--')){
    	//	lightningCustomDomainURL = customDomain.replace('my.salesforce.','lightning.force.');
		// }
		// //Assign lightning custom domain url if custom domain exists
		// else{
		// 	lightningInstanceURL = instanceURL.replace('.salesforce.','.lightning.force.');
		// }
		
		// // Query current user to see if lightning is enabled
		// List<User> user = [SELECT UserPreferencesLightningExperiencePreferred FROM User WHERE Id = :UserInfo.getUserId()];
		
		// //Query list of users who have lightning disabled to check if lightning is turned on orgwide
		// List<User> orgUsers = [SELECT UserPreferencesLightningExperiencePreferred FROM User WHERE UserPreferencesLightningExperiencePreferred = false];
		
		return new Map<String,String>{
			'INSTANCEURL'=> instanceURL,
			'CUSTOMDOMAIN' => customDomain
			
			//'CURRENTUSER_LIGHTNINGON' => user[0].UserPreferencesLightningExperiencePreferred == true ? 'On': 'Off',
			//'LIGHTNINGINSTANCEURL' => lightningInstanceURL,
			//'LIGHTNINGCUSTOMDOMAINURL' => lightningCustomDomainURL,
			//'ORG_LIGHTNINGON' => orgUsers.size() > 0 ? 'Off': 'On',
			//'ORG_UISKIN' => organizationObject.UISkin != 'Theme4d' ? 'Classic' : 'Lightning'
		};
	}
	    
	public nFUSE.AMiddlewareMessage GenerateMessage(nFUSE.AMiddlewareMessage message){
		//FROM DATA-2576 ------ Moving query of UserInfo from middleware to SF plugin
		try{
			if(forceUserError){
				throw new XEquifaxMessageGenerationException('forceUserError');
			}
			Map<String,String> userInfo = GetUserInfo();
			message.properties.put('REQUESTEDBY_ID', userInfo.get('REQUESTEDBY_ID'));
			message.properties.put('REQUESTEDBY_EMAIL', userInfo.get('REQUESTEDBY_EMAIL'));
			message.properties.put('REQUESTEDBY_FIRSTNAME', userInfo.get('REQUESTEDBY_FIRSTNAME'));
			message.properties.put('REQUESTEDBY_LASTNAME', userInfo.get('REQUESTEDBY_LASTNAME'));
			message.properties.put('REQUESTEDBY_USERNAME', userInfo.get('REQUESTEDBY_USERNAME'));
		}
		catch(Exception e){
			throw new XEquifaxMessageGenerationException(X_USERINFO_QUERY_FAILED);
		}
		
		//FROM DATA-3322 ---- Add url information to message properties, to accurately generate links for docman credit reports 
		Map<String,String> urlInfo = GetURLProperties();
		
		message.properties.put('INSTANCEURL', urlInfo.get('INSTANCEURL'));
		message.properties.put('CUSTOMDOMAIN', urlInfo.get('CUSTOMDOMAIN'));
		//message.properties.put('LIGHTNINGINSTANCEURL', urlInfo.get('LIGHTNINGINSTANCEURL'));
		//message.properties.put('LIGHTNINGCUSTOMDOMAINURL', urlInfo.get('LIGHTNINGCUSTOMDOMAINURL'));
		//message.properties.put('CURRENTUSER_LIGHTNINGON', urlInfo.get('CURRENTUSER_LIGHTNINGON'));
		//message.properties.put('ORG_LIGHTNINGON', urlInfo.get('ORG_LIGHTNINGON'));
		//message.properties.put('ORG_UISKIN', urlInfo.get('ORG_UISKIN'));
    	
		if(isBusinessCreditMessage(message)){
			mergeBusinessPropertiesToMessage(message);
		}
		else if(isConsumerCreditMessage(message)){
			mergeConsumerPropertiesToMessage(message);
		}
		else throw new XEquifaxMessageGenerationException(X_MISSING_UNKNOWN_REPORT_TYPE);
		
		//Validate that no more than 5 products are set to "Y"
		validateProductLimit(message);
		
		//DATA-1607
		message.properties.put(EquifaxCreditActivator.PLACEHOLDER_CATEGORY,
				this.getProperty(EquifaxCreditActivator.PLACEHOLDER_CATEGORY));
		message.properties.put(EquifaxCreditActivator.APPEND_DATE_TO_PLACEHOLDER_NAME,
				this.getProperty(EquifaxCreditActivator.APPEND_DATE_TO_PLACEHOLDER_NAME));
		return message;
	}
	
	private Boolean isBusinessCreditMessage(nFUSE.AMiddlewareMessage message){
		return message.properties.get(REPORT_TYPE) == REPORT_TYPE_BUSINESS;
	}

	private Boolean isConsumerCreditMessage(nFUSE.AMiddlewareMessage message){
		String reportType = (String)message.properties.get(REPORT_TYPE);

		return reportType == REPORT_TYPE_HARD || reportType == REPORT_TYPE_SOFT;
	}

	private void mergeConsumerPropertiesToMessage(nFUSE.AMiddlewareMessage message){
		String reportType = (String)message.properties.get(REPORT_TYPE);

		message.properties.put(EquifaxCreditActivator.CONSUMER_USER_SITE_ID,
				this.getProperty(EquifaxCreditActivator.CONSUMER_USER_SITE_ID));
		message.properties.put(EquifaxCreditActivator.CONSUMER_PASSWORD,
				this.getProperty(EquifaxCreditActivator.CONSUMER_PASSWORD));
		message.properties.put(EquifaxCreditActivator.CONSUMER_CUSTOMER_CODE,
				this.getProperty(EquifaxCreditActivator.CONSUMER_CUSTOMER_CODE));
		message.properties.put(EquifaxCreditActivator.CONSUMER_ENVIRONMENT_FLAG,
				this.getProperty(EquifaxCreditActivator.CONSUMER_ENVIRONMENT_FLAG));
		//DATA-1338
		message.properties.put(EquifaxCreditActivator.CONSUMER_RISK_BASED_PRICING,
				this.getProperty(EquifaxCreditActivator.CONSUMER_RISK_BASED_PRICING));
		//DATA-1602
		message.properties.put(EquifaxCreditActivator.CONSUMER_ADDTL_SCORING,
				this.getProperty(EquifaxCreditActivator.CONSUMER_ADDTL_SCORING));
		//DATA-1607
		message.properties.put(EquifaxCreditActivator.CONSUMER_PLACEHOLDER_NAME,
				this.getProperty(EquifaxCreditActivator.CONSUMER_PLACEHOLDER_NAME));
		message.properties.put(EquifaxCreditActivator.CONSUMER_APPEND_BUREAU_ID_TO_NAME,
				this.getProperty(EquifaxCreditActivator.CONSUMER_APPEND_BUREAU_ID_TO_NAME));
		//DATA-3384
		message.properties.put(EquifaxCreditActivator.SCORING_MODEL_1,
				this.getProperty(EquifaxCreditActivator.SCORING_MODEL_1));
		message.properties.put(EquifaxCreditActivator.SCORING_MODEL_2,
				this.getProperty(EquifaxCreditActivator.SCORING_MODEL_2));
		message.properties.put(EquifaxCreditActivator.SCORING_MODEL_3,
				this.getProperty(EquifaxCreditActivator.SCORING_MODEL_3));
				
		//DATA-2872
		message.properties.put(EquifaxCreditActivator.ADD_ON_BEACON_FLAG,
				this.getProperty(EquifaxCreditActivator.ADD_ON_BEACON_FLAG));
		message.properties.put(EquifaxCreditActivator.ADD_ON_FICO_FLAG,
				this.getProperty(EquifaxCreditActivator.ADD_ON_FICO_FLAG));
				message.properties.put(EquifaxCreditActivator.ADD_ON_FICO_VERBIAGE_FLAG,
				this.getProperty(EquifaxCreditActivator.ADD_ON_FICO_VERBIAGE_FLAG));
		message.properties.put(EquifaxCreditActivator.ADD_ON_EDAS_FLAG,
				this.getProperty(EquifaxCreditActivator.ADD_ON_EDAS_FLAG));
		message.properties.put(EquifaxCreditActivator.ADD_ON_ONLINE_DIRECTORY_FLAG,
				this.getProperty(EquifaxCreditActivator.ADD_ON_ONLINE_DIRECTORY_FLAG));
		message.properties.put(EquifaxCreditActivator.ADD_ON_CONSUMER_REF_FLAG,
				this.getProperty(EquifaxCreditActivator.ADD_ON_CONSUMER_REF_FLAG));
		message.properties.put(EquifaxCreditActivator.ADD_ON_ALERT_CONTACT_FLAG,
				this.getProperty(EquifaxCreditActivator.ADD_ON_ALERT_CONTACT_FLAG));
		message.properties.put(EquifaxCreditActivator.ADD_ON_DEFAULT_MODEL_FLAG,
				this.getProperty(EquifaxCreditActivator.ADD_ON_DEFAULT_MODEL_FLAG));
		message.properties.put(EquifaxCreditActivator.ADD_ON_RBP_BEACON_FLAG,
				this.getProperty(EquifaxCreditActivator.ADD_ON_RBP_BEACON_FLAG));
		message.properties.put(EquifaxCreditActivator.ADD_ON_RBP_FICO_FLAG,
				this.getProperty(EquifaxCreditActivator.ADD_ON_RBP_FICO_FLAG));
		message.properties.put(EquifaxCreditActivator.ADD_ON_RBP_ALL_FLAG,
				this.getProperty(EquifaxCreditActivator.ADD_ON_RBP_ALL_FLAG));
		message.properties.put(EquifaxCreditActivator.ADD_ON_24MONTH_PAYMENT_HISTORY,
				this.getProperty(EquifaxCreditActivator.ADD_ON_24MONTH_PAYMENT_HISTORY));
		message.properties.put(EquifaxCreditActivator.ADD_ON_SYNTHETIC_ID_ALERT,
				this.getProperty(EquifaxCreditActivator.ADD_ON_SYNTHETIC_ID_ALERT));
		message.properties.put(EquifaxCreditActivator.ADD_ON_EXPANDED_TRADE_A1160,
				this.getProperty(EquifaxCreditActivator.ADD_ON_EXPANDED_TRADE_A1160));
		message.properties.put(EquifaxCreditActivator.ADD_ON_EXPANDED_TRADE_DIMENSIONS,
				this.getProperty(EquifaxCreditActivator.ADD_ON_EXPANDED_TRADE_DIMENSIONS));
		message.properties.put(EquifaxCreditActivator.ADD_ON_EXPANDED_TRADE_HIGH_VALUE,
				this.getProperty(EquifaxCreditActivator.ADD_ON_EXPANDED_TRADE_HIGH_VALUE));
		message.properties.put(EquifaxCreditActivator.ADD_ON_EXPANDED_TRADE_TERMS,
				this.getProperty(EquifaxCreditActivator.ADD_ON_EXPANDED_TRADE_TERMS));
				
		if(reportType == REPORT_TYPE_SOFT){
			message.properties.put(EquifaxCreditActivator.CONSUMER_SOFT_MEMBER_NUMBER,
					this.getProperty(EquifaxCreditActivator.CONSUMER_SOFT_MEMBER_NUMBER));
			message.properties.put(EquifaxCreditActivator.CONSUMER_SOFT_SECURITY_CODE,
					this.getProperty(EquifaxCreditActivator.CONSUMER_SOFT_SECURITY_CODE));
		}
		
		if(reportType == REPORT_TYPE_HARD){
			message.properties.put(EquifaxCreditActivator.CONSUMER_HARD_SECURITY_CODE,
					this.getProperty(EquifaxCreditActivator.CONSUMER_HARD_SECURITY_CODE));
			message.properties.put(EquifaxCreditActivator.CONSUMER_HARD_MEMBER_NUMBER,
					this.getProperty(EquifaxCreditActivator.CONSUMER_HARD_MEMBER_NUMBER));
		}
	}

	private void mergeBusinessPropertiesToMessage(nFUSE.AMiddlewareMessage message){
		message.properties.put(EquifaxCreditActivator.BUSINESS_USER_SITE_ID,
				this.getProperty(EquifaxCreditActivator.BUSINESS_USER_SITE_ID));
		message.properties.put(EquifaxCreditActivator.BUSINESS_PASSWORD,
				this.getProperty(EquifaxCreditActivator.BUSINESS_PASSWORD));
		message.properties.put(EquifaxCreditActivator.BUSINESS_CUSTOMER_CODE,
				this.getProperty(EquifaxCreditActivator.BUSINESS_CUSTOMER_CODE));
		message.properties.put(EquifaxCreditActivator.BUSINESS_MEMBER_NUMBER,
				this.getProperty(EquifaxCreditActivator.BUSINESS_MEMBER_NUMBER));
		message.properties.put(EquifaxCreditActivator.BUSINESS_SECURITY_CODE,
				this.getProperty(EquifaxCreditActivator.BUSINESS_SECURITY_CODE));
		message.properties.put(EquifaxCreditActivator.BUSINESS_SERVICE_CODE,
				this.getProperty(EquifaxCreditActivator.BUSINESS_SERVICE_CODE));
		message.properties.put(EquifaxCreditActivator.BUSINESS_PDF_TRANSFORMER_SC,
                this.getProperty(EquifaxCreditActivator.BUSINESS_PDF_TRANSFORMER_SC));
		message.properties.put(EquifaxCreditActivator.BUSINESS_ENVIRONMENT_FLAG,
				this.getProperty(EquifaxCreditActivator.BUSINESS_ENVIRONMENT_FLAG));
		//DATA-1607
		message.properties.put(EquifaxCreditActivator.COMMERCIAL_PLACEHOLDER_NAME,
				this.getProperty(EquifaxCreditActivator.COMMERCIAL_PLACEHOLDER_NAME));
		message.properties.put(EquifaxCreditActivator.COMMERCIAL_APPEND_BUREAU_ID_TO_NAME,
				this.getProperty(EquifaxCreditActivator.COMMERCIAL_APPEND_BUREAU_ID_TO_NAME));
				
		//DATA-2648
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_REPORT,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_REPORT));	
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_REPORT_NTH,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_REPORT_NTH));

		message.properties.put(EquifaxCreditActivator.PRODUCT_PORTFOLIO_DATA_VERIFICATION,this.getProperty(EquifaxCreditActivator.PRODUCT_PORTFOLIO_DATA_VERIFICATION));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DATA_SELECT_PR,this.getProperty(EquifaxCreditActivator.PRODUCT_DATA_SELECT_PR));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DATA_SELECT_F,this.getProperty(EquifaxCreditActivator.PRODUCT_DATA_SELECT_F));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DATA_SELECT_CT,this.getProperty(EquifaxCreditActivator.PRODUCT_DATA_SELECT_CT));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DATA_SELECT_AH,this.getProperty(EquifaxCreditActivator.PRODUCT_DATA_SELECT_AH));

		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_IDENTITY,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_IDENTITY));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_IDENTITY_RP,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_IDENTITY_RP));
		
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY_RS,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY_RS));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY2,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY2));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY_RP,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY_RP));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY_RP2,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY_RP2));
		
		message.properties.put(EquifaxCreditActivator.PRODUCT_EXPANDED_MATCH,this.getProperty(EquifaxCreditActivator.PRODUCT_EXPANDED_MATCH));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_PRINCIPAL_REPORT,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_PRINCIPAL_REPORT));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BPR_STANDALONE,this.getProperty(EquifaxCreditActivator.PRODUCT_BPR_STANDALONE));
		message.properties.put(EquifaxCreditActivator.PRODUCT_OFAC_COMMERCIAL,this.getProperty(EquifaxCreditActivator.PRODUCT_OFAC_COMMERCIAL));
		message.properties.put(EquifaxCreditActivator.PRODUCT_OFAC_PRINCIPAL,this.getProperty(EquifaxCreditActivator.PRODUCT_OFAC_PRINCIPAL));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_FRAUD_ADVISOR,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_FRAUD_ADVISOR));
		
		message.properties.put(EquifaxCreditActivator.PRODUCT_SBC_RISKSCORE_SUPPLIERS,this.getProperty(EquifaxCreditActivator.PRODUCT_SBC_RISKSCORE_SUPPLIERS));
		message.properties.put(EquifaxCreditActivator.PRODUCT_SBC_RISKSCORE_FS,this.getProperty(EquifaxCreditActivator.PRODUCT_SBC_RISKSCORE_FS));
		message.properties.put(EquifaxCreditActivator.PRODUCT_SBC_RISKSCORE_FSB,this.getProperty(EquifaxCreditActivator.PRODUCT_SBC_RISKSCORE_FSB));
		message.properties.put(EquifaxCreditActivator.PRODUCT_SBC_RISKSCORE_S,this.getProperty(EquifaxCreditActivator.PRODUCT_SBC_RISKSCORE_S));
		
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_SCORE,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_SCORE));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_RISK,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_RISK));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_RISKSCORE,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_RISKSCORE));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_RISKRATING,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_RISKRATING));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_RISKLEVEL,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_RISKLEVEL));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_RISK,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_RISK));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_RISKSCORE,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_RISKSCORE));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_RISKCLASS,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_RISKCLASS));
		
		message.properties.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_FINANCIAL_SCORE,this.getProperty(EquifaxCreditActivator.PRODUCT_DELINQUENCY_FINANCIAL_SCORE));
		message.properties.put(EquifaxCreditActivator.PRODUCT_BUSINESS_DELINQUENCY_SCORE,this.getProperty(EquifaxCreditActivator.PRODUCT_BUSINESS_DELINQUENCY_SCORE));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_RISK_CLASS,this.getProperty(EquifaxCreditActivator.PRODUCT_DELINQUENCY_RISK_CLASS));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_RISK_CLASS_F,this.getProperty(EquifaxCreditActivator.PRODUCT_DELINQUENCY_RISK_CLASS_F));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_BLENDED_F,this.getProperty(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_BLENDED_F));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_BLENDED,this.getProperty(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_BLENDED));
		
		message.properties.put(EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_CARD,this.getProperty(EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_CARD));
		message.properties.put(EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_LOAN,this.getProperty(EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_LOAN));
		message.properties.put(EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_CONSERVATIVE,this.getProperty(EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_CONSERVATIVE));
		message.properties.put(EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_MODERATE,this.getProperty(EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_MODERATE));
		message.properties.put(EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_AGGRESSIVE,this.getProperty(EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_AGGRESSIVE));
		message.properties.put(EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_2,this.getProperty(EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_2));
	
		message.properties.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE,this.getProperty(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_M,this.getProperty(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_M));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_BS,this.getProperty(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_BS));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_T,this.getProperty(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_T));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_RL,this.getProperty(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_RL));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_COMMUNICATIONS,this.getProperty(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_COMMUNICATIONS));
		message.properties.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_PS,this.getProperty(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_PS));

		message.properties.put(EquifaxCreditActivator.PRODUCT_ACCOUNT_MANAGEMENT_SCORE,this.getProperty(EquifaxCreditActivator.PRODUCT_ACCOUNT_MANAGEMENT_SCORE));
		message.properties.put(EquifaxCreditActivator.PRODUCT_FINANCIAL_HEALTH_INDEX,this.getProperty(EquifaxCreditActivator.PRODUCT_FINANCIAL_HEALTH_INDEX));
		message.properties.put(EquifaxCreditActivator.PRODUCT_PAYMENT_INDEX_SERVICES,this.getProperty(EquifaxCreditActivator.PRODUCT_PAYMENT_INDEX_SERVICES));
		message.properties.put(EquifaxCreditActivator.PRODUCT_PAYMENT_INDEX,this.getProperty(EquifaxCreditActivator.PRODUCT_PAYMENT_INDEX));
		
		message.properties.put(EquifaxCreditActivator.PRODUCT_COMMERCIAL_SCORE_MARKETING,this.getProperty(EquifaxCreditActivator.PRODUCT_COMMERCIAL_SCORE_MARKETING));
	}
    
    /**
     * Return true when more than 5 Product flags are set in message
     **/
    @TestVisible
    private void validateProductLimit(nFUSE.AMiddlewareMessage message){
    	Integer productCount = 0;
    	String productName;
    	Map<String,Object> messageProperties = new Map<String,Object>();
    	messageProperties = message.properties;
    	
    	for(String key: messageProperties.keySet()){
    		if(key.contains('Product:')){
    			productName = String.valueOf(messageProperties.get(key));
    			if(productName.capitalize() == 'Y'){
    				productCount++;	
    			}
    		}
    	}
    	
    	if(productCount>5){
    		throw new XEquifaxMessageGenerationException(X_PRODUCT_LIMIT_EXCEEDED);
    	}
    }
    
    @TestVisible 
    private String getProperty(String propertyKey) {
        if(configurationMap == null || configurationMap.isEmpty()) return null;
        if(!configurationMap.containsKey(propertyKey)) {
            throw new XEquifaxMessageGenerationException(
                    X_MISSING_REQUIRED_PROPERTY + ': ' + propertyKey
            );
        }
        return configurationMap.get(propertyKey);
    }
    
	@TestVisible private static String REPORT_TYPE = 'ReportType';
	@TestVisible private static String REPORT_TYPE_HARD = 'Hard';
	@TestVisible private static String REPORT_TYPE_SOFT = 'Soft';
	@TestVisible private static String REPORT_TYPE_BUSINESS = 'Business';
	@TestVisible private static String CUSTOMER_NUMBER_DELIMITER = ',';
}