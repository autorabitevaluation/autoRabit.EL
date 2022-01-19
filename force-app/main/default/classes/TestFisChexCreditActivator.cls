@isTest
private class TestFisChexCreditActivator {
	@isTest
    static void setupData(){
        
        //system properties should already exist
        nFORCE__System_Properties__c property1 = new nFORCE__System_Properties__c(Name='aaaa',nFORCE__Category_Name__c='ChexSystems_CreditConfiguration',nFORCE__Is_Active__c=true);
        property1.nFORCE__Key__c = 'Consumer Days Valid';
        property1.nFORCE__Value__c = '30';
        insert property1;
    }
    
    @isTest 
    private static void testActivator_containsCategoryFalse(){
        FisChexCreditActivator expectedFalseReturn = new FisChexCreditActivator();
        expectedFalseReturn.onActivate();
        Boolean result = expectedFalseReturn.containsCategory('notACategory');
        System.assertEquals(false,result);
    }
    
    //original test
    @isTest
   private static void testReviewDecision(){
      FisChexCreditActivator.FisChexCreditPassReviewDecision decision = new FisChexCreditActivator.FisChexCreditPassReviewDecision();
      decision.create(new Map<String,Object>());
      System.assert(true, true);
   }
   
   //original test
   @isTest
   private static void testTypeDecision(){
      FisChexCreditActivator.FisChexCreditReportTypeDecision decision = new FisChexCreditActivator.FisChexCreditReportTypeDecision();
      decision.create(new Map<String,Object>());
      System.assert(true, true);
   }
   
   //original test
	@isTest
	private static void testActivation_onActivate_registersBean() {
		FisChexCreditAppFacade bean = retrieveBean();
		System.assertEquals(null, bean);
		new FisChexCreditActivator().onActivate();
		bean = retrieveBean();
		System.assertNotEquals(null, bean);
	}
	
	//changed
	@isTest
	private static void testActivation_getPropertiesForCategory() {
		FisChexCreditActivator activator = new FisChexCreditActivator();
		activator.onActivate();
		
		Set<String> keys = new Set<String>();
		for(nFUSE.PluginConfigurationManager.PluginConfiguration config : activator.configs) {
			keys.add(config.key);
		}
		System.assert(activator.configs.size()>0);
	}

	//changed
	@isTest
	private static void testActivation_onActivate_installProperties() {
		FisChexCreditActivator activator = new FisChexCreditActivator();
		activator.onActivate();
		
		System.assertEquals(activator.configs.size(), expectedProperties.size());
		
		Set<String> configKeys = new Set<String>();
		for(nFUSE.PluginConfigurationManager.PluginConfiguration config : activator.configs) {
			configKeys.add(config.key);
		}
		
		for(String key : configKeys){
			System.assert(expectedProperties.contains(key));
		}
	}
	
	//original test 
	@isTest
   private static void testActivation_deactivate() {
      Test.startTest();
      new FisChexCreditActivator().onDeactivate();
      Test.stopTest();
      System.assert(true, true);
   }

	//original test
	@isTest
	private static void testActivation_onActivate_installConfiguration_true() {
		FisChexCreditActivator act = new FisChexCreditActivator();
		act.onActivate();
		String categoryName = FisChexCreditActivator.PLUGIN_CONFIG_NAME;
		Boolean catPresent = act.containsCategory(categoryName);
		System.assert(true,catPresent);
	}
	
	//new test
	@isTest
	private static void testActivation_onActivate_installConfiguration_false() {
		FisChexCreditActivator act = new FisChexCreditActivator();
		act.onActivate();
		String falseCategory = 'Not_real';
		Boolean catPresent = act.containsCategory(falseCategory);
		System.assertEquals(false,catPresent);
	}

	//original test
	private static FisChexCreditAppFacade retrieveBean() {
		return (FisChexCreditAppFacade) nFORCE.BeanFactory.getInstance().getBeanByUniqueName(
			FisChexCreditAppFacade.class.getName()
		);
	}
	//insert number of properties in testActivation_onActivate_installProperties method in this file
	private static Set<String> expectedProperties = new Set<String> {
		
		//boiler plate properties
		FisChexCreditActivator.BUSINESS_DAYS_VALID,
		FisChexCreditActivator.CONSUMER_DAYS_VALID,
		FisChexCreditActivator.COMMERCIAL_PLACEHOLDER_NAME,
		FisChexCreditActivator.COMMERCIAL_APPEND_BUREAU_ID_TO_NAME,
		FisChexCreditActivator.CONSUMER_PLACEHOLDER_NAME,
		FisChexCreditActivator.CONSUMER_APPEND_BUREAU_ID_TO_NAME,
		FisChexCreditActivator.PLACEHOLDER_CATEGORY,
		FisChexCreditActivator.APPEND_DATE_TO_PLACEHOLDER_NAME,
		
		//fis specific properties
		FisChexCreditActivator.CHEXSYSTEMS_USERNAME,
		FisChexCreditActivator.CHEXSYSTEMS_PASSWORD,
		FisChexCreditActivator.STAGING_SERVER,
		FisChexCreditActivator.ACQUIRER_IDENTIFIER,
		FisChexCreditActivator.PRODUCT_QUALIFILE,
		FisChexCreditActivator.PRODUCT_CHEXSYSTEMS,
		FisChexCreditActivator.PRODUCT_IDENTITY_MANAGER,
		FisChexCreditActivator.PRODUCT_OFAC,
		FisChexCreditActivator.QUALIFILE_VERSION_NUMBER,
		FisChexCreditActivator.CHEXSYSTEMS_VERSION_NUMBER,
		FisChexCreditActivator.REPORT_DATA_TYPE,
		FisChexCreditActivator.CHEXSYSTEMS_REMINDDAYSBEFOREEXPIRATION
	};
}