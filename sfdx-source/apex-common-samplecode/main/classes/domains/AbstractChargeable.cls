/**
 * Copyright (c) 2013-2014, FinancialForce.com, inc
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
 * Abstract chargeable work-item domain that derives cost as hours worked times 100.
 * Concrete subclasses supply the cost field and hour calculation for their SObject type.
 */
public abstract inherited sharing class AbstractChargeable extends fflib_SObjectDomain
{
	/**
	 * Creates a domain wrapping the given records.
	 * @param records Work-item records to manage. Null is treated as an empty list.
	 */
	public AbstractChargeable(List<SObject> records)
	{
		super(records);
	}

	/**
	 * Returns the SObject field that stores the calculated cost of hours worked.
	 * @return Schema field token for the cost field on the concrete work-item type.
	 */
	public abstract Schema.SObjectField getCostOfHoursWorkedField();

	/**
	 * Calculates hours worked for each record in domain order.
	 * @return Hours worked per record; size matches {@link #getRecords()}.
	 */
	public abstract List<Integer> calculateHoursWorked();

	/**
	 * Before-insert hook that recalculates cost of hours worked on all records.
	 */
	public override void onBeforeInsert()
	{
		updateCostOfHoursWorked();
	}

	/**
	 * Before-update hook that recalculates cost of hours worked on all records.
	 * @param existingRecords Prior versions of the records keyed by Id. May be unused by the base implementation.
	 */
	public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
	{
		updateCostOfHoursWorked();
	}

	/**
	 * Sets each record's cost field to hours worked times 100 using
	 * {@link #calculateHoursWorked()} and {@link #getCostOfHoursWorkedField()}.
	 */
	public virtual void updateCostOfHoursWorked()
	{
		List<Integer> hoursWorked = calculateHoursWorked();
		Schema.SObjectField costOfHoursWorkedField = getCostOfHoursWorkedField();
		Integer hoursWorkedRecordIdx = 0;
		for(SObject record : Records)
		{
			record.put(costOfHoursWorkedField, hoursWorked[hoursWorkedRecordIdx++] * 100);
		}
	}
}
