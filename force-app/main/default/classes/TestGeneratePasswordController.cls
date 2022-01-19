@isTest
private class TestGeneratePasswordController {
    
    public static Boolean forceRequestError = false;
        
    public class TestException extends Exception {}
    
    private static String passwordChangeResponseBodySuccess = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><changepassV002Response xmlns="urn:fisauthentication"><changepassReturnV002 xmlns=""><error xsi:nil="true"/><message>The password has been changed to alsekflasd and it will be effective immediately.</message><result>true</result><newPassword>true</newPassword></changepassReturnV002></changepassV002Response></soapenv:Body></soapenv:Envelope>';
    private static String passwordChangeResponseBodyFailureNoPasswordParentNode = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><changepassV002Response xmlns="urn:fisauthentication"></changepassV002Response></soapenv:Body></soapenv:Envelope>';
    private static String passwordChangeResponseBodyFailureNotTrue = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><changepassV002Response xmlns="urn:fisauthentication"><changepassReturnV002 xmlns=""><error xsi:nil="true"/><message>not changed</message><result>false</result></changepassReturnV002></changepassV002Response></soapenv:Body></soapenv:Envelope>';
    private static String passwordChangeResponseBodyFailurePasswordBlank = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><changepassV002Response xmlns="urn:fisauthentication"><changepassReturnV002 xmlns=""><error xsi:nil="true"/><message>The password has been changed to alsekflasd and it will be effective immediately.</message><result>true</result><newPassword></newPassword></changepassReturnV002></changepassV002Response></soapenv:Body></soapenv:Envelope>';

    private static String expirationDateResponseBodySuccess = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><retrievePwdExpdateResponse xmlns="urn:fisauthentication"><retrieveExpdateReturn xmlns="">13-mar-2019 18:13:93</retrieveExpdateReturn></retrievePwdExpdateResponse></soapenv:Body></soapenv:Envelope>';
    private static String expirationDateResponseBodyFailureNoDateNode = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body></soapenv:Body></soapenv:Envelope>';
    private static String expirationDateResponseBodyFailureDateNodeBlank = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><retrievePwdExpdateResponse xmlns="urn:fisauthentication"><retrieveExpdateReturn xmlns=""></retrieveExpdateReturn></retrievePwdExpdateResponse></soapenv:Body></soapenv:Envelope>';
    private static String expirationDateResponseBodyFailureDateNotParsed = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><retrievePwdExpdateResponse xmlns="urn:fisauthentication"><retrieveExpdateReturn xmlns="">something unexpected</retrieveExpdateReturn></retrievePwdExpdateResponse></soapenv:Body></soapenv:Envelope>';
    
	private static void insertPluginData(String stagingServer, String daysReminder){
	    //update the userame and password to something
        List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs = new List<nFUSE.PluginConfigurationManager.PluginConfiguration> {};
		
		nFUSE.PluginConfigurationManager.PluginConfiguration config = new nFUSE.PluginConfigurationManager.PluginConfiguration();
		config.pluginName = FisChexCreditActivator.PLUGIN_NAME;
		config.pluginVersion = FisChexCreditActivator.PLUGIN_VERSION;
		config.category = FisChexCreditActivator.PLUGIN_NAME;
		config.key = FisChexCreditActivator.CHEXSYSTEMS_PASSWORD;
		config.valueDataType = 'String';
		config.value = 'anything';
		config.isEncrypted = true;
		
		configs.add(config);
		
		nFUSE.PluginConfigurationManager.PluginConfiguration config2 = new nFUSE.PluginConfigurationManager.PluginConfiguration();
		config2.pluginName = FisChexCreditActivator.PLUGIN_NAME;
		config2.pluginVersion = FisChexCreditActivator.PLUGIN_VERSION;
		config2.category = FisChexCreditActivator.PLUGIN_NAME;
		config2.key = FisChexCreditActivator.CHEXSYSTEMS_USERNAME;
		config2.valueDataType = 'String';
		config2.value = 'anything';
		config2.isEncrypted = false;
		
		configs.add(config2);
		
		nFUSE.PluginConfigurationManager.PluginConfiguration config3 = new nFUSE.PluginConfigurationManager.PluginConfiguration();
		config3.pluginName = FisChexCreditActivator.PLUGIN_NAME;
		config3.pluginVersion = FisChexCreditActivator.PLUGIN_VERSION;
		config3.category = FisChexCreditActivator.PLUGIN_NAME;
		config3.key = FisChexCreditActivator.STAGING_SERVER;
		config3.valueDataType = 'String';
		config3.value = stagingServer;
		config3.isEncrypted = false;
		
		configs.add(config3);
		
		nFUSE.PluginConfigurationManager.PluginConfiguration config4 = new nFUSE.PluginConfigurationManager.PluginConfiguration();
		config4.pluginName = FisChexCreditActivator.PLUGIN_NAME;
		config4.pluginVersion = FisChexCreditActivator.PLUGIN_VERSION;
		config4.category = FisChexCreditActivator.PLUGIN_NAME;
		config4.key = FisChexCreditActivator.CHEXSYSTEMS_REMINDDAYSBEFOREEXPIRATION;
		config4.valueDataType = 'String';
		config4.value = daysReminder;
		config4.isEncrypted = false;
		
		configs.add(config4);
		
		//DML
        new nFUSE.PluginConfigurationManager(FisChexCreditActivator.PLUGIN_NAME, FisChexCreditActivator.PLUGIN_VERSION).updateConfigurations(configs);
    
	}
	
	private static void AddPermissionToUser(User u, String permissionName){
	    
	    String permName = permissionName;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =:permName];

        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
	}
	
	private static User CreateUser(String alias, String email){
	    
	    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User u = new User(Alias = alias, Email=email,
                EmailEncodingKey='UTF-8', LastName=alias, LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',     UserName=email);
        insert u;

        return u;
        
	}
	
	@isTest
    private static void test_orchestrator_monthConversion_succeeds(){
        Map<String,String> months = new Map<String,String>{'jan'=>'01',
        'feb'=>'02',
        'mar'=>'03',
        'apr'=>'04',
        'may'=>'05',
        'jun'=>'06',
        'jul'=>'07',
        'aug'=>'08',
        'sep'=>'09',
        'oct'=>'10',
        'nov'=>'11',
        'dec'=>'12'};
        GeneratePasswordOrchestrator orch = new GeneratePasswordOrchestrator();
        for(String m : months.keySet()){
            
            String dateStringToParse = '01-{0}-2018 08:33:07';
            
            String expectedValue = String.format('{0}/01/2018 08:33 AM',new String[]{months.get(m)});
            String testValue = orch.convertChexDateTimeToSalesforceDateTime(String.format(dateStringToParse,new String[]{m}));
            
            system.assertEquals(expectedValue,testValue);
            
        }
    }
    
	@isTest
    private static void test_orchestrator_monthConversion_fails_notHandled(){
        GeneratePasswordOrchestrator orch = new GeneratePasswordOrchestrator();
        String dateStringToParse = 'something to fail';
        
        String expectedValue = '01/01/2018 08:33 AM';
        try{
            String testValue = orch.convertChexDateTimeToSalesforceDateTime(dateStringToParse);    
            system.assertEquals(true,false);
        }catch(Exception e){
            system.assertEquals(true,true);
        }
        
        
        
    }
    
    @isTest
    private static void test_orchestrator_monthConversion_fails_improperMonth(){
        GeneratePasswordOrchestrator orch = new GeneratePasswordOrchestrator();
        String dateStringToParse = '01-march-2018 08:33:07';
        
        String expectedValue = '01/01/2018 08:33 AM';
        try{
            String testValue = orch.convertChexDateTimeToSalesforceDateTime(dateStringToParse);    
            system.assertEquals(true,false);
        }catch(Exception e){
            system.assertEquals('Unsupported Month march',e.getMessage());
        }
    }
    
    @isTest
    private static void test_orchestrator_getConfiguration_failsNoReminderDays(){
        Test.testInstall(new nFUSE.DataInstaller(), null);
        GeneratePasswordOrchestrator orch = new GeneratePasswordOrchestrator();
        try{
            GeneratePasswordOrchestrator.ChexCreds creds = orch.GetConfigurationSettings();
            system.assertEquals(true,false);
        }catch(Exception e){
            system.assertEquals('The plugin configuration property for "'+FisChexCreditActivator.CHEXSYSTEMS_REMINDDAYSBEFOREEXPIRATION+'" must be populated with a positive number between 91 and 365. nCino recommends setting it to 100.',e.getMessage());
        }
    }
    
    
	@isTest
    private static void test_standardController_noAccess(){
        test.startTest();
        
        User userWithoutPermission = CreateUser('user2', 'chex-noperm@chex.com');
        
        system.runAs(userWithoutPermission){
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(false,c.hasPermission);
        }
        test.stopTest();
    }
    
    @isTest
    private static void test_standardController_hasAccess(){
        
        test.startTest();
        
        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
        }
        test.stopTest();
        
    }
    
    @isTest
    private static void test_standardController_expirationDateLoad_succeeds(){
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'Complete',
                expirationDateResponseBodySuccess,
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('y','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.getExpirationDate();    
                system.assertEquals('3/13/2019 6:13 PM',returnedDate);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals('test','Error: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    @isTest
    private static void test_standardController_expirationDateLoad_succeeds_stagingTrue(){
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'Complete',
                expirationDateResponseBodySuccess,
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('true','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.getExpirationDate();    
                system.assertEquals('3/13/2019 6:13 PM',returnedDate);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals('test','Error: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    @isTest
    private static void test_standardController_expirationDateLoad_succeeds_stagingYes(){
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'Complete',
                expirationDateResponseBodySuccess,
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('yes','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.getExpirationDate();    
                system.assertEquals('3/13/2019 6:13 PM',returnedDate);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals('test','Error: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    @isTest
    private static void test_standardController_expirationDateLoad_succeeds_stagingOne(){
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'Complete',
                expirationDateResponseBodySuccess,
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('1','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.getExpirationDate();    
                system.assertEquals('3/13/2019 6:13 PM',returnedDate);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals('test','Error: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    @isTest
    private static void test_standardController_expirationDateLoad_fails_calloutException(){
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'Complete',
                expirationDateResponseBodySuccess,
                null);
        forceRequestError = true;
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('y','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.getExpirationDate();    
                system.assertEquals(true,false);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals('Failed to communicate to ChexSystems. [Error: forceRequestError]',e.getMessage());
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    @isTest
    private static void test_standardController_expirationDateLoad_fails_daysReminderInvalid(){
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'Complete',
                expirationDateResponseBodySuccess,
                null);
        forceRequestError = true;
        
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('y','30');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.getExpirationDate();    
                system.assertEquals(true,false);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals('The plugin configuration property for "ChexSystems Reminder Days Before Expiration" must be populated with a positive number between 91 and 365. nCino recommends setting it to 100.',e.getMessage());
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    @isTest
    private static void test_standardController_expirationDateLoad_failsNoDateNode(){
        
        SingleRequestMock fakeResponse = new SingleRequestMock(500,
                'Complete',
                expirationDateResponseBodyFailureNoDateNode,
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('y','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.getExpirationDate();    
                system.assertEquals(true,false);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals(true,e.getMessage().startsWithIgnoreCase('Failed to parse expiration date response. [Error: Could not locate date node in the parsed response.'));
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    @isTest
    private static void test_standardController_expirationDateLoad_dateNodeBlank(){
        
        SingleRequestMock fakeResponse = new SingleRequestMock(500,
                'Complete',
                expirationDateResponseBodyFailureDateNodeBlank,
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('y','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.getExpirationDate();    
                system.assertEquals(true,false);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals(true,e.getMessage().startsWithIgnoreCase('Failed to parse expiration date response. [Error: Date node was blank when it was expected to be populated.'));
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    @isTest
    private static void test_standardController_expirationDateLoad_dateNotParsed(){
        
        SingleRequestMock fakeResponse = new SingleRequestMock(500,
                'Complete',
                expirationDateResponseBodyFailureDateNotParsed,
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('y','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.getExpirationDate();    
                system.assertEquals(true,false);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals(true,e.getMessage().startsWithIgnoreCase('Failed to parse expiration date response.'));
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    @isTest
    private static void test_standardController_passwordChange_succeeds(){
        
        GeneratePasswordOrchestrator.forcePasswordExpirationDateSkip = true;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'Complete',
                passwordChangeResponseBodySuccess,
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('y','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.autoGeneratePassword();    
                system.assertEquals(String.format(System.Label.ChexSystemsPasswordSuccessMessage, new String[]{ Date.valueOf(DateTime.Now().AddDays(1)).format(), '100', 'The password has been changed to alsekflasd and it will be effective immediately. ' }),returnedDate);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals('test','Error: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    @isTest
    private static void test_standardController_passwordChange_succeeds_reminderPresent(){
        
        GeneratePasswordOrchestrator.forcePasswordExpirationDateSkip = true;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'Complete',
                passwordChangeResponseBodySuccess,
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('y','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.autoGeneratePassword();    
                system.assertEquals(String.format(System.Label.ChexSystemsPasswordSuccessMessage, new String[]{ Date.valueOf(DateTime.Now().AddDays(1)).format(), '100', 'The password has been changed to alsekflasd and it will be effective immediately. ' }),returnedDate);
                
                List<Task> ts = [SELECT Id, Subject FROM Task];
                system.assertEquals(true,ts.size()==1);
                system.assertEquals(System.Label.ChexSystemsReminderSubject,ts[0].Subject);
                
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals('test','Error: ' + e.getMessage() + ' Line Number: ' + e.getLineNumber());
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    
    @isTest
    private static void test_standardController_passwordChange_fails_wrongDateObtainMessage(){
        
        SingleRequestMock fakeResponse = new SingleRequestMock(200,
                'Complete',
                passwordChangeResponseBodySuccess, //expected to fail because we only can set a single request
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('y','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.autoGeneratePassword();    
                system.assertEquals(true,false);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals(true,e.getMessage().startsWithIgnoreCase('Failed to parse expiration date response. [Error: Could not locate date node in the parsed response.'));
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    @isTest
    private static void test_standardController_passwordChange_FailsNoPasswordParentNode(){
        
        GeneratePasswordOrchestrator.forcePasswordExpirationDateSkip = true;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(500,
                'Complete',
                passwordChangeResponseBodyFailureNoPasswordParentNode,
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('y','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.autoGeneratePassword();    
                system.assertEquals(true,false);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals(true,e.getMessage().startsWithIgnoreCase('Failed to parse password update response. [Error: Could not locate password node in the parsed response.'));
            }
            test.stopTest();
            
        }
        
        
        
    }
    
	@isTest
    private static void test_standardController_passwordChange_FailsNotTrue(){
        
        GeneratePasswordOrchestrator.forcePasswordExpirationDateSkip = true;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(500,
                'Complete',
                passwordChangeResponseBodyFailureNotTrue,
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('y','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.autoGeneratePassword();    
                system.assertEquals(true,false);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals(true,e.getMessage().startsWithIgnoreCase('Failed to parse password update response. [Error: There was an error automatically generating the password. '));
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    @isTest
    private static void test_standardController_passwordChange_FailsPasswordBlank(){
        
        GeneratePasswordOrchestrator.forcePasswordExpirationDateSkip = true;
        
        SingleRequestMock fakeResponse = new SingleRequestMock(500,
                'Complete',
                passwordChangeResponseBodyFailurePasswordBlank,
                null);
                
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        User userWithPermission = CreateUser('user1', 'chex-perm@chex.com');
        
        AddPermissionToUser(userWithPermission, ChexSystemsGeneratePasswordController.PERMISSION_NAME);
        
        system.runAs(userWithPermission){
            
            Test.testInstall(new nFUSE.DataInstaller(), null);
            (new FisChexCreditActivator()).LoadPluginConfigurations();
            
            insertPluginData('y','100');
            
            ChexSystemsGeneratePasswordController c = new ChexSystemsGeneratePasswordController(new ApexPages.StandardController(new Account()));
            system.assertEquals(true,c.hasPermission);
            
            test.startTest();
            try{
                String returnedDate = ChexSystemsGeneratePasswordController.autoGeneratePassword();    
                system.assertEquals(true,false);
            }catch(Exception e){
                //system.assertEquals(true,false);
                system.assertEquals(true,e.getMessage().startsWithIgnoreCase('Failed to parse password update response. [Error: Password node was blank when it was expected to be populated.'));
            }
            test.stopTest();
            
        }
        
        
        
    }
    
    public class SingleRequestMock implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String bodyAsString;
        protected Blob bodyAsBlob;
        protected Map<String, String> responseHeaders;

        public SingleRequestMock(Integer code, String status, String body,
                Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsString = body;
            this.bodyAsBlob = null;
            this.responseHeaders = responseHeaders;
        }

        public SingleRequestMock(Integer code, String status, Blob body,
                Map<String, String> responseHeaders) {
            this.code = code;
            this.status = status;
            this.bodyAsBlob = body;
            this.bodyAsString = null;
            this.responseHeaders = responseHeaders;
        }

        public HTTPResponse respond(HTTPRequest req) {
            
            if(forceRequestError){
                throw new TestException('forceRequestError');
            }
            
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(code);
            resp.setStatus(status);
            if (bodyAsBlob != null) {
                resp.setBodyAsBlob(bodyAsBlob);
            } else {
                resp.setBody(bodyAsString);
            }

            if (responseHeaders != null) {
                for (String key : responseHeaders.keySet()) {
                    resp.setHeader(key, responseHeaders.get(key));
                }
            }
            return resp;
        }
    }
	
}