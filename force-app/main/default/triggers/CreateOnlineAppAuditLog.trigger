trigger CreateOnlineAppAuditLog on Online_Application_Audit__e (after insert) {
    List<Online_Application_Audit_Logs__c> listToInsert = new List<Online_Application_Audit_Logs__c>();
    for (Online_Application_Audit__e o : Trigger.new) {
        Online_Application_Audit_Logs__c onlineAppLog = new Online_Application_Audit_Logs__c(Audit_Text__c = o.Audit_Text__c, Primary_Object_Id__c = o.Primary_Object_Id__c);
        listToInsert.add(onlineAppLog);
    }

    if(ListToInsert.size() > 0) {
        Database.insert(ListToInsert);
    }
    
}