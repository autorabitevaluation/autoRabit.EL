trigger SessionTrigger on nFORCE__Session__c (after update) {
    Map<Id, nFORCE__Session__c> oldSessions = new Map<Id, nFORCE__Session__c>();
    for(nFORCE__Session__c session: Trigger.old) {
        oldSessions.put(session.Id, session);
    }
    /*
After every update, fire this trigger-- store the list of sessions that were edited and when the route group chages(oldsession != new session), and the App resolved equals review&submit,
fire the 'execute integration' trigger handler

    */
    for(nFORCE__Session__c session: Trigger.new) {
        nFORCE__Session__c oldSession = oldSessions.get(session.Id);
        
        if(oldSession.nFORCE__Route_Group__c != session.nFORCE__Route_Group__c) {
            if(session.nFORCE__App_Resolved__c ==  session.Fire_Chex_Systems_Formula__c )
                 { 

                ChexsystemsSessionTriggerHandler.executeIntegration(session.Id);
            }
        }
    }
}