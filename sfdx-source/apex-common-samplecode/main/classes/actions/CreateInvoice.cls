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
 *
 * Prefer the no-arg constructor / {@link #execute} for the default service and selector.
 * Use the constructor when composing deliberately (including tests).
 */
public inherited sharing class CreateInvoice {
	private final OpportunitiesService service;
	private final InvoicesSelector selector;

	/**
	 * Default composition: {@link OpportunitiesService#newInstance} and {@link InvoicesSelector#newInstance}.
	 */
	public CreateInvoice() {
		this(OpportunitiesService.newInstance(), InvoicesSelector.newInstance());
	}

	/**
	 * Creates an action with the given service and selector.
	 * @param service Opportunities service used to create invoices. Cannot be null.
	 * @param selector Selector used to load created invoice names. Cannot be null.
	 */
	public CreateInvoice(OpportunitiesService service, InvoicesSelector selector) {
		this.service = service;
		this.selector = selector;
	}

	/**
	 * Creates invoices for all requests via {@link OpportunitiesService#applyDiscountsAndCreateInvoices}.
	 * @param requests Opportunity Id and optional discount percent per request. Cannot be null.
	 * @return Invoice Id and Name in the same order as {@code requests}.
	 */
	@InvocableMethod(
		label='Create Invoice'
		description='Creates an Invoice from an Opportunity, optionally applying a discount first.'
		category='Opportunities'
	)
	public static List<Result> execute(List<Request> requests) {
		return new CreateInvoice().run(requests);
	}

	/**
	 * Instance entry used by {@link #execute} and by callers that inject collaborators.
	 * @param requests Opportunity Id and optional discount percent per request. Cannot be null.
	 * @return Invoice Id and Name in the same order as {@code requests}.
	 */
	public List<Result> run(List<Request> requests) {

		// Build the map of Opportunity Ids and discount percentages.
		Map<Id, Decimal> discountByOpportunityId = new Map<Id, Decimal>();
		for (Request request : requests) {
			discountByOpportunityId.put(request.opportunityId, request.discountPercentage);
		}

		// Apply discounts and create invoices.
		Map<Id, Id> invoiceIdByOpportunityId =
			service.applyDiscountsAndCreateInvoices(discountByOpportunityId);
		Map<Id, String> invoiceNameById = invoiceNamesById(invoiceIdByOpportunityId.values());

		// Build the results.
		List<Result> results = new List<Result>();
		for (Request request : requests) {
			Id invoiceId = invoiceIdByOpportunityId.get(request.opportunityId);
			Result result = new Result();
			result.invoiceId = invoiceId;
			result.invoiceName = invoiceNameById.get(invoiceId);
			results.add(result);
		}
		return results;
	}

	private Map<Id, String> invoiceNamesById(Iterable<Id> invoiceIds) {
		Set<Id> invoiceIdSet = new Set<Id>();
		for (Id invoiceId : invoiceIds) {
			invoiceIdSet.add(invoiceId);
		}
		Map<Id, String> invoiceNameById = new Map<Id, String>();
		for (Invoice__c invoice : selector.selectById(invoiceIdSet)) {
			invoiceNameById.put(invoice.Id, invoice.Name);
		}
		return invoiceNameById;
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
