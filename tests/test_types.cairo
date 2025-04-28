// Unit tests for the structs defined in `types.cairo`.
use graso_contract::types::{Contributor, PropertyInfo};

#[test]
fn test_property_info_serialization() {
    let property = PropertyInfo {
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
        wallet_address: 0x1234.try_into().unwrap(), amount: 100, timestamp: 1_700_000_000,
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
        wallet_address: 0x5678.try_into().unwrap(), amount: 0, timestamp: 1_700_000_000,
    };

    assert!(contributor.amount == 0, "Contributor edge case with amount = 0 failed.");
}
