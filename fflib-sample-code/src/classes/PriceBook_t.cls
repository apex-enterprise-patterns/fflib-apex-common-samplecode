public class PriceBook_t extends Domain_t {
	/**
	 * Methods/Properties below would be included in a basic template for any derived builder class
	 * 
	 * BEGIN STANDARD BUILDER TEMPLATE
	 * -------------------------------
	 **/

    /**
     * @description Default constructor
     **/		
	private PriceBook_t() {
		super(Pricebook2.SObjectType);
	}

    /**
     * @description Copy Constructor that constructs the Builder class based on the builder specified
     *
     * @param copyFrom The builder to copy/clone this instance from
     **/	
	private PriceBook_t(PriceBook_t copyFrom) {
		super(copyFrom);
	}			

    /**
     * @description Creates an existing SObject without issuing DML
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Pricebook2 build() {
    	return (Pricebook2)build(false);
    }

    /**
     * @description Creates an New SObject (No Id) without issuing DML
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Pricebook2 buildNew() {
    	return (Pricebook2)build(true);
    }

    /**
     * @description Persists builder and its related data through Unit Of Work
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Pricebook2 persist(fflib_ISObjectUnitOfWork uow) {
    	return (Pricebook2)persistBuilder(uow);
    }

    /**
     * @description Persists builder and its related data using default unit of work
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
     **/
    public Pricebook2 persist() {
        return persist(createUnitOfWork());
    }          

    /**
     * @description Registers instance for persistance via persistBuilders
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public PriceBook_t register() {
    	return (PriceBook_t)registerBuilder();
    }

    /**
     * @description Returns Contact SObject associated to this builder
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Pricebook2 Record {
    	get { return (Pricebook2)getRecord(); }
    	private set;
    }

    /**
     * @description Returns a Clone of this instance
	 **/
	public PriceBook_t but() {
		return new PriceBook_t(this);
	}	    

	/**
	 * Methods/Properties above would be included in a basic template for any derived builder class
	 * 
	 * END STANDARD BUILDER TEMPLATE
	 * -------------------------------
	 **/

    /**
     * @description Object Mother method for an Empty Price Book
	 **/
	public static PriceBook_t aPriceBook() {
		return new PriceBook_t();
	}
    /**
     * @description Remaining methods are SObject specific and support fluent configuration of field values
     **/
    public PriceBook_t withName(String value) {
    	set(Pricebook2.Name, value);
    	return this;
    }

    public PriceBook_t withIsActive(Boolean value) {
    	set(Pricebook2.IsActive, value);
    	return this;
    }
}