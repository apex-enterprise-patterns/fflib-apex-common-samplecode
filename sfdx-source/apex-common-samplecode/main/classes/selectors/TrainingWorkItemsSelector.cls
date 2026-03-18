/**
 * Selector for TrainingWorkItem__c. Supports invoicing via WorkOrder__r.Account__c.
 */
public with sharing class TrainingWorkItemsSelector extends fflib_SObjectSelector {
	@TestVisible
	private static TrainingWorkItemsSelector mock;
	public static TrainingWorkItemsSelector newInstance() {
		if (mock != null) { return mock; }
		return new TrainingWorkItemsSelector();
	}

	public TrainingWorkItemsSelector() {
		super(false);
		setDataAccess(fflib_SObjectSelector.DataAccess.USER_MODE);
	}

	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			TrainingWorkItem__c.Id,
			TrainingWorkItem__c.Name,
			TrainingWorkItem__c.WorkOrder__c,
			TrainingWorkItem__c.TrainingCost__c,
			TrainingWorkItem__c.DeliveryHours__c,
			TrainingWorkItem__c.PreparationHours__c
		};
	}

	public Schema.SObjectType getSObjectType() {
		return TrainingWorkItem__c.SObjectType;
	}

	public List<TrainingWorkItem__c> selectById(Set<Id> idSet) {
		return (List<TrainingWorkItem__c>) selectSObjectsById(idSet);
	}

	public override List<SObject> selectSObjectsById(Set<Id> idSet) {
		fflib_QueryFactory qf = newQueryFactory();
		qf.selectField('WorkOrder__r.Account__c');
		return Database.query(qf.setCondition('Id IN :idSet').toSOQL());
	}
}
