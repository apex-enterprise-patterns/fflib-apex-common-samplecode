/**
 * Copyright (c) 2014, FinancialForce.com, inc
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
 * Polymorphic invoicing service that generates invoices from registered source SObject types
 * via {@link InvoicingTargetsRegistry} and domains implementing {@link ISupportInvoicing}.
 */
public inherited sharing class InvoicingService
{
	@TestVisible
	private static InvoicingService mock;

	/**
	 * Factory that returns this service, or {@link #mock} when tests have set one.
	 * @return {@link InvoicingService} instance.
	 */
	public static InvoicingService newInstance()
	{
		return mock!=null ? mock : new InvoicingService();
	}

	/**
	 * Contract for domains that can contribute invoices to an {@link InvoiceFactory}.
	 */
	public interface ISupportInvoicing
	{
		/**
		 * Adds invoice DTOs for the domain's records to the factory.
		 * @param invoiceFactory Factory that collects invoice headers and lines. Cannot be null.
		 */
		void generate(InvoiceFactory invoiceFactory);
	}

	/**
	 * Registers invoice headers and lines with a Unit of Work.
	 */
	public class InvoiceFactory
{
		private fflib_ISObjectUnitOfWork unitOfWork;
		/**
		 * Invoice__c headers accumulated so far; Ids are set after commit.
		 */
		public List<Invoice__c> Invoices { get; private set; }

		/**
		 * Creates a factory that registers invoices on the given Unit of Work.
		 * @param unitOfWork Unit of Work that will insert headers and lines. Cannot be null.
		 */
		public InvoiceFactory(fflib_ISObjectUnitOfWork unitOfWork)
		{
			this.unitOfWork = unitOfWork;
			this.Invoices = new List<Invoice__c>();
		}

		/**
		 * Converts an {@link Invoice} DTO into Invoice__c / InvoiceLine__c rows registered on the UoW.
		 * @param invoice Invoice header and optional lines to add. Cannot be null.
		 */
		public void add(Invoice invoice)
		{
			Invoice__c invoiceRecord = new Invoice__c();
			invoiceRecord.Account__c = invoice.Account;
			invoiceRecord.Description__c = invoice.Description;
			invoiceRecord.InvoiceDate__c = invoice.InvoiceDate;
			unitOfWork.registerNew(invoiceRecord);
			Invoices.add(invoiceRecord);

			if(invoice.Lines==null)
			{
				return;
			}
			for(InvoiceLine line : invoice.Lines)
			{
				InvoiceLine__c invoiceLineItem = new InvoiceLine__c();
				invoiceLineItem.Description__c = line.Description;
				invoiceLineItem.Product__c = line.Product;
				invoiceLineItem.UnitPrice__c = line.UnitPrice;
				invoiceLineItem.Quantity__c = line.Quantity;
				unitOfWork.registerNew(invoiceLineItem, InvoiceLine__c.Invoice__c, invoiceRecord);
			}
		}
	}

	/**
	 * In-memory invoice header used by domains before persistence.
	 */
	public class Invoice
{
		public List<InvoiceLine> Lines { get; set; }
		public Id Account { get; set; }
		public String Description { get; set; }
		public Date InvoiceDate { get; set; }
	}

	/**
	 * In-memory invoice line used by domains before persistence.
	 */
	public class InvoiceLine
{
		public String Description { get; set; }
		public Id Product { get; set; }
		public Decimal UnitPrice { get; set; }
		public Decimal Quantity { get; set; }
	}

	/**
	 * Loads source records via {@link InvoicingTargetsRegistry}, asks the domain to generate invoices,
	 * and commits Invoice__c / InvoiceLine__c.
	 * @param sourceRecordIds Homogeneous Ids of registered invoice source records. Cannot be null.
	 * @return Ids of inserted Invoice__c records; empty list when none were created.
	 * @throws InvoicingException When the source type is invalid, commit fails, or another unexpected error occurs.
	 */
	public List<Id> generate(List<Id> sourceRecordIds)
	{
		try
		{
			fflib_ISObjectUnitOfWork uow = UnitOfWork.newInstance();
			InvoiceFactory invoiceFactory = new InvoiceFactory(uow);
			List<SObject> records = InvoicingTargetsRegistry.selectById(new Set<Id>(sourceRecordIds));
			Object domain = InvoicingTargetsRegistry.newDomain(records);
			if(!(domain instanceof ISupportInvoicing))
			{
				throw new InvoicingException('Invalid source object for generating invoices.');
			}

			((ISupportInvoicing) domain).generate(invoiceFactory);
			uow.commitWork();

			List<Id> invoiceIds = new List<Id>();
			for(Invoice__c invoice : invoiceFactory.Invoices)
			{
				invoiceIds.add(invoice.Id);
			}
			return invoiceIds;
		}
		catch (InvoicingException e)
		{
			throw e;
		}
		catch (DmlException e)
		{
			throw new InvoicingException('Error generating invoices: ' + e.getDmlMessage(0), e);
		}
		catch (Exception e)
		{
			throw new InvoicingException(e.getMessage(), e);
		}
	}

	/**
	 * Represents an exception thrown by {@link InvoicingService} operations.
	 */
	public class InvoicingException extends Exception
	{
	}
}
