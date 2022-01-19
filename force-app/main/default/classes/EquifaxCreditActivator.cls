/**
 * @author nCino
 * Implements the IPlugin Activator Interface and creates SystemProperties,
 * SystemConfiguration, and registers a bean for the CreditAppFacade on Activate.
 * Then does nothing on deactivate.
 **/
global with sharing class EquifaxCreditActivator implements nFUSE.IPluginActivator {
	
	global with sharing class EquifaxCreditPassReviewDecision extends nFUSE.ACreditPassReviewDecision {
		global override Flow.Interview create(Map<String,Object> inputs) {
			return new Flow.Interview.Credit_Pass_Review(inputs);
		}
	}
	
	global with sharing class EquifaxCreditReportTypeDecision extends nFUSE.ACreditReportTypeDecision {
		global override Flow.Interview create(Map<String,Object> inputs) {
			return new Flow.Interview.Credit_Report_Type(inputs);
		}
	}
	
	@testVisible
	private nFUSE.ServiceLocator locator = new nFUSE.ServiceLocator();
	
	public void onActivate() {
		
		// register Equifax credit app facade
		nFORCE.BeanRegistry.getInstance().registerBean(
				EquifaxCreditAppFacade.class.getName(),
				nFUSE.CreditAppFacade.class,
				EquifaxCreditAppFacade.class,
				new Map<String, Object>{},
				true);

		// register credit pass review and report type flows
		nFUSE.ACreditPassReviewDecision.register(EquifaxCreditPassReviewDecision.class);
		nFUSE.ACreditReportTypeDecision.register(EquifaxCreditReportTypeDecision.class);
		
		// load default configurations
		this.LoadPluginConfigurations();
		
		nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(EquifaxCreditActivator.PLUGIN_NAME, EquifaxCreditActivator.PLUGIN_VERSION, null);
        locator.register(request, nFUSE.SendService.class, EquifaxSendService.class,'EquifaxSendService');
	}

	public void onDeactivate() {
		nFUSE.PackageServiceRequest request = new nFUSE.PackageServiceRequest(EquifaxCreditActivator.PLUGIN_NAME, EquifaxCreditActivator.PLUGIN_VERSION, null);
		locator.deregister(request, nFUSE.SendService.class,'EquifaxSendService');
	}

	/**
     * Purpose : Create all configuration properties in one method following nFUSE.PluginConfigurationManager specifications
     * Details : To utilize nFUSE.PluginConfigurationManager and deprecate nForce.SystemsProperties usage as of Fall 2017 Release
     *			 Inserts new configurations into a list of configurations,
     *			 If configuration already exists in the data layer, then the existing config value is kept
     */ 
	@TestVisible
	public void LoadPluginConfigurations() {
		this.configs = new List<nFUSE.PluginConfigurationManager.PluginConfiguration> {};

		this.configs.add(CreateConfig(CONSUMER_USER_SITE_ID, '', 'String', false));
		this.configs.add(CreateConfig(CONSUMER_PASSWORD, '', 'String', true));
		this.configs.add(CreateConfig(CONSUMER_CUSTOMER_CODE, 'ISTS', 'String', false));
		this.configs.add(CreateConfig(CONSUMER_SOFT_MEMBER_NUMBER, '', 'String', false));
		this.configs.add(CreateConfig(CONSUMER_SOFT_SECURITY_CODE, '', 'String', true));
		this.configs.add(CreateConfig(CONSUMER_HARD_MEMBER_NUMBER, '', 'String', false));
		this.configs.add(CreateConfig(CONSUMER_HARD_SECURITY_CODE, '', 'String', true));
		this.configs.add(CreateConfig(CONSUMER_ENVIRONMENT_FLAG, 'UAT', 'String', false));
		//DATA-1338
		this.configs.add(CreateConfig(CONSUMER_RISK_BASED_PRICING, 'N', 'String', false));
		//DATA-1602
		this.configs.add(CreateConfig(CONSUMER_ADDTL_SCORING, '', 'String', false));
		//DATA-1607
		this.configs.add(CreateConfig(CONSUMER_PLACEHOLDER_NAME, 'Credit Report', 'String', false));
		this.configs.add(CreateConfig(CONSUMER_APPEND_BUREAU_ID_TO_NAME, 'Y', 'String', false));
		
		//DATA-3384
		this.configs.add(CreateConfig(SCORING_MODEL_1, '', 'String', false));
		this.configs.add(CreateConfig(SCORING_MODEL_2, '', 'String', false));
		this.configs.add(CreateConfig(SCORING_MODEL_3, '', 'String', false));
		
		//DATA-2872
		this.configs.add(CreateConfig(ADD_ON_BEACON_FLAG, 'N', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_FICO_FLAG, 'Y', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_FICO_VERBIAGE_FLAG, 'Y', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_EDAS_FLAG, 'Y', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_ONLINE_DIRECTORY_FLAG, 'Y', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_CONSUMER_REF_FLAG, 'N', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_ALERT_CONTACT_FLAG, 'Y', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_DEFAULT_MODEL_FLAG, 'N', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_RBP_BEACON_FLAG, 'N', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_RBP_FICO_FLAG, 'N', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_RBP_ALL_FLAG, 'N', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_24MONTH_PAYMENT_HISTORY, 'N', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_SYNTHETIC_ID_ALERT, 'N', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_EXPANDED_TRADE_A1160, 'N', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_EXPANDED_TRADE_DIMENSIONS, 'N', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_EXPANDED_TRADE_HIGH_VALUE, 'N', 'String', false));
		this.configs.add(CreateConfig(ADD_ON_EXPANDED_TRADE_TERMS, 'N', 'String', false));

		this.configs.add(CreateConfig(BUSINESS_USER_SITE_ID, '', 'String', false));
		this.configs.add(CreateConfig(BUSINESS_PASSWORD, '', 'String', true));
		this.configs.add(CreateConfig(BUSINESS_CUSTOMER_CODE, '', 'String', false));
		this.configs.add(CreateConfig(BUSINESS_MEMBER_NUMBER, '', 'String', false));
		this.configs.add(CreateConfig(BUSINESS_SECURITY_CODE, '', 'String', true));
		this.configs.add(CreateConfig(BUSINESS_SERVICE_CODE, '', 'String', false));
		this.configs.add(CreateConfig(BUSINESS_PDF_TRANSFORMER_SC, '', 'String', true));
		this.configs.add(CreateConfig(BUSINESS_ENVIRONMENT_FLAG, 'UAT', 'String', false));
		
		//DATA-1607
		this.configs.add(CreateConfig(COMMERCIAL_PLACEHOLDER_NAME, 'Credit Report', 'String', false));
		this.configs.add(CreateConfig(COMMERCIAL_APPEND_BUREAU_ID_TO_NAME, 'Y', 'String', false));

		//DATA-1607
		this.configs.add(CreateConfig(PLACEHOLDER_CATEGORY, 'Credit Reports', 'String', false));
		this.configs.add(CreateConfig(APPEND_DATE_TO_PLACEHOLDER_NAME, 'Y', 'String', false));
		
		this.configs.add(CreateConfig(BUSINESS_DAYS_VALID, '30', 'String', false));
		this.configs.add(CreateConfig(CONSUMER_DAYS_VALID, '30', 'String', false));
		
		//DATA-2648
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_CREDIT_REPORT, 'N', 'String', false));	
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_CREDIT_REPORT_NTH, 'N', 'String', false));

		this.configs.add(CreateConfig(PRODUCT_PORTFOLIO_DATA_VERIFICATION, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DATA_SELECT_PR, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DATA_SELECT_F, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DATA_SELECT_CT, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DATA_SELECT_AH, 'N', 'String', false));

		this.configs.add(CreateConfig(PRODUCT_BUSINESS_IDENTITY, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_IDENTITY_RP, 'N', 'String', false));
		
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_INDUSTRY_RS, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_INDUSTRY, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_INDUSTRY2, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_INDUSTRY_RP, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_INDUSTRY_RP2, 'Y', 'String', false));
		
		this.configs.add(CreateConfig(PRODUCT_EXPANDED_MATCH, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_PRINCIPAL_REPORT, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BPR_STANDALONE, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_OFAC_COMMERCIAL, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_OFAC_PRINCIPAL, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_FRAUD_ADVISOR, 'N', 'String', false));
		
		this.configs.add(CreateConfig(PRODUCT_SBC_RISKSCORE_SUPPLIERS, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_SBC_RISKSCORE_FS, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_SBC_RISKSCORE_FSB, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_SBC_RISKSCORE_S, 'N', 'String', false));
		
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_FAILURE_SCORE, 'Y', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_FAILURE_RISK, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_FAILURE_RISKSCORE, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_FAILURE_RISKRATING, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_FAILURE_RISKLEVEL, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_CREDIT_RISK, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_CREDIT_RISKSCORE, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_CREDIT_RISKCLASS, 'N', 'String', false));
		
		this.configs.add(CreateConfig(PRODUCT_DELINQUENCY_FINANCIAL_SCORE, 'Y', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_BUSINESS_DELINQUENCY_SCORE, 'Y', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DELINQUENCY_RISK_CLASS, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DELINQUENCY_RISK_CLASS_F, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DELINQUENCY_SCORE_BLENDED_F, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DELINQUENCY_SCORE_BLENDED, 'N', 'String', false));
		
		this.configs.add(CreateConfig(PRODUCT_SUGGESTED_CREDIT_LIMIT_CARD, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_SUGGESTED_CREDIT_LIMIT_LOAN, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_SUGGESTED_CREDIT_LIMIT_CONSERVATIVE, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_SUGGESTED_CREDIT_LIMIT_MODERATE, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_SUGGESTED_CREDIT_LIMIT_AGGRESSIVE, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_SUGGESTED_CREDIT_LIMIT_2, 'N', 'String', false));
	
		this.configs.add(CreateConfig(PRODUCT_DELINQUENCY_SCORE, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DELINQUENCY_SCORE_M, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DELINQUENCY_SCORE_BS, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DELINQUENCY_SCORE_T, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DELINQUENCY_SCORE_RL, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DELINQUENCY_SCORE_COMMUNICATIONS, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_DELINQUENCY_SCORE_PS, 'N', 'String', false));

		this.configs.add(CreateConfig(PRODUCT_ACCOUNT_MANAGEMENT_SCORE, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_FINANCIAL_HEALTH_INDEX, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_PAYMENT_INDEX_SERVICES, 'N', 'String', false));
		this.configs.add(CreateConfig(PRODUCT_PAYMENT_INDEX, 'N', 'String', false));
		
		this.configs.add(CreateConfig(PRODUCT_COMMERCIAL_SCORE_MARKETING, 'N', 'String', false));

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
	* @param String category : config category, example: 'Equifax_Credit'
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
	
	public List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs;
		
	public static final String PLUGIN_NAME = 'Equifax_Credit';
	public static final String PLUGIN_VERSION = '1.0';
	public static final String PLUGIN_CONFIG_NAME ='Equifax_CreditConfiguration';
	public static final String PLUGIN_HELP_TEXT = 'Equifax Plugin Category for Property Configuration';

	public static final String CONSUMER_USER_SITE_ID = 'Consumer User ID/Site ID';
	public static final String CONSUMER_PASSWORD = 'Consumer Password';
	public static final String CONSUMER_CUSTOMER_CODE = 'Consumer Customer Code';
	public static final String CONSUMER_SOFT_MEMBER_NUMBER = 'Consumer Soft Member Number';
	public static final String CONSUMER_SOFT_SECURITY_CODE = 'Consumer Soft Security Code';
	public static final String CONSUMER_HARD_MEMBER_NUMBER = 'Consumer Hard Member Number';
	public static final String CONSUMER_HARD_SECURITY_CODE = 'Consumer Hard Security Code';
	public static final String CONSUMER_DAYS_VALID = 'Consumer Days Valid';
	public static final String CONSUMER_ENVIRONMENT_FLAG = 'Consumer Environment Flag';
	//DATA-1338
	public static final String CONSUMER_RISK_BASED_PRICING = 'Consumer Risk Based Pricing';
	//DATA-1602
	public static final String CONSUMER_ADDTL_SCORING = 'Consumer Additional Scoring';
	//DATA-1607
	public static final String CONSUMER_PLACEHOLDER_NAME = 'Consumer Credit Placeholder Name';
	public static final String CONSUMER_APPEND_BUREAU_ID_TO_NAME = 'Append Bureau ID to Consumer Placeholder Name';
	//DATA-3328
	public static final String SCORING_MODEL_1 = 'Scoring Model #1';
	public static final String SCORING_MODEL_2 = 'Scoring Model #2';
	public static final String SCORING_MODEL_3 = 'Scoring Model #3';
	//DATA-2872
	public static final String ADD_ON_BEACON_FLAG = 'Add-on: Beacon Flag';
	public static final String ADD_ON_FICO_FLAG = 'Add-on: FICO Flag';
	public static final String ADD_ON_FICO_VERBIAGE_FLAG = 'Add-on: Use FICO Verbiage Flag';
	public static final String ADD_ON_EDAS_FLAG = 'Add-on: EDAS Flag';
	public static final String ADD_ON_ONLINE_DIRECTORY_FLAG = 'Add-on: Online Directory Flag';
	public static final String ADD_ON_CONSUMER_REF_FLAG = 'Add-on: Consumer Referral Location Flag';
	public static final String ADD_ON_ALERT_CONTACT_FLAG = 'Add-on: Alert Contact Flag';
	public static final String ADD_ON_DEFAULT_MODEL_FLAG = 'Add-on: Default Model Flag';
	public static final String ADD_ON_RBP_BEACON_FLAG = 'Add-on: RBP Beacon Only Flag';
	public static final String ADD_ON_RBP_FICO_FLAG = 'Add-on: RBP FICO Only Flag';
	public static final String ADD_ON_RBP_ALL_FLAG = 'Add-on: RBP All Flag';
	public static final String ADD_ON_24MONTH_PAYMENT_HISTORY = 'Add-on: 24-Month Payment History';
	public static final String ADD_ON_SYNTHETIC_ID_ALERT = 'Add-on: Synthetic ID Alert';
	public static final String ADD_ON_EXPANDED_TRADE_A1160 = 'Add-on: Expanded Trade A 1160';
	public static final String ADD_ON_EXPANDED_TRADE_DIMENSIONS = 'Add-on: Expanded Trade Dimensions';
	public static final String ADD_ON_EXPANDED_TRADE_HIGH_VALUE = 'Add-on: Expanded High Value';
	public static final String ADD_ON_EXPANDED_TRADE_TERMS = 'Add-on: Expanded Trade Terms';
	
	public static final String BUSINESS_USER_SITE_ID = 'Business User ID/Site ID';
	public static final String BUSINESS_PASSWORD = 'Business Password';
	public static final String BUSINESS_CUSTOMER_CODE = 'Business Customer Code';
	public static final String BUSINESS_MEMBER_NUMBER = 'Business Member Number';
	public static final String BUSINESS_SECURITY_CODE = 'Business Security Code';
	public static final String BUSINESS_SERVICE_CODE = 'Business Service Code';
	public static final String BUSINESS_PDF_TRANSFORMER_SC = 'Business PDF Transformer Security Code';
	public static final String BUSINESS_DAYS_VALID = 'Business Days Valid';
	public static final String BUSINESS_ENVIRONMENT_FLAG = 'Business Environment Flag';
	
	//DATA-1607
	public static final String COMMERCIAL_PLACEHOLDER_NAME = 'Commercial Credit Placeholder Name';
	public static final String COMMERCIAL_APPEND_BUREAU_ID_TO_NAME = 'Append Bureau ID to Commercial Placeholder Name';

	//global properties
	//DATA-1607
	public static final String PLACEHOLDER_CATEGORY = 'Credit Report Category';
	public static final String APPEND_DATE_TO_PLACEHOLDER_NAME = 'Append Date/Time to Placeholder Name';
	
	//DATA-2648
	public static final String PRODUCT_BUSINESS_CREDIT_REPORT = 'Product: Business Credit Report';
	public static final String PRODUCT_BUSINESS_CREDIT_REPORT_NTH = 'Product: Business Credit Report - No Trade History';	
	public static final String PRODUCT_PORTFOLIO_DATA_VERIFICATION = 'Product: Portfolio Data Verification';
	
	public static final String PRODUCT_DATA_SELECT_PR = 'Product: Data Select Public Records';
	public static final String PRODUCT_DATA_SELECT_F = 'Product: Data Select Firmographics';
	public static final String PRODUCT_DATA_SELECT_CT = 'Product: Data Select Current Trade';
	public static final String PRODUCT_DATA_SELECT_AH = 'Product: Data Select Account History';
	
	public static final String PRODUCT_BUSINESS_IDENTITY = 'Product: Business Identity Report';
	public static final String PRODUCT_BUSINESS_IDENTITY_RP = 'Product: Business Identity Report Plus';
	
	public static final String PRODUCT_BUSINESS_INDUSTRY_RS = 'Product: Business Credit Industry Report Summary';
	public static final String PRODUCT_BUSINESS_INDUSTRY = 'Product: Business Credit Industry Report';
	public static final String PRODUCT_BUSINESS_INDUSTRY2 = 'Product: Business Credit Industry Report 2.0';
	public static final String PRODUCT_BUSINESS_INDUSTRY_RP = 'Product: Business Credit Industry Report Plus';
	public static final String PRODUCT_BUSINESS_INDUSTRY_RP2 = 'Product: Business Credit Industry Report Plus 2.0';
	
	public static final String PRODUCT_EXPANDED_MATCH = 'Product: Expanded Match';
	public static final String PRODUCT_BUSINESS_PRINCIPAL_REPORT = 'Product: Business Principal Report';
	public static final String PRODUCT_BPR_STANDALONE = 'Product: BPR Standalone';
	public static final String PRODUCT_OFAC_COMMERCIAL = 'Product: OFAC Alert - Commercial';
	public static final String PRODUCT_OFAC_PRINCIPAL = 'Product: OFAC Alert - Principal';
	public static final String PRODUCT_BUSINESS_FRAUD_ADVISOR = 'Product: Business Fraud Advisor';
	
	public static final String PRODUCT_SBC_RISKSCORE_SUPPLIERS = 'Product: Small Business Credit Risk Score for Suppliers';
	public static final String PRODUCT_SBC_RISKSCORE_FS = 'Product: Small Business Credit Risk Score for Financial Services';
	public static final String PRODUCT_SBC_RISKSCORE_FSB = 'Product: Small Business Credit Risk Score for Financial Services Blended';
	public static final String PRODUCT_SBC_RISKSCORE_S = 'Product: Small Business Credit Risk Score for Suppliers Blended';
	
	public static final String PRODUCT_BUSINESS_FAILURE_SCORE = 'Product: Business Failure Score';
	public static final String PRODUCT_BUSINESS_FAILURE_RISK = 'Product: Business Failure Risk';
	public static final String PRODUCT_BUSINESS_FAILURE_RISKSCORE = 'Product: Business Failure Risk Score';
	public static final String PRODUCT_BUSINESS_FAILURE_RISKRATING = 'Product: Business Failure Risk Rating';
	public static final String PRODUCT_BUSINESS_FAILURE_RISKLEVEL = 'Product: Business Failure Risk Level';
	public static final String PRODUCT_BUSINESS_CREDIT_RISK = 'Product: Business Credit Risk';
	public static final String PRODUCT_BUSINESS_CREDIT_RISKSCORE = 'Product: Business Credit Risk Score';
	public static final String PRODUCT_BUSINESS_CREDIT_RISKCLASS = 'Product: Business Credit Risk Class';
	
	public static final String PRODUCT_DELINQUENCY_FINANCIAL_SCORE = 'Product: Business Delinquency Financial Score';
	public static final String PRODUCT_BUSINESS_DELINQUENCY_SCORE = 'Product: Business Delinquency Score';	
	public static final String PRODUCT_DELINQUENCY_RISK_CLASS = 'Product: Business Delinquency Risk Class';
	public static final String PRODUCT_DELINQUENCY_RISK_CLASS_F = 'Product: Business Delinquency Financial Risk Class';
	public static final String PRODUCT_DELINQUENCY_SCORE_BLENDED_F = 'Product: Business Delinquency Financial Score Blended';
	public static final String PRODUCT_DELINQUENCY_SCORE_BLENDED = 'Product: Business Delinquency Score Blended';
	
	public static final String PRODUCT_SUGGESTED_CREDIT_LIMIT_CARD = 'Product: Suggested Credit Limit, Card';
	public static final String PRODUCT_SUGGESTED_CREDIT_LIMIT_LOAN = 'Product: Suggested Credit Limit, Loan';
	public static final String PRODUCT_SUGGESTED_CREDIT_LIMIT_CONSERVATIVE = 'Product: Suggested Credit Limit, Conservative';
	public static final String PRODUCT_SUGGESTED_CREDIT_LIMIT_MODERATE = 'Product: Suggested Credit Limit, Moderate';
	public static final String PRODUCT_SUGGESTED_CREDIT_LIMIT_AGGRESSIVE = 'Product: Suggested Credit Limit, Aggressive';
	public static final String PRODUCT_SUGGESTED_CREDIT_LIMIT_2 = 'Product: Suggested Credit Limit 2.0';

	public static final String PRODUCT_DELINQUENCY_SCORE = 'Product: Delinquency Score';	
	public static final String PRODUCT_DELINQUENCY_SCORE_M = 'Product: Delinquency Score Manufacturing';
	public static final String PRODUCT_DELINQUENCY_SCORE_BS = 'Product: Delinquency Score Business Services and Wholesale';
	public static final String PRODUCT_DELINQUENCY_SCORE_T = 'Product: Delinquency Score Transporation';
	public static final String PRODUCT_DELINQUENCY_SCORE_RL = 'Product: Delinquency Score Rental and Leasing Services';
	public static final String PRODUCT_DELINQUENCY_SCORE_COMMUNICATIONS = 'Product: Delinquency Score Communications';
	public static final String PRODUCT_DELINQUENCY_SCORE_PS = 'Product: Delinquency Score Professional Services';
	
	public static final String PRODUCT_ACCOUNT_MANAGEMENT_SCORE = 'Product: Account Management Score';
	public static final String PRODUCT_FINANCIAL_HEALTH_INDEX = 'Product: Financial Health Index';
	public static final String PRODUCT_PAYMENT_INDEX_SERVICES = 'Product: Payment Index for Services and Trade';
	public static final String PRODUCT_PAYMENT_INDEX = 'Product: Payment Index';
	
	public static final String PRODUCT_COMMERCIAL_SCORE_MARKETING = 'Product: Commercial Score for Marketing';
}