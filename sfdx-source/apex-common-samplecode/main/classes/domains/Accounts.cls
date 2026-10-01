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
 * Domain logic for Account records, including opportunity activity description updates.
 */
public virtual inherited sharing class Accounts extends fflib_SObjects
{
	@TestVisible
	private static Accounts mock;

	/**
	 * Factory that wraps the given Account records, or {@link #mock} when tests have set one.
	 * @param recordList Accounts to manage. Null is treated as an empty list.
	 * @return {@link Accounts} instance.
	 */
	public static Accounts newInstance(List<Account> recordList)
	{
		return mock!=null ? mock : new Accounts(recordList);
	}

	/**
	 * Prefix written to Account.Description when opportunity activity is recorded.
	 */
	public static final String OPPORTUNITY_RAISED_DESCRIPTION = 'Last Opportunity Raised';

	/**
	 * Creates a domain wrapping the given Account records.
	 * @param sObjectList Accounts to manage. Null is treated as an empty list.
	 */
	public Accounts(List<Account> sObjectList)
	{
		super(sObjectList==null ? new List<Account>() : sObjectList);
	}

	/**
	 * Returns the Account records held by this domain.
	 * @return The in-memory Account list; never null. Same as {@link #getRecords()}.
	 */
	public List<Account> getAccounts()
	{
		return (List<Account>) getRecords();
	}

	/**
	 * Sets Description on every Account in the domain.
	 * @param description Value to assign to Account.Description.
	 */
	public void setDescription(String description)
	{
		for(Account account : (List<Account>) getRecords())
		{
			account.Description = description;
		}
	}

	/**
	 * Updates Description to record that an opportunity was raised today.
	 * Uses {@link #OPPORTUNITY_RAISED_DESCRIPTION} plus {@code System.today()}.
	 */
	public void updateOpportunityActivity()
	{
		setDescription(OPPORTUNITY_RAISED_DESCRIPTION + ' ' + System.today());
	}
}
