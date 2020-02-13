# DSS Darkfix Spell

Using the `CREATE2` opcode, we can predetermine the deploy address of a contract if we have the following three items:

- (`bytes`) init bytecode of the contract (currently undeployed)
- (`address`) address of contract that will deploy the contract
- (`bytes32`) salt (also referred to as the nonce)

The most simple option to fix a bug is to use a `CREATE2` generated address as the 'action' address in a spell, deploy, lift to the hat, and schedule the spell. Then, once beyond the 24 hour GSM delay, deploy the pre-authorized spell action contract, and then cast the plotted spell. 

Typically, the 'SpellAction' contracts consists of a handful of constant state variables and an execute() function with no parameters. Within the execute function are the privileged calls to the DSS system, where the bug fix would occur. We're mostly copying the SpellAction contract style, so the bytecode size should be relatively small.

# Requirements

- https://dapp.tools

# Getting Started

Clone the repository

```
git clone https://github.com/makerdao/dss-darkfix.git
```

Then, with `ETH_FROM`, `ETH_KEYSTORE`, and `ETH_PASSWORD` env vars set:

```
./test.sh
```
