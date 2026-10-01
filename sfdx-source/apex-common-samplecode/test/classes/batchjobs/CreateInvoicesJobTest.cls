/**
 * Copyright (c) 2013, FinancialForce.com, inc
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
 * Unit tests for {@link CreateInvoicesJob} using fflib-apex-mocks.
 */
@IsTest
private class CreateInvoicesJobTest
{
	@IsTest
	private static void startCallsSelector()
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		OpportunitiesService mockService = (OpportunitiesService) mocks.mock(OpportunitiesService.class);
		OpportunitiesSelector selectorMock = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);
		Database.QueryLocator locator = Database.getQueryLocator(
			[SELECT Id FROM Opportunity WHERE Id = null]
		);
		mocks.startStubbing();
		mocks.when(selectorMock.readyToInvoiceAsQueryLocator()).thenReturn(locator);
		mocks.stopStubbing();

		new CreateInvoicesJob(mockService, selectorMock).start(null);

		((OpportunitiesSelector) mocks.verify(selectorMock)).readyToInvoiceAsQueryLocator();
	}

	@IsTest
	private static void executeCallsService()
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		OpportunitiesService mockService = (OpportunitiesService) mocks.mock(OpportunitiesService.class);
		OpportunitiesSelector selectorMock = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);
		Id opportunityId = TestIdGenerator.generate(Opportunity.SObjectType);
		Opportunity opp = new Opportunity(Id = opportunityId, Name = 'Ready');

		new CreateInvoicesJob(mockService, selectorMock).execute(null, new List<Opportunity>{ opp });

		((OpportunitiesService) mocks.verify(mockService)).applyDiscountsAndCreateInvoices(
			new Map<Id, Decimal>{ opportunityId => 0 }
		);
	}
}
