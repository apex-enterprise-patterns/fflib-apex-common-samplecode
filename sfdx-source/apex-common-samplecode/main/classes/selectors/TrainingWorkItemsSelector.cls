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
 * Selector for TrainingWorkItem__c including related Work Order account for invoicing.
 */
public virtual inherited sharing class TrainingWorkItemsSelector extends fflib_SObjectSelector {
	@TestVisible
	private static TrainingWorkItemsSelector mock;

	/**
	 * Factory that returns this selector, or {@link #mock} when tests have set one.
	 * @return {@link TrainingWorkItemsSelector} instance.
	 */
	public static TrainingWorkItemsSelector newInstance() {
		return mock != null ? mock : new TrainingWorkItemsSelector();
	}

	/**
	 * Creates a selector that queries in user mode.
	 */
	public TrainingWorkItemsSelector() {
		super(false, fflib_SObjectSelector.DataAccess.USER_MODE);
	}

	/**
	 * Fields included in default queries from this selector.
	 * @return TrainingWorkItem__c Id, Name, WorkOrder__c, TrainingCost__c, DeliveryHours__c, and PreparationHours__c.
	 */
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField>{
			TrainingWorkItem__c.Id,
			TrainingWorkItem__c.Name,
			TrainingWorkItem__c.WorkOrder__c,
			TrainingWorkItem__c.TrainingCost__c,
			TrainingWorkItem__c.DeliveryHours__c,
			TrainingWorkItem__c.PreparationHours__c
		};
	}

	/**
	 * SObject type this selector queries.
	 * @return {@code TrainingWorkItem__c.SObjectType}.
	 */
	public Schema.SObjectType getSObjectType() {
		return TrainingWorkItem__c.SObjectType;
	}

	/**
	 * Selects training work items by Id with fields needed for cost and invoicing.
	 * @param idSet TrainingWorkItem__c Ids to query. Empty set returns an empty list.
	 * @return Matching TrainingWorkItem__c records; empty list when none match.
	 */
	public List<TrainingWorkItem__c> selectById(Set<Id> idSet) {
		return (List<TrainingWorkItem__c>) selectSObjectsById(idSet);
	}

	/**
	 * Factory {@code selectById} uses this method; invoicing needs Work Order account.
	 * @param idSet TrainingWorkItem__c Ids to query. Empty set returns an empty list.
	 * @return Matching work items with WorkOrder__r.Account__c; empty list when none match.
	 */
	public override List<SObject> selectSObjectsById(Set<Id> idSet) {
		return Database.query(
			newQueryFactory().selectField('WorkOrder__r.Account__c').setCondition('Id IN :idSet').toSOQL()
		);
	}
}
