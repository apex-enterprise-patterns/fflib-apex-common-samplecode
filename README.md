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

- **Metadata-driven factory**—The `Application` class and its factories (Selector, Domain, UnitOfWork, Service) are configured via Custom Metadata (`Application__mdt`) instead of hardcoded mappings, enabling configuration without code changes.
- **CRUD/FLS and user mode**—The sample can be configured to use fflib user mode for selectors and UnitOfWork where appropriate.
- **Dependency injection**—Uses `Application.Selector.setMock()`, `Application.Domain.setMock()`, `Application.UnitOfWork.setMock()`, and `Application.Service.setMock()` for testability.

A detailed comparison by area:

| Area | Original | Alternative (this branch) |
|------|----------|---------------------------|
| **Factory pattern** | Uses `fflib_Application` with code-configured factories | Uses `fflib_Application` with Custom Metadata (`Application__mdt`) for Selector, Domain, UnitOfWork, and Service configuration |
| **Interfaces** | Domain, selector, and service classes implement interfaces | Same; interfaces retained (e.g. IOpportunities, IAccountsSelector, IOpportunitiesService) |
| **Service layer** | Interface + Impl pattern | Same (e.g. OpportunitiesServiceImpl, InvoicingServiceImpl) |
| **Configuration** | Static code in Application.cls initializer | Driven by `Application__mdt` records |

Application Enterprise Patterns on Salesforce Lightning Platform
================================================================

Design patterns are an invaluable tool for developers and architects looking to build enterprise solutions. Here are presented some tried and tested enterprise application engineering patterns that have been used in other platforms and languages. We will discuss and illustrate how patterns such as Data Mapper, Service Layer, Unit of Work and of course Model View Controller can be applied to Force.com. Applying these patterns can help manage governed resources (such as DML) better, encourage better separation-of-concerns in your logic and enforce Force.com coding best practices.

More Information on Trailhead
--------------------------------------------

There are two Trailhead Modules for Apex Enterprise Patterns:

- [Apex Enterprise Patterns - Service Layer](https://trailhead.salesforce.com/en/content/learn/modules/apex_patterns_sl)
    - [Separation of Concerns](https://trailhead.salesforce.com/en/content/learn/modules/apex_patterns_sl/apex_patterns_sl_soc)
- [Apex Enterprise Patterns - Domain and Selector Layer](https://trailhead.salesforce.com/en/content/learn/modules/apex_patterns_dsl)
