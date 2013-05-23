#import "ParameterValidator.h"
#import "Error.h"

@implementation ParameterValidator

+ (instancetype)validator {
	return [[self alloc] init];
}

- (BOOL)isPleasedWith:(id)param error:(NSError **)anError {
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


@implementation ParameterValidator (ConstructionConvenience)

+ (NumberValidator *)number {
	return [NumberValidator validator];
}

+ (StringValidator *)string {
	return [StringValidator validator];
}

+ (HexstringValidator *)hexstring {
	return [HexstringValidator validator];
}

+ (ArrayValidator *)array {
	return [ArrayValidator validator];
}

@end


@implementation NumberValidator

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

- (BOOL)isPleasedWith:(id)param error:(NSError **)anError {
	if (![param isKindOfClass:[NSNumber class]]) {
		if (anError) *anError = CreateError(0, @"must be a number");
		return NO;
	}

	BOOL lowFailed = NO;
	BOOL highFailed = NO;

	if (self.low) {
		NSComparisonResult r = [param compare:self.low];
		if (!self.lowInclusive && r != NSOrderedDescending) lowFailed = YES;
		else if (self.lowInclusive && r == NSOrderedAscending) lowFailed = YES;
	}

	if (self.high) {
		NSComparisonResult r = [param compare:self.high];
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


@implementation StringValidator

- (instancetype)length:(NSNumber *)limit {
	[self min:limit];
	[self max:limit];
	return self;
}

- (instancetype)min:(NSNumber *)limit {
	self.min = limit;
	return self;
}

- (instancetype)max:(NSNumber *)limit {
	self.max = limit;
	return self;
}

- (BOOL)isPleasedWith:(id)param error:(NSError **)anError {
	if (![param isKindOfClass:[NSString class]]) {
		if (anError) *anError = CreateError(0, @"must be a string");
		return NO;
	}

	BOOL minFailed = NO;
	BOOL maxFailed = NO;

	if (self.min)
		minFailed = [param length] < ((NSUInteger)[self.min integerValue]);

	if (self.max)
		maxFailed = [param length] > ((NSUInteger)[self.max integerValue]);

	if (self.min && self.max && (minFailed || maxFailed)) {
		if (anError) {
			if ([self.min isEqual:self.max])
				*anError = CreateError(0, @"must be exactly %@ characters", self.min);
			else
				*anError = CreateError(0, @"must be %@ to %@ characters", self.min, self.max);
		}
		return NO;
	}

	if (minFailed) {
		if (anError)
			*anError = CreateError(0, @"must be at least %@ characters", self.min);
		return NO;
	}

	if (maxFailed) {
		if (anError)
			*anError = CreateError(0, @"must be at most %@ characters", self.max);
		return NO;
	}
	return YES;
}

@end


@implementation HexstringValidator

- (BOOL)isPleasedWith:(id)param error:(NSError **)anError {
	if (![super isPleasedWith:param error:anError]) return NO;

	NSCharacterSet *hexChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"];
	for (NSUInteger i=0; i<[param length]; i++) {
		if ([hexChars characterIsMember:[param characterAtIndex:i]]) continue;
		if (anError)
			*anError = CreateError(0, @"must be a hexstring");
		return NO;
	}

	return YES;
}

@end


@implementation ArrayValidator

- (instancetype)of:(ParameterValidator *)prototype {
	self.prototype = prototype;
	return self;
}

- (BOOL)isPleasedWith:(id)param error:(NSError **)anError {
	if (![param isKindOfClass:[NSArray class]]) {
		if (anError) *anError = CreateError(0, @"must be an array");
		return NO;
	}

	for (NSUInteger i=0; i<[param count]; i++) {
		id item = param[i];
		NSError *paramError = nil;
		if ([self.prototype isPleasedWith:item error:&paramError]) continue;
		if (anError)
			*anError = CreateError(0, @"parameter %lu %@", i+1, [paramError localizedDescription]);
		return NO;
	}

	return YES;
}

@end


@interface DictionaryValidator ()
@property (strong) NSMutableArray *validators;
@end


@implementation DictionaryValidator

+ (instancetype)validator {
	return [[self alloc] init];
}

- (id)init {
	if (!(self = [super init])) return nil;
	self.validators = [[NSMutableArray alloc] init];
	return self;
}

- (void)validate:(NSString *)name with:(id)validator {
	[self.validators addObject:@{@"param":name, @"validator":validator}];
}

- (BOOL)isPleasedWith:(NSDictionary *)parameters error:(NSError **)anError {
	NSMutableSet *processedParameters = [NSMutableSet set];

	for (NSDictionary *each in self.validators) {
		NSString *paramName = each[@"param"];
		ParameterValidator *paramValidator = each[@"validator"];

		[processedParameters addObject:paramName];

		NSString *paramValue = parameters[paramName];
		if (!paramValue) {
			if (paramValidator.isOptional) continue;
			if (anError)
				*anError = CreateError(0, @"missing required parameter '%@'", paramName);
			return NO;
		}

		NSError *paramError = nil;
		if (![paramValidator isPleasedWith:paramValue error:&paramError]) {
			if (anError)
				*anError = CreateError(0, @"parameter '%@' %@", paramName, [paramError localizedDescription]);
			return NO;
		}
	}

	if (!self.allowsExtraParameters) {
		NSMutableSet *superflousParameters = [NSMutableSet setWithArray:[parameters allKeys]];
		[superflousParameters minusSet:processedParameters];
		if ([superflousParameters count]) {
			if (anError)
				*anError = CreateError(0, @"superflous parameters %@", [[[superflousParameters allObjects] sortedArrayUsingSelector:@selector(compare:)] componentsJoinedByString:@", "]);
			return NO;
		}
	}

	return YES;
}

@end
