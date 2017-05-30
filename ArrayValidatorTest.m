#import <XCTest/XCTest.h>
#import "ParameterValidator.h"

@interface ArrayValidatorTest : XCTestCase
@end

@implementation ArrayValidatorTest

- (void)testInstance {
	XCTAssertEqualObjects([[ArrayValidator validator] class], [ArrayValidator class]);
}

- (void)testConvenienceInstance {
	XCTAssertEqualObjects([[ParameterValidator array] class], [ArrayValidator class]);
}

- (void)testPleasedWithArray {
	XCTAssert([[ParameterValidator array] isPleasedWith:@[] error:nil]);
}

- (void)testNotPleasedWithNonArray {
	NSError *error = nil;
	XCTAssertFalse([[ParameterValidator array] isPleasedWith:@2 error:&error]);
	XCTAssertEqual([error code], ParameterValidatorErrorCodeLeaf);
	XCTAssertEqualObjects([error domain], ParameterValidatorErrorDomain);
	XCTAssertEqualObjects([error localizedDescription], @"must be an array");
}

- (void)testPrototype {
	XCTAssert([[[ParameterValidator array] of:[ParameterValidator number]] isPleasedWith:(@[@1,@1,@2,@3]) error:nil]);
}

- (void)testPrototypeError {
	NSError *error = nil;
	XCTAssertFalse([[[ParameterValidator array] of:[ParameterValidator number]] isPleasedWith:(@[@1,@1,@"x",@3]) error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"validation error for parameter '2': must be a number");
}

- (void)testPrototypeErrorIsABranchError {
	NSError *error = nil;
	XCTAssertFalse([[[ParameterValidator array] of:[ParameterValidator number]] isPleasedWith:(@[@1,@1,@"x",@3]) error:&error]);

	XCTAssertEqual([error code], ParameterValidatorErrorCodeBranch);
	XCTAssertEqualObjects([error domain], ParameterValidatorErrorDomain);
	XCTAssertEqualObjects([error localizedDescription], @"validation error for parameter '2': must be a number");

	XCTAssertEqualObjects([ParameterValidator underlyingErrorKeys:error], (@[ @[@2] ]));
}

- (void)testReportsAllPrototypeErrors {
	NSError *error = nil;
	XCTAssertFalse([[[ParameterValidator array] of:[ParameterValidator number]] isPleasedWith:(@[@"y",@1,@"x",@3]) error:&error]);

	XCTAssertEqual([error code], ParameterValidatorErrorCodeBranch);
	XCTAssertEqualObjects([error domain], ParameterValidatorErrorDomain);
	XCTAssertEqualObjects([error localizedDescription], @"validation error for multiple parameters");

	XCTAssertEqualObjects([ParameterValidator underlyingErrorKeys:error], (@[ @[@0], @[@2] ]));
}

- (void)testMinCount {
	XCTAssert([[[ParameterValidator array] min:@3] isPleasedWith:(@[@1,@2,@3]) error:nil]);
}

- (void)testMinCountError {
	NSError *error = nil;
	XCTAssertFalse([[[ParameterValidator array] min:@3] isPleasedWith:(@[@1,@2]) error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must have at least 3 elements");
}

- (void)testMaxCount {
	XCTAssert([[[ParameterValidator array] max:@3] isPleasedWith:(@[@1,@2,@3]) error:nil]);
}

- (void)testMaxCountError {
	NSError *error = nil;
	XCTAssertFalse([[[ParameterValidator array] max:@3] isPleasedWith:(@[@1,@2,@3,@4]) error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must have at most 3 elements");
}

- (void)testMinAndMax {
	XCTAssert([[[[ParameterValidator array] min:@3] max:@5] isPleasedWith:(@[@1,@2,@3]) error:nil]);
}

- (void)testMinAndMaxError {
	ParameterValidator *validator = [[[ParameterValidator array] min:@3] max:@5];
	NSError *error = nil;

	XCTAssertFalse([validator isPleasedWith:(@[@1,@2]) error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must have 3 to 5 elements");

	XCTAssertFalse([validator isPleasedWith:(@[@1,@2,@3,@4,@5,@6]) error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must have 3 to 5 elements");
}

- (void)testSameMinMax {
	NSError *error = nil;
	XCTAssertFalse([[[[ParameterValidator array] min:@3] max:@3] isPleasedWith:(@[@1,@2]) error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must have exactly 3 elements");
}

- (void)testCount {
	XCTAssert([[[ParameterValidator array] count:@3] isPleasedWith:(@[@1,@2,@3]) error:nil]);
}

- (void)testCountErrorSameAsMinMax {
	ParameterValidator *validator = [[ParameterValidator array] count:@3];
	NSError *error = nil;

	XCTAssertFalse([validator isPleasedWith:(@[@1,@2]) error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"must have exactly 3 elements");
}

@end
