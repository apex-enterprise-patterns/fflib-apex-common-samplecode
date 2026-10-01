/**
 * Copyright (c) 2013-2016, FinancialForce.com, inc
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
 * Selector for Account queries used by account and opportunity activity flows.
 */
public virtual inherited sharing class AccountsSelector extends fflib_SObjectSelector
{
	/**
	 * Factory that returns this selector.
	 * @return {@link AccountsSelector} instance.
	 */
	public static AccountsSelector newInstance()
	{
		return new AccountsSelector();
	}

	/**
	 * Creates a selector that queries in user mode.
	 */
	public AccountsSelector()
	{
		super(false, fflib_SObjectSelector.DataAccess.USER_MODE);
	}

	/**
	 * Fields included in default queries from this selector.
	 * @return Account Id, Name, and Description.
	 */
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>{
			Account.Id,
			Account.Name,
			Account.Description
		};
	}

	/**
	 * SObject type this selector queries.
	 * @return {@code Account.SObjectType}.
	 */
	public Schema.SObjectType getSObjectType()
	{
		return Account.SObjectType;
	}

	/**
	 * Selects Accounts by Id with Id, Name, and Description.
	 * @param idSet Account Ids to query. Empty set returns an empty list.
	 * @return Matching Accounts; empty list when none match.
	 */
	public List<Account> selectById(Set<Id> idSet)
	{
		return (List<Account>) selectSObjectsById(idSet);
	}

	/**
	 * Selects Accounts related to the given Opportunities via AccountId.
	 * @param opportunities Opportunities whose AccountId values are collected. Cannot be null.
	 * @return Matching Accounts; empty list when no AccountIds are present.
	 */
	public List<Account> selectByOpportunity(List<Opportunity> opportunities)
	{
		Set<Id> accountIds = new Set<Id>();
		for(Opportunity opp : opportunities)
		{
			if(opp.AccountId!=null)
			{
				accountIds.add(opp.AccountId);
			}
		}
		return selectById(accountIds);
	}
}
