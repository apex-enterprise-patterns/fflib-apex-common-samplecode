import { LightningElement, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import getWizardData from "@salesforce/apex/QuickOpportunityWizardController.getWizardData";
import createOpportunity from "@salesforce/apex/QuickOpportunityWizardController.createOpportunity";

const COLUMNS = [
  { label: "Product Name", fieldName: "productName", type: "text" },
  { label: "Pricebook", fieldName: "pricebookName", type: "text" },
  {
    label: "Description",
    fieldName: "description",
    type: "text",
    editable: true
  },
  { label: "List Price", fieldName: "listPrice", type: "currency" },
  {
    label: "Unit Price",
    fieldName: "unitPrice",
    type: "currency",
    editable: true
  },
  { label: "Quantity", fieldName: "quantity", type: "number", editable: true }
];

export default class QuickOpportunityWizard extends NavigationMixin(LightningElement) {
  _recordId;
  opportunityName;
  lineItems = [];
  draftValues = [];
  columns = COLUMNS;
  isSaving = false;
  errorMessage;

  @api
  get recordId() {
    return this._recordId;
  }
  set recordId(value) {
    this._recordId = value;
    if (value) {
      this.loadWizard();
    }
  }

  async loadWizard() {
    this.errorMessage = undefined;
    try {
      const data = await getWizardData({ accountId: this._recordId });
      this.opportunityName = data.opportunityName;
      this.lineItems = data.selectLineItemList || [];
    } catch (error) {
      this.errorMessage = this.reduceError(error);
    }
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleCellChange(event) {
    this.draftValues = event.detail.draftValues;
  }

  handleCreate() {
    const form = this.template.querySelector("lightning-record-edit-form");
    if (form) {
      form.submit();
    }
  }

  handleFormError(event) {
    this.errorMessage = event.detail?.message || "Unable to create the Opportunity.";
  }

  async handleSubmit(event) {
    event.preventDefault();
    if (this.isSaving) {
      return;
    }
    this.isSaving = true;
    this.errorMessage = undefined;
    try {
      const fields = event.detail.fields;
      const opportunityId = await createOpportunity({
        accountId: this._recordId,
        name: fields.Name,
        stageName: fields.StageName,
        closeDate: fields.CloseDate,
        selectLineItemList: this.selectedLineItems()
      });
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Success",
          message: "Opportunity created.",
          variant: "success"
        })
      );
      this.dispatchEvent(new CloseActionScreenEvent());
      this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
          recordId: opportunityId,
          objectApiName: "Opportunity",
          actionName: "view"
        }
      });
    } catch (error) {
      this.errorMessage = this.reduceError(error);
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error creating Opportunity",
          message: this.errorMessage,
          variant: "error"
        })
      );
    } finally {
      this.isSaving = false;
    }
  }

  selectedLineItems() {
    const table = this.template.querySelector("lightning-datatable");
    const draftsByKey = {};
    (this.draftValues || []).forEach((draft) => {
      draftsByKey[draft.key] = draft;
    });
    const selectedKeys = new Set(
      (typeof table?.getSelectedRows === "function" ? table.getSelectedRows() : []).map((row) => row.key)
    );
    return this.lineItems.map((row) => {
      const draft = draftsByKey[row.key] || {};
      return {
        key: row.key,
        selected: selectedKeys.has(row.key),
        productName: row.productName,
        pricebookName: row.pricebookName,
        description: draft.description !== undefined ? draft.description : row.description,
        listPrice: row.listPrice,
        unitPrice: draft.unitPrice !== undefined ? draft.unitPrice : row.unitPrice,
        quantity: draft.quantity !== undefined ? draft.quantity : row.quantity,
        pricebookEntryId: row.pricebookEntryId
      };
    });
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
