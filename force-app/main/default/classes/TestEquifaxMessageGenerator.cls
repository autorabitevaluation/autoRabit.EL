@isTest
private class TestEquifaxMessageGenerator {

	@TestSetup
	static void setup() {
		new nFUSE.DataInstaller().onInstall(null);
	}

	/**
	 * Test generating Equifax business message
	 **/
	@isTest
	private static void TestGenerateMessage_business(){
		EquifaxCreditActivator credActivator = new EquifaxCreditActivator();
		credActivator.onActivate();
		
		nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='cccc',nFORCE__Category_Name__c='Equifax_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = 'Business Member Number';
        property1.nFORCE__Value__c = '12348765AB';
        insert property1;
		
		//build message 
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock().putProperty(EquifaxMessageGenerator.REPORT_TYPE, EquifaxMessageGenerator.REPORT_TYPE_BUSINESS);
		
		//Init user to establish user context & populate userInfo
		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		
		User U = new user();
		U.Username='standarduser' + DateTime.now().getTime() + '@ncino.com';
		U.FirstName='Test';
		U.LastName='User';
		U.Email='useremail@ncino.com';
		U.Alias = 'Tcode';
		U.TimeZoneSidKey = 'GMT';
		U.LocaleSidKey = 'en_US';
		U.EmailEncodingKey = 'UTF-8';
		U.ProfileID = profileId.Id;
		U.LanguageLocaleKey = 'en_US';
		
		//Hydrate configurationMap
		EquifaxCreditAppFacade appfacade = new EquifaxCreditAppFacade();
		
		System.RunAs(U){
			EquifaxMessageGenerator msgGenerator = new EquifaxMessageGenerator(appfacade.retrieveKeyValueMap());
			EquifaxMessageGenerator.sfdcURL = 'https://customDomain--nfuse.na78.visual.force.com';
			nFUSE.AMiddlewareMessage newMessage = msgGenerator.GenerateMessage(blankMessage);
			//real value => check for value specific to EquifaxMessageGenerator.GenerateMessage
			System.assertEquals('UAT', newMessage.properties.get(EquifaxCreditActivator.BUSINESS_ENVIRONMENT_FLAG));
			System.assertEquals('Test', newMessage.properties.get('REQUESTEDBY_FIRSTNAME'));
			System.assertEquals('https://customDomain--c.na78.visual.force.com', newMessage.properties.get('CUSTOMDOMAIN'));
		}
	}

	/**
	 * Test generating Equifax consumer message
	 **/
	@isTest
	private static void TestGenerateMessage_consumer(){
		EquifaxCreditActivator credActivator = new EquifaxCreditActivator();
		credActivator.onActivate();
		
		nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='cccc',nFORCE__Category_Name__c='Equifax_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = 'Consumer Soft Member Number';
        property1.nFORCE__Value__c = '12348765AB';
        insert property1;
		
		//build message 
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock().putProperty(EquifaxMessageGenerator.REPORT_TYPE, EquifaxMessageGenerator.REPORT_TYPE_SOFT);
		
		//Init user to establish user context & populate userInfo
		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		
		User U = new user();
		U.Username='standarduser' + DateTime.now().getTime() + '@ncino.com';
		U.FirstName='Test';
		U.LastName='User';
		U.Email='useremail@ncino.com';
		U.Alias = 'Tcode';
		U.TimeZoneSidKey = 'GMT';
		U.LocaleSidKey = 'en_US';
		U.EmailEncodingKey = 'UTF-8';
		U.ProfileID = profileId.Id;
		U.LanguageLocaleKey = 'en_US';
		
		//Hydrate configurationMap
		EquifaxCreditAppFacade appfacade = new EquifaxCreditAppFacade();
		
		System.RunAs(U){
			nFUSE.AMiddlewareMessage newMessage = new EquifaxMessageGenerator(appfacade.retrieveKeyValueMap()).GenerateMessage(blankMessage);
			//real value => check for value specific to EquifaxMessageGenerator.GenerateMessage
			System.assertEquals('UAT', newMessage.properties.get(EquifaxCreditActivator.CONSUMER_ENVIRONMENT_FLAG));
			System.assertEquals('Test', newMessage.properties.get('REQUESTEDBY_FIRSTNAME'));
		}
	}
		
	/**
	 * Test product limit validation
	 **/
	@isTest
	private static void TestProductLimitValidation(){
		EquifaxCreditActivator credActivator = new EquifaxCreditActivator();
		credActivator.onActivate();
		
		nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='cccc',nFORCE__Category_Name__c='Equifax_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = 'Business Member Number';
        property1.nFORCE__Value__c = '12348765AB';
        insert property1;
		
		Map<String, String> configurationMap = new Map<String, String>();
		
		EquifaxCreditAppFacade appFacade = new EquifaxCreditAppFacade();
		configurationMap = appFacade.retrieveKeyValueMap();
		
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock().putProperty(EquifaxMessageGenerator.REPORT_TYPE, EquifaxMessageGenerator.REPORT_TYPE_BUSINESS);
		
		configurationMap.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE,'Y');
		configurationMap.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_BS,'Y');
		configurationMap.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_M,'Y');
		configurationMap.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_RL,'Y');
		configurationMap.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_T,'Y');
		configurationMap.put(EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_COMMUNICATIONS,'Y');

		try{
			nFUSE.AMiddlewareMessage newMessage = new EquifaxMessageGenerator(configurationMap).GenerateMessage(blankMessage);
			System.assertEquals(true,false);
		}
		catch(Exception e){
			System.assertEquals(EquifaxMessageGenerator.X_PRODUCT_LIMIT_EXCEEDED,e.getMessage());
		}
	}
	
	@isTest
	private static void TestGenerateMessage_forceUserException(){
		EquifaxCreditActivator credActivator = new EquifaxCreditActivator();
		credActivator.onActivate();
		
		//build message 
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock();
		String externalId = new nFORCE.GuidGenerator().randomUUID();
	
		//Hydrate configurationMap
		EquifaxCreditAppFacade appfacade = new EquifaxCreditAppFacade();
		
		try{
			EquifaxMessageGenerator.forceUserError = true;
			nFUSE.AMiddlewareMessage newMessage = new EquifaxMessageGenerator(appfacade.retrieveKeyValueMap()).GenerateMessage(blankMessage);
			System.assertEquals(true,false);
		}
		catch(EquifaxMessageGenerator.XEquifaxMessageGenerationException e){
			System.assertEquals(true,true);
		}
	}
	
	/**
	 * Test generating message with invalid report type
	 **/
	@isTest
	private static void TestGenerateMessage_invalidReportType(){
		Map<String, String> configurationMap = new Map<String, String>();
		
		configurationMap.put('MEDIUM', EquifaxMessageGenerator.REPORT_TYPE);
		
		EquifaxMessageGenerator msgGenerator = new EquifaxMessageGenerator(configurationMap);
		
		//build message 
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock().putProperty(EquifaxMessageGenerator.REPORT_TYPE, 'MEDIUM');
		
		//real value => check for value specific to EquifaxMessageGenerator.GenerateMessage
		try{
			msgGenerator.GenerateMessage(blankMessage);
			System.assert(false, 'Expected Exception NOT thrown');	
		}
		
		catch(EquifaxMessageGenerator.XEquifaxMessageGenerationException ex){
			System.assert(ex.getMessage().startsWith(EquifaxMessageGenerator.X_MISSING_UNKNOWN_REPORT_TYPE));
		}
	}
	
	/**
	 * Test for an invalid value from EquifaxMessageGenerator.getProperty();
	 **/
	@isTest 
	private static void testGetPropertyThrow(){
		Map<String, String> configurationMap = new Map<String, String>();
		configurationMap.put('@U2', 'CONSUMER_HARD_SECURITY_CODE');
		EquifaxMessageGenerator msgGenerator = new EquifaxMessageGenerator(configurationMap);
		try{
			msgGenerator.getProperty('exception');
			System.assert(false, 'Expected Exception NOT thrown');	
		}
		
		catch(EquifaxMessageGenerator.XEquifaxMessageGenerationException ex){
			System.assert(ex.getMessage().startsWith(EquifaxMessageGenerator.X_MISSING_REQUIRED_PROPERTY));
		}
	}
	
	/**
	 * Test for handling of null & empty configuration map
	 **/
	@isTest 
	private static void testGetPropertyEmptyConfig(){
		
		//Testing for null configuration map
		Map<String, String> configurationMap;
		String test1 = new EquifaxMessageGenerator(configurationMap).getProperty('My Test String');
		System.assertEquals(null, test1);
		
		//Testing for empty configuration map
		configurationMap = new Map<String, String>();
		String test2 = new EquifaxMessageGenerator(configurationMap).getProperty('My Test String');
		System.assertEquals(null, test2);
	}
	
	private class MiddlewareMessageMock extends nFUSE.AMiddlewareMessage {
		public MiddlewareMessageMock(){}

		public MiddlewareMessageMock putProperty(String key, String value){
			this.properties.put(key, value);
			return this;
		}
	}
	
	@isTest
	private static void testGetUserInfo(){
		Map<String, String> configurationMap = new Map<String, String>();
		EquifaxMessageGenerator msgGenerator = new EquifaxMessageGenerator(configurationMap);
		
		//Init user to establish user context & populate userInfo
		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

		User U = new user();
		U.Username='standarduser' + DateTime.now().getTime() + '@ncino.com';
		U.FirstName='Test';
		U.LastName='User';
		U.Email='useremail@ncino.com';
		U.Alias = 'Tcode';
		U.TimeZoneSidKey = 'GMT';
		U.LocaleSidKey = 'en_US';
		U.EmailEncodingKey = 'UTF-8';
		U.ProfileID = profileId.Id;
		U.LanguageLocaleKey = 'en_US';

		System.RunAs(U){
			Map<String,String> userInfo = msgGenerator.GetUserInfo();
			
			System.assertEquals(userInfo.get('REQUESTEDBY_ID'),U.Id);
			System.assertEquals(userInfo.get('REQUESTEDBY_EMAIL'),U.Email);
			System.assertEquals(userInfo.get('REQUESTEDBY_FIRSTNAME'),U.FirstName);
			System.assertEquals(userInfo.get('REQUESTEDBY_LASTNAME'),U.LastName);
			System.assertEquals(userInfo.get('REQUESTEDBY_USERNAME'), U.Username);
		}
	}

	private static final String Equifax_CATEGORY = 'Equifax_CreditConfiguration';
}