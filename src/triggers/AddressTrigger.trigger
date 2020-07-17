trigger AddressTrigger on Address__c (before insert, before update, after insert,after update) {
/*******************************************************************************************************************
@Author        : Jagan Periyakaruppan
@Date Created    : 4/30/2017
@Description    : Trigger invokes handler class to update Address information on parent Account
********************************************************************************************************************/    
    if(trigger.isAfter) 
    {
        //Proceed to make changes to Address object only when the address change (Bill To or Ship To) happened from Address object        
        if(trigger.isInsert)
        {
            if(ClsAccountAddressTriggerStaticClass.addressChangeInvokedFromAddress)
                ClsAddressTriggerHandler.ProcessAddressInsert(trigger.new);
            ClsAddressTriggerHandler.processSystemOfOriginOnAddressCreate(trigger.new); // Set the System_Of_Origin and System_Of_Origin_Id 
            ClsAddressTriggerHandler.handleAddressCreatePublish(trigger.new);    // Publish Address Create Events
            ClsAddressTriggerHandler.processOneKeyAddress(trigger.new);//Process IQVIA address --> Create Billto when Shipto is inserted
        }
        if(trigger.isUpdate)
        {
            if(ClsAccountAddressTriggerStaticClass.addressChangeInvokedFromAddress)
                ClsAddressTriggerHandler.ProcessAddressUpdate(trigger.newmap, trigger.oldmap);
            ClsAddressTriggerHandler.handleAddressUpdatePublish(trigger.newMap, trigger.oldMap);   // Publish Address Update Events.
        }
    }
    
}