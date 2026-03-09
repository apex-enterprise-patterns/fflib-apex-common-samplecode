/**
 * Runtime registry for polymorphic domain/selector resolution via Custom Metadata.
 *
 * Acts as a basic factory: given record Ids or records, it resolves the correct
 * selector and domain class from DomainConfiguration__mdt, then instantiates them.
 * Delegates domain construction to fflib_Application.DomainFactory.
 *
 * Basic factory example:
 * <pre>
 * Set&lt;Id&gt; ids = new Set&lt;Id&gt;{ someAccountId };
 * List&lt;SObject&gt; records = DomainRegistry.selectById(ids);  // resolves selector, executes query
 * fflib_IDomain domain = DomainRegistry.newDomain(records); // resolves domain, constructs instance
 * </pre>
 *
 * Use direct selector/domain construction (e.g. AccountsSelector.newInstance(), new Accounts(...))
 * when the SObject type is known at compile time, to avoid the registry indirection.
 */
public with sharing class DomainRegistry
{
	private static fflib_Application.SelectorFactory selectorFactory;
	private static fflib_Application.DomainFactory domainFactory;

	@TestVisible
	private static Map<SObjectType, fflib_ISObjectSelector> mockSelectors;
	@TestVisible
	private static Map<SObjectType, fflib_IDomain> mockDomains;

	public static fflib_IDomain newDomain(List<SObject> records)
	{
		SObjectType t = records.getSObjectType();
		if (t == null) { throw new DomainRegistryException('Unable to determine SObjectType'); }
		if (mockDomains != null && mockDomains.containsKey(t)) {
			return mockDomains.get(t);
		}
		ensureInitialized();
		return domainFactory.newInstance(records);
	}

	public static List<SObject> selectById(Set<Id> recordIds)
	{
		if (recordIds == null || recordIds.isEmpty()) { throw new DomainRegistryException('Invalid record Ids'); }
		SObjectType t = new List<Id>(recordIds)[0].getSObjectType();
		for (Id id : recordIds) {
			if (id.getSObjectType() != t) { throw new DomainRegistryException('Mixed SObject types'); }
		}
		if (mockSelectors != null && mockSelectors.containsKey(t)) {
			return mockSelectors.get(t).selectSObjectsById(recordIds);
		}
		ensureInitialized();
		return selectorFactory.selectById(recordIds);
	}

	private static void ensureInitialized()
	{
		if (selectorFactory != null) { return; }
		Map<SObjectType, Type> sobjectToDomain = new Map<SObjectType, Type>();
		Map<SObjectType, Type> sobjectToSelector = new Map<SObjectType, Type>();
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		for (DomainConfiguration__mdt c : [
			SELECT SObjectType__r.QualifiedApiName, DomainClass__c, SelectorClass__c
			FROM DomainConfiguration__mdt
			WHERE SObjectType__c != null
			WITH USER_MODE
		])
		{
			String apiName = c.SObjectType__r?.QualifiedApiName;
			if (String.isNotBlank(apiName) && gd.containsKey(apiName))
			{
				SObjectType sot = gd.get(apiName);
				if (String.isNotBlank(c.DomainClass__c)) { sobjectToDomain.put(sot, Type.forName(c.DomainClass__c)); }
				if (String.isNotBlank(c.SelectorClass__c)) { sobjectToSelector.put(sot, Type.forName(c.SelectorClass__c)); }
			}
		}
		selectorFactory = new fflib_Application.SelectorFactory(sobjectToSelector);
		domainFactory = new fflib_Application.DomainFactory(selectorFactory, sobjectToDomain);
	}

	public class DomainRegistryException extends Exception { }
}
