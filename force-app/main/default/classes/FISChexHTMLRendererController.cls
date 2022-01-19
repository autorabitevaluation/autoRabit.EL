public class FISChexHTMLRendererController {
    
    @TestVisible private class XFISChexHTMLControllerContentVersionIdNotProvidedException extends Exception {}  
    @TestVisible private class XFISChexHTMLControllerContentVersionIdNotFoundException extends Exception {}  
    
    @TestVisible
    private static Boolean forceZeroDocumentStoreIndices = false;
    @TestVisible
    private static Boolean forceZeroDocumentStores = false;
    @TestVisible
    private static Boolean forceZeroContentVersions = false;
    
    public String HTMLInjected { get;set; }
    
    public FISChexHTMLRendererController(){
        //default constructor
        //get the necessary data out of the querystring
        //String resourceOverride = getPageParam('resourceOverride'); //this enables customization through the override
        //if(String.isBlank(resourceOverride)) resourceOverride = 'EXPRN_EXPSTYLENEW_RelativeLinks';
        
        String locationOverride = getPageParam('location'); //this enables customization through the override
        if(String.isBlank(locationOverride)) locationOverride = 'account';
        
        //String resourceBasePath = getResourceURL(resourceOverride);
        
        String reportType = getPageParam('reportType');
        if(String.isBlank(reportType)) reportType = 'HTMLCombo';
        
        String contentVersionId = getPageParam('contentVersionId');
        String placeholderKey = getPageParam('placeholderKey');
        
        if(String.isBlank(contentVersionId) && String.isBlank(placeholderKey)) throw new XFISChexHTMLControllerContentVersionIdNotProvidedException();
        
        //String rootPath = 'premierprofile';
        String rawData = '';
        
        /* keep in case we want to specify report types 
        if(reportType.toLowerCase() == 'htmlcombo'){
            rootPath = 'premierprofile';
        }else if(reportType.toLowerCase() == 'sbcs'){
            rootPath = 'sbcs_v2';
        }else if (reportType.toLowerCase()== 'intelliscore'){
        	rootPath = 'intelliscore';
        	reportType = 'IP'; //may or may not use this
        }else{
            rootPath = 'premierprofile';
        }
        */
        
       // String styleSheetRef = '<?xml-stylesheet type="text/xsl" href="'+ resourceBasePath + '/' + rootPath + '/'+ reportType +'.xslt' +'"?>';
        //String tagToInjectToRootPayload = '<nCinoBaseUrl>'+ resourceBasePath + '/</nCinoBaseUrl>';
        
        if(!String.isBlank(contentVersionId)){
            rawData = getContentFromContentVersion(contentVersionId);
        }else if(!String.isBlank(placeholderKey)){
            contentVersionId = getContentVersionIdFromPlaceholderKey(locationOverride, placeholderKey);
            rawData = getContentFromContentVersion(contentVersionId);
        }
        
    
        //String sourceVariablePath = '<xsl:variable name="baseResourcePath" select="'+ resourceBasePath + '/" />';
        system.debug('rawData ' + rawData);
        this.HTMLInjected = rawData;
        
    }
    
    @testVisible
    private static Map<String,String> getPageParams() {
        return ApexPages.CurrentPage().getParameters();
    }

    @testVisible
    private static String getPageParam(String key) {
        return getPageParams().get(key);
    }
    
    @testVisible
    private static String injectTagToSpecificNode(String xmlAsString, String stringLocator, String stringToInject){
        
        return xmlAsString.replace(stringLocator, stringToInject);
        
    }
    
    @testVisible
    private String getContentFromContentVersion(String id){
        System.Debug('Will attempt to get content version id : ' + id);
        ContentVersion[] versionData = [SELECT VersionData FROM ContentVersion WHERE IsLatest = true AND Id = :id];
        if(versionData.size()==1){
            String afterblob = EncodingUtil.base64Encode(versionData[0].VersionData);
            String blobAsString = EncodingUtil.base64Decode(afterblob).toString();
            return blobAsString;
        }
        throw new XFISChexHTMLControllerContentVersionIdNotFoundException();
    }
    
    @testVisible
    private String getContentVersionIdFromPlaceholderKey(String location, String placeholderKey){
        
        //we only support account and loan locations at this time
        if(location != 'account' && location != 'loan')
            throw new XFISChexHTMLControllerContentVersionIdNotFoundException('Only two docman locations are supported at this time (account and loan). Please access this document from one of the supported locations.');
        
        System.Debug('Will attempt to get content version id from placeholder key : ' + placeholderKey);
        
        String docStoreIndex = '';
        
        if(location == 'account'){
            
            LLC_BI__AccountDocument__c[] accountDocuments = [SELECT Id, LLC_BI__Document_Store_Index__c FROM LLC_BI__AccountDocument__c WHERE Id = :placeholderKey];
        
            if(accountDocuments.size()!=1)//could be zero or more than one
                throw new XFISChexHTMLControllerContentVersionIdNotFoundException('More than one record returned for LLC_BI__AccountDocument__c given placeholder key '+placeholderKey);
            
            docStoreIndex = accountDocuments[0].LLC_BI__Document_Store_Index__c;
                
        }
        if(location == 'loan'){
            
            LLC_BI__LLC_LoanDocument__c[] loanDocuments = [SELECT Id, LLC_BI__Document_Store_Index__c FROM LLC_BI__LLC_LoanDocument__c WHERE Id = :placeholderKey];
        
            if(loanDocuments.size()!=1)//could be zero or more than one
                throw new XFISChexHTMLControllerContentVersionIdNotFoundException('More than one record returned for LLC_BI__LLC_LoanDocument__c given placeholder key '+placeholderKey);
            
            docStoreIndex = loanDocuments[0].LLC_BI__Document_Store_Index__c;
                
        }
        
        LLC_BI__Document_Store_Index__c[] documentStoreIndices = [SELECT Id, LLC_BI__Document_Store__c FROM LLC_BI__Document_Store_Index__c WHERE Id = :docStoreIndex];
        if(documentStoreIndices.size()!=1 || forceZeroDocumentStoreIndices) //could be zero or more than one
            throw new XFISChexHTMLControllerContentVersionIdNotFoundException('More than one record returned for LLC_BI__Document_Store_Index__c given document store index '+docStoreIndex);
        
        LLC_BI__Document_Store__c[] documentStores = [SELECT Id FROM LLC_BI__Document_Store__c WHERE Id = :documentStoreIndices[0].LLC_BI__Document_Store__c];
        //TODO:should never get here if documentStoreIndices was null or greater than 1
        if(documentStores.size()!=1 || forceZeroDocumentStores) //could be zero or more than one
            throw new XFISChexHTMLControllerContentVersionIdNotFoundException('More than one record returned for LLC_BI__Document_Store__c given Id '+documentStoreIndices[0].LLC_BI__Document_Store__c);
        
        Set<Id> newSet = new Set<Id>();
        newSet.add(documentStores[0].Id);
        
        ContentDocumentLink[] docLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :newSet];
        if(docLinks.size()!=1) //could be zero or more than one
            throw new XFISChexHTMLControllerContentVersionIdNotFoundException('More than one record returned for ContentDocumentLink given document store id '+documentStores[0].Id);
          
        ContentVersion[] versions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :docLinks[0].ContentDocumentId Order By CreatedDate DESC LIMIT 1];
        if(versions.size()!=1 || forceZeroContentVersions) //could be zero or more than one
            throw new XFISChexHTMLControllerContentVersionIdNotFoundException('More than one record returned for ContentVersion given document link ContentDocumentId '+docLinks[0].ContentDocumentId);
         
        return versions[0].Id;
        
    }
    
}