/**
 * Copyright (c) 2012-2014, FinancialForce.com, inc
 * All rights reserved.
 */
public with sharing class InvoicingService
{
	@TestVisible
	private static InvoicingService mock;
	public static InvoicingService newInstance()
	{
		if (mock != null) { return mock; }
		return new InvoicingService();
	}

	/**
	 * Interface implemented by domain classes that support the ability to produce invoices
	 */
	public interface ISupportInvoicing
	{
		void generate(InvoiceFactory invoiceFactory);
	}

	/**
	 * Methods on this factory will help create and register with the UOW invoices
	 */
	public class InvoiceFactory
	{
		private fflib_ISObjectUnitOfWork unitOfWork;
		public List<Invoice__c> Invoices { get; private set; }

		public InvoiceFactory(fflib_ISObjectUnitOfWork unitOfWork)
		{
			this.unitOfWork = unitOfWork;
			this.Invoices = new List<Invoice__c>();
		}

		public void add(Invoice invoice)
		{
			Invoice__c invoiceRecord = new Invoice__c();
			invoiceRecord.Account__c = invoice.Account;
			invoiceRecord.Description__c = invoice.Description;
			invoiceRecord.InvoiceDate__c = invoice.InvoiceDate;
			unitOfWork.registerNew(invoiceRecord);
			if (invoice.Lines != null)
			{
				for (InvoiceLine line : invoice.Lines)
				{
					InvoiceLine__c invoiceLineItem = new InvoiceLine__c();
					invoiceLineItem.Description__c = line.Description;
					invoiceLineItem.Product__c = line.Product;
					invoiceLineItem.UnitPrice__c = line.UnitPrice;
					invoiceLineItem.Quantity__c = line.Quantity;
					unitOfWork.registerNew(invoiceLineItem, InvoiceLine__c.Invoice__c, invoiceRecord);
				}
			}
			Invoices.add(invoiceRecord);
		}
	}

	public class Invoice
	{
		public List<InvoiceLine> Lines { get; set; }
		public Id Account { get; set; }
		public String Description { get; set; }
		public Date InvoiceDate { get; set; }
	}

	public class InvoiceLine
	{
		public String Description { get; set; }
		public Id Product { get; set; }
		public Decimal UnitPrice { get; set; }
		public Decimal Quantity { get; set; }
	}

	/**
	 * Generate invoices for the given source records (so long as their domain classes implement ISupportInvoicing)
	 */
	public List<Id> generate(List<Id> sourceRecordIds)
	{
		fflib_ISObjectUnitOfWork uow = UnitOfWork.newInstance();
		InvoiceFactory invoiceFactory = new InvoiceFactory(uow);
		List<SObject> records = InvoicingTargetsRegistry.selectById(new Set<Id>(sourceRecordIds));
		fflib_IDomain domain = InvoicingTargetsRegistry.newDomain(records);
		if (domain instanceof ISupportInvoicing)
		{
			((ISupportInvoicing) domain).generate(invoiceFactory);
			uow.commitWork();
			List<Id> invoiceIds = new List<Id>();
			for (Invoice__c invoice : invoiceFactory.Invoices) {
				invoiceIds.add(invoice.Id);
			}
			return invoiceIds;
		}
		throw new InvoicingException('Invalid source object for generating invoices.');
	}

	public class InvoicingException extends Exception { }
}
