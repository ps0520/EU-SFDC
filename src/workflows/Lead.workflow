<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>IE_Auto_Lead_Cancel_Email_For_Non_Responsive_Reason</fullName>
        <description>IE Auto Lead Cancel Email For Non Responsive Reason</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>ie.sales@dexcom.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/IE_Auto_Lead_Cancel_Email_For_Non_Responsive_Reason</template>
    </alerts>
    <alerts>
        <fullName>IE_Auto_Reply_Email_Send_For_New_Leads</fullName>
        <description>IE Auto Reply Email Send For New Leads</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>ie.sales@dexcom.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/IE_Auto_Reply_Email_Send_For_New_Leads</template>
    </alerts>
    <alerts>
        <fullName>UKIE_Auto_Reply_Email_Send_For_New_Leads</fullName>
        <description>UK Auto Reply Email Send For New Leads</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>gb.sales@dexcom.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/UKIE_Auto_Reply_Email_Send_For_New_Leads</template>
    </alerts>
    <alerts>
        <fullName>UK_Auto_Lead_Cancel_Email_For_Non_Responsive_Reason</fullName>
        <description>UK Auto Lead Cancel Email For Non Responsive Reason</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>gb.sales@dexcom.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/UK_Auto_Lead_Cancel_Email_For_Non_Responsive_Reason</template>
    </alerts>
    <alerts>
        <fullName>UK_Auto_Reply_Email_Send_For_New_Leads</fullName>
        <description>UK Auto Reply Email Send For New Leads</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>gb.sales@dexcom.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/UK_Auto_Reply_Email_Send_For_New_Leads</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Lead_Email_Opt_In_Modified_Date</fullName>
        <description>Update Email Opt In Last Modified date when the Optn In happens</description>
        <field>Email_Opt_In_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>Update Lead Email Opt In Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Email_Opt_Out_List_False</fullName>
        <field>Email_Opt_Out_List__c</field>
        <literalValue>False</literalValue>
        <name>Update Lead Email Opt Out List False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Email_Opt_Out_List_True</fullName>
        <description>Update &apos;Email Opt Out List&apos; on Lead to True</description>
        <field>Email_Opt_Out_List__c</field>
        <literalValue>True</literalValue>
        <name>Update Lead Email Opt Out List True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Email_Opt_Out_Modified_Date</fullName>
        <description>Update Email Opt Out Last Modified date when the OptOut happens</description>
        <field>Email_Opt_Out_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>Update Lead Email Opt Out Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SMS_360_Value_To_False</fullName>
        <field>tdc_tsw__SMS_Opt_out__c</field>
        <literalValue>0</literalValue>
        <name>Update SMS 360 Value To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SMS_360_Value_To_True</fullName>
        <field>tdc_tsw__SMS_Opt_out__c</field>
        <literalValue>1</literalValue>
        <name>Update SMS 360 Value To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SMS_Opt_In_Value_To_False</fullName>
        <field>SMS_Opt_In_List__c</field>
        <literalValue>False</literalValue>
        <name>Update SMS Opt In Value To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_SMS_Opt_In_Value_To_True</fullName>
        <field>SMS_Opt_In_List__c</field>
        <literalValue>True</literalValue>
        <name>Update SMS Opt In Value To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>All Lead Update SMS 360 To False Based On SMS Opt In</fullName>
        <actions>
            <name>Update_SMS_360_Value_To_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When SMS Opt Out is selected manually then the corresponding SMS 360 value need to be updated</description>
        <formula>AND (ISCHANGED( SMS_Opt_In_List__c ), Text(SMS_Opt_In_List__c) = &apos;True&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>All Lead Update SMS 360 To True Based On SMS Opt In</fullName>
        <actions>
            <name>Update_SMS_360_Value_To_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When SMS Opt Out is selected manually then the corresponding SMS 360 value need to be updated</description>
        <formula>AND (ISCHANGED( SMS_Opt_In_List__c ), Text(SMS_Opt_In_List__c) = &apos;False&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>All Lead Update SMS Opt In To False Based On SMS 360</fullName>
        <actions>
            <name>Update_SMS_Opt_In_Value_To_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When SMS Opt Out is selected via SMS 360 update the corresponding SMS Opt In field value</description>
        <formula>AND(ISCHANGED( tdc_tsw__SMS_Opt_out__c), tdc_tsw__SMS_Opt_out__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>All Lead Update SMS Opt In To True Based On SMS 360</fullName>
        <actions>
            <name>Update_SMS_Opt_In_Value_To_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When SMS Opt Out is selected via SMS 360 update the corresponding SMS Opt In field value</description>
        <formula>AND(ISCHANGED(tdc_tsw__SMS_Opt_out__c), NOT(tdc_tsw__SMS_Opt_out__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>All_Lead Update Email Opt In Fields On False</fullName>
        <actions>
            <name>Update_Lead_Email_Opt_Out_List_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Lead_Email_Opt_Out_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Email_Opt_In_List__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Based on the &apos;Email Opt In List&apos; being False actions need to be taken</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>All_Lead Update Email Opt In Fields On True</fullName>
        <actions>
            <name>Update_Lead_Email_Opt_In_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Lead_Email_Opt_Out_List_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Email_Opt_In_List__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Based on the &apos;Email Opt In List&apos; being True actions need to be taken</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IE Auto Lead Cancel Email For Non Responsive Reason</fullName>
        <actions>
            <name>IE_Auto_Lead_Cancel_Email_For_Non_Responsive_Reason</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workflow to trigger email when the Lead is cancelled with Non Responsive reason</description>
        <formula>AND(  RecordType.Name = &apos;IE Person Lead&apos;, ISCHANGED( Status ), ISPICKVAL(Status, &apos;Cancelled&apos;), INCLUDES( Cancelled_Reasons__c , &apos;Non-responsive&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IE Auto Reply Email For New Leads</fullName>
        <actions>
            <name>IE_Auto_Reply_Email_Send_For_New_Leads</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>IE Person Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Once the lead enters Dexcom, this email should be sent out.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UK Auto Lead Cancel Email For Non Responsive Reason</fullName>
        <actions>
            <name>UK_Auto_Lead_Cancel_Email_For_Non_Responsive_Reason</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workflow to trigger email when the Lead is cancelled with Non Responsive reason</description>
        <formula>AND(  RecordType.Name = &apos;GB Person Lead&apos;, ISCHANGED( Status ), ISPICKVAL(Status, &apos;Cancelled&apos;), INCLUDES( Cancelled_Reasons__c , &apos;Non-responsive&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UK Auto Reply Email For New Leads</fullName>
        <actions>
            <name>UKIE_Auto_Reply_Email_Send_For_New_Leads</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UK_Auto_Reply_Email_Send_For_New_Leads</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>GB Person Lead</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Once the lead enters Dexcom, this email should be sent out.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
