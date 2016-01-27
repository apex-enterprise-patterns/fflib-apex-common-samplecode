public class PriceBookEntry_t extends Domain_t 
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
    private PriceBookEntry_t() {
        super(PricebookEntry.SObjectType);
    }

    /**
     * @description Copy Constructor that constructs the Builder class based on the builder specified
     *
     * @param copyFrom The builder to copy/clone this instance from
    **/
    private PriceBookEntry_t(PriceBookEntry_t copyFrom) {
        super(copyFrom);
    }            

    /**
     * @description Creates an existing SObject without issuing DML
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
    **/
    public PricebookEntry build() {
        return (PricebookEntry)build(false);
    }

    /**
     * @description Creates an New SObject (No Id) without issuing DML
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
    **/
    public PricebookEntry buildNew() {
        return (PricebookEntry)build(true);
    }

    /**
     * @description Persists builder and its related data through Unit Of Work
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
    **/
    public PricebookEntry persist(fflib_ISObjectUnitOfWork uow) {
        return (PricebookEntry)persistBuilder(uow);
    }            

    /**
     * @description Persists builder and its related data using default unit of work
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
    **/
    public PricebookEntry persist() {
        return persist(createUnitOfWork());
    }

    /**
     * @description Registers instance for persistance via persistBuilders
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
    **/
    public PriceBookEntry_t register() {
        return (PriceBookEntry_t)registerBuilder();
    }

    /**
     * @description Returns Contact SObject associated to this builder
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
    **/
    public PricebookEntry Record {
        get { return (PricebookEntry)getRecord(); }
        private set;
    }

    /**
     * @description Returns a Clone of this instance
    **/
    public PriceBookEntry_t but() {
        return new PriceBookEntry_t(this);
    }

    /**
     * Methods/Properties above would be included in a basic template for any derived builder class
     * 
     * END STANDARD BUILDER TEMPLATE
     * -------------------------------
    **/

    /**
     * @description Object Mother method for an Empty Price Book Entry
    **/
    public static PriceBookEntry_t aPriceBookEntry() {
        return new PriceBookEntry_t();
    }

    /**
     * @description Object Mother method for Price Book Entry that uses the Standard Price Book
    **/
    public static PriceBookEntry_t aPriceBookEntryWithStandardPriceBook() {
        return aPriceBookEntry().withStandardPriceBook();
    }

    /**
     * @description Remaining methods are SObject specific and support fluent configuration of field values
    **/
    public PriceBookEntry_t withUnitPrice(Decimal value) {
        set(PricebookEntry.UnitPrice, value);
        return this;
    }

    public PriceBookEntry_t withIsActive(Boolean value) {
        set(PricebookEntry.IsActive, value);
        return this;
    }

    public PriceBookEntry_t withUseStandardPrice(Boolean value) {
        set(PriceBookEntry.UseStandardPrice, value);
        return this;
    }    

    public PriceBookEntry_t withStandardPriceBook() {
        set(PriceBookEntry.PriceBook2Id, Test.getStandardPricebookId());
        return this;
    }

    public PriceBookEntry_t withPriceBook(PriceBook_t value) {
        setParent(PriceBookEntry.PriceBook2Id, value);
        return this;
    }

    public PriceBookEntry_t withProduct(Product_t value) {
        setParent(PriceBookEntry.Product2Id, value);
        return this;
    }
}