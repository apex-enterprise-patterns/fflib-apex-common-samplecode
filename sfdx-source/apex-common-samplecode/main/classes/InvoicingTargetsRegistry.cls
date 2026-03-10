/**
 * Registry for InvoicingService.generate: polymorphic resolution of domains/selectors
 * for SObject types whose domain implements InvoicingService.ISupportInvoicing.
 *
 * Configure via InvoiceTargets__mdt only for SObject types whose domain implements ISupportInvoicing.
 * Not a general-purpose factory. Use direct construction (e.g. AccountsSelector.newInstance(),
 * Opportunities.newInstance(records)) when the SObject type is known at compile time.
 */
public with sharing class InvoicingTargetsRegistry
{
	private static fflib_Application.SelectorFactory selectorFactory;
	private static fflib_Application.DomainFactory domainFactory;

	@TestVisible
	private static Map<SObjectType, fflib_ISObjectSelector> mockSelectors;
	@TestVisible
	private static Map<SObjectType, fflib_IDomain> mockDomains;

	/** Build domain instance for given records; type resolved from metadata or mock. */
	public static fflib_IDomain newDomain(List<SObject> records)
	{
		SObjectType t = records.getSObjectType();
		if (t == null) { throw new InvoicingTargetsRegistryException('Unable to determine SObjectType'); }
		if (mockDomains != null && mockDomains.containsKey(t)) {
			return mockDomains.get(t);
		}
		ensureInitialized();
		return domainFactory.newInstance(records);
	}

	/** Query records by Id; selector resolved from metadata or mock. All Ids must be same SObject type. */
	public static List<SObject> selectById(Set<Id> recordIds)
	{
		if (recordIds == null || recordIds.isEmpty()) { throw new InvoicingTargetsRegistryException('Invalid record Ids'); }
		SObjectType t = new List<Id>(recordIds)[0].getSObjectType();
		for (Id id : recordIds) {
			if (id.getSObjectType() != t) { throw new InvoicingTargetsRegistryException('Mixed SObject types'); }
		}
		if (mockSelectors != null && mockSelectors.containsKey(t)) {
			return mockSelectors.get(t).selectSObjectsById(recordIds);
		}
		ensureInitialized();
		return selectorFactory.selectById(recordIds);
	}

	/** Lazy init: load InvoiceTargets__mdt and build selector/domain factories. */
	private static void ensureInitialized()
	{
		if (selectorFactory != null) { return; }
		Map<SObjectType, Type> sobjectToDomain = new Map<SObjectType, Type>();
		Map<SObjectType, Type> sobjectToSelector = new Map<SObjectType, Type>();
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		for (InvoiceTargets__mdt c : [
			SELECT SObjectType__r.QualifiedApiName, DomainClass__c, SelectorClass__c
			FROM InvoiceTargets__mdt
			WHERE SObjectType__c != null
			WITH USER_MODE
		])
		{
			SObjectType sot = gd.get(c.SObjectType__r.QualifiedApiName);
			sobjectToDomain.put(sot, Type.forName(c.DomainClass__c));
			sobjectToSelector.put(sot, Type.forName(c.SelectorClass__c));
		}
		selectorFactory = new fflib_Application.SelectorFactory(sobjectToSelector);
		domainFactory = new fflib_Application.DomainFactory(selectorFactory, sobjectToDomain);
	}

	public class InvoicingTargetsRegistryException extends Exception { }
}
