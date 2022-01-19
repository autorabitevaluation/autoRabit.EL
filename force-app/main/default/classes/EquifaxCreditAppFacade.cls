/**
 * Credit AppFacade Extension for Equifax
 */
global with sharing class EquifaxCreditAppFacade extends nFUSE.CreditAppFacade {

	@TestVisible private DocManAttachmentHandler attachmentHandler = new DocManAttachmentHandler();

	/**
	 * Stores Documents returned from the Middleware
	 * @param The external transaction identifier
	 * @param The document name (not used with this plugin)
	 * @param The document content
	 */
	global override void storeDocument(String transactionId, String docName, String docContent) {
		Blob content = Blob.valueOf(docContent);
		attachmentHandler.storeDocument(transactionId, REPORT_NAME, content);
	}

	/**
	 * Alters the outbound middleware message
	 * @param outbound AMiddlewareMessage
	 */
	global override nFUSE.AMiddlewareMessage preCommAdjustments(nFUSE.AMiddlewareMessage message){
		return new EquifaxMessageGenerator(retrieveKeyValueMap()).GenerateMessage(message);
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
	@TestVisible
	private virtual class DocManAttachmentHandler {

		public virtual void storeDocument(String transactionId, String templateName, Blob docContent) {
			nFUSE.DocManAttachment att = new nFUSE.DocManAttachment(transactionId, templateName);
			att.storeDocument(docContent);
		}
	}

	@TestVisible private static String REPORT_NAME = 'Equifax_Credit';
}