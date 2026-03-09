FFLib Apex Common Sample
=====================================
![Push Source and Run Apex Tests](https://github.com/apex-enterprise-patterns/fflib-apex-common-samplecode/workflows/Create%20a%20Scratch%20Org,%20Push%20Source%20and%20Run%20Apex%20Tests/badge.svg)

**Dependencies:** Must deploy [Apex Mocks](https://github.com/apex-enterprise-patterns/fflib-apex-mocks) and [Apex Common](https://github.com/apex-enterprise-patterns/fflib-apex-common) before deploying this library

| Library | Deploy |
|---------|--------|
| Apex Mocks | <a href="https://githubsfdeploy.herokuapp.com?owner=apex-enterprise-patterns&repo=fflib-apex-mocks"><img alt="Deploy to Salesforce" src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png"></a> |
| Apex Common | <a href="https://githubsfdeploy.herokuapp.com?owner=apex-enterprise-patterns&repo=fflib-apex-common"><img alt="Deploy to Salesforce" src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png"></a> |
| Apex Common Sample Code | <a href="https://githubsfdeploy.herokuapp.com?owner=apex-enterprise-patterns&repo=fflib-apex-common-samplecode"><img alt="Deploy to Salesforce" src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png"></a> |

Sample Application
==================

This repository contains a sample application illustrating the Apex Enterprise Patterns library. The aim is to illustrate a fully working sample application that demonstrates the patterns.

**NOTE:** The supporting **Apex Common** library can be found [here](https://github.com/apex-enterprise-patterns/fflib-apex-common).

| Platform Feature | Patterns Used |
|------------------|---------------|
| Custom Buttons | Building **UI** logic and calling **Service Layer** code from Controllers |
| Batch Apex | Reusing **Service** and **Selector Layer** code from within a Batch context |
| Integration API | Exposing an Integration API via **Service Layer** using Apex and REST |
| Apex Triggers | Factoring your Apex Trigger logic via the **Domain Layer** (wrappers) |

Differences from Original Sample
-------------------------

This alternative diverges from the original sample in the following ways:

- **Simplified design**—Removes the `Application` central class and interface-based pattern in response to feedback about overhead and complexity. That design was mainly for mocking via interfaces; now that Apex supports mocking concrete classes, the sample can be simplified.
- **CRUD/FLS and user mode**—The previous sample relied on fflib defaults (Selector: LEGACY data access with object-level CRUD assertion; UoW: SimpleDML / system-mode DML); the preference now is to enable fflib user mode.
- **Dependency injection**—Can be done in many ways (factories, constructor injection, or direct methods); this sample uses the simplest approach that works when mocking specific services, domains, and selectors.

A detailed comparison by area:

| Area | Original | Alternative |
|------|----------|-------------|
| **Factory pattern** | Uses `fflib_Application` (`Application.UnitOfWork`, `Application.Domain`, `Application.Selector`, `Application.Service`) | Largely removed; uses `newInstance()` and mock property setting. `DomainRegistry` is an example implementation to support the polymorphic domain pattern (e.g. `InvoicingService` resolving domains via Custom Metadata) |
| **Interfaces** | Domain, selector, and service classes implement interfaces (e.g. IOpportunities, IAccountsSelector) | No interfaces; concrete classes used directly, leveraging Apex mocking support for concrete classes |
| **Service layer** | Interface + Impl pattern (e.g. OpportunitiesServiceImpl, AccountsServiceImpl) | Single concrete service classes (OpportunitiesService, AccountsService) |
| **USER_MODE / FLS** | System mode (no USER_MODE enforcement) | Selectors use `setDataAccess(USER_MODE)`; DomainRegistry query uses `WITH USER_MODE`; UnitOfWork uses `UserModeDML()` |
| **Test setup** | No runAs; tests run as system user | `TestDataFactory` creates Standard User with `ApexEnterprisePatternsSampleApp` permission set; DML tests use `System.runAs()` |
| **Permission set** | None | `ApexEnterprisePatternsSampleApp` grants field-level access for USER_MODE tests |
| **OpportunityConsoleController** | Has `@RemoteAction applyDiscount` | Removed; VF Remoting is outdated technology and no longer relevant |

Application Enterprise Patterns on Salesforce Lightning Platform
================================================================

Design patterns are an invaluable tool for developers and architects looking to build enterprise solutions. Here are presented some tried and tested enterprise application engineering patterns that have been used in other platforms and languages. We will discuss and illustrate how patterns such as Data Mapper, Service Layer, Unit of Work and of course Model View Controller can be applied to Force.com. Applying these patterns can help manage governed resources (such as DML) better, encourage better separation-of-concerns in your logic and enforce Force.com coding best practices.

More Information on Trailhead
--------------------------------------------

There are two Trailhead Modules for Apex Enterprise Patterns:

- [Apex Enterprise Patterns - Service Layer](https://trailhead.salesforce.com/en/content/learn/modules/apex_patterns_sl)
    - [Separation of Concerns](https://trailhead.salesforce.com/en/content/learn/modules/apex_patterns_sl/apex_patterns_sl_soc)
- [Apex Enterprise Patterns - Domain and Selector Layer](https://trailhead.salesforce.com/en/content/learn/modules/apex_patterns_dsl)

