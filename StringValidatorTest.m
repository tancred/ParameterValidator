#import <XCTest/XCTest.h>
#import "ParameterValidator.h"

@interface StringValidatorTest : XCTestCase
@end

@implementation StringValidatorTest

- (void)testInstance {
	XCTAssertEqualObjects([[StringValidator validator] class], [StringValidator class]);
}

- (void)testConvenienceInstance {
	XCTAssertEqualObjects([[ParameterValidator string] class], [StringValidator class]);
}

- (void)testPleasedWithString {
	XCTAssert([[ParameterValidator string] isPleasedWith:@"two" error:nil]);
}

- (void)testNotPleasedWithNonString {
	NSError *error = nil;
	XCTAssertFalse([[ParameterValidator string] isPleasedWith:@2 error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be a string");
}

- (void)testReportsLeafError {
	NSError *error = nil;
	XCTAssertFalse([[ParameterValidator string] isPleasedWith:@2 error:&error]);
	XCTAssertEqual([error code], ParameterValidatorErrorCodeLeaf);
	XCTAssertEqualObjects([error domain], ParameterValidatorErrorDomain);
}

- (void)testMinLength {
	XCTAssert([[[ParameterValidator string] min:@3] isPleasedWith:@"two" error:nil]);
}

- (void)testMinLengthError {
	NSError *error = nil;
	XCTAssertFalse([[[ParameterValidator string] min:@3] isPleasedWith:@"to" error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be at least 3 characters");
}

- (void)testMaxLength {
	XCTAssert([[[ParameterValidator string] max:@3] isPleasedWith:@"two" error:nil]);
}

- (void)testMaxLengthError {
	NSError *error = nil;
	XCTAssertFalse([[[ParameterValidator string] max:@3] isPleasedWith:@"three" error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be at most 3 characters");
}

- (void)testMinAndMax {
	XCTAssert([[[[ParameterValidator string] min:@3] max:@5] isPleasedWith:@"two" error:nil]);
}

- (void)testMinAndMaxError {
	ParameterValidator *validator = [[[ParameterValidator string] min:@3] max:@5];
	NSError *error = nil;

	XCTAssertFalse([validator isPleasedWith:@"to" error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be 3 to 5 characters");

	XCTAssertFalse([validator isPleasedWith:@"threee" error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be 3 to 5 characters");
}

- (void)testSameMinMax {
	NSError *error = nil;
	XCTAssertFalse([[[[ParameterValidator string] min:@3] max:@3] isPleasedWith:@"three" error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be exactly 3 characters");
}

- (void)testLength {
	XCTAssert([[[ParameterValidator string] length:@3] isPleasedWith:@"two" error:nil]);
}

- (void)testLengthErrorSameAsMinMax {
	ParameterValidator *validator = [[ParameterValidator string] length:@3];
	NSError *error = nil;

	XCTAssertFalse([validator isPleasedWith:@"to" error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be exactly 3 characters");
}

@end
