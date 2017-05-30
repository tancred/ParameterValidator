#import <XCTest/XCTest.h>
#import "ParameterValidator.h"

@interface HexstringValidatorTest : XCTestCase
@end

@implementation HexstringValidatorTest

- (void)testInstance {
	XCTAssertEqualObjects([[HexstringValidator validator] class], [HexstringValidator class]);
}

- (void)testConvenienceInstance {
	XCTAssertEqualObjects([[ParameterValidator hexstring] class], [HexstringValidator class]);
}

- (void)testPleasedWithHexstring {
	XCTAssert([[ParameterValidator hexstring] isPleasedWith:@"abcdefABCDEF0123456789" error:nil]);
}

- (void)testPerformsStringValidationsBeforeSpecificHexValidations {
	NSError *error = nil;
	XCTAssertFalse([[ParameterValidator hexstring] isPleasedWith:@2 error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be a string");

	error = nil;
	XCTAssertFalse([[[ParameterValidator hexstring] min:@3] isPleasedWith:@"to" error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be at least 3 characters");

	error = nil;
	XCTAssertFalse([[[ParameterValidator hexstring] length:@3] isPleasedWith:@"to" error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be exactly 3 characters");
}

- (void)testNotPleasedWithNonHexstring {
	// It's difficult to test what something isn't, short of testing all of the isn'ts.
	// We're taking a leap of faith here and check only a few chars that lies outside the
	// hex string range.
	// Another approach might be to expose details of the implementation so that a more
	// thorough test can be performed on the algorithm instead of the data, but let's not
	// over-work this.
	NSError *error = nil;
	XCTAssertFalse([[ParameterValidator hexstring] isPleasedWith:@"a b" error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be a hexstring");

	error = nil;
	XCTAssertFalse([[ParameterValidator hexstring] isPleasedWith:@" ab" error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be a hexstring");

	error = nil;
	XCTAssertFalse([[ParameterValidator hexstring] isPleasedWith:@"ab " error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must be a hexstring");
}

- (void)testReportsLeafError {
	NSError *error = nil;
	XCTAssertFalse([[ParameterValidator hexstring] isPleasedWith:@"xyz" error:&error]);
	XCTAssertEqual([error code], ParameterValidatorErrorCodeLeaf);
	XCTAssertEqualObjects([error domain], ParameterValidatorErrorDomain);
}

@end
