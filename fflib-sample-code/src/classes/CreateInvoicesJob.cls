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
 * Class implements the required interfaces for Scheduling and executing in Batch
 *
 * NOTE: The server and selector methods are reused, logic in this batch class is thus very light,
 *        focusing on passing paramters in and handling errors and notfications
 *
 **/ 
global with sharing class CreateInvoicesJob
	implements System.Schedulable, Database.Batchable<SObject>, Database.Stateful  
{	
	// Simple job log for errors
	private List<JobError> jobErrors = new List<JobError>();
	
	global void execute(SchedulableContext sc)
	{
		// Start the job once the scheduled time has arrived
		Database.executeBatch(new CreateInvoicesJob());		
	}
	
	public Database.QueryLocator start(Database.BatchableContext context)
	{
		// Obtain appoprite query locator from the selector
		return new OpportunitiesSelector().queryLocatorReadyToInvoice();	
	}
	
	public void execute(Database.BatchableContext context, List<Opportunity> opps)
	{
		try
		{
			// Opportunites ready to be invoiced
			Set<Id> opportunitiesToInvoice = new Map<Id, SObject>(opps).keySet();
						
			// Create invoices
			OpportunitiesService.createInvoices(opportunitiesToInvoice, 0);	
		}
		catch (Exception e)
		{
			// Capture context and error for reporting once job complete
			JobError jobError = new JobError();
			jobError.records = opps;
			jobError.message = e.getMessage();
			jobErrors.add(jobError);
		}
	}
	
	public void finish(Database.BatchableContext context)
	{
		// Simple notifiation of any errors received via email
		if(jobErrors.size() > 0)
		{
			// Email address from user
			Map<Id, String> usersEmail = 
				new UsersSelector().getUsersEmail(
					new Set<Id> { UserInfo.getUserId() });
			// Construct email body 
			String emailBody = '';
			for(JobError jobError : jobErrors)
			{
				List<String> failedOpps = new List<String>();
				for(Opportunity opp : jobError.records)
					failedOpps.add(opp.Name);
				emailBody+= String.format('<p>Error {0} occured during the processing of Opportunities {1}</p>', 
					new List<String> { jobError.message, String.join(failedOpps, ',') });					
			}			
			// Send email
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[] { usersEmail.get(UserInfo.getUserId()) });
			mail.setReplyTo(usersEmail.get(UserInfo.getUserId()));
			mail.setSenderDisplayName(userInfo.getUserName());
			mail.setSubject('Create Invoice Job Failures');
			mail.setHtmlBody(emailBody);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });			
		}
	}
	
	/**
	 * Simple wrapper class containing the error message and the records in scope at the time
	 **/
	public class JobError
	{
		public String message;		
		public List<Opportunity> records;
	}
}