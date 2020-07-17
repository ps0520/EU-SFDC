/**********************************************************************
@Description    : Class will handle logic for SSIPRule object
***********************************************************************/
public class SSIPRuleTriggerHandler {
    
    
    public void onBeforeInsert(List<SSIP_Rule__c> lstSSIPRuleNew){
        //Collection variables
        Set<Id> productIds = new Set<Id>();
        Set<Id> PBIds = new set<Id>();
        Map<Id, String> productNameMap = new Map<Id, String>();
        List<PricebookEntry> PBEItemList = new List<PricebookEntry>();
        //Prepares the product map for the rules that need to be updated with Product Name
        for(SSIP_Rule__c objSSIPRule : lstSSIPRuleNew){
            if(objSSIPRule.Product__c != null && objSSIPRule.Product_Name__c == null) productIds.add(objSSIPRule.Product__c);
           
            PBIds.add(objSSIPRule.Price_Book__c); 
        }
        if(!productIds.isEmpty()){
            for(Product2 prod : [SELECT Id, Name FROM Product2 WHERE Id IN : productIds])
                productNameMap.put(prod.Id, prod.Name);
        }
        for(PricebookEntry pbe : [select id, Name, UnitPrice, Pricebook2Id, Product2Id from PricebookEntry where Pricebook2Id IN :PBIds] )   PBEItemList.add(pbe); 
        
        system.debug('PBEItemList'+PBEItemList);
        //For every rule update the 18 digit account id and Product name based on the chosen product
        for(SSIP_Rule__c objSSIPRule : lstSSIPRuleNew)
        {
            objSSIPRule.Account_18_Digit_Id__c = objSSIPRule.Account__c;
            Boolean Prodfound = false;
            for(PricebookEntry PBE :PBEItemList){  
                if(PBE.Pricebook2Id == objSSIPRule.Price_Book__c && PBE.Product2Id == objSSIPRule.Product__c){                    
                    Prodfound = True ;
                    objSSIPRule.Unit_Price__c = PBE.UnitPrice;
                    
                }
            }
            if(!Prodfound){
                objSSIPRule.addError('Wrong combination of Product and Pricbook.');
                return;
            }  
            if(!productNameMap.isEmpty() && objSSIPRule.Product__c != null && objSSIPRule.Product_Name__c == null && productNameMap.containsKey(objSSIPRule.Product__c))
                objSSIPRule.Product_Name__c = productNameMap.get(objSSIPRule.Product__c);
        }    
        
       
    }
    
    public void onAfterInsert(List<SSIP_Rule__c> lstSSIPRuleNew){
        createSSIPScheduleRecord(lstSSIPRuleNew, new Map<Id,SSIP_Rule__c>());
    }
    
    public void onAfterUpdate(List<SSIP_Rule__c> lstSSIPRuleNew, Map<Id, SSIP_Rule__c> mapSSIPRuleOld){
        createSSIPScheduleRecord(lstSSIPRuleNew, mapSSIPRuleOld);
    }
    
    
    private void createSSIPScheduleRecord(List<SSIP_Rule__c> lstSSIPRuleNew, Map<Id, SSIP_Rule__c> mapSSIPRuleOld){
        Map<Id, SSIP_Rule__c> mapSSIPRuleNew = new Map<Id, SSIP_Rule__c>(lstSSIPRuleNew);
        Map<Id, Id> ruleToFundMap = new Map<Id, Id>();		
        Map<Id, List<SSIP_Schedule__c>> mapSSIPIdTolstSSIPSchedule = new Map<Id, List<SSIP_Schedule__c>>();
        List<SSIP_Schedule__c> lstSSIPSchedule = new List<SSIP_Schedule__c>();
        Set<SSIP_Schedule__c>  lstSSIPSet  = new Set<SSIP_Schedule__c>();        
        List<SSIP_Schedule__c> lstSSIPScheduleToDelete = new List<SSIP_Schedule__c>();
        Set<Id> setSSIPRuleId = new Set<Id>();
        
      
        //Find if the Rule has order association and prepare the map
        for(SSIP_Rule__c objSSIPRule : [SELECT Id, First_Order__r.Fund__c FROM SSIP_Rule__c WHERE First_Order__c != null AND Id IN: lstSSIPRuleNew]){
            if(objSSIPRule.First_Order__r.Fund__c != null)
                ruleToFundMap.put(objSSIPRule.Id, objSSIPRule.First_Order__r.Fund__c);
        }        
        
        //Process the SSIP Rule records to create Schedules
        for(SSIP_Rule__c objSSIPRule : lstSSIPRuleNew){
            System.debug('createSSIPScheduleRecord for loop');                
      
            Integer count = objSSIPRule.Schedule_Count__c != null ? Integer.valueOf(objSSIPRule.Schedule_Count__c) : 3;
            Integer firstRepeatOrderLeadDays = objSSIPRule.First_Repeat_Order_Lead_Days__c != null ? Integer.valueOf(objSSIPRule.First_Repeat_Order_Lead_Days__c) : 0;
            if((Trigger.isInsert && objSSIPRule.First_Shipment_Date__c != null) || (Trigger.isUpdate && mapSSIPRuleOld.get(objSSIPRule.Id).First_Shipment_Date__c == null && objSSIPRule.First_Shipment_Date__c != null) && objSSIPRule.Frequency_In_Days__c != null){
                for(Integer i = 1; i <= count; i++){
                    lstSSIPSchedule.add(new SSIP_Schedule__c(Account__c = objSSIPRule.Account__c, Country__c = objSSIPRule.Country__c, Payment_Term__c = objSSIPRule.Payment_Term__c, Shipping_Address__c = objSSIPRule.Shipping_Address__c,
                                                             Shipping_Method__c = objSSIPRule.Shipping_Method__c, SSIP_Rule__c = objSSIPRule.Id, Status__c = 'Open',
                                                             Fund__c = !ruleToFundMap.isEmpty() ? ruleToFundMap.get(objSSIPRule.Id) : null, 	
                                                             Schedule_Date__c = objSSIPRule.First_Shipment_Date__c.addDays(Integer.valueOf(objSSIPRule.Frequency_In_Days__c) * i) - firstRepeatOrderLeadDays));
                }
            }                        
            if(Trigger.isUpdate && ((mapSSIPRuleOld.get(objSSIPRule.Id).First_Shipment_Date__c != null && objSSIPRule.Rule_End_Date__c != mapSSIPRuleOld.get(objSSIPRule.Id).Rule_End_Date__c) 
                                    || mapSSIPRuleOld.get(objSSIPRule.Id).Payment_Term__c != objSSIPRule.Payment_Term__c || mapSSIPRuleOld.get(objSSIPRule.Id).Shipping_Method__c != objSSIPRule.Shipping_Method__c
                                    /*|| (objSSIPRule.Rule_Re_schedule_Date__c != null && mapSSIPRuleOld.get(objSSIPRule.Id).Rule_Re_schedule_Date__c != objSSIPRule.Rule_Re_schedule_Date__c ) */)){
                                       
                                        system.debug('objSSIPRule.Id = '+ objSSIPRule.Id);
                                        setSSIPRuleId.add(objSSIPRule.Id);
                                    }
            if(Trigger.isUpdate && (objSSIPRule.Rule_Re_schedule_Date__c != null && mapSSIPRuleOld.get(objSSIPRule.Id).Rule_Re_schedule_Date__c != objSSIPRule.Rule_Re_schedule_Date__c ))
                handleScheduleChange(objSSIPRule);
        }
        //Set Payment Term, Shipping Method from the Rule to the schedule records. Also delete all schedules once the Rule End Date is set on the Rule
        for(SSIP_Schedule__c objSSIPSchedule : [SELECT Id, SSIP_Rule__c, SSIP_Rule__r.Rule_End_Date__c, Rescheduled_Shipment_Date__c, Schedule_Date__c FROM SSIP_Schedule__c WHERE SSIP_Rule__c IN: setSSIPRuleId AND Status__c = 'Open']){
            System.debug('createSSIPScheduleRecord for loop 2');                
      
            //Process deletion logic first and then go to update logic
            //If the Reschedued Shipment Date is populated on the SSIP Schedule that takes the precedence
            if(objSSIPSchedule.Rescheduled_Shipment_Date__c != null && (objSSIPSchedule.Rescheduled_Shipment_Date__c > objSSIPSchedule.SSIP_Rule__r.Rule_End_Date__c))
                lstSSIPScheduleToDelete.add(objSSIPSchedule);
            else
                if(objSSIPSchedule.Rescheduled_Shipment_Date__c == null && (objSSIPSchedule.Schedule_Date__c > objSSIPSchedule.SSIP_Rule__r.Rule_End_Date__c))
                lstSSIPScheduleToDelete.add(objSSIPSchedule);
            else{
                if(mapSSIPRuleNew.get(objSSIPSchedule.SSIP_Rule__c).Payment_Term__c != mapSSIPRuleOld.get(objSSIPSchedule.SSIP_Rule__c).Payment_Term__c){
                    objSSIPSchedule.Payment_Term__c = mapSSIPRuleNew.get(objSSIPSchedule.SSIP_Rule__c).Payment_Term__c;
                }
                if(mapSSIPRuleNew.get(objSSIPSchedule.SSIP_Rule__c).Shipping_Method__c != mapSSIPRuleOld.get(objSSIPSchedule.SSIP_Rule__c).Shipping_Method__c){
                    objSSIPSchedule.Shipping_Method__c = mapSSIPRuleNew.get(objSSIPSchedule.SSIP_Rule__c).Shipping_Method__c;
                }    
                // Re-Scheduling ssip schedule  - Navneet
                /* This is being handled from else where.        
                if(Trigger.isUpdate && (mapSSIPRuleNew.get(objSSIPSchedule.SSIP_Rule__c).Rule_Re_schedule_Date__c != null && mapSSIPRuleNew.get(objSSIPSchedule.SSIP_Rule__c).Rule_Re_schedule_Date__c != mapSSIPRuleOld.get(objSSIPSchedule.SSIP_Rule__c).Rule_Re_schedule_Date__c) ){
                    Integer firstRepeatOrderLeadDays = mapSSIPRuleNew.get(objSSIPSchedule.SSIP_Rule__c).First_Repeat_Order_Lead_Days__c != null ? Integer.valueOf(mapSSIPRuleNew.get(objSSIPSchedule.SSIP_Rule__c).First_Repeat_Order_Lead_Days__c) : 7;
                    Date firstsDate = mapSSIPRuleNew.get(objSSIPSchedule.SSIP_Rule__c).First_Shipment_Date__c ;
                    Integer difdays = firstsDate.daysBetween(mapSSIPRuleNew.get(objSSIPSchedule.SSIP_Rule__c).Rule_Re_schedule_Date__c) ;
                    objSSIPSchedule.Rescheduled_Shipment_Date__c = objSSIPSchedule.Schedule_Date__c.addDays(difdays); 
                    //handleScheduleChange();
                }
				*/
                
                lstSSIPSchedule.add(objSSIPSchedule);
            }
        }
        delete lstSSIPScheduleToDelete;
        upsert lstSSIPSchedule;
        
    }
    public Static void handleScheduleChange(SSIP_Rule__c objSSIPRule) {
        List<SSIP_Schedule__c> scheds = [Select Id, Schedule_Date__c from SSIP_Schedule__c where SSIP_Rule__c = :objSSIPRule.id and Status__c = 'OPEN'];
        Integer count = objSSIPRule.Schedule_Count__c != null ? Integer.valueOf(objSSIPRule.Schedule_Count__c) : 3;
        Integer firstRepeatOrderLeadDays = objSSIPRule.First_Repeat_Order_Lead_Days__c != null ? Integer.valueOf(objSSIPRule.First_Repeat_Order_Lead_Days__c) : 0;
        List<SSIP_Schedule__c> lstSSIPSchedule = new List<SSIP_Schedule__c>();
        integer schedCounter = 0;
        for(SSIP_Schedule__c sched : scheds) {
            if (schedCounter == 0 && (objSSIPRule.Rule_End_Date__c == null ||  objSSIPRule.Rule_Re_schedule_Date__c <= objSSIPRule.Rule_End_Date__c)) 
                lstSSIPSchedule.add(new SSIP_Schedule__c(id=sched.Id, Schedule_Date__c = objSSIPRule.Rule_Re_schedule_Date__c));
            else if (objSSIPRule.Rule_End_Date__c == null  || objSSIPRule.Rule_Re_schedule_Date__c.adddays((Integer) ((objSSIPRule.Frequency_In_Days__c * schedCounter) - firstRepeatOrderLeadDays)) <= objSSIPRule.Rule_End_Date__c) 
                lstSSIPSchedule.add(new SSIP_Schedule__c(id=sched.Id, Schedule_Date__c = objSSIPRule.Rule_Re_schedule_Date__c.adddays((Integer) ((objSSIPRule.Frequency_In_Days__c * schedCounter) - firstRepeatOrderLeadDays))));
        	schedCounter++;
        }
        If (count > schedCounter) {
            for(Integer i = schedCounter; i < count; i++){
                if (objSSIPRule.Rule_End_Date__c == null  || objSSIPRule.Rule_Re_schedule_Date__c.adddays((Integer) ((objSSIPRule.Frequency_In_Days__c * i) - firstRepeatOrderLeadDays)) <= objSSIPRule.Rule_End_Date__c)
                        lstSSIPSchedule.add(new SSIP_Schedule__c(Account__c = objSSIPRule.Account__c, Country__c = objSSIPRule.Country__c, Payment_Term__c = objSSIPRule.Payment_Term__c, Shipping_Address__c = objSSIPRule.Shipping_Address__c,
                                                                 Shipping_Method__c = objSSIPRule.Shipping_Method__c, SSIP_Rule__c = objSSIPRule.Id, Status__c = 'Open',
                                                                 //Fund__c = !ruleToFundMap.isEmpty() ? ruleToFundMap.get(objSSIPRule.Id) : null, 	
                                                                 Schedule_Date__c = objSSIPRule.Rule_Re_schedule_Date__c.addDays(Integer.valueOf(objSSIPRule.Frequency_In_Days__c) * i) - firstRepeatOrderLeadDays));
            }
        }
        upsert lstSSIPSchedule;

    }
}