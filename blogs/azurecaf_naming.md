---
title: Standardize resource names in Terraform scripts
published: false
description: Use a tool to generate Azure resource names in your Terraform script - how and why.
tags: azure,tooling,devops,cloud
series: DevCrewLever-Fall2020
//cover_image: https://direct_url_to_image.jpg
---

When starting a Terraform project for an Azure architecture, it's easy to come up with useful names for the resources in your architecture. They usually look like "my-resource-group', "my-public-ip", "my-vm", "mystorageaccount", and so on. When the architecture grows, or elements of it scale out, it becomes harder to design useful names that meet all requirements. This blog is about a tool that helps with this task.
