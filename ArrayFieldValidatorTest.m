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

@end
