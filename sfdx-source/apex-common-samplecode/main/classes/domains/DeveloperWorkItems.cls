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

public with sharing class DeveloperWorkItems extends AbstractChargeable
	implements IDeveloperWorkItems
{
	public static IDeveloperWorkItems newInstance(List<DeveloperWorkItem__c> recordList)
	{
		return (IDeveloperWorkItems) Application.Domain.newInstance(recordList);
	}

	public static IDeveloperWorkItems newInstance(Set<Id> recordIdSet)
	{
		return (IDeveloperWorkItems) Application.Domain.newInstance(recordIdSet);
	}
	
	public DeveloperWorkItems(List<DeveloperWorkItem__c> workItems)
	{
		super(workItems);
	}
	
	public override Schema.SObjectField getCostOfHoursWorkedField()
	{
		// Field base class will populate once it has calculated the cost
		return DeveloperWorkItem__c.DeveloperCost__c;
	}
	 
	public override List<Integer> calculateHoursWorked()
	{
		// Calculate the hours worked for each record
		List<Integer> hoursWorked = new List<Integer>(); 
		for(DeveloperWorkItem__c workItem : (List<DeveloperWorkItem__c>) this.records)
		{
			// This calculation is intentionally simplistic for illustration purposes
			hoursWorked.add((Integer)  
				(workItem.CodingHours__c + 
				 workItem.CodeReviewingHours__c + 
				 workItem.TechnicalDesignHours__c));
		}
		return hoursWorked;
	}	
	
	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new DeveloperWorkItems(sObjectList);
		}
	}	
}