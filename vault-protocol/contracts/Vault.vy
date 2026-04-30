# @version 0.3.10
# @title Simple ETH Vault
# @notice A minimal vault that lets users deposit and withdraw ETH,
#         tracking shares per depositor. Owner can pause deposits in emergencies.
# @dev    Educational contract. NOT audited. Do not use with real funds.

# ---------------------------------------------------------------------------
# Events
# ---------------------------------------------------------------------------
event Deposit:
    user: indexed(address)
    amount: uint256
    shares: uint256

event Withdraw:
    user: indexed(address)
    amount: uint256
    shares: uint256

event Paused:
    by: indexed(address)
    state: bool

event OwnershipTransferred:
    previous_owner: indexed(address)
    new_owner: indexed(address)


# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------
owner: public(address)
paused: public(bool)

# Each user's share balance. Total shares track total deposits 1:1 in this
# simple version (no yield strategy attached).
shares_of: public(HashMap[address, uint256])
total_shares: public(uint256)


# ---------------------------------------------------------------------------
# Constructor
# ---------------------------------------------------------------------------
@external
def __init__():
    self.owner = msg.sender
    self.paused = False
    log OwnershipTransferred(empty(address), msg.sender)


# ---------------------------------------------------------------------------
# Modifiers (Vyper uses internal helper checks)
# ---------------------------------------------------------------------------
@internal
def _only_owner():
    assert msg.sender == self.owner, "not owner"

@internal
def _not_paused():
    assert not self.paused, "paused"


# ---------------------------------------------------------------------------
# Core: deposit / withdraw
# ---------------------------------------------------------------------------
@external
@payable
def deposit():
    """
    @notice Deposit ETH and receive vault shares 1:1.
    """
    self._not_paused()
    assert msg.value > 0, "zero deposit"

    shares: uint256 = msg.value
    self.shares_of[msg.sender] += shares
    self.total_shares += shares

    log Deposit(msg.sender, msg.value, shares)


@external
def withdraw(shares: uint256):
    """
    @notice Burn `shares` and receive equivalent ETH back.
    """
    assert shares > 0, "zero shares"
    assert self.shares_of[msg.sender] >= shares, "insufficient shares"

    self.shares_of[msg.sender] -= shares
    self.total_shares -= shares

    # 1:1 redemption since this vault has no yield strategy
    raw_call(msg.sender, b"", value=shares)

    log Withdraw(msg.sender, shares, shares)


# ---------------------------------------------------------------------------
# Views
# ---------------------------------------------------------------------------
@external
@view
def total_assets() -> uint256:
    """
    @notice Total ETH currently held by the vault.
    """
    return self.balance


@external
@view
def balance_of(user: address) -> uint256:
    """
    @notice ETH-equivalent balance for `user`.
    """
    return self.shares_of[user]


# ---------------------------------------------------------------------------
# Admin
# ---------------------------------------------------------------------------
@external
def set_paused(state: bool):
    """
    @notice Pause/unpause new deposits. Withdrawals always remain open.
    """
    self._only_owner()
    self.paused = state
    log Paused(msg.sender, state)


@external
def transfer_ownership(new_owner: address):
    """
    @notice Hand off contract ownership.
    """
    self._only_owner()
    assert new_owner != empty(address), "zero address"
    log OwnershipTransferred(self.owner, new_owner)
    self.owner = new_owner
