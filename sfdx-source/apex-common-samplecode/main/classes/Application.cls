/**
 * Copyright (c) 2014-2016, FinancialForce.com, Inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution. 
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public class Application {
	public static final fflib_Application.SelectorFactory Selector;
	public static final fflib_Application.DomainFactory Domain;
	public static final fflib_Application.UnitOfWorkFactory UnitOfWork;
	public static final fflib_Application.ServiceFactory Service;

	static {
		Map<SObjectType, Type> selectorTypeBySObject = new Map<SObjectType, Type>();
		Map<SObjectType, Type> constructorTypeBySObject = new Map<SObjectType, Type>();
		List<SObjectType> unitOfWorkTypes = new List<SObjectType>();
		Map<Type, Type> implByInterface = new Map<Type, Type>();
		for (Application__mdt m : [
			SELECT FactoryType__c, SObjectType__c, KeyClass__c, ValueClass__c, Order__c
			FROM Application__mdt
			WITH SYSTEM_MODE
			ORDER BY FactoryType__c, Order__c ASC NULLS LAST
		]) {
			SObjectType sType = Schema.getGlobalDescribe().get(m.SObjectType__c);
			Type keyType = Type.forName(m.KeyClass__c);
			Type valueType = Type.forName(m.ValueClass__c);
			switch on m.FactoryType__c {
				when 'Selector' {
					selectorTypeBySObject.put(sType, keyType);
				}
				when 'Domain' {
					constructorTypeBySObject.put(sType, keyType);
				}
				when 'UnitOfWork' {
					unitOfWorkTypes.add(sType);
				}
				when 'Service' {
					implByInterface.put(keyType, valueType);
				}
			}
		}
		Selector = new fflib_Application.SelectorFactory(selectorTypeBySObject);
		Domain = new fflib_Application.DomainFactory(Selector, constructorTypeBySObject);
		UnitOfWork = new UserModeUnitOfWorkFactory(unitOfWorkTypes);
		Service = new fflib_Application.ServiceFactory(implByInterface);
	}

	private class UserModeUnitOfWorkFactory extends fflib_Application.UnitOfWorkFactory {
		public UserModeUnitOfWorkFactory(List<SObjectType> objectTypes) { super(objectTypes); }
		public override fflib_ISObjectUnitOfWork newInstance() {
			if (m_mockUow != null) return m_mockUow;
			return new fflib_SObjectUnitOfWork(m_objectTypes, new fflib_SObjectUnitOfWork.UserModeDML());
		}
	}
}
