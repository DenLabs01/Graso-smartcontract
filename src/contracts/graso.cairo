#[starknet::contract]
pub mod Graso {
    use core::starknet::storage::{
        Map, MutableVecTrait, StoragePathEntry, StoragePointerReadAccess, StoragePointerWriteAccess,
        Vec, VecTrait,
    };
    use core::starknet::{ContractAddress, get_caller_address};
    use graso_contract::interfaces::irealestateido::IRealEstateIDO;
    use graso_contract::types::types::{Contributor, PropertyInfo};

    #[storage]
    struct Storage {
        // Mapping of property ID to PropertyInfo
        properties: Map<felt252, PropertyInfo>,
        // Mapping of property ID to array of contributors
        contributors: Map<felt252, Array<Contributor>>,
        // Contributors list: property_id -> array of contributors (stored as separate entries)
        property_contributors: Map<(felt252, u32), ContractAddress>,
        // Count of contributors per property: property_id -> count
        contributor_counts: Map<felt252, u32>,
        contribution_timestamps: Map<(felt252, ContractAddress), u64>,
        // Array of all property IDs

        // Mapping of (property ID, user address) to contribution amount
        user_contributions: Map<(felt252, ContractAddress), u64>,
        // Array of all property IDs
        all_properties: Array<felt252>,
    }


    #[abi(embed_v0)]
    impl GrasoImpl of IRealEstateIDO<ContractState> {
        fn create_property(
            ref self: ContractState,
            title: felt252,
            description: felt252,
            property_type: felt252,
            image: felt252,
            price: u64,
            deadline: u64,
            longitude: felt252,
            latitude: felt252,
        ) {}
        fn contribute(ref self: ContractState, property_id: felt252, amount: u64) {}

        fn withdraw(ref self: ContractState, property_id: felt252) {}


        fn finalize_campaign(ref self: ContractState, property_id: felt252) {}

        /// 1️⃣ Get full property details
        fn get_property_info(self: @ContractState, property_id: felt252) -> PropertyInfo {
            // Read property from storage and return it
            self.properties.entry(property_id).read()
        }


        /// 2️⃣ Get list of all contributors for a property
        fn get_contributors(self: @ContractState, property_id: felt252) -> Array<Contributor> {
            let mut contributors = ArrayTrait::new();

            // Get the number of contributors for this property
            let contributor_count = self.contributor_counts.entry(property_id).read();

            // If no contributors, return empty array
            if contributor_count == 0 {
                return contributors;
            }

            // Loop through all contributors
            let mut i: u32 = 0;
            while i < contributor_count {
                // Get contributor address
                let contributor_address = self.property_contributors.entry((property_id, i)).read();

                // Get contribution amount
                let contribution_amount = self
                    .user_contributions
                    .entry((property_id, contributor_address))
                    .read();

                // Only include contributors with non-zero contributions
                if contribution_amount > 0 {
                    // Get contribution timestamp
                    let timestamp = self
                        .contribution_timestamps
                        .entry((property_id, contributor_address))
                        .read();

                    // Create Contributor struct and add to array
                    contributors
                        .append(
                            Contributor {
                                wallet_address: contributor_address,
                                amount: contribution_amount,
                                timestamp,
                            },
                        );
                }

                i += 1;
            }

            contributors
        }

        fn is_contributor(
            self: @ContractState, property_id: felt252, user: ContractAddress,
        ) -> (bool, u64) {
            // Get the contribution amount for this user
            let contribution_amount = self.user_contributions.entry((property_id, user)).read();

            // Return (true, amount) if contributed, (false, 0) otherwise
            if contribution_amount > 0 {
                (true, contribution_amount)
            } else {
                (false, 0)
            }
        }
    }
}
