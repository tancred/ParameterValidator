#import "StringFieldValidatorTest.h"
#import "FieldValidator.h"

@implementation StringFieldValidatorTest

- (void)testInstance {
	STAssertEqualObjects([[StringFieldValidator validator] class], [StringFieldValidator class], nil);
}

- (void)testConvenienceInstance {
	STAssertEqualObjects([[FieldValidator string] class], [StringFieldValidator class], nil);
}

- (void)testPleasedWithString {
	STAssertTrue([[FieldValidator string] isPleasedWith:@"two" error:nil], nil);
}

- (void)testNotPleasedWithNonString {
	NSError *error = nil;
	STAssertFalse([[FieldValidator string] isPleasedWith:@2 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be a string", nil);
}

@end
