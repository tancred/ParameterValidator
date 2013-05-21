#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

@interface ParameterValidator : NSObject
@property BOOL allowsExtraParameters;
- (void)requireField:(NSString *)name conformsTo:(id)validator;
- (BOOL)isPleasedWith:(id)parameters error:(NSError **)anError;
	// Params normally dictionary but should really just respond to -objectForKey: and -allKeys (for checking extra parameters).
	// Process validators in order registered
	// Allow multiple validators for a field? Allow contradictions?
@end


@interface FieldValidator : NSObject
@property BOOL isOptional; // used by ParameterValidator, not selfs -isPleasedWith:error:

+ (instancetype)validator;
- (BOOL)isPleasedWith:(id)field error:(NSError **)anError;

- (instancetype)mandatory;
- (instancetype)optional;
@end

@interface NumberFieldValidator : FieldValidator
// no strict type checking; use other validator for that
- (instancetype)atMost:(NSNumber *)limit;
- (instancetype)lessThan:(NSNumber *)limit;
- (instancetype)atLeast:(NSNumber *)limit;
- (instancetype)greaterThan:(NSNumber *)limit;
@end

@interface StringFieldValidator : FieldValidator
- (instancetype)length:(NSUInteger)limit; // min == max
- (instancetype)min:(NSUInteger)limit;
- (instancetype)max:(NSUInteger)limit;
@end

@interface HexstringFieldValidator : StringFieldValidator
- (instancetype)bits:(NSUInteger)limit; // minBits == maxBits
- (instancetype)minBits:(NSUInteger)limit;
- (instancetype)maxBits:(NSUInteger)limit;
@end

@interface ArrayFieldValidator : FieldValidator
- (instancetype)of:(FieldValidator *)prototype;
@end

@interface PredicateFieldValidator : NSObject
@end

@interface FieldValidator (ConstructionConvenience)
+ (NumberFieldValidator *)number;
+ (StringFieldValidator *)string;
+ (HexstringFieldValidator *)hexstring;
+ (ArrayFieldValidator *)array;
@end


static NSError *CreateError(NSInteger code, NSString *descriptionFormat, ...) NS_FORMAT_FUNCTION(2, 3);
static NSError *CreateErrorFixedArgs(NSInteger code, NSString *descriptionFormat, va_list args) NS_FORMAT_FUNCTION(2, 0);


int main() {
	@autoreleasepool {
		return SenSelfTestMain();
	}
	return 0;
}

@implementation FieldValidator
+ (instancetype)validator {
	return [[[self class] alloc] init];
}

- (BOOL)isPleasedWith:(id)field error:(NSError **)anError {
	return YES;
}

- (instancetype)mandatory {
	self.isOptional = NO;
	return self;
}
- (instancetype)optional {
	self.isOptional = YES;
	return self;
}
@end


@implementation FieldValidator (ConstructionConvenience)

+ (NumberFieldValidator *)number {
	return [NumberFieldValidator validator];
}

+ (StringFieldValidator *)string {
	return nil;
}

+ (HexstringFieldValidator *)hexstring {
	return nil;
}

+ (ArrayFieldValidator *)array {
	return nil;
}

@end


@implementation NumberFieldValidator

- (BOOL)isPleasedWith:(id)field error:(NSError **)anError {
	if ([field isKindOfClass:[NSNumber class]]) return YES;
	if (anError)
		*anError = CreateError(0, @"not a number");
	return NO;
}

@end


static NSError *CreateError(NSInteger code, NSString *descriptionFormat, ...) {
	va_list args;
	va_start(args, descriptionFormat);
	NSError *error = CreateErrorFixedArgs(code, descriptionFormat, args);
	va_end(args);
	return error;
}

static NSError *CreateErrorFixedArgs(NSInteger code, NSString *descriptionFormat, va_list args) {
	NSString *description = [[NSString alloc] initWithFormat:descriptionFormat arguments:args];
	return [NSError errorWithDomain:@"com.tancred.parametervalidator" code:code userInfo:@{NSLocalizedDescriptionKey: description}];
}


@interface FieldValidatorTest : SenTestCase
@end

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


@interface NumberFieldValidatorTest : SenTestCase
@end

@implementation NumberFieldValidatorTest

- (void)testInstance {
	STAssertEqualObjects([[NumberFieldValidator validator] class], [NumberFieldValidator class], nil);
}

- (void)testConvenienceInstance {
	STAssertEqualObjects([[FieldValidator number] class], [NumberFieldValidator class], nil);
}

- (void)testPleasedWithNumber {
	STAssertTrue([[FieldValidator number] isPleasedWith:@2 error:nil], nil);
}

- (void)testNotPleasedWithNonNumber {
	NSError *error = nil;
	STAssertFalse([[FieldValidator number] isPleasedWith:@"two" error:&error], nil);
	STAssertNotNil(error, nil);
	STAssertEqualObjects([error localizedDescription], @"not a number", nil);
}

@end
