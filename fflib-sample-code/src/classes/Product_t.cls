@isTest
public with sharing class Product_t extends fflib_DomainObjectBuilder {
    
    private Product2 prd;
    
    // CONSTRUCTORS
    
    public Product_t(String name) {
        super(Product2.SObjectType);
        
        prd = (Product2) record;
        prd.Name = name;
    }
    
    public Product_t() {
        this('Product');
    }
    
    // BUILDER METHODS

    public Product_t add(PricebookEntry_t pbe) {
        return (Product_t) pbe.setParent(PricebookEntry.Product2Id, this);
    }
}