<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Cloned_Case_Status_To_Unresolved</fullName>
        <field>Status</field>
        <literalValue>Unresolved</literalValue>
        <name>Update Cloned Case Status To Unresolved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Integrated_Date_To_Blank</fullName>
        <description>Update Integration Executed date to blank when a cloned case is created.</description>
        <field>Integration_Executed_Date_Time__c</field>
        <name>Update Integrated Date To Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Integration_Executed_To_No</fullName>
        <description>Update case status to Unresolved when the case is cloned.</description>
        <field>Integration_Executed__c</field>
        <literalValue>No</literalValue>
        <name>Update Integration Executed To No</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Case Status On Cloning</fullName>
        <actions>
            <name>Update_Cloned_Case_Status_To_Unresolved</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Integrated_Date_To_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Integration_Executed_To_No</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Udate case status to Unresolved when the case is cloned.</description>
        <formula>OR(
 ISPICKVAL( Status , &apos;New&apos;),
	AND(
	 			 ISPICKVAL(Integration_Executed__c, &apos;Yes&apos;) ,
			 	 NOT(ISBLANK(Integration_Executed_Date_Time__c)) 
				)
)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
