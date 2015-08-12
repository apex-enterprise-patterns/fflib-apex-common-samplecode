@isTest
public with sharing class OpportunityLineItem_t extends fflib_DomainObjectBuilder {
    
    private OpportunityLineItem oli;
    
    // CONSTRUCTORS
    
    public OpportunityLineItem_t() {
        this(new PriceBookEntry_t());
    }
    
    public OpportunityLineItem_t(PriceBookEntry_t pbe) {
        super(OpportunityLineItem.SObjectType, OpportunityLineItem.PriceBookEntryId, pbe);
        oli = (OpportunityLineItem) record;
    }
    
    // BUILDER METHODS

    public OpportunityLineItem_t totalPrice(Decimal value) {
       	return (OpportunityLineItem_t) set(OpportunityLineItem.TotalPrice, value);
    }

    public OpportunityLineItem_t quantity(Integer value) {
       	return (OpportunityLineItem_t) set(OpportunityLineItem.Quantity, value);
    }
}