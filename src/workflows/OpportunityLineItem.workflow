<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Medical_Advice_Number_Exception</fullName>
        <description>Update the medical advice number exception field based on the Product code stamped on the Product.</description>
        <field>Medical_Advice_Number_Exception__c</field>
        <formula>VALUE(SUBSTITUTE( PricebookEntry.Product2.ProductCode,  &quot;.&quot;,  &quot;&quot; ))</formula>
        <name>Update Medical Advice Number Exception</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Product_Type</fullName>
        <description>Update product type</description>
        <field>Product_Type__c</field>
        <literalValue>Transmitter</literalValue>
        <name>Update Product Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Product_Type_System</fullName>
        <field>Product_Type__c</field>
        <literalValue>Virtual</literalValue>
        <name>Update Product Type - System</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>DE_Update Xmer Med Adv No Exception</fullName>
        <actions>
            <name>Update_Medical_Advice_Number_Exception</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Product_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Jagan 09/08/2018 - Rules updates the &apos;Xmer_Medical_Advice_Number_Exception__c&apos; upon Opportunity product creation.</description>
        <formula>AND(  Opportunity.RecordType.DeveloperName = &apos;DE_Opportunity&apos;, PricebookEntry.Product2.Is_Medical_Advice_Number_Exception__c = true, TEXT(PricebookEntry.Product2.Product_Type__c) = &apos;Transmitter&apos; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>DE_Update Xmer Med Adv No Exception - System</fullName>
        <actions>
            <name>Update_Medical_Advice_Number_Exception</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Product_Type_System</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Jagan 03/27/2019 - Rules updates the &apos;Xmer_Medical_Advice_Number_Exception__c&apos; upon Opportunity product creation.</description>
        <formula>AND( 			 Opportunity.RecordType.DeveloperName = &apos;DE_Opportunity&apos;,	 	PricebookEntry.Product2.Is_Medical_Advice_Number_Exception__c = true, 				  	TEXT(PricebookEntry.Product2.Product_Type__c) = &apos;Virtual&apos; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Xmer Med Adv No Exception</fullName>
        <actions>
            <name>Update_Medical_Advice_Number_Exception</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Product_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Jagan 09/08/2018 - Rules updates the &apos;Xmer_Medical_Advice_Number_Exception__c&apos; upon Opportunity product creation.</description>
        <formula>AND( PricebookEntry.Product2.Is_Medical_Advice_Number_Exception__c = true, TEXT(PricebookEntry.Product2.Product_Type__c) = &apos;Transmitter&apos; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Xmer Med Adv No Exception - System</fullName>
        <actions>
            <name>Update_Medical_Advice_Number_Exception</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Product_Type_System</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Jagan 03/27/2019 - Rules updates the &apos;Xmer_Medical_Advice_Number_Exception__c&apos; upon Opportunity product creation.</description>
        <formula>AND( 				 	PricebookEntry.Product2.Is_Medical_Advice_Number_Exception__c = true, 				  	TEXT(PricebookEntry.Product2.Product_Type__c) = &apos;Virtual&apos; )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
