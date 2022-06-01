/***************
** History**
** update 6th June **

*******************/


@isTest
private class AutoCreateRegHandlerTest {
    
    static testMethod void testPWMManualQueueAssignemntTest() {
        Test.startTest();
        AutocreatedRegHandler1559890732239 handler = new AutocreatedRegHandler1559890732239();
        //Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
        //                                             'testFirst testLast', 'testuserss@example.org', null, 'testuserlong', 'en_US', 'facebook',
         //                                            null, new Map<String, String>{'language' => 'en_US'});
        //String pid =[Select Id from Profile Where name ='System Administrator'].Id ;
        Map<string,String> businessAdminUser=  new Map<String, String>
            {'language' => 'en_US' ,
            'User.UserName'=>'PWMBusinessAdmin@FRB.com' ,
            'User.LastName'=>'Admin',
            'User.FirstName'=>'PWM Business User',
            'User.Email'=>'admin@FRB.com',
            'User.Alias'=>'pwmBA',
            'User.CommunityNickname'=>'asdjasxxgdjhahsdhaqq',
            'User.TimeZoneSidKey'=>'America/Los_Angeles',
            'User.LocaleSidKey'=>'en_US',
            'User.EmailEncodingKey'=>'UTF-8',
            'User.IsActive'=>'true',
            'memberOf'=>'gg_app_CLM_PWM_Business_Admin',
            'federationIdentifier'=>'federationId1',
            'User.LanguageLocaleKey'=>'en_US' 
            };     
            String uid = '';
            User baUser;
            try {
                
                baUser = handler.createUser(null,null,null,'federationId1', businessAdminUser  ,null);
                uid = baUser.id;
                System.assert(uid != null);                    
            } catch(Exception e){
                system.debug('#####################');
                system.debug(e.getMessage() + ' ' + e.getStackTraceString());
                system.debug('#####################');
            }
            PermissionSet ps = [ SELECT id FROM PermissionSet WHERE Name = 'PWM_Business_Admin'];
            PermissionSetAssignment psa = new PermissionSetAssignment( AssigneeId = UserInfo.getUserId() , PermissionSetId = ps.Id );
            insert psa;
                //System.runAs(baUser) {
                Group g = new Group( Type = 'Queue', Name = 'GJ-PWM-Test Queue' );
                insert g;
                QueueSObject q = new QueueSObject( QueueId = g.id , SObjectType = 'Case');
                insert q;
                System.assert( q.id != null ) ;
                GroupMember gm = new GroupMember( GroupId = g.id , UserOrGroupId = baUser.id );
                insert gm;
                System.assert( gm.id != null );
                System.assert( uid != null );
                List<GroupMember> groupMemberList = [ SELECT id,GroupId FROM GroupMember WHERE UserOrGroupId = :baUser.id ];        
                try {
                    //businessAdminUser.put('memberOf','gg_app_CLM_Eagle_Role_LOS_Associate');
                    //businessAdminUser.put( 'User.IsActive','false');
                    handler.updateUser(baUser.id,null,null,null, 'federationId1', businessAdminUser,null);
                    groupMemberList = [ SELECT id FROM GroupMember WHERE GroupId = :g.id AND UserOrGroupId = :baUser.id ];
                    System.debug( groupMemberList );
                    System.assert( groupMemberList.size() == 1) ;
                } catch (exception ex){
                    system.debug('Try two #####################');
                    system.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
                    system.debug('#####################');
                }
            //}
        Test.stopTest();
    }        
    /*static testMethod void testManualQueueAssignemntTest() {
        AutocreatedRegHandler1559890732239 handler = new AutocreatedRegHandler1559890732239();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuserss@example.org', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        //String pid =[Select Id from Profile Where name ='System Administrator'].Id ;
        Map<string,String> businessAdminUser=  new Map<String, String>
            {'language' => 'en_US' ,
            'User.UserName'=>'PWMBusinessAdmin@FRB.com' ,
            'User.LastName'=>'Admin',
            'User.FirstName'=>'PWM Business User',
            'User.Email'=>'admin@FRB.com',
            'User.Alias'=>'pwmBA',
            'User.CommunityNickname'=>'asdjasxxgdjhahsdhaqq',
            'User.TimeZoneSidKey'=>'America/Los_Angeles',
            'User.LocaleSidKey'=>'en_US',
            'User.EmailEncodingKey'=>'UTF-8',
            'User.IsActive'=>'true',
            'memberOf'=>'gg_app_CLM_PWM_Business_Admin',
            'federationIdentifier'=>'federationId1',
            'User.LanguageLocaleKey'=>'en_US' 
            };     
            String uid = '';
            User baUser;
            try {
                
                baUser = handler.createUser(null,null,null,'federationId1', businessAdminUser  ,null);
                uid = baUser.id;
                System.assert(uid != null);                    
                
            } catch(Exception e){
                system.debug('#####################');
                system.debug(e.getMessage() + ' ' + e.getStackTraceString());
                system.debug('#####################');
            }
            //System.runAs(baUser) {
                Group g = new Group( Type = 'Queue', Name = 'GJ-PWM-Test Queue' );
                insert g;
                QueueSObject q = new QueueSObject( QueueId = g.id , SObjectType = 'Case');
                insert q;
                System.assert( q.id != null ) ;
                GroupMember gm = new GroupMember( GroupId = g.id , UserOrGroupId = baUser.id );
                insert gm;
                System.assert( uid != null );
                try {
                    businessAdminUser.put('memberOf','gg_app_CLM_Eagle_Role_LOS_Associate');
                    //businessAdminUser.put( 'User.IsActive','false');
                    handler.updateUser(baUser.id,null,null,null, 'federationId1', businessAdminUser,null);
                    List<GroupMember> groupMemberList = [ SELECT id FROM GroupMember WHERE GroupId = :g.id AND UserOrGroupId = :baUser.id ];
                    System.debug( 'GroupMember' + groupMemberList );
                    System.assert( groupMemberList.isEmpty());
                } catch (exception ex){
                    system.debug('Try two #####################');
                    system.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
                    system.debug('#####################');
                }
            //}
    }*/    
    static testMethod void testPermissionSets() {
        AutocreatedRegHandler1559890732239 handler = new AutocreatedRegHandler1559890732239();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuserss@example.org', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        //String pid =[Select Id from Profile Where name ='System Administrator'].Id ;
        Map<string,String> tempUser=  new Map<String, String>
        {'language' => 'en_US' ,
            'User.UserName'=>'testasxxkdhjkaqqq@sdjkfhsjd.com' ,
            'User.LastName'=>'asdjhgasjhd',
            'User.FirstName'=>'asdjhgasjhdsxxs',
            'User.Email'=>'askdasgdxxhgasqa@sdjkfd.com',
            'User.Alias'=>'asxq',
            'User.CommunityNickname'=>'asdjasxxgdjhahsdhaqq',
            'User.TimeZoneSidKey'=>'America/Los_Angeles',
            'User.LocaleSidKey'=>'en_US',
            'User.EmailEncodingKey'=>'UTF-8',
            'User.IsActive'=>'true',
            'memberOf'=>'gg_app_CLM_System_Admin,gg_app_nCino_ROLE_TEST,gg_app_nCino_group_TEST',
            'federationIdentifier'=>'aasdjhgasxxhd',
            'User.LanguageLocaleKey'=>'en_US' 
            }; 
                
            String uid = '';
                try{
                    
                    
                    User u = handler.createUser(null,null,null,'aasdjhgasxxhd', tempUser ,null);
                    
                    
                    uid = u.id;
                    System.assert(uid != null);
                    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                                                   'testNewFirst testNewLast', 'testuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
                                                   null, new Map<String, String>{'language' => 'en_US'});
                    handler.updateUser(uid,null,null,null, 'aasdjhgasxxhd', tempUser,null);
                    
                    User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
                    
                    
                }catch(Exception e){
                    system.debug('#####################');
                    system.debug(e.getMessage() + ' ' + e.getStackTraceString());
                    system.debug('#####################');
                }
                try{
                    User updatedUser2 = [SELECT userName, email, firstName, lastName, alias FROM user WHERE profile.name = 'System Administrator' LIMIT 1];
                    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                                                   'testNewFirst testNewLast', 'testuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
                                                   null, new Map<String, String>{'language' => 'en_US'});
                    handler.updateUser(updatedUser2.id,null,null,null, 'aasdjhgasxxhd', tempUser,null);
                } catch (exception ex){
                    system.debug('Try two #####################');
                    system.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
                    system.debug('#####################');
                }
    }
    static testMethod void testPermissionSetUpdate() {
        AutocreatedRegHandler1559890732239 handler = new AutocreatedRegHandler1559890732239();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuserss@example.org', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        //String pid =[Select Id from Profile Where name ='System Administrator'].Id ;
        Map<string,String> tempUser=  new Map<String, String>
        {'language' => 'en_US' ,
            'User.UserName'=>'testasxxkdhjkaqqq@sdjkfhsjd.com' ,
            'User.LastName'=>'asdjhgasjhd',
            'User.FirstName'=>'asdjhgasjhdsxxs',
            'User.Email'=>'askdasgdxxhgasqa@sdjkfd.com',
            'User.Alias'=>'asxq',
            'User.CommunityNickname'=>'asdjasxxgdjhahsdhaqq',
            'User.TimeZoneSidKey'=>'America/Los_Angeles',
            'User.LocaleSidKey'=>'en_US',
            'User.EmailEncodingKey'=>'UTF-8',
            'User.IsActive'=>'true',
            'memberOf'=>'gg_app_CLM_System_Admin,gg_app_nCino_ROLE_TEST,gg_app_nCino_group_TEST',
            'federationIdentifier'=>'aasdjhgasxxhd',
            'User.LanguageLocaleKey'=>'en_US' 
            }; 
                
            String uid = '';
                
                try{
                    User updatedUser2 = [SELECT userName, email, firstName, lastName, alias FROM user WHERE profile.name = 'System Administrator' LIMIT 1];
                    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                                                   'testNewFirst testNewLast', 'testuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
                                                   null, new Map<String, String>{'language' => 'en_US'});
                    handler.updateUser(updatedUser2.id,null,null,null, 'aasdjhgasxxhd', tempUser,null);
                } catch (exception ex){
                    system.debug('Try two #####################');
                    system.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
                    system.debug('#####################');
                }
    }
    
    static testMethod void testCreateAndUpdateUserWithProfile() {
        AutocreatedRegHandler1559890732239 handler = new AutocreatedRegHandler1559890732239();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        //String pid =[Select Id from Profile Where name ='System Administrator'].Id ;
        Map<string,String> tempUser=  new Map<String, String>
        {'language' => 'en_US' ,
            'User.UserName'=>'testaskdhjkaqqq@sdjkfhsjd.com' ,
            'User.LastName'=>'asdjhgasjhd',
            'User.FirstName'=>'asdjhgasjhdsss',
            'User.Email'=>'askdasgdhgasqa@sdjkfd.com',
            'User.Alias'=>'askdq',
            'User.CommunityNickname'=>'asdjasgdjhahsdhaqq',
            'User.TimeZoneSidKey'=>'America/Los_Angeles',
            'User.LocaleSidKey'=>'en_US',
            'User.EmailEncodingKey'=>'UTF-8',
            'User.IsActive'=>'true',
            'memberOf'=>'gg_app_SalesForce_Profile_System_Admin_R,gg_app_nCino_ROLE_TEST',
            'federationIdentifier'=>'aasdjhgasjhd',
            'User.LanguageLocaleKey'=>'en_US' }; 
                
                
                try{
                    
                    
                    User u = handler.createUser(null,null,null,'aasdjhgasjhd', tempUser ,null);
                    
                    
                    String uid = u.id;
                    System.assert(uid != null);
                    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                                                   'testNewFirst testNewLast', 'testuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
                                                   null, new Map<String, String>{'language' => 'en_US'});
                    handler.updateUser(uid,null,null,null, 'aasdjhgasjhd', tempUser,null);
                    
                    User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
                }catch(Exception e){
                    
                }
    }
    
    static testMethod void testCreateAndUpdateUser() {
        AutocreatedRegHandler1559890732239 handler = new AutocreatedRegHandler1559890732239();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        //String pid =[Select Id from Profile Where name ='Standard User'].Id ;
        Map<string,String> tempUser=  new Map<String, String>
        {'language' => 'en_US' ,
            'User.UserName'=>'testaskdhjkasdj@sdjkfhsjd.com' ,
            'User.LastName'=>'asdjhgasjhd',
            'User.Email'=>'askdasgdhgas@sdjkfd.com',
            'User.Alias'=>'askda',
            'User.CommunityNickname'=>'asdjasgdjhahsdhasd',
            'User.TimeZoneSidKey'=>'America/Los_Angeles',
            'User.LocaleSidKey'=>'en_US',
            'User.EmailEncodingKey'=>'UTF-8',
            'User.IsActive'=>'true',
            'memberOf'=>'gg_app_SalesForce_Profile_System_Admin_R,gg_app_nCino_ROLE_TEST',
            'federationIdentifier'=>'aasdjhgasjhd',
            'User.LanguageLocaleKey'=>'en_US' }; 
                
                
                try{
                    
                    
                    User u = handler.createUser(null,null,null,'aasdjhgasjhd', tempUser ,null);
                    
                    
                    String uid = u.id;
                    System.assert(uid != null);
                    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                                                   'testNewFirst testNewLast', 'testuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
                                                   null, new Map<String, String>{'language' => 'en_US'});
                    handler.updateUser(uid,null,null,null, 'aasdjhgasjhd', tempUser,null);
                    
                    User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
                }catch(Exception e){
                    
                }
    }
    
    static testMethod void testCreateAndUpdateUserPermissions() {
        AutocreatedRegHandler1559890732239 handler = new AutocreatedRegHandler1559890732239();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        //String pid =[Select Id from Profile Where name ='Standard User'].Id ;
        Map<string,String> tempUser=  new Map<String, String>
        {'language' => 'en_US' ,
            'User.UserName'=>'testaskdhjkasdj@sdjkfhsjd.com' ,
            'User.LastName'=>'asdjhgasjhd',
            'User.Email'=>'askdasgdhgas@sdjkfd.com',
            'User.Alias'=>'askda',
            'User.CommunityNickname'=>'asdjasgdjhahsdhasd',
            'User.TimeZoneSidKey'=>'America/Los_Angeles',
            'User.LocaleSidKey'=>'en_US',
            'User.EmailEncodingKey'=>'UTF-8',
            'User.IsActive'=>'true',
            'memberOf'=>'gg_app_nCino_Profile_Eagle_LOS_ELC_RW,gg_app_nCino_ROLE_TEST,gg_app_nCino_Permission_Eagle_LOS_DocMan_Create_Placeholder',
            'federationIdentifier'=>'aasdjhgasjhd',
            'User.LanguageLocaleKey'=>'en_US' }; 
                
                
                try{
                    
                    
                    User u = handler.createUser(null,null,null,'aasdjhgasjhd', tempUser ,null);
                    
                    
                    String uid = u.id;
                    System.assert(uid != null);
                    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                                                   'testNewFirst testNewLast', 'testuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
                                                   null, new Map<String, String>{'language' => 'en_US'});
                    handler.updateUser(uid,null,null,null, 'aasdjhgasjhd', tempUser,null);
                    
                    User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
                }catch(Exception e){
                    
                }
    }
    
    static testMethod void testCreateAndUpdateRemoveUserPermissions() {
        AutocreatedRegHandler1559890732239 handler = new AutocreatedRegHandler1559890732239();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        //String pid =[Select Id from Profile Where name ='Standard User'].Id ;
        Map<string,String> tempUser=  new Map<String, String>
        {'language' => 'en_US' ,
            'User.UserName'=>'testaskdhjkasdj@sdjkfhsjd.com' ,
            'User.FirstName'=>'asdjhgasjhd',
            'User.LastName'=>'asdjhgasjhd',
            'User.Email'=>'askdasgdhgas@sdjkfd.com',
            'User.CommunityNickname'=>'asdjasgdjhahsdhasd',
            'User.IsActive'=>'true',
            'memberOf'=>'gg_app_CLM_Eagle_Role_LOS_Sales',
            'federationIdentifier'=>'aasdjhgasjhd',
            'User.LanguageLocaleKey'=>'en_US' }; 
                
                
                try{   
                    User u = handler.createUser(null,null,null,'aasdjhgasjhd', tempUser ,null);
                    
                    
                    String uid = u.id;
                    System.assert(uid != null);
                    sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                                                   'testNewFirst testNewLast', 'testuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
                                                   null, new Map<String, String>{'language' => 'en_US'});
                    
                    tempUser=  new Map<String, String>
                    {'language' => 'en_US' ,
                        'User.UserName'=>'testaskdhjkasdj@sdjkfhsjd.com' ,
                        'User.FirstName'=>'asdjhgasjhd',
                        'User.LastName'=>'asdjhgasjhd',
                        'User.Email'=>'askdasgdhgas@sdjkfd.com',
                        'User.Alias'=>'askda',
                        'User.CommunityNickname'=>'asdjasgdjhahsdhasd',
                        'User.TimeZoneSidKey'=>'America/Los_Angeles',
                        'User.LocaleSidKey'=>'en_US',
                        'User.EmailEncodingKey'=>'UTF-8',
                        'User.IsActive'=>'true',
                        'memberOf'=>'gg_app_CLM_Eagle_Role_LOS_Sales',
                        'federationIdentifier'=>'aasdjhgasjhd',
                        'User.LanguageLocaleKey'=>'en_US' }; 
                            handler.updateUser(uid,null,null,null, 'aasdjhgasjhd', tempUser,null);
                    
                    User updatedUser = [SELECT userName, email, firstName, lastName, alias, profileId FROM user WHERE id=:uid];
                    List<PermissionSetAssignment> psassigned = [select PermissionSet.Name, PermissionSet.Label, Assignee.Name, Id, PermissionSetId, SystemModstamp from PermissionSetAssignment Where AssigneeId =:uid];
                    for(PermissionSetAssignment psa : psassigned){
                        System.debug('perm set: ' + psa.PermissionSet.Name + 'to user: ' + psa.Assignee.Name);
                        System.debug('perm set label: ' + psa.PermissionSet.Label + 'to user: ' + psa.Assignee.Name);
                        System.debug('perm set id: ' + psa.PermissionSetId + 'to user: ' + psa.Assignee.Name);
                    }
                    AD_Group_Permission_Mapping__mdt profileMap = [SELECT MasterLabel, AD_Group_Name__c, Security_Group_Id__c, Salesforce_Security_Name__c, AD_Group_Type__c  
                                                                   FROM AD_Group_Permission_Mapping__mdt WHERE AD_Group_Name__c ='gg_app_nCino_Profile_Eagle_LOS_ELC_RW']; 
                    
                    // System.assertEquals(updatedUser.ProfileId, profileMap.Security_Group_Id__c);
                    // System.assertEquals(updatedUser.Email, tempUser.get('User.Email') );
                }catch(Exception e){
                    System.debug('exception');
                }
    }
    static testMethod void testCreateAutoRabit(){}
    
   @istest
    static void TestARmethod(){
    //some test logic
    //test line 2
    }
     @istest
    static void TestARmethodT(){
    //some test logic
    //test line 2
    }
    
    @istest
    static void T2DevworkOnSameClass(){
    //some test logic
    
    }
}
