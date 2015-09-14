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

public class OpportunitiesSelector extends fflib_SObjectSelector
	implements IOpportunitiesSelector
{
	public static IOpportunitiesSelector newInstance()
	{
		return (IOpportunitiesSelector) Application.Selector.newInstance(Opportunity.SObjectType);
	}
	
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Opportunity.AccountId,
			Opportunity.Amount,
			Opportunity.CloseDate,
			Opportunity.Description,
			Opportunity.ExpectedRevenue,
			Opportunity.Id,
			Opportunity.Name,
			Opportunity.Pricebook2Id,
			Opportunity.Probability,
			Opportunity.StageName,
			Opportunity.Type,
			Opportunity.DiscountType__c
		};
	}
	
	public Schema.SObjectType getSObjectType()
	{
		return Opportunity.sObjectType;
	}

	public List<Opportunity> selectById(Set<ID> idSet)
	{
		return (List<Opportunity>) selectSObjectsById(idSet);
	}

	public List<Opportunity> selectByIdWithProducts(Set<ID> idSet)
	{
		fflib_QueryFactory opportunitiesQueryFactory = newQueryFactory();

		fflib_QueryFactory lineItemsQueryFactory = 
			new OpportunityLineItemsSelector().
				addQueryFactorySubselect(opportunitiesQueryFactory);
			
		new PricebookEntriesSelector().
			configureQueryFactoryFields(lineItemsQueryFactory, 'PricebookEntry');
		new ProductsSelector().
			configureQueryFactoryFields(lineItemsQueryFactory, 'PricebookEntry.Product2');
		new PricebooksSelector().
			configureQueryFactoryFields(lineItemsQueryFactory, 'PricebookEntry.Pricebook2');

		return (List<Opportunity>) Database.query(
			opportunitiesQueryFactory.setCondition('id in :idSet').toSOQL());
	}
	
	public List<OpportunityInfo> selectOpportunityInfo(Set<Id> idSet)
	{
		List<OpportunityInfo> opportunityInfos = new List<OpportunityInfo>();
		for(Opportunity opportunity : Database.query(
				newQueryFactory(false).
					selectField(Opportunity.Id).
					selectField(Opportunity.StageName).
					selectField('Account.Name').
					selectField('Account.AccountNumber').
					selectField('Account.Owner.Name').
					setCondition('id in :idSet').
					toSOQL()))
			opportunityInfos.add(new OpportunityInfo(opportunity));
		return opportunityInfos;	
	}
	
	public Database.QueryLocator queryLocatorReadyToInvoice()
	{
		return Database.getQueryLocator(
			newQueryFactory().setCondition('InvoicedStatus__c = \'\'Ready\'\'').toSOQL());
	}
	
	public class OpportunityInfo
	{		 
		private Opportunity opportunity;
		public Id Id { get { return opportunity.Id; } }		
		public Decimal Amount { get { return opportunity.Amount; } }		
		public String Stage { get { return opportunity.StageName; } }		
		public String AccountName { get { return opportunity.Account.Name; } }		
		public String AccountNumber { get { return opportunity.Account.AccountNumber; } }		
		public String AccountOwner { get { return opportunity.Account.Owner.Name; } }
		private OpportunityInfo(Opportunity opportunity) { this.opportunity = opportunity; }		 
	}
}