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
 * This controller is not using the pattern approach in this code sample version. See the other two controllers
 *   in this sample for an illustration of how the patterns are used.
 **/
public with sharing class QuickOpportunityWizardController
{	
	public ViewState ViewState { get; set; }
	
	private ApexPages.StandardController standardController;

	public QuickOpportunityWizardController(ApexPages.StandardController controller)
	{
		standardController = controller;

		// Create a new Opportunity defaulting from the Account
		Account account = (Account) standardController.getRecord();
		viewState = new ViewState();
		viewState.Opportunity = new Opportunity();
		viewState.Opportunity.Name = account.Name; 
		viewState.Opportunity.AccountId = account.Id;
		viewState.Opportunity.DiscountType__c = OpportunitySettings__c.getInstance().DiscountType__c;
		viewState.SelectLineItemList = new List<SelectLineItem>();
			
		// Recently used Opportunity lines
		List<OpportunityLineItem> lines = 
			[select 
				Id, 
				Description, 
				ListPrice, 
				OpportunityId, 
				PricebookEntryId, 
				Quantity, 
				SortOrder, 
				TotalPrice, 
				UnitPrice, 
				PricebookEntry.Id,
				PricebookEntry.IsActive,
				PricebookEntry.Name,
				PricebookEntry.Pricebook2Id,
				PricebookEntry.Product2Id,
				PricebookEntry.ProductCode,
				PricebookEntry.UnitPrice,
				PricebookEntry.UseStandardPrice,
				PricebookEntry.Pricebook2.Description,
				PricebookEntry.Pricebook2.Id,
				PricebookEntry.Pricebook2.IsActive,
				PricebookEntry.Pricebook2.IsStandard,
				PricebookEntry.Pricebook2.Name 
			 from OpportunityLineItem
			 where Opportunity.Account.id = :account.Id 
			 order by SystemModstamp 
			 desc limit 10];
			 
		//  Clone these to be available for selection for the new opportunity
		for(OpportunityLineItem item : lines)
		{
			SelectLineItem sli = new SelectLineItem();
			sli.OpportunityLineItem = item.clone(false, true, false, false);
			sli.OpportunityLineItem.OpportunityId = null; // this will be set as the new opportunity Id
			sli.OpportunityLineItem.TotalPrice = null; // must null this as the record also includes a unit price
			sli.Selected = false; 
			viewState.SelectLineItemList.add(sli);
		}
	}
	
 	public PageReference createOpportunity()
	{
		try
		{
			// Insert new Opportunity 
			insert Viewstate.Opportunity;
			
			// Insert selected Opportunity Lines (cloned from those recently used)
			List<OpportunityLineItem> lines = new List<OpportunityLineItem>(); 
			for(SelectLineItem item : ViewState.SelectLineItemList)
			{
				if(item.Selected)
				{
					OpportunityLineItem line = item.OpportunityLineItem;
					line.OpportunityId = ViewState.Opportunity.Id;
					lines.add(line);
				}
			}
			insert lines;
			
			// Redirect to the new Opportunity
			return new PageReference('/' + viewState.Opportunity.Id);
		}
		catch (Exception e)
		{
			ApexPages.addMessages(e);
		}
		
		return null;
	}

	public class ViewState
	{
		public Opportunity Opportunity {get;set;}
		
		public List<SelectLineItem> SelectLineItemList {get;set;}
	}

	public class SelectLineItem
	{
		public OpportunityLineItem OpportunityLineItem {get;set;}
		
		public Boolean Selected {get;set;}
	}
}