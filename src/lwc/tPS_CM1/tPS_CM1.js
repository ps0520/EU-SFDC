import { LightningElement, track, wire, api } from 'lwc';
import getRecords from '@salesforce/apex/TPS_NewTOLiftController.getReturnProducts';
import { getRecord } from 'lightning/uiRecordApi';

const columns = [
    { label: 'Product', fieldName: 'ProductCode' },
    { label: 'Available', fieldName: 'AvailableQty', type: 'number'}
];

export default class TPS_CM1 extends LightningElement {
@api recordId;
@track data = [];
@track columns = columns;
@track tableLoadingState = true;

@wire(getRecords , { recordId: '$recordId' })
    campaignMembers_x({ error, data }) {
        if (data) {
            this.data  = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data  = undefined;
        }
        this.tableLoadingState  = false;
    }       
}
const COLS = [
    { label: 'Product', fieldName: 'ProductCode', type: 'Text' },
    { label: 'Available', fieldName: 'AvailableQty', type: 'number'}
];