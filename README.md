# DSS Darkspell

Using the `CREATE2` opcode, we can predetermine the deploy address of a contract if we have the following three items:

- (`bytes`) init bytecode of the contract (currently undeployed)
- (`address`) address of contract that will deploy the contract
- (`bytes32`) salt (also referred to as the nonce)

The most simple option to fix a bug is to use a `CREATE2` generated address as the 'action' address in a spell, deploy, lift to the hat, and schedule the spell. Then, once beyond the non-zero GSM delay, deploy the pre-authorized spell action contract, and then cast the plotted spell. 

Typically, spells make use of a separate 'SpellAction' proxy contract to execute system changes. 'SpellAction' contracts consists of a handful of constant state variables and an `execute()` function with no parameters. Within the execute function are the privileged calls to the DSS system, where the bug fix would occur. This architecture requires no changes to the current spell infrastructure.

# Requirements

- https://dapp.tools

# Getting Started

Clone the repository:

```
git clone https://github.com/makerdao/dss-darkspell.git
```

Then, in the `env-kovan` file in this repo, with `ETH_FROM`, `ETH_KEYSTORE`, and `ETH_PASSWORD` environment variables set:

```
./test.sh
```
