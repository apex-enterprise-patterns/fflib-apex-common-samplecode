import { LightningElement, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import applyDiscount from "@salesforce/apex/OpportunityApplyDiscountController.applyDiscount";

export default class OpportunityApplyDiscount extends LightningElement {
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

  async handleApply() {
    if (this.isSaving) {
      return;
    }
    this.isSaving = true;
    try {
      await applyDiscount({
        opportunityId: this._recordId,
        discountPercentage: this.discountPercentage
      });
      await notifyRecordUpdateAvailable([{ recordId: this._recordId }]);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Discount applied.",
          variant: "success"
        })
      );
      this.dispatchEvent(new CloseActionScreenEvent());
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error applying discount",
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
