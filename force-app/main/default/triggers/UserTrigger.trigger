trigger UserTrigger on User (before insert)  {
    /*firing trigger before user is saved to database*/
    User usr = Trigger.new[0];
/*getting first usr[0] from list of users that are new */
    if(usr.ContactId != null) {
        usr.UserPermissionsSFContentUser = true;
    }
}


/*when user with a contact(portal user) is created, enable as content user. */