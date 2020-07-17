<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Invoice_Unit_Price</fullName>
        <description>Updates the Invoice Unit Price based on the Product logic.</description>
        <field>Invoice_Unit_Price__c</field>
        <formula>IF(PricebookEntry.Product2.Name = &apos;CASTARTERKITG6&apos;, 0,
IF(PricebookEntry.Product2.Name = &apos;STS-GS-015&apos; &amp;&amp; IsBundleItem__c = true, 299,UnitPrice))</formula>
        <name>Update_Invoice_Unit_Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Is_Return_Item_On_Order_Item</fullName>
        <description>Update field Is_Return_Item__c  on line item.</description>
        <field>Is_Return_Item__c</field>
        <literalValue>1</literalValue>
        <name>Update Is Return Item On Order Item</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Order_Item_External_Id</fullName>
        <description>Field update triggers the update on External Id field</description>
        <field>External_Id__c</field>
        <formula>OrderId + &apos;-&apos; +   PricebookEntry.Product2.Name + &apos;-&apos; +  IF(IsBundleItem__c, &quot;Y&quot;, &quot;N&quot;)</formula>
        <name>Update Order Item External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Product_Name</fullName>
        <field>Product_Name__c</field>
        <formula>PricebookEntry.Product2.Name</formula>
        <name>Update_Product_Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>All_Update Is Return Item On Order Item</fullName>
        <actions>
            <name>Update_Is_Return_Item_On_Order_Item</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OrderItem.ProductCode</field>
            <operation>contains</operation>
            <value>RT</value>
        </criteriaItems>
        <description>Rule will set a flag on the Order item when a return kit is selected.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>All_Update Order Item Attributes</fullName>
        <actions>
            <name>Update_Invoice_Unit_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Product_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates the selected Product name, Invoice Unit Price on Order Item</description>
        <formula>NOT(ISBLANK(Product2Id))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>DE_Update External Id</fullName>
        <actions>
            <name>Update_Order_Item_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow updates External Id field on Order</description>
        <formula>TEXT(CurrencyIsoCode) = &apos;EUR&apos;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Is Return Item On Order Item</fullName>
        <actions>
            <name>Update_Is_Return_Item_On_Order_Item</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>OrderItem.ProductCode</field>
            <operation>contains</operation>
            <value>RT</value>
        </criteriaItems>
        <description>Rule will set a flag on the Order item when a return kit is selected.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Product Name And External Id</fullName>
        <actions>
            <name>Update_Order_Item_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Product_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow updates the selected Product name in &quot;Product Name&quot; field and External Id field on Order</description>
        <formula>NOT(ISBLANK(Product2Id))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
