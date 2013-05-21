#import "NumberFieldValidatorTest.h"
#import "FieldValidator.h"

@implementation NumberFieldValidatorTest

- (void)testInstance {
	STAssertEqualObjects([[NumberFieldValidator validator] class], [NumberFieldValidator class], nil);
}

- (void)testConvenienceInstance {
	STAssertEqualObjects([[FieldValidator number] class], [NumberFieldValidator class], nil);
}

- (void)testPleasedWithNumber {
	STAssertTrue([[FieldValidator number] isPleasedWith:@2 error:nil], nil);
}

- (void)testNotPleasedWithNonNumber {
	NSError *error = nil;
	STAssertFalse([[FieldValidator number] isPleasedWith:@"two" error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be a number", nil);
}

- (void)testLessThan {
	STAssertTrue([[[FieldValidator number] lessThan:@3] isPleasedWith:@2 error:nil], nil);
}

- (void)testLessThanError {
	NSError *error = nil;
	STAssertFalse([[[FieldValidator number] lessThan:@3] isPleasedWith:@3 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be less than 3", nil);
}

- (void)testAtMost {
	STAssertTrue([[[FieldValidator number] atMost:@3] isPleasedWith:@3 error:nil], nil);
}

- (void)testAtMostError {
	NSError *error = nil;
	STAssertFalse([[[FieldValidator number] atMost:@3] isPleasedWith:@4 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be at most 3", nil);
}

- (void)testGreaterThan {
	STAssertTrue([[[FieldValidator number] greaterThan:@3] isPleasedWith:@4 error:nil], nil);
}

- (void)testGreaterThanError {
	NSError *error = nil;
	STAssertFalse([[[FieldValidator number] greaterThan:@3] isPleasedWith:@3 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be greater than 3", nil);
}

- (void)testAtLeast {
	STAssertTrue([[[FieldValidator number] atLeast:@3] isPleasedWith:@3 error:nil], nil);
}

- (void)testAtLeastError {
	NSError *error = nil;
	STAssertFalse([[[FieldValidator number] atLeast:@3] isPleasedWith:@2 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be at least 3", nil);
}

- (void)testLowAndHigh {
	STAssertTrue([[[[FieldValidator number] atLeast:@3] atMost:@5] isPleasedWith:@4 error:nil], nil);
}

- (void)testLowAndHighError {
	FieldValidator *validator = [[[FieldValidator number] atLeast:@3] lessThan:@5];
	NSError *error = nil;

	STAssertFalse([validator isPleasedWith:@2 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be in [3,5)", nil);

	STAssertFalse([validator isPleasedWith:@5 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be in [3,5)", nil);
}

@end
