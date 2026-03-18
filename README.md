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

User Mode and CRUD/FLS
----------------------

This sample enforces field-level security (FLS) by using fflib user mode throughout. Selectors use `setDataAccess(USER_MODE)` for FLS on queries; the UnitOfWork uses `UserModeDML()` via an inner `UserModeUnitOfWorkFactory` in `Application.cls` for FLS on DML. Tests that exercise USER_MODE code use `TestDataFactory` to create a Standard User with the `ApexEnterprisePatternsSampleApp` permission set, then run under `System.runAs(getRunAsUser())`; data setup requiring elevated permissions (e.g. PricebookEntry insert) runs in system context.

| Area | Approach |
|------|----------|
| **Selectors** | `super(false); setDataAccess(USER_MODE)` in all selector constructors |
| **UnitOfWork** | Inner `UserModeUnitOfWorkFactory` in Application.cls; uses `UserModeDML()` |
| **Tests** | `TestDataFactory`; `@TestSetup` + `System.runAs(getRunAsUser())` for DML/selector tests |
| **Permission set** | `ApexEnterprisePatternsSampleApp` grants field-level access for USER_MODE tests |

Application Enterprise Patterns on Salesforce Lightning Platform
================================================================

Design patterns are an invaluable tool for developers and architects looking to build enterprise solutions. Here are presented some tried and tested enterprise application engineering patterns that have been used in other platforms and languages. We will discuss and illustrate how patterns such as Data Mapper, Service Layer, Unit of Work and of course Model View Controller can be applied to Force.com. Applying these patterns can help manage governed resources (such as DML) better, encourage better separation-of-concerns in your logic and enforce Force.com coding best practices.

More Information on Trailhead
--------------------------------------------

There are two Trailhead Modules for Apex Enterprise Patterns:

- [Apex Enterprise Patterns - Service Layer](https://trailhead.salesforce.com/en/content/learn/modules/apex_patterns_sl)
    - [Separation of Concerns](https://trailhead.salesforce.com/en/content/learn/modules/apex_patterns_sl/apex_patterns_sl_soc)
- [Apex Enterprise Patterns - Domain and Selector Layer](https://trailhead.salesforce.com/en/content/learn/modules/apex_patterns_dsl)

