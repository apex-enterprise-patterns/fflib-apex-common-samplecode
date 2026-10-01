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
 * Service for Account-related operations invoked from the service layer.
 *
 * Prefer {@link #newInstance} for the default selector.
 * Use the constructor when tests inject a selector mock.
 * Each method that persists creates a fresh {@link UnitOfWork#newInstance}.
 */
public inherited sharing class AccountsService
{
	private final AccountsSelector selector;

	/**
	 * Default composition: {@link AccountsSelector#newInstance}.
	 * @return {@link AccountsService} instance.
	 */
	public static AccountsService newInstance()
	{
		return new AccountsService(AccountsSelector.newInstance());
	}

	/**
	 * Creates a service with the given selector.
	 * @param selector Account selector used to load records. Cannot be null.
	 */
	public AccountsService(AccountsSelector selector)
	{
		this.selector = selector;
	}

	/**
	 * Updates last Opportunity activity on the related Accounts.
	 * @param accountIds Account Ids to update. Empty set is a no-op.
	 */
	public void updateOpportunityActivity(Set<Id> accountIds)
	{
		if(accountIds.isEmpty())
		{
			return;
		}

		fflib_SObjectUnitOfWork uow = UnitOfWork.newInstance();
		List<Account> accountRecords = selector.selectById(accountIds);
		Accounts accountsDomain = Accounts.newInstance(accountRecords);
		accountsDomain.updateOpportunityActivity();
		uow.registerDirty(accountsDomain.getRecords());
		uow.commitWork();
	}
}
