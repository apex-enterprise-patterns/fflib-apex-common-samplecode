import { createElement } from "@lwc/engine-dom";
import QuickOpportunityWizard from "c/quickOpportunityWizard";
import getWizardData from "@salesforce/apex/QuickOpportunityWizardController.getWizardData";

jest.mock(
  "@salesforce/apex/QuickOpportunityWizardController.getWizardData",
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

describe("c-quick-opportunity-wizard", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("loads wizard data when recordId is set", async () => {
    getWizardData.mockResolvedValue({
      opportunityName: "Acme",
      selectLineItemList: []
    });
    const element = createElement("c-quick-opportunity-wizard", {
      is: QuickOpportunityWizard
    });
    document.body.appendChild(element);
    element.recordId = "001000000000001AAA";
    await Promise.resolve();
    await Promise.resolve();

    expect(getWizardData).toHaveBeenCalledWith({ accountId: "001000000000001AAA" });
  });
});
