/**
 * Copyright (c) 2012-2014, FinancialForce.com, inc
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

/**
 * Service for Opportunity discounting, invoice creation, and invoicing job submission.
 */
public inherited sharing class OpportunitiesService
{
	@TestVisible
	private static OpportunitiesService mock;

	/**
	 * Factory that returns this service, or {@link #mock} when tests have set one.
	 * @return {@link OpportunitiesService} instance.
	 */
	public static OpportunitiesService newInstance()
	{
		return mock!=null ? mock : new OpportunitiesService();
	}

	private OpportunitiesSelector selector;

	/**
	 * Creates a service using {@link OpportunitiesSelector#newInstance}.
	 */
	public OpportunitiesService()
	{
		this.selector = OpportunitiesSelector.newInstance();
	}

	/**
	 * Applies discounts in one query and one commit.
	 * @param discountByOpportunityId Map of Opportunity Id to discount percent. Empty map performs no DML.
	 * @throws OpportunitiesServiceException When commit fails or another unexpected error occurs.
	 */
	public void applyDiscounts(Map<Id, Decimal> discountByOpportunityId)
	{
		if(discountByOpportunityId==null || discountByOpportunityId.isEmpty())
		{
			return;
		}
		try
		{
			fflib_ISObjectUnitOfWork uow = UnitOfWork.newInstance();
			List<Opportunity> opportunitiesWithProducts = selector.selectByIdWithProducts(discountByOpportunityId.keySet());
			Opportunities opportunities = Opportunities.newInstance(opportunitiesWithProducts);
			opportunities.applyDiscounts(discountByOpportunityId, uow);
			uow.commitWork();
		}
		catch (Exception e)
		{
			throw wrap(e);
		}
	}

	/**
	 * Optionally discounts Opportunities, then creates Invoice__c and InvoiceLine__c records.
	 * Invoice date is CloseDate (the simple Opportunity path; {@link InvoicingService} uses CloseDate plus 14 days).
	 * @param opportunityIds Opportunity Ids to invoice. Empty set returns an empty set.
	 * @param discountPercentage Optional discount applied before invoicing when greater than zero; null or zero skips discounting.
	 * @return Ids of inserted Invoice__c records; empty set when no invoices were created.
	 * @throws OpportunitiesServiceException When commit fails or another unexpected error occurs.
	 */
	public Set<Id> createInvoices(Set<Id> opportunityIds, Decimal discountPercentage)
	{
		try
		{
			fflib_ISObjectUnitOfWork uow = UnitOfWork.newInstance();
			Opportunities opps = Opportunities.newInstance(selector.selectByIdWithProducts(opportunityIds));
			if(discountPercentage!=null && discountPercentage > 0)
			{
				Map<Id, Decimal> discountByOpportunityId = new Map<Id, Decimal>();
				for(Opportunity opportunityRecord : (List<Opportunity>) opps.getRecords())
				{
					discountByOpportunityId.put(opportunityRecord.Id, discountPercentage);
				}
				opps.applyDiscounts(discountByOpportunityId, uow);
			}

			List<Invoice__c> invoices = new List<Invoice__c>();
			for(Opportunity opportunityRecord : (List<Opportunity>) opps.getRecords())
			{
				Invoice__c invoice = new Invoice__c();
				invoice.Account__c = opportunityRecord.AccountId;
				invoice.Description__c = opportunityRecord.Description;
				invoice.InvoiceDate__c = opportunityRecord.CloseDate;
				invoice.Opportunity__c = opportunityRecord.Id;
				uow.registerNew(invoice);
				invoices.add(invoice);
				if(opportunityRecord.OpportunityLineItems==null)
				{
					continue;
				}
				for(OpportunityLineItem lineItem : opportunityRecord.OpportunityLineItems)
				{
					InvoiceLine__c invoiceLineItem = new InvoiceLine__c();
					invoiceLineItem.Description__c = lineItem.Description;
					invoiceLineItem.Product__c = lineItem.PricebookEntry.Product2Id;
					invoiceLineItem.UnitPrice__c = lineItem.UnitPrice;
					invoiceLineItem.Quantity__c = lineItem.Quantity;
					uow.registerNew(invoiceLineItem, InvoiceLine__c.Invoice__c, invoice);
				}
			}
			uow.commitWork();

			Set<Id> invoiceIds = new Set<Id>();
			for(Invoice__c invoice : invoices)
			{
				invoiceIds.add(invoice.Id);
			}
			return invoiceIds;
		}
		catch (Exception e)
		{
			throw wrap(e);
		}
	}

	/**
	 * Submits {@link CreateInvoicesJob} as a Batch Apex job.
	 * @return Async Apex job Id returned by {@code Database.executeBatch}.
	 */
	public Id submitInvoicingJob()
	{
		return Database.executeBatch(new CreateInvoicesJob());
	}

	private static OpportunitiesServiceException wrap(Exception e)
	{
		if(e instanceof OpportunitiesServiceException)
		{
			return (OpportunitiesServiceException) e;
		}
		if(e instanceof DmlException)
		{
			return new OpportunitiesServiceException('Error applying discounts or creating invoices: ' + ((DmlException) e).getDmlMessage(0), e);
		}
		return new OpportunitiesServiceException(e.getMessage(), e);
	}

	/**
	 * Represents an exception thrown by {@link OpportunitiesService} operations.
	 */
	public class OpportunitiesServiceException extends Exception
	{
	}
}
