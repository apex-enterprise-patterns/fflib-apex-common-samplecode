/**
 * Copyright (c) 2013-2014, FinancialForce.com, inc
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
 * Domain for OpportunityLineItem discounting based on parent Opportunity discount rules.
 */
public virtual inherited sharing class OpportunityLineItems extends fflib_SObjects
{
	@TestVisible
	private static OpportunityLineItems mock;

	/**
	 * Factory that wraps the given line items, or {@link #mock} when tests have set one.
	 * @param recordList Opportunity line items to manage. Null is treated as an empty list.
	 * @return {@link OpportunityLineItems} instance.
	 */
	public static OpportunityLineItems newInstance(List<OpportunityLineItem> recordList)
	{
		return mock!=null ? mock : new OpportunityLineItems(recordList);
	}

	/**
	 * Creates a domain wrapping the given OpportunityLineItem records.
	 * @param sObjectList Opportunity line items to manage. Null is treated as an empty list.
	 */
	public OpportunityLineItems(List<OpportunityLineItem> sObjectList)
	{
		super(sObjectList==null ? new List<OpportunityLineItem>() : sObjectList);
	}

	/**
	 * Applies discounts for each Opportunity Line Item Id and percentage pair.
	 * When the parent Opportunity DiscountType__c is Approved Products, only lines whose
	 * product has DiscountingApproved__c true are changed. Registers a minimal dirty
	 * record (Id + UnitPrice) on the Unit of Work so user-mode DML does not touch unread fields.
	 * @param opps Parent opportunities providing DiscountType__c context. Cannot be null.
	 * @param discountByOpportunityLineItemId Map of Opportunity Line Item Id to discount percent.
	 * @param uow Unit of Work that receives dirty line items. Cannot be null.
	 */
	public virtual void applyDiscounts(
		Opportunities opps,
		Map<Id, Decimal> discountByOpportunityLineItemId,
		fflib_SObjectUnitOfWork uow
	)
	{
		Map<Id, Opportunity> opportunitiesById = new Map<Id, Opportunity>((List<Opportunity>) opps.getRecords());
		for(OpportunityLineItem line : (List<OpportunityLineItem>) getRecords())
		{
			// Apply discount to the line item only if the parent product has Approved Products discounting.
			Decimal discountPercentage = discountByOpportunityLineItemId.get(line.Id);
			Opportunity opportunity = opportunitiesById.get(line.OpportunityId);
			if(opportunity.DiscountType__c=='Approved Products')
			{
				if(line.PricebookEntry.Product2.DiscountingApproved__c==false)
				{
					continue;
				}
			}
			Decimal factor = Opportunities.calculateDiscountFactor(discountPercentage);
			line.UnitPrice = line.UnitPrice * factor;
			uow.registerDirty(new OpportunityLineItem(Id = line.Id, UnitPrice = line.UnitPrice));
		}
	}
}
