global class WorkflowAuditEventUtility{

    @InvocableMethod
    global static void createWorkFlowAuditEvent(List <WorkflowAuditInputParams> inputs){
        for(WorkflowAuditInputParams c : inputs){
            new WorkflowAuditEventUtility(c.primaryObjectId, c.workflowType, c.workflowStage, c.processType, c.auditText, c.interfaceContext);
        }
    }

    global WorkflowAuditEventUtility(String primaryObjectId, String workflowType, String workflowStage, String processType, String auditLog, String interfaceContext){

        Workflow_Audit_Log__e workflowAuditLog = new Workflow_Audit_Log__e(Primary_Object_ID__c = primaryObjectId, Workflow_Type__c = workflowType, Workflow_Stage__c = workflowStage, Process_Type__c = processType, Audit_Text__c = auditLog, Interface_Context__c = interfaceContext);

        // Call method to publish events
        Database.SaveResult result;

        try{
            result = EventBus.publish(workflowAuditLog);
        }catch(Exception e){
            System.debug('Failed to create Workflow Audit platform event.  Primary Object Id: ' + primaryObjectId + ', Audit Log: ' + auditLog + ', Workflow Type: ' + workflowType + ', Workflow Stage: ' + workflowStage + ', Process Type: ' + processType + ', Interface Context: ' + interfaceContext);
        }
    }

    @TestVisible
    global class WorkflowAuditInputParams {
        @invocableVariable(
            required = true 
            label = 'Primary Object Id'
            description = 'Primary object ID for process which originated this call'
        )
        global String primaryObjectId;

        @invocableVariable(
            required = true 
            label = 'Workflow Type'
            description = 'Workflow type which originated this call'
        )
        global String workflowType;

        @invocableVariable(
            required = true 
            label = 'Workflow Stage'
            description = 'Workflow stage which originated this call'
        )
        global String workflowStage;
        
        @invocableVariable(
            required = true 
            label = 'Process Type'
            description = 'Process type which originated this call'
        )
        global String processType;

        @invocableVariable(
            required = true 
            label = 'Audit Text'
            description = 'Audit text to be logged in Workflow Audit'
        )
        global String auditText;

        @invocableVariable(
            required = true 
            label = 'Interface Context'
            description = 'Interface context which originated this call'
        )
        global String interfaceContext;
    }
}