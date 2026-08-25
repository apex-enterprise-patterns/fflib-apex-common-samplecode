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
 * Wizard to create an Opportunity from recently used line items on an Account.
 * Intentionally not pattern-based (matches sample).
 */
public inherited sharing class QuickOpportunityWizardController
{
	/**
	 * Loads default Opportunity name and recently used line items for the Account Lightning action.
	 * @param accountId Account Id whose recent opportunity products are offered. Cannot be null.
	 * @return Wizard state with default name and selectable line items.
	 */
	@AuraEnabled(cacheable=false)
	public static ViewState getWizardData(Id accountId)
	{
		try
		{
			Account account = [SELECT Id, Name FROM Account WHERE Id = :accountId];
			ViewState viewState = new ViewState();
			viewState.opportunityName = account.Name;
			viewState.selectLineItemList = new List<SelectLineItem>();

			List<OpportunityLineItem> lines = [
				SELECT
					Id,
					OpportunityId,
					Description,
					Quantity,
					UnitPrice,
					ListPrice,
					PricebookEntryId,
					SortOrder,
					PricebookEntry.Name,
					PricebookEntry.Product2Id,
					PricebookEntry.Product2.DiscountingApproved__c,
					PricebookEntry.Pricebook2.Name
				FROM OpportunityLineItem
				WHERE Opportunity.Account.Id = :account.Id
				ORDER BY SystemModstamp DESC
				LIMIT 10
			];

			Integer rowKey = 0;
			for(OpportunityLineItem item : lines)
			{
				SelectLineItem sli = new SelectLineItem();
				sli.key = String.valueOf(rowKey++);
				sli.selected = false;
				sli.productName = item.PricebookEntry.Name;
				sli.pricebookName = item.PricebookEntry.Pricebook2.Name;
				sli.description = item.Description;
				sli.listPrice = item.ListPrice;
				sli.unitPrice = item.UnitPrice;
				sli.quantity = item.Quantity;
				sli.pricebookEntryId = item.PricebookEntryId;
				viewState.selectLineItemList.add(sli);
			}
			return viewState;
		}
		catch (Exception e)
		{
			throw toAura(e);
		}
	}

	/**
	 * Inserts the Opportunity and selected line items, then returns the new Opportunity Id.
	 * @param accountId Account Id to own the Opportunity. Cannot be null.
	 * @param name Opportunity name.
	 * @param stageName Opportunity stage.
	 * @param closeDate Opportunity close date.
	 * @param selectLineItemList Line items from the wizard; only selected rows are inserted.
	 * @return Id of the inserted Opportunity.
	 */
	@AuraEnabled(cacheable=false)
	public static Id createOpportunity(
		Id accountId,
		String name,
		String stageName,
		Date closeDate,
		List<SelectLineItem> selectLineItemList
	)
	{
		try
		{
			Opportunity opportunity = new Opportunity();
			opportunity.Name = name;
			opportunity.AccountId = accountId;
			opportunity.StageName = stageName;
			opportunity.CloseDate = closeDate;
			opportunity.DiscountType__c = OpportunitySettings__c.getInstance().DiscountType__c;
			Database.insert(opportunity);

			List<OpportunityLineItem> lines = new List<OpportunityLineItem>();
			if(selectLineItemList!=null)
			{
				for(SelectLineItem item : selectLineItemList)
				{
					if(item!=null && item.selected==true)
					{
						lines.add(
							new OpportunityLineItem(
								OpportunityId = opportunity.Id,
								PricebookEntryId = item.pricebookEntryId,
								Description = item.description,
								Quantity = item.quantity,
								UnitPrice = item.unitPrice
							)
						);
					}
				}
			}
			if(!lines.isEmpty())
			{
				Database.insert(lines);
			}
			return opportunity.Id;
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

	/**
	 * Holds wizard Opportunity defaults and selectable recent line items.
	 */
	public class ViewState
{
		/**
		 * Default Opportunity name, taken from the Account.
		 */
		@AuraEnabled
		public String opportunityName { get; set; }
		/**
		 * Recent line items the user may select to copy onto the new Opportunity.
		 */
		@AuraEnabled
		public List<SelectLineItem> selectLineItemList { get; set; }
	}

	/**
	 * Wrapper for a cloned OpportunityLineItem and its selection flag in the wizard.
	 */
	public class SelectLineItem
{
		/**
		 * Client-side row key for the datatable.
		 */
		@AuraEnabled
		public String key { get; set; }
		/**
		 * Whether the user selected this line for the new Opportunity.
		 */
		@AuraEnabled
		public Boolean selected { get; set; }
		/**
		 * Product name from the price book entry.
		 */
		@AuraEnabled
		public String productName { get; set; }
		/**
		 * Price book name from the price book entry.
		 */
		@AuraEnabled
		public String pricebookName { get; set; }
		/**
		 * Line description to insert when selected.
		 */
		@AuraEnabled
		public String description { get; set; }
		/**
		 * List price shown read-only in the wizard.
		 */
		@AuraEnabled
		public Decimal listPrice { get; set; }
		/**
		 * Unit price to insert when selected.
		 */
		@AuraEnabled
		public Decimal unitPrice { get; set; }
		/**
		 * Quantity to insert when selected.
		 */
		@AuraEnabled
		public Decimal quantity { get; set; }
		/**
		 * Price book entry used when inserting the line.
		 */
		@AuraEnabled
		public Id pricebookEntryId { get; set; }
	}
}
