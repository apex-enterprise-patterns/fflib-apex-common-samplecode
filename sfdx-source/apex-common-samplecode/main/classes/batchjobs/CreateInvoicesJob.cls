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
 * Batch and schedulable job that invoices Opportunities marked Ready via {@link OpportunitiesService}.
 * Accumulates per-chunk failures and emails the running user on finish.
 */
public inherited sharing class CreateInvoicesJob
	implements System.Schedulable, Database.Batchable<SObject>, Database.Stateful  
{	
	private List<JobError> jobErrors = new List<JobError>();
	
	/**
	 * Schedulable entry point that starts a new batch instance of this job.
	 * @param sc Schedulable context provided by the platform.
	 */
	public void execute(SchedulableContext sc)
	{
		Database.executeBatch(new CreateInvoicesJob());		
	}
	
	/**
	 * Starts the batch using Opportunities with InvoicedStatus__c Ready.
	 * @param context Batchable context provided by the platform.
	 * @return QueryLocator from {@link OpportunitiesSelector#readyToInvoiceAsQueryLocator}.
	 */
	public Database.QueryLocator start(Database.BatchableContext context)
	{
		return OpportunitiesSelector.newInstance().readyToInvoiceAsQueryLocator();	
	}
	
	/**
	 * Creates invoices for the current chunk of Opportunities with zero discount.
	 * Failures are captured in {@link JobError} without failing the entire batch.
	 * @param context Batchable context provided by the platform.
	 * @param opps Opportunity chunk to invoice.
	 */
	public void execute(Database.BatchableContext context, List<Opportunity> opps)
	{
		try
		{
			Set<Id> opportunitiesToInvoice = new Map<Id, SObject>(opps).keySet();
			OpportunitiesService.newInstance().createInvoices(opportunitiesToInvoice, 0);	
		}
		catch (Exception e)
		{
			JobError jobError = new JobError();
			jobError.records = opps;
			jobError.message = e.getMessage();
			jobErrors.add(jobError);
		}
	}
	
	/**
	 * Emails the running user a summary of any chunk failures recorded during execute.
	 * @param context Batchable context provided by the platform.
	 */
	public void finish(Database.BatchableContext context)
	{
		if(jobErrors.size() > 0)
		{
			Map<Id, String> usersEmail = 
				UsersSelector.newInstance().getUsersEmail(
					new Set<Id> { UserInfo.getUserId() });
			String emailBody = '';
			for(JobError jobError : jobErrors)
			{
				List<String> failedOpps = new List<String>();
				for (Opportunity opp : jobError.records)
				{
					failedOpps.add(opp.Name);
				}
				emailBody += String.format('<p>Error {0} occurred during the processing of Opportunities {1}</p>',
					new List<String> { jobError.message, String.join(failedOpps, ',') });					
			}			
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[] { usersEmail.get(UserInfo.getUserId()) });
			mail.setReplyTo(usersEmail.get(UserInfo.getUserId()));
			mail.setSenderDisplayName(UserInfo.getUserName());
			mail.setSubject('Create Invoice Job Failures');
			mail.setHtmlBody(emailBody);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });			
		}
	}
	
	/**
	 * Captures a batch chunk failure message and the Opportunities that failed.
	 */
	public class JobError
	{
		/**
		 * Exception or error message for the failed chunk.
		 */
		public String message;		
		/**
		 * Opportunities in the chunk that failed processing.
		 */
		public List<Opportunity> records;
	}
}
