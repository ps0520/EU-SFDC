<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Order_Delivery_Note_Received</fullName>
        <description>Order-Delivery_Note_Received</description>
        <protected>false</protected>
        <recipients>
            <field>Consumer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>de.info@dexcom.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Order_Delivery_Note_Received</template>
    </alerts>
    <alerts>
        <fullName>Order_Status_Open_moving_out_of_Order_Fulfillment</fullName>
        <description>Order-Status-Open-moving_out_of_Order_Fulfillment</description>
        <protected>false</protected>
        <recipients>
            <field>Consumer_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>de.info@dexcom.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Order_Status_Open_moving_out_of_Order_Fulfillment</template>
    </alerts>
    <alerts>
        <fullName>Send_Approval_Email</fullName>
        <description>Send Approval Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Sample_Order_Req_Approved</template>
    </alerts>
    <alerts>
        <fullName>Send_Approval_Email_for_Return_and_Credit_Order</fullName>
        <description>Send Approval Email for Return and Credit Order</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Return_and_Credit_Order_Req_Approved</template>
    </alerts>
    <alerts>
        <fullName>Send_Rejection_Email</fullName>
        <description>Send Rejection Email</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Sample_Order_Req_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Send_Rejection_Email_for_Return_and_Credit_Order</fullName>
        <description>Send Rejection Email for Return and Credit Order</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Return_and_Credit_Order_Req_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Status_to_Activated</fullName>
        <field>Status</field>
        <literalValue>Activated</literalValue>
        <name>Change Status to Activated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Non_Insurance_Order_Skip_Shipping_Hold</fullName>
        <field>Status</field>
        <literalValue>Activated</literalValue>
        <name>Non Insurance Order - Skip Shipping Hold</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Order_RT_Change_on_Shipping_Hold_status</fullName>
        <field>RecordTypeId</field>
        <lookupValue>DE_Sales_Order_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Order-RT Change on Shipping Hold status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sample_Order_Approved</fullName>
        <description>Sales Sample has been approved.</description>
        <field>Status</field>
        <literalValue>Activated</literalValue>
        <name>Sample Order Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Sample_Order_Req_Rejected_Status_to_Draf</fullName>
        <description>Set the Order status to Draft so that it can modified</description>
        <field>Status</field>
        <literalValue>Draft</literalValue>
        <name>Sample Order Req Rejected Status to Draf</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_SOO_Unique_ID</fullName>
        <field>SOS_Unique_ID__c</field>
        <formula>&apos;crm&apos;+Id</formula>
        <name>Set SOO Unique ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_SoO_to_crm</fullName>
        <description>Update the default value to crm</description>
        <field>System_Of_Origin__c</field>
        <formula>&apos;crm&apos;</formula>
        <name>Set SoO to crm</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_System_of_Origin_Id</fullName>
        <field>System_Of_Origin_ID__c</field>
        <formula>Id</formula>
        <name>Set System of Origin Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Delivery_Reminder_Changed_Date</fullName>
        <field>Delivery_Reminder_Change_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Delivery Reminder Changed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Email_Stage_To_1</fullName>
        <field>Email_Stage__c</field>
        <formula>1</formula>
        <name>Update_Email_Stage_To_1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Email_Status_To_Pending</fullName>
        <description>Update Invoice Email Status to Pending.</description>
        <field>Invoice_Email_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Update Invoice Email Status To Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Invoice_Status</fullName>
        <field>Invoice_Status__c</field>
        <literalValue>Invoice Open</literalValue>
        <name>Update Invoice Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Letter_Of_Ack_Sent_Date</fullName>
        <description>This will update letter of acknowledgement sent date.</description>
        <field>Letter_of_Acknowledgement_Sent_Date__c</field>
        <formula>If((Letter_of_Acknowledgement_Sent__c = TRUE &amp;&amp; ISBLANK(Letter_of_Acknowledgement_Sent_Date__c)), Today(),null)</formula>
        <name>Update Letter Of Ack Sent Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Order_Shipping_Hold_Status</fullName>
        <field>Shipping_Hold_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Update Order Shipping Hold Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Order_Status_to_Closed</fullName>
        <description>• When &apos;Invoice Status&apos; is updated to &apos;Invoice Closed&apos; then the &apos;Order Status&apos; should be updated to &apos;Closed&apos;</description>
        <field>Status</field>
        <literalValue>CLOSED</literalValue>
        <name>Update Order Status to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Send_Order_Release_To_Oracle</fullName>
        <apiVersion>42.0</apiVersion>
        <description>12/30/2019 - Removed PROD URL - https://eu.connect.boomi.com/ws/soap/orderreleasehold;boomi_auth=c2FsZXNmb3JjZUBkZXhjb21pbmMtNk82SjBPLklQVFNCSjphYWM3Y2UzNi00Yzg0LTQ3ZjMtOWRkOS1kZTlhMmU1M2M1OTY=</description>
        <endpointUrl>https://test.com</endpointUrl>
        <fields>Id</fields>
        <fields>OrderNumber</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>salesforce.admin@dexcom.com.eu</integrationUser>
        <name>Send Order Release To Oracle</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Send_Order_To_Oracle</fullName>
        <apiVersion>40.0</apiVersion>
        <description>Outbound message to send Order updates
12/30/2019 - Removed Prod URL - https://eu.connect.boomi.com/ws/soap/order;boomi_auth=c2FsZXNmb3JjZUBkZXhjb21pbmMtNk82SjBPLklQVFNCSjphYWM3Y2UzNi00Yzg0LTQ3ZjMtOWRkOS1kZTlhMmU1M2M1OTY=</description>
        <endpointUrl>https://dummyurl.com</endpointUrl>
        <fields>AccountId</fields>
        <fields>Account_Party_Id__c</fields>
        <fields>ActivatedById</fields>
        <fields>ActivatedDate</fields>
        <fields>BillToContactId</fields>
        <fields>BillingCity</fields>
        <fields>BillingCountry</fields>
        <fields>BillingCountryCode</fields>
        <fields>BillingGeocodeAccuracy</fields>
        <fields>BillingLatitude</fields>
        <fields>BillingLongitude</fields>
        <fields>BillingPostalCode</fields>
        <fields>BillingState</fields>
        <fields>BillingStateCode</fields>
        <fields>BillingStreet</fields>
        <fields>Case_Number__c</fields>
        <fields>Co_Pay__c</fields>
        <fields>CompanyAuthorizedById</fields>
        <fields>CompanyAuthorizedDate</fields>
        <fields>ContractId</fields>
        <fields>Count_of_Order_Line_Items__c</fields>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>CustomerAuthorizedById</fields>
        <fields>CustomerAuthorizedDate</fields>
        <fields>Customer_Bill_To_Address__c</fields>
        <fields>Customer_Ship_To_Address__c</fields>
        <fields>Description</fields>
        <fields>EffectiveDate</fields>
        <fields>EndDate</fields>
        <fields>External_Id__c</fields>
        <fields>Id</fields>
        <fields>Invoice_Status__c</fields>
        <fields>IsDeleted</fields>
        <fields>IsReductionOrder</fields>
        <fields>Is_Cash_Order__c</fields>
        <fields>LastModifiedById</fields>
        <fields>LastModifiedDate</fields>
        <fields>LastReferencedDate</fields>
        <fields>LastViewedDate</fields>
        <fields>Last_Sync_Date_With_Oracle__c</fields>
        <fields>Name</fields>
        <fields>OpportunityId</fields>
        <fields>Oracle_Account_Customer_Id__c</fields>
        <fields>Oracle_Payor_Customer_Id__c</fields>
        <fields>Oracle_Shipping_Party_Site_Use_Id__c</fields>
        <fields>OrderNumber</fields>
        <fields>OrderReferenceNumber</fields>
        <fields>OriginalOrderId</fields>
        <fields>OwnerId</fields>
        <fields>Parent_Order__c</fields>
        <fields>Payor_Bill_To_Address__c</fields>
        <fields>Payor_Party_Id__c</fields>
        <fields>Payor__c</fields>
        <fields>PoDate</fields>
        <fields>PoNumber</fields>
        <fields>Price_Book__c</fields>
        <fields>Pricebook2Id</fields>
        <fields>QuoteId</fields>
        <fields>RecordTypeId</fields>
        <fields>Schedule__c</fields>
        <fields>Send_To_Oracle__c</fields>
        <fields>ShipToContactId</fields>
        <fields>ShippingCity</fields>
        <fields>ShippingCountry</fields>
        <fields>ShippingCountryCode</fields>
        <fields>ShippingGeocodeAccuracy</fields>
        <fields>ShippingLatitude</fields>
        <fields>ShippingLongitude</fields>
        <fields>ShippingPostalCode</fields>
        <fields>ShippingState</fields>
        <fields>ShippingStateCode</fields>
        <fields>ShippingStreet</fields>
        <fields>Shipping_Instructions__c</fields>
        <fields>Shipping_Method__c</fields>
        <fields>Status</fields>
        <fields>StatusCode</fields>
        <fields>SystemModstamp</fields>
        <fields>Territory_Aligned_To_Customer__c</fields>
        <fields>TotalAmount</fields>
        <fields>Type</fields>
        <fields>Warehouse__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>salesforce.admin@dexcom.com.eu</integrationUser>
        <name>Send Order To Oracle</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>All Change Status for Sample And Return Orders</fullName>
        <actions>
            <name>Change_Status_to_Activated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Order Type is &apos;Sales Sample&apos; and the status is Shipping Hold, then change it to Activated as we want to by pass QC Check for all countries.</description>
        <formula>AND( Text(Status) = &apos;Shipping Hold&apos;, OR( 	AND(CONTAINS(TEXT(Type), &apos;SAMPLE&apos;), NOT(OR(BEGINS(TEXT(Type), &apos;GB&apos;),BEGINS(TEXT(Type), &apos;IE&apos;), BEGINS(TEXT(Type), &apos;SI&apos;)))) /*, 	CONTAINS(TEXT(Type), &apos;RETURN&apos;)*/ ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>All Order Default SoO</fullName>
        <actions>
            <name>Set_SOO_Unique_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_SoO_to_crm</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_System_of_Origin_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Set the default System of Origin to crm if it is blank at the time of Order creation.</description>
        <formula>ISBLANK( System_Of_Origin__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>All Update Invoice Email Status On Order</fullName>
        <actions>
            <name>Update_Invoice_Email_Status_To_Pending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Invoice Email Status based on the Payor account or Consumer accounts email opt in status to receive Invoice via email.</description>
        <formula>AND(     Email_Invoice_Opt_In__c,     ISCHANGED( Invoice_Number__c),     ISBLANK(PRIORVALUE( Invoice_Number__c )),     NOT(ISBLANK(Invoice_Number__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>All_Non Insurance Type Order - Skip Shipping Hold</fullName>
        <actions>
            <name>Non_Insurance_Order_Skip_Shipping_Hold</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Shipping Hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Is_Cash_Order__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>startsWith</operation>
            <value>DE</value>
        </criteriaItems>
        <description>This workflow rule skips the Order Audit Process for Non Insurance Order Records by moving the Order Status from Draft to Activated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>All_Update Invoice Status</fullName>
        <actions>
            <name>Update_Order_Status_to_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This will update order status when &apos;Invoice Status&apos; is updated to &apos;Invoice Closed&apos; then the &apos;Order Status&apos; should be updated to     &apos;Closed&apos;</description>
        <formula>AND(ISCHANGED(Invoice_Status__c ), ISPICKVAL( Invoice_Status__c , &quot;Invoice Closed&quot;), BEGINS(  RecordType.DeveloperName, &apos;DE_&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>All_Update Invoice Status for Insurance Order</fullName>
        <actions>
            <name>Update_Invoice_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>For Insurance Order (ones which have     Opportunity tied to it) when the &apos;Order status&apos; is put &apos;On-Hold&apos; then the &apos;Invoice Status&apos; field should be set to &apos;Invoice Open&apos; status value</description>
        <formula>AND(ISCHANGED( Status  ),ISPICKVAL(Status , &quot;On-Hold&quot;), NOT(ISBLANK(OpportunityId )), NOT( Is_Cash_Order__c ),  BEGINS(RecordType.DeveloperName, &apos;DE_&apos;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DE Send Order Release To Oracle</fullName>
        <actions>
            <name>Send_Order_Release_To_Oracle</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>On Order -- Part of Invoice Updated Processing - 04-03-2018 Anuj.</description>
        <formula>AND(  	
ActivatedDate &lt;= DATETIMEVALUE( &apos;2019-12-31 12:00:00&apos; ),
BEGINS(RecordType.DeveloperName, &apos;DE&apos;), 	ISCHANGED( Invoice_Status__c ), 	ISBLANK(Invoice_Number__c), 	
AND(ISPICKVAL(Invoice_Status__c, &quot;Invoice Requested&quot;), 	ISPICKVAL(PRIORVALUE(Invoice_Status__c),&quot;Invoice Open&quot;)) 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DE Send Order To Oracle</fullName>
        <actions>
            <name>Send_Order_To_Oracle</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>Jagan 07/29/2017 - Rule sends Order record to Oracle</description>
        <formula>AND( 	 	BEGINS(RecordType.DeveloperName, &apos;DE&apos;), 	OR(NOT(ISBLANK(OpportunityId)), CONTAINS(TEXT(Type), &apos;DE TECH&apos;)),	 	OR ( 	 		 		AND( 			ISCHANGED(Status), 		 			 			ISPICKVAL(Status, &apos;Activated&apos;), 		 			 			ISBLANK(Last_Sync_Date_With_Oracle__c) 		), 	 		 		AND( 			ISCHANGED(Send_To_Oracle__c), 			Send_To_Oracle__c = true  	 		 		)  	 	)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DE_Delivery Note Reminder Changed</fullName>
        <actions>
            <name>Update_Delivery_Reminder_Changed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updated the Delivery Reminder Changed Date when value in Delivery Note Reminder Field is changed.</description>
        <formula>AND( CONTAINS(TEXT(Type), &apos;DE &apos;),  ISCHANGED( Delivery_Note_Reminder__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DE_Update Letter Of Ack Sent Date</fullName>
        <actions>
            <name>Update_Letter_Of_Ack_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Jagan 12/10/2017 - Added Rule to set the letter of acknowledgement sent date on Order when the Letter of acknowledgement sent flag is set and the date is not filled in.</description>
        <formula>OR( 	 AND(Letter_of_Acknowledgement_Sent__c = TRUE, CONTAINS(TEXT(Type), &apos;DE &apos;),  ISBLANK(Letter_of_Acknowledgement_Sent_Date__c)), 	AND(Letter_of_Acknowledgement_Sent__c = FALSE, CONTAINS(TEXT(Type), &apos;DE &apos;), NOT(ISBLANK(Letter_of_Acknowledgement_Sent_Date__c))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DE_Update Order Layout To Readonly On Shipping Hold Status</fullName>
        <actions>
            <name>Order_RT_Change_on_Shipping_Hold_status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Order_Shipping_Hold_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Shipping Hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>equals</operation>
            <value>DE Sales Order</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Type</field>
            <operation>equals</operation>
            <value>DE STANDARD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Is_Cash_Order__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow will change the Order Record type to DE Standard Sales Read Only when Status changes to Shipping Hold</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DE_Update Order Shipping Hold Status for non Insurance</fullName>
        <actions>
            <name>Update_Order_Shipping_Hold_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 ANd 5</booleanFilter>
        <criteriaItems>
            <field>Order.Is_Cash_Order__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Type</field>
            <operation>equals</operation>
            <value>DE STANDARD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>equals</operation>
            <value>DE Sales Order Read Only</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Shipping Hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Shipping_Hold_Status__c</field>
            <operation>equals</operation>
            <value>Not Started</value>
        </criteriaItems>
        <description>Update the Shipping hold status on order to In Progress when RT is DE Sales Order Read Only</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Delivery Note Reminder Changed</fullName>
        <actions>
            <name>Update_Delivery_Reminder_Changed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow updated the Delivery Reminder Changed Date when value in Delivery Note Reminder Field is changed.</description>
        <formula>ISCHANGED( Delivery_Note_Reminder__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Non Insurance Type Order - Skip Shipping Hold</fullName>
        <actions>
            <name>Non_Insurance_Order_Skip_Shipping_Hold</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 OR 3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Shipping Hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Is_Cash_Order__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>DE Sales Order,DE Sales Order Read Only</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Type</field>
            <operation>notEqual</operation>
            <value>DE STANDARD</value>
        </criteriaItems>
        <description>This workflow rule skips the Order Audit Process for Non Insurance Order Records by moving the Order Status from Draft to Activated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Invoice Status</fullName>
        <actions>
            <name>Update_Order_Status_to_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This will update order status when &apos;Invoice Status&apos; is updated to &apos;Invoice Closed&apos; then the &apos;Order Status&apos; should be updated to     &apos;Closed&apos;</description>
        <formula>AND(ISCHANGED(Invoice_Status__c ), ISPICKVAL( Invoice_Status__c , &quot;Invoice Closed&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Invoice Status for Insurance Order</fullName>
        <actions>
            <name>Update_Invoice_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>For Insurance Order (ones which have     Opportunity tied to it) when the &apos;Order status&apos; is put &apos;On-Hold&apos; then the &apos;Invoice Status&apos; field should be set to &apos;Invoice Open&apos; status value</description>
        <formula>AND(ISCHANGED( Status  ),ISPICKVAL(Status , &quot;On-Hold&quot;), NOT(ISBLANK(OpportunityId )), NOT( Is_Cash_Order__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Letter Of Ack Sent Date</fullName>
        <actions>
            <name>Update_Letter_Of_Ack_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Jagan 12/10/2017 - Added Rule to set the letter of acknowledgement sent date on Order when the Letter of acknowledgement sent flag is set and the date is not filled in.</description>
        <formula>OR( 	AND(Letter_of_Acknowledgement_Sent__c = TRUE, ISBLANK(Letter_of_Acknowledgement_Sent_Date__c)), 	AND(Letter_of_Acknowledgement_Sent__c = FALSE, NOT(ISBLANK(Letter_of_Acknowledgement_Sent_Date__c))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Order Layout To Readonly On Shipping Hold Status</fullName>
        <actions>
            <name>Order_RT_Change_on_Shipping_Hold_status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Shipping Hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>equals</operation>
            <value>DE Sales Order</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Type</field>
            <operation>equals</operation>
            <value>DE STANDARD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Is_Cash_Order__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow will change the Order Record type to DE Standard Sales Read Only when Status changes to Shipping Hold</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Order Shipping Hold Status for non Insurance</fullName>
        <actions>
            <name>Update_Order_Shipping_Hold_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 ANd 5</booleanFilter>
        <criteriaItems>
            <field>Order.Is_Cash_Order__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Type</field>
            <operation>equals</operation>
            <value>DE STANDARD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.RecordTypeId</field>
            <operation>equals</operation>
            <value>DE Sales Order Read Only</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>Shipping Hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Shipping_Hold_Status__c</field>
            <operation>equals</operation>
            <value>Not Started</value>
        </criteriaItems>
        <description>Update the Shipping hold status on order to In Progress when RT is DE Sales Order Read Only</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update_Email_Stage_To_1_Final</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>On-Hold</value>
        </criteriaItems>
        <description>This will help firing the email on 28th day since the order moved to Open Status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Email_Stage_To_1</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
