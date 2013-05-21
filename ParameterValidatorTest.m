#import "ParameterValidatorTest.h"
#import "ParameterValidator.h"
#import "FieldValidator.h"

@implementation ParameterValidatorTest

- (void)testAlwaysPleased {
	STAssertTrue([[ParameterValidator validator] isPleasedWith:nil error:nil], nil);
	STAssertTrue([[ParameterValidator validator] isPleasedWith:@{} error:nil], nil);
}

- (void)testMandatoryPresent {
	ParameterValidator *validator = [ParameterValidator validator];
	[validator requireField:@"field" conformsTo:[FieldValidator validator]];
	STAssertTrue([validator isPleasedWith:@{@"field":@"something"} error:nil], nil);
}

- (void)testMandatoryMissing {
	ParameterValidator *validator = [ParameterValidator validator];
	[validator requireField:@"field" conformsTo:[FieldValidator validator]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:@{@"fieldZ":@"something"} error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"missing required parameter 'field'", nil);
}

- (void)testOptionalPresent {
	ParameterValidator *validator = [ParameterValidator validator];
	[validator requireField:@"field" conformsTo:[[FieldValidator validator] optional]];
	STAssertTrue([validator isPleasedWith:@{@"field":@"something"} error:nil], nil);
}

- (void)testOptionalMissing {
	ParameterValidator *validator = [ParameterValidator validator];
	[validator requireField:@"field" conformsTo:[[FieldValidator validator] optional]];
	STAssertTrue([validator isPleasedWith:@{} error:nil], nil);
}

- (void)testPleasedWithField {
	ParameterValidator *validator = [ParameterValidator validator];
	[validator requireField:@"field" conformsTo:[[FieldValidator number] lessThan:@4]];
	STAssertTrue([validator isPleasedWith:@{@"field":@3} error:nil], nil);
}

- (void)testNotPleasedWithField {
	ParameterValidator *validator = [ParameterValidator validator];
	[validator requireField:@"field" conformsTo:[[FieldValidator number] lessThan:@4]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:@{@"field":@4} error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"parameter 'field' must be less than 4", nil);
}

- (void)testFieldsValidatedInOrder {
	ParameterValidator *validator = [ParameterValidator validator];
	[validator requireField:@"field1" conformsTo:[[FieldValidator number] lessThan:@4]];
	[validator requireField:@"field2" conformsTo:[FieldValidator number]];

	NSError *error = nil;
	STAssertFalse([validator isPleasedWith:(@{@"field1":@3, @"field2":@"str"}) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"parameter 'field2' must be a number", nil);
}

- (void)testNotPleasedWithExtraParameters {
	NSError *error = nil;
	STAssertFalse([[ParameterValidator validator] isPleasedWith:(@{@"field1":@3, @"field2":@"str", @"field3":@2}) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"superflous parameters field1, field2, field3", nil);
}

- (void)testPleasedWithExtraParameters {
	ParameterValidator *validator = [ParameterValidator validator];
	validator.allowsExtraParameters = YES;
	STAssertTrue([validator isPleasedWith:(@{@"field1":@3, @"field2":@"str", @"field3":@2}) error:nil], nil);
}

@end
