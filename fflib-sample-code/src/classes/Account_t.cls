public class Account_t extends Domain_t 
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
	private Account_t() {
		super(Account.SObjectType);
	}

    /**
     * @description Copy Constructor that constructs the Builder class based on the builder specified
     *
     * @param copyFrom The builder to copy/clone this instance from
     **/
	private Account_t(Account_t copyFrom) {
		super(copyFrom);
	}

    /**
     * @description Creates an existing SObject without issuing DML
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Account build() {
    	return (Account)build(false);
    }

    /**
     * @description Creates an New SObject (No Id) without issuing DML
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Account buildNew() {
    	return (Account)build(true);
    }

    /**
     * @description Persists builder and its related data through Unit Of Work
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Account persist(fflib_ISObjectUnitOfWork uow) {
    	return (Account)persistBuilder(uow);
    }

    /**
     * @description Persists builder and its related data using default unit of work
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
     **/
    public Account persist() {
        return persist(createUnitOfWork());
    }    

    /**
     * @description Registers instance for persistance via persistBuilders
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Account_t register() {
    	return (Account_t)registerBuilder();
    }		

    /**
     * @description Returns Contact SObject associated to this builder
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Account Record {
    	get { return (Account)getRecord(); }
    	private set;
    }	    

    /**
     * @description Returns a Clone of this instance
	 **/
	public Account_t but() {
		return new Account_t(this);
	}

	/**
	 * Methods/Properties above would be included in a basic template for any derived builder class
	 * 
	 * END STANDARD BUILDER TEMPLATE
	 * -------------------------------
	 **/

    /**
     * @description Object Mother method for an empty account
	 **/
	public static Account_t anAccount() {
		return new Account_t();
	}

    /**
     * @description Object Mother method for an Prospect account
	 **/
	public static Account_t aProspect() {
		return anAccount().withName('Potential Customer').withType('Prospect');
	}

    /**
     * @description Remaining methods are SObject specific and support fluent configuration of field values
     **/
	public Account_t withName(String value) {
		set(Account.Name, value);
		return this;
	}

	public Account_t withType(String value) {
		set(Account.Type, value);
		return this;
	}

    public Account_t withDescription(String value) {
        set(Account.Description, value);
        return this;
    }    
}