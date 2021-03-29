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

public class Opportunities extends fflib_SObjects
	implements IOpportunities, InvoicingService.ISupportInvoicing
{
	public static IOpportunities newInstance(List<Opportunity> recordList)
	{
		return (IOpportunities) Application.Domain.newInstance(recordList);
	}

	public static IOpportunities newInstance(Set<Id> recordIdSet)
	{
		return (IOpportunities) Application.Domain.newInstance(recordIdSet);
	}
	
	public Opportunities(List<Opportunity> sObjectList)
	{
		// Domain classes are initialised with lists to enforce bulkification throughout
		super(sObjectList);
	}
	
	public void generate(InvoicingService.InvoiceFactory invoiceFactory)
	{
		// Utilise InvoiceFactory to create invoices from Opportunity details
		for(Opportunity opportunity : (List<Opportunity>) getRecords())
		{
			InvoicingService.Invoice invoice = new InvoicingService.Invoice();
			invoice.Account = opportunity.AccountId;
			invoice.Description = opportunity.Description;
			invoice.InvoiceDate = opportunity.CloseDate.addDays(14);
			invoice.Lines = new List<InvoicingService.InvoiceLine>();
			for(OpportunityLineItem lineItem : opportunity.OpportunityLineItems)
			{
				InvoicingService.InvoiceLine invoiceLineItem = new InvoicingService.InvoiceLine();
				invoiceLineItem.Description = lineItem.Description;
				invoiceLineItem.Product = lineItem.PricebookEntry.Product2Id;
				invoiceLineItem.UnitPrice = lineItem.UnitPrice;
				invoiceLineItem.Quantity = lineItem.Quantity;
				invoice.Lines.add(invoiceLineItem);
			}			
			invoiceFactory.add(invoice);
		}
	}

	public void applyDiscount(Decimal discountPercentage, fflib_ISObjectUnitOfWork uow)
	{
		// Calculate discount factor
		Decimal factor = calculateDiscountFactor(discountPercentage);

		// Opportunity lines to apply discount to
		List<OpportunityLineItem> linesToApplyDiscount = new List<OpportunityLineItem>();
		
		// Apply discount 
		for(Opportunity opportunity : (List<Opportunity>) getRecords())
		{
			// Apply to the Opportunity Amount?
			if(opportunity.OpportunityLineItems == null 
        || opportunity.OpportunityLineItems.isEmpty())
			{
				// Adjust the Amount on the Opportunity if no lines
				opportunity.Amount = opportunity.Amount * factor;
				uow.registerDirty(opportunity);
			}
			else
			{
				// Collect lines to apply discount to
				linesToApplyDiscount.addAll(opportunity.OpportunityLineItems);
			}
		}		
		
		// Apply discount to lines
		IOpportunityLineItems lineItems = (IOpportunityLineItems) Application.Domain.newInstance(linesToApplyDiscount);

		lineItems.applyDiscount(this, discountPercentage, uow);
	}

	public static Decimal calculateDiscountFactor(Decimal discountPercentage)
	{
		// Calculate discount factor
		Decimal discountProportion = discountPercentage==null ? 0 : discountPercentage / 100;
		Decimal factor = 1 - discountProportion;
		return factor;
	}

	public Set<Id> getAccountIds()
	{
		Set<Id> result = new Set<Id>();
		for (Opportunity record : (List<Opportunity>) getRecords())
		{
			if (record.AccountId != null)
			{
				result.add(record.AccountId);
			}
		}
		return result;
	}

	public class Constructor implements fflib_IDomainConstructor
	{
		public fflib_SObjects construct(List<Object> objectList)
		{
			return new Opportunities((List<SObject>) objectList);
		}
	}
}