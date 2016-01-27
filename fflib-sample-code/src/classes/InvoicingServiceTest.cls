/**
 * Copyright (c), FinancialForce.com, inc
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
	@IsTest
	private static void testService()
	{
		// Create Test Data
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		Opportunity opp = new Opportunity();
		opp.Name = 'Opportunity';
		opp.StageName = 'Open';
		opp.CloseDate = System.today();
		uow.registerNew(opp);		
		for(Integer i=0; i<5; i++)
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

		// Call Service
		List<Id> invoiceIds = InvoicingService.generate(new List<Id> { opp.Id });

		// Assert Invoices
		System.assertEquals(1, invoiceIds.size());
	}

	@IsTest
	private static void testService_UsingBuildersWithDML()
	{
		// Create Test Data
		// BuilderNote: We do not have to call register here because the Opportunity will be automatically
		//              persisted because the Opportunity Line contains a reference to it.  Alternately, we
		//              could call register on the Opportunity itself but its not necessary in this case.
		Opportunity_t opp = Opportunity_t.anOpenOpportunity()
											.withName('Opportunity');

		Integer numLines = 5;
		for (Integer i = 0; i < numLines; i++) {
			// BuilderNote: We call register on each Opportunity Line Item so that it is added to the list of 
			//				builders that will be persisted to DB.  Note that we have to call register
			//				on each individual Opportunity Line Item because there are no other builders that 
			//              reference it.  However, we do not need to call register on the PriceBookEntry,
			//              Product or Opportunity because the Opportunity Line Item is registered and anything
			//              it references will be automatically added to the unit of work.
			OpportunityLineItem_t oli = OpportunityLineItem_t.anOpportunityLineItem()
																.withQuantity(1)
																.withTotalPrice(1)
																.withPriceBookEntry(
																	PriceBookEntry_t.aPriceBookEntryWithStandardPriceBook()
																						.withUseStandardPrice(false)
																						.withIsActive(true)
																						.withUnitPrice(10)
																						.withProduct(
																							Product_t.aProduct()
																										.withName('Product ' + i)))
																.withOpportunity(opp)
																.register();
		}

		// persist the builders
		fflib_DomainObjectBuilder.persistRegistered(Application.UnitOfWork.newInstance());

		// Call Service
		List<Id> invoiceIds = InvoicingService.generate(new List<Id> { opp.Record.Id });

		// Assert Invoices
		System.assertEquals(1, invoiceIds.size());
		System.assertEquals(1, [SELECT COUNT() FROM Opportunity]);
		System.assertEquals(numLines, [SELECT COUNT() FROM OpportunityLineItem]);
		System.assertEquals(numLines, [SELECT COUNT() FROM PriceBookEntry]);
		System.assertEquals(numLines, [SELECT COUNT() FROM Product2]);
	}

	@IsTest
	private static void testService_UsingBuildersAddingChildToParentWithDML()
	{
		// Create Test Data
		// BuilderNote: We do not have to call register here because the Opportunity will be automatically
		//              persisted because the Opportunity Line contains a reference to it.  Alternately, we
		//              could call register on the Opportunity itself but its not necessary in this case.  
		Opportunity_t opp = Opportunity_t.anOpenOpportunity()
											.withName('Opportunity');

		Integer numLines = 5;
		for (Integer i = 0; i < numLines; i++) {
			// BuilderNote: We call register on each Opportunity Line Item so that it is added to the list of 
			//				builders that will be persisted to DB.  Note that we have to call register
			//				on each individual Opportunity Line Item because there are no other builders that 
			//              reference it.  However, we do not need to call register on the PriceBookEntry,
			//              Product or Opportunity because the Opportunity Line Item is registered and anything
			//              it references will be automatically added to the unit of work.
			opp.add(OpportunityLineItem_t.anOpportunityLineItem()
											.withQuantity(1)
											.withTotalPrice(1)
											.withPriceBookEntry(
												PriceBookEntry_t.aPriceBookEntryWithStandardPriceBook()
																	.withUseStandardPrice(false)
																	.withIsActive(true)
																	.withUnitPrice(10)
																	.withProduct(
																		Product_t.aProduct()
																					.withName('Product ' + i)))
											.register());
		}

		// persist the builders
		fflib_DomainObjectBuilder.persistRegistered(Application.UnitOfWork.newInstance());

		// Call Service
		List<Id> invoiceIds = InvoicingService.generate(new List<Id> { opp.Record.Id });

		// Assert Invoices
		System.assertEquals(1, invoiceIds.size());
		System.assertEquals(1, [SELECT COUNT() FROM Opportunity]);
		System.assertEquals(numLines, [SELECT COUNT() FROM OpportunityLineItem]);
		System.assertEquals(numLines, [SELECT COUNT() FROM PriceBookEntry]);
		System.assertEquals(numLines, [SELECT COUNT() FROM Product2]);		
	}	

	@IsTest
	private static void testService_UsingBuildersWithoutDML()
	{
		// Create Mocks
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
		IOpportunitiesSelector selectorMock = new Mocks.OpportunitiesSelector(mocks);
		IOpportunities domainMock = new Mocks.Opportunities(mocks);

		// Given
		// Create Test Data
		// BuilderNote: Use the 'build' method to generate an Existing in-memory opportunity
		Opportunity opp = Opportunity_t.anOpenOpportunity()
											.withName('Opportunity')
											.build();
		Set<Id> oppIds = new Set<Id> { opp.Id };
		// setup mocks
		mocks.startStubbing();
		mocks.when(selectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
		mocks.when(selectorMock.selectSObjectsById(oppIds)).thenReturn(new List<Opportunity> { opp });
		mocks.when(domainMock.sObjectType()).thenReturn(Opportunity.SObjectType);
		mocks.stopStubbing();
		Application.UnitOfWork.setMock(uowMock);
		Application.Selector.setMock(selectorMock);
		Application.Domain.setMock(domainMock);

		// When - Call Service
		List<Id> invoiceIds = InvoicingService.generate(new List<Id> { opp.Id });

		// Then
		((fflib_ISObjectUnitOfWork)
			mocks.verify(uowMock, 1)).commitWork();
		((IOpportunitiesSelector)
			mocks.verify(selectorMock, 1)).selectSObjectsById(oppIds);
		// There is a limitation currently with Apex Mocks where method arguments must EXACTLY match
		// in order to be verified.  For this reason, we create an Invoice Factory that represents
		// what was passed in to the Domain Layer within the service method call.  There is an upcoming
		// enhancement to Apex Mocks (see https://github.com/financialforcedev/fflib-apex-mocks/issues/8) 
		// that will simplify method verification and will avoid the need for creating the Factory here.  
		// See equals(Object) && hashCode() in InvoiceFactory class.
		InvoicingService.InvoiceFactory invoiceFactory = new InvoicingService.InvoiceFactory(uowMock);
		((InvoicingService.ISupportInvoicing)
			mocks.verify(domainMock, 1)).generate(invoiceFactory);
	}
}