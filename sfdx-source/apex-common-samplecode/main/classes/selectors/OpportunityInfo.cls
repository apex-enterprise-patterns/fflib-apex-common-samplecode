public class OpportunityInfo
{
    private Opportunity opportunity;

    public OpportunityInfo(Opportunity opportunity)
    {
        this.opportunity = opportunity;
    }

    public Id Id { get { return this.opportunity.Id; } }
    public Decimal Amount { get { return this.opportunity.Amount; } }
    public String Stage { get { return this.opportunity.StageName; } }
    public String AccountName { get { return this.opportunity.Account.Name; } }
    public String AccountNumber { get { return this.opportunity.Account.AccountNumber; } }
    public String AccountOwner { get { return this.opportunity.Account.Owner.Name; } }

}
