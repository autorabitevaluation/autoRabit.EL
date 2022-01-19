@IsTest
public class TestWorkflowAuditEventUtility {

    @IsTest
    private static void test_createWorkFlowAuditEvent(){
        
        List<WorkflowAuditEventUtility.WorkflowAuditInputParams> inputParams = new List<WorkflowAuditEventUtility.WorkflowAuditInputParams>();
        WorkflowAuditEventUtility.WorkflowAuditInputParams param = new WorkflowAuditEventUtility.WorkflowAuditInputParams();

        param.primaryObjectId = 'testID';
        param.workflowType = 'Online Application';
        param.workflowStage = 'Verifications';
        param.processType = 'Testing';
        param.auditText = 'Relevant Warning';
        param.interfaceContext = 'UnitTest';
        
        inputParams.add(param);
        
        try {
            WorkflowAuditEventUtility.createWorkFlowAuditEvent(inputParams);
            system.assertEquals(true,true);
        } catch(Exception ex) {
            system.assertEquals(true,false);
        }
        
    }
}