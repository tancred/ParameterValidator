#import <SenTestingKit/SenTestingKit.h>
#import "ParameterValidator.h"

@interface ParameterValidatorTest : SenTestCase
@end

@implementation ParameterValidatorTest

- (void)testInstance {
	STAssertEqualObjects([[ParameterValidator validator] class], [ParameterValidator class], nil);
}

- (void)testMandatoryByDefault {
	STAssertFalse([[ParameterValidator validator] isOptional], nil);
}

- (void)testOptional {
	STAssertTrue([[[ParameterValidator validator] optional] isOptional], nil);
}

- (void)testMandatory {
	STAssertFalse([[[[ParameterValidator validator] optional] mandatory] isOptional], nil);
}

- (void)testOptionalReturnsSelf {
	ParameterValidator *validator = [ParameterValidator validator];
	ParameterValidator *optional = [validator optional];
	STAssertEquals(validator, optional, nil);
}

- (void)testMandatoryReturnsSelf {
	ParameterValidator *validator = [ParameterValidator validator];
	ParameterValidator *mandatory = [validator mandatory];
	STAssertEquals(validator, mandatory, nil);
}

- (void)testAlwaysPleased {
	STAssertTrue([[ParameterValidator validator] isPleasedWith:nil error:nil], nil);
}

@end
