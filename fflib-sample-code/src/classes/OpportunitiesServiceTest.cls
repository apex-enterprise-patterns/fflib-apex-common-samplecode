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
private class OpportunitiesServiceTest 
{
	@IsTest
	private static void callingServiceShouldCallSelectorApplyDiscountInDomainAndCommit()
	{
		// Create mocks
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
		IOpportunities domainMock = new Mocks.Opportunities(mocks);
		IOpportunitiesSelector selectorMock = new Mocks.OpportunitiesSelector(mocks);

		// Given
		mocks.startStubbing();
		List<Opportunity> testOppsList = new List<Opportunity> { 
			new Opportunity(
				Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
				Name = 'Test Opportunity',
				StageName = 'Open',
				Amount = 1000,
				CloseDate = System.today()) };
		Set<Id> testOppsSet = new Map<Id, Opportunity>(testOppsList).keySet();
		mocks.when(domainMock.sObjectType()).thenReturn(Opportunity.SObjectType);
		mocks.when(selectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
		mocks.when(selectorMock.selectByIdWithProducts(testOppsSet)).thenReturn(testOppsList);
		mocks.stopStubbing();
		Decimal discountPercent = 10;
		Application.UnitOfWork.setMock(uowMock);
		Application.Domain.setMock(domainMock);
		Application.Selector.setMock(selectorMock);

		// When
		OpportunitiesService.applyDiscounts(testOppsSet, discountPercent);

		// Then
		((IOpportunitiesSelector) 
			mocks.verify(selectorMock)).selectByIdWithProducts(testOppsSet);
		((IOpportunities) 
			mocks.verify(domainMock)).applyDiscount(discountPercent, uowMock);
		((fflib_ISObjectUnitOfWork) 
			mocks.verify(uowMock, 1)).commitWork();
	}
}