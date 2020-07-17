<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Accnt_Email_Opt_In_Modified_Date</fullName>
        <description>Update Email Opt In Last Modified date when the Optn In happens</description>
        <field>Email_Opt_In_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>Update Accnt Email Opt In Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_Email_Opt_Out_List_False</fullName>
        <description>Update &apos;Email Opt Out List&apos; on Lead to False</description>
        <field>Email_Opt_Out_List__c</field>
        <literalValue>False</literalValue>
        <name>Update Accnt Email Opt Out List False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_Email_Opt_Out_List_True</fullName>
        <description>Update &apos;Email Opt Out List&apos; on Lead to True</description>
        <field>Email_Opt_Out_List__c</field>
        <literalValue>True</literalValue>
        <name>Update Accnt Email Opt Out List True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_Email_Opt_Out_Modified_Date</fullName>
        <description>Update Email Opt Out Last Modified date when the OptOut happens</description>
        <field>Email_Opt_Out_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>Update Accnt Email Opt Out Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_Mail_Opt_In_Modified_Date</fullName>
        <description>Based on the &apos;Mail Opt In&apos; being True actions need to be taken</description>
        <field>Mail_Opt_In_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>Update Accnt Mail Opt In Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_Mail_Opt_Out_List_False</fullName>
        <description>Update &apos;Mail Opt Out List&apos; on Lead to False</description>
        <field>Mail_Opt_Out_List__c</field>
        <literalValue>False</literalValue>
        <name>Update Accnt Mail Opt Out List False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_Mail_Opt_Out_List_True</fullName>
        <description>Based on the &apos;Mail Opt In List&apos; being False actions need to be taken</description>
        <field>Mail_Opt_Out_List__c</field>
        <literalValue>True</literalValue>
        <name>Update Accnt Mail Opt Out List True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_Mail_Opt_Out_Modified_Date</fullName>
        <description>Update Mail Opt Out Last Modified date when the OptOut happens</description>
        <field>Mail_Opt_Out_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>Update Accnt Mail Opt Out Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_Phone_Opt_In_Modified_Date</fullName>
        <description>Update Phone Opt In Last Modified date when the Optn In happens</description>
        <field>Phone_Opt_In_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>Update Accnt Phone Opt In Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_Phone_Opt_Out_List_False</fullName>
        <description>Based on the &apos;Phone Opt In&apos; being True actions need to be taken</description>
        <field>Phone_Opt_Out__c</field>
        <literalValue>False</literalValue>
        <name>Update Accnt Phone Opt Out List False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_Phone_Opt_Out_List_True</fullName>
        <description>Based on the &apos;Phone Opt In List&apos; being False actions need to be taken</description>
        <field>Phone_Opt_Out__c</field>
        <literalValue>True</literalValue>
        <name>Update Accnt Phone Opt Out List True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_Phone_Opt_Out_Modified_Date</fullName>
        <description>Update Phone Opt Out Last Modified date when the OptOut happens</description>
        <field>Phone_Opt_Out_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>Update Accnt Phone Opt Out Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_SMS_Opt_In_Modified_Date</fullName>
        <description>Update SMS Opt In Last Modified date when the Optn In happens</description>
        <field>SMS_Opt_In_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>Update Accnt SMS Opt In Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_SMS_Opt_Out_List_False</fullName>
        <description>Update &apos;SMS Opt Out List&apos; on Lead to False</description>
        <field>SMS_Opt_Out_List__c</field>
        <literalValue>False</literalValue>
        <name>Update Accnt SMS Opt Out List False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_SMS_Opt_Out_List_True</fullName>
        <description>Update &apos;SMS Opt Out List&apos; on Lead to True</description>
        <field>SMS_Opt_Out_List__c</field>
        <literalValue>True</literalValue>
        <name>Update Accnt SMS Opt Out List True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Accnt_SMS_Opt_Out_Modified_Date</fullName>
        <description>Update SMS Opt Out Last Modified date when the OptOut happens</description>
        <field>SMS_Opt_Out_Last_Modified__c</field>
        <formula>NOW()</formula>
        <name>Update Accnt SMS Opt Out Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_BirthDate</fullName>
        <field>PersonBirthdate</field>
        <formula>Lead_Birth_Date__c</formula>
        <name>Update BirthDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Rx_Expiration_Date_On_Account</fullName>
        <description>Jagan 05/31/2017 - Created this field update to update the field CMN or Rx Expiration Date on Account</description>
        <field>CMN_or_Rx_Expiration_Date__c</field>
        <formula>Rx_Date_Written__c + 28</formula>
        <name>Update Rx Expiration Date On Account</name>
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
    <outboundMessages>
        <fullName>Send_Account_To_Oracle</fullName>
        <apiVersion>40.0</apiVersion>
        <description>Outbound message to send Account updates
12/30/19 - Removed Prod URL - https://eu.connect.boomi.com/ws/soap/createparty;boomi_auth=c2FsZXNmb3JjZUBkZXhjb21pbmMtNk82SjBPLklQVFNCSjphYWM3Y2UzNi00Yzg0LTQ3ZjMtOWRkOS1kZTlhMmU1M2M1OTY=</description>
        <endpointUrl>https://dummyurl.com</endpointUrl>
        <fields>Active_Start_Date__c</fields>
        <fields>CreatedDate</fields>
        <fields>Facility_Number__c</fields>
        <fields>Fax</fields>
        <fields>FirstName</fields>
        <fields>Gender__c</fields>
        <fields>Id</fields>
        <fields>Inactive_Reason__c</fields>
        <fields>Inactive__c</fields>
        <fields>Insurance_Company_Contract_Number__c</fields>
        <fields>Insurance_Company_Identification_Number__c</fields>
        <fields>LastName</fields>
        <fields>Last_Sync_Date_With_Oracle__c</fields>
        <fields>MiddleName</fields>
        <fields>Name</fields>
        <fields>Organzation_Email__c</fields>
        <fields>Party_Id__c</fields>
        <fields>PersonBirthdate</fields>
        <fields>PersonEmail</fields>
        <fields>PersonHomePhone</fields>
        <fields>PersonMobilePhone</fields>
        <fields>PersonOtherPhone</fields>
        <fields>Phone</fields>
        <fields>Prescriber_Id__c</fields>
        <fields>Primary_Phone_Contact__c</fields>
        <fields>Record_Type_Name__c</fields>
        <fields>Salutation</fields>
        <fields>Secondary_Email__c</fields>
        <fields>Title__pc</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>salesforce.admin@dexcom.com.eu</integrationUser>
        <name>Send Account To Oracle</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Send_Account_Updates_To_Oracle</fullName>
        <apiVersion>41.0</apiVersion>
        <description>Outbound message to send Account updates
12/30/19 - Removed Prod URL - https://eu.connect.boomi.com/ws/soap/updatecustomerinfo;boomi_auth=c2FsZXNmb3JjZUBkZXhjb21pbmMtNk82SjBPLklQVFNCSjphYWM3Y2UzNi00Yzg0LTQ3ZjMtOWRkOS1kZTlhMmU1M2M1OTY=</description>
        <endpointUrl>https://dummyurl.com</endpointUrl>
        <fields>Active_Start_Date__c</fields>
        <fields>CreatedDate</fields>
        <fields>Customer_Id__c</fields>
        <fields>Facility_Number__c</fields>
        <fields>Fax</fields>
        <fields>FirstName</fields>
        <fields>Gender__c</fields>
        <fields>Id</fields>
        <fields>Inactive_Reason__c</fields>
        <fields>Inactive__c</fields>
        <fields>Insurance_Company_Contract_Number__c</fields>
        <fields>Insurance_Company_Identification_Number__c</fields>
        <fields>LastName</fields>
        <fields>MiddleName</fields>
        <fields>Name</fields>
        <fields>Organzation_Email__c</fields>
        <fields>Party_Id__c</fields>
        <fields>PersonBirthdate</fields>
        <fields>PersonEmail</fields>
        <fields>PersonHomePhone</fields>
        <fields>PersonMobilePhone</fields>
        <fields>PersonOtherPhone</fields>
        <fields>Phone</fields>
        <fields>Prescriber_Id__c</fields>
        <fields>Primary_Phone_Contact__c</fields>
        <fields>Record_Type_Name__c</fields>
        <fields>Salutation</fields>
        <fields>Secondary_Email__c</fields>
        <fields>Title__pc</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>salesforce.admin@dexcom.com.eu</integrationUser>
        <name>Send Account Updates To Oracle</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>All Account Update SMS 360 To False Based On SMS Opt In</fullName>
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
        <fullName>All Account Update SMS 360 To True Based On SMS Opt In</fullName>
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
        <fullName>All Account Update SMS Opt In To False Based On SMS 360</fullName>
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
        <fullName>All Account Update SMS Opt In To True Based On SMS 360</fullName>
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
        <fullName>All Map Lead Birth Date to PersonBirthDate</fullName>
        <actions>
            <name>Update_BirthDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copy the Birthdate on the lead to Account on Conversion</description>
        <formula>AND( IsPersonAccount , ISBLANK( PersonContact.Birthdate ), NOT(ISBLANK( Lead_Birth_Date__c )))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>All_Account Update Email Opt In Fields On False</fullName>
        <actions>
            <name>Update_Accnt_Email_Opt_Out_List_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Accnt_Email_Opt_Out_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Email_Opt_In_List__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Based on the &apos;Email Opt In List&apos; being False actions need to be taken</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>All_Account Update Email Opt In Fields On True</fullName>
        <actions>
            <name>Update_Accnt_Email_Opt_In_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Accnt_Email_Opt_Out_List_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Email_Opt_In_List__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Based on the &apos;Email Opt In&apos; being True actions need to be taken</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>All_Account Update Mail Opt In Fields On False</fullName>
        <actions>
            <name>Update_Accnt_Mail_Opt_Out_List_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Accnt_Mail_Opt_Out_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Mail_Opt_In_List__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Based on the &apos;Mail Opt In List&apos; being False actions need to be taken</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>All_Account Update Mail Opt In Fields On True</fullName>
        <actions>
            <name>Update_Accnt_Mail_Opt_In_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Accnt_Mail_Opt_Out_List_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Mail_Opt_In_List__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Based on the &apos;Mail Opt In&apos; being True actions need to be taken</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>All_Account Update Phone Opt In Fields On False</fullName>
        <actions>
            <name>Update_Accnt_Phone_Opt_Out_List_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Accnt_Phone_Opt_Out_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Phone_Opt_In_List__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Based on the &apos;Phone Opt In List&apos; being False actions need to be taken</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>All_Account Update Phone Opt In Fields On True</fullName>
        <actions>
            <name>Update_Accnt_Phone_Opt_In_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Accnt_Phone_Opt_Out_List_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Phone_Opt_In_List__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Based on the &apos;Phone Opt In&apos; being True actions need to be taken</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>All_Account Update SMS Opt In Fields On False</fullName>
        <actions>
            <name>Update_Accnt_SMS_Opt_Out_List_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Accnt_SMS_Opt_Out_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.SMS_Opt_In_List__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Based on the &apos;SMS Opt In&apos; being False actions need to be taken</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>All_Account Update SMS Opt In Fields On True</fullName>
        <actions>
            <name>Update_Accnt_SMS_Opt_In_Modified_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Accnt_SMS_Opt_Out_List_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.SMS_Opt_In_List__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Based on the &apos;SMS Opt In&apos; being True actions need to be taken</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DE Send Account To Oracle</fullName>
        <actions>
            <name>Send_Account_To_Oracle</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>Jagan 07/29/2017 - Rule sends account record to Oracle</description>
        <formula>AND( 	BEGINS(RecordType.DeveloperName, &apos;DE&apos;), 	OR ( ISNEW(), AND( ISCHANGED(Send_To_Oracle__c), Send_To_Oracle__c = true ) )	 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DE Send Account Updates To Oracle</fullName>
        <actions>
            <name>Send_Account_Updates_To_Oracle</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>Workflow will fire an outbound message when any one of the user editable field is changed.</description>
        <formula>OR ( 	 	AND ( 	 		BEGINS(RecordType.DeveloperName, &apos;DE&apos;), 		IsPersonAccount = true, 		OR( 			ISCHANGED(FirstName), 			ISCHANGED(Gender__c), 			ISCHANGED(LastName), 			ISCHANGED(MiddleName), 			ISCHANGED(Name), 			ISCHANGED(PersonBirthdate), 			ISCHANGED(PersonEmail), 			ISCHANGED(PersonHomePhone), 			AND(NOT(ISBLANK(PRIORVALUE(PersonHomePhone))), ISBLANK(PersonHomePhone)), 			ISCHANGED(PersonOtherPhone), 			AND(NOT(ISBLANK(PRIORVALUE(PersonOtherPhone))), ISBLANK(PersonOtherPhone)), 			ISCHANGED(Phone), 			AND(NOT(ISBLANK(PRIORVALUE(Phone))), ISBLANK(Phone)), 			ISCHANGED(PersonMobilePhone), 			AND(NOT(ISBLANK(PRIORVALUE(PersonMobilePhone))), ISBLANK(PersonMobilePhone)), 			ISCHANGED(Secondary_Email__c), 			ISCHANGED(Primary_Phone_Contact__c) 		)	 	), 	 	AND(  		 		BEGINS(RecordType.DeveloperName, &apos;DE&apos;), 		ISCHANGED(Send_To_Oracle__c),  		 		Send_To_Oracle__c = true  	 		)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Rx Expiration Date On Account</fullName>
        <actions>
            <name>Update_Rx_Expiration_Date_On_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.CMN_or_Rx_Expiration_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Rx_Date_Written__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Jagan 05/31/2017 - Created this rule to update the Rx Expiration Date if this is blank</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
