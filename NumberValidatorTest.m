#import "NumberValidatorTest.h"
#import "ParameterValidator.h"

@implementation NumberValidatorTest

- (void)testInstance {
	STAssertEqualObjects([[NumberValidator validator] class], [NumberValidator class], nil);
}

- (void)testConvenienceInstance {
	STAssertEqualObjects([[ParameterValidator number] class], [NumberValidator class], nil);
}

- (void)testPleasedWithNumber {
	STAssertTrue([[ParameterValidator number] isPleasedWith:@2 error:nil], nil);
}

- (void)testNotPleasedWithNonNumber {
	NSError *error = nil;
	STAssertFalse([[ParameterValidator number] isPleasedWith:@"two" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be a number", nil);
}

- (void)testReportsLeafError {
	NSError *error = nil;
	STAssertFalse([[ParameterValidator number] isPleasedWith:@"two" error:&error], nil);
	STAssertEquals([error code], ParameterValidatorErrorCodeLeaf, nil);
	STAssertEqualObjects([error domain], ParameterValidatorErrorDomain, nil);
}

- (void)testLessThan {
	STAssertTrue([[[ParameterValidator number] lessThan:@3] isPleasedWith:@2 error:nil], nil);
}

- (void)testLessThanError {
	NSError *error = nil;
	STAssertFalse([[[ParameterValidator number] lessThan:@3] isPleasedWith:@3 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be less than 3", nil);
}

- (void)testAtMost {
	STAssertTrue([[[ParameterValidator number] atMost:@3] isPleasedWith:@3 error:nil], nil);
}

- (void)testAtMostError {
	NSError *error = nil;
	STAssertFalse([[[ParameterValidator number] atMost:@3] isPleasedWith:@4 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be at most 3", nil);
}

- (void)testGreaterThan {
	STAssertTrue([[[ParameterValidator number] greaterThan:@3] isPleasedWith:@4 error:nil], nil);
}

- (void)testGreaterThanError {
	NSError *error = nil;
	STAssertFalse([[[ParameterValidator number] greaterThan:@3] isPleasedWith:@3 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be greater than 3", nil);
}

- (void)testAtLeast {
	STAssertTrue([[[ParameterValidator number] atLeast:@3] isPleasedWith:@3 error:nil], nil);
}

- (void)testAtLeastError {
	NSError *error = nil;
	STAssertFalse([[[ParameterValidator number] atLeast:@3] isPleasedWith:@2 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be at least 3", nil);
}

- (void)testLowAndHigh {
	STAssertTrue([[[[ParameterValidator number] atLeast:@3] atMost:@5] isPleasedWith:@4 error:nil], nil);
}

- (void)testLowAndHighError {
	ParameterValidator *validator = [[[ParameterValidator number] atLeast:@3] lessThan:@5];
	NSError *error = nil;

	STAssertFalse([validator isPleasedWith:@2 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be in [3,5)", nil);

	STAssertFalse([validator isPleasedWith:@5 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be in [3,5)", nil);
}

@end
