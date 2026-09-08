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
 * Domain for TrainingWorkItem__c that calculates training cost and builds invoice DTOs.
 * Implements {@link InvoicingService.ISupportInvoicing} for polymorphic invoicing.
 */
public virtual inherited sharing class TrainingWorkItems extends AbstractChargeable
	implements InvoicingService.ISupportInvoicing {

	@TestVisible
	private static TrainingWorkItems mock;

	/**
	 * Factory that wraps the given training work items, or {@link #mock} when tests have set one.
	 * @param recordList Training work items to manage. Null is treated as an empty list.
	 * @return {@link TrainingWorkItems} instance.
	 */
	public static TrainingWorkItems newInstance(List<TrainingWorkItem__c> recordList) {
		return mock != null ? mock : new TrainingWorkItems(recordList);
	}

	/**
	 * Creates a domain wrapping the given training work items.
	 * @param workItems Training work items to manage. Null is treated as an empty list.
	 */
	public TrainingWorkItems(List<TrainingWorkItem__c> workItems) {
		super(workItems == null ? new List<TrainingWorkItem__c>() : workItems);
	}

	/**
	 * Returns the field that stores calculated training cost.
	 * @return {@code TrainingWorkItem__c.TrainingCost__c}.
	 */
	public override Schema.SObjectField getCostOfHoursWorkedField() {
		return TrainingWorkItem__c.TrainingCost__c;
	}

	/**
	 * Sums delivery and preparation hours for each work item; null hour fields count as zero.
	 * @return Hours worked per record in domain order.
	 */
	public override List<Integer> calculateHoursWorked() {
		List<Integer> hoursWorked = new List<Integer>();
		for (TrainingWorkItem__c wi : (List<TrainingWorkItem__c>) Records) {
			Decimal d =
				(wi.DeliveryHours__c != null ? wi.DeliveryHours__c : 0) +
				(wi.PreparationHours__c != null ? wi.PreparationHours__c : 0);
			hoursWorked.add(d.intValue());
		}
		return hoursWorked;
	}

	/**
	 * Adds one invoice per work item that has a related Work Order account.
	 * Unit price comes from TrainingCost__c; work items without an account are skipped.
	 * @param invoiceFactory Factory that collects invoice headers and lines. Cannot be null.
	 */
	public virtual void generate(InvoicingService.InvoiceFactory invoiceFactory) {
		for (TrainingWorkItem__c wi : (List<TrainingWorkItem__c>) Records) {
			Id accountId = wi.WorkOrder__r != null ? wi.WorkOrder__r.Account__c : null;
			if (accountId == null) {
				continue;
			}
			InvoicingService.Invoice invoice = new InvoicingService.Invoice();
			invoice.Account = accountId;
			invoice.Description = 'Training: ' + (wi.Name != null ? wi.Name : 'Work Item');
			invoice.InvoiceDate = Date.today();
			InvoicingService.InvoiceLine line = new InvoicingService.InvoiceLine();
			line.Description = 'Training delivery';
			line.Product = null;
			line.UnitPrice = wi.TrainingCost__c != null ? wi.TrainingCost__c : 0;
			line.Quantity = 1;
			invoice.Lines = new List<InvoicingService.InvoiceLine>{ line };
			invoiceFactory.add(invoice);
		}
	}

	/**
	 * Constructs this domain from a trigger record list.
	 */
	public class Constructor implements fflib_SObjectDomain.IConstructable {
		public fflib_SObjectDomain construct(List<SObject> sObjectList) {
			return new TrainingWorkItems((List<TrainingWorkItem__c>) sObjectList);
		}
	}
}
