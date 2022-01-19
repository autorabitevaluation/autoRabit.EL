public with sharing class MyApplicationController {
 
   public final LLC_BI__Application__c application;
 
    public MyApplicationController() {
        application = [SELECT Id, Name, nPortal__Status__c FROM LLC_BI__Application__c 
                   WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
    }
 
    public LLC_BI__Application__c getApplication() {
        return application;
    }
 
    public PageReference save() {
        update application;
        return null;
    }
}