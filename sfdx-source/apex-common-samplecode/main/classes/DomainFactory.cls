/**
 * File Name: DomainFactory 
 * Description: 
 *
 * @author: architect ir. Wilhelmus G.J. Velzeboer | wvelzebo@its.jnj.com 
 */
public with sharing class DomainFactory
		extends fflib_Application.DomainFactory
{
	public DomainFactory(fflib_Application.SelectorFactory selectorFactory, Map<Object, Type> constructorTypeByObject)
	{
		super(selectorFactory, constructorTypeByObject);
	}

	public DomainFactory(fflib_Application.SelectorFactory selectorFactory, Map<SObjectType, Type> sObjectByDomainConstructorType)
	{
		super(selectorFactory, sObjectByDomainConstructorType);
	}

	public static IAccounts newInstance(List<Account> recordList)
	{
		return (IAccounts) Application.Domain.newInstance(recordList);
	}

	public static IAccounts newInstance(Set<Id> recordIdSet)
	{
		return (IAccounts) Application.Domain.newInstance(recordIdSet);
	}


}