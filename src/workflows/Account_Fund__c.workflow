<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Account_Fund_Account_Id_on_Insert</fullName>
        <description>Update Account Id on Account Fund</description>
        <field>Account_18_Digit_Id__c</field>
        <formula>Account__c</formula>
        <name>Update Account Fund Account Id on Insert</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Account_Fund_Fund_Id_on_Insert</fullName>
        <description>Populate the Fund Id based on the Fund association on the Account Fund object</description>
        <field>Fund_18_Digit_Id__c</field>
        <formula>Fund__c</formula>
        <name>Update Account Fund Fund Id on Insert</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Account Fund Ids on Insert</fullName>
        <actions>
            <name>Update_Account_Fund_Account_Id_on_Insert</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Account_Fund_Fund_Id_on_Insert</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account_Fund__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>When record is inserted populate the account Id and fund id to be used for duplicate rules.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
