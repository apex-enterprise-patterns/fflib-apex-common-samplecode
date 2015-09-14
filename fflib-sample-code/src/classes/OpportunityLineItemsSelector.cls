/**
 * Copyright (c), FinancialForce.com, inc
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

public class OpportunityLineItemsSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			OpportunityLineItem.Description,
			OpportunityLineItem.Id,
			OpportunityLineItem.ListPrice,
			OpportunityLineItem.OpportunityId,
			OpportunityLineItem.PricebookEntryId,
			OpportunityLineItem.Quantity,
			OpportunityLineItem.SortOrder,
			OpportunityLineItem.TotalPrice,
			OpportunityLineItem.UnitPrice
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return OpportunityLineItem.sObjectType;
	}

	public override String getOrderBy()
	{
		return 'SortOrder,PricebookEntry.Name';
	}

	public List<OpportunityLineItem> selectById(Set<ID> idSet)
	{
		return (List<OpportunityLineItem>) selectSObjectsById(idSet);
	}

	public List<OpportunityLineItem> selectRecentlyUsed(Set<Id> accountIds, Integer recordLimit)
	{
		assertIsAccessible();
		String query = String.format('select {0} from {1} where Opportunity.Account.id in :accountIds order by SystemModstamp DESC LIMIT :recordLimit', 
			new List<String>{ getFieldListString(), getSObjectName() });
		return (List<OpportunityLineItem>) Database.query(query);
	}
}