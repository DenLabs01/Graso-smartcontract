use graso_contract::types::{Contributor, PropertyInfo};
use starknet::ContractAddress;

/// Interface representing `IRealEstateIDO`.
/// This interface provides functionality for property management, contribution & funds management,
/// and read-only getters.
#[starknet::interface]
pub trait IRealEstateIDO<TContractState> {
    /// Create a property with relevant details.
    fn create_property(
        ref self: TContractState,
        title: felt252,
        description: felt252,
        property_type: felt252,
        image: felt252,
        price: u64,
        deadline: u64,
        longitude: felt252,
        latitude: felt252,
    );

    /// Contribute to a property.
    fn contribute(ref self: TContractState, property_id: felt252, amount: u64);

    /// Withdraw contributions from a property.
    fn withdraw(ref self: TContractState, property_id: felt252);

    /// Finalize the campaign for a property.
    fn finalize_campaign(ref self: TContractState, property_id: felt252);

    /// Retrieve property information.
    fn get_property_info(self: @TContractState, property_id: felt252) -> PropertyInfo;

    /// List contributors for a property.
    fn get_contributors(self: @TContractState, property_id: felt252) -> Array<Contributor>;

    /// Check if a specific user has contributed to a property.
    fn is_contributor(
        self: @TContractState, property_id: felt252, user: ContractAddress,
    ) -> (bool, u64);
}
