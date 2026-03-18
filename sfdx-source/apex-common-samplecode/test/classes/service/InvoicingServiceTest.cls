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

@IsTest
private class InvoicingServiceTest
{
	@TestSetup
	static void setup()
	{
		TestDataFactory.createUserWithSampleAppPermissions();
	}

	@IsTest
	private static void generateReturnsInvoiceIds()
	{
		// Given
		fflib_ISObjectUnitOfWork uow = UnitOfWork.newInstance();
		Opportunity opp = new Opportunity();
		opp.Name = 'Opportunity';
		opp.StageName = 'Open';
		opp.CloseDate = System.today();
		uow.registerNew(opp);
		for (Integer i = 0; i < 5; i++)
		{
			Product2 product = new Product2();
			product.Name = opp.Name + ' : Product : ' + i;
			uow.registerNew(product);
			PricebookEntry pbe = new PricebookEntry();
			pbe.UnitPrice = 10;
			pbe.IsActive = true;
			pbe.UseStandardPrice = false;
			pbe.Pricebook2Id = Test.getStandardPricebookId();
			uow.registerNew(pbe, PricebookEntry.Product2Id, product);
			OpportunityLineItem oppLineItem = new OpportunityLineItem();
			oppLineItem.Quantity = 1;
			oppLineItem.TotalPrice = 10;
			uow.registerRelationship(oppLineItem, OpportunityLineItem.PricebookEntryId, pbe);
			uow.registerNew(oppLineItem, OpportunityLineItem.OpportunityId, opp);
		}
		uow.commitWork();

		// When
		System.runAs(TestDataFactory.getRunAsUser())
		{
			List<Id> invoiceIds = InvoicingService.newInstance().generate(new List<Id> { opp.Id });

			// Then
			System.assertEquals(1, invoiceIds.size(), 'Should generate one invoice');
		}
	}

	@IsTest
	private static void generateFromDeveloperWorkItemReturnsInvoiceId()
	{
		// Given: Account, WorkOrder with Account, DeveloperWorkItem with cost
		// Run entire flow as permission-set user (UnitOfWork uses UserModeDML)
		List<Id> invoiceIds;
		Id accId;
		System.runAs(TestDataFactory.getRunAsUser())
		{
			fflib_ISObjectUnitOfWork uow = UnitOfWork.newInstance();
			Account acc = new Account(Name = 'Client');
			uow.registerNew(acc);
			WorkOrder__c wo = new WorkOrder__c();
			uow.registerNew(wo);
			uow.registerRelationship(wo, WorkOrder__c.Account__c, acc);
			DeveloperWorkItem__c wi = new DeveloperWorkItem__c();
			wi.CodingHours__c = 10;
			wi.CodeReviewingHours__c = 2;
			wi.TechnicalDesignHours__c = 3;
			uow.registerNew(wi, DeveloperWorkItem__c.WorkOrder__c, wo);
			uow.commitWork();
			accId = acc.Id;

			// When
			invoiceIds = InvoicingService.newInstance().generate(new List<Id> { wi.Id });
		}

		// Then
		System.assertEquals(1, invoiceIds.size(), 'Should generate one invoice from DeveloperWorkItem');
		Invoice__c inv = [SELECT Account__c, Description__c FROM Invoice__c WHERE Id = :invoiceIds[0]];
		System.assertEquals(accId, inv.Account__c, 'Invoice should be for work order account');
		System.assert(inv.Description__c != null && inv.Description__c.contains('Developer'), 'Description should mention developer work');
	}

	@IsTest
	private static void generateFromTrainingWorkItemReturnsInvoiceId()
	{
		// Given: Account, WorkOrder with Account, TrainingWorkItem with cost
		// Run entire flow as permission-set user (UnitOfWork uses UserModeDML)
		List<Id> invoiceIds;
		Id accId;
		System.runAs(TestDataFactory.getRunAsUser())
		{
			fflib_ISObjectUnitOfWork uow = UnitOfWork.newInstance();
			Account acc = new Account(Name = 'Client');
			uow.registerNew(acc);
			WorkOrder__c wo = new WorkOrder__c();
			uow.registerNew(wo);
			uow.registerRelationship(wo, WorkOrder__c.Account__c, acc);
			TrainingWorkItem__c wi = new TrainingWorkItem__c();
			wi.DeliveryHours__c = 8;
			wi.PreparationHours__c = 2;
			uow.registerNew(wi, TrainingWorkItem__c.WorkOrder__c, wo);
			uow.commitWork();
			accId = acc.Id;

			// When
			invoiceIds = InvoicingService.newInstance().generate(new List<Id> { wi.Id });
		}

		// Then
		System.assertEquals(1, invoiceIds.size(), 'Should generate one invoice from TrainingWorkItem');
		Invoice__c inv = [SELECT Account__c, Description__c FROM Invoice__c WHERE Id = :invoiceIds[0]];
		System.assertEquals(accId, inv.Account__c, 'Invoice should be for work order account');
		System.assert(inv.Description__c != null && inv.Description__c.contains('Training'), 'Description should mention training');
	}

	@IsTest
	private static void generateWithUnsupportedSourceTypeThrows()
	{
		// Given: Account is not an invoice target
		Account acc = new Account(Name = 'Test');
		insert acc;

		// When / Then
		System.runAs(TestDataFactory.getRunAsUser())
		{
			try
			{
				InvoicingService.newInstance().generate(new List<Id> { acc.Id });
				System.assert(false, 'Expected exception for unsupported source type');
			}
			catch (Exception e)
			{
				System.assert(true, 'Exception thrown as expected: ' + e.getTypeName());
			}
		}
	}
}
