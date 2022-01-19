global class EquifaxPerformObtainReport extends EquifaxCalloutBase implements Database.Batchable<EquifaxCalloutInputParams>, Database.AllowsCallouts {

    global with sharing class PerformObtainReportResponse{
        public String transactionLogId {get;set;}
        public String transactionLogStatus {get;set;}
        public String vendorStatus {get;set;}
        public String errorMessage {get;set;}
    }
    
    @TestVisible 
    private class BatchableException extends Exception {}
    @TestVisible
    private static Boolean forceTestingException = false;
    @TestVisible
    private static Boolean forceTestingOverrideParams = false;

    List<EquifaxCalloutInputParams> items = new List<EquifaxCalloutInputParams>();

    global EquifaxPerformObtainReport(List<EquifaxCalloutInputParams> items) {this.items = items;}

    global Iterable<EquifaxCalloutInputParams> start(Database.BatchableContext bc) {
        return (Iterable<EquifaxCalloutInputParams>)this.items;
    }
    
    global void execute(Database.BatchableContext BC, List<EquifaxCalloutInputParams> items){
        List<PerformObtainReportResponse> resArr = new List<PerformObtainReportResponse>();
        for(EquifaxCalloutInputParams c : items){
            PerformObtainReportResponse res = new PerformObtainReportResponse();
            try{
                
                if(forceTestingException)
                    throw new BatchableException('forceTestingException');
                
                //use the send service invoker
                //https://github.com/loanlifecycle/integrations-framework-force/blob/release/src/classes/SendServiceInvoker.cls#L111
                //https://ncinodev.atlassian.net/wiki/display/DEV/Send+Service
                
                List<nFUSE.RequestCreditReport.InputParams> params = new List<nFUSE.RequestCreditReport.InputParams>(); //possible namespace issue
                nFUSE.RequestCreditReport.InputParams param = new nFUSE.RequestCreditReport.InputParams(); //possible namespace issue
                
                param.pluginName = 'Equifax_Credit';
                //param.pluginVersion = '1.0';
                //param.transactionLogId = c.externalReferenceId;
                //param.userSalesforceSessionId = c.userSessionId;
                param.accountId = c.relationshipId;
                param.isHardRequest = true;
                
                List<String> props = new List<String>();
                props.add('primary_object_id|'+c.relationshipId);
                props.add('relationshipId|'+c.relationshipId);
                props.add('salesforce_session_id|'+c.userSessionId);
                param.propertyMap = props;
                
                params.add(param);
                
                List<nFUSE.RequestCreditReport.OutputParams> outParams = nFUSE.RequestCreditReport.invoke(params); //possible namespace issue
                
                if(forceTestingOverrideParams)
                    outParams = new List<nFUSE.RequestCreditReport.OutputParams>();
                
                if(outParams.size()==1){
                    res.errorMessage = null;
                    res.transactionLogId = outParams[0].logId;
                    res.transactionLogStatus = null;
                    res.vendorStatus = null;
                }else{
                    res.errorMessage = 'output parameters were not populated.';
                    res.transactionLogId = null;
                    res.transactionLogStatus = null;
                    res.vendorStatus = null;
                }
                
            } catch(Exception ex) {
                res.errorMessage = 'An error occured trying to perform the Credit report call: ' + ex.getMessage();
            }  
    
            resArr.add(res);

        }
        //system.debug(resArr);
    }
    global void finish(Database.BatchableContext BC){}
    
}