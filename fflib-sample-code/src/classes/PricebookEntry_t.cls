@isTest
public with sharing class PricebookEntry_t extends fflib_DomainObjectBuilder {
    
    private PricebookEntry pbe;
    
    // CONSTRUCTORS
    
    public PricebookEntry_t() {
        this(new Product_t());
    }
    
    public PricebookEntry_t(Product_t prd) {
        super(PricebookEntry.SObjectType, PricebookEntry.Product2Id , prd);
        
        pbe = (PricebookEntry) record;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.IsActive = true;
        price(0);
    }
    
    // BUILDER METHODS
    
    public PricebookEntry_t price(Decimal value) {
        return (PricebookEntry_t) set(PricebookEntry.UnitPrice, value);
    }
    
    public PricebookEntry_t useStdPrice(Boolean value) {
        return (PricebookEntry_t) set(PricebookEntry.UseStandardPrice, value);
    }
}