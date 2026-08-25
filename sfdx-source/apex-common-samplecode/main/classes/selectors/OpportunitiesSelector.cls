/**
 * Copyright (c) 2012-2015, FinancialForce.com, inc
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
 * Selector for Opportunity queries used by discounting, invoicing, and summary views.
 */
public virtual inherited sharing class OpportunitiesSelector extends fflib_SObjectSelector
{
	@TestVisible
	private static OpportunitiesSelector mock;

	/**
	 * Factory that returns this selector, or {@link #mock} when tests have set one.
	 * @return {@link OpportunitiesSelector} instance.
	 */
	public static OpportunitiesSelector newInstance()
	{
		return mock!=null ? mock : new OpportunitiesSelector();
	}

	/**
	 * Creates a selector that queries in user mode.
	 */
	public OpportunitiesSelector()
	{
		super(false, fflib_SObjectSelector.DataAccess.USER_MODE);
	}

	/**
	 * Fields included in default queries from this selector.
	 * @return Opportunity Id, AccountId, Amount, CloseDate, Description, DiscountType__c, Name, StageName, and InvoicedStatus__c.
	 */
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>{
			Opportunity.Id,
			Opportunity.AccountId,
			Opportunity.Amount,
			Opportunity.CloseDate,
			Opportunity.Description,
			Opportunity.DiscountType__c,
			Opportunity.Name,
			Opportunity.StageName,
			Opportunity.InvoicedStatus__c
		};
	}

	/**
	 * SObject type this selector queries.
	 * @return {@code Opportunity.SObjectType}.
	 */
	public Schema.SObjectType getSObjectType()
	{
		return Opportunity.SObjectType;
	}

	/**
	 * Selects Opportunities by Id using the Opportunity field list (no related Account fields).
	 * @param idSet Opportunity Ids to query. Empty set returns an empty list.
	 * @return Matching Opportunities; empty list when none match.
	 */
	public List<Opportunity> selectById(Set<Id> idSet)
	{
		return (List<Opportunity>) selectSObjectsById(idSet);
	}

	/**
	 * Factory {@code selectById} uses this method; invoicing needs line items.
	 * @param idSet Opportunity Ids to query. Empty set returns an empty list.
	 * @return Matching Opportunities with nested OpportunityLineItems; empty list when none match.
	 */
	public override List<SObject> selectSObjectsById(Set<Id> idSet)
	{
		return selectByIdWithProducts(idSet);
	}

	/**
	 * Selects Opportunities by Id including line items needed for discount and invoice flows.
	 * @param idSet Opportunity Ids to query. Empty set returns an empty list.
	 * @return Matching Opportunities with nested OpportunityLineItems; empty list when none match.
	 */
	public List<Opportunity> selectByIdWithProducts(Set<Id> idSet)
	{
		fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory();
		opportunitiesQueryFactory.selectField('Account.Name');
		opportunitiesQueryFactory.selectField('Account.AccountNumber');
		opportunitiesQueryFactory.selectField('Account.Owner.Name');

		fflib_QueryFactory lineItemsQueryFactory = OpportunityLineItemsSelector.newInstance()
			.addQueryFactorySubselect(opportunitiesQueryFactory);

		PricebookEntriesSelector.newInstance()
			.configureQueryFactoryFields(lineItemsQueryFactory, 'PricebookEntry');
		ProductsSelector.newInstance()
			.configureQueryFactoryFields(lineItemsQueryFactory, 'PricebookEntry.Product2');
		PricebooksSelector.newInstance()
			.configureQueryFactoryFields(lineItemsQueryFactory, 'PricebookEntry.Pricebook2');

		return (List<Opportunity>) Database.query(
			opportunitiesQueryFactory.setCondition('Id IN :idSet').toSOQL()
		);
	}

	/**
	 * Selects read-only opportunity summary DTOs including related Account and owner names.
	 * @param idSet Opportunity Ids to query. Empty set returns an empty list.
	 * @return {@link OpportunitySummary} wrappers; empty list when none match.
	 */
	public List<OpportunitySummary> selectOpportunitySummary(Set<Id> idSet)
	{
		List<OpportunitySummary> opportunitySummaries = new List<OpportunitySummary>();
		for(
			Opportunity opportunity : (List<Opportunity>) Database.query(
				newQueryFactory(false)
					.selectField(Opportunity.Id)
					.selectField(Opportunity.Amount)
					.selectField(Opportunity.StageName)
					.selectField('Account.Name')
					.selectField('Account.AccountNumber')
					.selectField('Account.Owner.Name')
					.setCondition('Id IN :idSet')
					.toSOQL()
			)
		)
		{
			opportunitySummaries.add(new OpportunitySummary(opportunity));
		}
		return opportunitySummaries;
	}

	/**
	 * Returns a QueryLocator for Opportunities whose InvoicedStatus__c is Ready.
	 * @return QueryLocator suitable for Batch Apex start methods. Fields match {@link #selectById}.
	 */
	public Database.QueryLocator readyToInvoiceAsQueryLocator()
	{
		return Database.getQueryLocator(
			newQueryFactory().setCondition('InvoicedStatus__c = \'Ready\'').toSOQL()
		);
	}
}
