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
 * Tests for QuickOpportunityWizardController Lightning action methods.
 */
@IsTest
private class QuickOpportunityWizardControllerTest {
	@TestSetup
	static void setup() {
		// Given a run-as user with sample app permissions
		TestDataFactory.createUserWithSampleAppPermissions();
	}

	@IsTest
	private static void getWizardDataReturnsAccountNameAndNoLines() {
		System.runAs(TestDataFactory.getRunAsUser()) {
			// Given an account with no opportunity products
			Account account = new Account(Name = 'Wizard Account');
			insert account;

			// When wizard data is loaded
			Test.startTest();
			QuickOpportunityWizardController.ViewState viewState = QuickOpportunityWizardController.getWizardData(
				account.Id
			);
			Test.stopTest();

			// Then the opportunity name defaults to the account name
			System.assertEquals('Wizard Account', viewState.opportunityName, 'Opportunity name should default to Account name');
			System.assertEquals(0, viewState.selectLineItemList.size(), 'No recent line items should be returned');
		}
	}

	@IsTest
	private static void createOpportunityInsertsOpportunityWithoutLines() {
		System.runAs(TestDataFactory.getRunAsUser()) {
			// Given an account and wizard field values with no selected lines
			Account account = new Account(Name = 'Wizard Account');
			insert account;

			// When the wizard creates an opportunity
			Test.startTest();
			Id opportunityId = QuickOpportunityWizardController.createOpportunity(
				account.Id,
				'New Opportunity',
				'Open',
				System.today(),
				new List<QuickOpportunityWizardController.SelectLineItem>()
			);
			Test.stopTest();

			// Then the opportunity is inserted against the account
			Opportunity created = [SELECT Name, AccountId, StageName FROM Opportunity WHERE Id = :opportunityId];
			System.assertEquals('New Opportunity', created.Name, 'Opportunity name should match');
			System.assertEquals(account.Id, created.AccountId, 'Opportunity should belong to the account');
			System.assertEquals('Open', created.StageName, 'Stage should match');
		}
	}
}
