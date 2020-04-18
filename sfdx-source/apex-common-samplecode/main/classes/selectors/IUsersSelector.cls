public interface IUsersSelector extends fflib_ISObjectSelector 
{
	Map<Id, String> getUsersEmail(Set<Id> userIds);
}
