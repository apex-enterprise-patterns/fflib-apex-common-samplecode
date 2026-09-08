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
 * Integration test for OpportunitiesService.applyDiscounts.
 */
@IsTest
private class OpportunitiesServiceIntegrationTest
{
	@TestSetup
	static void setup()
	{
		// Given a run-as user with sample app permissions
		TestDataFactory.createUserWithSampleAppPermissions();
	}

	@IsTest
	private static void applyDiscountsAsRunAsUserReducesAmount()
	{
		// Given an opportunity with priced line items
		Opportunity opp = new Opportunity(
			Name = 'Test',
			StageName = 'Open',
			CloseDate = System.today(),
			Pricebook2Id = Test.getStandardPricebookId()
		);
		insert opp;

		List<Product2> products = new List<Product2>();
		for(Integer i = 0; i < 10; i++)
		{
			products.add(new Product2(Name = opp.Name + ' : Product : ' + i, IsActive = true));
		}
		insert products;

		List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
		for(Product2 product : products)
		{
			pricebookEntries.add(
				new PricebookEntry(
					Product2Id = product.Id,
					UnitPrice = 10,
					IsActive = true,
					UseStandardPrice = false,
					Pricebook2Id = Test.getStandardPricebookId()
				)
			);
		}
		insert pricebookEntries;

		List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
		for(PricebookEntry pbe : pricebookEntries)
		{
			oppLineItems.add(
				new OpportunityLineItem(
					OpportunityId = opp.Id,
					PricebookEntryId = pbe.Id,
					Quantity = 1,
					TotalPrice = 10
				)
			);
		}
		insert oppLineItems;

		System.runAs(TestDataFactory.getRunAsUser())
		{
			// When discounts are applied for the opportunity
			Test.startTest();
			OpportunitiesService.newInstance().applyDiscounts(
				new Map<Id, Decimal>{ opp.Id => 10 }
			);
			Test.stopTest();
		}

		// Then the opportunity amount reflects the discount
		System.assertEquals(90, [SELECT Amount FROM Opportunity WHERE Id = :opp.Id].Amount);
	}
}
