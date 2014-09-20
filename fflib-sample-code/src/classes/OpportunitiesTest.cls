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

/**
 * This test class demonstrates two approaches to unit testing, with and without DML, each has its own pros and cons
 **/
@IsTest
private class OpportunitiesTest 
{
	@IsTest
	private static void callingApplyDiscountShouldCalcDiscountAndRegisterDirty()
	{
		// Create mocks
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);

		// Given
		Opportunity opp = new Opportunity(
			Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
			Name = 'Test Opportunity',
			StageName = 'Open',
			Amount = 1000,
			CloseDate = System.today());
		List<Opportunity> testOppsList = new List<Opportunity> { opp };
		Decimal discountPercent = 10;
		Application.UnitOfWork.setMock(uowMock);

		// When
		IOpportunities opps = 
			Opportunities.newInstance(testOppsList);
		opps.applyDiscount(discountPercent, uowMock);

		// Then
		((fflib_ISObjectUnitOfWork) 
			mocks.verify(uowMock, 1)).registerDirty(opp);
		System.assertEquals(900, opp.Amount);
	}	

	@IsTest
	private static void testValidationWithoutDML()
	{
		Opportunities opps = new Opportunities(new Opportunity[] { new Opportunity ( Name = 'Test', Type = 'Existing Account' ) } );
		opps.onValidate();
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());		
		System.assertEquals('You must provide an Account for Opportunities for existing Customers.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(Opportunity.AccountId, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field); 		
	}
	
	@IsTest
	private static void testInsertValidationFailedWithoutDML()
	{
		Opportunity opp = new Opportunity ( Name = 'Test', Type = 'Existing Account' );
		fflib_SObjectDomain.Test.Database.onInsert(new Opportunity[] { opp } );		
		fflib_SObjectDomain.triggerHandler(Opportunities.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());		
		System.assertEquals('You must provide an Account for Opportunities for existing Customers.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(Opportunity.AccountId, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field); 		
	}

	@IsTest
	private static void testUpdateValidationFailedWithoutDML()
	{
		Opportunity oldOpp = new Opportunity ( Name = 'Test', Type = 'Existing Account' );
		Opportunity newOpp = new Opportunity ( Name = 'Test', Type = 'New Account' );
		fflib_SObjectDomain.Test.Database.onUpdate(new Opportunity[] { newOpp }, new Map<Id, SObject> { newOpp.Id => oldOpp } );		
		fflib_SObjectDomain.triggerHandler(Opportunities.class);		
		System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size());		
		System.assertEquals('You cannot change the Opportunity type once it has been created.', fflib_SObjectDomain.Errors.getAll()[0].message);
		System.assertEquals(Opportunity.Type, ((fflib_SObjectDomain.FieldError)fflib_SObjectDomain.Errors.getAll()[0]).field); 		
	}
	
	@IsTest
	private static void testInsertValidationSuccessWithoutDML()
	{
		Opportunity opp = new Opportunity ( Name = 'Test' );
		fflib_SObjectDomain.Test.Database.onInsert(new Opportunity[] { opp } );		
		fflib_SObjectDomain.triggerHandler(Opportunities.class);
		System.assertEquals(fflib_SObjectDomain.Errors.getAll().size(), 0);		
	}
			
	@IsTest
	private static void testApplyDiscountWithoutOpportunityLines()
	{
		Opportunity opp = new Opportunity ( 
			Name = 'Test', 
			Type = 'New Account',
			StageName = 'Open',
			CloseDate = System.today().addMonths(1), 
			Amount = 100 );
		insert opp;			
		fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork( new Schema.SObjectType[] { Opportunity.SObjectType });				
		Opportunities opps = new Opportunities(new List<Opportunity> { opp });
		opps.applyDiscount(10, uow);
		uow.commitWork();		
		Opportunity assertOpp = [select Amount from Opportunity where Id = :opp.Id];
		System.assertEquals(90, assertOpp.Amount);				
	}
		
	@IsTest
	private static void testUpdateAccountOnInsertOfOpportunity()
	{
		Account account = new Account( 
			Name = 'Test', 
			Description = null );
		insert account;
		Opportunity opp = new Opportunity ( 
			Name = 'Test', 
			Type = 'Existing Account',
			StageName = 'Open',
			CloseDate = System.today().addMonths(1), 
			AccountId = account.Id );
		insert opp;		
		Account assertAccount = [select Description from Account where Id = :account.Id];
		System.assertEquals('Last Opportunity Raised ' + System.today(), assertAccount.Description);		
	}			
}