<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_External_Id_On_Quote_Line_Item</fullName>
        <field>External_Id__c</field>
        <formula>Quote.QuoteNumber + &apos; - &apos; + Product2.Name</formula>
        <name>Update External Id On Quote Line Item</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Medical_Advice_Feature_Code</fullName>
        <description>Updates Medical Advice Feature code value on Quote line item from Opportunity line item.</description>
        <field>Medical_Advice_Feature_Code__c</field>
        <formula>IF( Is_Medical_Advice_Number_Product__c == TRUE, Text(OpportunityLineItem.Medical_Advice_Feature__c), &apos;&apos;)</formula>
        <name>Update Medical Advice Feature Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Line_Item_Price</fullName>
        <description>Update Quote Line Item Price based on the split price</description>
        <field>UnitPrice</field>
        <formula>If (NOT(ISBLANK(PricebookEntry.Split_Price__c)), PricebookEntry.Split_Price__c ,  OpportunityLineItem.UnitPrice)</formula>
        <name>Update Quote Line Item Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quote_Line_Item_Qty</fullName>
        <description>Update Quote Line Item Qty based on the Split Qty</description>
        <field>Quantity</field>
        <formula>If (NOT(ISBLANK(PricebookEntry.Split_Qty__c)), PricebookEntry.Split_Qty__c ,  OpportunityLineItem.Quantity)</formula>
        <name>Update Quote Line Item Qty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>All_Update External Id On Quote Line Item</fullName>
        <actions>
            <name>Update_External_Id_On_Quote_Line_Item</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>QuoteLineItem.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update the external id to Quote Number + Product Name</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>All_Update Quote Line Item Details From Oppty Line Item</fullName>
        <actions>
            <name>Update_Medical_Advice_Feature_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Quote_Line_Item_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Quote_Line_Item_Qty</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Process will update the Medical Advice Feature code, Qty and Price value from Opportunity Line Item to Quote Line Item object</description>
        <formula>NOT(ISBLANK(OpportunityLineItem.Id))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update External Id On Quote Line Item</fullName>
        <actions>
            <name>Update_External_Id_On_Quote_Line_Item</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>QuoteLineItem.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update the external id to Quote Number + Product Name</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Medical Advice Feature Code On Quote Line Item</fullName>
        <actions>
            <name>Update_Medical_Advice_Feature_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>QuoteLineItem.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Process will update the Medical Advice Feature code value from Opportunity Line Item to Quote Line Item object</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Quote Line Item Details From Oppty Line Item</fullName>
        <actions>
            <name>Update_Medical_Advice_Feature_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Quote_Line_Item_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Quote_Line_Item_Qty</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Process will update the Medical Advice Feature code, Qty and Price value from Opportunity Line Item to Quote Line Item object</description>
        <formula>NOT(ISBLANK(OpportunityLineItem.Id))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
