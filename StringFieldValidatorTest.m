#import "StringFieldValidatorTest.h"
#import "FieldValidator.h"

@implementation StringFieldValidatorTest

- (void)testInstance {
	STAssertEqualObjects([[StringFieldValidator validator] class], [StringFieldValidator class], nil);
}

- (void)testConvenienceInstance {
	STAssertEqualObjects([[FieldValidator string] class], [StringFieldValidator class], nil);
}

- (void)testPleasedWithString {
	STAssertTrue([[FieldValidator string] isPleasedWith:@"two" error:nil], nil);
}

- (void)testNotPleasedWithNonString {
	NSError *error = nil;
	STAssertFalse([[FieldValidator string] isPleasedWith:@2 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be a string", nil);
}

- (void)testMinLength {
	STAssertTrue([[[FieldValidator string] min:@3] isPleasedWith:@"two" error:nil], nil);
}

- (void)testMinLengthError {
	NSError *error = nil;
	STAssertFalse([[[FieldValidator string] min:@3] isPleasedWith:@"to" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be at least 3 characters", nil);
}

- (void)testMaxLength {
	STAssertTrue([[[FieldValidator string] max:@3] isPleasedWith:@"two" error:nil], nil);
}

- (void)testMaxLengthError {
	NSError *error = nil;
	STAssertFalse([[[FieldValidator string] max:@3] isPleasedWith:@"three" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be at most 3 characters", nil);
}

- (void)testMinAndMax {
	STAssertTrue([[[[FieldValidator string] min:@3] max:@5] isPleasedWith:@"two" error:nil], nil);
}

- (void)testMinAndMaxError {
	FieldValidator *validator = [[[FieldValidator string] min:@3] max:@5];
	NSError *error = nil;

	STAssertFalse([validator isPleasedWith:@"to" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be 3 to 5 characters", nil);

	STAssertFalse([validator isPleasedWith:@"threee" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be 3 to 5 characters", nil);
}

- (void)testSameMinMax {
	NSError *error = nil;
	STAssertFalse([[[[FieldValidator string] min:@3] max:@3] isPleasedWith:@"three" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be exactly 3 characters", nil);
}

- (void)testLength {
	STAssertTrue([[[FieldValidator string] length:@3] isPleasedWith:@"two" error:nil], nil);
}

- (void)testLengthErrorSameAsMinMax {
	FieldValidator *validator = [[FieldValidator string] length:@3];
	NSError *error = nil;

	STAssertFalse([validator isPleasedWith:@"to" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be exactly 3 characters", nil);
}

@end
