/**
 * Unit of Work for the sample application.
 */
public with sharing class UnitOfWork
{
	private static final List<SObjectType> OBJECT_TYPES = new List<SObjectType> {
		Account.SObjectType,
		Invoice__c.SObjectType,
		InvoiceLine__c.SObjectType,
		Opportunity.SObjectType,
		Product2.SObjectType,
		PricebookEntry.SObjectType,
		OpportunityLineItem.SObjectType,
		WorkOrder__c.SObjectType,
		DeveloperWorkItem__c.SObjectType,
		TrainingWorkItem__c.SObjectType,
		DesignWorkItem__c.SObjectType
	};

	@TestVisible
	private static fflib_ISObjectUnitOfWork mock;
	public static fflib_ISObjectUnitOfWork newInstance()
	{
		if (mock != null) { return mock; }
		return new fflib_SObjectUnitOfWork(OBJECT_TYPES, new fflib_SObjectUnitOfWork.UserModeDML());
	}
}
