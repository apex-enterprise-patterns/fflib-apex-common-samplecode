/**
 * Copyright (c) 2013, FinancialForce.com, inc
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
 * Controller for the Apply Discount Lightning action.
 * Delegates discounting to {@link OpportunitiesService}.
 *
 * Prefer the no-arg constructor / {@link #applyDiscount} for the default service.
 * Use the service constructor when composing deliberately (including tests).
 */
public inherited sharing class OpportunityApplyDiscountController
{
	private final OpportunitiesService opportunitiesSvc;

	/**
	 * Default composition: {@link OpportunitiesService#newInstance}.
	 */
	public OpportunityApplyDiscountController()
	{
		this(OpportunitiesService.newInstance());
	}

	/**
	 * Creates a controller with the given service.
	 * @param opportunitiesSvc Opportunities service used to apply discounts. Cannot be null.
	 */
	public OpportunityApplyDiscountController(OpportunitiesService opportunitiesSvc)
	{
		this.opportunitiesSvc = opportunitiesSvc;
	}

	/**
	 * Applies a discount to a single Opportunity from the Lightning action.
	 * @param opportunityId Opportunity Id to discount. Cannot be null.
	 * @param discountPercentage Discount percent to apply (for example 10 for 10%).
	 */
	@AuraEnabled(cacheable=false)
	public static void applyDiscount(Id opportunityId, Decimal discountPercentage)
	{
		new OpportunityApplyDiscountController().handleApplyDiscount(opportunityId, discountPercentage);
	}

	/**
	 * Instance entry for {@link #applyDiscount}, used by callers that inject a service.
	 * @param opportunityId Opportunity Id to discount. Cannot be null.
	 * @param discountPercentage Discount percent to apply (for example 10 for 10%).
	 */
	public void handleApplyDiscount(Id opportunityId, Decimal discountPercentage)
	{
		try
		{
			opportunitiesSvc.applyDiscounts(
				new Map<Id, Decimal>{ opportunityId => discountPercentage }
			);
		}
		catch (Exception e)
		{
			throw toAura(e);
		}
	}

	private static AuraHandledException toAura(Exception e)
	{
		AuraHandledException auraException = new AuraHandledException(e.getMessage());
		auraException.setMessage(e.getMessage());
		return auraException;
	}
}
