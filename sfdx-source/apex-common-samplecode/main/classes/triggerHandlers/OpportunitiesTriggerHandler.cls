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
 * Opportunity trigger handler that applies defaults, validates records, and updates related Account activity.
 */
public inherited sharing class OpportunitiesTriggerHandler extends fflib_SObjectDomain
{
	/**
	 * Creates a handler for the given Opportunity records.
	 * @param sObjectList Trigger.new records. Cannot be null.
	 */
	public OpportunitiesTriggerHandler(List<Opportunity> sObjectList)
	{
		super(sObjectList);
	}

	/**
	 * Sets DiscountType__c from {@link OpportunitySettings__c} on each Opportunity.
	 */
	public override void onApplyDefaults()
	{
		for(Opportunity opportunity : (List<Opportunity>) Records)
		{
			opportunity.DiscountType__c = OpportunitySettings__c.getInstance().DiscountType__c;
		}
	}

	/**
	 * Validates new Opportunities: Existing* types require an AccountId.
	 */
	public override void onValidate()
	{
		for(Opportunity opp : (List<Opportunity>) Records)
		{
			if(opp.Type!=null && opp.Type.startsWith('Existing') && opp.AccountId==null)
			{
				opp.AccountId.addError(
					error('You must provide an Account for OpportunityTriggerHandler for existing Customers.', opp, Opportunity.AccountId)
				);
			}
		}
	}

	/**
	 * Validates updates: Opportunity Type cannot change after create.
	 * @param existingRecords Prior Opportunity versions keyed by Id. Cannot be null.
	 */
	public override void onValidate(Map<Id, SObject> existingRecords)
	{
		for(Opportunity opp : (List<Opportunity>) Records)
		{
			Opportunity existingOpp = (Opportunity) existingRecords.get(opp.Id);
			if(opp.Type!=existingOpp.Type)
			{
				opp.Type.addError(
					error('You cannot change the Opportunity type once it has been created.', opp, Opportunity.Type)
				);
			}
		}
	}

	/**
	 * Updates Description on related Accounts to record opportunity activity.
	 */
	public override void onAfterInsert()
	{
		updateOpportunityActivityOnAccount();
	}

	private void updateOpportunityActivityOnAccount()
	{
		Set<Id> accountIds =
			Opportunities.newInstance((List<Opportunity>) Records).getAccountIds();

		if(accountIds.isEmpty())
		{
			return;
		}

		AccountsService.newInstance().updateOpportunityActivity(accountIds);
	}

	/**
	 * Constructs this handler from a trigger record list.
	 */
	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new OpportunitiesTriggerHandler((List<Opportunity>) sObjectList);
		}
	}
}
