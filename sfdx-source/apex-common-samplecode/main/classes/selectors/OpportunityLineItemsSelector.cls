/**
 * Copyright (c) 2013-2015, FinancialForce.com, inc
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
 * Selector for OpportunityLineItem queries used by discount and wizard flows.
 */
public virtual inherited sharing class OpportunityLineItemsSelector extends fflib_SObjectSelector
{
	@TestVisible
	private static OpportunityLineItemsSelector mock;

	/**
	 * Factory that returns this selector, or {@link #mock} when tests have set one.
	 * @return {@link OpportunityLineItemsSelector} instance.
	 */
	public static OpportunityLineItemsSelector newInstance()
	{
		return mock!=null ? mock : new OpportunityLineItemsSelector();
	}

	/**
	 * Creates a selector that queries in user mode.
	 */
	public OpportunityLineItemsSelector()
	{
		super(false, fflib_SObjectSelector.DataAccess.USER_MODE);
	}

	/**
	 * Fields included in default queries from this selector.
	 * @return OpportunityLineItem Id, OpportunityId, Description, Quantity, UnitPrice, ListPrice, PricebookEntryId, and SortOrder.
	 */
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>{
			OpportunityLineItem.Id,
			OpportunityLineItem.OpportunityId,
			OpportunityLineItem.Description,
			OpportunityLineItem.Quantity,
			OpportunityLineItem.UnitPrice,
			OpportunityLineItem.ListPrice,
			OpportunityLineItem.PricebookEntryId,
			OpportunityLineItem.SortOrder
		};
	}

	/**
	 * SObject type this selector queries.
	 * @return {@code OpportunityLineItem.SObjectType}.
	 */
	public Schema.SObjectType getSObjectType()
	{
		return OpportunityLineItem.SObjectType;
	}

	/**
	 * Selects OpportunityLineItems by Id with fields used by discounting, invoicing, and the wizard.
	 * @param idSet OpportunityLineItem Ids to query. Empty set returns an empty list.
	 * @return Matching line items; empty list when none match.
	 */
	public List<OpportunityLineItem> selectById(Set<Id> idSet)
	{
		return (List<OpportunityLineItem>) selectSObjectsById(idSet);
	}

	/**
	 * Selects recently modified line items for Opportunities belonging to the given Accounts.
	 * @param accountIds Account Ids whose related opportunity line items are included. Empty set returns an empty list.
	 * @param recordLimit Maximum number of rows to return.
	 * @return Matching line items ordered by SystemModstamp descending; empty list when none match.
	 */
	public List<OpportunityLineItem> selectRecentlyUsed(Set<Id> accountIds, Integer recordLimit)
	{
		return (List<OpportunityLineItem>) Database.query(
			newQueryFactory()
				.selectField('PricebookEntry.Name')
				.selectField('PricebookEntry.Product2Id')
				.selectField('PricebookEntry.Product2.DiscountingApproved__c')
				.selectField('PricebookEntry.Pricebook2.Name')
				.setCondition('Opportunity.AccountId IN :accountIds')
				.setOrdering('SystemModstamp', fflib_QueryFactory.SortOrder.DESCENDING)
				.setLimit(recordLimit)
				.toSOQL()
		);
	}
}
