public class Opportunity_t extends Domain_t 
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
	private Opportunity_t() {
		super(Opportunity.SObjectType);
	}

	/**
	 * @description Copy Constructor that constructs the Builder class based on the builder specified
	 *
	 * @param copyFrom The builder to copy/clone this instance from
	 **/
	private Opportunity_t(Opportunity_t copyFrom) {
		super(copyFrom);
	}			

    /**
     * @description Creates an existing SObject without issuing DML
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Opportunity build() {
    	return (Opportunity)build(false);
    }

    /**
     * @description Creates an New SObject (No Id) without issuing DML
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/	
    public Opportunity buildNew() {
    	return (Opportunity)build(true);
    }

    /**
     * @description Persists builder and its related data through Unit Of Work
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Opportunity persist(fflib_ISObjectUnitOfWork uow) {
    	return (Opportunity)persistBuilder(uow);
    }	    

    /**
     * @description Persists builder and its related data using default unit of work
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
     **/
    public Opportunity persist() {
        return persist(createUnitOfWork());
    }

    /**
     * @description Registers instance for persistance via persistBuilders
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Opportunity_t register() {
    	return (Opportunity_t)registerBuilder();
    }

    /**
     * @description Returns Contact SObject associated to this builder
     *              
     * @remarks Wrapper method to base class to allow for casting of specific SObjectType
	 **/
    public Opportunity Record {
    	get { return (Opportunity)getRecord(); }
    	private set;
    }

    /**
     * @description Returns a Clone of this instance
	 **/
	public Opportunity_t but() {
		return new Opportunity_t(this);
	}

	/**
	 * Methods/Properties above would be included in a basic template for any derived builder class
	 * 
	 * END STANDARD BUILDER TEMPLATE
	 * -------------------------------
	 **/

    /**
     * @description Object Mother method for an Empty Opportunity
	 **/
	public static Opportunity_t anOpportunity() {
		return new Opportunity_t();
	}

    /**
     * @description Object Mother method for a Closed Won Opportunity
	 **/
	public static Opportunity_t aClosedWonOpportunity() {
		return anOpportunity()
					.withName('Large Purchase')
					.withAccount(Account_t.aProspect())
					.withAmount(1000000.00)
					.withStageName('Closed Won')
					.withType('New Customer')
					.withCloseDate(System.today());
	}

    /**
     * @description Object Mother method for an Open Opportunity
	 **/
	public static Opportunity_t anOpenOpportunity() {
		return anOpportunity()
					.withName('Open Opportunity')
					.withStageName('Open')
					.withCloseDate(System.today());
	}

	/**
	 * Object Mother method for an Existing Account Opportunity with an Existing Account
	 **/
	public static Opportunity_t anOpportunityWithExistingAccount()
	{
			return anOpportunity()
					.withName('Test')
					.withType('Existing Account')
					.withAccount(Account_t.anAccount().withName('Test Account'));
	}

    /**
     * @description Remaining methods are SObject specific and support fluent configuration of field values
     **/
    public Opportunity_t withAccount(Account_t value) {
    	setParent(Opportunity.AccountId, value);
    	return this;
    }

	public Opportunity_t withName(String value) {
		set(Opportunity.Name, value);
		return this;
	}

	public Opportunity_t withAmount(Decimal value) {
		set(Opportunity.Amount, value);
		return this;
	}

	public Opportunity_t withStageName(String value) {
		set(Opportunity.StageName, value);
		return this;
	}

	public Opportunity_t withCloseDate(Date value) {
		set(Opportunity.CloseDate, value);
		return this;
	}

	public Opportunity_t withType(String value) {
		set(Opportunity.Type, value);
		return this;
	}
}