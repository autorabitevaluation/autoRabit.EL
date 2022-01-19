/**
 * @author nCino
 * Implements the IPlugin Activator Interface and creates SystemProperties,
 * SystemConfiguration, and registers a bean for the CreditAppFacade on Activate.
 * Then does nothing on deactivate.
 **/
global with sharing class FisChexCreditActivator implements nFUSE.IPluginActivator {
    
    global with sharing class FisChexCreditPassReviewDecision extends nFUSE.ACreditPassReviewDecision { //possible namespace issue
        global override Flow.Interview create(Map<String,Object> inputs) {
            return new Flow.Interview.Credit_Report_Type(inputs);
            //switch out with the code below once ACreditPassReviewDecision in nFUSE is moved to version 42.0
            //return Flow.Interview.createInterview('Credit_Pass_Review',inputs);
        }
    }
    
    global with sharing class FisChexCreditReportTypeDecision extends nFUSE.ACreditReportTypeDecision { //possible namespace issue
        global override Flow.Interview create(Map<String,Object> inputs) {
            return new Flow.Interview.Credit_Report_Type(inputs);
            //switch out with the code below once ACreditPassReviewDecision in nFUSE is moved to version 42.0
            //return Flow.Interview.createInterview('Credit_Report_Type',inputs);
        }
    }
    
    
    public void onActivate() {
        // register ChexSystems app facade
        nFORCE.BeanRegistry.getInstance().registerBean(
            FisChexCreditAppFacade.class.getName(),
            nFUSE.CreditAppFacade.class, //possible namespace issue
            FisChexCreditAppFacade.class,
            new Map<String, Object>{},
            true);
        
        // load default configurations
        this.LoadPluginConfigurations();
        
        //DATA-2474 : register send service class 
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(FisChexCreditActivator.PLUGIN_NAME, FisChexCreditActivator.PLUGIN_VERSION, null);
        locator.register(request, nFUSE.SendService.class, FisDefaultSendService.class,'FisDefaultSendService');
        
        // register credit pass review and report type flows
        nFUSE.ACreditPassReviewDecision.register(FisChexCreditPassReviewDecision.class); //possible namespace issue
        nFUSE.ACreditReportTypeDecision.register(FisChexCreditReportTypeDecision.class); //possible namespace issue
    }
    
    // future implementation
    public void onDeactivate() {
        //DATA-2474 : deregister send service class 
        nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(FisChexCreditActivator.PLUGIN_NAME, FisChexCreditActivator.PLUGIN_VERSION, null);
        locator.deregister(request, nFUSE.SendService.class,'FisDefaultSendService');
    }
    
    /**
     * Purpose : Create all configuration properties in one method following nFUSE.PluginConfigurationManager specifications
     * Details : To utilize nFUSE.PluginConfigurationManager and deprecate nForce.SystemsProperties usage as of Fall 2017 Release
     *           Inserts new configurations into a list of configurations,
     *           If configuration already exists in the data layer, then the existing config value is kept
     */ 
    public void LoadPluginConfigurations() {
        this.configs = new List<nFUSE.PluginConfigurationManager.PluginConfiguration> {};
        
        //Boiler Plate settings
        this.configs.add(this.CreateConfig(BUSINESS_DAYS_VALID, '30', 'String', false));  
        this.configs.add(this.CreateConfig(CONSUMER_DAYS_VALID, '30', 'String', false)); 
        this.configs.add(this.CreateConfig(COMMERCIAL_PLACEHOLDER_NAME, 'Debit Report', 'String', false)); 
        this.configs.add(this.CreateConfig(COMMERCIAL_APPEND_BUREAU_ID_TO_NAME, 'Y', 'String', false)); 
        this.configs.add(this.CreateConfig(CONSUMER_PLACEHOLDER_NAME, 'Debit Report', 'String', false)); 
        this.configs.add(this.CreateConfig(CONSUMER_APPEND_BUREAU_ID_TO_NAME, 'Y', 'String', false)); 
        this.configs.add(this.CreateConfig(PLACEHOLDER_CATEGORY,'Debit Reports', 'String', false)); 
        this.configs.add(this.CreateConfig(APPEND_DATE_TO_PLACEHOLDER_NAME, '', 'String', false)); 

        //FIS specific settings
        this.configs.add(this.CreateConfig(CHEXSYSTEMS_USERNAME, '', 'String', false)); 
        this.configs.add(this.CreateConfig(CHEXSYSTEMS_PASSWORD, '', 'String', true));
        this.configs.add(this.CreateConfig(STAGING_SERVER, 'Y', 'String', false));
        this.configs.add(this.CreateConfig(ACQUIRER_IDENTIFIER, '192594','String', false));
        this.configs.add(this.CreateConfig(PRODUCT_QUALIFILE, 'Y','String', false)); 
        this.configs.add(this.CreateConfig(PRODUCT_CHEXSYSTEMS, 'N','String', false)); 
        this.configs.add(this.CreateConfig(PRODUCT_IDENTITY_MANAGER, 'N','String', false)); 
        this.configs.add(this.CreateConfig(PRODUCT_OFAC, 'N','String', false)); // index 16
        this.configs.add(this.CreateConfig(QUALIFILE_VERSION_NUMBER,'N003', 'String', false)); 
        this.configs.add(this.CreateConfig(CHEXSYSTEMS_VERSION_NUMBER, '', 'String', false)); 
        this.configs.add(this.CreateConfig(REPORT_DATA_TYPE, '2', 'String', false)); 
        this.configs.add(this.CreateConfig(CHEXSYSTEMS_REMINDDAYSBEFOREEXPIRATION, '100', 'String', false)); 
        
        new nFUSE.PluginConfigurationManager(PLUGIN_NAME, PLUGIN_VERSION).softInsertConfigurations(configs);
    }
    
    /*
    * Purpose : Create configuration properties by using the nFUSE class PluginConfigurationManager.cls
    * @param String key : config key, example: 'Business Days Valid'
    * @param String value : config default value: example: '30'
    * @param String dataType : it is always a string
    * @param Boolean isEncrypted : none of the configs are encrypted for this specific plugin
    * returns a list of configurations [PluginConfigurationManager.Configurations]
    */
    @TestVisible 
    private nFUSE.PluginConfigurationManager.PluginConfiguration CreateConfig(String key, String value, String dataType, Boolean isEncrypted){
        nFUSE.PluginConfigurationManager.PluginConfiguration config = new nFUSE.PluginConfigurationManager.PluginConfiguration();
        config.pluginName = PLUGIN_NAME;
        config.pluginVersion = PLUGIN_VERSION;
        config.category = PLUGIN_NAME;
        config.key = key;
        config.valueDataType = dataType;
        config.value = value;
        config.isEncrypted = isEncrypted;
        return config;
    }
    
    /*
    * Purpose : Check for existence of category in configuration properties by using the nFUSE class PluginConfigurationManager.cls
    * @param String category : config category, example: 'ChexSystems_Credit'
    */ 
    @TestVisible 
    private Boolean containsCategory(String category){
        for(nFUSE.PluginConfigurationManager.PluginConfiguration config : this.configs) {
                if (config.category == category){
                    return true;
                }
        }
        return false;
    }
    
    @testVisible
    private nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
    
    public List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs;
    
    private static final String nFUSE_CONFIGURATION_KEYWORD = 'Configuration';
    
    public static final String PLUGIN_NAME = 'ChexSystems_Credit',
        PLUGIN_VERSION = '1.0',
        PLUGIN_CONFIG_NAME ='ChexSystems_Credit' + nFUSE_CONFIGURATION_KEYWORD,
        PLUGIN_HELP_TEXT = 'ChexSystems Plugin Category for Property Configuration',
   
        //Boiler Plate Properties
        BUSINESS_DAYS_VALID = 'Business Days Valid',
        CONSUMER_DAYS_VALID = 'Consumer Days Valid',
        COMMERCIAL_PLACEHOLDER_NAME = 'Commercial Credit Placeholder Name',
        COMMERCIAL_APPEND_BUREAU_ID_TO_NAME = 'Append Bureau ID to Commercial Placeholder Name',
        CONSUMER_PLACEHOLDER_NAME = 'Consumer Credit Placeholder Name',
        CONSUMER_APPEND_BUREAU_ID_TO_NAME = 'Append Bureau ID to Consumer Placeholder Name',
        PLACEHOLDER_CATEGORY = 'Credit Report Category',
        APPEND_DATE_TO_PLACEHOLDER_NAME = 'Append Date/Time to Placeholder Name',
        
        //FIS specific properties
        CHEXSYSTEMS_USERNAME = 'ChexSystems Username',
        CHEXSYSTEMS_PASSWORD = 'ChexSystems Password',
        STAGING_SERVER = 'Staging Server',
        ACQUIRER_IDENTIFIER = 'Acquirer Identifier',
        CUSTOMER_IDENTIFIER = 'Customer Identifier',
        PRODUCT_QUALIFILE = 'Product: QualiFile',
        PRODUCT_CHEXSYSTEMS = 'Product: Chexsystems',
        PRODUCT_IDENTITY_MANAGER = 'Product: Identity Manager',
        PRODUCT_OFAC = 'Product: OFAC',
        QUALIFILE_VERSION_NUMBER = 'QualiFile Version Number',
        CHEXSYSTEMS_VERSION_NUMBER = 'Chexsystems Version Number',
        INQUIRY_IDENTIFIER = 'Inquiry Identifier',
        STRATEGY_TYPE_INDICATOR = 'Strategy Type Indicator',
        REPORT_DATA_TYPE = 'Report Data Type',
        CHEXSYSTEMS_REMINDDAYSBEFOREEXPIRATION = 'ChexSystems Reminder Days Before Expiration';

}