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

@IsTest
private class OpportunitiesServiceTestIntegration 
{
	@IsTest
	private static void testServiceClass() 
	{
		// Create Opportunity, Lines, Pricebooks and Products
		List<Opportunity> opps = new List<Opportunity>();
		List<List<Product2>> productsByOpp = new List<List<Product2>>(); 		
		List<List<PricebookEntry>> pricebookEntriesByOpp = new List<List<PricebookEntry>>(); 		
		List<List<OpportunityLineItem>> oppLinesByOpp = new List<List<OpportunityLineItem>>(); 		
		Opportunity opp = new Opportunity();
		opp.Name = 'Test';
		opp.StageName = 'Open';
		opp.CloseDate = System.today();
		opps.add(opp);
		List<Product2> products = new List<Product2>();
		List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
		List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
		for(Integer i=0; i<10; i++) {						
			Product2 product = new Product2();
			product.Name = opp.Name + ' : Product : ' + i;
			products.add(product);
			PricebookEntry pbe = new PricebookEntry();
			pbe.UnitPrice = 10;
			pbe.IsActive = true;
			pbe.UseStandardPrice = false;
			pbe.Pricebook2Id = Test.getStandardPricebookId();
			pricebookEntries.add(pbe);
			OpportunityLineItem oppLineItem = new OpportunityLineItem();
			oppLineItem.Quantity = 1;
			oppLineItem.TotalPrice = 10;
			oppLineItems.add(oppLineItem);
		}
		productsByOpp.add(products);
		pricebookEntriesByOpp.add(pricebookEntries);
		oppLinesByOpp.add(oppLineItems);				
		// Insert Opportunities
		insert opps;
		// Insert Products
		List<Product2> allProducts = new List<Product2>(); 
		for(List<Product2> oppProducts : productsByOpp)
			allProducts.addAll(oppProducts);			
		insert allProducts;
		// Insert Pricebooks
		Integer oppIdx = 0;			
		List<PricebookEntry> allPricebookEntries = new List<PricebookEntry>();				
		for(List<PricebookEntry> oppPricebookEntries : pricebookEntriesByOpp) {
			List<Product2> pbproducts = productsByOpp[oppIdx++];
			Integer lineIdx = 0;
			for(PricebookEntry pricebookEntry : oppPricebookEntries)
				pricebookEntry.Product2Id = pbproducts[lineIdx++].Id;
			allPricebookEntries.addAll(oppPricebookEntries);
		}			
		insert allPricebookEntries;
		// Insert Opportunity Lines
		oppIdx = 0;						
		List<OpportunityLineItem> allOppLineItems = new List<OpportunityLineItem>(); 			
		for(List<OpportunityLineItem> oppLines : oppLinesByOpp) {
			List<PricebookEntry> oppPricebookEntries = pricebookEntriesByOpp[oppIdx];
			Integer lineIdx = 0;
			for(OpportunityLineItem oppLine : oppLines) {
				oppLine.OpportunityId = opps[oppIdx].Id;
				oppLine.PricebookEntryId = oppPricebookEntries[lineIdx++].Id;
			}
			allOppLineItems.addAll(oppLines);
			oppIdx++;
		}			
		insert allOppLineItems;

		// Test
		Test.startTest();
		OpportunitiesService.applyDiscounts(new Set<Id> { opp.Id }, 10);
		Test.stopTest();

		// Assert
		System.assertEquals(90, [select Amount from Opportunity limit 1][0].Amount);
	}	
}