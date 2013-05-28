#import "StringValidatorTest.h"
#import "ParameterValidator.h"

@implementation StringValidatorTest

- (void)testInstance {
	STAssertEqualObjects([[StringValidator validator] class], [StringValidator class], nil);
}

- (void)testConvenienceInstance {
	STAssertEqualObjects([[ParameterValidator string] class], [StringValidator class], nil);
}

- (void)testPleasedWithString {
	STAssertTrue([[ParameterValidator string] isPleasedWith:@"two" error:nil], nil);
}

- (void)testNotPleasedWithNonString {
	NSError *error = nil;
	STAssertFalse([[ParameterValidator string] isPleasedWith:@2 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be a string", nil);
}

- (void)testReportsLeafError {
	NSError *error = nil;
	STAssertFalse([[ParameterValidator string] isPleasedWith:@2 error:&error], nil);
	STAssertEquals([error code], ParameterValidatorErrorCodeLeaf, nil);
	STAssertEqualObjects([error domain], ParameterValidatorErrorDomain, nil);
}

- (void)testMinLength {
	STAssertTrue([[[ParameterValidator string] min:@3] isPleasedWith:@"two" error:nil], nil);
}

- (void)testMinLengthError {
	NSError *error = nil;
	STAssertFalse([[[ParameterValidator string] min:@3] isPleasedWith:@"to" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be at least 3 characters", nil);
}

- (void)testMaxLength {
	STAssertTrue([[[ParameterValidator string] max:@3] isPleasedWith:@"two" error:nil], nil);
}

- (void)testMaxLengthError {
	NSError *error = nil;
	STAssertFalse([[[ParameterValidator string] max:@3] isPleasedWith:@"three" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be at most 3 characters", nil);
}

- (void)testMinAndMax {
	STAssertTrue([[[[ParameterValidator string] min:@3] max:@5] isPleasedWith:@"two" error:nil], nil);
}

- (void)testMinAndMaxError {
	ParameterValidator *validator = [[[ParameterValidator string] min:@3] max:@5];
	NSError *error = nil;

	STAssertFalse([validator isPleasedWith:@"to" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be 3 to 5 characters", nil);

	STAssertFalse([validator isPleasedWith:@"threee" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be 3 to 5 characters", nil);
}

- (void)testSameMinMax {
	NSError *error = nil;
	STAssertFalse([[[[ParameterValidator string] min:@3] max:@3] isPleasedWith:@"three" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be exactly 3 characters", nil);
}

- (void)testLength {
	STAssertTrue([[[ParameterValidator string] length:@3] isPleasedWith:@"two" error:nil], nil);
}

- (void)testLengthErrorSameAsMinMax {
	ParameterValidator *validator = [[ParameterValidator string] length:@3];
	NSError *error = nil;

	STAssertFalse([validator isPleasedWith:@"to" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be exactly 3 characters", nil);
}

@end
