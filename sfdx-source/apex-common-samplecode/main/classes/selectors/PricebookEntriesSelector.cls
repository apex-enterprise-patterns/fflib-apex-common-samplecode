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
 * Selector for PricebookEntry queries.
 */
public virtual inherited sharing class PricebookEntriesSelector extends fflib_SObjectSelector
{
	/**
	 * Factory that returns this selector.
	 * @return {@link PricebookEntriesSelector} instance.
	 */
	public static PricebookEntriesSelector newInstance()
	{
		return new PricebookEntriesSelector();
	}

	/**
	 * Creates a selector that queries in user mode.
	 */
	public PricebookEntriesSelector()
	{
		super(false, fflib_SObjectSelector.DataAccess.USER_MODE);
	}

	/**
	 * Fields included in default queries from this selector.
	 * @return PricebookEntry Id, IsActive, Name, Pricebook2Id, Product2Id, ProductCode, UnitPrice, and UseStandardPrice.
	 */
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>{
			PricebookEntry.Id,
			PricebookEntry.IsActive,
			PricebookEntry.Name,
			PricebookEntry.Pricebook2Id,
			PricebookEntry.Product2Id,
			PricebookEntry.ProductCode,
			PricebookEntry.UnitPrice,
			PricebookEntry.UseStandardPrice
		};
	}

	/**
	 * SObject type this selector queries.
	 * @return {@code PricebookEntry.SObjectType}.
	 */
	public Schema.SObjectType getSObjectType()
	{
		return PricebookEntry.SObjectType;
	}

	/**
	 * Selects PricebookEntries by Id with standard pricing fields.
	 * @param idSet PricebookEntry Ids to query. Empty set returns an empty list.
	 * @return Matching PricebookEntry records; empty list when none match.
	 */
	public List<PricebookEntry> selectById(Set<Id> idSet)
	{
		return (List<PricebookEntry>) selectSObjectsById(idSet);
	}
}
