import { LightningElement, track, wire, api } from 'lwc';
import getRecords from '@salesforce/apex/ClsReturnCreditOrderCon.getReturnProducts';
import { getRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ID_FIELD from '@salesforce/schema/OrderItem.Id';
import RETURNQTY_FIELD from '@salesforce/schema/OrderItem.Quantity';
import RETURNREASON_FIELD from '@salesforce/schema/OrderItem.Return_Reason__c';

const columns = [
    {label: 'Product', fieldName: 'ProductCode', editable: false, type: 'text', sortable: false},
    {label: 'Available', fieldName: 'AvailableQty', editable: false, type: 'number', sortable: false, initialWidth: 90, cellAttributes: { alignment: 'center' } },           
    {label: 'Return', fieldName: 'ReturnQty', editable: true, type: 'number', initialWidth: 80, cellAttributes: { alignment: 'center' } },    
    {
        label: 'Return Reason1', fieldName: 'ReturnReason', editable: true, type: 'picklist', typeAttributes: {
            placeholder: 'Choose reason', options: [
                { label: 'Hot', value: 'Hot' },
                { label: 'Warm', value: 'Warm' },
                { label: 'Cold', value: 'Cold' },
            ]            
        }
    }  
];

export default class TPS_DT2 extends LightningElement {
@api recordId;
@track data = [];
@track columns = columns;
@track tableLoadingState = true;
@track error;
@track draftValues = [];

@wire(getRecords , { recordId: '$recordId' })
    wireMethod({ error, data }) {
        if (data) {
            this.data  = data;
            this.error = undefined;
            console.log('** TPS:EH 1.1 data=' + JSON.stringify(data));
        } else if (error) {
            this.error = error;
            this.data  = undefined;
        }
        this.tableLoadingState  = false;
    }

    handleSave(event) {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = event.detail.draftValues[0].Id;
        fields[RETURNQTY_FIELD.fieldApiName] = event.detail.draftValues[0].ReturnQty;
        fields[RETURNREASON_FIELD.fieldApiName] = event.detail.draftValues[0].ReturnReason;

        this.draftValues = [];
        return refreshApex(this.data);
    }       
}