#import <SenTestingKit/SenTestingKit.h>
#import "ParameterValidator.h"

@interface ArrayValidatorTest : SenTestCase
@end

@implementation ArrayValidatorTest

- (void)testInstance {
	STAssertEqualObjects([[ArrayValidator validator] class], [ArrayValidator class], nil);
}

- (void)testConvenienceInstance {
	STAssertEqualObjects([[ParameterValidator array] class], [ArrayValidator class], nil);
}

- (void)testPleasedWithArray {
	STAssertTrue([[ParameterValidator array] isPleasedWith:@[] error:nil], nil);
}

- (void)testNotPleasedWithNonArray {
	NSError *error = nil;
	STAssertFalse([[ParameterValidator array] isPleasedWith:@2 error:&error], nil);
	STAssertEquals([error code], ParameterValidatorErrorCodeLeaf, nil);
	STAssertEqualObjects([error domain], ParameterValidatorErrorDomain, nil);
	STAssertEqualObjects([error localizedDescription], @"must be an array", nil);
}

- (void)testPrototype {
	STAssertTrue([[[ParameterValidator array] of:[ParameterValidator number]] isPleasedWith:(@[@1,@1,@2,@3]) error:nil], nil);
}

- (void)testPrototypeError {
	NSError *error = nil;
	STAssertFalse([[[ParameterValidator array] of:[ParameterValidator number]] isPleasedWith:(@[@1,@1,@"x",@3]) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"validation error for parameter '2': must be a number", nil);
}

- (void)testPrototypeErrorIsABranchError {
	NSError *error = nil;
	STAssertFalse([[[ParameterValidator array] of:[ParameterValidator number]] isPleasedWith:(@[@1,@1,@"x",@3]) error:&error], nil);

	STAssertEquals([error code], ParameterValidatorErrorCodeBranch, nil);
	STAssertEqualObjects([error domain], ParameterValidatorErrorDomain, nil);
	STAssertEqualObjects([error localizedDescription], @"validation error for parameter '2': must be a number", nil);

	STAssertEqualObjects([ParameterValidator underlyingErrorKeys:error], (@[ @[@2] ]), nil);
}

- (void)testReportsAllPrototypeErrors {
	NSError *error = nil;
	STAssertFalse([[[ParameterValidator array] of:[ParameterValidator number]] isPleasedWith:(@[@"y",@1,@"x",@3]) error:&error], nil);

	STAssertEquals([error code], ParameterValidatorErrorCodeBranch, nil);
	STAssertEqualObjects([error domain], ParameterValidatorErrorDomain, nil);
	STAssertEqualObjects([error localizedDescription], @"validation error for multiple parameters", nil);

	STAssertEqualObjects([ParameterValidator underlyingErrorKeys:error], (@[ @[@0], @[@2] ]), nil);
}

- (void)testMinCount {
	STAssertTrue([[[ParameterValidator array] min:@3] isPleasedWith:(@[@1,@2,@3]) error:nil], nil);
}

- (void)testMinCountError {
	NSError *error = nil;
	STAssertFalse([[[ParameterValidator array] min:@3] isPleasedWith:(@[@1,@2]) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must have at least 3 elements", nil);
}

- (void)testMaxCount {
	STAssertTrue([[[ParameterValidator array] max:@3] isPleasedWith:(@[@1,@2,@3]) error:nil], nil);
}

- (void)testMaxCountError {
	NSError *error = nil;
	STAssertFalse([[[ParameterValidator array] max:@3] isPleasedWith:(@[@1,@2,@3,@4]) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must have at most 3 elements", nil);
}

- (void)testMinAndMax {
	STAssertTrue([[[[ParameterValidator array] min:@3] max:@5] isPleasedWith:(@[@1,@2,@3]) error:nil], nil);
}

- (void)testMinAndMaxError {
	ParameterValidator *validator = [[[ParameterValidator array] min:@3] max:@5];
	NSError *error = nil;

	STAssertFalse([validator isPleasedWith:(@[@1,@2]) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must have 3 to 5 elements", nil);

	STAssertFalse([validator isPleasedWith:(@[@1,@2,@3,@4,@5,@6]) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must have 3 to 5 elements", nil);
}

- (void)testSameMinMax {
	NSError *error = nil;
	STAssertFalse([[[[ParameterValidator array] min:@3] max:@3] isPleasedWith:(@[@1,@2]) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must have exactly 3 elements", nil);
}

- (void)testCount {
	STAssertTrue([[[ParameterValidator array] count:@3] isPleasedWith:(@[@1,@2,@3]) error:nil], nil);
}

- (void)testCountErrorSameAsMinMax {
	ParameterValidator *validator = [[ParameterValidator array] count:@3];
	NSError *error = nil;

	STAssertFalse([validator isPleasedWith:(@[@1,@2]) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must have exactly 3 elements", nil);
}

@end
