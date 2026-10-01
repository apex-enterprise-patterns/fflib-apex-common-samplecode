import { createElement } from "@lwc/engine-dom";
import OpportunityCreateInvoice from "c/opportunityCreateInvoice";
import createInvoice from "@salesforce/apex/OpportunityCreateInvoiceController.createInvoice";

jest.mock(
  "@salesforce/apex/OpportunityCreateInvoiceController.createInvoice",
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

describe("c-opportunity-create-invoice", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("creates an invoice for the current opportunity", async () => {
    createInvoice.mockResolvedValue("a00000000000001AAA");
    const element = createElement("c-opportunity-create-invoice", {
      is: OpportunityCreateInvoice
    });
    document.body.appendChild(element);
    element.recordId = "006000000000001AAA";

    const input = element.shadowRoot.querySelector("lightning-input");
    input.dispatchEvent(new CustomEvent("change", { detail: { value: "5" } }));

    const createButton = [...element.shadowRoot.querySelectorAll("lightning-button")].find(
      (button) => button.label === "Create Invoice"
    );
    createButton.click();
    await Promise.resolve();
    await Promise.resolve();

    expect(createInvoice).toHaveBeenCalledWith({
      opportunityId: "006000000000001AAA",
      discountPercentage: "5"
    });
  });
});
