public with sharing class GeneratePasswordOrchestrator implements IGeneratePasswordOrchestrator {
    
    @testVisible
    private static Boolean forcePasswordExpirationDateSkip = false;
    
    public class GeneratePasswordOrchestratorException extends Exception {}
    
    @testVisible
    private class ChexCreds {
        public String Username {get;set;}
        public String Password {get;set;}
        public Boolean UseStaging {get;set;}
        public Integer ReminderDaysPriorToExpiration {get;set;}
    }
    
    public GeneratePasswordOrchestrator(){}
    
    @testVisible
    private DateTime GetExpirationDate(ChexCreds creds){
        System.debug(creds.Password);
        String soapMessage = this.GenerateSoapBodyExpirationDate(creds);
        String endpointToUse = creds.UseStaging ? ChexStagingAuthenticationUrl : ChexProductionAuthenticationUrl;
        String responseBody = PerformHttpRequest(endpointToUse,soapMessage);
        String convertedDateTime = '';
        try{
            ChexXmlDom xd = new ChexXmlDom(responseBody);
            ChexXmlDom.Element root = xd.ownerDocument();
            List<ChexXmlDom.element> elements = root.getElementsByPath(RetrievedDatePath);
            if(elements.size() == 0 || elements.size()>1){
                throw new GeneratePasswordOrchestratorException('Could not locate date node in the parsed response.');
            }
            ChexXmlDom.element dateElement = elements[0];
            String dateValueAsString = dateElement.getValue(RetrievedDateNodePath);
            if(String.isBlank(dateValueAsString)){
                throw new GeneratePasswordOrchestratorException('Date node was blank when it was expected to be populated.');
            }
            convertedDateTime = convertChexDateTimeToSalesforceDateTime(dateValueAsString);
        }catch(Exception e){
            throw new GeneratePasswordOrchestratorException(String.format('Failed to parse expiration date response. [Error: {0}] [Response: {1}]', new String[]{ e.getMessage(), responseBody.escapeXml() }));
        }
        
        return DateTime.parse(convertedDateTime);
    }
    
    public DateTime GetExpirationDate(){
        ChexCreds creds = this.GetConfigurationSettings();
        return this.GetExpirationDate(creds);
    }
    
    @testVisible
    private String convertChexDateTimeToSalesforceDateTime(String chexDateTime){
        //parse the date here
        //existing format is 13-mar-2019 08:33:07
        List<String> splitList = chexDateTime.splitByCharacterType();
        
        String days = splitList[0];
        String month = splitList[2];
        String year = splitList[4];
        String hours = splitList[6];
        String minutes = splitList[8];
        String seconds = splitList[10];
        
        if(month.toLowerCase() == 'jan'){
            month = '01';
        }else if(month.toLowerCase() == 'feb'){
            month = '02';
        }else if(month.toLowerCase() == 'mar'){
            month = '03';
        }else if(month.toLowerCase() == 'apr'){
            month = '04';
        }else if(month.toLowerCase() == 'may'){
            month = '05';
        }else if(month.toLowerCase() == 'jun'){
            month = '06';
        }else if(month.toLowerCase() == 'jul'){
            month = '07';
        }else if(month.toLowerCase() == 'aug'){
            month = '08';
        }else if(month.toLowerCase() == 'sep'){
            month = '09';
        }else if(month.toLowerCase() == 'oct'){
            month = '10';
        }else if(month.toLowerCase() == 'nov'){
            month = '11';
        }else if(month.toLowerCase() == 'dec'){
            month = '12';
        }else{
            throw new GeneratePasswordOrchestratorException('Unsupported Month ' + month);
        }
        return month + '/' + days + '/' + year + ' ' + (Integer.valueOf(hours) >= 12 ? String.valueOf(Integer.valueOf(hours)-12) : hours) + ':' + minutes + (Integer.valueOf(hours) >= 12 ? ' PM' : ' AM');
        //return year + '-' + month + '-' + days + 'T' + hours + ':' + minutes + ':' + seconds +'Z';
    }
    
    public String AutoGeneratePassword(){
        ChexCreds creds = this.GetConfigurationSettings();
        
        String soapMessage = this.GenerateSoapBodyAutoGeneratePassword(creds);
        String endpointToUse = creds.UseStaging ? ChexStagingAuthenticationUrl : ChexProductionAuthenticationUrl;
        String responseBody = PerformHttpRequest(endpointToUse,soapMessage);
        //String responseBodySuccess = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><changepassV002Response xmlns="urn:fisauthentication"><changepassReturnV002 xmlns=""><error xsi:nil="true"/><message>The password has been changed to alsekflasd and it will be effective immediately.</message><result>true</result><newPassword>true</newPassword></changepassReturnV002></changepassV002Response></soapenv:Body></soapenv:Envelope>';
        //String responseBodyFailure = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><changepassV002Response xmlns="urn:fisauthentication"><changepassReturnV002 xmlns=""><error>This is the detailed error.</error><message>There was a problem.</message><result>anything</result><newPassword></newPassword></changepassReturnV002></changepassV002Response></soapenv:Body></soapenv:Envelope>';
        String pwdAsString = '';
        String errorAsString = '';
        String messageAsString = '';
        String resultAsString = '';
        try{
            
            ChexXmlDom xd = new ChexXmlDom(responseBody);
            ChexXmlDom.Element root = xd.ownerDocument();
            List<ChexXmlDom.element> elements = root.getElementsByPath(UpdatedPasswordPath);
            if(elements.size() == 0 || elements.size()>1){
                throw new GeneratePasswordOrchestratorException('Could not locate password node in the parsed response.');
            }
            ChexXmlDom.element pwdElement = elements[0];
            
            errorAsString = pwdElement.getValue(UpdatedPasswordErrorNodePath);
            messageAsString = pwdElement.getValue(UpdatedPasswordMessageNodePath);
            resultAsString = pwdElement.getValue(UpdatedPasswordResultNodePath);
            
            System.debug(messageAsString);
            
            if(resultAsString.toLowerCase() != 'true'){
                throw new GeneratePasswordOrchestratorException('There was an error automatically generating the password. ' + errorAsString);
            }
            
            pwdAsString = pwdElement.getValue(UpdatedPasswordNodePath);
            if(String.isBlank(pwdAsString)){
                throw new GeneratePasswordOrchestratorException('Password node was blank when it was expected to be populated.');
            }
            
        }catch(Exception e){
            throw new GeneratePasswordOrchestratorException(String.format('Failed to parse password update response. [Error: {0}] [Response: {1}]', new String[]{ e.getMessage(), responseBody.escapeXml() }));
        }
        
        creds.Password = pwdAsString;
        
        System.debug('New Password is ' + pwdAsString);
        //get the new expiration date as soon as possible in a future method
        DateTime newExpiration = null;
        if(!forcePasswordExpirationDateSkip){
            newExpiration = this.GetExpirationDate(creds);
        }else{
            newExpiration = DateTime.Now().AddDays(1);
        }
        //update the password in the configuration manager
        this.UpdatePluginConfigurationWithNewPassword(pwdAsString);
        //create the reminder
        this.CreateReminder(URL.getSalesforceBaseUrl().toExternalForm(), newExpiration, creds.ReminderDaysPriorToExpiration);
        //shape a nice response for the admin to view
        return String.format(System.Label.ChexSystemsPasswordSuccessMessage, new String[]{ Date.valueOf(newExpiration).format(), String.valueOf(creds.ReminderDaysPriorToExpiration), (messageAsString.length()>0? (messageAsString + ' ') : '') });
    }
    
    @testVisible
    private String PerformHttpRequest(String endpoint, String requestSoapBody){
        try
        {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/soap+xml; charset=utf-8;');
            req.setHeader('SOAPACTION', '""');
            req.setHeader('Host', (new Url(endpoint)).getHost());
            req.setHeader('User-Agent', 'Mozilla/4.0 (compatible; MSIE 6.0; MS Web Services Client Protocol 1.1.4322.573; nCino)');
            req.setTimeout(60000); //timeout after 60 seconds
            req.setEndpoint(endpoint);
            req.setBody(requestSoapBody);
            req.setMethod('POST');
            // Send the request, and return a response
            HttpResponse resp = h.send(req);
            
            // Get the response body
            String responseBody = resp.getBody();
            
            // Do not do anything but send it back
            return responseBody;
            
        }
        catch(Exception e){
            throw new GeneratePasswordOrchestratorException(String.format('Failed to communicate to ChexSystems. [Error: {0}]', new String[]{ e.getMessage() }));
        }
    }
    
    @testVisible
    private String GenerateSoapBodyExpirationDate(ChexCreds creds){
        String template = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns0="urn:fisauthentication"><SOAP-ENV:Header/><SOAP-ENV:Body><ns0:retrievePwdExpdate><in0>{0}</in0><in1>{1}</in1></ns0:retrievePwdExpdate></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        return String.format(template,new String[]{creds.Username,creds.Password});
    }
    
    @testVisible
    private String GenerateSoapBodyAutoGeneratePassword(ChexCreds creds){
        String template = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns0="urn:fisauthentication"><SOAP-ENV:Header/><SOAP-ENV:Body><ns0:changepassV002><in0>{0}</in0><in1>{1}</in1><in2 /><in3>true</in3></ns0:changepassV002></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        return String.format(template,new String[]{creds.Username,creds.Password});
    }
    
    @testVisible
    private ChexCreds GetConfigurationSettings(){
        
        ChexCreds creds = new ChexCreds();
        
        nFUSE.PluginConfigurationManager configManager = new nFUSE.PluginConfigurationManager(FisChexCreditActivator.PLUGIN_NAME, FisChexCreditActivator.PLUGIN_VERSION);
	    Map<String, String> configurationMap = new Map<String, String>();
	    List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs = configManager.getConfigurations();
	    for(nFUSE.PluginConfigurationManager.PluginConfiguration config : configs) {
	        configurationMap.put(config.key, config.value);
	    }
	    
	    creds.Username = configurationMap.get(FisChexCreditActivator.CHEXSYSTEMS_USERNAME);
        creds.Password = configurationMap.get(FisChexCreditActivator.CHEXSYSTEMS_PASSWORD);
        creds.UseStaging = true; //set to true by default
        if(configurationMap.containsKey(FisChexCreditActivator.STAGING_SERVER)){
            creds.UseStaging = (configurationMap.get(FisChexCreditActivator.STAGING_SERVER).toLowerCase() == 'y' ||
                configurationMap.get(FisChexCreditActivator.STAGING_SERVER).toLowerCase() == 'true' || 
                configurationMap.get(FisChexCreditActivator.STAGING_SERVER).toLowerCase() == 'yes' ||
                configurationMap.get(FisChexCreditActivator.STAGING_SERVER).toLowerCase() == '1');
        }
        
        if(!configurationMap.containsKey(FisChexCreditActivator.CHEXSYSTEMS_REMINDDAYSBEFOREEXPIRATION)){
            throw new GeneratePasswordOrchestratorException('The plugin configuration property for "'+FisChexCreditActivator.CHEXSYSTEMS_REMINDDAYSBEFOREEXPIRATION+'" must be populated with a positive number between 91 and 365. nCino recommends setting it to 100.');
        }
        
        Integer daysReminder = Integer.valueOf(configurationMap.get(FisChexCreditActivator.CHEXSYSTEMS_REMINDDAYSBEFOREEXPIRATION));
        
        if(daysReminder < 91 || daysReminder > 365){
            throw new GeneratePasswordOrchestratorException('The plugin configuration property for "'+FisChexCreditActivator.CHEXSYSTEMS_REMINDDAYSBEFOREEXPIRATION+'" must be populated with a positive number between 91 and 365. nCino recommends setting it to 100.');
        }
        
        creds.ReminderDaysPriorToExpiration = daysReminder;
        
        return creds;
        
    }
    
    @testVisible
    private void UpdatePluginConfigurationWithNewPassword(String newPassword){
        List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs = new List<nFUSE.PluginConfigurationManager.PluginConfiguration> {};
		
		nFUSE.PluginConfigurationManager.PluginConfiguration config = new nFUSE.PluginConfigurationManager.PluginConfiguration();
		config.pluginName = FisChexCreditActivator.PLUGIN_NAME;
		config.pluginVersion = FisChexCreditActivator.PLUGIN_VERSION;
		config.category = FisChexCreditActivator.PLUGIN_NAME;
		config.key = FisChexCreditActivator.CHEXSYSTEMS_PASSWORD;
		config.valueDataType = 'String';
		config.value = newPassword;
		config.isEncrypted = true;
		
		configs.add(config);
		//DML
        new nFUSE.PluginConfigurationManager(FisChexCreditActivator.PLUGIN_NAME, FisChexCreditActivator.PLUGIN_VERSION).updateConfigurations(configs);
    }
    
    @testVisible
    private void CreateReminder(String baseUri, DateTime nextExpirationDate, Integer reminderDaysBeforeExpiration){
        Task newTask = new Task(
            Priority = System.Label.ChexSystemsReminderPriority,
            Status = System.Label.ChexSystemsReminderInitialStatus,
            Subject = System.Label.ChexSystemsReminderSubject,
            Description = String.format(System.Label.ChexSystemsReminderCommentTemplate,new String[]{ String.valueOf(reminderDaysBeforeExpiration), baseUri + '/apex/ChexSystemsGeneratePassword'}),
            IsReminderSet = true,
            ReminderDateTime = nextExpirationDate - reminderDaysBeforeExpiration,
            ActivityDate = Date.valueOf(nextExpirationDate)
        );
        //DML
        nFORCE.DmlUtility.insertObj(newTask);
    }

    @testVisible
    private static String
        RetrievedDatePath = '/Envelope/Body/retrievePwdExpdateResponse',
        RetrievedDateNodePath = 'retrieveExpdateReturn',
        UpdatedPasswordPath = '/Envelope/Body/changepassV002Response/changepassReturnV002',
        UpdatedPasswordNodePath = 'newPassword',
        UpdatedPasswordResultNodePath = 'result',
        UpdatedPasswordErrorNodePath = 'error',
        UpdatedPasswordMessageNodePath = 'message',
        ChexStagingAuthenticationUrl = 'https://penleyincqa.penleyinc.com/fissoap1/services/authentication',
		ChexProductionAuthenticationUrl = 'https://soap.penleyinc.com/fissoap1/services/authentication';
}