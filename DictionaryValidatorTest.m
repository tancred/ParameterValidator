#import <XCTest/XCTest.h>
#import "ParameterValidator.h"

@interface DictionaryValidatorTest : XCTestCase
@end

@implementation DictionaryValidatorTest

- (void)testInstance {
	XCTAssertEqualObjects([[DictionaryValidator validator] class], [DictionaryValidator class]);
}

- (void)testConvenienceInstance {
	XCTAssertEqualObjects([[ParameterValidator dictionary] class], [DictionaryValidator class]);
}

- (void)testPleasedWithDictionary {
	XCTAssert([[ParameterValidator dictionary] isPleasedWith:@{} error:nil]);
}

- (void)testNotPleasedWithNonDictionary {
	NSError *error = nil;
	XCTAssertFalse([[ParameterValidator dictionary] isPleasedWith:@2 error:&error]);
	XCTAssertEqual([error code], ParameterValidatorErrorCodeLeaf);
	XCTAssertEqualObjects([error domain], ParameterValidatorErrorDomain);
	XCTAssertEqualObjects([error localizedDescription], @"must be a dictionary");
}

- (void)testMandatoryPresent {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[ParameterValidator validator]];
	XCTAssert([validator isPleasedWith:@{@"param":@"something"} error:nil]);
}

- (void)testMandatoryMissing {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[ParameterValidator validator]];

	NSError *error = nil;
	XCTAssertFalse([validator isPleasedWith:@{} error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"validation error for parameter 'param': is missing");
}

- (void)testOptionalPresent {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[[ParameterValidator validator] optional]];
	XCTAssert([validator isPleasedWith:@{@"param":@"something"} error:nil]);
}

- (void)testOptionalMissing {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[[ParameterValidator validator] optional]];
	XCTAssert([validator isPleasedWith:@{} error:nil]);
}

- (void)testPleasedWithParameter {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[[ParameterValidator number] lessThan:@4]];
	XCTAssert([validator isPleasedWith:@{@"param":@3} error:nil]);
}

- (void)testNotPleasedWithParameter {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[[ParameterValidator number] lessThan:@4]];

	NSError *error = nil;
	XCTAssertFalse([validator isPleasedWith:@{@"param":@4} error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"validation error for parameter 'param': must be less than 4");
}

- (void)testParametersValidatedInOrder {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param1" with:[[ParameterValidator number] lessThan:@4]];
	[validator validate:@"param2" with:[ParameterValidator number]];

	NSError *error = nil;
	XCTAssertFalse([validator isPleasedWith:(@{@"param1":@3, @"param2":@"str"}) error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"validation error for parameter 'param2': must be a number");
}

- (void)testNotPleasedWithExtraParameters {
	DictionaryValidator *validator = [[DictionaryValidator validator] merciless];

	NSError *error = nil;
	XCTAssertFalse([validator isPleasedWith:(@{@"param1":@3, @"param2":@"str", @"param3":@2}) error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"validation error for multiple parameters");

	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];
	XCTAssertEqual([keys count], (NSUInteger)3);
	XCTAssert([keys containsObject:@[@"param1"]]);
	XCTAssert([keys containsObject:@[@"param2"]]);
	XCTAssert([keys containsObject:@[@"param3"]]);
}

- (void)testPleasedWithExtraParameters {
	DictionaryValidator *validator = [[DictionaryValidator validator] merciful];
	XCTAssert([validator isPleasedWith:(@{@"param1":@3, @"param2":@"str", @"param3":@2}) error:nil]);
}

- (void)testNested {
	DictionaryValidator *validator = [[ [DictionaryValidator validator]
		validate:@"param1" with:[[ParameterValidator dictionary] optional] ]
		validate:@"param2" with:[ParameterValidator dictionary] ];

	NSError *error = nil;
	XCTAssertFalse([validator isPleasedWith:(@{@"param2":@2}) error:&error]);
	XCTAssertEqualObjects([error localizedDescription], @"validation error for parameter 'param2': must be a dictionary");
}

- (void)testParameterErrorIsABranchError {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[[ParameterValidator number] lessThan:@4]];

	NSError *error = nil;
	XCTAssertFalse([validator isPleasedWith:@{@"param":@4} error:&error]);
	XCTAssertEqual([error code], ParameterValidatorErrorCodeBranch);
	XCTAssertEqualObjects([error domain], ParameterValidatorErrorDomain);
	XCTAssertEqualObjects([error localizedDescription], @"validation error for parameter 'param': must be less than 4");
}

- (void)testReportsAllParameterErrors {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param1" with:[[ParameterValidator number] lessThan:@4]];
	[validator validate:@"param2" with:[ParameterValidator validator]];

	NSError *error = nil;
	XCTAssertFalse([validator isPleasedWith:(@{@"param1":@4,@"param3":@"x",@"param4":@"y"}) error:&error]);
	XCTAssertEqual([error code], ParameterValidatorErrorCodeBranch);
	XCTAssertEqualObjects([error domain], ParameterValidatorErrorDomain);
	XCTAssertEqualObjects([error localizedDescription], @"validation error for multiple parameters");

	XCTAssertEqualObjects([ParameterValidator underlyingErrorKeys:error], (@[ @[@"param1"],@[@"param2"],@[@"param3"],@[@"param4"] ]));
}

@end
