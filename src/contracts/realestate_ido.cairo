use graso_contract::interfaces::irealestateido::IRealEstateIDO;
use graso_contract::types::types::{Contributor, PropertyInfo};
use starknet::ContractAddress;

#[starknet::contract]
mod RealEstateIDO {
    use super::{IRealEstateIDO, Contributor, PropertyInfo, ContractAddress};
    use core::starknet::storage::{
        StoragePointerReadAccess,  StoragePathEntry, Map
    };

    #[storage]
    struct Storage {
        // Property storage: property_id -> PropertyInfo
        properties: Map<felt252, PropertyInfo>,
        // Contributors storage: (property_id, contributor_address) -> contribution_amount
        contributions: Map<(felt252, ContractAddress), u64>,
        // Contributors list: property_id -> array of contributors (stored as separate entries)
        property_contributors: Map<(felt252, u32), ContractAddress>,
        // Count of contributors per property: property_id -> count
        contributor_counts: Map<felt252, u32>,
        // Contribution timestamps: (property_id, contributor_address) -> timestamp
        contribution_timestamps: Map<(felt252, ContractAddress), u64>,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        // Constructor can be empty for now
    }

    #[abi(embed_v0)]
    impl RealEstateIDOImpl of IRealEstateIDO<ContractState> {
        
        // TODO: Implement these functions later
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
        ) {
            // TODO: Implementation needed
        }

        fn contribute(ref self: ContractState, property_id: felt252, amount: u64) {
            // TODO: Implementation needed
        }

        fn withdraw(ref self: ContractState, property_id: felt252) {
            // TODO: Implementation needed
        }

        fn finalize_campaign(ref self: ContractState, property_id: felt252) {
            // TODO: Implementation needed
        }

        // 🎯 YOUR READ-ONLY GETTER FUNCTIONS:

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
                let contribution_amount = self.contributions.entry((property_id, contributor_address)).read();
                
                // Only include contributors with non-zero contributions
                if contribution_amount > 0 {
                    // Get contribution timestamp
                    let timestamp = self.contribution_timestamps.entry((property_id, contributor_address)).read();
                    
                    // Create Contributor struct and add to array
                    contributors.append(Contributor {
                        wallet_address: contributor_address,
                        amount: contribution_amount,
                        timestamp,
                    });
                }
                
                i += 1;
            };
            
            contributors
        }

        /// 3️⃣ Check if a specific user contributed to a property
        fn is_contributor(
            self: @ContractState, 
            property_id: felt252, 
            user: ContractAddress,
        ) -> (bool, u64) {
            // Get the contribution amount for this user
            let contribution_amount = self.contributions.entry((property_id, user)).read();
            
            // Return (true, amount) if contributed, (false, 0) otherwise
            if contribution_amount > 0 {
                (true, contribution_amount)
            } else {
                (false, 0)
            }
        }
    }
}