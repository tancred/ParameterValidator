#import "FieldValidatorTest.h"
#import "FieldValidator.h"

@implementation FieldValidatorTest

- (void)testInstance {
	STAssertEqualObjects([[FieldValidator validator] class], [FieldValidator class], nil);
}

- (void)testMandatoryByDefault {
	STAssertFalse([[FieldValidator validator] isOptional], nil);
}

- (void)testOptional {
	STAssertTrue([[[FieldValidator validator] optional] isOptional], nil);
}

- (void)testMandatory {
	STAssertFalse([[[[FieldValidator validator] optional] mandatory] isOptional], nil);
}

- (void)testOptionalReturnsSelf {
	FieldValidator *validator = [FieldValidator validator];
	FieldValidator *optional = [validator optional];
	STAssertEquals(validator, optional, nil);
}

- (void)testMandatoryReturnsSelf {
	FieldValidator *validator = [FieldValidator validator];
	FieldValidator *mandatory = [validator mandatory];
	STAssertEquals(validator, mandatory, nil);
}

- (void)testAlwaysPleased {
	STAssertTrue([[FieldValidator validator] isPleasedWith:nil error:nil], nil);
}

@end
