terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.25.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = var.starter.access_key
  secret_key = var.starter.secret_key
}

### create a VPC for the PoC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc.cidr_block
}

### Define a subnet inside of the VPC
resource "aws_subnet" "pocnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.pocnet.cidr_block
  depends_on = [
    aws_vpc.vpc
  ]
}

### Create a group of rules to be used in the PoC firewall
resource "aws_networkfirewall_rule_group" "fw_rg" {
  capacity = var.fw_rg.capacity
  name     = var.fw_rg.name
  type     = var.fw_rg.type
  rule_group {
    rules_source {
      rules_string = var.fw_rg.rules_string
    }
  }
}

### Create a network policy which defines default actions and what rule group to use
resource "aws_networkfirewall_firewall_policy" "fw_fp" {
  name = var.fw_fp.name

  firewall_policy {
    stateless_default_actions          = ["aws:drop"]
    stateless_fragment_default_actions = ["aws:drop"]
    stateful_rule_group_reference {
      priority = 1
      resource_arn = aws_networkfirewall_rule_group.fw_rg.arn
    }
  }
  depends_on = [
    aws_networkfirewall_rule_group.fw_rg
  ]
}

### Create the actual firewall
resource "aws_networkfirewall_firewall" "firewall" {
  name                = "mainFW"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.fw_fp.arn
  vpc_id              = aws_vpc.vpc.id
  subnet_mapping {
    subnet_id = aws_subnet.pocnet.id
  }
  depends_on = [
    aws_networkfirewall_firewall_policy.fw_fp,
    aws_subnet.pocnet
  ]
}