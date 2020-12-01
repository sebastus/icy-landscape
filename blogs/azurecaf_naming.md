---
title: Standardize resource names in Terraform scripts
published: false
description: Use a tool to generate Azure resource names in your Terraform script - how and why.
tags: azure,tooling,devops,cloud
series: DevCrewLever-Fall2020
//cover_image: https://direct_url_to_image.jpg
---

When starting a Terraform project for an Azure architecture, it's easy to come up with useful names for the resources in your architecture. They usually look like "my-resource-group', "my-public-ip", "my-vm", "mystorageaccount", and so on. When the architecture grows, or elements of it scale out, it becomes harder to design useful names that meet all requirements. This blog is about a tool that helps with this task.  

What are some of the requirements that must be met?

* for each resource type, rules vary
  * length
  * accepted characters
  * accepted patterns (e.g. first character must be a lowercase alpha)
* It must be possible to override generated names in special cases
* It must be possible to generate globally unique names
* Generated names must behave like any other resource stored in tfstate
  * names persist across 'terraform apply' runs as long as name resource definition remains static
  * name resources can be destroyed, tainted, etc just like any other terraform resource

What are some of the nice-to-have requirements?  

* a generated name should conform to a regular pattern that becomes familiar and instantly recognizable
* when there are many resources in list, it should be possible to instantly recognize resource types from the name
* clear and concise name generation code
* when an architecture grows or resources scale out horizontally, name generation follows naturally
* when testing permutations of resource properties, generating names is a very powerful enabling technique
