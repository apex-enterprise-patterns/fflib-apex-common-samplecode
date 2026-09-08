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

/**
 * Selector for Product2 queries, optionally including OpportunityDiscount field set members.
 */
public virtual inherited sharing class ProductsSelector extends fflib_SObjectSelector
{
	/**
	 * Factory that returns a selector without field set fields.
	 * @return {@link ProductsSelector} instance.
	 */
	public static ProductsSelector newInstance()
	{
		return newInstance(false);
	}

	/**
	 * Factory that returns a selector with optional field set fields.
	 * @param includeFieldSetFields When true, OpportunityDiscount field set fields are included.
	 * @return {@link ProductsSelector} instance.
	 */
	public static ProductsSelector newInstance(Boolean includeFieldSetFields)
	{
		return new ProductsSelector(includeFieldSetFields);
	}

	/**
	 * Creates a selector that queries only the default product field list.
	 */
	public ProductsSelector()
	{
		this(false);
	}

	/**
	 * Creates a selector that optionally includes OpportunityDiscount field set fields.
	 * @param includeFieldSetFields When true, fields from Product2.FieldSets.OpportunityDiscount are added to the SELECT list.
	 */
	public ProductsSelector(Boolean includeFieldSetFields)
	{
		super(includeFieldSetFields==true, fflib_SObjectSelector.DataAccess.USER_MODE);
	}

	/**
	 * Fields included in default queries from this selector.
	 * @return Product2 Description, Id, IsActive, Name, ProductCode, and DiscountingApproved__c.
	 */
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>{
			Product2.Description,
			Product2.Id,
			Product2.IsActive,
			Product2.Name,
			Product2.ProductCode,
			Product2.DiscountingApproved__c
		};
	}

	/**
	 * SObject type this selector queries.
	 * @return {@code Product2.SObjectType}.
	 */
	public Schema.SObjectType getSObjectType()
	{
		return Product2.SObjectType;
	}

	/**
	 * Field sets optionally added when the selector is constructed with includeFieldSetFields.
	 * @return {@code Product2.FieldSets.OpportunityDiscount}.
	 */
	public override List<Schema.FieldSet> getSObjectFieldSetList()
	{
		return new List<Schema.FieldSet>{ SObjectType.Product2.FieldSets.OpportunityDiscount };
	}

	/**
	 * Selects Products by Id using the configured field list.
	 * @param idSet Product2 Ids to query. Empty set returns an empty list.
	 * @return Matching Product2 records; empty list when none match.
	 */
	public List<Product2> selectById(Set<Id> idSet)
	{
		return (List<Product2>) selectSObjectsById(idSet);
	}

	/**
	 * Returns a QueryLocator for Products by Id using the configured field list.
	 * @param idSet Product2 Ids to include in the locator.
	 * @return QueryLocator suitable for Batch Apex or large result sets.
	 */
	public override Database.QueryLocator queryLocatorById(Set<Id> idSet)
	{
		return Database.getQueryLocator(newQueryFactory().setCondition('Id IN :idSet').toSOQL());
	}
}
