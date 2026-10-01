import { LightningElement, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import createInvoice from "@salesforce/apex/OpportunityCreateInvoiceController.createInvoice";

export default class OpportunityCreateInvoice extends NavigationMixin(LightningElement) {
  _recordId;
  discountPercentage;
  isSaving = false;

  @api
  get recordId() {
    return this._recordId;
  }
  set recordId(value) {
    this._recordId = value;
  }

  handleDiscountChange(event) {
    this.discountPercentage = event.detail.value;
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  async handleCreate() {
    if (this.isSaving) {
      return;
    }
    this.isSaving = true;
    try {
      const invoiceId = await createInvoice({
        opportunityId: this._recordId,
        discountPercentage: this.discountPercentage
      });
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Invoice created.",
          variant: "success"
        })
      );
      this.dispatchEvent(new CloseActionScreenEvent());
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: invoiceId,
          objectApiName: "Invoice__c",
          actionName: "view"
        }
      });
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error creating invoice",
          message: this.reduceError(error),
          variant: "error"
        })
      );
    } finally {
      this.isSaving = false;
    }
  }

  reduceError(error) {
    if (typeof error === "string") {
      return error;
    }
    if (Array.isArray(error.body)) {
      return error.body.map((e) => e.message).join(", ");
    }
    return error?.body?.message || error?.message || "Unknown error";
  }
}
