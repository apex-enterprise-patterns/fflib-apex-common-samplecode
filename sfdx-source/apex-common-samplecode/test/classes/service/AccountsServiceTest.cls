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
 * Unit tests for AccountsService using fflib-apex-mocks. No DML.
 */
@IsTest
private class AccountsServiceTest
{
	@TestSetup
	static void setup()
	{
		TestDataFactory.createUserWithSampleAppPermissions();
	}

	@IsTest
	static void itShouldUpdateOpportunityActivity()
	{
		System.runAs(TestDataFactory.getRunAsUser())
		{
			List<Account> accounts = new List<Account>
			{
				new Account(Name = 'A', Id = TestIdGenerator.generate(Schema.Account.SObjectType)),
				new Account(Name = 'B', Id = TestIdGenerator.generate(Schema.Account.SObjectType)),
				new Account(Name = 'C', Id = TestIdGenerator.generate(Schema.Account.SObjectType))
			};
			Set<Id> accountIds = new Map<Id, SObject>(accounts).keySet();

			fflib_ApexMocks mocks = new fflib_ApexMocks();
			fflib_SObjectUnitOfWork unitOfWorkMock = (fflib_SObjectUnitOfWork) mocks.mock(fflib_SObjectUnitOfWork.class);
			AccountsSelector selectorMock = (AccountsSelector) mocks.mock(AccountsSelector.class);

			mocks.startStubbing();
			mocks.when(selectorMock.selectById(accountIds)).thenReturn(accounts);
			mocks.stopStubbing();

			UnitOfWork.mock = unitOfWorkMock;
			AccountsSelector.mock = selectorMock;

			Test.startTest();
			AccountsService.newInstance().updateOpportunityActivity(accountIds);
			Test.stopTest();

			((AccountsSelector) mocks.verify(selectorMock)).selectById(accountIds);
			((fflib_SObjectUnitOfWork) mocks.verify(unitOfWorkMock)).registerDirty(accounts);
			((fflib_SObjectUnitOfWork) mocks.verify(unitOfWorkMock)).commitWork();
		}
	}
}
