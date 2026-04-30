# On-Chain Vault Protocol

A minimal ETH vault written in **Vyper**. Users deposit ETH, receive shares 1:1, and can withdraw at any time. The owner can pause new deposits in emergencies; withdrawals always remain open.

This is an educational starter contract — clean syntax, no dependencies, easy to extend with yield strategies, ERC4626 compliance, or access control.

## Features

- Deposit / withdraw ETH with share accounting
- Pausable deposits (withdrawals always live)
- Ownership transfer
- Indexed events for off-chain indexing
- Reentrancy-safe ordering (state changes before external call)

## Stack

- [Vyper](https://docs.vyperlang.org/) `^0.3.10`
- [Ape Framework](https://docs.apeworx.io/) for testing & deployment
- Python 3.10+

## Project structure

```
vault-protocol/
├── contracts/
│   └── Vault.vy
├── tests/
│   └── test_vault.py
└── README.md
```

## Quickstart

```bash
# 1. Install deps
pip install eth-ape "ape-vyper"

# 2. Compile
ape compile

# 3. Run tests
ape test

# 4. Deploy locally
ape console
>>> account = accounts.test_accounts[0]
>>> vault = account.deploy(project.Vault)
>>> vault.deposit(value="1 ether", sender=account)
```

## Contract API

| Function | Description |
|---|---|
| `deposit()` payable | Deposit ETH, mint shares 1:1 |
| `withdraw(shares)` | Burn shares, receive ETH back |
| `balance_of(user)` view | Get a user's share balance |
| `total_assets()` view | Total ETH held by the vault |
| `set_paused(bool)` owner | Pause/unpause new deposits |
| `transfer_ownership(addr)` owner | Hand off ownership |

## Events

- `Deposit(user, amount, shares)`
- `Withdraw(user, amount, shares)`
- `Paused(by, state)`
- `OwnershipTransferred(previous, new)`

## Roadmap / extensions

- [ ] ERC4626 compliance
- [ ] Pluggable yield strategies (Aave, Compound)
- [ ] Performance & withdrawal fees
- [ ] Multi-token vaults via factory
- [ ] Foundry/Hardhat integration tests

## ⚠️ Disclaimer

This contract is unaudited and intended for educational purposes only. Do not deploy with real funds without a professional audit.

## License

MIT
