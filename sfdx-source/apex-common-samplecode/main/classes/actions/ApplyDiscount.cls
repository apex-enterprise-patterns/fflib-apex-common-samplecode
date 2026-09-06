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
 * Invocable action that applies a percentage discount to an Opportunity.
 * Delegates to {@link OpportunitiesService}.
 */
public inherited sharing class ApplyDiscount {
	/**
	 * Applies discounts for all requests via {@link OpportunitiesService#applyDiscounts}.
	 * @param requests Opportunity Id and discount percent per request. Cannot be null.
	 * @return Opportunity Ids in the same order as {@code requests}.
	 */
	@InvocableMethod(
		label='Apply Discount'
		description='Applies a percentage discount to an Opportunity and its discountable products.'
		category='Opportunities'
	)
	public static List<Result> execute(List<Request> requests) {

		// Build the map of Opportunity Ids and discount percentages.
		Map<Id, Decimal> discountByOpportunityId = new Map<Id, Decimal>();
		for (Request request : requests) {
			discountByOpportunityId.put(request.opportunityId, request.discountPercentage);
		}

		// Apply discounts to the Opportunities.
		OpportunitiesService.newInstance().applyDiscounts(discountByOpportunityId);

		// Build the results.
		List<Result> results = new List<Result>();
		for (Request request : requests) {
			Result result = new Result();
			result.opportunityId = request.opportunityId;
			result.discountPercentage = request.discountPercentage;
			results.add(result);
		}
		return results;
	}

	/**
	 * Input for {@link #execute}.
	 */
	public class Request {
		/**
		 * Opportunity Id to discount.
		 */
		@InvocableVariable(label='Opportunity Id' required=true)
		public Id opportunityId;
		/**
		 * Discount percent to apply (for example 10 for 10%).
		 */
		@InvocableVariable(label='Discount Percentage' required=true)
		public Decimal discountPercentage;
	}

	/**
	 * Output for {@link #execute}.
	 */
	public class Result {
		/**
		 * Id of the discounted Opportunity.
		 */
		@InvocableVariable(label='Opportunity Id')
		public Id opportunityId;
		/**
		 * Discount percent that was applied.
		 */
		@InvocableVariable(label='Discount Percentage')
		public Decimal discountPercentage;
	}
}
