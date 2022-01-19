global with sharing class FisDefaultSendService extends nFUSE.SendService {
    
    public FisDefaultSendService(){
        super();
    }
    
    public override Object preSendRequest(Object request, nFUSE.AMiddlewareMessage msg){
        // if(request instanceof HttpRequest){
        //// this is where we can manipulate the request itself - url, headers, etc
        // }
        return request;
    }
    
    public override nFUSE.AMiddlewareMessage preSendSeam(nFUSE.AMiddlewareMessage message) {
        //message manipulation block 
        //DATA-2474
        return new FisMessageGenerator(retrieveKeyValueMap()).GenerateMessage(message);
    }
    
    public override nFUSE.AMiddlewareMessage postSendSeam(nFUSE.AMiddlewareMessage message) {
        //handle the response if this was expected to behave synchronously
        return message;
    }
    
    @TestVisible
    private Map<String, String> retrieveKeyValueMap(){
	    nFUSE.PluginConfigurationManager configManager = new nFUSE.PluginConfigurationManager(FisChexCreditActivator.PLUGIN_NAME, FisChexCreditActivator.PLUGIN_VERSION);
	    Map<String, String> configurationMap = new Map<String, String>();
	    List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs = configManager.getConfigurations();
	    for(nFUSE.PluginConfigurationManager.PluginConfiguration config : configs) {
	        configurationMap.put(config.key, config.value);
	    }
	    return configurationMap;
    }
    
}