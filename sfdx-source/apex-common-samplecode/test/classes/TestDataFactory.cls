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
 * Shared test data factory. Creates a Standard User with ApexEnterprisePatternsSampleApp
 * permission set for runAs tests that require field-level access.
 */
@IsTest
public class TestDataFactory
{
	private static final String RUN_AS_USER_LASTNAME = 'SampleApp';

	/**
	 * Inserts a Sales User (or Standard User fallback) and assigns ApexEnterprisePatternsSampleApp.
	 * @return The inserted User ready for System.runAs.
	 */
	public static User createUserWithSampleAppPermissions()
	{
		List<Profile> salesProfiles = [
			SELECT Id
			FROM Profile
			WHERE Name = 'Sales User' AND UserLicense.Name = 'Salesforce'
			LIMIT 1
		];
		Profile p = salesProfiles.isEmpty()
			? [
				SELECT Id
				FROM Profile
				WHERE Name = 'Standard User' AND UserLicense.Name = 'Salesforce'
				LIMIT 1
			]
			: salesProfiles[0];
		String uniqueName = 'sampleapp_' + DateTime.now().getTime() + '@test.org';
		User u = new User(
			Alias = 'sampapp',
			Email = 'sampleapp@test.org',
			EmailEncodingKey = 'UTF-8',
			LastName = RUN_AS_USER_LASTNAME,
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = p.Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = uniqueName
		);
		insert u;

		PermissionSet ps = [
			SELECT Id
			FROM PermissionSet
			WHERE Name = 'ApexEnterprisePatternsSampleApp'
			LIMIT 1
		];
		insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
		return u;
	}

	/**
	 * Returns the runAs user previously created by {@link #createUserWithSampleAppPermissions}.
	 * @return User with LastName SampleApp; query exception if none exists.
	 */
	public static User getRunAsUser()
	{
		return [SELECT Id FROM User WHERE LastName = :RUN_AS_USER_LASTNAME LIMIT 1];
	}
}
