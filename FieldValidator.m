#import "FieldValidator.h"
#import "Error.h"

@implementation FieldValidator

+ (instancetype)validator {
	return [[self alloc] init];
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
		if (anError) *anError = CreateError(0, @"must be a number");
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
