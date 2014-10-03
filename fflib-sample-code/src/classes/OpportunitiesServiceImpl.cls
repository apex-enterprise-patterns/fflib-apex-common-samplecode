/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public class OpportunitiesServiceImpl 
	implements IOpportunitiesService
{
	public void applyDiscounts(Set<ID> opportunityIds, Decimal discountPercentage)
	{
		// Create unit of work to capture work and commit it under one transaction
	    fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
	    	    	    	  	    										
		// Query Opportunities
		List<Opportunity> oppRecords = 
			OpportunitiesSelector.newInstance().selectByIdWithProducts(opportunityIds);

		// Apply discount via Opportunties domain class behaviour
		IOpportunities opps = Opportunities.newInstance(oppRecords);				
		opps.applyDiscount(discountPercentage, uow);
		
		// Commit updates to opportunities		
		uow.commitWork();						
	}

	public Set<Id> createInvoices(Set<ID> opportunityIds, Decimal discountPercentage)
	{
		// Create unit of work to capture work and commit it under one transaction
	    fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
	    										
		// Query Opportunities
		IOpportunities opps = 
			Opportunities.newInstance(
				OpportunitiesSelector.newInstance().selectByIdWithProducts(opportunityIds));		
		
		// Optionally apply discounts as part of invoice creation
		if(discountPercentage!=null && discountPercentage>0)
			opps.applyDiscount(discountPercentage, uow);		
		
		// Create Invoices from the given opportunities
		List<SObject> invoices = new List<SObject>();
		for(Opportunity opportunityRecord : (List<Opportunity>) opps.getRecords())		
		{
			Invoice__c invoice = new Invoice__c();
			invoice.Account__c = opportunityRecord.AccountId;
			invoice.Description__c = opportunityRecord.Description;
			invoice.InvoiceDate__c = opportunityRecord.CloseDate;
			invoice.Opportunity__c = opportunityRecord.Id;
			uow.registerNew(invoice);
			for(OpportunityLineItem lineItem : opportunityRecord.OpportunityLineItems)
			{
				InvoiceLine__c invoiceLineItem = new InvoiceLine__c();
				invoiceLineItem.Description__c = lineItem.Description;
				invoiceLineItem.Product__c = lineItem.PricebookEntry.Product2Id;
				invoiceLineItem.UnitPrice__c = lineItem.UnitPrice;
				invoiceLineItem.Quantity__c = lineItem.Quantity;
				uow.registerNew(invoiceLineItem, InvoiceLine__c.Invoice__c, invoice);
			}
			invoices.add(invoice);
		}
		
		// Commit any Opportunity updates and new invoices
		uow.commitWork();									
		
		// Invoice Ids
		Set<Id> invoiceIds = new Set<Id>();
		for(SObject invoice : invoices)
			invoiceIds.add((ID)invoice.get('Id'));
		return invoiceIds;
	}
	
	public Id submitInvoicingJob()
	{
		// Submit the job via Batch Apex, 
		//   service layer can perform validations and updates such as logging etc on behalf of client
		//   also configure scope size, knowledge of the class to use etc is encapsulated in the service		
		return Database.executeBatch(new CreateInvoicesJob());		
	}
}