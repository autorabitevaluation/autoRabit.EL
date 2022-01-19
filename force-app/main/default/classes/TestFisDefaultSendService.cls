@isTest
private class TestFisDefaultSendService{
    
    @isTest 
    private static void TestpreSendRequest(){
        Object acct = (Object) new Account(Name = 'Test');
        
        FisDefaultSendService service = new FisDefaultSendService();
        MiddlewareMessageMock message = new MiddlewareMessageMock();
        Object sameObject = service.preSendRequest(acct, message);
        
        System.assertEquals(acct, sameObject);
    }
    
    @isTest
    private static void TestpreSendSeam(){
        //create nFuse.PluginConfigurationManager by calling onActivate() to defer null reference error 
        new FisChexCreditActivator().onActivate();
        FisDefaultSendService service = new FisDefaultSendService();
        
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
            nFUSE.AMiddlewareMessage newMessage = service.preSendSeam(new MiddlewareMessageMock());
            System.assertEquals('N003', newMessage.properties.get('QUALIFILE_VERSION_NUMBER'));
		}
    }
    
    @isTest
    private static void TestpostSendSeam(){
        //create nFuse.PluginConfigurationManager by calling onActivate() to defer null reference error 
        new FisChexCreditActivator().onActivate();
        MiddlewareMessageMock message = new MiddlewareMessageMock();
        FisDefaultSendService service = new FisDefaultSendService();

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