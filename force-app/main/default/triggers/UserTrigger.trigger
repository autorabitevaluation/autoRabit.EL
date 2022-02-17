trigger UserTrigger on User (before insert)  {
    /*firing trigger before user is saved to database*/
    /* Comment Added By Debasish dtd: 30th Jan, 2022 */
    User usr = Trigger.new[0];
/*getting first usr[0] from list of users that are new */
    if(usr.ContactId != null) {
        usr.UserPermissionsSFContentUser = true;
    }
}
//Test VC from Naresh Rao Dtd: 31st Jan, 2022

/*when user with a contact(portal user) is created, enable as content user. */