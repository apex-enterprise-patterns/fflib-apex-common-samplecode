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
 * REST resource that applies a discount to a single Opportunity identified in the URL path.
 * Path pattern: {@code /opportunities/{id}/applydiscount} with optional {@code discount} query parameter.
 */
@RestResource(UrlMapping='/opportunities/*/applydiscount')
global inherited sharing class OpportunitiesResource
{
	/**
	 * Applies a discount to the Opportunity Id in the request URI via {@link OpportunitiesService}.
	 * Reads the {@code discount} query parameter; defaults to zero when absent.
	 */
	@HttpPost
	global static void applyDiscount()
	{
		RestRequest req = RestContext.request;
		String[] uriParts = req.requestURI.split('/');
		Id opportunityId = uriParts[2];
		String discountParam = req.params.get('discount');
		Decimal discountPercent = discountParam!=null ? Decimal.valueOf(discountParam) : 0;
		OpportunitiesService.newInstance().applyDiscounts(new Set<Id>{ opportunityId }, discountPercent);
	}
}
