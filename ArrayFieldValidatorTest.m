#import "ArrayFieldValidatorTest.h"
#import "FieldValidator.h"

@implementation ArrayFieldValidatorTest

- (void)testInstance {
	STAssertEqualObjects([[ArrayFieldValidator validator] class], [ArrayFieldValidator class], nil);
}

- (void)testConvenienceInstance {
	STAssertEqualObjects([[FieldValidator array] class], [ArrayFieldValidator class], nil);
}

- (void)testPleasedWithArray {
	STAssertTrue([[FieldValidator array] isPleasedWith:@[] error:nil], nil);
}

- (void)testNotPleasedWithNonArray {
	NSError *error = nil;
	STAssertFalse([[FieldValidator array] isPleasedWith:@2 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be an array", nil);
}

- (void)testPrototype {
	STAssertTrue([[[FieldValidator array] of:[FieldValidator number]] isPleasedWith:(@[@1,@1,@2,@3]) error:nil], nil);
}

- (void)testPrototypeError {
	NSError *error = nil;
	STAssertFalse([[[FieldValidator array] of:[FieldValidator number]] isPleasedWith:(@[@1,@1,@"x",@3]) error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"parameter 3 must be a number", nil);
}

@end
