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
 * Controller that submits the Opportunity invoicing Batch Apex job from a headless Lightning action.
 *
 * Prefer the no-arg constructor / {@link #startJob} for the default service.
 * Use the service constructor when composing deliberately (including tests).
 */
public inherited sharing class OpportunityInvoicingController
{
	private final OpportunitiesService opportunitiesSvc;

	/**
	 * Default composition: {@link OpportunitiesService#newInstance}.
	 */
	public OpportunityInvoicingController()
	{
		this(OpportunitiesService.newInstance());
	}

	/**
	 * Creates a controller with the given service.
	 * @param opportunitiesSvc Opportunities service used to submit the job. Cannot be null.
	 */
	public OpportunityInvoicingController(OpportunitiesService opportunitiesSvc)
	{
		this.opportunitiesSvc = opportunitiesSvc;
	}

	/**
	 * Submits {@link CreateInvoicesJob} through {@link OpportunitiesService#submitInvoicingJob}.
	 * @return Async Apex job Id returned after a successful submit.
	 */
	@AuraEnabled(cacheable=false)
	public static Id startJob()
	{
		return new OpportunityInvoicingController().handleStartJob();
	}

	/**
	 * Instance entry for {@link #startJob}, used by callers that inject a service.
	 * @return Async Apex job Id returned after a successful submit.
	 */
	public Id handleStartJob()
	{
		try
		{
			return opportunitiesSvc.submitInvoicingJob();
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
