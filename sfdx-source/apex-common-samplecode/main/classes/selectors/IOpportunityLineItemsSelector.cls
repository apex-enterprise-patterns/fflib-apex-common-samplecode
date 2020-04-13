public interface IOpportunityLineItemsSelector extends fflib_ISObjectSelector 
{
    List<OpportunityLineItem> selectRecentlyUsed(Set<Id> accountIds, Integer recordLimit);
}