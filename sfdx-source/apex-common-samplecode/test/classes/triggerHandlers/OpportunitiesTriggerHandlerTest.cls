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
 * This test class demonstrates two approaches to unit testing, with and without DML, each has its own pros and cons
 **/
@IsTest
private class OpportunitiesTriggerHandlerTest
{
	@TestSetup
	static void setup()
	{
		TestDataFactory.createUserWithSampleAppPermissions();
	}

	@IsTest
	private static void validateExistingAccountNoAccountIdFails()
	{
		System.runAs(TestDataFactory.getRunAsUser())
		{
			// Given
			OpportunitiesTriggerHandler opps = OpportunitiesTriggerHandler.newInstance(new List<Opportunity> { new Opportunity(Name = 'Test', Type = 'Existing Account') });

			// When
			opps.onValidate();

			// Then
			System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size(), 'Should have one validation error');
			System.assertEquals('You must provide an Account for OpportunityTriggerHandler for existing Customers.', fflib_SObjectDomain.Errors.getAll()[0].message, 'Error message should match');
			System.assertEquals(Opportunity.AccountId, ((fflib_SObjectDomain.FieldError) fflib_SObjectDomain.Errors.getAll()[0]).field, 'Error field should be AccountId');
		}
	}

	@IsTest
	private static void insertExistingAccountNoAccountIdFails()
	{
		System.runAs(TestDataFactory.getRunAsUser())
		{
			// Given
			Opportunity opp = new Opportunity(Name = 'Test', Type = 'Existing Account');
			fflib_SObjectDomain.Test.Database.onInsert(new Opportunity[] { opp });

			// When
			fflib_SObjectDomain.triggerHandler(OpportunitiesTriggerHandler.class);

			// Then
			System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size(), 'Should have one validation error');
			System.assertEquals('You must provide an Account for OpportunityTriggerHandler for existing Customers.', fflib_SObjectDomain.Errors.getAll()[0].message, 'Error message should match');
			System.assertEquals(Opportunity.AccountId, ((fflib_SObjectDomain.FieldError) fflib_SObjectDomain.Errors.getAll()[0]).field, 'Error field should be AccountId');
		}
	}

	@IsTest
	private static void updateTypeChangeFails()
	{
		System.runAs(TestDataFactory.getRunAsUser())
		{
			// Given
			Opportunity oldOpp = new Opportunity(Name = 'Test', Type = 'Existing Account');
			Opportunity newOpp = new Opportunity(Name = 'Test', Type = 'New Account');
			fflib_SObjectDomain.Test.Database.onUpdate(new Opportunity[] { newOpp }, new Map<Id, SObject> { newOpp.Id => oldOpp });

			// When
			fflib_SObjectDomain.triggerHandler(OpportunitiesTriggerHandler.class);

			// Then
			System.assertEquals(1, fflib_SObjectDomain.Errors.getAll().size(), 'Should have one validation error');
			System.assertEquals('You cannot change the Opportunity type once it has been created.', fflib_SObjectDomain.Errors.getAll()[0].message, 'Error message should match');
			System.assertEquals(Opportunity.Type, ((fflib_SObjectDomain.FieldError) fflib_SObjectDomain.Errors.getAll()[0]).field, 'Error field should be Type');
		}
	}

	@IsTest
	private static void insertValidOpportunityPasses()
	{
		System.runAs(TestDataFactory.getRunAsUser())
		{
			// Given
			Opportunity opp = new Opportunity(Name = 'Test');

			// When
			fflib_SObjectDomain.Test.Database.onInsert(new Opportunity[] { opp });
			fflib_SObjectDomain.triggerHandler(OpportunitiesTriggerHandler.class);

			// Then
			System.assertEquals(0, fflib_SObjectDomain.Errors.getAll().size(), 'Should have no validation errors');
		}
	}
}