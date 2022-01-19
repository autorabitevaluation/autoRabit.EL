@isTest
private without sharing class TestChexsystemsSessionTriggerHandler {

    @isTest
    private static void checkProductLoyalty() {
        setupData(Date.newInstance(1991, 12, 12), PRODUCT1, LOYALTYCHECKING,'FakeBranchName','CK001');
        
        nFORCE__Session__c testSession = [SELECT Id FROM nFORCE__Session__c LIMIT 1];
        nFORCE__Route_Group__c testRouteGroup = [SELECT Id FROM nFORCE__Route_Group__c LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Email = 'bruce.wayne@wayneenterprises.com' LIMIT 1];
        
        System.runAs(testUser) {
            new FisChexCreditActivator().onActivate();
        }
        
        test.startTest();
        
        testSession.nFORCE__Route_Group__c = testRouteGroup.Id;
        
        System.runAs(testUser) {
            update testSession;
        }
        
        test.stopTest();
    }

    @isTest
    private static void setDefaultFISChexFields_invalidBranchName() {

        Id accountId = setupData(Date.newInstance(1991, 12, 12), PRODUCT1, LOYALTYCHECKING,'FakeBranchName','CK001');
        
        nFORCE__Session__c testSession = [SELECT Id FROM nFORCE__Session__c LIMIT 1];
        nFORCE__Route_Group__c testRouteGroup = [SELECT Id FROM nFORCE__Route_Group__c LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Email = 'bruce.wayne@wayneenterprises.com' LIMIT 1];

        Account acct = new Account(Id = accountId);

        test.startTest();
        
        List<String> auditTextList = ChexsystemsSessionTriggerHandler.setDefaultFISChexFields(acct);
        System.assertEquals(2, auditTextList.size(), JSON.serialize(auditTextList));
        System.assertEquals(true, auditTextList[0].contains('Failed to query LLC_BI__Branch'), JSON.serialize(auditTextList));
        System.assertEquals(true, auditTextList[1].contains('Could not locate LLC_BI__Branch record associated to the configured default Branch Name: FakeBranchName.'), JSON.serialize(auditTextList));

        test.stopTest();
    }

    @isTest
    private static void setDefaultFISChexFields_chexSystemsSettingsDoNotExist() {

        Id accountId = setupData(Date.newInstance(1991, 12, 12), PRODUCT1, LOYALTYCHECKING,'','');
        
        nFORCE__Session__c testSession = [SELECT Id FROM nFORCE__Session__c LIMIT 1];
        nFORCE__Route_Group__c testRouteGroup = [SELECT Id FROM nFORCE__Route_Group__c LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Email = 'bruce.wayne@wayneenterprises.com' LIMIT 1];

        Account acct = new Account(Id = accountId);

        test.startTest();
        
        List<String> auditTextList = ChexsystemsSessionTriggerHandler.setDefaultFISChexFields(acct);
        System.assertEquals(1, auditTextList.size(), JSON.serialize(auditTextList));
        System.assertEquals(true, auditTextList[0].contains('Chexsystems Online App Default Settings do not exist.'), JSON.serialize(auditTextList));

        test.stopTest();
    }
    
    @isTest
    private static void checkProductChoiceChecking() {
        setupData(Date.newInstance(1999, 12, 12), PRODUCT1, CHOICECHECKING,'ONLINE','CK001');
        nFORCE__Session__c testSession = [SELECT Id FROM nFORCE__Session__c LIMIT 1];
        nFORCE__Route_Group__c testRouteGroup = [SELECT Id FROM nFORCE__Route_Group__c LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Email = 'bruce.wayne@wayneenterprises.com' LIMIT 1];
        
        System.runAs(testUser) {
            new FisChexCreditActivator().onActivate();
        }
        
        test.startTest();
        
        testSession.nFORCE__Route_Group__c = testRouteGroup.Id;
        System.runAs(testUser) {
            update testSession;
        }
        
        test.stopTest();
    }
    
    @isTest
    private static void checkProductOther() {
        setupData(Date.newInstance(1991, 12, 12), PRODUCT1, 'Gold Checking','ONLINE','CK001');
        nFORCE__Session__c testSession = [SELECT Id FROM nFORCE__Session__c LIMIT 1];
        nFORCE__Route_Group__c testRouteGroup = [SELECT Id FROM nFORCE__Route_Group__c LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Email = 'bruce.wayne@wayneenterprises.com' LIMIT 1];
        
        System.runAs(testUser) {
            new FisChexCreditActivator().onActivate();
        }
        
        test.startTest();
        
        testSession.nFORCE__Route_Group__c = testRouteGroup.Id;
        System.runAs(testUser) {
            update testSession;
        }
        
        test.stopTest();
    }
    private static Id setupData(Date bday, String loanProductName, String depositProductName, String defaultBranchName, String chexSystemsStrategy) {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];

        Id accountId;
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'testhjalfkdshfu3@valleyTewst.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            IsActive = true
        );
        Database.insert(portalAccountOwner1);
        
        System.runAs ( portalAccountOwner1 ) {

            if(String.isNotBlank(defaultBranchName) && String.isNotBlank(chexSystemsStrategy)){
                Chexsystems_Online_App_Default_Settings__c hierarchySetting = Chexsystems_Online_App_Default_Settings__c.getOrgDefaults();
                hierarchySetting.Default_Branch__c = defaultBranchName;
                hierarchySetting.Default_ChexSystems_Qualifile_Strategy__c = chexSystemsStrategy;
                insert hierarchySetting;
            }

            //Create account
            Account portalAccount1 = new Account(
                Name = 'TestAccount',
                OwnerId = portalAccountOwner1.Id
            );
            Database.insert(portalAccount1);

            accountId = portalAccount1.Id;

            //Create contact
            Contact contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = portalAccount1.Id,
                Birthdate = bday,
                Email = System.now().millisecond() + 'test@test.com'
               
           //     RecordTypeId = Schema.SObjectType.contact.getRecordTypeInfosByName().get('Business').getRecordTypeId()
            );
            Database.insert(contact1);
            System.debug(contact1);
            
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'nCino Community User' Limit 1];
            System.debug(portalProfile);
            User user1 = new User(
                Username = System.now().millisecond() + 'testhjalfkdshfuie123@valleyTewst.com',
                ContactId = contact1.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'testhjalfkdshfuie123@valleyTewst.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            Database.insert(user1);
            system.debug(user1);
            
            Account acct = [SELECT Id FROM Account WHERE Id = :portalAccount1.Id LIMIT 1];
            Contact contct = [SELECT Id FROM Contact WHERE AccountId = :portalAccount1.Id LIMIT 1];
            User newUser = [SELECT Id FROM User WHERE LastName = 'McTesty' LIMIT 1];
            
            LLC_BI__Product_Line__c productLine = new LLC_BI__Product_Line__c(
                Name = 'Mortgage'
            );
            
            insert productLine;
            
            LLC_BI__Product_Line__c productLineDeposit = new LLC_BI__Product_Line__c(
                Name = 'Deposit'
            );
            
            insert productLineDeposit;
            
            LLC_BI__Product_Type__c productType = new LLC_BI__Product_Type__c(
                Name = 'Mortgage',
                LLC_BI__Product_Line__c = productLine.Id
            );
            
            insert productType;
            
            LLC_BI__Product_Type__c productTypeDeposit = new LLC_BI__Product_Type__c(
                Name = 'Checking',
                LLC_BI__Product_Line__c = productLineDeposit.Id
            );
            
            insert productTypeDeposit;
            
            LLC_BI__Product__c product1 = new LLC_BI__Product__c(
                Name = PRODUCT1,
                LLC_BI__Product_Type__c = productType.Id
            );
            
            insert product1;
            
            LLC_BI__Product__c product2 = new LLC_BI__Product__c(
                Name = 'Other',
                LLC_BI__Product_Type__c = productType.Id
            );
            
            insert product2;
            
            LLC_BI__Product__c product3 = new LLC_BI__Product__c(
                Name = LOYALTYCHECKING,
                LLC_BI__Product_Type__c = productTypeDeposit.Id
            );
            
            insert product3;
            
            LLC_BI__Product__c product4 = new LLC_BI__Product__c(
                Name = CHOICECHECKING,
                LLC_BI__Product_Type__c = productTypeDeposit.Id
            );
            
            insert product4;
            
            LLC_BI__Product__c product5 = new LLC_BI__Product__c(
                Name = 'Gold Checking',
                LLC_BI__Product_Type__c = productTypeDeposit.Id
            );
            
            insert product5;
            
            LLC_BI__Loan__c loan = new LLC_BI__Loan__c(
                Name = 'Test Loan',
                LLC_BI__Product_Line__c = 'Mortgage',
                LLC_BI__Product_Type__c = 'Mortgage',
                LLC_BI__Product__c = loanProductName,
                LLC_BI__Status__c = STATUSOPEN
            );
            
            insert loan;
            
            LLC_BI__Legal_Entities__c legalEntity = new LLC_BI__Legal_Entities__c(
                Name = '456uhbvfr56ujm',
                LLC_BI__Account__c = acct.Id,
                LLC_BI__Loan__c = loan.Id,
                LLC_BI__Ownership__c = 100
            );
            
            insert legalEntity;
            
            LLC_BI__Application__c application = new LLC_BI__Application__c(
                nPORTAL__Account__c = acct.Id,
                nPORTAL__Applicant__c = newUser.Id
            );
            
            insert application;
            
            nFORCE__Session__c session = new nFORCE__Session__c(
                Name = '457ujbt67'
            );
            
            insert session;
            
            nPORTAL__Context__c context = new nPORTAL__Context__c(
                nPORTAL__Session__c = session.Id,
                nPORTAL__Application__c = application.Id,
                nPortal__Context_Start__c = DateTime.now(),
                nPortal__User__c = newUser.Id
                
            );
            
            insert context;
           

            LLC_BI__Deposit__c deposit = new LLC_BI__Deposit__c(
                Name = 'Test Deposit',
                LLC_BI__Application__c = application.Id,
                LLC_BI__Product_Line__c = 'Deposit',
                LLC_BI__Product_Type__c = 'Checking',
                LLC_BI__Product__c = depositProductName,
                LLC_BI__Product_Reference__c = product5.Id 
            );
            
            insert deposit;
            
             LLC_BI__Branch__c newBranch = new LLC_BI__Branch__c(
                Name = 'ONLINE',
                ChexSystems_Identifier__c = '30291878'
            );
            
            insert newBranch;
            
            nFORCE__Group__c newGroup = new nFORCE__Group__c(
                Name = 'Test Group',
                nFORCE__App__c = 'portal-dep',
                ChexSystems_Route__c = 'portal-dep.dep-review'
            );
            
            insert newGroup;
            
            nFORCE__Route__c route = new nFORCE__Route__c(
                Name = 'test Route',
                nFORCE__App__c = 'dep-review'
            );
            
            insert route;
            
            nFORCE__Route_Group__c routeGroup = new nFORCE__Route_Group__c(
                nFORCE__Group__c = newGroup.Id,
                nFORCE__Route__c = route.Id
            );
            
            insert routeGroup;
            
            nFORCE__System_Properties__c mw1 = new nFORCE__System_Properties__c(Name='middleware.username',nFORCE__Category_Name__c='Middleware Configuration',nFORCE__Is_Active__c=true);
            mw1.nFORCE__Key__c = 'middleware.username';
            mw1.nFORCE__Value__c = 'user1';
            insert mw1;
            
            nFORCE__System_Properties__c mw2 = new nFORCE__System_Properties__c(Name='middleware.endpoint',nFORCE__Category_Name__c='Middleware Configuration',nFORCE__Is_Active__c=true);
            mw2.nFORCE__Key__c = 'middleware.endpoint';
            mw2.nFORCE__Value__c = 'http://www.google.com';
            insert mw2;
            
            nFORCE__System_Properties__c mw3 = new nFORCE__System_Properties__c(Name='middleware.password',nFORCE__Category_Name__c='Middleware Configuration',nFORCE__Is_Active__c=true);
            mw3.nFORCE__Key__c = 'middleware.password';
            mw3.nFORCE__Value__c = 'pwd';
            insert mw3;
            
            
            //system properties should already exist
            nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
            property1.nFORCE__Key__c = 'Consumer Days Valid';
            property1.nFORCE__Value__c = '30';
            insert property1;
            
            nFORCE__System_Properties__c property2 = new nFORCE__System_Properties__c(Name='bbbb',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
            property2.nFORCE__Key__c = 'Business Days Valid';
            property2.nFORCE__Value__c = '30';
            insert property2;
            
            nFORCE__System_Properties__c property3 = new nFORCE__System_Properties__c(Name='cccc',nFORCE__Category_Name__c='FairIsaac_CreditConfiguration',nFORCE__Is_Active__c=true);
            property3.nFORCE__Key__c = 'FICO.Individual_Types';
            property3.nFORCE__Value__c = 'Individual';
            insert property3;
        }

        return accountId;
    }

    private static final String LOYALTYCHECKING = 'My Loyalty Checking Account';
    private static final String CHOICECHECKING = 'VNB My Choice Checking';
    private static final String STATUSOPEN = 'Open';
    private static final String PRODUCT1 = 'Commercial Mortgage';
}