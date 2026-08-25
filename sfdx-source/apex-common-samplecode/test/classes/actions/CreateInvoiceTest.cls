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
 * Unit tests for {@link CreateInvoice} using fflib-apex-mocks.
 */
@IsTest
private class CreateInvoiceTest {
	@IsTest
	private static void executeCallsServiceAndReturnsInvoiceId() {
		// Given a mocked opportunities service that returns an invoice id
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		OpportunitiesService mockService = (OpportunitiesService) mocks.mock(OpportunitiesService.class);
		Id opportunityId = TestIdGenerator.generate(Opportunity.SObjectType);
		Id invoiceId = TestIdGenerator.generate(Invoice__c.SObjectType);
		Set<Id> invoiceIds = new Set<Id>{ invoiceId };
		mocks.startStubbing();
		mocks.when(mockService.createInvoices(new Set<Id>{ opportunityId }, 10)).thenReturn(invoiceIds);
		mocks.stopStubbing();
		OpportunitiesService.mock = mockService;
		CreateInvoice.testInvoiceName = 'INV-00000001';
		CreateInvoice.Request request = new CreateInvoice.Request();
		request.opportunityId = opportunityId;
		request.discountPercentage = 10;

		// When the invocable action is executed
		List<CreateInvoice.Result> results = CreateInvoice.execute(
			new List<CreateInvoice.Request>{ request }
		);

		// Then the service is called and the invoice id is returned
		((OpportunitiesService) mocks.verify(mockService)).createInvoices(
			new Set<Id>{ opportunityId },
			10
		);
		System.assertEquals(1, results.size(), 'One result should be returned');
		System.assertEquals(invoiceId, results[0].invoiceId, 'Created invoice Id should be returned');
		System.assertEquals('INV-00000001', results[0].invoiceName, 'Created invoice Name should be returned');
	}
}
