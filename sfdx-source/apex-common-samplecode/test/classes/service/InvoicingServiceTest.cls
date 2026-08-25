/**
 * Copyright (c) 2014, FinancialForce.com, inc
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
 * Integration tests for InvoicingService.generate.
 */
@IsTest
private class InvoicingServiceTest
{
	@TestSetup
	static void setup()
	{
		// Given a run-as user with sample app permissions
		TestDataFactory.createUserWithSampleAppPermissions();
	}

	@IsTest
	private static void generateReturnsInvoiceIds()
	{
		// Given an opportunity with products and line items
		Opportunity opp = new Opportunity(
			Name = 'Opportunity',
			StageName = 'Open',
			CloseDate = System.today(),
			Pricebook2Id = Test.getStandardPricebookId()
		);
		insert opp;

		List<Product2> products = new List<Product2>();
		for(Integer i = 0; i < 5; i++)
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

		List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>();
		for(PricebookEntry pbe : pricebookEntries)
		{
			lineItems.add(
				new OpportunityLineItem(
					OpportunityId = opp.Id,
					PricebookEntryId = pbe.Id,
					Quantity = 1,
					TotalPrice = 10
				)
			);
		}
		insert lineItems;

		System.runAs(TestDataFactory.getRunAsUser())
		{
			// When invoices are generated for the opportunity
			Test.startTest();
			List<Id> invoiceIds = InvoicingService.newInstance().generate(new List<Id>{ opp.Id });
			Test.stopTest();

			// Then one invoice id is returned
			System.assertEquals(1, invoiceIds.size(), 'Should generate one invoice');
		}
	}

	@IsTest
	private static void generateFromDeveloperWorkItemReturnsInvoiceId()
	{
		System.runAs(TestDataFactory.getRunAsUser())
		{
			// Given a developer work item under a work order and account
			Account acc = new Account(Name = 'Client');
			insert acc;
			WorkOrder__c wo = new WorkOrder__c(Account__c = acc.Id);
			insert wo;
			DeveloperWorkItem__c wi = new DeveloperWorkItem__c(
				WorkOrder__c = wo.Id,
				CodingHours__c = 10,
				CodeReviewingHours__c = 2,
				TechnicalDesignHours__c = 3
			);
			insert wi;

			// When invoices are generated from the work item
			Test.startTest();
			List<Id> invoiceIds = InvoicingService.newInstance().generate(new List<Id>{ wi.Id });
			Test.stopTest();

			// Then one invoice is created for the work order account
			System.assertEquals(1, invoiceIds.size(), 'Should generate one invoice from DeveloperWorkItem');
			Invoice__c inv = [SELECT Account__c, Description__c FROM Invoice__c WHERE Id = :invoiceIds[0]];
			System.assertEquals(acc.Id, inv.Account__c, 'Invoice should be for work order account');
			System.assert(
				inv.Description__c!=null && inv.Description__c.contains('Developer'),
				'Description should mention developer work'
			);
		}
	}

	@IsTest
	private static void generateFromTrainingWorkItemReturnsInvoiceId()
	{
		System.runAs(TestDataFactory.getRunAsUser())
		{
			// Given a training work item under a work order and account
			Account acc = new Account(Name = 'Client');
			insert acc;
			WorkOrder__c wo = new WorkOrder__c(Account__c = acc.Id);
			insert wo;
			TrainingWorkItem__c wi = new TrainingWorkItem__c(
				WorkOrder__c = wo.Id,
				DeliveryHours__c = 8,
				PreparationHours__c = 2
			);
			insert wi;

			// When invoices are generated from the work item
			Test.startTest();
			List<Id> invoiceIds = InvoicingService.newInstance().generate(new List<Id>{ wi.Id });
			Test.stopTest();

			// Then one invoice is created for the work order account
			System.assertEquals(1, invoiceIds.size(), 'Should generate one invoice from TrainingWorkItem');
			Invoice__c inv = [SELECT Account__c, Description__c FROM Invoice__c WHERE Id = :invoiceIds[0]];
			System.assertEquals(acc.Id, inv.Account__c, 'Invoice should be for work order account');
			System.assert(
				inv.Description__c!=null && inv.Description__c.contains('Training'),
				'Description should mention training'
			);
		}
	}

	@IsTest
	private static void generateWithUnsupportedSourceTypeThrows()
	{
		// Given an account id that is not a supported invoicing source
		Account acc = new Account(Name = 'Test');
		insert acc;

		System.runAs(TestDataFactory.getRunAsUser())
		{
			// When invoice generation is attempted for that account
			Test.startTest();
			Boolean threw = false;
			try
			{
				InvoicingService.newInstance().generate(new List<Id>{ acc.Id });
			}
			catch (Exception e)
			{
				threw = true;
				// Then an exception is raised for the unsupported source type
				System.assert(true, 'Exception thrown as expected: ' + e.getTypeName());
			}
			Test.stopTest();
			System.assert(threw, 'Expected exception for unsupported source type');
		}
	}
}
