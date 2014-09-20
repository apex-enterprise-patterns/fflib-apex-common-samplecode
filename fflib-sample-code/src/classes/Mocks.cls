/*
* FinancialForce.com, inc. claims copyright in this software, its screen
* display designs and supporting documentation. FinancialForce and
* FinancialForce.com are trademarks of FinancialForce.com, inc. Any
* unauthorized use, copying or sale of the above may constitute an
* infringement of copyright and may result in criminal or other legal
* proceedings.
*
* Copyright (c) FinancialForce.com, inc. All rights reserved.
*/

@IsTest
public class Mocks 
{
	public class OpportunitiesService 
		implements IOpportunitiesService
	{
		private fflib_ApexMocks mocks;

		public OpportunitiesService(fflib_ApexMocks mocks)
		{
			this.mocks = mocks;
		}

		public void applyDiscounts(Set<ID> opportunityIds, Decimal discountPercentage)
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'applyDiscounts', new List<Object> {opportunityIds, discountPercentage});
			}
			else
			{
				mocks.recordMethod(this, 'applyDiscounts', new List<Object> {opportunityIds, discountPercentage});
			}			
		}

		public Set<Id> createInvoices(Set<ID> opportunityIds, Decimal discountPercentage)
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'createInvoices', new List<Object> {opportunityIds, discountPercentage});
			}
			else if (mocks.Stubbing)
			{
				mocks.prepareMethodReturnValue(this, 'createInvoices', new List<Object> {opportunityIds, discountPercentage});
				return null;
			}
			else
			{
				mocks.recordMethod(this, 'createInvoices', new List<Object> {opportunityIds, discountPercentage});

				fflib_MethodReturnValue methodReturnValue = mocks.getMethodReturnValue(this, 'createInvoices', new List<Object> {opportunityIds, discountPercentage});

				if (methodReturnValue != null)
				{
					if (methodReturnValue.ReturnValue instanceof Exception)
					{
						throw ((Exception) methodReturnValue.ReturnValue);
					}

					return (Set<Id>) methodReturnValue.ReturnValue;
				}
			}
			return null;
		}		
		
		public Id submitInvoicingJob()
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'submitInvoicingJob', new List<Object> { });
			}
			else if (mocks.Stubbing)
			{
				mocks.prepareMethodReturnValue(this, 'submitInvoicingJob', new List<Object> { });
				return null;
			}			
			else
			{
				mocks.recordMethod(this, 'submitInvoicingJob', new List<Object> { });
				
				fflib_MethodReturnValue methodReturnValue = mocks.getMethodReturnValue(this, 'submitInvoicingJob', new List<Object> { });

				if (methodReturnValue != null)
				{
					if (methodReturnValue.ReturnValue instanceof Exception)
					{
						throw ((Exception) methodReturnValue.ReturnValue);
					}

					return (Id) methodReturnValue.ReturnValue;
				}				
			}	
			return null;					
		}
	}

	public class Opportunities extends fflib_SObjectMocks.SObjectDomain
		implements IOpportunities
	{
		private fflib_ApexMocks mocks;

		public Opportunities(fflib_ApexMocks mocks)
		{
			super(mocks);
			this.mocks = mocks;
		}

		public void applyDiscount(Decimal discountPercentage, fflib_ISObjectUnitOfWork uow)
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'applyDiscount', new List<Object> {discountPercentage, uow});
			}
			else
			{
				mocks.recordMethod(this, 'applyDiscount', new List<Object> {discountPercentage, uow});
			}
		}
	}

	public class OpportunitiesSelector extends fflib_SObjectMocks.SObjectSelector
		implements IOpportunitiesSelector
	{
		private fflib_ApexMocks mocks;

		public OpportunitiesSelector(fflib_ApexMocks mocks)
		{
			super(mocks);
			this.mocks = mocks;
		}

		public List<Opportunity> selectByIdWithProducts(Set<ID> idSet)
		{
			if (mocks.Verifying)
			{
				mocks.verifyMethodCall(this, 'selectByIdWithProducts', new List<Object> {idSet});
			}
			else if (mocks.Stubbing)
			{
				mocks.prepareMethodReturnValue(this, 'selectByIdWithProducts', new List<Object> {idSet});
				return null;
			}
			else
			{
				mocks.recordMethod(this, 'selectByIdWithProducts', new List<Object> {idSet});

				fflib_MethodReturnValue methodReturnValue = mocks.getMethodReturnValue(this, 'selectByIdWithProducts', new List<Object> {idSet});

				if (methodReturnValue != null)
				{
					if (methodReturnValue.ReturnValue instanceof Exception)
					{
						throw ((Exception) methodReturnValue.ReturnValue);
					}

					return (List<Opportunity>) methodReturnValue.ReturnValue;
				}
			}

			return null;
		}
	}
}