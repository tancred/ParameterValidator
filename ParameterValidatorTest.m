#import <XCTest/XCTest.h>
#import "ParameterValidator.h"

@interface ParameterValidatorTest : XCTestCase
@end

@implementation ParameterValidatorTest

- (void)testInstance {
	XCTAssertEqualObjects([[ParameterValidator validator] class], [ParameterValidator class]);
}

- (void)testMandatoryByDefault {
	XCTAssertFalse([[ParameterValidator validator] isOptional]);
}

- (void)testOptional {
	XCTAssert([[[ParameterValidator validator] optional] isOptional]);
}

- (void)testMandatory {
	XCTAssertFalse([[[[ParameterValidator validator] optional] mandatory] isOptional]);
}

- (void)testOptionalReturnsSelf {
	ParameterValidator *validator = [ParameterValidator validator];
	ParameterValidator *optional = [validator optional];
	XCTAssertEqual(validator, optional);
}

- (void)testMandatoryReturnsSelf {
	ParameterValidator *validator = [ParameterValidator validator];
	ParameterValidator *mandatory = [validator mandatory];
	XCTAssertEqual(validator, mandatory);
}

- (void)testAlwaysPleased {
	XCTAssert([[ParameterValidator validator] isPleasedWith:nil error:nil]);
}

@end
