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
}