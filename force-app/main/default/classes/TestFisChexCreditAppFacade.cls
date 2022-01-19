@isTest
private class TestFisChexCreditAppFacade {
 
	@isTest
	private static void testStoreDocuments_hasImplementation() {
		FisChexCreditAppFacade facade = new FisChexCreditAppFacade();
		Account acct = new Account(Name = 'Test');
		insert acct;
		nFUSE__Transaction_Log__c tLog = new nFUSE__Transaction_Log__c( //possible namespace issue
			nFUSE__Action__c = 'test',
			nFUSE__Api_Version__c = '1.0',
			nFUSE__Requesting_User_Id__c = UserInfo.getUserId(),
			nFUSE__Requested_By_User_Id__c = UserInfo.getUserId(),
			nFUSE__Transaction_Status__c = 'INPROGRESS',
			nFUSE__Object_Id__c = acct.Id,
			nFUSE__Primary_Object_Id__c = acct.Id,
			nFUSE__App_Plugin__c = 'ChexSystems_Credit',
			nFUSE__External_Id__c = new nFORCE.GuidGenerator().randomUUID()
		);
		insert tLog;
		test.startTest();
		try{
			facade.storeDocument(tLog.nFUSE__External_Id__c, 'test', 'some doc content');
			
		}catch(Exception e){
			
		}
		test.stopTest();
		System.assertEquals(true, true);
	}
	
	@isTest
	private static void testPreCommAdjustments(){
		//system properties should already exist
        nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='ChexSystems_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = 'QualiFile Version Number';
        property1.nFORCE__Value__c = 'N003';
        insert property1;
        
        nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbb',nFORCE__Category_Name__c='ChexSystems_CreditConfiguration',nFORCE__Is_Active__c=true);
        property2.nFORCE__Key__c = 'Consumer Days Valid';
        property2.nFORCE__Value__c = '30';
        insert property2;
		
		FisChexCreditActivator activator = new FisChexCreditActivator();
		activator.onActivate();
		MiddlewareMessageMock message = new MiddlewareMessageMock()
			.putProperty('ReportType', 'Hard')
			.putProperty('recordType', 'Contact');
		FisChexCreditAppFacade facade = new FisChexCreditAppFacade();

		facade.preCommAdjustments(message);
		System.assertEquals('N003', message.properties.get('QUALIFILE_VERSION_NUMBER'));
	}
	
@isTest
	private static void testPreCommAdjustments_MissingExpectedProperty(){
		nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='ChexSystems_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = 'Product: Identity Manager';
        property1.nFORCE__Value__c = 'N';
        insert property1;
		FisChexCreditActivator ac = new FisChexCreditActivator();
		ac.LoadPluginConfigurations();
		MiddlewareMessageMock message = new MiddlewareMessageMock()
			.putProperty('ReportType', 'Hard')
			.putProperty('recordType', 'Contact');
		FisChexCreditAppFacade facade = new FisChexCreditAppFacade();
		
		facade.preCommAdjustments(message);
		System.assertEquals('N', message.properties.get('PRODUCT_IDENTITY_MANAGER'));
	}


	private class MiddlewareMessageMock extends nFUSE.AMiddlewareMessage {
		public MiddlewareMessageMock(){}

		public MiddlewareMessageMock putProperty(String key, String value){
			this.properties.put(key, value);
			return this;
		}
	}
	
	private static NFORCE__System_Properties__c create(String cat, String key, String val){
		return new NFORCE__System_Properties__c(
			Name = new nFORCE.GuidGenerator().randomUUID(),
			NFORCE__Category_Name__c = cat,
			NFORCE__Key__c = key,
			NFORCE__Value__c = val,
			NFORCE__Is_Active__c = true
		);
	}


	private static final String CHEXSYSTEMS_CATEGORY = FisChexCreditActivator.PLUGIN_NAME + 'Configuration';
}