public class FRB_CLM_RoundRobin { 
    public static Eagle_Lending_Global_Setting__c custSettings = new Eagle_Lending_Global_Setting__c();
    
    public static Id getRMContactId(Id accountId){ 
        custSettings = Eagle_Lending_Global_Setting__c.getOrgDefaults();
        
        List<Account> acc = [Select Id, LLC_BI__Billing_Address_County__c, BillingCity, BillingPostalCode 
                       From Account Where Id=:accountId LIMIT 1];
        
        If(!acc.isEmpty()){
            List<Zip_Codes__c> zip = [Select FRB_CLM_Territory__c, FRB_CLM_Region__c From Zip_Codes__c 
                                Where Name=:acc[0].BillingPostalCode.left(5) LIMIT 1];
            
            if(!zip.isEmpty()){
                //Getting List of User Ids which are present in the User table(Active/Inactive) Based on County Search - 
                //Ordered by Last Name Desc. 
                List<UserTerritory2Association> userIdsInTerritory = [Select UserId, User.LastName, User.Email, Territory2Id 
                                                                      From UserTerritory2Association where Territory2Id 
                                                                      IN :[Select Id From Territory2 
                                                                           where Territory2Type.Developername=
                                                                           :custSettings.RM_Search_Based_On__c
                                                                           And Name=:acc[0].LLC_BI__Billing_Address_County__c]
                                                                      And UserId IN :[Select Id From User Where Profile.Name =:System.Label.RM_Profile] Order By User.LastName Asc];
                
                Map<String, List<String>> mapUsersInTerritory = new Map<String, List<String>>();
                
                System.debug('userIdsInTerritory Size>>>' + userIdsInTerritory.size());
                
                if(!userIdsInTerritory.isEmpty()){ 
                    for(UserTerritory2Association usrInTer : userIdsInTerritory){ 
                        mapUsersInTerritory.put(usrInTer.UserId, new List<String>{usrInTer.User.LastName, usrInTer.User.Email});
                    }
                
                
                // Getting the List of User Ids account-wise and County Wise, already inserted in Round Robin Table 
                List<FRB_CLM_RM_ROUND_ROBIN__c> UserIdsInRoundRobin = [Select FRB_CLM_RM_UserId__c, 
                                                                       FRB_CLM_RM_Email__c //, FRB_CLM_No_of_Assignments__c
                                                                       From FRB_CLM_RM_ROUND_ROBIN__c 
                                                                       Where FRB_CLM_County__c=:acc[0].LLC_BI__Billing_Address_County__c 
                                                                       AND FRB_CLM_Relationship_Id__c = :accountId
                                                                       //Order By FRB_CLM_No_of_Assignments__c Desc
                                                                      ];
                
                
                Map<String, List<String>> mapUsersInRoundRobin = new Map<String, List<String>>();
                String emailToSearchInContact = '';
                String userId = '';
                
                System.debug('UserIdsInRoundRobin Size>>>' + UserIdsInRoundRobin.size());
                
                if(!UserIdsInRoundRobin.isEmpty()){
                    for(FRB_CLM_RM_ROUND_ROBIN__c rr : UserIdsInroundRobin){
                        //mapUsersInRoundRobin.put(rr.FRB_CLM_RM_UserId__c, new List<String>{rr.FRB_CLM_RM_Email__c, String.valueOf(rr.FRB_CLM_No_of_Assignments__c)});
                        mapUsersInRoundRobin.put(rr.FRB_CLM_RM_UserId__c, new List<String>{rr.FRB_CLM_RM_Email__c});
                    } 
                }
                else{// If there is no entry in Round Robin Table the first record of the sorted List "userIdsInTerritory" 
                     //is the User who is the selected RM
                    emailToSearchInContact = userIdsInTerritory[0].User.Email;
                    userId = userIdsInTerritory[0].UserId;
                }
                
                //Logic for assigning RM the first round
                //If there is already some entry in Round Robin Table then the first found User in Sorted Map "mapUsersInTerritory" 
                //who is NOT there in the map "mapUsersInRoundRobin" would be the Selected RM
                if(!mapUsersInTerritory.isEmpty() && !mapUsersInRoundRobin.isEmpty()){  
                    for(String usrIdInTer : mapUsersInTerritory.keySet()){
                        if(!mapUsersInRoundRobin.keySet().contains(usrIdInTer) && (null != mapUsersInTerritory.get(usrIdInTer))){
                            emailToSearchInContact = mapUsersInTerritory.get(usrIdInTer)[1];
                            userId = usrIdInTer;
                            break;
                        }
                    }
                }             
                
                
                //Logic for assigning RM for Second Round and beyond
                //If the Round Robin Table contains all the RMs listed under the user List of the account then the Sorted List userIdsInTerritory 
                //will be rounded again for finding the next RM to be assigned. The latest Index of the List is stored in a Custom Setting.
                //if(String.isBlank(emailToSearchInContact) || Test.isRunningTest()){ 
                if(String.isBlank(emailToSearchInContact)){
                    Integer index = Integer.valueOf(custSettings.RM_List_Latest_Index__c);
                    
                    if(Index == userIdsInTerritory.size()){
                        index = 0;
                    }
                    
                    emailToSearchInContact = userIdsInTerritory[index].User.Email;
                    userId = userIdsInTerritory[index].UserId;
                    index++;
                    custSettings.RM_List_Latest_Index__c = index;
                    update custSettings;
                }
                
                List<Contact> Con = new List<Contact>();
                
                System.debug('emailToSearchInContact-------->>>' + emailToSearchInContact);
                
                if(!String.isBlank(emailToSearchInContact)){
                   // if(Test.isRunningTest()){
                   //     emailToSearchInContact = 'testterritory@frbnp2.com';
                  //  }
                    //Getting Contact Id based on the selected already searched Email
                    con = [Select Id, FirstName, LastName, Email from Contact Where Email=:emailToSearchInContact Limit 1];
                }
                
                if(!con.isEmpty()){
                    Id roundRobinId = populateRoundRobinDetails(Con[0], 
                                                                zip[0].FRB_CLM_Territory__c,
                                                                zip[0].FRB_CLM_Region__c,
                                                                acc[0].LLC_BI__Billing_Address_County__c, 
                                                                acc[0].BillingCity,
                                                                acc[0].BillingPostalCode.left(5),
                                                                accountId,
                                                                userId);
                    if(null != roundRobinId){  
                        return con[0].Id;
                    }
                        
                        return ID.valueof('000000000000000');//Null Contact Id
                    }
                    
                    return ID.valueof('000000000000001');//Null Zip Code
                }
                
                return ID.valueof('000000000000002');//Null Account
                
            }
            return ID.valueof('000000000000003');//Invalid County
        } 
        return null;
    } 
    
    /* Following fields are populated in Round Robin Table using this method:
     * RM Name, Email, No of Assignement, Assigned Date,Account Id, User Id, Territory, Region, County, City, Zip Code and the Assigned Flag
     */
     
    public static Id populateRoundRobinDetails(Contact con, String teritory, String region, String county, 
                                               String city, String zip, String accId, String userId){
                                                   
        FRB_CLM_RM_ROUND_ROBIN__c roundRobinDtl = new FRB_CLM_RM_ROUND_ROBIN__c();
        roundRobinDtl.FRB_CLM_RM_Name__c = con.FirstName + ' ' + con.LastName;
        roundRobinDtl.FRB_CLM_RM_Email__c = con.Email;
        roundRobinDtl.FRB_CLM_Assigned_Date__c = System.Datetime.now();
        roundRobinDtl.FRB_CLM_Relationship_Id__c = accId; 
        roundRobinDtl.FRB_CLM_RM_UserId__c = userId;
        roundRobinDtl.FRB_CLM_Territory__c = teritory;
        roundRobinDtl.FRB_CLM_Region__c = region;
        roundRobinDtl.FRB_CLM_County__c = county;
        roundRobinDtl.FRB_CLM_City__c = city;
        roundRobinDtl.FRB_CLM_Zip_Code__c = zip;
        roundRobinDtl.FRB_CLM_RM_Assigned__c = True;
                                                   
        upsert roundRobinDtl FRB_CLM_RM_Email__c;
                                                   
        if(null != roundRobinDtl.id){
            List<FRB_CLM_RM_ROUND_ROBIN__c> roundRobinRec = [Select FRB_CLM_No_of_Assignments__c From FRB_CLM_RM_ROUND_ROBIN__c Where Id= :roundRobinDtl.id Limit 1];
            roundRobinRec[0].FRB_CLM_No_of_Assignments__c +=1;
            update roundRobinRec[0];
            return roundRobinDtl.id;
        }
                                                   
        return null;
   }
}