<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Create_SDJob_to_True</fullName>
        <field>Create_SDJob__c</field>
        <literalValue>1</literalValue>
        <name>Set Create SDJob to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>All_Update Field to Create SDJob</fullName>
        <active>true</active>
        <criteriaItems>
            <field>SDJob_Temp__c.Create_SDJob__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow will set a flag on the temp record, which will invoke the S-Doc creation. The temp record will be inserted from BPClsOrder class.</description>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Create_SDJob_to_True</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>SDJob_Temp__c.CreatedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
