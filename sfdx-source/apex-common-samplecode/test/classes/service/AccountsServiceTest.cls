/**
 * Copyright (c) 2012-2014, FinancialForce.com, inc
 * All rights reserved.
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
	static void updateActivitySelectsAndCommits()
	{
		System.runAs(TestDataFactory.getRunAsUser())
		{
			// Given
			List<Account> accounts = new List<Account> {
				new Account(Name = 'A', Id = fflib_IDGenerator.generate(Schema.Account.SObjectType)),
				new Account(Name = 'B', Id = fflib_IDGenerator.generate(Schema.Account.SObjectType)),
				new Account(Name = 'C', Id = fflib_IDGenerator.generate(Schema.Account.SObjectType))
			};
			Set<Id> accountIds = new Map<Id, SObject>(accounts).keySet();
			fflib_ApexMocks mocks = new fflib_ApexMocks();
			fflib_ISObjectUnitOfWork unitOfWorkMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
			AccountsSelector selectorMock = (AccountsSelector) mocks.mock(AccountsSelector.class);
			mocks.startStubbing();
			mocks.when(selectorMock.selectById(accountIds)).thenReturn(accounts);
			mocks.stopStubbing();
			UnitOfWork.mock = unitOfWorkMock;
			AccountsSelector.mock = selectorMock;

			// When
			Test.startTest();
			AccountsService.newInstance().updateOpportunityActivity(accountIds);
			Test.stopTest();

			// Then
			((AccountsSelector) mocks.verify(selectorMock)).selectById(accountIds);
			((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock)).registerDirty(accounts);
			((fflib_ISObjectUnitOfWork) mocks.verify(unitOfWorkMock)).commitWork();
			System.assert(true, 'Service updateOpportunityActivity was called correctly');
		}
	}
}
