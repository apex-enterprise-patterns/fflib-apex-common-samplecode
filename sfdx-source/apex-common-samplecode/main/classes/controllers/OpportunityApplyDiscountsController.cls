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
 * Visualforce controller for the Apply Discounts list-view button.
 * Delegates discounting to {@link OpportunitiesService}.
 *
 * Prefer the StandardSetController constructor for the default service.
 * Use the service overload when composing deliberately (including tests).
 */
public inherited sharing class OpportunityApplyDiscountsController {
	/**
	 * Discount percent entered on the list page (for example 10 for 10%).
	 */
	public Decimal discountPercentage { get; set; }

	private ApexPages.StandardSetController standardSetController;
	private final OpportunitiesService opportunitiesSvc;

	/**
	 * Default composition: {@link OpportunitiesService#newInstance}.
	 * @param controller StandardSetController with selected Opportunities. Cannot be null.
	 */
	public OpportunityApplyDiscountsController(ApexPages.StandardSetController controller) {
		this(controller, OpportunitiesService.newInstance());
	}

	/**
	 * Creates a controller with the given StandardSetController and service.
	 * @param controller StandardSetController with selected Opportunities. Cannot be null.
	 * @param opportunitiesSvc Opportunities service used to apply discounts. Cannot be null.
	 */
	public OpportunityApplyDiscountsController(
		ApexPages.StandardSetController controller,
		OpportunitiesService opportunitiesSvc
	) {
		this.standardSetController = controller;
		this.opportunitiesSvc = opportunitiesSvc;
	}

	/**
	 * Applies {@link #discountPercentage} to all selected Opportunities on the list view.
	 * @return Null so the list page remains; adds an info message on success.
	 */
	public PageReference applyDiscounts() {
		try {
			Set<Id> selectedOpportunityIds =
				new Map<Id, SObject>(standardSetController.getSelected()).keySet();
			Map<Id, Decimal> discountByOpportunityId = new Map<Id, Decimal>();
			for (Id opportunityId : selectedOpportunityIds) {
				discountByOpportunityId.put(opportunityId, discountPercentage);
			}
			opportunitiesSvc.applyDiscounts(discountByOpportunityId);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Opportunities updated.'));
		} catch (Exception e) {
			ApexPages.addMessages(e);
		}
		return null;
	}
}
