@isTest
private class TestEquifaxSendService{
    
    @isTest 
    private static void TestpreSendRequest(){
        Object acct = (Object) new Account(Name = 'Test');
        
        EquifaxSendService service = new EquifaxSendService();
        MiddlewareMessageMock message = new MiddlewareMessageMock();
        
        Object sameObject = service.preSendRequest(acct, message);
        
        System.assertEquals(acct, sameObject);
    }
    
    @isTest
    private static void TestpreSendSeam(){
        //create nFuse.PluginConfigurationManager by calling onActivate() to defer null reference error 
        EquifaxCreditActivator credActivator = new EquifaxCreditActivator();
		credActivator.onActivate();
		
		nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='bbbb',nFORCE__Category_Name__c='Equifax_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = 'Consumer Hard Member Number';
        property1.nFORCE__Value__c = '12348765AB';
        insert property1;
		
        EquifaxSendService service = new EquifaxSendService();
        
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
            nFUSE.AMiddlewareMessage newMessage = service.preSendSeam(new MiddlewareMessageMock().putProperty('ReportType', 'Hard'));
            System.assertEquals('ISTS', newMessage.properties.get(EquifaxCreditActivator.CONSUMER_CUSTOMER_CODE));
		}
    }
    
    @isTest
    private static void TestpostSendSeam(){
        //create nFuse.PluginConfigurationManager by calling onActivate() to defer null reference error 
        new EquifaxCreditActivator().onActivate();
        MiddlewareMessageMock message = new MiddlewareMessageMock();
        EquifaxSendService service = new EquifaxSendService();

        message.putProperty('testProperty','12345');
        
        nFUSE.AMiddlewareMessage newMessage = service.postSendSeam(message);
        System.assertEquals(message, newMessage);
    }
    
    private class MiddlewareMessageMock extends nFUSE.AMiddlewareMessage {
        public MiddlewareMessageMock(){}
        public MiddlewareMessageMock putProperty(String key, String value){
            this.properties.put(key, value);
            return this;
        }
    }
}