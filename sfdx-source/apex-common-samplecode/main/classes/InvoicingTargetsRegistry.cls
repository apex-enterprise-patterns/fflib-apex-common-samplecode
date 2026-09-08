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
 * Registry for InvoicingService.generate: polymorphic resolution of domains/selectors
 * for SObject types whose domain implements InvoicingService.ISupportInvoicing.
 *
 * Configure via InvoiceTargets__mdt only for SObject types whose domain implements ISupportInvoicing.
 * Not a general-purpose factory. Use direct construction (e.g. AccountsSelector.newInstance(),
 * Opportunities.newInstance(records)) when the SObject type is known at compile time.
 */
public inherited sharing class InvoicingTargetsRegistry {
	private static fflib_Application.SelectorFactory selectorFactory;
	private static fflib_Application.DomainFactory domainFactory;

	@TestVisible
	private static Map<SObjectType, fflib_ISObjectSelector> mockSelectors;
	@TestVisible
	private static Map<SObjectType, fflib_IDomain> mockDomains;

	/**
	 * Constructs a domain for the given records using the type registered in InvoiceTargets__mdt.
	 * @param records Homogeneous SObject list whose type is registered for invoicing. Cannot be null.
	 * @return Domain instance for the records' SObject type.
	 * @throws InvoicingTargetsRegistryException When the type is unsupported or cannot be determined.
	 */
	public static fflib_IDomain newDomain(List<SObject> records) {
		SObjectType t = records.getSObjectType();
		if (t == null) {
			throw new InvoicingTargetsRegistryException('Unable to determine SObjectType');
		}
		if (mockDomains != null && mockDomains.containsKey(t)) {
			return mockDomains.get(t);
		}
		ensureInitialized();
		return domainFactory.newInstance(records);
	}

	/**
	 * Selects records by Id using the selector registered in InvoiceTargets__mdt.
	 * @param recordIds Homogeneous set of Ids. Cannot be null or empty.
	 * @return Matching SObjects queried by the configured selector.
	 * @throws InvoicingTargetsRegistryException When Ids are invalid or mixed.
	 */
	public static List<SObject> selectById(Set<Id> recordIds) {
		if (recordIds == null || recordIds.isEmpty()) {
			throw new InvoicingTargetsRegistryException('Invalid record Ids');
		}
		SObjectType t = new List<Id>(recordIds)[0].getSObjectType();
		for (Id recordId : recordIds) {
			if (recordId.getSObjectType() != t) {
				throw new InvoicingTargetsRegistryException('Mixed SObject types');
			}
		}
		if (mockSelectors != null && mockSelectors.containsKey(t)) {
			return mockSelectors.get(t).selectSObjectsById(recordIds);
		}
		ensureInitialized();
		return selectorFactory.selectById(recordIds);
	}

	private static void ensureInitialized() {
		if (selectorFactory != null) {
			return;
		}
		Map<SObjectType, Type> sobjectToDomain = new Map<SObjectType, Type>();
		Map<SObjectType, Type> sobjectToSelector = new Map<SObjectType, Type>();
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		for (InvoiceTargets__mdt config : [
			SELECT SObjectType__r.QualifiedApiName, DomainClass__c, SelectorClass__c
			FROM InvoiceTargets__mdt
			WHERE SObjectType__c != null
			WITH USER_MODE
		]) {
			SObjectType sot = gd.get(config.SObjectType__r.QualifiedApiName);
			if (sot == null) {
				continue;
			}
			sobjectToDomain.put(sot, Type.forName(config.DomainClass__c));
			sobjectToSelector.put(sot, Type.forName(config.SelectorClass__c));
		}
		selectorFactory = new fflib_Application.SelectorFactory(sobjectToSelector);
		domainFactory = new fflib_Application.DomainFactory(selectorFactory, sobjectToDomain);
	}

	/**
	 * Thrown when registry lookup or domain/selector construction fails.
	 */
	public class InvoicingTargetsRegistryException extends Exception {
	}
}
