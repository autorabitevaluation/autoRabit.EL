global with sharing class ChexSystemsGeneratePasswordController {
    
    @TestVisible private class ControllerException extends Exception {}
    
    public Boolean hasPermission {get;set;}
    public ApexPages.StandardController controller;
    
    @testVisible
    private static IGeneratePasswordOrchestrator orchestrator = new GeneratePasswordOrchestrator();
    
    public ChexSystemsGeneratePasswordController(ApexPages.StandardController controller) {
        
        this.controller = controller;
        
        List<PermissionSetAssignment> currentPermissions =    [SELECT Id, PermissionSet.Name,AssigneeId
        FROM PermissionSetAssignment
        WHERE AssigneeId = :Userinfo.getUserId() ];

        hasPermission = false;

        for ( PermissionSetAssignment psa : currentPermissions ) {
            if ( psa.PermissionSet.Name.equals(PERMISSION_NAME) ) {
                hasPermission = true;
            }
        }
        
        ApexPages.currentPage().getParameters().put('hasPermission', String.valueOf(hasPermission));
        
	}
	
	@RemoteAction
	global static String getExpirationDate() {
        return orchestrator.GetExpirationDate().format();
	}
	
	@RemoteAction
	global static String autoGeneratePassword() {
        return orchestrator.AutoGeneratePassword();
	}
	
	@TestVisible
    private static final String
        PERMISSION_NAME = 'ChexSystems_AutoGeneratePassword';

}