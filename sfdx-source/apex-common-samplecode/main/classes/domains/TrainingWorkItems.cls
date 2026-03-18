/**
 * Domain for TrainingWorkItem__c. Extends AbstractChargeable for cost calculation.
 * Implements ISupportInvoicing for invoice generation.
 */
public with sharing class TrainingWorkItems extends AbstractChargeable
	implements InvoicingService.ISupportInvoicing
{
	@TestVisible
	private static TrainingWorkItems mock;
	public static TrainingWorkItems newInstance(List<TrainingWorkItem__c> recordList) {
		if (mock != null) { return mock; }
		return new TrainingWorkItems(recordList);
	}

	public TrainingWorkItems(List<TrainingWorkItem__c> workItems) {
		super(workItems);
	}

	public override Schema.SObjectField getCostOfHoursWorkedField() {
		return TrainingWorkItem__c.TrainingCost__c;
	}

	public override List<Integer> calculateHoursWorked() {
		List<Integer> hoursWorked = new List<Integer>();
		for (TrainingWorkItem__c wi : (List<TrainingWorkItem__c>) this.records) {
			Decimal d = (wi.DeliveryHours__c != null ? wi.DeliveryHours__c : 0) +
				(wi.PreparationHours__c != null ? wi.PreparationHours__c : 0);
			hoursWorked.add(d.intValue());
		}
		return hoursWorked;
	}

	public void generate(InvoicingService.InvoiceFactory invoiceFactory) {
		for (TrainingWorkItem__c wi : (List<TrainingWorkItem__c>) getRecords()) {
			Id accountId = wi.WorkOrder__r != null ? wi.WorkOrder__r.Account__c : null;
			if (accountId == null) { continue; }
			InvoicingService.Invoice invoice = new InvoicingService.Invoice();
			invoice.Account = accountId;
			invoice.Description = 'Training: ' + (wi.Name != null ? wi.Name : 'Work Item');
			invoice.InvoiceDate = Date.today();
			InvoicingService.InvoiceLine line = new InvoicingService.InvoiceLine();
			line.Description = 'Training delivery';
			line.Product = null;
			line.UnitPrice = wi.TrainingCost__c != null ? wi.TrainingCost__c : 0;
			line.Quantity = 1;
			invoice.Lines = new List<InvoicingService.InvoiceLine> { line };
			invoiceFactory.add(invoice);
		}
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new TrainingWorkItems(sObjectList);
		}
	}
}
