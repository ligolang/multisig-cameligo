# Multi signature

This exeample is meant to illustrate a transaction requiring multiple people's confirmation before the operation is executed. With this MVP example smart-contrat, we show how to use multisig-type confirmation from M of N signers in order to send an operation. In this example, we will bind a call to a token transfer from another smart-contrat, since it’s the most classic use case ( Fungible Asset 2 ).

## The multisig pattern

Step Zero : deploy the contract with desired parameters and bind it to the entrypoint to execute. Each time a multisignature is required :

1. A signer proposes a new operation execution with parameters
2. M of N possible signers submit an approval transaction to the smart-contrat
3. When the last required signer submits their approval transaction and the threshold is obtained, the resulting original transaction of the first signer is executed

Any number of operations can be in valid execution at the same time.

The multisig contract can be invoked to request any operation on other smart contracts.

## Content

The `multisig` project contains 2 main directories:

- `cameligo`: contains smart contracts implementation in cameligo
- `fa2` - contains implementation of FA2 token used by the multisig contract

## Pre-requisites

You need to install the following tools:

- [NodeJS & Npm](https://nodejs.org/en/download/)
- [LIGO](https://ligolang.org/docs/intro/installation/) **or** [Docker](https://docs.docker.com/get-docker/)

## Compiling / testing / deploying

This repository provides a Makefile for compiling and testing smart contracts. One can type `make` to display all available rules.
The `make all` command will clean all produced smart contracts, then compile smart contracts and then launch tests.

- The `make compile` command triggers the compilation of smart contracts (advisor and indice).

- The `make test` command launches tests oon compiled smart contracts (advisor and indice).

- The `make deploy` command deploys smart contracts. You need to rename `deploy/.env.dist` to `deploy/.env` and **fill the required variables**.

You can also override `make` parameters by running :

```sh
make compile ligo_compiler=<LIGO_EXECUTABLE> protocol_opt="--protocol <PROTOCOL>"
```
