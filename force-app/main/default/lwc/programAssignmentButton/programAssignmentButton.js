import { LightningElement, api } from 'lwc';

export default class ProgramAssignmentButton extends LightningElement {
    @api message;
    
    @api
    childComp(name){
        this.message = name;
    }
}