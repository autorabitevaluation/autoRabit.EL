public without sharing class ChexsystemsSessionTriggerHandler {
    /* test deploy 
    */
    public static void executeIntegration(Id recordId) {
        List<String> auditTextList = new List<String>();
        nPORTAL__Context__c context = getContext(recordId);
        
        Boolean accountMissingRequiredFields = (context.nPortal__User__r.Account.LLC_BI__Branch__c == null || String.isBlank(context.nPortal__User__r.Account.ChexSystems_Qualifile_Strategy__c));

        LLC_BI__Application__c application = getApplication(context.nPORTAL__Application__c);
        User usr = getUser(context.nPortal__User__c);
        Contact primaryContact = [SELECT Id FROM Contact WHERE AccountId = :context.nPortal__User__r.Account.Id LIMIT 1];
        LLC_BI__Deposit__c deposit = getDeposit(application.Id);
        List<LLC_BI__Legal_Entities__c> entities = getEntities(application.nPORTAL__Account__c);
       
        FisChexCalloutBase.FisChexCalloutInputParams input = new FisChexCalloutBase.FisChexCalloutInputParams();
        input.relationshipId = context.nPortal__User__r.Account.Id;
        input.userSessionId = UserInfo.getSessionId();
        input.requestedByUserId = UserInfo.getUserId();
        
        //Hydrate input params for callout
        List<FisChexCalloutBase.FisChexCalloutInputParams> inputParams = new List<FisChexCalloutBase.FisChexCalloutInputParams>{input};
          system.debug('**' + inputParams);

        // If account is missing required fields for the Chexsystems request,
        // attempt to populate defaults from Chexsystems_Online_App_Default_Settings__c
        if(accountMissingRequiredFields){
            
            Account acct = new Account(
                Id = context.nPortal__User__r.Account.Id,
                ChexSystems_Qualifile_Strategy__c = context.nPortal__User__r.Account.ChexSystems_Qualifile_Strategy__c,
                LLC_BI__Branch__c =context.nPortal__User__r.Account.LLC_BI__Branch__c);

            auditTextList = setDefaultFISChexFields(acct);

            // if(defaultChexSettings.Id != null){

            //     String defaultBranchName = defaultChexSettings.Default_Branch__c;
            //     String chexSystemsStrategy = defaultChexSettings.Default_ChexSystems_Qualifile_Strategy__c;

            //     if(context.nPortal__User__r.Account.LLC_BI__Branch__c == null){
            //         if(String.isNotBlank(defaultBranchName)){
            //             Id branchId;
                    
            //             try{
            //                 //Query LLC_BI__Branch record by Name
            //                 branchId = getBranchId(defaultBranchName);
            //             }catch(Exception e){
            //                 // Might be an unneccessary protection
            //                 auditTextList.add('Failed to query LLC_BI__Branch: ' + e.getMessage());
            //             }
                        
            //             if(branchId != null){
            //                 acct.LLC_BI__Branch__c = branchId;
            //             }else{
            //                 auditTextList.add('Could not locate LLC_BI__Branch record associated to the configured default Branch Name: ' + defaultBranchName + '. Ensure that a valid Branch Name is configured in the Chexsystems_Online_App_Default_Settings__c.Default_Branch__c custom setting.');
            //             }
            //         }else{
            //             auditTextList.add('Branch field lookup on the Account ID, ' + context.nPortal__User__r.Account.Id + ', is null and there is no configured default Branch Name value. Ensure that Chexsystems_Online_App_Default_Settings__c.Default_Branch__c is populated with a valid Branch Name.');
            //         }
            //     }

            //     if(String.isBlank(context.nPortal__User__r.Account.ChexSystems_Qualifile_Strategy__c)){
            //         if(String.isNotBlank(chexSystemsStrategy)){
            //             acct.ChexSystems_Qualifile_Strategy__c = chexSystemsStrategy;
            //         }else{
            //             auditTextList.add('Chexsystems Qualifile Strategy picklist on the Account ID, ' + context.nPortal__User__r.Account.Id + ', is null and there is no configured default value. Ensure that Chexsystems_Online_App_Default_Settings__c.Default_ChexSystems_Qualifile_Strategy__c is populated with a valid ChexSystems_Qualifile_Strategy__c picklist value ');
            //         }
            //     }
                
            //     try{
            //         Database.update(acct);
            //     }catch(Exception e){
            //         auditTextList.add('Error encountered when updating Account with Chexsystems default settings: ' + e.getMessage());
            //     }
            // }else{
            //     auditTextList.add('Chexsystems Online App Default Settings do not exist.');  
            // }
        }

        if(auditTextList.size() > 0){
            String auditTextSerialized = JSON.serialize(auditTextList);
            new WorkflowAuditEventUtility(context.nPortal__User__r.Account.Id, context.nPORTAL__Session__r.Id, context.nPORTAL__Session__r.Fire_Chex_Systems_Formula__c, 'FIS Chexsystems', auditTextSerialized, 'Trigger');
        }
     
        if(context.nPortal__User__r.Account.LLC_BI__Active__c != 'Yes') {
            FisChexObtainReport.obtainReport(inputParams);
        }
    }

    @testVisible
    private static List<String> setDefaultFISChexFields(Account acct){

        List<String> auditTextList = new List<String>();

        Chexsystems_Online_App_Default_Settings__c defaultChexSettings = Chexsystems_Online_App_Default_Settings__c.getOrgDefaults();

        if(defaultChexSettings.Id != null){

            String defaultBranchName = defaultChexSettings.Default_Branch__c;
            String chexSystemsStrategy = defaultChexSettings.Default_ChexSystems_Qualifile_Strategy__c;

            if(acct.LLC_BI__Branch__c == null){
                if(String.isNotBlank(defaultBranchName)){
                    Id branchId;
                
                    try{
                        //Query LLC_BI__Branch record by Name
                        branchId = getBranchId(defaultBranchName);
                    }catch(Exception e){
                        // Might be an unneccessary protection
                        auditTextList.add('Failed to query LLC_BI__Branch: ' + e.getMessage());
                    }
                    
                    if(branchId != null){
                        acct.LLC_BI__Branch__c = branchId;
                    }else{
                        auditTextList.add('Could not locate LLC_BI__Branch record associated to the configured default Branch Name: ' + defaultBranchName + '. Ensure that a valid Branch Name is configured in the Chexsystems_Online_App_Default_Settings__c.Default_Branch__c custom setting.');
                    }
                }
            }

            if(String.isBlank(acct.ChexSystems_Qualifile_Strategy__c)){
                if(String.isNotBlank(chexSystemsStrategy)){
                    acct.ChexSystems_Qualifile_Strategy__c = chexSystemsStrategy;
                }
            }
            
            if(!Test.isRunningTest()){
                try{
                    Database.update(acct);
                }catch(Exception e){
                    auditTextList.add('Error encountered when updating Account with Chexsystems default settings: ' + e.getMessage());
                }
            }
        }else{
            auditTextList.add('Chexsystems Online App Default Settings do not exist.');  
        }

        return auditTextList;
    }
    
    
    
    private static List<LLC_BI__Legal_Entities__c> getEntities(Id acctId) {
        return [SELECT
                        Id,
                        LLC_BI__Loan__r.LLC_BI__Status__c,
                        LLC_BI__Loan__r.LLC_BI__Stage__c,
                        LLC_BI__Loan__r.LLC_BI__Product__c
               FROM
                        LLC_BI__Legal_Entities__c
               WHERE
                        LLC_BI__Account__c = :acctId
               AND
                        LLC_BI__Loan__c != null
               LIMIT 5000];
    }
    
    private static nPORTAL__Context__c getContext(Id sessionId) {
        return [SELECT
                        Id,
                        nPORTAL__Application__c,
                        nPortal__User__c,
                        nPortal__User__r.Account.Id,
                        nPortal__User__r.Account.LLC_BI__Branch__c,
                        nPortal__User__r.Account.ChexSystems_Qualifile_Strategy__c,
                        nPortal__User__r.Account.LLC_BI__Active__c,
                        nPORTAL__Session__r.Fire_Chex_Systems_Formula__c,
                        nPORTAL__Session__r.Id

                FROM
                        nPORTAL__Context__c
                WHERE
                        nPORTAL__Session__c = :sessionId
                LIMIT 1];
    }
    
    private static LLC_BI__Application__c getApplication(Id appId) {
        return [SELECT
                        Id,
                        nPORTAL__Account__c,
                        nPORTAL__Account__r.LLC_BI__Active__c,
                        nPORTAL__Account__r.LLC_BI__Branch__c,
                        nPORTAL__Account__r.ChexSystems_Qualifile_Strategy__c,
                        nPORTAL__Applicant__c
               FROM
                        LLC_BI__Application__c
               WHERE
                        Id = :appId
               LIMIT 1];
    }
    
    private static User getUser(Id contextUserId) {
        return [SELECT
                        Id,
                        ContactId
               FROM
                        User
               WHERE
                        Id = :contextUserId
               LIMIT 1];
    }
    
    private static LLC_BI__Deposit__c getDeposit(Id applicationId) {
        return [SELECT
                        Id,
                        LLC_BI__Product__c
               FROM
                        LLC_BI__Deposit__c
               WHERE
                        LLC_BI__Application__c = :applicationId
               LIMIT 1];
    }
    
    private static Id getBranchId(String defaultBranchName) {
        return [SELECT
                        Id
               FROM
                        LLC_BI__Branch__c
               WHERE
                        Name = :defaultBranchName
               LIMIT 1].Id;
    }
}
