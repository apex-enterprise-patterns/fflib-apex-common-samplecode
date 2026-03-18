/**
 * Shared test data factory. Creates a Standard User with ApexEnterprisePatternsSampleApp
 * permission set for runAs tests that require field-level access (USER_MODE enforcement).
 */
@IsTest
public class TestDataFactory
{
	private static final String RUN_AS_USER_LASTNAME = 'SampleApp';

	/**
	 * Creates a Standard User with ApexEnterprisePatternsSampleApp permission set.
	 * Call from @TestSetup. In test methods, use getRunAsUser() with System.runAs().
	 * @return The created user
	 */
	public static User createUserWithSampleAppPermissions()
	{
		List<Profile> salesProfiles = [SELECT Id FROM Profile WHERE Name = 'Sales User' AND UserLicense.Name = 'Salesforce' LIMIT 1];
		Profile p = salesProfiles.isEmpty()
			? [SELECT Id FROM Profile WHERE Name = 'Standard User' AND UserLicense.Name = 'Salesforce' LIMIT 1]
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

		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ApexEnterprisePatternsSampleApp' LIMIT 1];
		insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);

		return u;
	}

	/** Returns the runAs user created by createUserWithSampleAppPermissions(). Use with System.runAs(). */
	public static User getRunAsUser()
	{
		return [SELECT Id FROM User WHERE LastName = :RUN_AS_USER_LASTNAME LIMIT 1];
	}
}
