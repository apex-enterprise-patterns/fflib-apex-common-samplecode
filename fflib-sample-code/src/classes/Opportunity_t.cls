@isTest
public class Opportunity_t extends fflib_DomainObjectBuilder {
    
    private Opportunity opt; 
    
    // CONSTRUCTORS
    
    public Opportunity_t(String name) {
        super(Opportunity.SObjectType);
        
        opt = (Opportunity) record;
        opt.Name = name;
        closes(System.today());
    }
    
    public Opportunity_t() {
        this('Opportunity');
    }
    
    // BUILDER METHODS

    public Opportunity_t add(OpportunityLineItem_t oli) {
        return (Opportunity_t) oli.setParent(OpportunityLineItem.OpportunityId, this);
    }

    public Opportunity_t stage(String value) {
        return (Opportunity_t) set(Opportunity.StageName, value);
    }

    public Opportunity_t closes(Date value) {
        return (Opportunity_t) set(Opportunity.CloseDate, value);
    }
}