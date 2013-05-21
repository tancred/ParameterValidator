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
@property (copy) NSNumber *low;
@property (copy) NSNumber *high;
@property (assign) BOOL lowInclusive;
@property (assign) BOOL highInclusive;

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

- (instancetype)atMost:(NSNumber *)limit {
	self.high = limit;
	self.highInclusive = YES;
	return self;
}

- (instancetype)lessThan:(NSNumber *)limit {
	self.high = limit;
	self.highInclusive = NO;
	return self;
}

- (instancetype)atLeast:(NSNumber *)limit {
	self.low = limit;
	self.lowInclusive = YES;
	return self;
}

- (instancetype)greaterThan:(NSNumber *)limit {
	self.low = limit;
	self.lowInclusive = NO;
	return self;
}

- (BOOL)isPleasedWith:(id)field error:(NSError **)anError {
	if (![field isKindOfClass:[NSNumber class]]) {
		if (anError) *anError = CreateError(0, @"not a number");
		return NO;
	}

	BOOL lowFailed = NO;
	BOOL highFailed = NO;

	if (self.low) {
		NSComparisonResult r = [field compare:self.low];
		if (!self.lowInclusive && r != NSOrderedDescending) lowFailed = YES;
		else if (self.lowInclusive && r == NSOrderedAscending) lowFailed = YES;
	}

	if (self.high) {
		NSComparisonResult r = [field compare:self.high];
		if (!self.highInclusive && r != NSOrderedAscending) highFailed = YES;
		else if (self.highInclusive && r == NSOrderedDescending) highFailed = YES;
	}

	if (self.low && self.high && (lowFailed || highFailed)) {
		if (anError)
			*anError = CreateError(0, @"must be in %@%@,%@%@", self.lowInclusive ? @"[" : @"(", self.low, self.high, self.highInclusive ? @"]" : @")");
		return NO;
	}
	if (lowFailed) {
		if (anError)
			*anError = CreateError(0, @"must be %@ %@", self.lowInclusive ? @"at least" : @"greater than", self.low);
		return NO;
	}
	if (highFailed) {
		if (anError)
			*anError = CreateError(0, @"must be %@ %@", self.highInclusive ? @"at most" : @"less than", self.high);
		return NO;
	}

	return YES;
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
	STAssertEqualObjects([error localizedDescription], @"not a number", nil);
}

- (void)testLessThan {
	STAssertTrue([[[FieldValidator number] lessThan:@3] isPleasedWith:@2 error:nil], nil);
}

- (void)testLessThanError {
	NSError *error = nil;
	STAssertFalse([[[FieldValidator number] lessThan:@3] isPleasedWith:@3 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be less than 3", nil);
}

- (void)testAtMost {
	STAssertTrue([[[FieldValidator number] atMost:@3] isPleasedWith:@3 error:nil], nil);
}

- (void)testAtMostError {
	NSError *error = nil;
	STAssertFalse([[[FieldValidator number] atMost:@3] isPleasedWith:@4 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be at most 3", nil);
}

- (void)testGreaterThan {
	STAssertTrue([[[FieldValidator number] greaterThan:@3] isPleasedWith:@4 error:nil], nil);
}

- (void)testGreaterThanError {
	NSError *error = nil;
	STAssertFalse([[[FieldValidator number] greaterThan:@3] isPleasedWith:@3 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be greater than 3", nil);
}

- (void)testAtLeast {
	STAssertTrue([[[FieldValidator number] atLeast:@3] isPleasedWith:@3 error:nil], nil);
}

- (void)testAtLeastError {
	NSError *error = nil;
	STAssertFalse([[[FieldValidator number] atLeast:@3] isPleasedWith:@2 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be at least 3", nil);
}

- (void)testLowAndHigh {
	STAssertTrue([[[[FieldValidator number] atLeast:@3] atMost:@5] isPleasedWith:@4 error:nil], nil);
}

- (void)testLowAndHighError {
	FieldValidator *validator = [[[FieldValidator number] atLeast:@3] lessThan:@5];
	NSError *error = nil;

	STAssertFalse([validator isPleasedWith:@2 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be in [3,5)", nil);

	STAssertFalse([validator isPleasedWith:@5 error:&error], nil);
	STAssertEqualObjects([error localizedDescription], @"must be in [3,5)", nil);
}

@end
