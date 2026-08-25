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
 * Invocable action that creates an Invoice from an Opportunity.
 * Delegates to {@link OpportunitiesService}.
 */
public inherited sharing class CreateInvoice {
	/**
	 * Creates an Invoice for each request via {@link OpportunitiesService#createInvoices}.
	 * @param requests Opportunity Id and optional discount percent per request. Cannot be null.
	 * @return Invoice Id and Name in the same order as {@code requests}.
	 */
	@InvocableMethod(
		label='Create Invoice'
		description='Creates an Invoice from an Opportunity, optionally applying a discount first.'
		category='Opportunities'
	)
	public static List<Result> execute(List<Request> requests) {
		List<Result> results = new List<Result>();
		for (Request request : requests) {
			Set<Id> invoiceIds = OpportunitiesService.newInstance().createInvoices(
				new Set<Id>{ request.opportunityId },
				request.discountPercentage
			);
			Id invoiceId = new List<Id>(invoiceIds)[0];
			Result result = new Result();
			result.invoiceId = invoiceId;
			result.invoiceName = invoiceName(invoiceId);
			results.add(result);
		}
		return results;
	}

	@TestVisible
	private static String testInvoiceName;

	private static String invoiceName(Id invoiceId) {
		if (testInvoiceName != null) {
			return testInvoiceName;
		}
		return [SELECT Name FROM Invoice__c WHERE Id = :invoiceId].Name;
	}

	/**
	 * Input for {@link #execute}.
	 */
	public class Request {
		/**
		 * Opportunity Id to invoice.
		 */
		@InvocableVariable(label='Opportunity Id' required=true)
		public Id opportunityId;
		/**
		 * Optional discount percent applied before invoicing (for example 10 for 10%).
		 */
		@InvocableVariable(label='Discount Percentage')
		public Decimal discountPercentage;
	}

	/**
	 * Output for {@link #execute}.
	 */
	public class Result {
		/**
		 * Id of the created Invoice__c.
		 */
		@InvocableVariable(label='Invoice Id')
		public Id invoiceId;
		/**
		 * Auto-number Name of the created Invoice__c (for example INV-00000001).
		 */
		@InvocableVariable(label='Invoice Number')
		public String invoiceName;
	}
}
