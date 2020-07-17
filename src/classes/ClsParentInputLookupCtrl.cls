public class ClsParentInputLookupCtrl {
    @AuraEnabled
    public static List<User> searchUser(String userId){
        List<User> ownerid=new List<User>();
        ownerid=[SELECT id,isActive From User where isActive=true];
        return ownerid;
    }
   
}