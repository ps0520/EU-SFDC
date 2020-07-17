/****************************************************************************************
@Description : Class handles all logic related to Marketing Interactions for all countries
******************************************************************************************/

public class ClsMarketingInteractionHandler {

	//Method evaluates changes for Account updates to create the MIs
	//Method segregates the country specific records
    public static void handleMIsForAccountUpdates(Map<Id, Account> newTriggerAccount, Map<Id, Account> oldTriggerAccount) {
        ClsAccountAddressTriggerStaticClass.invokeMILogicOnlyOnce = false;
		Map<Id, Account> newCATriggerAccount = new Map<Id, Account>();
		Map<Id, Account> oldCATriggerAccount = new Map<Id, Account>();

		//for UK and IE campaigns:
		Map<Id, Account> newUKIETriggerAccount = new Map<Id, Account>();
		Map<Id, Account> oldUKIETriggerAccount = new Map<Id, Account>();

		for(Account newAccnt : newTriggerAccount.values())
		{
			String recdTypeDeveloperName = Schema.SObjectType.Account.getRecordTypeInfosById().get(newAccnt.RecordTypeId).getDeveloperName();
			Account oldAccnt = oldTriggerAccount.get(newAccnt.Id);
			//Route the logic to CA specific method
			if(recdTypeDeveloperName.startsWithIgnoreCase('CA_'))
			{
				newCATriggerAccount.put(newAccnt.Id, newAccnt);
				oldCATriggerAccount.put(oldAccnt.Id, oldAccnt);
			} else if (recdTypeDeveloperName == 'GB_Consumer' || recdTypeDeveloperName == 'IE_Consumer'){
				newUKIETriggerAccount.put(newAccnt.Id, newAccnt);
				oldUKIETriggerAccount.put(oldAccnt.Id, oldAccnt);
			}
		}
		if(!newCATriggerAccount.isEmpty() && !oldCATriggerAccount.isEmpty())
			handleCAMIsForAccountUpdates(newCATriggerAccount, oldCATriggerAccount);

		//for UK and IE campaigns:	
		if (!newUKIETriggerAccount.isEmpty() && !oldUKIETriggerAccount.isEmpty()){
			handleUKMIsForAccountUpdates(newUKIETriggerAccount, oldUKIETriggerAccount);
		}
	}
	
	//Method evaluates changes for Account updates to create the MIs
    public static void handleCAMIsForAccountUpdates(Map<Id, Account> newTriggerAccount, Map<Id, Account> oldTriggerAccount) {
		system.debug('***ENTERED THE METHOD handleCAMIsForAccountUpdates');
		Set<String> accountsToProcessForMIsSet = new Set<String>();//Reason for the concatenated set is same account may be involved in multiple MIs
		Set<Id> accountsWithG6ConvFlgSet = new Set<Id>();//Set holds the Account Ids, which have the G6_Starter_Kit_Conversion__c set
		List<Marketing_Interaction__c> newMIsListToBeCreated = new List<Marketing_Interaction__c>();//List of MIs to be created
		List<Account> accntToBeUpdatedWithG6ConvFlag = new List<Account>();//List of accounts to be updated with G6 Converstion Flag
		Set<Id> g6ProdOnBoardAccnts = new Set<Id>();
		Set<Id> g6ReordRemindAccnts = new Set<Id>();
		
		
		for(Account newAccnt : newTriggerAccount.values())
		{	
			//Get Account before update for Reference
			Account oldAccnt = oldTriggerAccount.get(newAccnt.Id);
			//Find if there are any new Closed Orders for the account
			if((oldAccnt.Number_of_Orders__c != newAccnt.Number_of_Orders__c) && (oldAccnt.Number_of_Orders__c == null || oldAccnt.Number_of_Orders__c == 0) && newAccnt.Number_of_Orders__c == 1)
			{
                system.debug('***FOUND ENTRY FOR THE CA CUSTOMER ONBOARDING FLOW');
				accountsToProcessForMIsSet.add(newAccnt.Id + '|' + 'CA - Customer Onboarding');
			}
			system.debug('newAccnt.G6_Transmitter_Ship_Date__c' + newAccnt.G6_Transmitter_Ship_Date__c);
			//Find if there are any new G6 Transmitter shipped for the customer
			if((oldAccnt.G6_Transmitter_Ship_Date__c != newAccnt.G6_Transmitter_Ship_Date__c) && oldAccnt.G6_Transmitter_Ship_Date__c == null && newAccnt.G6_Transmitter_Ship_Date__c != null && Date.Today() >= newAccnt.G6_Transmitter_Ship_Date__c)
			{
                g6ProdOnBoardAccnts.add(newAccnt.Id);
				accountsToProcessForMIsSet.add(newAccnt.Id + '|' + 'CA - Product Onboarding - G6');
				system.debug('***FOUND ENTRY FOR CA PRODUCT ONBOARDING G6');
			}
			system.debug('newAccnt.G6_Starter_Kit_Ship_Date__c' + newAccnt.G6_Starter_Kit_Ship_Date__c);
			//Find if there are any new Starter Kit for the account
			if((oldAccnt.G6_Starter_Kit_Ship_Date__c != newAccnt.G6_Starter_Kit_Ship_Date__c) && newAccnt.G6_Starter_Kit_Ship_Date__c != null && Date.Today() >= newAccnt.G6_Starter_Kit_Ship_Date__c)
			{
				g6ReordRemindAccnts.add(newAccnt.Id);
                accountsToProcessForMIsSet.add(newAccnt.Id + '|' + 'CA - Reorder Reminder - G6 Starter Kit');
				system.debug('***FOUND ENTRY FOR CA REORDER REMINDER G6 STARTER KIT');
			}
			//Find if account has the starter kit order and now has ordered a new product
			if((oldAccnt.Number_of_Orders__c != newAccnt.Number_of_Orders__c) && newAccnt.Number_of_Orders__c != null && newAccnt.Number_of_Orders__c > 1 && oldAccnt.G6_Starter_Kit_Ship_Date__c != null && newAccnt.G6_Starter_Kit_Conversion__c == false )
			{
                system.debug('***FOUND ENTRY FOR NEW ORDER AFTER STARTER KIT TO SET THE CONVERTED FLAG');
				accountsToProcessForMIsSet.add(newAccnt.Id + '|' + 'CA - Set Converted Flag');
			}
			//Prepare the set of Account Ids with G6_Starter_Kit_Conversion__c
			if(newAccnt.G6_Starter_Kit_Conversion__c)
				accountsWithG6ConvFlgSet.add(newAccnt.Id);
		}
		//Find if there are any MIs to be processed
		if(!accountsToProcessForMIsSet.isEmpty())
		{
			system.debug('***ENTERED THE METHOD TO PROCESS THE LOGIC');
			Set<Id> accountIdSet = new Set<Id>();
			Set<Id> caOnboardingSet = new Set<Id>();
			Set<Id> caG6ProductOnboardingSet = new Set<Id>();
			Set<Id> caG6ReorderSet = new Set<Id>();
			Map<Id, String> accntToG6XmerOrderMap = new Map<Id, String>();
			Map<Id, String> accntToG6StarterKitOrderMap = new Map<Id, String>();			
			
			//Get all the account Ids involved for processing			
			for(String str : accountsToProcessForMIsSet)
			{
				List<String> accntIdToTypeList = str.split('\\|');
				accountIdSet.add(accntIdToTypeList[0]);
			}
			
			//Get all MIs tied the accounts involved in processing, we need to use this to verify before we create the MIs
			Map<Id, Marketing_Interaction__c> miMap = new Map<Id, Marketing_Interaction__c>([SELECT Id, Account__c, Communication_Type__c FROM Marketing_Interaction__c WHERE Account__c IN : accountIdSet]);
			for(Marketing_Interaction__c mi : miMap.values())
			{
				system.debug('***EXISTING MEARKETING INTERACTIONS FOUND ');
				if(mi.Communication_Type__c == 'CA - Customer Onboarding') caOnboardingSet.add(mi.Account__c);
				if(mi.Communication_Type__c == 'CA - Product Onboarding - G6') caG6ProductOnboardingSet.add(mi.Account__c);
				if(mi.Communication_Type__c == 'CA - Reorder Reminder - G6 Starter Kit') caG6ReorderSet.add(mi.Account__c);
			}
			
			//If involvesG6ProductOnboarding = true then process below logic
			if(!g6ProdOnBoardAccnts.isEmpty())
			{
				system.debug('***ENTERED THE LOGIC FOR involvesG6ProductOnboarding');
				for(OrderItem oi : [SELECT Id, Order.Id, Order.AccountId, Order.Shipping_Method__c FROM OrderItem WHERE Product_Name__c = 'STT-GS-006' AND Order.Recordtype.Name = 'CA Sales Order' AND Order.Status = 'Closed' AND Order.AccountId IN : g6ProdOnBoardAccnts ORDER BY Order.AccountId, Order.Createddate DESC LIMIT 1])
				{
					system.debug('***FOUND ORDER WITH STT-GS-006');
					String madeupString = oi.Order.Id + '|' + oi.Order.Shipping_Method__c;
					accntToG6XmerOrderMap.put(oi.Order.AccountId, madeupString);
				}
			}
			//If involvesG6ReorderReminder = true then process below logic
			if(!g6ReordRemindAccnts.isEmpty())
			{
				system.debug('***ENTERED THE LOGIC FOR involvesG6ReorderReminder');
				Map<Id, String> accntToStarterKitOrderMap = new Map<Id, String>();
				for(OrderItem oi : [SELECT Id, Order.Id, Order.AccountId, Order.Shipping_Method__c FROM OrderItem WHERE Order.AccountId IN : g6ReordRemindAccnts AND Product_Name__c = 'CASTARTERKITG6' AND Order.Recordtype.Name = 'CA Sales Order' AND Order.Status = 'Closed' ORDER BY Order.AccountId, Order.Createddate DESC LIMIT 1])
				{
					system.debug('***FOUND ORDER WITH CASTARTERKITG6');
					String madeupString = oi.Order.Id + '|' + oi.Order.Shipping_Method__c;
					accntToG6StarterKitOrderMap.put(oi.Order.AccountId, madeupString);
				}
			}
			//Prepare the required sets required for analysis	
			for(String str : accountsToProcessForMIsSet)
			{
				List<String> accntIdToTypeList = str.split('\\|');
				Id accntId = accntIdToTypeList[0];
				//Check if the communication type is CA - Product Onboarding - G6 and equivalent MI doesn't exist before then proceed
				if(accntIdToTypeList[1] == 'CA - Product Onboarding - G6' && !caG6ProductOnboardingSet.contains(accntId) && !accntToG6XmerOrderMap.isEmpty())
				{
					system.debug('***PROCESING CA - Product Onboarding - G6');
					//Get reference to the latest Xmer order to pass in the order information in the MI
					String miReferenceFields = accntToG6XmerOrderMap.get(accntId);
					List<String> g6XmerOrderRefValues = miReferenceFields.split('\\|');//This will split the string with the Order Id and its shipping method
					//Construct information to create the MI
					newMIsListToBeCreated.add(createMI(accntId, g6XmerOrderRefValues[0], 'CA - Product Onboarding - G6', g6XmerOrderRefValues[1], 'Canada'));
				}
				//Check if the communication type is CA - Reorder Reminder - G6 Starter Kit and equivalent MI doesn't exist before then proceed
				if(accntIdToTypeList[1] == 'CA - Reorder Reminder - G6 Starter Kit' && !caG6ProductOnboardingSet.contains(accntId) && !accntToG6StarterKitOrderMap.isEmpty())
				{
					system.debug('***PROCESING CA - Reorder Reminder - G6 Starter Kit');
					//Get reference to the latest Xmer order to pass in the order information in the MI
					String miReferenceFields = accntToG6StarterKitOrderMap.get(accntId);
					List<String> g6StarterKitOrderRefValues = miReferenceFields.split('\\|');//This will split the string with the Order Id and its shipping method
					//Construct information to create the MI
					newMIsListToBeCreated.add(createMI(accntId, g6StarterKitOrderRefValues[0], 'CA - Reorder Reminder - G6 Starter Kit', g6StarterKitOrderRefValues[1], 'Canada'));
				}
				//Check the communication type and make sure there aren't any other interaction exist of the same type for the same account
				if((accntIdToTypeList[1] == 'CA - Customer Onboarding' && !caOnboardingSet.contains(accntId)))
				{
                    system.debug('***PROCESING CA - Customer Onboarding');
					newMIsListToBeCreated.add(createMI(accntId, accntId, 'CA - Customer Onboarding', null, 'Canada'));
				}
 				//For Communication type 'CA - Reorder Reminder - G6 Starter Kit' remove the conversion flag if it is already set	
				if(accntIdToTypeList[1] == 'CA - Reorder Reminder - G6 Starter Kit' && accountsWithG6ConvFlgSet.contains(accntId))
				{
                    system.debug('***SET G6_Starter_Kit_Conversion__c TO FALSE');
					accntToBeUpdatedWithG6ConvFlag.add(new Account (Id = accntId, G6_Starter_Kit_Conversion__c = false));
				}
 				//For the customer who have the Starter Kit order, when a new order is placed, we need to set the conversion flag to exit the journey
				if(accntIdToTypeList[1] == 'CA - Set Converted Flag')
				{
                    system.debug('***SET G6_Starter_Kit_Conversion__c TO TRUE');
					accntToBeUpdatedWithG6ConvFlag.add(new Account (Id = accntId, G6_Starter_Kit_Conversion__c = true));
				}
 			}
		}
		// Insert marketing interaction
		if (newMIsListToBeCreated.size() > 0) {
            system.debug('********Enter process to create new MIs');
			try { insert newMIsListToBeCreated;
			} catch (DmlException de) {
			system.debug(de);                    
			}
		}
		// Accounts to be updated
		if (accntToBeUpdatedWithG6ConvFlag.size() > 0) {
            system.debug('********Enter process to update with G6 Conversion flag');
			try { update accntToBeUpdatedWithG6ConvFlag;
			} catch (DmlException de) {
			system.debug(de);                    
			}
		}
	}

	public static void handleUKMIsForAccountUpdates(Map<Id, Account> newTriggerAccount, Map<Id, Account> oldTriggerAccount){
        
        String miCommunicationType = 'UKIE - Subscription Upsell - G6';
        List<Marketing_Interaction__c> currentMIList = [SELECT Id, Account__c, Communication_Type__c 
                                                        FROM Marketing_Interaction__c 
                                                        WHERE Account__c IN :newTriggerAccount.keySet()
                                                       	AND Communication_Type__c = :miCommunicationType];
                
        Map<Id,List<Marketing_Interaction__c>> currentMIMap = new Map<Id,List<Marketing_Interaction__c>>();
        
        for (Marketing_Interaction__c currentMI : currentMIList) {
			Id accountId = currentMI.Account__c;
            if (!currentMIMap.containsKey(accountId)) {
                currentMIMap.put(accountId, new List<Marketing_Interaction__c>());
            }
            currentMIMap.get(accountId).add(currentMI);
        }

		Id gbConsumerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('GB_Consumer').getRecordTypeId();
		Id ieConsumerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IE_Consumer').getRecordTypeId();
		
        String countryString;
        List<Marketing_Interaction__c> miList = new List<Marketing_Interaction__c>();
		
		for (Account newAccnt : newTriggerAccount.values()){
			Account oldAccnt = oldTriggerAccount.get(newAccnt.Id);
			if (newAccnt.G6_Starter_Kit_Ship_Date__c != null && (newAccnt.G6_Starter_Kit_Ship_Date__c != oldAccnt.G6_Starter_Kit_Ship_Date__c)){
				if (newAccnt.RecordTypeId == gbConsumerId){
					countryString = 'United Kingdom';
				} else if (newAccnt.RecordTypeId == ieConsumerId){
					countryString = 'Ireland';
				}
                if(!String.isBlank(countryString) && currentMIMap.get(newAccnt.Id) == null){
					miList.add(createMI(newAccnt.Id, null, miCommunicationType, null, countryString));
                }
			}
		}
        insert miList;
	}
		
	//Method to create the Marketing Interaction structure
	private static Marketing_Interaction__c createMI(Id accntId, String sourceRecordId, String communicationType, String relatedInformation, String country)
	{
		Marketing_Interaction__c mi = new Marketing_Interaction__c();               
		mi.Account__c = accntId;
		mi.Source_Record_Id__c = sourceRecordId;
		mi.Communication_Type__c = communicationType;
		mi.Related_Information__c = relatedInformation;	
		mi.Country__c = country;
		return mi;
	}
}