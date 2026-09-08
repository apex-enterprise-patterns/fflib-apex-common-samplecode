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
 * Selector for Invoice__c queries used by invocable and UI entry points.
 */
public virtual inherited sharing class InvoicesSelector extends fflib_SObjectSelector
{
	/**
	 * Factory that returns this selector.
	 * @return {@link InvoicesSelector} instance.
	 */
	public static InvoicesSelector newInstance()
	{
		return new InvoicesSelector();
	}

	/**
	 * Creates a selector that queries in user mode.
	 */
	public InvoicesSelector()
	{
		super(false, fflib_SObjectSelector.DataAccess.USER_MODE);
	}

	/**
	 * Fields included in default queries from this selector.
	 * @return Invoice__c Id and Name.
	 */
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>{
			Invoice__c.Id,
			Invoice__c.Name
		};
	}

	/**
	 * SObject type this selector queries.
	 * @return {@code Invoice__c.SObjectType}.
	 */
	public Schema.SObjectType getSObjectType()
	{
		return Invoice__c.SObjectType;
	}

	/**
	 * Selects Invoice__c records by Id with Id and Name.
	 * @param idSet Invoice Ids to query. Empty set returns an empty list.
	 * @return Matching invoices; empty list when none match.
	 */
	public List<Invoice__c> selectById(Set<Id> idSet)
	{
		return (List<Invoice__c>) selectSObjectsById(idSet);
	}
}
