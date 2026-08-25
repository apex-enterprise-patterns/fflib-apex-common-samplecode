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
 * Thin Unit of Work factory for the sample app. No Application class.
 */
public inherited sharing class UnitOfWork {
	@TestVisible
	private static fflib_ISObjectUnitOfWork mock;

	/**
	 * Returns a Unit of Work registered for this app's types, or {@link #mock} when tests have set one.
	 * DML runs in user mode.
	 * @return Unit of Work instance.
	 */
	public static fflib_ISObjectUnitOfWork newInstance() {
		if (mock != null) {
			return mock;
		}
		return new fflib_SObjectUnitOfWork(
			new List<SObjectType>{
				Account.SObjectType,
				Opportunity.SObjectType,
				Product2.SObjectType,
				PricebookEntry.SObjectType,
				OpportunityLineItem.SObjectType,
				Invoice__c.SObjectType,
				InvoiceLine__c.SObjectType,
				WorkOrder__c.SObjectType,
				DeveloperWorkItem__c.SObjectType,
				TrainingWorkItem__c.SObjectType,
				DesignWorkItem__c.SObjectType
			},
			new fflib_SObjectUnitOfWork.UserModeDML()
		);
	}
}
