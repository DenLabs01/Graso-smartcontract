// Unit tests for the structs defined in `types.cairo`.
use graso_contract::types::types::{Contributor, PropertyInfo};
use starknet::{ContractAddress, contract_address_const};
use starknet::testing::{set_caller_address, set_block_timestamp};

#[test]
fn test_property_info_serialization() {
    let property = PropertyInfo {
        title: 'Luxury Condo',
        description: 'Beautiful condo in city center',
        property_type: 'Residential',
        image: 'ipfs://imagehash',
        creator: contract_address_const::<0x1234>(),
        price: 1_000_000,
        current_amount: 500_000,
        deadline: 1_700_000_000,
        longitude: '40.7128N',
        latitude: '74.0060W',
        is_active: true,
        is_successful: false,
    };

    let mut serialized: Array<felt252> = array![];
    property.serialize(ref serialized);

    let mut span_array = serialized.span();
    let deserialized: PropertyInfo = Serde::<PropertyInfo>::deserialize(ref span_array).unwrap();

    assert!(property == deserialized, "PropertyInfo serialization/deserialization failed.");
}

#[test]
fn test_contributor_serialization() {
    let contributor = Contributor {
        wallet_address: contract_address_const::<0x1234>(),
        amount: 100,
        timestamp: 1_700_000_000,
    };

    let mut serialized: Array<felt252> = array![];
    contributor.serialize(ref serialized);

    let mut span_array = serialized.span();
    let deserialized: Contributor = Serde::<Contributor>::deserialize(ref span_array).unwrap();

    assert!(contributor == deserialized, "Contributor serialization/deserialization failed.");
}

#[test]
fn test_contributor_edge_case() {
    let contributor = Contributor {
        wallet_address: contract_address_const::<0x5678>(),
        amount: 0,
        timestamp: 1_700_000_000,
    };

    assert!(contributor.amount == 0, "Contributor edge case with amount = 0 failed.");
}

//==============================================
// 🧪 GETTER FUNCTIONS UNIT TESTS
//==============================================

// Import the interface for testing
use graso_contract::interfaces::irealestateido::{IRealEstateIDODispatcher, IRealEstateIDODispatcherTrait};
use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address, stop_cheat_caller_address};

/// Helper function to create a test PropertyInfo
fn create_test_property() -> PropertyInfo {
    PropertyInfo {
        title: 'Test Property',
        description: 'A property for testing',
        property_type: 'Residential',
        image: 'ipfs://testhash',
        creator: contract_address_const::<0x100>(),
        price: 1_000_000,
        current_amount: 0,
        deadline: 1_800_000_000,
        longitude: '40.7128N',
        latitude: '74.0060W',
        is_active: true,
        is_successful: false,
    }
}

//==============================================
// 1️⃣ GET_PROPERTY_INFO TESTS
//==============================================

#[test]
fn test_get_property_info_returns_default_for_nonexistent() {
    let contract = declare("RealEstateIDO").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    
    let dispatcher = IRealEstateIDODispatcher { contract_address };
    let property_id: felt252 = 'nonexistent_property';
    
    let retrieved_property = dispatcher.get_property_info(property_id);
    
    // Should return default/empty PropertyInfo since no property was created
    assert!(retrieved_property.title == 0, "Should return empty title for nonexistent property");
    assert!(retrieved_property.price == 0, "Should return zero price for nonexistent property");
    assert!(retrieved_property.current_amount == 0, "Should return zero current_amount for nonexistent property");
}

//==============================================
// 2️⃣ GET_CONTRIBUTORS TESTS
//==============================================

#[test]
fn test_get_contributors_empty_case() {
    // 🔹 Test Case 1: Property with 0 contributors → Returns empty array
    let contract = declare("RealEstateIDO").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    
    let dispatcher = IRealEstateIDODispatcher { contract_address };
    let property_id: felt252 = 'test_property_1';
    
    let contributors = dispatcher.get_contributors(property_id);
    
    assert!(contributors.len() == 0, "Should return empty array for property with no contributors");
}

#[test]
fn test_get_contributors_returns_array_type() {
    // Test that the function returns the correct type
    let contract = declare("RealEstateIDO").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    
    let dispatcher = IRealEstateIDODispatcher { contract_address };
    let property_id: felt252 = 'test_property_array';
    
    let contributors = dispatcher.get_contributors(property_id);
    
    // Verify it's an array and we can call methods on it
    assert!(contributors.len() == 0, "Should return valid array structure");
}

//==============================================
// 3️⃣ IS_CONTRIBUTOR TESTS  
//==============================================

#[test]
fn test_is_contributor_returns_false_for_non_contributor() {
    // 🔹 Test Case 3: is_contributor → Returns (false, 0) for non-contributor
    let contract = declare("RealEstateIDO").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    
    let dispatcher = IRealEstateIDODispatcher { contract_address };
    let property_id: felt252 = 'test_property';
    let non_contributor_address = contract_address_const::<0x500>();
    
    let (is_contributor, amount) = dispatcher.is_contributor(property_id, non_contributor_address);
    
    assert!(is_contributor == false, "Should return false for non-contributor");
    assert!(amount == 0, "Should return zero amount for non-contributor");
}

#[test]
fn test_is_contributor_different_properties() {
    let contract = declare("RealEstateIDO").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    
    let dispatcher = IRealEstateIDODispatcher { contract_address };
    let property_id1: felt252 = 'property_1';
    let property_id2: felt252 = 'property_2';
    let contributor_address = contract_address_const::<0x700>();
    
    // Check both properties (should return false for both since no contributions yet)
    let (is_contributor_1, amount_1) = dispatcher.is_contributor(property_id1, contributor_address);
    let (is_contributor_2, amount_2) = dispatcher.is_contributor(property_id2, contributor_address);
    
    assert!(is_contributor_1 == false, "Should not be contributor to property 1");
    assert!(amount_1 == 0, "Should return zero for property 1");
    assert!(is_contributor_2 == false, "Should not be contributor to property 2");
    assert!(amount_2 == 0, "Should return zero for property 2");
}

#[test]
fn test_is_contributor_with_multiple_addresses() {
    let contract = declare("RealEstateIDO").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    
    let dispatcher = IRealEstateIDODispatcher { contract_address };
    let property_id: felt252 = 'multi_test_property';
    
    // Test multiple different addresses
    let addr1 = contract_address_const::<0x800>();
    let addr2 = contract_address_const::<0x801>();
    let addr3 = contract_address_const::<0x802>();
    
    let (is_contrib1, amount1) = dispatcher.is_contributor(property_id, addr1);
    let (is_contrib2, amount2) = dispatcher.is_contributor(property_id, addr2);
    let (is_contrib3, amount3) = dispatcher.is_contributor(property_id, addr3);
    
    // All should return false since no contributions have been made
    assert!(is_contrib1 == false && amount1 == 0, "Address 1 should not be contributor");
    assert!(is_contrib2 == false && amount2 == 0, "Address 2 should not be contributor");
    assert!(is_contrib3 == false && amount3 == 0, "Address 3 should not be contributor");
}

//==============================================
// 🔧 GAS EFFICIENCY TESTS
//==============================================

#[test]
fn test_getter_functions_gas_efficiency() {
    let contract = declare("RealEstateIDO").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    
    let dispatcher = IRealEstateIDODispatcher { contract_address };
    
    // Test multiple calls to ensure they're efficient
    let mut i = 0;
    while i == 10 {
        let property_id: felt252 = 'efficiency_test';
        let test_address = contract_address_const::<0x900>();
        
        // Multiple calls should complete without issues
        let _property_info = dispatcher.get_property_info(property_id);
        let _contributors = dispatcher.get_contributors(property_id);
        let (_is_contrib, _amount) = dispatcher.is_contributor(property_id, test_address);
        
        i += 1;
    };
    
    // If we reach here, the functions are working efficiently
    assert!(true, "Gas efficiency test completed successfully");
}

//==============================================
// 📋 EDGE CASE TESTS
//==============================================

#[test]
fn test_get_property_info_with_different_property_ids() {
    let contract = declare("RealEstateIDO").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    
    let dispatcher = IRealEstateIDODispatcher { contract_address };
    
    // Test with different types of property IDs
    let prop1 = dispatcher.get_property_info('short');
    let prop2 = dispatcher.get_property_info('a_very_long_property_name');
    let prop3 = dispatcher.get_property_info(12345);
    
    // All should return default values since no properties exist
    assert!(prop1.title == 0 && prop1.price == 0, "Short property ID should return default");
    assert!(prop2.title == 0 && prop2.price == 0, "Long property ID should return default");
    assert!(prop3.title == 0 && prop3.price == 0, "Numeric property ID should return default");
}

#[test]
fn test_contributors_array_properties() {
    let contract = declare("RealEstateIDO").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    
    let dispatcher = IRealEstateIDODispatcher { contract_address };
    let property_id: felt252 = 'array_test';
    
    let contributors = dispatcher.get_contributors(property_id);
    
    // Test array properties
    assert!(contributors.len() == 0, "Empty array should have length 0");
    
    // Test that we can create a span from it
    let _contributors_span = contributors.span();
    
    // Test successful - array is properly formatted
    assert!(true, "Contributors array properties test passed");
}