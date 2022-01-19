global with sharing class EquifaxSendService extends nFUSE.SendService{
    global EquifaxSendService(){
        super();
    }
    
    public override Object preSendRequest(Object request, nFUSE.AMiddlewareMessage msg){
     // if(request instanceof HttpRequest){
     //// this is where we can manipulate the request itself - url, headers, etc
     // }
     return request;
    }
    
    global override nFUSE.AMiddlewareMessage preSendSeam(nFUSE.AMiddlewareMessage message) {
        //NOTE: This is where the custom handling of the response takes place.    
        return new EquifaxMessageGenerator(retrieveKeyValueMap()).GenerateMessage(message);
    }
    
    public override nFUSE.AMiddlewareMessage postSendSeam(nFUSE.AMiddlewareMessage message) {
     //handle the response if this was expected to behave synchronously
     return message;
    }

	@TestVisible
    private Map<String, String> retrieveKeyValueMap(){
	    nFUSE.PluginConfigurationManager configManager = new nFUSE.PluginConfigurationManager(EquifaxCreditActivator.PLUGIN_NAME, EquifaxCreditActivator.PLUGIN_VERSION);
	    Map<String, String> configurationMap = new Map<String, String>();
	    List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs = configManager.getConfigurations();
	    for(nFUSE.PluginConfigurationManager.PluginConfiguration config : configs) {
	        configurationMap.put(config.key, config.value);
	    }
	    return configurationMap;
    }
}