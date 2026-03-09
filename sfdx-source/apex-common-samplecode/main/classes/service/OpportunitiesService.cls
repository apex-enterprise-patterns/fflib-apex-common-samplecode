/**
 * Copyright (c) 2012-2014, FinancialForce.com, inc
 * All rights reserved.
 */
public with sharing class OpportunitiesService
{
	@TestVisible
	private static OpportunitiesService mock;
	public static OpportunitiesService newInstance()
	{
		if (mock != null) { return mock; }
		return new OpportunitiesService();
	}

	public void applyDiscounts(Set<Id> opportunityIds, Decimal discountPercentage)
	{
		applyDiscounts(
			OpportunitiesSelector.newInstance().selectByIdWithProducts(opportunityIds),
			discountPercentage);
	}

	public void applyDiscounts(List<Opportunity> opportunitiesWithProducts, Decimal discountPercentage)
	{
		applyDiscounts(
			Opportunities.newInstance(opportunitiesWithProducts),
			discountPercentage);
	}

	private void applyDiscounts(Opportunities opportunitiesWithProducts, Decimal discountPercentage)
	{
		fflib_ISObjectUnitOfWork uow = UnitOfWork.newInstance();
		opportunitiesWithProducts.applyDiscount(discountPercentage, uow);
		uow.commitWork();
	}

	public Set<Id> createInvoices(Set<Id> opportunityIds, Decimal discountPercentage)
	{
		fflib_ISObjectUnitOfWork uow = UnitOfWork.newInstance();
		Opportunities opps = Opportunities.newInstance(
			OpportunitiesSelector.newInstance().selectByIdWithProducts(opportunityIds));
		if (discountPercentage != null && discountPercentage > 0)
		{
			opps.applyDiscount(discountPercentage, uow);
		}
		Set<Id> invoiceIds = new Set<Id>();
		for (Opportunity opportunityRecord : (List<Opportunity>) opps.getRecords())
		{
			Invoice__c invoice = new Invoice__c();
			invoice.Account__c = opportunityRecord.AccountId;
			invoice.Description__c = opportunityRecord.Description;
			invoice.InvoiceDate__c = opportunityRecord.CloseDate;
			invoice.Opportunity__c = opportunityRecord.Id;
			uow.registerNew(invoice);
			for (OpportunityLineItem lineItem : opportunityRecord.OpportunityLineItems)
			{
				InvoiceLine__c invoiceLineItem = new InvoiceLine__c();
				invoiceLineItem.Description__c = lineItem.Description;
				invoiceLineItem.Product__c = lineItem.PricebookEntry.Product2Id;
				invoiceLineItem.UnitPrice__c = lineItem.UnitPrice;
				invoiceLineItem.Quantity__c = lineItem.Quantity;
				uow.registerNew(invoiceLineItem, InvoiceLine__c.Invoice__c, invoice);
			}
			invoiceIds.add(invoice.Id);
		}
		uow.commitWork();
		return invoiceIds;
	}

	public Id submitInvoicingJob()
	{
		return Database.executeBatch(new CreateInvoicesJob());
	}
}
