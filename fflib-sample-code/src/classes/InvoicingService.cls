/**
 * Copyright (c) 2012, FinancialForce.com, inc
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

public with sharing class InvoicingService 
{
	public void invoiceOpportunities(Set<Id> opportunityIds)
	{
		// Create unit of work to capture work and commit it under one transaction
		fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(SERVICE_SOBJECTS);
		
		// Invoicing Factory helps domain classes produce invoices
		InvoiceFactory invoiceFactory = new InvoiceFactory(uow);
		
		// Construct domain class capabile of performing invoicing
		ISupportInvoicing invoicing = 
			new Opportunities(new OpportunitiesSelector().selectByIdWithProducts(opportunityIds));				
		invoicing.generate(invoiceFactory);
		
		// Commit updates to opportunities		
		uow.commitWork();									
	}
	
	/**
	 * Interface implemented by domain classes that support the ability to produce invoices
	 **/
	public interface ISupportInvoicing 
	{
		void generate(InvoiceFactory invoiceFactory);
	}
	
	/**
	 * Methods on this factory will help create and register with the UOW invoices
	 */
	public class InvoiceFactory
	{
		private fflib_SObjectUnitOfWork unitOfWork;
		
		public InvoiceFactory(fflib_SObjectUnitOfWork unitOfWork)
		{
			this.unitOfWork = unitOfWork;
		}
		
		public Invoice__c createInvoice(Id accountId, String description, Date dueDate)
		{
			Invoice__c invoice = new Invoice__c();
			// Set fields
			// ...
			unitOfWork.registerNew(invoice);
			return invoice;
		}
	}
	
	// SObject's used by the logic in this service, listed in dependency order
	private static List<Schema.SObjectType> SERVICE_SOBJECTS = 
		new Schema.SObjectType[] { 
			Invoice__c.SObjectType, 
			Opportunity.SObjectType, 
			OpportunityLineItem.SObjectType };		
}