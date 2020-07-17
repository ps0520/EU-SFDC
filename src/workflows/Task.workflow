<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Log_a_Call_Subject</fullName>
        <field>Subject</field>
        <formula>&apos;Call - &apos; +  Text(Call_Reason__c)</formula>
        <name>Update Log a Call Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Log a call Subject</fullName>
        <actions>
            <name>Update_Log_a_Call_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Task.Type</field>
            <operation>equals</operation>
            <value>Call</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Call_Reason__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update log a call subject if a call reason is filled in</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
