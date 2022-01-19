trigger CreateWorkflowAudit on Workflow_Audit_Log__e (after insert) {
    List<Workflow_Audit__c> listToInsert = new List<Workflow_Audit__c>();
    for (Workflow_Audit_Log__e o : Trigger.new) {
        Workflow_Audit__c workflowAudit = new Workflow_Audit__c(
                                                Primary_Object_Id__c = o.Primary_Object_Id__c, 
                                                Workflow_Type__c = o.Workflow_Type__c, 
                                                Workflow_Stage__c = o.Workflow_Stage__c, 
                                                Process_Type__c = o.Process_Type__c, 
                                                Audit_Text__c = o.Audit_Text__c, 
                                                Interface_Context__c = o.Interface_Context__c);
        listToInsert.add(workflowAudit);
    }

    if(ListToInsert.size() > 0) {
        Database.insert(ListToInsert);
    }
    
}