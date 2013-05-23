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
	STAssertFalse([validator isPleasedWith:@{@"paramZ":@"something"} error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"missing required parameter 'param'", nil);
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

- (void)testPleasedWithField {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[[ParameterValidator number] lessThan:@4]];
	STAssertTrue([validator isPleasedWith:@{@"param":@3} error:nil], nil);
}

- (void)testNotPleasedWithField {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param" with:[[ParameterValidator number] lessThan:@4]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:@{@"param":@4} error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"parameter 'param' must be less than 4", nil);
}

- (void)testFieldsValidatedInOrder {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"param1" with:[[ParameterValidator number] lessThan:@4]];
	[validator validate:@"param2" with:[ParameterValidator number]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:(@{@"param1":@3, @"param2":@"str"}) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"parameter 'param2' must be a number", nil);
}

- (void)testNotPleasedWithExtraParameters {
	NSError *error = nil;
	STAssertFalse([[DictionaryValidator validator] isPleasedWith:(@{@"param1":@3, @"param2":@"str", @"param3":@2}) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"superflous parameters param1, param2, param3", nil);
}

- (void)testPleasedWithExtraParameters {
	DictionaryValidator *validator = [DictionaryValidator validator];
	validator.allowsExtraParameters = YES;
	STAssertTrue([validator isPleasedWith:(@{@"param1":@3, @"param2":@"str", @"param3":@2}) error:nil], nil);
}

@end
