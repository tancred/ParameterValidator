#import "DictionaryValidatorTest.h"
#import "DictionaryValidator.h"
#import "ParameterValidator.h"

@implementation DictionaryValidatorTest

- (void)testAlwaysPleased {
	STAssertTrue([[DictionaryValidator validator] isPleasedWith:nil error:nil], nil);
	STAssertTrue([[DictionaryValidator validator] isPleasedWith:@{} error:nil], nil);
}

- (void)testMandatoryPresent {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"field" with:[ParameterValidator validator]];
	STAssertTrue([validator isPleasedWith:@{@"field":@"something"} error:nil], nil);
}

- (void)testMandatoryMissing {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"field" with:[ParameterValidator validator]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:@{@"fieldZ":@"something"} error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"missing required parameter 'field'", nil);
}

- (void)testOptionalPresent {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"field" with:[[ParameterValidator validator] optional]];
	STAssertTrue([validator isPleasedWith:@{@"field":@"something"} error:nil], nil);
}

- (void)testOptionalMissing {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"field" with:[[ParameterValidator validator] optional]];
	STAssertTrue([validator isPleasedWith:@{} error:nil], nil);
}

- (void)testPleasedWithField {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"field" with:[[ParameterValidator number] lessThan:@4]];
	STAssertTrue([validator isPleasedWith:@{@"field":@3} error:nil], nil);
}

- (void)testNotPleasedWithField {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"field" with:[[ParameterValidator number] lessThan:@4]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:@{@"field":@4} error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"parameter 'field' must be less than 4", nil);
}

- (void)testFieldsValidatedInOrder {
	DictionaryValidator *validator = [DictionaryValidator validator];
	[validator validate:@"field1" with:[[ParameterValidator number] lessThan:@4]];
	[validator validate:@"field2" with:[ParameterValidator number]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:(@{@"field1":@3, @"field2":@"str"}) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"parameter 'field2' must be a number", nil);
}

- (void)testNotPleasedWithExtraParameters {
	NSError *error = nil;
	STAssertFalse([[DictionaryValidator validator] isPleasedWith:(@{@"field1":@3, @"field2":@"str", @"field3":@2}) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"superflous parameters field1, field2, field3", nil);
}

- (void)testPleasedWithExtraParameters {
	DictionaryValidator *validator = [DictionaryValidator validator];
	validator.allowsExtraParameters = YES;
	STAssertTrue([validator isPleasedWith:(@{@"field1":@3, @"field2":@"str", @"field3":@2}) error:nil], nil);
}

@end
