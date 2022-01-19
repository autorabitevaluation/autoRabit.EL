@isTest
private class TestFisMessageGenerator {

	@isTest
	private static void TestGenerateMessage(){
		FisChexCreditActivator credActivator = new FisChexCreditActivator();
		credActivator.onActivate();
		
		//build message 
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock();
		String externalId = new nFORCE.GuidGenerator().randomUUID();
		
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
		FisChexCreditAppFacade appfacade = new FisChexCreditAppFacade();
		
		//Run in context of sys admin to GetUserInfo()
		System.RunAs(U){
		nFUSE.AMiddlewareMessage newMessage = new FisMessageGenerator(appfacade.retrieveKeyValueMap()).GenerateMessage(blankMessage);
		//real value => check for value specific to FisMessageGenerator.GenerateMessage
		System.assertEquals('Test', newMessage.properties.get('REQUESTEDBY_FIRSTNAME'));
		}
	}

	@isTest
	private static void TestGenerateMessage_forceUserException(){
		FisChexCreditActivator credActivator = new FisChexCreditActivator();
		credActivator.onActivate();
		
		//build message 
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock();
		String externalId = new nFORCE.GuidGenerator().randomUUID();
	
		//Hydrate configurationMap
		FisChexCreditAppFacade appfacade = new FisChexCreditAppFacade();
		
		try{
			FisMessageGenerator.forceUserError = true;
			nFUSE.AMiddlewareMessage newMessage = new FisMessageGenerator(appfacade.retrieveKeyValueMap()).GenerateMessage(blankMessage);
			System.assertEquals(true,false);
		}
		catch(FisMessageGenerator.XFisChexMessageGenerationException e){
			System.assertEquals(true,true);
		}
	}
	
	/**
	 * Test for an invalid value from FisMessageGenerator.getProperty();
	 **/
	@isTest 
	private static void testGetPropertyThrow(){
		Map<String, String> configurationMap = new Map<String, String>();
		configurationMap.put('N003', 'QUALIFILE_VERSION_NUMBER');
		FisMessageGenerator msgGenerator = new FisMessageGenerator(configurationMap);
		try{
			msgGenerator.getProperty('exception');
			System.assert(false, 'Expected Exception NOT thrown');	
		}
		
		catch(FisMessageGenerator.XFisChexMessageGenerationException ex){
			System.assert(ex.getMessage().startsWith(FisMessageGenerator.X_MISSING_REQUIRED_PROPERTY));
		}
	}
	
	/**
	 * Test for handling of null & empty configuration map
	 **/
	@isTest 
	private static void testGetPropertyEmptyConfig(){
		
		//Testing for null configuration map
		Map<String, String> configurationMap;
		String test1 = new FisMessageGenerator(configurationMap).getProperty('My Test String');
		System.assertEquals(null, test1);
		
		//Testing for empty configuration map
		configurationMap = new Map<String, String>();
		String test2 = new FisMessageGenerator(configurationMap).getProperty('My Test String');
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
		FisMessageGenerator msgGenerator = new FisMessageGenerator(configurationMap);
		
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

	@isTest
	private static void testGetFISIdentifier(){
		FisChexCreditActivator credActivator = new FisChexCreditActivator();
		credActivator.onActivate();

		//build message
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock();
		String externalId = new nFORCE.GuidGenerator().randomUUID();

		Map<String, String> configurationMap = new Map<String, String>();
		//copying nFUSE's output
		blankMessage.putProperty('record', '[{"saved":false,"recordId":"0031I00000GzkcdQAB","name":"JANET RILEY","isRelationshipPointer":false,"apexType":"nFUSE.Contact_v1_0","properties":{"Name":{"value":"JANET RILEY","type":"STRING","name":"Name","label":"Full Name","isRequired":false},"ChexSystems_Qualifile_Strategy__c":{"value":"CK001","type":"STRING","name":"ChexSystems_Qualifile_Strategy__c","label":"FIS Qualifile Strategy","isRequired":false},"ChexSystems_Identifier__c":{"value":"12345678","type":"STRING","name":"ChexSystems_Identifier__c","label":"FIS Identifier","isRequired":false},"LLC_BI__SS__c":{"value":"666990422","type":"ENCRYPTEDSTRING","name":"LLC_BI__SS__c","label":"SS#","isRequired":false},"MailingStreet":{"value":"204 E AMERICAN BLVD","type":"TEXTAREA","name":"MailingStreet","label":"Mailing Street","isRequired":false},"MailingCity":{"value":"BLOOMINGTON","type":"STRING","name":"MailingCity","label":"Mailing City","isRequired":false},"MailingState":{"value":"MN","type":"STRING","name":"MailingState","label":"Mailing State/Province","isRequired":false},"MailingPostalCode":{"value":"55425","type":"STRING","name":"MailingPostalCode","label":"Mailing Zip/Postal Code","isRequired":false},"MailingCountry":{"value":null,"type":"STRING","name":"MailingCountry","label":"Mailing Country","isRequired":false},"AccountId":{"value":"0011I00000Nh3P7QAJ","type":"REFERENCE","name":"AccountId","label":"Account ID","isRequired":false},"Birthdate":{"value":null,"type":"DATE","name":"Birthdate","label":"Birthdate","isRequired":false},"LastName":{"value":"RILEY","type":"STRING","name":"LastName","label":"Last Name","isRequired":false},"FirstName":{"value":"JANET","type":"STRING","name":"FirstName","label":"First Name","isRequired":false},"Id":{"value":"0031I00000GzkcdQAB","type":"ID","name":"Id","label":"Contact ID","isRequired":false}}}]');
		FisMessageGenerator msgGenerator = new FisMessageGenerator(configurationMap);

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

		FisChexCreditAppFacade appfacade = new FisChexCreditAppFacade();

		System.RunAs(U){
			nFUSE.AMiddlewareMessage newMessage = new FisMessageGenerator(appfacade.retrieveKeyValueMap()).GenerateMessage(blankMessage);
			//real value => check for value specific to FisMessageGenerator.GenerateMessage

			system.assertEquals('12345678', newMessage.properties.get('CHEXSYSTEMS_IDENTIFIER'));
		}
	}
	@isTest
	private static void testGetFISIdentifierNull(){
		FisChexCreditActivator credActivator = new FisChexCreditActivator();
		credActivator.onActivate();

		//build message
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock();
		String externalId = new nFORCE.GuidGenerator().randomUUID();

		Map<String, String> configurationMap = new Map<String, String>();
		//copying nFUSE's output
		blankMessage.putProperty('record', '[{"saved":false,"recordId":"0031I000009lrymQAA","name":"Warren Curtis","isRelationshipPointer":false,"apexType":"nFUSE.Contact_v1_0","properties":{"Name":{"value":"Warren Curtis","type":"STRING","name":"Name","label":"Full Name","isRequired":false},"ChexSystems_Identifier__c":{"value":null,"type":"DOUBLE","name":"ChexSystems_Identifier__c","label":"FIS Identifier","isRequired":false},"LLC_BI__SS__c":{"value":"666-99-0040","type":"ENCRYPTEDSTRING","name":"LLC_BI__SS__c","label":"SS#","isRequired":false},"MailingStreet":{"value":"3843 FRANKFORD RD","type":"TEXTAREA","name":"MailingStreet","label":"Mailing Street","isRequired":false},"MailingCity":{"value":"DALLAS","type":"STRING","name":"MailingCity","label":"Mailing City","isRequired":false},"MailingState":{"value":"TX","type":"STRING","name":"MailingState","label":"Mailing State/Province","isRequired":false},"MailingPostalCode":{"value":"75287","type":"STRING","name":"MailingPostalCode","label":"Mailing Zip/Postal Code","isRequired":false},"MailingCountry":{"value":"US","type":"STRING","name":"MailingCountry","label":"Mailing Country","isRequired":false},"AccountId":{"value":"0011I00000FEY7mQAH","type":"REFERENCE","name":"AccountId","label":"Account ID","isRequired":false},"Birthdate":{"value":null,"type":"DATE","name":"Birthdate","label":"Birthdate","isRequired":false},"LastName":{"value":"Curtis","type":"STRING","name":"LastName","label":"Last Name","isRequired":false},"FirstName":{"value":"Warren","type":"STRING","name":"FirstName","label":"First Name","isRequired":false},"Id":{"value":"0031I000009lrymQAA","type":"ID","name":"Id","label":"Contact ID","isRequired":false}}}]');
		FisMessageGenerator msgGenerator = new FisMessageGenerator(configurationMap);

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

		FisChexCreditAppFacade appfacade = new FisChexCreditAppFacade();

		System.RunAs(U){
			try{
				nFUSE.AMiddlewareMessage newMessage = new FisMessageGenerator(appfacade.retrieveKeyValueMap()).GenerateMessage(blankMessage);
			}
			catch (Exception e){
				system.assertEquals(e.getMessage(), 'ChexSystems_Identifier__c' + ' ' + FisMessageGenerator.X_FIELD_EMPTY_BRANCH);
			}
		}
	}
	@isTest
	private static void testGetFISIdentifierNonNumeric(){
		FisChexCreditActivator credActivator = new FisChexCreditActivator();
		credActivator.onActivate();

		//build message
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock();
		String externalId = new nFORCE.GuidGenerator().randomUUID();

		Map<String, String> configurationMap = new Map<String, String>();
		//copying nFUSE's output
		blankMessage.putProperty('record', '[{"saved":false,"recordId":"0031I00000GzkcdQAB","name":"JANET RILEY","isRelationshipPointer":false,"apexType":"nFUSE.Contact_v1_0","properties":{"Name":{"value":"JANET RILEY","type":"STRING","name":"Name","label":"Full Name","isRequired":false},"ChexSystems_Qualifile_Strategy__c":{"value":null,"type":"STRING","name":"ChexSystems_Qualifile_Strategy__c","label":"FIS Qualifile Strategy","isRequired":false},"ChexSystems_Identifier__c":{"value":"cheese","type":"STRING","name":"ChexSystems_Identifier__c","label":"FIS Identifier","isRequired":false},"LLC_BI__SS__c":{"value":"666990422","type":"ENCRYPTEDSTRING","name":"LLC_BI__SS__c","label":"SS#","isRequired":false},"MailingStreet":{"value":"204 E AMERICAN BLVD","type":"TEXTAREA","name":"MailingStreet","label":"Mailing Street","isRequired":false},"MailingCity":{"value":"BLOOMINGTON","type":"STRING","name":"MailingCity","label":"Mailing City","isRequired":false},"MailingState":{"value":"MN","type":"STRING","name":"MailingState","label":"Mailing State/Province","isRequired":false},"MailingPostalCode":{"value":"55425","type":"STRING","name":"MailingPostalCode","label":"Mailing Zip/Postal Code","isRequired":false},"MailingCountry":{"value":null,"type":"STRING","name":"MailingCountry","label":"Mailing Country","isRequired":false},"AccountId":{"value":"0011I00000Nh3P7QAJ","type":"REFERENCE","name":"AccountId","label":"Account ID","isRequired":false},"Birthdate":{"value":null,"type":"DATE","name":"Birthdate","label":"Birthdate","isRequired":false},"LastName":{"value":"RILEY","type":"STRING","name":"LastName","label":"Last Name","isRequired":false},"FirstName":{"value":"JANET","type":"STRING","name":"FirstName","label":"First Name","isRequired":false},"Id":{"value":"0031I00000GzkcdQAB","type":"ID","name":"Id","label":"Contact ID","isRequired":false}}}]');
		FisMessageGenerator msgGenerator = new FisMessageGenerator(configurationMap);

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

		FisChexCreditAppFacade appfacade = new FisChexCreditAppFacade();

		System.RunAs(U){
			try{
				nFUSE.AMiddlewareMessage newMessage = new FisMessageGenerator(appfacade.retrieveKeyValueMap()).GenerateMessage(blankMessage);
			}
			catch (Exception e){
				system.assertEquals(e.getMessage(), 'ChexSystems_Identifier__c' + ' ' + FisMessageGenerator.X_NOT_NUMERIC);
			}
		}
	}
	@isTest
	private static void testGetFISIdentifierNotInFieldset(){
		FisChexCreditActivator credActivator = new FisChexCreditActivator();
		credActivator.onActivate();

		//build message
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock();
		String externalId = new nFORCE.GuidGenerator().randomUUID();

		Map<String, String> configurationMap = new Map<String, String>();
		//copying nFUSE's output
		blankMessage.putProperty('record', '[{"saved":false,"recordId":"0031I000009lrymQAA","name":"Warren Curtis","isRelationshipPointer":false,"apexType":"nFUSE.Contact_v1_0","properties":{"Name":{"value":"Warren Curtis","type":"STRING","name":"Name","label":"Full Name","isRequired":false},"LLC_BI__SS__c":{"value":"666-99-0040","type":"ENCRYPTEDSTRING","name":"LLC_BI__SS__c","label":"SS#","isRequired":false},"MailingStreet":{"value":"3843 FRANKFORD RD","type":"TEXTAREA","name":"MailingStreet","label":"Mailing Street","isRequired":false},"MailingCity":{"value":"DALLAS","type":"STRING","name":"MailingCity","label":"Mailing City","isRequired":false},"MailingState":{"value":"TX","type":"STRING","name":"MailingState","label":"Mailing State/Province","isRequired":false},"MailingPostalCode":{"value":"75287","type":"STRING","name":"MailingPostalCode","label":"Mailing Zip/Postal Code","isRequired":false},"MailingCountry":{"value":"US","type":"STRING","name":"MailingCountry","label":"Mailing Country","isRequired":false},"AccountId":{"value":"0011I00000FEY7mQAH","type":"REFERENCE","name":"AccountId","label":"Account ID","isRequired":false},"Birthdate":{"value":null,"type":"DATE","name":"Birthdate","label":"Birthdate","isRequired":false},"LastName":{"value":"Curtis","type":"STRING","name":"LastName","label":"Last Name","isRequired":false},"FirstName":{"value":"Warren","type":"STRING","name":"FirstName","label":"First Name","isRequired":false},"Id":{"value":"0031I000009lrymQAA","type":"ID","name":"Id","label":"Contact ID","isRequired":false}}}]');
		FisMessageGenerator msgGenerator = new FisMessageGenerator(configurationMap);

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

		FisChexCreditAppFacade appfacade = new FisChexCreditAppFacade();

		System.RunAs(U){
			try{
				nFUSE.AMiddlewareMessage newMessage = new FisMessageGenerator(appfacade.retrieveKeyValueMap()).GenerateMessage(blankMessage);
			}
			catch (Exception e){
				system.assertEquals(e.getMessage(), 'ChexSystems_Identifier__c' + ' ' + FisMessageGenerator.X_MISSING_FROM_FIELDSET);
			}
		}
	}
	@isTest
	private static void testGetFISQualifileStrategy(){
		FisChexCreditActivator credActivator = new FisChexCreditActivator();
		credActivator.onActivate();

		//build message
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock();
		String externalId = new nFORCE.GuidGenerator().randomUUID();

		Map<String, String> configurationMap = new Map<String, String>();
		//copying nFUSE's output
		blankMessage.putProperty('record', '[{"saved":false,"recordId":"0031I00000GzkcdQAB","name":"JANET RILEY","isRelationshipPointer":false,"apexType":"nFUSE.Contact_v1_0","properties":{"Name":{"value":"JANET RILEY","type":"STRING","name":"Name","label":"Full Name","isRequired":false},"ChexSystems_Qualifile_Strategy__c":{"value":"CK001","type":"STRING","name":"ChexSystems_Qualifile_Strategy__c","label":"FIS Qualifile Strategy","isRequired":false},"ChexSystems_Identifier__c":{"value":"12345678","type":"STRING","name":"ChexSystems_Identifier__c","label":"FIS Identifier","isRequired":false},"LLC_BI__SS__c":{"value":"666990422","type":"ENCRYPTEDSTRING","name":"LLC_BI__SS__c","label":"SS#","isRequired":false},"MailingStreet":{"value":"204 E AMERICAN BLVD","type":"TEXTAREA","name":"MailingStreet","label":"Mailing Street","isRequired":false},"MailingCity":{"value":"BLOOMINGTON","type":"STRING","name":"MailingCity","label":"Mailing City","isRequired":false},"MailingState":{"value":"MN","type":"STRING","name":"MailingState","label":"Mailing State/Province","isRequired":false},"MailingPostalCode":{"value":"55425","type":"STRING","name":"MailingPostalCode","label":"Mailing Zip/Postal Code","isRequired":false},"MailingCountry":{"value":null,"type":"STRING","name":"MailingCountry","label":"Mailing Country","isRequired":false},"AccountId":{"value":"0011I00000Nh3P7QAJ","type":"REFERENCE","name":"AccountId","label":"Account ID","isRequired":false},"Birthdate":{"value":null,"type":"DATE","name":"Birthdate","label":"Birthdate","isRequired":false},"LastName":{"value":"RILEY","type":"STRING","name":"LastName","label":"Last Name","isRequired":false},"FirstName":{"value":"JANET","type":"STRING","name":"FirstName","label":"First Name","isRequired":false},"Id":{"value":"0031I00000GzkcdQAB","type":"ID","name":"Id","label":"Contact ID","isRequired":false}}}]');
		FisMessageGenerator msgGenerator = new FisMessageGenerator(configurationMap);

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

		FisChexCreditAppFacade appfacade = new FisChexCreditAppFacade();

		System.RunAs(U){
			nFUSE.AMiddlewareMessage newMessage = new FisMessageGenerator(appfacade.retrieveKeyValueMap()).GenerateMessage(blankMessage);
			//real value => check for value specific to FisMessageGenerator.GenerateMessage

			system.assertEquals('CK001', newMessage.properties.get('CHEXSYSTEMS_QUALIFILE_STRATEGY'));
		}
	}
	@isTest
	private static void testGetQualifileStrategyNull(){
		FisChexCreditActivator credActivator = new FisChexCreditActivator();
		credActivator.onActivate();

		//build message
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock();
		String externalId = new nFORCE.GuidGenerator().randomUUID();

		Map<String, String> configurationMap = new Map<String, String>();
		//copying nFUSE's output
		blankMessage.putProperty('record', '[{"saved":false,"recordId":"0031I00000GzkcdQAB","name":"JANET RILEY","isRelationshipPointer":false,"apexType":"nFUSE.Contact_v1_0","properties":{"Name":{"value":"JANET RILEY","type":"STRING","name":"Name","label":"Full Name","isRequired":false},"ChexSystems_Qualifile_Strategy__c":{"value":null,"type":"STRING","name":"ChexSystems_Qualifile_Strategy__c","label":"FIS Qualifile Strategy","isRequired":false},"ChexSystems_Identifier__c":{"value":"12345678","type":"STRING","name":"ChexSystems_Identifier__c","label":"FIS Identifier","isRequired":false},"LLC_BI__SS__c":{"value":"666990422","type":"ENCRYPTEDSTRING","name":"LLC_BI__SS__c","label":"SS#","isRequired":false},"MailingStreet":{"value":"204 E AMERICAN BLVD","type":"TEXTAREA","name":"MailingStreet","label":"Mailing Street","isRequired":false},"MailingCity":{"value":"BLOOMINGTON","type":"STRING","name":"MailingCity","label":"Mailing City","isRequired":false},"MailingState":{"value":"MN","type":"STRING","name":"MailingState","label":"Mailing State/Province","isRequired":false},"MailingPostalCode":{"value":"55425","type":"STRING","name":"MailingPostalCode","label":"Mailing Zip/Postal Code","isRequired":false},"MailingCountry":{"value":null,"type":"STRING","name":"MailingCountry","label":"Mailing Country","isRequired":false},"AccountId":{"value":"0011I00000Nh3P7QAJ","type":"REFERENCE","name":"AccountId","label":"Account ID","isRequired":false},"Birthdate":{"value":null,"type":"DATE","name":"Birthdate","label":"Birthdate","isRequired":false},"LastName":{"value":"RILEY","type":"STRING","name":"LastName","label":"Last Name","isRequired":false},"FirstName":{"value":"JANET","type":"STRING","name":"FirstName","label":"First Name","isRequired":false},"Id":{"value":"0031I00000GzkcdQAB","type":"ID","name":"Id","label":"Contact ID","isRequired":false}}}]');
		FisMessageGenerator msgGenerator = new FisMessageGenerator(configurationMap);

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

		FisChexCreditAppFacade appfacade = new FisChexCreditAppFacade();

		System.RunAs(U){
			try{
				nFUSE.AMiddlewareMessage newMessage = new FisMessageGenerator(appfacade.retrieveKeyValueMap()).GenerateMessage(blankMessage);
			}
			catch (Exception e){
				system.assertEquals(e.getMessage(), 'ChexSystems_Qualifile_Strategy__c' + ' ' + FisMessageGenerator.X_FIELD_EMPTY);
			}
		}
	}
	@isTest
	private static void testGetFISQualifileStrategyNotInFieldset(){
		FisChexCreditActivator credActivator = new FisChexCreditActivator();
		credActivator.onActivate();

		//build message
		MiddlewareMessageMock blankMessage = new MiddlewareMessageMock();
		String externalId = new nFORCE.GuidGenerator().randomUUID();

		Map<String, String> configurationMap = new Map<String, String>();
		//copying nFUSE's output
		blankMessage.putProperty('record', '[{"saved":false,"recordId":"0031I00000GzkcdQAB","name":"JANET RILEY","isRelationshipPointer":false,"apexType":"nFUSE.Contact_v1_0","properties":{"Name":{"value":"JANET RILEY","type":"STRING","name":"Name","label":"Full Name","isRequired":false},"ChexSystems_Identifier__c":{"value":"12345678","type":"STRING","name":"ChexSystems_Identifier__c","label":"FIS Identifier","isRequired":false},"LLC_BI__SS__c":{"value":"666990422","type":"ENCRYPTEDSTRING","name":"LLC_BI__SS__c","label":"SS#","isRequired":false},"MailingStreet":{"value":"204 E AMERICAN BLVD","type":"TEXTAREA","name":"MailingStreet","label":"Mailing Street","isRequired":false},"MailingCity":{"value":"BLOOMINGTON","type":"STRING","name":"MailingCity","label":"Mailing City","isRequired":false},"MailingState":{"value":"MN","type":"STRING","name":"MailingState","label":"Mailing State/Province","isRequired":false},"MailingPostalCode":{"value":"55425","type":"STRING","name":"MailingPostalCode","label":"Mailing Zip/Postal Code","isRequired":false},"MailingCountry":{"value":null,"type":"STRING","name":"MailingCountry","label":"Mailing Country","isRequired":false},"AccountId":{"value":"0011I00000Nh3P7QAJ","type":"REFERENCE","name":"AccountId","label":"Account ID","isRequired":false},"Birthdate":{"value":null,"type":"DATE","name":"Birthdate","label":"Birthdate","isRequired":false},"LastName":{"value":"RILEY","type":"STRING","name":"LastName","label":"Last Name","isRequired":false},"FirstName":{"value":"JANET","type":"STRING","name":"FirstName","label":"First Name","isRequired":false},"Id":{"value":"0031I00000GzkcdQAB","type":"ID","name":"Id","label":"Contact ID","isRequired":false}}}]');
		FisMessageGenerator msgGenerator = new FisMessageGenerator(configurationMap);

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

		FisChexCreditAppFacade appfacade = new FisChexCreditAppFacade();

		System.RunAs(U){
			try{
				nFUSE.AMiddlewareMessage newMessage = new FisMessageGenerator(appfacade.retrieveKeyValueMap()).GenerateMessage(blankMessage);
			}
			catch (Exception e){
				system.assertEquals(e.getMessage(), 'ChexSystems_Qualifile_Strategy__c' + ' ' + FisMessageGenerator.X_MISSING_FROM_FIELDSET);
			}
		}
	}
	private static final String CHEXSYSTEMS_CATEGORY = FisChexCreditActivator.PLUGIN_NAME + 'Configuration';
}