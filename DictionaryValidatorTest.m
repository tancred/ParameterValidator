#import "DictionaryValidatorTest.h"
#import "ParameterValidator.h"

@implementation DictionaryValidatorTest

- (void)testInstance {
	STAssertEqualObjects([[DictionaryValidator validator] class], [DictionaryValidator class], nil);
}

- (void)testConvenienceInstance {
	STAssertEqualObjects([[ParameterValidator dictionary] class], [DictionaryValidator class], nil);
}

- (void)testPleasedWithDictionary {
	STAssertTrue([[ParameterValidator dictionary] isPleasedWith:@{} error:nil], nil);
}

- (void)testNotPleasedWithNonDictionary {
	NSError *error = nil;
	STAssertFalse([[ParameterValidator dictionary] isPleasedWith:@2 error:&error], nil);
	STAssertEquals([error code], ParameterValidatorErrorCodeLeaf, nil);
	STAssertEqualObjects([error domain], ParameterValidatorErrorDomain, nil);
	STAssertEqualObjects([error localizedDescription], @"must be a dictionary", nil);
}

- (void)testMandatoryPresent {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[ParameterValidator validator]];
	STAssertTrue([validator isPleasedWith:@{@"param":@"something"} error:nil], nil);
}

- (void)testMandatoryMissing {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[ParameterValidator validator]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:@{} error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"validation error for parameter 'param': missing mandatory", nil);
}

- (void)testOptionalPresent {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[[ParameterValidator validator] optional]];
	STAssertTrue([validator isPleasedWith:@{@"param":@"something"} error:nil], nil);
}

- (void)testOptionalMissing {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[[ParameterValidator validator] optional]];
	STAssertTrue([validator isPleasedWith:@{} error:nil], nil);
}

- (void)testPleasedWithParameter {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[[ParameterValidator number] lessThan:@4]];
	STAssertTrue([validator isPleasedWith:@{@"param":@3} error:nil], nil);
}

- (void)testNotPleasedWithParameter {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[[ParameterValidator number] lessThan:@4]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:@{@"param":@4} error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"validation error for parameter 'param': must be less than 4", nil);
}

- (void)testParametersValidatedInOrder {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param1" with:[[ParameterValidator number] lessThan:@4]];
	[validator validate:@"param2" with:[ParameterValidator number]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:(@{@"param1":@3, @"param2":@"str"}) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"validation error for parameter 'param2': must be a number", nil);
}

- (void)testNotPleasedWithExtraParameters {
	DictionaryValidator *validator = [[DictionaryValidator validator] merciless];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:(@{@"param1":@3, @"param2":@"str", @"param3":@2}) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"validation error for multiple parameters", nil);

	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];
	STAssertEquals([keys count], (NSUInteger)3, nil);
	STAssertTrue([keys containsObject:@[@"param1"]], nil);
	STAssertTrue([keys containsObject:@[@"param2"]], nil);
	STAssertTrue([keys containsObject:@[@"param3"]], nil);
}

- (void)testPleasedWithExtraParameters {
	DictionaryValidator *validator = [[DictionaryValidator validator] merciful];
	STAssertTrue([validator isPleasedWith:(@{@"param1":@3, @"param2":@"str", @"param3":@2}) error:nil], nil);
}

- (void)testNested {
	DictionaryValidator *validator = [[ [DictionaryValidator validator]
		validate:@"param1" with:[[ParameterValidator dictionary] optional] ]
		validate:@"param2" with:[ParameterValidator dictionary] ];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:(@{@"param2":@2}) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"validation error for parameter 'param2': must be a dictionary", nil);
}

- (void)testParameterErrorIsABranchError {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[[ParameterValidator number] lessThan:@4]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:@{@"param":@4} error:&error], nil);
	STAssertEquals([error code], ParameterValidatorErrorCodeBranch, nil);
	STAssertEqualObjects([error domain], ParameterValidatorErrorDomain, nil);
	STAssertEqualObjects([error localizedDescription], @"validation error for parameter 'param': must be less than 4", nil);
}

- (void)testReportsAllParameterErrors {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param1" with:[[ParameterValidator number] lessThan:@4]];
	[validator validate:@"param2" with:[ParameterValidator validator]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:(@{@"param1":@4,@"param3":@"x",@"param4":@"y"}) error:&error], nil);
	STAssertEquals([error code], ParameterValidatorErrorCodeBranch, nil);
	STAssertEqualObjects([error domain], ParameterValidatorErrorDomain, nil);
	STAssertEqualObjects([error localizedDescription], @"validation error for multiple parameters", nil);

	STAssertEqualObjects([ParameterValidator underlyingErrorKeys:error], (@[ @[@"param1"],@[@"param2"],@[@"param3"],@[@"param4"] ]), nil);
}

@end
