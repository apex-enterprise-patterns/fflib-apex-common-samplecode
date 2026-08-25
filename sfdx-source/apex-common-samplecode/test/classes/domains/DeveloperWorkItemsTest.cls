/**
 * Copyright (c) 2016, FinancialForce.com, inc
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
 * Integration test for DeveloperWorkItems cost calculation.
 */
@IsTest
private class DeveloperWorkItemsTest
{
	@TestSetup
	static void setup()
	{
		// Given a run-as user with sample app permissions
		TestDataFactory.createUserWithSampleAppPermissions();
	}

	@IsTest
	static void insertWorkItemsCalculatesCost()
	{
		System.runAs(TestDataFactory.getRunAsUser())
		{
			// Given a work order and developer work item with hours
			WorkOrder__c wo = new WorkOrder__c();
			insert wo;
			DeveloperWorkItem__c wi = new DeveloperWorkItem__c(
				WorkOrder__c = wo.Id,
				CodingHours__c = 20,
				CodeReviewingHours__c = 1,
				TechnicalDesignHours__c = 10
			);

			// When the work item is inserted
			Test.startTest();
			insert wi;
			Test.stopTest();

			// Then the developer cost is calculated from hours worked
			System.assertEquals(
				3100,
				[SELECT DeveloperCost__c FROM DeveloperWorkItem__c WHERE Id = :wi.Id].DeveloperCost__c,
				'Developer cost should be 3100'
			);
		}
	}
}
