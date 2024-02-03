# An assortment of mint contracts

Forked off of a template for quickly getting started with forge

---

## Getting Started

If you don't have forge installed:
1. `curl -L https://foundry.paradigm.xyz | bash`
2. `foundryup`
3. `brew install libusb`
4. then forge should be intalled

---

## Running Tests
When adjusting the contract being tested you may need to compile from scratch. Sometimes forge bugs out and doesn't recompile properly. 
```
forge clean && forge test -vvv
```
- `-v`, `-vv`, `-vvv`, `-vvvv` : each v increases the details returned from the test (I usually use `-vvv` & `-vvvv`)
- `forge test -vvv --match--contract <CONTRACT_NAME>` : tests a single contract (don't put `.t.sol` or `.sol` at the end).

---

## Features

### Preinstalled dependencies

`openzeppelin` is already installed.

### Linting

Pre-configured `solhint` and `prettier-plugin-solidity`. Can be run by

```
npm run solhint
npm run prettier
```

### CI with Github Actions

Automatically run linting and tests on pull requests.
