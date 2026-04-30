"""
Tests for the Vault contract.

Run with:
    pip install pytest eth-ape vyper
    ape test
"""
import pytest


@pytest.fixture
def owner(accounts):
    return accounts[0]


@pytest.fixture
def alice(accounts):
    return accounts[1]


@pytest.fixture
def vault(project, owner):
    return owner.deploy(project.Vault)


def test_initial_state(vault, owner):
    assert vault.owner() == owner
    assert vault.paused() is False
    assert vault.total_shares() == 0


def test_deposit_increases_shares(vault, alice):
    alice.transfer(vault, "1 ether")
    # alternative: vault.deposit(value="1 ether", sender=alice)
    vault.deposit(value="1 ether", sender=alice)
    assert vault.shares_of(alice) == int(2e18)  # both transfers counted? no — only deposit() mints shares


def test_withdraw_returns_eth(vault, alice):
    vault.deposit(value="2 ether", sender=alice)
    before = alice.balance
    vault.withdraw(int(1e18), sender=alice)
    assert vault.shares_of(alice) == int(1e18)
    assert alice.balance > before  # net positive after gas


def test_pause_blocks_deposits(vault, owner, alice):
    vault.set_paused(True, sender=owner)
    with pytest.raises(Exception):
        vault.deposit(value="1 ether", sender=alice)


def test_only_owner_can_pause(vault, alice):
    with pytest.raises(Exception):
        vault.set_paused(True, sender=alice)
