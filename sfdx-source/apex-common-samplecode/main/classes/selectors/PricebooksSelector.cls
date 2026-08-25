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
 * Selector for Pricebook2 queries.
 */
public virtual inherited sharing class PricebooksSelector extends fflib_SObjectSelector
{
	@TestVisible
	private static PricebooksSelector mock;

	/**
	 * Factory that returns this selector, or {@link #mock} when tests have set one.
	 * @return {@link PricebooksSelector} instance.
	 */
	public static PricebooksSelector newInstance()
	{
		return mock!=null ? mock : new PricebooksSelector();
	}

	/**
	 * Creates a selector that queries in user mode.
	 */
	public PricebooksSelector()
	{
		super(false, fflib_SObjectSelector.DataAccess.USER_MODE);
	}

	/**
	 * Fields included in default queries from this selector.
	 * @return Pricebook2 Description, Id, IsActive, IsStandard, and Name.
	 */
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>{
			Pricebook2.Description,
			Pricebook2.Id,
			Pricebook2.IsActive,
			Pricebook2.IsStandard,
			Pricebook2.Name
		};
	}

	/**
	 * SObject type this selector queries.
	 * @return {@code Pricebook2.SObjectType}.
	 */
	public Schema.SObjectType getSObjectType()
	{
		return Pricebook2.SObjectType;
	}

	/**
	 * Selects Pricebooks by Id with Description, active, and standard flags.
	 * @param idSet Pricebook2 Ids to query. Empty set returns an empty list.
	 * @return Matching Pricebook2 records; empty list when none match.
	 */
	public List<Pricebook2> selectById(Set<Id> idSet)
	{
		return (List<Pricebook2>) selectSObjectsById(idSet);
	}
}
