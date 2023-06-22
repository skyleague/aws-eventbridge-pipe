# SkyLeague `aws-eventbridge-pipe` - easy AWS EventBridge pipe deployment with Terraform

[![tfsec](https://github.com/skyleague/aws-eventbridge-pipe/actions/workflows/tfsec.yml/badge.svg?branch=main)](https://github.com/skyleague/aws-eventbridge-pipe/actions/workflows/tfsec.yml)

This module simplifies the deployment of AWS Eventbridge Pipes using Terraform, as well as simplifying the adoption of the [Principle of Least Privilege](https://aws.amazon.com/blogs/security/techniques-for-writing-least-privilege-iam-policies/). When using this module, there is no need to attach AWS Managed Policies for basic functionality (sources, targets). The Principle of Least Privilege is achieved by letting this module create a separate role for each pipe. This role is granted the bare minimum set of permissions to match the configuration provided to this module. For example, `sqs` permissions are automatically granted if (and only if) source type is "sqs". Similar (dynamic) permissions are provided for other inputs (see [`iam.tf`](./iam.tf) for all dynamic permissions).

## Version

Currently, We are utilizing the AWS Cloud Control (awscc) version of the resouces
because the stable version (aws) does not allow for the use of parameters.
However, to expedite the implementation of parameter support,
We encourage you to contribute by voting on this pull request (PR).
By doing so, we can facilitate its inclusion in the stable version of aws sooner.
[https://github.com/hashicorp/terraform-provider-aws/pull](https://github.com/hashicorp/terraform-provider-aws/pull/31607#issue-1728257255)

## Usage

```terraform
module "this" {
  source = "git@github.com:skyleague/aws-eventbridge-pipe.git?ref=v1.0.0"

  pipe_name = "hello-world"
  source_settings = {
    type = "sqs"
    arn  = "arn:aws:sqs:"

    sqs = {
      sqs_queue_parameters = {
        batch_size = 1
      }
    }

    filters = [{ pattern = "{ \"body\": { \"id\": [\"123\"] } }" }]

  }
  enrichment_settings = {
    arn            = "arn:aws:lambda: ..."
    input_template = "{\"id\": \"<$.body.id>\"}"

  }

  target_settings = {
    arn            = "arn:aws:lambda: ..."
    input_template = "{\"id\": \"<$.body.id>\"}"
  }
}
```

## Options

For a complete reference of all variables, have a look at the descriptions in [`variables.tf`](./variables.tf).

## Future additions

This is the initial release of the module, with a very minimal set of standardized functionality. We plan on standardizing more integrations, so feel free to leave suggestions!

## Support

SkyLeague provides Enterprise Support on this open-source library package at clients across industries. Please get in touch via [`https://skyleague.io`](https://skyleague.io).

If you are not under Enterprise Support, feel free to raise an issue and we'll take a look at it on a best-effort basis!

## License & Copyright

This library is licensed under the MIT License (see [LICENSE.md](./LICENSE.md) for details).

If you using this SDK without Enterprise Support, please note this (partial) MIT license clause:

> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND

Copyright (c) 2023, SkyLeague Technologies B.V..
'SkyLeague' and the astronaut logo are trademarks of SkyLeague Technologies, registered at Chamber of Commerce in The Netherlands under number 86650564.

All product names, logos, brands, trademarks and registered trademarks are property of their respective owners. All company, product and service names used in this website are for identification purposes only. Use of these names, trademarks and brands does not imply endorsement.
