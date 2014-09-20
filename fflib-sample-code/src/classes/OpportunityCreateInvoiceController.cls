/**
 * Copyright (c), FinancialForce.com, inc
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
 * Controller shared by Create Invoice and Create Invoices Custom Buttons (and related pages) on the Opportunity
 * 
 * NOTE: The same service method is called regardless, logic in this controller is thus very light,
 *        focusing on passing paramters in and handling errors and notfications
 **/
public with sharing class OpportunityCreateInvoiceController 
{
	public Decimal DiscountPercentage { get; set; } 
		
	private ApexPages.StandardController standardController = null; 
	
	private ApexPages.StandardSetController standardSetController = null; 
	
	public OpportunityCreateInvoiceController(ApexPages.StandardController controller)
	{
		standardController = controller;
	}
	
	public OpportunityCreateInvoiceController(ApexPages.StandardSetController controller)
	{
		standardSetController = controller;
	}

	public PageReference createInvoice()
	{
		try
		{
			// Create Invoice the Opportunity
			Set<Id> invoiceIds = OpportunitiesService.createInvoices(
				new Set<ID> { standardController.getId() }, DiscountPercentage);
			
			// Redirect to Invoice 
			return new PageReference('/'+new List<Id>(invoiceIds)[0]);
		}
		catch (Exception e)		
		{
			ApexPages.addMessages(e);
		}	
				
		return ApexPages.hasMessages() ? null : standardController.view();
	}
	
	public PageReference createInvoices()
	{
		try
		{
			// Selected Opportunity Id's
			Set<Id> selectedOpportuntyIds = 
				new Map<Id, SObject>(standardSetController.getSelected()).keySet();
			
			// Create invoices for selected Invoices, optionally applying discount before hand
			OpportunitiesService.createInvoices(selectedOpportuntyIds, DiscountPercentage);
			
			// Confirm
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Invoices created.'));			
		}
		catch (Exception e)		
		{
			ApexPages.addMessages(e);
		}	
				
		return null;
	}	
}