#import "ArrayValidatorTest.h"
#import "ParameterValidator.h"

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
	STAssertEqualObjects([error localizedDescription], @"must be an array", nil);
}

- (void)testPrototype {
	STAssertTrue([[[ParameterValidator array] of:[ParameterValidator number]] isPleasedWith:(@[@1,@1,@2,@3]) error:nil], nil);
}

- (void)testPrototypeError {
	NSError *error = nil;
	STAssertFalse([[[ParameterValidator array] of:[ParameterValidator number]] isPleasedWith:(@[@1,@1,@"x",@3]) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"parameter 3 must be a number", nil);
}

@end
