<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_SSIP_Product_Name</fullName>
        <field>Product_Name__c</field>
        <formula>Product_Name__c +  TEXT(NOW())</formula>
        <name>Update SSIP Product Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update SSIP Rule On Create</fullName>
        <active>true</active>
        <criteriaItems>
            <field>SSIP_Rule__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Inactive</value>
        </criteriaItems>
        <description>Upon Creation of SSIP Rule update the Product Name and Account Id</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update SSIP Rule Product Name</fullName>
        <actions>
            <name>Update_SSIP_Product_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SSIP_Rule__c.Status__c</field>
            <operation>equals</operation>
            <value>Inactive</value>
        </criteriaItems>
        <description>Update Product Name when the SSIP Status is changed to inactive</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
