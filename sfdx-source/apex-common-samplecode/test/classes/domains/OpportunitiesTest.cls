/**
 * Copyright (c) 2012-2016, FinancialForce.com, inc
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
 * Domain tests for Opportunities.
 */
@IsTest
private class OpportunitiesTest
{
	@IsTest
	private static void applyDiscountWithoutLinesMutatesAmount()
	{
		// Given an opportunity with an amount and no line items
		Opportunity opp = new Opportunity(
			Id = TestIdGenerator.generate(Opportunity.SObjectType),
			Name = 'Test Opportunity',
			StageName = 'Open',
			Amount = 1000,
			CloseDate = System.today()
		);
		Opportunities opps = Opportunities.newInstance(new List<Opportunity>{ opp });
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
			fflib_SObjectUnitOfWork.class
		);

		// When a discount is applied in the domain
		opps.applyDiscounts(new Map<Id, Decimal>{ opp.Id => 10 }, uowMock);

		// Then the amount is reduced on the wrapped records and registered dirty
		System.assertEquals(1, opps.getRecords().size(), 'Domain should still wrap one opportunity');
		System.assertEquals(900, opp.Amount, 'Amount should be discounted to 900');
		System.assertEquals(900, ((Opportunity) opps.getRecords()[0]).Amount, 'getRecords amount should be 900');
		((fflib_SObjectUnitOfWork) mocks.verify(uowMock)).registerDirty(opp);
	}

	@IsTest
	private static void applyDiscountNoLinesReducesAmount()
	{
		// Given a persisted opportunity with an amount and no lines
		Opportunity opp = new Opportunity(
			Name = 'Test',
			Type = 'New Account',
			StageName = 'Open',
			CloseDate = System.today().addMonths(1),
			Amount = 100
		);
		insert opp;

		// When discounts are applied and updates are committed by the caller
		Opportunities opps = Opportunities.newInstance(new List<Opportunity>{ opp });
		fflib_SObjectUnitOfWork uow = UnitOfWork.newInstance();
		opps.applyDiscounts(new Map<Id, Decimal>{ opp.Id => 10 }, uow);
		uow.commitWork();

		// Then the stored amount reflects the discount
		Opportunity assertOpp = [SELECT Amount FROM Opportunity WHERE Id = :opp.Id];
		System.assertEquals(90, assertOpp.Amount, 'Discount should reduce amount to 90');
	}

	@IsTest
	private static void insertOppUpdatesAccountDesc()
	{
		// Given an account and a related opportunity insert
		Account account = new Account(Name = 'Test', Description = null);
		insert account;
		Opportunity opp = new Opportunity(
			Name = 'Test',
			Type = 'Existing Account',
			StageName = 'Open',
			CloseDate = System.today().addMonths(1),
			AccountId = account.Id
		);

		// When the opportunity is inserted
		insert opp;

		// Then the account description records opportunity activity
		Account assertAccount = [SELECT Description FROM Account WHERE Id = :account.Id];
		System.assertEquals(
			'Last Opportunity Raised ' + System.today(),
			assertAccount.Description,
			'Account description should be updated'
		);
	}
}
