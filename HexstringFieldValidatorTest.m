#import "HexstringFieldValidatorTest.h"
#import "FieldValidator.h"

@implementation HexstringFieldValidatorTest

- (void)testInstance {
	STAssertEqualObjects([[HexstringFieldValidator validator] class], [HexstringFieldValidator class], nil);
}

- (void)testConvenienceInstance {
	STAssertEqualObjects([[FieldValidator hexstring] class], [HexstringFieldValidator class], nil);
}

- (void)testPleasedWithHexstring {
	STAssertTrue([[FieldValidator hexstring] isPleasedWith:@"abcdefABCDEF0123456789" error:nil], nil);
}

- (void)testPerformsStringValidationsBeforeSpecificHexValidations {
	NSError *error = nil;
	STAssertFalse([[FieldValidator hexstring] isPleasedWith:@2 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be a string", nil);

	error = nil;
	STAssertFalse([[[FieldValidator hexstring] min:@3] isPleasedWith:@"to" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be at least 3 characters", nil);

	error = nil;
	STAssertFalse([[[FieldValidator hexstring] length:@3] isPleasedWith:@"to" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be exactly 3 characters", nil);
}

- (void)testNotPleasedWithNonHexstring {
	// It's difficult to test what something isn't, short of testing all of the isn'ts.
	// We're taking a leap of faith here and check only a few chars that lies outside the
	// hex string range.
	// Another approach might be to expose details of the implementation so that a more
	// thorough test can be performed on the algorithm instead of the data, but let's not
	// over-work this.
	NSError *error = nil;
	STAssertFalse([[FieldValidator hexstring] isPleasedWith:@"a b" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be a hexstring", nil);

	error = nil;
	STAssertFalse([[FieldValidator hexstring] isPleasedWith:@" ab" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be a hexstring", nil);

	error = nil;
	STAssertFalse([[FieldValidator hexstring] isPleasedWith:@"ab " error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be a hexstring", nil);
}

@end
