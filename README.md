FFLib Apex Common Sample
=====================================
![Push Source and Run Apex Tests](https://github.com/apex-enterprise-patterns/fflib-apex-common-samplecode/workflows/Create%20a%20Scratch%20Org,%20Push%20Source%20and%20Run%20Apex%20Tests/badge.svg)

**Dependencies:** Deploy [Apex Mocks](https://github.com/apex-enterprise-patterns/fflib-apex-mocks) and [Apex Common](https://github.com/apex-enterprise-patterns/fflib-apex-common) before deploying this sample.

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
| Lightning Web Components & Quick Actions | **UI** logic in `@AuraEnabled` controllers calling **Service Layer** code |
| Visualforce (list views) | Bulk **UI** actions via `StandardSetController` pages |
| Batch Apex | Reusing **Service** and **Selector Layer** code from within a Batch context |
| Integration API | Exposing an Integration API via **Service Layer** using Apex REST |
| Apex Triggers | **Domain Layer** trigger handlers (`fflib_SObjectDomain`) separate from **Domain Layer** service behaviour (`fflib_SObjects`) |
| Invocable Apex & Agentforce | **Service Layer** exposed to Agentforce via invocable actions and an AI authoring bundle |
| Polymorphic invoicing | **Custom Metadata** (`InvoiceTargets__mdt`) drives invoicing across Opportunity, DeveloperWorkItem, and TrainingWorkItem |

Architecture Notes
------------------

This sample uses **concrete** Domain, Selector, and Service classes with static `newInstance()` factories and `@TestVisible` mock hooks for unit tests. There is no `Application.cls` dependency-injection factory — see [Apex Enterprise Patterns: Recent Updates and Thoughts on the Application Class](https://andyinthecloud.com/2026/04/13/apex-enterprise-patterns-recent-updates-and-thoughts-on-the-application-class/) for background on this approach.

| Component | Role |
|-----------|------|
| **Services** | `OpportunitiesService`, `InvoicingService`, `AccountsService` — orchestrate selectors, domains, and Unit of Work |
| **Domains** | Business logic on records (e.g. discounting, invoice DTO generation) |
| **Trigger handlers** | `fflib_SObjectDomain` subclasses wired from triggers |
| **UnitOfWork** | `UnitOfWork.cls` — thin factory returning `fflib_SObjectUnitOfWork` with `UserModeDML()` |
| **InvoicingTargetsRegistry** | Resolves invoice targets from `InvoiceTargets__mdt` at runtime |

User Mode and CRUD/FLS
----------------------

This sample targets **API 67.0 and above**, where Apex runs in **user mode by default** at the platform level. That aligns with enforcing CRUD/FLS in production without relying on implicit system-mode behaviour.

When the codebase runs on **API 66 or below** (where system mode is still the platform default), fflib and this sample **still enforce user mode explicitly** through the patterns below — selectors, Unit of Work, and tests do not depend on the platform default alone.

Selectors pass `fflib_SObjectSelector.DataAccess.USER_MODE` into the `super(...)` constructor for FLS on queries. DML runs through `UnitOfWork.newInstance()`, which uses `UserModeDML()`.

Tests that exercise USER_MODE code use `TestDataFactory` to create a Standard User with the `ApexEnterprisePatternsSampleApp` permission set, then run under `System.runAs(getRunAsUser())`. **Setup, DML, queries, and assertions** that touch FLS-protected fields must all run inside that `runAs` block. Data setup requiring elevated permissions (e.g. `PricebookEntry` insert) may run in system context before `runAs`.

| Area | Approach |
|------|----------|
| **Selectors** | `super(false, fflib_SObjectSelector.DataAccess.USER_MODE)` in selector constructors (and `includeFieldSetFields` overload where present) |
| **UnitOfWork** | `UnitOfWork.cls` factory; uses `UserModeDML()` |
| **Tests** | `TestDataFactory`; `@TestSetup` + `System.runAs(getRunAsUser())` for USER_MODE tests |
| **Permission set** | `ApexEnterprisePatternsSampleApp` grants field-level access for USER_MODE tests |

Local Development
-----------------

**API version:** 67.0 and above (`sfdx-project.json`). API 67 introduced user mode as the Apex default; this sample is written for that baseline and remains compatible with later API versions.

**Scratch org:** `config/project-scratch-def.json` enables Agentforce/Einstein (`Einstein1AIPlatform` feature) for deploying the AI authoring bundle and invocable actions. Your Dev Hub must support these features.

Deploy in order:

```bash
# 1. Create scratch org
sf org create scratch --definition-file config/project-scratch-def.json --alias fflib-sample-scratch --set-default

# 2. Deploy dependencies
git clone https://github.com/apex-enterprise-patterns/fflib-apex-mocks.git temp/fflib-apex-mocks
git clone https://github.com/apex-enterprise-patterns/fflib-apex-common.git temp/fflib-apex-common
sf project deploy start --source-dir temp/fflib-apex-mocks --target-org fflib-sample-scratch
sf project deploy start --source-dir temp/fflib-apex-common --target-org fflib-sample-scratch

# 3. Deploy this sample
sf project deploy start --target-org fflib-sample-scratch

# 4. Run tests
sf apex run test --target-org fflib-sample-scratch --wait 10
```

Assign `ApexEnterprisePatternsSampleApp` to users who need access to the sample app's custom fields and tabs. Tests assign this permission set automatically via `TestDataFactory`; manual assignment is not required to run Apex tests.

Application Enterprise Patterns on Salesforce Lightning Platform
================================================================

Design patterns are an invaluable tool for developers and architects looking to build enterprise solutions. Here are presented some tried and tested enterprise application engineering patterns that have been used in other platforms and languages. We will discuss and illustrate how patterns such as Data Mapper, Service Layer, Unit of Work and of course Model View Controller can be applied to Force.com. Applying these patterns can help manage governed resources (such as DML) better, encourage better separation-of-concerns in your logic and enforce Force.com coding best practices.

More Information on Trailhead
--------------------------------------------

Trailhead modules for Apex Enterprise Patterns:

- [Apex Enterprise Patterns - Separation of Concerns](https://trailhead.salesforce.com/en/content/learn/modules/apex_patterns_sl/apex_patterns_sl_soc)
- [Apex Enterprise Patterns - Service Layer](https://trailhead.salesforce.com/en/content/learn/modules/apex_patterns_sl)
- [Apex Enterprise Patterns - Domain and Selector Layer](https://trailhead.salesforce.com/en/content/learn/modules/apex_patterns_dsl)
