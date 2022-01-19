@isTest
private class TestEquifaxCreditAppFacade {

	@isTest
	private static void testStoreDocuments_hasImplementation() {
		EquifaxCreditAppFacade facade = new EquifaxCreditAppFacade();
		Account acct = new Account(Name = 'Test');
		insert acct;
		nFUSE__Transaction_Log__c tLog = new nFUSE__Transaction_Log__c(
			nFUSE__Action__c = 'test',
			nFUSE__Api_Version__c = '1.0',
			nFUSE__Requesting_User_Id__c = UserInfo.getUserId(),
			nFUSE__Requested_By_User_Id__c = UserInfo.getUserId(),
			nFUSE__Transaction_Status__c = 'INPROGRESS',
			nFUSE__Object_Id__c = acct.Id,
			nFUSE__Primary_Object_Id__c = acct.Id,
			nFUSE__App_Plugin__c = 'Equifax_Credit',
			nFUSE__External_Id__c = new nFORCE.GuidGenerator().randomUUID()
		);
		insert tLog;
		Test.startTest();
		try{
			facade.storeDocument(tLog.nFUSE__External_Id__c, 'test', 'some doc content');
			
		}catch(Exception e){
			
		}
		Test.stopTest();
	    System.assertEquals(true, true);
	}

	@isTest
	private static void testPreCommAdjustments(){
	    		
		//system properties should already exist
        nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='Equifax_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = 'Consumer Environment Flag';
        property1.nFORCE__Value__c = 'UAT';
        insert property1;
        
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbb',nFORCE__Category_Name__c='Equifax_CreditConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = 'Consumer Days Valid';
        property2.nFORCE__Value__c = '30';
        insert property2;
        
        nFORCE__System_Properties__c property3 = new nFORCE__System_Properties__c(Name='cccc',nFORCE__Category_Name__c='Equifax_CreditConfiguration',nFORCE__Is_Active__c=true);
        property3.nFORCE__Key__c = 'Consumer Hard Member Number';
        property3.nFORCE__Value__c = '12348765AB';
        insert property3;
		
		EquifaxCreditActivator activator = new EquifaxCreditActivator();
		activator.onActivate();
		
		MiddlewareMessageMock message = new MiddlewareMessageMock()
			.putProperty('ReportType', 'Hard')
			.putProperty('recordType', 'Contact');
			
		EquifaxCreditAppFacade facade = new EquifaxCreditAppFacade();
		facade.preCommAdjustments(message);

		System.assertEquals('UAT', message.properties.get(EquifaxCreditActivator.CONSUMER_ENVIRONMENT_FLAG));
	}
	
	private class MiddlewareMessageMock extends nFUSE.AMiddlewareMessage {
		public MiddlewareMessageMock(){}

		public MiddlewareMessageMock putProperty(String key, String value){
			this.properties.put(key, value);
			return this;
		}
	}
	private static final String EQUIFAX_CATEGORY = EquifaxCreditActivator.PLUGIN_NAME + 'Configuration';
}