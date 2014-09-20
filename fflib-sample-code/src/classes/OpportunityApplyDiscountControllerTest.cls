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
private class OpportunityApplyDiscountControllerTest 
{
	@IsTest
	private static void callingApplyDiscountOnControllerShouldCallService()
	{
		fflib_ApexMocks mocks = new fflib_ApexMocks();

		// Given
		Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
		Opportunity opp = new Opportunity(Id = opportunityId, Amount = 100, Name = 'Test');
		ApexPages.StandardController standardController = new ApexPages.StandardController(opp);
		Mocks.OpportunitiesService mockService = new Mocks.OpportunitiesService(mocks);
		Application.Service.setMock(IOpportunitiesService.class, mockService);

		// When
		OpportunityApplyDiscountController controller = new OpportunityApplyDiscountController(standardController);
		controller.DiscountPercentage = 10;
		controller.applyDiscount();

		// Then
		((IOpportunitiesService) 
			mocks.verify(mockService, 1)).applyDiscounts(new Set<Id> { opportunityId }, 10);
	}
}