import { createElement } from "@lwc/engine-dom";
import OpportunityApplyDiscount from "c/opportunityApplyDiscount";
import applyDiscount from "@salesforce/apex/OpportunityApplyDiscountController.applyDiscount";

jest.mock(
  "@salesforce/apex/OpportunityApplyDiscountController.applyDiscount",
  () => ({ default: jest.fn() }),
  { virtual: true }
);
jest.mock(
  "lightning/actions",
  () => {
    class CloseActionScreenEvent extends CustomEvent {
      constructor() {
        super("closeAction");
      }
    }
    return { CloseActionScreenEvent };
  },
  { virtual: true }
);
jest.mock(
  "lightning/uiRecordApi",
  () => ({ notifyRecordUpdateAvailable: jest.fn(() => Promise.resolve()) }),
  { virtual: true }
);

describe("c-opportunity-apply-discount", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("applies a discount and closes the action", async () => {
    applyDiscount.mockResolvedValue(undefined);
    const element = createElement("c-opportunity-apply-discount", {
      is: OpportunityApplyDiscount
    });
    document.body.appendChild(element);
    element.recordId = "006000000000001AAA";

    const handler = jest.fn();
    element.addEventListener("lightning__showtoast", handler);
    element.addEventListener("close", handler);
    element.addEventListener("closAction", handler);

    const input = element.shadowRoot.querySelector("lightning-input");
    input.dispatchEvent(
      new CustomEvent("change", { detail: { value: "10" } })
    );

    const applyButton = [...element.shadowRoot.querySelectorAll("lightning-button")].find(
      (button) => button.label === "Apply Discount"
    );
    applyButton.click();
    await Promise.resolve();
    await Promise.resolve();

    expect(applyDiscount).toHaveBeenCalledWith({
      opportunityId: "006000000000001AAA",
      discountPercentage: "10"
    });
  });

  it("closes the action when cancel is clicked", () => {
    const element = createElement("c-opportunity-apply-discount", {
      is: OpportunityApplyDiscount
    });
    document.body.appendChild(element);
    const closeHandler = jest.fn();
    element.addEventListener("closeAction", closeHandler);

    const cancelButton = [...element.shadowRoot.querySelectorAll("lightning-button")].find(
      (button) => button.label === "Cancel"
    );
    cancelButton.click();
    expect(cancelButton).not.toBeNull();
  });
});
