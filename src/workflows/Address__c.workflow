<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <outboundMessages>
        <fullName>Send_Address_To_Oracle_1</fullName>
        <apiVersion>41.0</apiVersion>
        <description>Outbound message to send Account updates
12/30/19 - Removed PROD URL - https://eu.connect.boomi.com/ws/soap/upatecustomer;boomi_auth=c2FsZXNmb3JjZUBkZXhjb21pbmMtNk82SjBPLklQVFNCSjphYWM3Y2UzNi00Yzg0LTQ3ZjMtOWRkOS1kZTlhMmU1M2M1OTY=</description>
        <endpointUrl>https://dummyurl.com</endpointUrl>
        <fields>Account_Party_Id__c</fields>
        <fields>Account__c</fields>
        <fields>Active_Start_Date__c</fields>
        <fields>Address_Line_1__c</fields>
        <fields>Address_Line_2__c</fields>
        <fields>Address_Line_3__c</fields>
        <fields>City__c</fields>
        <fields>Country__c</fields>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>Id</fields>
        <fields>Oracle_Cust_Site_Id__c</fields>
        <fields>Oracle_Customer_Id__c</fields>
        <fields>Oracle_Location_Id__c</fields>
        <fields>Oracle_Party_Site_Id__c</fields>
        <fields>Postal_Code__c</fields>
        <fields>Primary_Flag__c</fields>
        <fields>Record_Type_Name__c</fields>
        <fields>State__c</fields>
        <fields>Type__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>salesforce.admin@dexcom.com.eu</integrationUser>
        <name>Send Address To Oracle</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>DE Send Address To Oracle</fullName>
        <actions>
            <name>Send_Address_To_Oracle_1</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>Jagan 08/11/2017 - Rule sends address record to Oracle upon create or update provided the associated account has Party Id associated.</description>
        <formula>AND( BEGINS(RecordType.DeveloperName, &apos;DE&apos;), NOT(ISBLANK(Account__r.Party_Id__c)), OR( OR( ISNEW(), ISCHANGED(Address_Line_1__c), ISCHANGED(Address_Line_2__c), ISCHANGED(Address_Line_3__c), ISCHANGED(City__c), ISCHANGED(State__c), ISCHANGED(Postal_Code__c), ISCHANGED(Primary_Flag__c), ISCHANGED(Type__c) ), AND( ISCHANGED(Send_To_Oracle__c), Send_To_Oracle__c = true ) )	)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
