/**
 * Copyright (c) 2013-2015, FinancialForce.com, inc
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

@IsTest
private class ProductsSelectorTest
{
	@TestSetup
	static void setup()
	{
		TestDataFactory.createUserWithSampleAppPermissions();
	}

	@IsTest
	private static void selectByIdReturnsExpectedFields()
	{
		// Given
		Product2 product = new Product2(Description = 'Something cool', Name = 'CoolItem', IsActive = true, SubscriberField__c = 'My Text Field');
		insert product;

		// When
		System.runAs(TestDataFactory.getRunAsUser())
		{
			List<Product2> products = ProductsSelector.newInstance(true).selectById(new Set<Id> { product.Id });

			// Then
			System.assertEquals('Something cool', products[0].Description, 'Description should match');
			System.assertEquals('CoolItem', products[0].Name, 'Name should match');
			System.assertEquals(true, products[0].IsActive, 'IsActive should be true');
			System.assertEquals('My Text Field', products[0].SubscriberField__c, 'SubscriberField should match');
		}
	}

	@IsTest
	private static void queryLocatorByIdReturnsExpectedFields()
	{
		// Given
		Product2 product = new Product2(Description = 'Something cool', Name = 'CoolItem', IsActive = true, SubscriberField__c = 'My Text Field');
		insert product;

		// When
		System.runAs(TestDataFactory.getRunAsUser())
		{
			Database.QueryLocator queryLocator = ProductsSelector.newInstance(true).queryLocatorById(new Set<Id> { product.Id });
			Database.QueryLocatorIterator productsIterator = queryLocator.iterator();
			Product2 queriedProduct = (Product2) productsIterator.next();

			// Then
			System.assertEquals('Something cool', queriedProduct.Description, 'Description should match');
			System.assertEquals('CoolItem', queriedProduct.Name, 'Name should match');
			System.assertEquals(true, queriedProduct.IsActive, 'IsActive should be true');
			System.assertEquals('My Text Field', queriedProduct.SubscriberField__c, 'SubscriberField should match');
		}
	}
}
