public abstract class Domain_t extends fflib_DomainObjectBuilder
{
	/**
	 * @description Constructs the Builder class with the specified SObjectType
	 *
	 * @param type The SObject type that the builder will build
	 **/	
    protected Domain_t(SObjectType type) {
    	super(type);
    }

	/**
	 * @description Copy Constructor that constructs the Builder class based on the builder specified
	 *
	 * @param copyFrom The builder to copy/clone this instance from
	 **/
	protected Domain_t(Domain_t copyFrom) {
		super(copyFrom);
	}

	/**
	 * Helper method to obtain the default Unit Of Work for use with persist methods
	 **/
	protected virtual fflib_ISObjectUnitOfWork createUnitOfWork()
	{
		return Application.UnitOfWork.newInstance();
	}
}