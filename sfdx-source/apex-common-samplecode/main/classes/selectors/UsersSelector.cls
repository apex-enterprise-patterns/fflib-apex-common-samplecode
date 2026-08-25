/**
 * Copyright (c) 2013-2015, FinancialForce.com, inc
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
 * Selector for User email addresses used by job notification flows.
 */
public virtual inherited sharing class UsersSelector extends fflib_SObjectSelector
{
	@TestVisible
	private static UsersSelector mock;

	/**
	 * Factory that returns this selector, or {@link #mock} when tests have set one.
	 * @return {@link UsersSelector} instance.
	 */
	public static UsersSelector newInstance()
	{
		return mock!=null ? mock : new UsersSelector();
	}

	/**
	 * Creates a selector that queries in user mode.
	 */
	public UsersSelector()
	{
		super(false, fflib_SObjectSelector.DataAccess.USER_MODE);
	}

	/**
	 * Fields included in default queries from this selector.
	 * @return User Id and Email.
	 */
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>{ User.Id, User.Email };
	}

	/**
	 * SObject type this selector queries.
	 * @return {@code User.SObjectType}.
	 */
	public Schema.SObjectType getSObjectType()
	{
		return User.SObjectType;
	}

	/**
	 * Maps User Ids to their Email addresses.
	 * @param userIds User Ids to query. Empty set returns an empty map.
	 * @return Map of User Id to Email; users without a matching row are omitted.
	 */
	public Map<Id, String> getUsersEmail(Set<Id> userIds)
	{
		Map<Id, String> emailsById = new Map<Id, String>();
		for(User u : (List<User>) selectSObjectsById(userIds))
		{
			emailsById.put(u.Id, u.Email);
		}
		return emailsById;
	}
}
