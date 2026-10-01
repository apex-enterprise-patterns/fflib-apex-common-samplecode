import { createElement } from "@lwc/engine-dom";
import OpportunityInvoiceJob from "c/opportunityInvoiceJob";
import startJob from "@salesforce/apex/OpportunityInvoicingController.startJob";

jest.mock(
  "@salesforce/apex/OpportunityInvoicingController.startJob",
  () => ({ default: jest.fn() }),
  { virtual: true }
);

describe("c-opportunity-invoice-job", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("submits the invoicing job and shows a success toast", async () => {
    startJob.mockResolvedValue("707000000000001AAA");
    const element = createElement("c-opportunity-invoice-job", {
      is: OpportunityInvoiceJob
    });
    document.body.appendChild(element);

    const toastHandler = jest.fn();
    element.addEventListener("lightning__showtoast", toastHandler);

    await element.invoke();
    await Promise.resolve();

    expect(startJob).toHaveBeenCalledTimes(1);
    expect(toastHandler).toHaveBeenCalled();
    const toast = toastHandler.mock.calls[0][0];
    expect(toast.detail.variant).toBe("success");
  });

  it("shows an error toast when the job fails", async () => {
    startJob.mockRejectedValue({ body: { message: "Job failed" } });
    const element = createElement("c-opportunity-invoice-job", {
      is: OpportunityInvoiceJob
    });
    document.body.appendChild(element);

    const toastHandler = jest.fn();
    element.addEventListener("lightning__showtoast", toastHandler);

    await element.invoke();
    await Promise.resolve();

    expect(toastHandler).toHaveBeenCalled();
    expect(toastHandler.mock.calls[0][0].detail.variant).toBe("error");
  });
});
