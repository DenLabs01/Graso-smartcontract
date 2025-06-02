#[starknet::contract]
pub mod Graso {
    use graso_contract::interfaces::irealestateido::IRealEstateIDO;
    use graso_contract::types::types::{Contributor, PropertyInfo};

    use core::starknet::ContractAddress;
    use core::starknet::get_caller_address;
    use core::starknet::storage::{Map, StoragePathEntry};
    use core::starknet::storage::{Vec, VecTrait, MutableVecTrait};
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        // Mapping of property ID to PropertyInfo
        properties: Map<felt252, PropertyInfo>,
        
        // Mapping of property ID to array of contributors
        contributors: Map<felt252, Array<Contributor>>,
        
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
        ){}
        fn contribute(ref self: ContractState, property_id: felt252, amount: u64) {
    
        }

        fn withdraw(ref self: ContractState, property_id: felt252){
    
        }


        fn finalize_campaign(ref self: ContractState, property_id: felt252) {
           
        }

        fn get_property_info(self: @ContractState, property_id: felt252) -> PropertyInfo {
            PropertyInfo {
                title: 'Luxury Condo',
                description: 'Beautiful condo in city center',
                property_type: 'Residential',
                image: 'ipfs://imagehash',
                creator: 0x1234.try_into().unwrap(),
                price: 1_000_000,
                current_amount: 500_000,
                deadline: 1_700_000_000,
                longitude: '40.7128N',
                latitude: '74.0060W',
                is_active: true,
                is_successful: false, // Example timestamp
            }
        }

        fn get_contributors(self: @ContractState, property_id: felt252) -> Array<Contributor> {
            let mut dummy_contributors = array![];
            dummy_contributors.append(Contributor {
                wallet_address: get_caller_address(),
                amount: 100,
                timestamp: 1672531200,
            });
            dummy_contributors
        }

        fn is_contributor(
            self: @ContractState, property_id: felt252, user: ContractAddress,
        ) -> (bool, u64){
            (true, 50)
        }
    }
}
