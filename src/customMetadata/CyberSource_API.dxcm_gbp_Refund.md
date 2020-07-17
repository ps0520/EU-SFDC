<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Refund</label>
    <protected>false</protected>
    <values>
        <field>CurrencyIsoCode__c</field>
        <value xsi:type="xsd:string">GBP</value>
    </values>
    <values>
        <field>Enviornment__c</field>
        <value xsi:type="xsd:string">Dev</value>
    </values>
    <values>
        <field>endPoint__c</field>
        <value xsi:type="xsd:string">https://apitest.cybersource.com/pts/v2/payments/{PaymentId}/refunds</value>
    </values>
    <values>
        <field>host__c</field>
        <value xsi:type="xsd:string">apitest.cybersource.com</value>
    </values>
    <values>
        <field>keyid__c</field>
        <value xsi:type="xsd:string">8bb78528-3c56-4de4-9fc9-7320625fe3d2</value>
    </values>
    <values>
        <field>merchant_id__c</field>
        <value xsi:type="xsd:string">dxcm_gbp</value>
    </values>
    <values>
        <field>profile_id__c</field>
        <value xsi:type="xsd:string">BB35D3D1-2546-4A9F-A69A-56E7FC6A2772</value>
    </values>
    <values>
        <field>reqBody__c</field>
        <value xsi:type="xsd:string">{&quot;clientReferenceInformation&quot;: {&quot;code&quot;: &quot;[OrderId]&quot;}, &quot;orderInformation&quot;: {&quot;amountDetails&quot;: {&quot;totalAmount&quot;: &quot;[RefundAmount]&quot;,&quot;currency&quot;: &quot;USD&quot;}}}</value>
    </values>
    <values>
        <field>secretKey__c</field>
        <value xsi:type="xsd:string">UVASMQwkf4wC+bhdqgAen4oxXw8gWprTOpzCHx4mNKk=</value>
    </values>
</CustomMetadata>
