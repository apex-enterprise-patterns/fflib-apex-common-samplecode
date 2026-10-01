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
 * Tests for OpportunitiesTriggerHandler without fflib test harness.
 */
@IsTest
private class OpportunitiesTriggerHandlerTest
{
	@TestSetup
	static void setup()
	{
		// Given a run-as user with sample app permissions
		TestDataFactory.createUserWithSampleAppPermissions();
	}

	@IsTest
	private static void insertExistingAccountNoAccountIdFails()
	{
		System.runAs(TestDataFactory.getRunAsUser())
		{
			// Given an existing-customer opportunity without an account
			Opportunity opp = new Opportunity(
				Name = 'Test',
				Type = 'Existing Account',
				StageName = 'Open',
				CloseDate = System.today()
			);

			// When the opportunity is inserted
			Test.startTest();
			Boolean denied = false;
			try
			{
				insert opp;
			}
			catch (DmlException e)
			{
				denied = true;
				// Then insert fails with the account validation message
				System.assert(
					e.getMessage().contains(
						'You must provide an Account for OpportunityTriggerHandler for existing Customers.'
					),
					'DML error should include validation message'
				);
			}
			Test.stopTest();
			System.assert(denied, 'Expected DmlException for missing AccountId');
		}
	}

	@IsTest
	private static void updateTypeChangeFails()
	{
		System.runAs(TestDataFactory.getRunAsUser())
		{
			// Given a persisted opportunity whose type must not change
			Opportunity opp = new Opportunity(
				Name = 'Test',
				Type = 'New Account',
				StageName = 'Open',
				CloseDate = System.today()
			);
			insert opp;
			opp.Type = 'Existing Account';

			// When the opportunity type is updated
			Test.startTest();
			Boolean denied = false;
			try
			{
				update opp;
			}
			catch (DmlException e)
			{
				denied = true;
				// Then the update fails with the type-change validation message
				System.assert(
					e.getMessage().contains('You cannot change the Opportunity type once it has been created.'),
					'DML error should include type-change validation message'
				);
			}
			Test.stopTest();
			System.assert(denied, 'Expected DmlException when changing Type');
		}
	}

	@IsTest
	private static void insertValidOpportunityPasses()
	{
		System.runAs(TestDataFactory.getRunAsUser())
		{
			// Given a valid new opportunity
			Opportunity opp = new Opportunity(
				Name = 'Test',
				StageName = 'Open',
				CloseDate = System.today()
			);

			// When the opportunity is inserted
			Test.startTest();
			insert opp;
			Test.stopTest();

			// Then insert succeeds
			System.assertNotEquals(null, opp.Id, 'Valid opportunity should insert');
		}
	}
}
