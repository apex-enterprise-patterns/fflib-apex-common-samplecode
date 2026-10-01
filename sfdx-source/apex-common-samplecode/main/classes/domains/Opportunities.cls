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
 * Domain for Opportunity records that supports discounting and invoice generation.
 * Implements {@link InvoicingService.ISupportInvoicing} for polymorphic invoicing.
 */
public virtual inherited sharing class Opportunities extends fflib_SObjects
	implements InvoicingService.ISupportInvoicing
{
	@TestVisible
	private static Opportunities mock;

	/**
	 * Factory that wraps the given Opportunity records, or {@link #mock} when tests have set one.
	 * Domain records are not known until the caller has them, so this factory (not a constructor
	 * collaborator) is the seam for substituting a domain created mid-method.
	 * @param recordList Opportunities to manage. Null is treated as an empty list.
	 * @return {@link Opportunities} instance.
	 */
	public static Opportunities newInstance(List<Opportunity> recordList)
	{
		return mock!=null ? mock : new Opportunities(recordList);
	}

	/**
	 * Creates a domain wrapping the given Opportunity records.
	 * @param sObjectList Opportunities to manage. Null is treated as an empty list.
	 */
	public Opportunities(List<Opportunity> sObjectList)
	{
		super(sObjectList==null ? new List<Opportunity>() : sObjectList);
	}

	/**
	 * Builds invoice DTOs from each Opportunity and its line items into the factory.
	 * Invoice date is CloseDate plus 14 days; product comes from the pricebook entry.
	 * @param invoiceFactory Factory that collects invoice headers and lines. Cannot be null.
	 */
	public virtual void generate(InvoicingService.InvoiceFactory invoiceFactory)
	{
		for(Opportunity opportunity : (List<Opportunity>) getRecords())
		{
			InvoicingService.Invoice invoice = new InvoicingService.Invoice();
			invoice.Account = opportunity.AccountId;
			invoice.Description = opportunity.Description;
			invoice.InvoiceDate = opportunity.CloseDate.addDays(14);
			invoice.Lines = new List<InvoicingService.InvoiceLine>();
			if(opportunity.OpportunityLineItems!=null)
			{
				for(OpportunityLineItem lineItem : opportunity.OpportunityLineItems)
				{
					InvoicingService.InvoiceLine invoiceLineItem = new InvoicingService.InvoiceLine();
					invoiceLineItem.Description = lineItem.Description;
					invoiceLineItem.Product = lineItem.PricebookEntry.Product2Id;
					invoiceLineItem.UnitPrice = lineItem.UnitPrice;
					invoiceLineItem.Quantity = lineItem.Quantity;
					invoice.Lines.add(invoiceLineItem);
				}
			}
			invoiceFactory.add(invoice);
		}
	}

	/**
	 * Applies discounts for each Opportunity Id and percentage pair on this domain instance.
	 * Registers dirty records on the Unit of Work. Does not commit.
	 * @param discountByOpportunityId Map of Opportunity Id to discount percent.
	 * @param uow Unit of Work that receives dirty Opportunity / line item records. Cannot be null.
	 */
	public virtual void applyDiscounts(Map<Id, Decimal> discountByOpportunityId, fflib_SObjectUnitOfWork uow)
	{
		if(discountByOpportunityId==null || discountByOpportunityId.isEmpty())
		{
			return;
		}
		List<OpportunityLineItem> linesToApplyDiscount = new List<OpportunityLineItem>();
		Map<Id, Decimal> discountByOpportunityLineItemId = new Map<Id, Decimal>();

		// Apply discounts to Opportunities without lines, or to their line items.
		for(Opportunity opportunity : (List<Opportunity>) getRecords())
		{
			Decimal discountPercentage = discountByOpportunityId.get(opportunity.Id);
			if(opportunity.OpportunityLineItems==null || opportunity.OpportunityLineItems.isEmpty())
			{
				// Apply discount to the Opportunity (no line items).
				Decimal factor = calculateDiscountFactor(discountPercentage);
				opportunity.Amount = opportunity.Amount * factor;
				uow.registerDirty(opportunity);
			}
			else
			{
				for(OpportunityLineItem lineItem : opportunity.OpportunityLineItems)
				{
					linesToApplyDiscount.add(lineItem);
					discountByOpportunityLineItemId.put(lineItem.Id, discountPercentage);
				}
			}
		}

		// Apply discounts to line items.
		if(!linesToApplyDiscount.isEmpty())
		{
			OpportunityLineItems.newInstance(linesToApplyDiscount)
				.applyDiscounts(this, discountByOpportunityLineItemId, uow);
		}
	}

	/**
	 * Converts a discount percentage into a multiplicative factor.
	 * @param discountPercentage Discount percent (for example 10 for 10%). Null is treated as zero.
	 * @return Factor to multiply prices by (for example 0.9 for a 10% discount).
	 */
	public static Decimal calculateDiscountFactor(Decimal discountPercentage)
	{
		Decimal discountProportion = discountPercentage==null ? 0 : discountPercentage / 100;
		return 1 - discountProportion;
	}

	/**
	 * Collects distinct Account Ids from the Opportunities in this domain.
	 * @return Account Ids present on the records; empty when none have an AccountId.
	 */
	public Set<Id> getAccountIds()
	{
		Set<Id> result = new Set<Id>();
		for(Opportunity record : (List<Opportunity>) getRecords())
		{
			if(record.AccountId!=null)
			{
				result.add(record.AccountId);
			}
		}
		return result;
	}

	/**
	 * Constructs this domain from a record list for {@link fflib_Application.DomainFactory}.
	 */
	public class Constructor implements fflib_IDomainConstructor
	{
		public fflib_IDomain construct(List<Object> objects)
		{
			return new Opportunities((List<Opportunity>) objects);
		}
	}
}
