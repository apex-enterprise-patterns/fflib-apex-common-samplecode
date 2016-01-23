public class OpportunityLineItem_t extends Domain_t 
{
    /**
     * Methods/Properties below would be included in a basic template for any derived builder class
     * 
     * BEGIN STANDARD BUILDER TEMPLATE
     * -------------------------------
     **/

    /**
     * @description Default constructor
     **/    
    private OpportunityLineItem_t() {
        super(OpportunityLineItem.SObjectType);
    }

    /**
     * @description Copy Constructor that constructs the Builder class based on the builder specified
     *
     * @param copyFrom The builder to copy/clone this instance from
     **/
    private OpportunityLineItem_t(OpportunityLineItem_t copyFrom) {
        super(copyFrom);
    }           

    /**
     * @description Creates an existing SObject without issuing DML
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
     **/
    public OpportunityLineItem build() {
        return (OpportunityLineItem)build(false);
    }

    /**
     * @description Creates an New SObject (No Id) without issuing DML
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
     **/
    public OpportunityLineItem buildNew() {
        return (OpportunityLineItem)build(true);
    }

    /**
     * @description Persists builder and its related data through Unit Of Work
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
     **/
    public OpportunityLineItem persist(fflib_ISObjectUnitOfWork uow) {
        return (OpportunityLineItem)persistBuilder(uow);
    }

    /**
     * @description Persists builder and its related data using default unit of work
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
     **/
    public OpportunityLineItem persist() {
        return persist(createUnitOfWork());
    }              

    /**
     * @description Registers instance for persistance via persistBuilders
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
     **/
    public OpportunityLineItem_t register() {
        return (OpportunityLineItem_t)registerBuilder();
    }

    /**
     * @description Returns Contact SObject associated to this builder
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
     **/
    public OpportunityLineItem Record {
        get { return (OpportunityLineItem)getRecord(); }
        private set;
    }

    /**
     * @description Returns a Clone of this instance
     **/
    public OpportunityLineItem_t but() {
        return new OpportunityLineItem_t(this);
    }

    /**
     * Methods/Properties above would be included in a basic template for any derived builder class
     * 
     * END STANDARD BUILDER TEMPLATE
     * -------------------------------
     **/

    /**
     * @description Object Mother method for an Empty Opportunity Line Item
     **/
    public static OpportunityLineItem_t anOpportunityLineItem() {
        return new OpportunityLineItem_t();
    }     

    /**
     * @description Remaining methods are SObject specific and support fluent configuration of field values
     **/
    public OpportunityLineItem_t withQuantity(Decimal value) {
        set(OpportunityLineItem.Quantity, value);
        return this;
    }

    public OpportunityLineItem_t withTotalPrice(Decimal value) {
        set(OpportunityLineItem.TotalPrice, value);
        return this;
    }

    public OpportunityLineItem_t withPriceBookEntry(PriceBookEntry_t value) {
        setParent(OpportunityLineItem.PriceBookEntryId, value);
        return this;
    }

    public OpportunityLineItem_t withOpportunity(Opportunity_t value) {
        setParent(OpportunityLineItem.OpportunityId, value);
        return this;
    }
}