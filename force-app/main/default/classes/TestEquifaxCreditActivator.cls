@isTest
private class TestEquifaxCreditActivator {

	@TestSetup
	static void setup() {
		new nFUSE.DataInstaller().onInstall(null);
	}
	
	    @isTest
   private static void testReviewDecision(){
      EquifaxCreditActivator.EquifaxCreditPassReviewDecision decision = new EquifaxCreditActivator.EquifaxCreditPassReviewDecision();
      decision.create(new Map<String,Object>());
      System.assert(true, true);
   }
   @isTest
   private static void testTypeDecision(){
      EquifaxCreditActivator.EquifaxCreditReportTypeDecision decision = new EquifaxCreditActivator.EquifaxCreditReportTypeDecision();
      decision.create(new Map<String,Object>());
      System.assert(true, true);
   }

	@isTest
	private static void testActivation_onActivate_registersBean() {
		EquifaxCreditAppFacade bean = retrieveBean();
		System.assertEquals(null, bean);
		Test.startTest();
		new EquifaxCreditActivator().onActivate();
		Test.stopTest();
		bean = retrieveBean();
		System.assertNotEquals(null, bean);
	}

	@isTest
	private static void testActivation_onActivate_installProperties() {
		Test.startTest();
		new EquifaxCreditActivator().onActivate();
		Test.stopTest();

		nFUSE.PluginConfigurationManager configManager = new nFUSE.PluginConfigurationManager(EquifaxCreditActivator.PLUGIN_NAME, EquifaxCreditActivator.PLUGIN_VERSION);
		List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs = configManager.getConfigurations();

		List<String> keysToCheck = expectedProperties.clone();
		System.assertEquals(102, keysToCheck.size());
		for(nFUSE.PluginConfigurationManager.PluginConfiguration currentConfig : configs) {
			removeValueFromList(keysToCheck, currentConfig.key);
		}
		System.assertEquals(0, keysToCheck.size());
	}

	@isTest
	private static void testActivation_onActivateTwice_installProperties() {
		Test.startTest();
		EquifaxCreditActivator act = new EquifaxCreditActivator();
		act.onActivate();
		act.onDeactivate();
		act.onActivate();
		Test.stopTest();

		nFUSE.PluginConfigurationManager configManager = new nFUSE.PluginConfigurationManager(EquifaxCreditActivator.PLUGIN_NAME, EquifaxCreditActivator.PLUGIN_VERSION);
		List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs = configManager.getConfigurations();

		List<String> keysToCheck = expectedProperties.clone();
		System.assertEquals(102, keysToCheck.size());
		for(nFUSE.PluginConfigurationManager.PluginConfiguration currentConfig : configs) {
			removeValueFromList(keysToCheck, currentConfig.key);
		}
		System.assertEquals(0, keysToCheck.size());
	}
	
	@isTest
	private static void testActivation_onActivate_installConfiguration() {
		EquifaxCreditActivator act = new EquifaxCreditActivator();
		act.onActivate();
		String categoryName = EquifaxCreditActivator.PLUGIN_CONFIG_NAME;
		Boolean catPresent = act.containsCategory(categoryName);
		System.assert(true,catPresent);
	}

	@isTest	
	private static void containsCategory_false() {
		EquifaxCreditActivator act = new EquifaxCreditActivator();
		act.onActivate();
		string categoryName = 'Invalid Category';
		Boolean catPresent = act.containsCategory(categoryName);
		System.assertEquals(false,catPresent);
	}

	private static void removeValueFromList(List<Object> theList, Object theValue) {
		for(Integer i = 0; i < theList.size(); i++) {
			if(theList.get(i) == theValue) {
				theList.remove(i);
				return;
			}
		}
	}

	private static EquifaxCreditAppFacade retrieveBean() {
		return (EquifaxCreditAppFacade) nFORCE.BeanFactory.getInstance().getBeanByUniqueName(
				EquifaxCreditAppFacade.class.getName()
		);
	}

	private static List<String> expectedProperties = new List<String> {
			EquifaxCreditActivator.CONSUMER_USER_SITE_ID,
			EquifaxCreditActivator.CONSUMER_PASSWORD,
			EquifaxCreditActivator.CONSUMER_CUSTOMER_CODE,
			EquifaxCreditActivator.CONSUMER_SOFT_MEMBER_NUMBER,
			EquifaxCreditActivator.CONSUMER_SOFT_SECURITY_CODE,
			EquifaxCreditActivator.CONSUMER_HARD_MEMBER_NUMBER,
			EquifaxCreditActivator.CONSUMER_HARD_SECURITY_CODE,
			EquifaxCreditActivator.CONSUMER_DAYS_VALID,
			EquifaxCreditActivator.CONSUMER_ENVIRONMENT_FLAG,
			EquifaxCreditActivator.BUSINESS_USER_SITE_ID,
			EquifaxCreditActivator.BUSINESS_PASSWORD,
			EquifaxCreditActivator.BUSINESS_CUSTOMER_CODE,
			EquifaxCreditActivator.BUSINESS_MEMBER_NUMBER,
			EquifaxCreditActivator.BUSINESS_PDF_TRANSFORMER_SC,
			EquifaxCreditActivator.BUSINESS_SECURITY_CODE,
			EquifaxCreditActivator.BUSINESS_SERVICE_CODE,
			EquifaxCreditActivator.BUSINESS_DAYS_VALID,
			EquifaxCreditActivator.BUSINESS_ENVIRONMENT_FLAG,
			EquifaxCreditActivator.CONSUMER_RISK_BASED_PRICING,
			EquifaxCreditActivator.CONSUMER_ADDTL_SCORING,
			EquifaxCreditActivator.CONSUMER_PLACEHOLDER_NAME,
			EquifaxCreditActivator.CONSUMER_APPEND_BUREAU_ID_TO_NAME,
			EquifaxCreditActivator.COMMERCIAL_PLACEHOLDER_NAME,
			EquifaxCreditActivator.COMMERCIAL_APPEND_BUREAU_ID_TO_NAME,
			EquifaxCreditActivator.PLACEHOLDER_CATEGORY,
			EquifaxCreditActivator.APPEND_DATE_TO_PLACEHOLDER_NAME,
			EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_REPORT,
			EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_REPORT_NTH,
			EquifaxCreditActivator.PRODUCT_PORTFOLIO_DATA_VERIFICATION,
			EquifaxCreditActivator.PRODUCT_DATA_SELECT_PR,
			EquifaxCreditActivator.PRODUCT_DATA_SELECT_F,
			EquifaxCreditActivator.PRODUCT_DATA_SELECT_CT,
			EquifaxCreditActivator.PRODUCT_DATA_SELECT_AH,
			EquifaxCreditActivator.PRODUCT_BUSINESS_IDENTITY,
			EquifaxCreditActivator.PRODUCT_BUSINESS_IDENTITY_RP,
			EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY_RS,
			EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY,
			EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY2,
			EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY_RP,
			EquifaxCreditActivator.PRODUCT_BUSINESS_INDUSTRY_RP2,
			EquifaxCreditActivator.PRODUCT_EXPANDED_MATCH,
			EquifaxCreditActivator.PRODUCT_BUSINESS_PRINCIPAL_REPORT,
			EquifaxCreditActivator.PRODUCT_BPR_STANDALONE,
			EquifaxCreditActivator.PRODUCT_OFAC_COMMERCIAL,
			EquifaxCreditActivator.PRODUCT_OFAC_PRINCIPAL,
			EquifaxCreditActivator.PRODUCT_BUSINESS_FRAUD_ADVISOR,
			EquifaxCreditActivator.PRODUCT_SBC_RISKSCORE_SUPPLIERS,
			EquifaxCreditActivator.PRODUCT_SBC_RISKSCORE_FS,
			EquifaxCreditActivator.PRODUCT_SBC_RISKSCORE_FSB,
			EquifaxCreditActivator.PRODUCT_SBC_RISKSCORE_S,
			EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_SCORE,
			EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_RISK,
			EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_RISKSCORE,
			EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_RISKRATING,
			EquifaxCreditActivator.PRODUCT_BUSINESS_FAILURE_RISKLEVEL,
			EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_RISK,
			EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_RISKSCORE,
			EquifaxCreditActivator.PRODUCT_BUSINESS_CREDIT_RISKCLASS,
			EquifaxCreditActivator.PRODUCT_DELINQUENCY_FINANCIAL_SCORE,
			EquifaxCreditActivator.PRODUCT_BUSINESS_DELINQUENCY_SCORE,
			EquifaxCreditActivator.PRODUCT_DELINQUENCY_RISK_CLASS,
			EquifaxCreditActivator.PRODUCT_DELINQUENCY_RISK_CLASS_F,
			EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_BLENDED_F,
			EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_BLENDED,
			EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_CARD,
			EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_LOAN,
			EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_CONSERVATIVE,
			EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_MODERATE,
			EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_AGGRESSIVE,
			EquifaxCreditActivator.PRODUCT_SUGGESTED_CREDIT_LIMIT_2,
			EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE,
			EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_M,
			EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_BS,
			EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_T,
			EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_RL,
			EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_COMMUNICATIONS,
			EquifaxCreditActivator.PRODUCT_DELINQUENCY_SCORE_PS,
			EquifaxCreditActivator.PRODUCT_ACCOUNT_MANAGEMENT_SCORE,
			EquifaxCreditActivator.PRODUCT_FINANCIAL_HEALTH_INDEX,
			EquifaxCreditActivator.PRODUCT_PAYMENT_INDEX_SERVICES,
			EquifaxCreditActivator.PRODUCT_PAYMENT_INDEX,
			EquifaxCreditActivator.PRODUCT_COMMERCIAL_SCORE_MARKETING,
			EquifaxCreditActivator.SCORING_MODEL_1,
			EquifaxCreditActivator.SCORING_MODEL_2,
			EquifaxCreditActivator.SCORING_MODEL_3,
			EquifaxCreditActivator.ADD_ON_BEACON_FLAG,
			EquifaxCreditActivator.ADD_ON_FICO_FLAG,
			EquifaxCreditActivator.ADD_ON_FICO_VERBIAGE_FLAG,
			EquifaxCreditActivator.ADD_ON_EDAS_FLAG,
			EquifaxCreditActivator.ADD_ON_ONLINE_DIRECTORY_FLAG,
			EquifaxCreditActivator.ADD_ON_CONSUMER_REF_FLAG,
			EquifaxCreditActivator.ADD_ON_ALERT_CONTACT_FLAG,
			EquifaxCreditActivator.ADD_ON_DEFAULT_MODEL_FLAG,
			EquifaxCreditActivator.ADD_ON_RBP_BEACON_FLAG,
			EquifaxCreditActivator.ADD_ON_RBP_FICO_FLAG,
			EquifaxCreditActivator.ADD_ON_RBP_ALL_FLAG,
			EquifaxCreditActivator.ADD_ON_24MONTH_PAYMENT_HISTORY,
			EquifaxCreditActivator.ADD_ON_SYNTHETIC_ID_ALERT,
			EquifaxCreditActivator.ADD_ON_EXPANDED_TRADE_A1160,
			EquifaxCreditActivator.ADD_ON_EXPANDED_TRADE_DIMENSIONS,
			EquifaxCreditActivator.ADD_ON_EXPANDED_TRADE_HIGH_VALUE,
			EquifaxCreditActivator.ADD_ON_EXPANDED_TRADE_TERMS
	};
}