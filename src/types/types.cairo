/// Core structs for the Graso smart contract.
use starknet::ContractAddress;

/// Struct representing property information for an IDO campaign.
#[derive(PartialEq, Drop, Serde, Copy, starknet::Store)]
pub struct PropertyInfo {
    /// Short name of the property (e.g., "Luxury Condo").
    pub title: felt252,
    /// Detailed property description.
    pub description: felt252,
    /// Category of the property (e.g., "Residential", "Commercial").
    pub property_type: felt252,
    /// URL/IPFS hash of the property image.
    pub image: felt252,
    /// Starknet address of the campaign creator.
    pub creator: ContractAddress,
    /// Target funding amount (in GRASO/ETH).
    pub price: u64,
    /// Total funds raised so far.
    pub current_amount: u64,
    /// Campaign end date (UNIX timestamp).
    pub deadline: u64,
    /// Geographic longitude coordinate.
    pub longitude: felt252,
    /// Geographic latitude coordinate.
    pub latitude: felt252,
    /// Indicates if the campaign is accepting contributions.
    pub is_active: bool,
    /// Indicates if the funding goal was met.
    pub is_successful: bool,
}

/// Struct representing an individual contributor to a property IDO.
#[derive(PartialEq, Drop, Serde, Copy, starknet::Store)]
pub struct Contributor {
    /// Starknet address of the contributor.
    pub wallet_address: ContractAddress,
    /// Contribution amount (in GRASO/ETH).
    pub amount: u64,
    /// Timestamp of the contribution (UNIX seconds).
    pub timestamp: u64,
}
