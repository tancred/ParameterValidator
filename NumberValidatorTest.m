#import <XCTest/XCTest.h>
#import "ParameterValidator.h"

@interface NumberValidatorTest : XCTestCase
@end

@implementation NumberValidatorTest

- (void)testInstance {
	XCTAssertEqualObjects([[NumberValidator validator] class], [NumberValidator class]);
}

- (void)testConvenienceInstance {
	XCTAssertEqualObjects([[ParameterValidator number] class], [NumberValidator class]);
}

- (void)testPleasedWithNumber {
	XCTAssert([[ParameterValidator number] isPleasedWith:@2 error:nil]);
}

- (void)testNotPleasedWithNonNumber {
	NSError *error = nil;
	XCTAssertFalse([[ParameterValidator number] isPleasedWith:@"two" error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be a number");
}

- (void)testReportsLeafError {
	NSError *error = nil;
	XCTAssertFalse([[ParameterValidator number] isPleasedWith:@"two" error:&error]);
	XCTAssertEqual([error code], ParameterValidatorErrorCodeLeaf);
	XCTAssertEqualObjects([error domain], ParameterValidatorErrorDomain);
}

- (void)testLessThan {
	XCTAssert([[[ParameterValidator number] lessThan:@3] isPleasedWith:@2 error:nil]);
}

- (void)testLessThanError {
	NSError *error = nil;
	XCTAssertFalse([[[ParameterValidator number] lessThan:@3] isPleasedWith:@3 error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be less than 3");
}

- (void)testAtMost {
	XCTAssert([[[ParameterValidator number] atMost:@3] isPleasedWith:@3 error:nil]);
}

- (void)testAtMostError {
	NSError *error = nil;
	XCTAssertFalse([[[ParameterValidator number] atMost:@3] isPleasedWith:@4 error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be at most 3");
}

- (void)testGreaterThan {
	XCTAssert([[[ParameterValidator number] greaterThan:@3] isPleasedWith:@4 error:nil]);
}

- (void)testGreaterThanError {
	NSError *error = nil;
	XCTAssertFalse([[[ParameterValidator number] greaterThan:@3] isPleasedWith:@3 error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be greater than 3");
}

- (void)testAtLeast {
	XCTAssert([[[ParameterValidator number] atLeast:@3] isPleasedWith:@3 error:nil]);
}

- (void)testAtLeastError {
	NSError *error = nil;
	XCTAssertFalse([[[ParameterValidator number] atLeast:@3] isPleasedWith:@2 error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be at least 3");
}

- (void)testLowAndHigh {
	XCTAssert([[[[ParameterValidator number] atLeast:@3] atMost:@5] isPleasedWith:@4 error:nil]);
}

- (void)testLowAndHighError {
	ParameterValidator *validator = [[[ParameterValidator number] atLeast:@3] lessThan:@5];
	NSError *error = nil;

	XCTAssertFalse([validator isPleasedWith:@2 error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be in [3,5)");

	XCTAssertFalse([validator isPleasedWith:@5 error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be in [3,5)");
}

@end
