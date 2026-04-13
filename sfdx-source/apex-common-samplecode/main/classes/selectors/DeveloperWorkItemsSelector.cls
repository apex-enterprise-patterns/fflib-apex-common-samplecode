/**
 * Selector for DeveloperWorkItem__c. Supports invoicing via WorkOrder__r.Account__c.
 */
public with sharing class DeveloperWorkItemsSelector extends fflib_SObjectSelector {
	@TestVisible
	private static DeveloperWorkItemsSelector mock;
	public static DeveloperWorkItemsSelector newInstance() {
		if (mock != null) { return mock; }
		return new DeveloperWorkItemsSelector();
	}

	public DeveloperWorkItemsSelector() {
		super(false, fflib_SObjectSelector.DataAccess.USER_MODE);
	}

	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			DeveloperWorkItem__c.Id,
			DeveloperWorkItem__c.Name,
			DeveloperWorkItem__c.WorkOrder__c,
			DeveloperWorkItem__c.DeveloperCost__c,
			DeveloperWorkItem__c.CodingHours__c,
			DeveloperWorkItem__c.CodeReviewingHours__c,
			DeveloperWorkItem__c.TechnicalDesignHours__c
		};
	}

	public Schema.SObjectType getSObjectType() {
		return DeveloperWorkItem__c.SObjectType;
	}

	public List<DeveloperWorkItem__c> selectById(Set<Id> idSet) {
		return (List<DeveloperWorkItem__c>) selectSObjectsById(idSet);
	}

	public override List<SObject> selectSObjectsById(Set<Id> idSet) {
		fflib_QueryFactory qf = newQueryFactory();
		qf.selectField('WorkOrder__r.Account__c');
		return Database.query(qf.setCondition('Id IN :idSet').toSOQL());
	}
}
