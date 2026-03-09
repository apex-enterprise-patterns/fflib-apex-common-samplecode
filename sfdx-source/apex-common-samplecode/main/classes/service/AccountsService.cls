/**
 * Copyright (c) 2012-2014, FinancialForce.com, inc
 * All rights reserved.
 */
public with sharing class AccountsService
{
	@TestVisible
	private static AccountsService mock;
	public static AccountsService newInstance()
	{
		if (mock != null) { return mock; }
		return new AccountsService();
	}

	/**
	 * Update last Opportunity activity on the related Accounts
	 */
	public void updateOpportunityActivity(Set<Id> accountIds)
	{
		fflib_ISObjectUnitOfWork uow = UnitOfWork.newInstance();
		List<Account> accounts = AccountsSelector.newInstance().selectById(accountIds);
		Accounts accountsDomain = new Accounts(accounts);
		accountsDomain.updateOpportunityActivity();
		uow.registerDirty(accountsDomain.getRecords());
		uow.commitWork();
	}
}
