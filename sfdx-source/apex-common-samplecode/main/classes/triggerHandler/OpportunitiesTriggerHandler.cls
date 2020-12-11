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

public class OpportunitiesTriggerHandler extends fflib_SObjectDomain
{
	/**
	 * Provides easy access to the domain
	 *
	 * @return Instance of the Opportunities Domain
	 */
	private IOpportunities newDomain()
	{
		return (IOpportunities) Application.Domain.newInstance(getRecords(), Schema.Opportunity.SObjectType);
	}
	private IOpportunities newDomain(List<SObject> recordList)
	{
		return (IOpportunities) Application.Domain.newInstance(recordList, Schema.Opportunity.SObjectType);
	}

	/**
	 * Class Constructor
	 *
	 * @param sObjectList The records processed by the Trigger Handler
	 */
	public OpportunitiesTriggerHandler(List<Opportunity> sObjectList)
	{
		// Domain classes are initialised with lists to enforce nullification throughout
		super(sObjectList);
	}

	/**
	 * Business logic to be performed on AFTER_INSERT trigger operations
	 */
	public override void onAfterInsert()
	{
		updateOpportunityActivityOnRelatedAccounts();
	}

	/**
	 * Apply defaults to OpportunitiesTriggerHandler
	 */
	public override void onApplyDefaults()
	{
		newDomain()
				.setDiscountType(OpportunitySettings__c.getInstance().DiscountType__c);
	}

	/**
	 * Validates existing records in an INSERT trigger operation
	 */
	public override void onValidate()
	{
		validateAccountForExistingCustomers();
	}

	/**
	 * Validates existing records in an UPDATE trigger operation
	 * @param existingRecords Reference to Trigger.OldMap
	 */
	public override void onValidate(Map<Id, SObject> existingRecords)
	{
		validateThatTypeIsUnchanged();
	}

	/**
	 * Updates the related accounts with a Timestamp of the last opportunity activity
	 */
	// Todo - Refactor
	private void updateOpportunityActivityOnRelatedAccounts()
	{
		Set<Id> accountIds = newDomain().getAccountIds();

		// Todo - Here should be a call to a service method on AccountsService
		//  as it is not the concern of the Opportunity domain to know about Accounts.

		// Update last Opportunity activity on the related Accounts (via the Accounts domain class)
		fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {Account.SObjectType});
		Accounts accounts = new Accounts([SELECT Id, Name FROM Account WHERE Id IN :accountIds]);
		accounts.updateOpportunityActivity(uow);
		uow.commitWork();
	}

	// Todo - Refactor
	public void applyDiscount(Decimal discountPercentage, fflib_ISObjectUnitOfWork uow)
	{
		// Calculate discount factor
		Decimal factor = calculateDiscountFactor(discountPercentage);

		// Opportunity lines to apply discount to
		List<OpportunityLineItem> linesToApplyDiscount = new List<OpportunityLineItem>();

		// Apply discount
		for(Opportunity opportunity : (List<Opportunity>) Records)
		{
			// Apply to the Opportunity Amount?
			if(opportunity.OpportunityLineItems == null ||
			   opportunity.OpportunityLineItems.size()==0)
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
		IOpportunityLineItems lineItems =
			(IOpportunityLineItems) Application.Domain.newInstance(linesToApplyDiscount);
		lineItems.applyDiscount(newDomain(), discountPercentage, uow);
	}

	// Todo - Refactor
	public static Decimal calculateDiscountFactor(Decimal discountPercentage)
	{
		// Calculate discount factor
		Decimal discountProportion = discountPercentage == null ? 0 : discountPercentage / 100;
		Decimal factor = 1 - discountProportion;
		return factor;
	}


	/**
	 * Validates that Opportunities should have an account when the Opportunity Type is "Existing*"
	 */
	private void validateAccountForExistingCustomers()
	{
		IOpportunities opportunitiesWithoutAccounts =
				newDomain().selectWithoutAccountsByExistingCustomers();

		if (opportunitiesWithoutAccounts.getObjects().isEmpty()) return;

		opportunitiesWithoutAccounts.addAccountError(
				'You must provide an Account for Opportunities for existing Customers.'
		);
	}

	/**
	 * Validates that the Opportunity Type is not changed,
	 * if it is changed an field error is added
	 */
	private void validateThatTypeIsUnchanged()
	{
		List<SObject> changedRecords = getChangedRecords(new Set<SObjectField> {Opportunity.Type});

		if (changedRecords.isEmpty()) return;

		newDomain(changedRecords)
				.addTypeError('You cannot change the Opportunity type once it has been created.');
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new OpportunitiesTriggerHandler(sObjectList);
		}
	}
}