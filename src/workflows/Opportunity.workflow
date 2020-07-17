<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Stage1_moving_out_of_New_Opportunity</fullName>
        <description>Stage1-moving_out_of_New_Opportunity</description>
        <protected>false</protected>
        <recipients>
            <field>Consumer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>de.info@dexcom.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Stage1_moving_out_of_New_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Stage3_moving_out_of_Cost_Estimate</fullName>
        <description>Stage3-moving_out_of_Cost_Estimate</description>
        <protected>false</protected>
        <recipients>
            <field>Consumer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>de.info@dexcom.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Stage3_moving_out_of_Cost_Estimate</template>
    </alerts>
    <fieldUpdates>
        <fullName>FU_Contract_Received_Date</fullName>
        <description>Update the Contract Received Date to today</description>
        <field>Contract_Received_Date__c</field>
        <formula>Contract_Received_Date_DS__c</formula>
        <name>FU Contract Received Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Contract_Sent_Date</fullName>
        <description>Update the sent date with the DS sent date</description>
        <field>Contract_Sent_Date__c</field>
        <formula>DATETIMEVALUE( Contract_Sent_Date_DS__c )</formula>
        <name>FU Contract Sent Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FU_Latest_Docusign_Received_ID</fullName>
        <description>Blank out this field</description>
        <field>Latest_Docusign_Received_ID__c</field>
        <name>FU Latest Docusign Received ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Customer_Docs_Collection_Status</fullName>
        <description>Customer Docs Collection Status: &apos;All Docs Received&apos;</description>
        <field>CA_Customer_Docs_Collection_Status__c</field>
        <literalValue>All Docs Received</literalValue>
        <name>Update Customer Docs Collection Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Health_Insurance_Approval</fullName>
        <description>Update Opportunity Health Insurance Approval: &quot;NOT REQUIRED&quot;</description>
        <field>Health_Insurance_Approval__c</field>
        <literalValue>Not Required</literalValue>
        <name>Update Opp Health Insurance Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Rx_Expiration_Date_On_Opportunity</fullName>
        <description>Jagan 03/22/2018 - Created this field update to update the field CMN or Rx Expiration Date on Opportunity</description>
        <field>Rx_Expiration_Date__c</field>
        <formula>Rx_Date_Written__c + 28</formula>
        <name>Update Rx Expiration Date On Opportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Schedule_Send</fullName>
        <field>Contract_Send_Scheduled__c</field>
        <literalValue>1</literalValue>
        <name>Update Schedule Send</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_send_date</fullName>
        <field>Contract_Sent_Date__c</field>
        <formula>NOW()</formula>
        <name>Update send date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Send_Cost_Estimate_To_EGEKO</fullName>
        <apiVersion>40.0</apiVersion>
        <description>Outbound message to send the cost estimate</description>
        <endpointUrl>https://eu.connect.boomi.com/ws/soap/createeusalesforceopportunity;boomi_auth=c2FsZXNmb3JjZUBkZXhjb21pbmMtNk82SjBPLklQVFNCSjphYWM3Y2UzNi00Yzg0LTQ3ZjMtOWRkOS1kZTlhMmU1M2M1OTY=</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>salesforce.admin@dexcom.com.eu</integrationUser>
        <name>Send Cost Estimate To EGEKO</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Send_Order_Release_To_Oracle</fullName>
        <apiVersion>40.0</apiVersion>
        <description>This rule will send the release hold to Oracle</description>
        <endpointUrl>https://eu.connect.boomi.com/ws/soap/orderreleasehold;boomi_auth=c2FsZXNmb3JjZUBkZXhjb21pbmMtNk82SjBPLklQVFNCSjphYWM3Y2UzNi00Yzg0LTQ3ZjMtOWRkOS1kZTlhMmU1M2M1OTY=</endpointUrl>
        <fields>Id</fields>
        <fields>StageName</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>salesforce.admin@dexcom.com.eu</integrationUser>
        <name>Send Order Release To Oracle</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>AT Populate Default Values</fullName>
        <actions>
            <name>Update_Customer_Docs_Collection_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Opp_Health_Insurance_Approval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>AT Populate Default Values
Stage =Customer Doc Collection
Health Insurance Approval: &quot;NOT REQUIRED&quot;
Customer Docs Collection Status: &apos;All Docs Received&apos;</description>
        <formula>AND( BEGINS(RecordType.DeveloperName, &apos;AT&apos;),ISPICKVAL(StageName, &apos;Customer Doc Collection&apos;),ISPICKVAL(Type, &apos;Reorder&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DE Send Cost Estimate To EGEKO</fullName>
        <actions>
            <name>Send_Cost_Estimate_To_EGEKO</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <description>Workflow rule will trigger the outbound message to be sent to EGEKO</description>
        <formula>AND ( 	RecordType.DeveloperName = &apos;DE_Opportunity&apos;,  	NOT($Profile.Name = &quot;System Administrator&quot;), 	NOT($Profile.Name = &quot;Data Integrator&quot;), 	ISBLANK(Parent_Opportunity__c),   	ISCHANGED(EGEKO_Out__c), 	PRIORVALUE( EGEKO_Out__c ) = FALSE, 	EGEKO_Out__c = TRUE )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DE_Update Rx Expiration Date On Opportunity</fullName>
        <actions>
            <name>Update_Rx_Expiration_Date_On_Opportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Jagan 03/22/2018 - Created this rule to update the Rx Expiration Date if this is blank</description>
        <formula>AND(  RecordType.DeveloperName = &apos;DE_Opportunity&apos;, 	 NOT(ISBLANK(Rx_Date_Written__c)), 	 OR(ISNEW(),  ISCHANGED(Rx_Date_Written__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Contract</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Contract_Request_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Contract_Send_Scheduled__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Schedule_Send</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_send_date</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Opportunity.Contract_Request_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Send Order Release To Oracle</fullName>
        <actions>
            <name>Send_Order_Release_To_Oracle</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>Jagan 07/29/2017 - Rule sends order release information to Oracle</description>
        <formula>OR ( 	AND ( 	RecordType.DeveloperName = &apos;DE_Opportunity&apos;, 	PRIORVALUE(Probability) = 0.95, 	Probability = 1.0 	), 	AND(  		ISCHANGED(Send_To_Oracle__c),  		Send_To_Oracle__c = true  	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UKIE Update DD Dates</fullName>
        <actions>
            <name>FU_Contract_Received_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Contract_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FU_Latest_Docusign_Received_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Any delayed document (DD prefix) needs will update the Contract Received Dat</description>
        <formula>BEGINS(Latest_Docusign_Received_ID__c, &quot;DD&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Rx Expiration Date On Opportunity</fullName>
        <actions>
            <name>Update_Rx_Expiration_Date_On_Opportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Jagan 03/22/2018 - Created this rule to update the Rx Expiration Date if this is blank</description>
        <formula>AND( 	NOT(ISBLANK(Rx_Date_Written__c)), 	OR(ISNEW(), ISCHANGED(Rx_Date_Written__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
