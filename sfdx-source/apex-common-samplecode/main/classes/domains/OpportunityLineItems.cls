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

public with sharing class OpportunityLineItems extends fflib_SObjectDomain
{
	public static OpportunityLineItems newInstance(List<OpportunityLineItem> recordList)
	{
		return (OpportunityLineItems) DomainRegistry.newDomain(recordList);
	}

	public static OpportunityLineItems newInstance(Set<Id> recordIdSet)
	{
		return (OpportunityLineItems) DomainRegistry.newDomain(DomainRegistry.selectById(recordIdSet));
	}

	public OpportunityLineItems(List<OpportunityLineItem> sObjectList)
	{
		super(sObjectList);
	}

	public void applyDiscount(Opportunities opps, Decimal discountPercentage, fflib_ISObjectUnitOfWork uow)
	{
		// Opportunties by Id
		Map<Id, Opportunity> opportunitiesById =
			new Map<Id, Opportunity>((List<Opportunity>) opps.getRecords());

		// Calculate discount factor
		Decimal factor = Opportunities.calculateDiscountFactor(discountPercentage);

		for(OpportunityLineItem line : (List<OpportunityLineItem>) this.records)
		{
			// Skip products that have not been approved for discounting
			Opportunity opportunity = opportunitiesById.get(line.OpportunityId);
			if (opportunity.DiscountType__c == 'Approved Products')
			{
				if (line.PricebookEntry.Product2.DiscountingApproved__c == false)
				{
					continue;
				}
			}

			// Minimal record (Id + UnitPrice only): USER_MODE DML enforces FLS on every field in the record; queried records carry OpportunityId, PricebookEntryId, etc. that trigger "fields being inaccessible".
			OpportunityLineItem updateOli = new OpportunityLineItem(Id = line.Id);
			updateOli.UnitPrice = line.UnitPrice * factor;
			uow.registerDirty(updateOli);
		}
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new OpportunityLineItems(sObjectList);
		}
	}
}