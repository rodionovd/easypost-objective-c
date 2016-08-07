
// Created by Sinisa Drpa, 2015.

#import <XCTest/XCTest.h>

#import "EZPClient+Batch.h"
#import "EZPAddress.h"
#import "EZPParcel.h"
#import "EZPClient+Shipment.h"

@interface EZPBatchSynchronousTests : XCTestCase
@property (strong) EZPClient *client;
@end

@implementation EZPBatchSynchronousTests

- (void)setUp {
    [super setUp];
    self.client = [EZPClient defaultClient];
}

- (void)tearDown {
    self.client = nil;
    [super tearDown];
}

- (void)testCreateAndRetrieve {
    EZPBatch *batch = [self.client createBatchWithParameters:nil];
    XCTAssertNotNil(batch);

    EZPBatch *retrieved = [self.client retrieveBatch:batch.itemId];
    XCTAssertNotNil(retrieved);
    XCTAssertTrue([[retrieved itemId] isEqualToString:[batch itemId]]);
}

- (void)testAddRemoveShipments {
    EZPBatch *batch = [self.client createBatchWithParameters:nil];
    XCTAssertNotNil(batch);

    EZPShipment *shipment = [self shipment];
    [self.client createShipmentSynchronously:shipment];
    XCTAssertNotNil(shipment);

    EZPShipment *otherShipment = [self shipment];
    [self.client createShipmentSynchronously:otherShipment];
    XCTAssertNotNil(otherShipment);

    EZPBatch *retrieved = [self.client retrieveBatch:batch.itemId];
    XCTAssertNotNil(retrieved);

    [self.client addShipmentsSynchronously:@[shipment.itemId, otherShipment.itemId] toBatch:batch];
    XCTAssertEqual(2, batch.num_shipments);
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"SELF.itemId contains[cd] %@", batch.shipments[0].itemId];
    XCTAssertEqual(1, [[batch.shipments filteredArrayUsingPredicate:predicate] count]);
    predicate = [NSPredicate predicateWithFormat:@"SELF.itemId contains[cd] %@", batch.shipments[1].itemId];
    XCTAssertEqual(1, [[batch.shipments filteredArrayUsingPredicate:predicate] count]);
}

#pragma mark

- (EZPShipment *)shipment {
    NSDictionary *parcelDictionary = @{@"length": @8,
                                       @"width": @6,
                                       @"height": @5,
                                       @"weight": @10};
    EZPParcel *parcel = [[EZPParcel alloc] initWithDictionary:parcelDictionary];

    EZPShipment *shipment = [EZPShipment new];
    shipment.from_address = [self fromAddress];
    shipment.to_address = [self toAddress];
    shipment.parcel = parcel;
    shipment.reference = @"ShipmentRef";

    return shipment;
}

- (EZPAddress *)toAddress {
    NSDictionary *toAddressDictionary = @{@"company": @"Simpler Postage Inc",
                                          @"street1": @"164 Townsend Street",
                                          @"street2": @"Unit 1",
                                          @"city": @"San Francisco",
                                          @"state": @"CA",
                                          @"country": @"US",
                                          @"zip": @"94107"};
    EZPAddress *toAddress = [[EZPAddress alloc] initWithDictionary:toAddressDictionary];
    XCTAssertNotNil(toAddress);
    return toAddress;
}

- (EZPAddress *)fromAddress {
    NSDictionary *fromAddressDictionary = @{@"name": @"Andrew Tribone",
                                            @"street1": @"480 Fell St",
                                            @"street2": @"#3",
                                            @"city": @"San Francisco",
                                            @"state": @"CA",
                                            @"country": @"US",
                                            @"zip": @"94102"};
    EZPAddress *fromAddress = [[EZPAddress alloc] initWithDictionary:fromAddressDictionary];
    XCTAssertNotNil(fromAddress);
    return fromAddress;
}

@end
