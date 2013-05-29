#import "ParameterValidator.h"

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

+ (DictionaryValidator *)dictionary {
	return [DictionaryValidator validator];
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
		if (anError) *anError = [ParameterValidator leafError:@"must be a number"];
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
			*anError = [ParameterValidator leafError:@"must be in %@%@,%@%@", self.lowInclusive ? @"[" : @"(", self.low, self.high, self.highInclusive ? @"]" : @")"];
		return NO;
	}
	if (lowFailed) {
		if (anError)
			*anError = [ParameterValidator leafError:@"must be %@ %@", self.lowInclusive ? @"at least" : @"greater than", self.low];
		return NO;
	}
	if (highFailed) {
		if (anError)
			*anError = [ParameterValidator leafError:@"must be %@ %@", self.highInclusive ? @"at most" : @"less than", self.high];
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
		if (anError) *anError = [ParameterValidator leafError:@"must be a string"];
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
				*anError = [ParameterValidator leafError:@"must be exactly %@ characters", self.min];
			else
				*anError = [ParameterValidator leafError:@"must be %@ to %@ characters", self.min, self.max];
		}
		return NO;
	}

	if (minFailed) {
		if (anError)
			*anError = [ParameterValidator leafError:@"must be at least %@ characters", self.min];
		return NO;
	}

	if (maxFailed) {
		if (anError)
			*anError = [ParameterValidator leafError:@"must be at most %@ characters", self.max];
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
			*anError = [ParameterValidator leafError:@"must be a hexstring"];
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

- (instancetype)count:(NSNumber *)limit {
	self.min = limit;
	self.max = limit;
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
	if (![param isKindOfClass:[NSArray class]]) {
		if (anError) *anError = [ParameterValidator leafError:@"must be an array"];
		return NO;
	}

	BOOL minFailed = NO;
	BOOL maxFailed = NO;

	if (self.min)
		minFailed = [param count] < ((NSUInteger)[self.min integerValue]);

	if (self.max)
		maxFailed = [param count] > ((NSUInteger)[self.max integerValue]);

	if (self.min && self.max && (minFailed || maxFailed)) {
		if (anError) {
			if ([self.min isEqual:self.max])
				*anError = [ParameterValidator leafError:@"must have exactly %@ elements", self.min];
			else
				*anError = [ParameterValidator leafError:@"must have %@ to %@ elements", self.min, self.max];
		}
		return NO;
	}

	if (minFailed) {
		if (anError)
			*anError = [ParameterValidator leafError:@"must have at least %@ elements", self.min];
		return NO;
	}

	if (maxFailed) {
		if (anError)
			*anError = [ParameterValidator leafError:@"must have at most %@ elements", self.max];
		return NO;
	}

	NSMutableArray *underlyingErrors = [NSMutableArray array];

	if (self.prototype) {
		for (NSUInteger i=0; i<[param count]; i++) {
			id item = param[i];
			NSError *paramError = nil;
			if ([self.prototype isPleasedWith:item error:&paramError]) continue;
			[underlyingErrors addObject: @[ @(i), paramError ]];
		}
	}

	if ([underlyingErrors count]) {
		if (anError)
			*anError = [ParameterValidator branchErrorForKeyedErrors:underlyingErrors];
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

- (instancetype)merciless {
	self.allowsExtraParameters = NO;
	return self;
}

- (instancetype)merciful {
	self.allowsExtraParameters = YES;
	return self;
}

- (instancetype)validate:(NSString *)name with:(id)validator {
	[self.validators addObject:@{@"param":name, @"validator":validator}];
	return self;
}

- (BOOL)isPleasedWith:(id)param error:(NSError **)anError {
	if (![param isKindOfClass:[NSDictionary class]]) {
		if (anError) *anError = [ParameterValidator leafError:@"must be a dictionary"];
		return NO;
	}

	NSMutableSet *processedParameters = [NSMutableSet set];
	NSMutableArray *underlyingErrors = [NSMutableArray array];

	for (NSDictionary *each in self.validators) {
		NSString *paramName = each[@"param"];
		ParameterValidator *paramValidator = each[@"validator"];

		[processedParameters addObject:paramName];

		NSString *paramValue = param[paramName];
		if (!paramValue) {
			if (paramValidator.isOptional) continue;
			[underlyingErrors addObject: @[ paramName, [ParameterValidator leafError:@"is missing"]]];
			continue;
		}

		NSError *paramError = nil;
		if (![paramValidator isPleasedWith:paramValue error:&paramError]) {
			[underlyingErrors addObject: @[ paramName, paramError] ];
			continue;
		}
	}

	if (!self.allowsExtraParameters) {
		NSMutableSet *superflousParameters = [NSMutableSet setWithArray:[param allKeys]];
		[superflousParameters minusSet:processedParameters];
		for (id superflousParam in superflousParameters) {
			[underlyingErrors addObject: @[ superflousParam, [ParameterValidator leafError:@"superflous parameter '%@'", superflousParam]]];
		}
	}

	if ([underlyingErrors count]) {
		if (anError)
			*anError = [ParameterValidator branchErrorForKeyedErrors:underlyingErrors];
		return NO;
	}

	return YES;
}

@end


@implementation ParameterValidator (ErrorReporting)

+ (NSArray *)underlyingErrorKeys:(NSError *)anError {
	NSMutableArray *uniqueKeysInOrderEncountered = [NSMutableArray array];
	NSMutableSet *uniqueKeys = [NSMutableSet set];

	NSDictionary *underlyingErrors = [[anError userInfo] objectForKey:ParameterValidatorUnderlyingValidatorErrorsKey];

	for (NSArray *eachError in underlyingErrors) {
		id key = eachError[0];
		id subKeys = [self underlyingErrorKeys:eachError[1]];

		if ([subKeys count]) {
			for (id subKey in subKeys) {
				id combinedKey = [@[key] arrayByAddingObjectsFromArray:subKey];
				if ([uniqueKeys containsObject:combinedKey]) continue;
				[uniqueKeys addObject:combinedKey];
				[uniqueKeysInOrderEncountered addObject:combinedKey];
			}
		} else {
			id combinedKey = @[key];
			if ([uniqueKeys containsObject:combinedKey]) continue;
			[uniqueKeys addObject:combinedKey];
			[uniqueKeysInOrderEncountered addObject:combinedKey];
		}
	}

	return uniqueKeysInOrderEncountered;
}

+ (NSError *)leafError:(NSString *)fmt, ... {
	va_list args;
	va_start(args, fmt);
	NSString *description = [[NSString alloc] initWithFormat:fmt arguments:args];
	va_end(args);
	return [NSError errorWithDomain:ParameterValidatorErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey: description}];
}

+ (NSError *)leafErrorFromError:(NSError *)anError format:(NSString *)fmt, ... {
	va_list args;
	va_start(args, fmt);
	NSString *description = [[NSString alloc] initWithFormat:fmt arguments:args];
	va_end(args);

	if (anError) {
		description = [description stringByAppendingFormat:@" %@", [anError localizedDescription]];
	}

	id userInfo = @{
		NSLocalizedDescriptionKey: description,
		NSUnderlyingErrorKey: anError
	};

	return [NSError errorWithDomain:ParameterValidatorErrorDomain code:0 userInfo:userInfo];
}

+ (NSError *)branchErrorForKeyedErrors:(NSArray *)errors {
	NSString *description = @"validation error for multiple parameters";

	if ([errors count] == 1) {
		id firstKeyedError = errors[0];
		description = [NSString stringWithFormat:@"validation error for parameter '%@': %@", firstKeyedError[0], [firstKeyedError[1] localizedDescription]];
	}

	id userInfo = @{
		ParameterValidatorUnderlyingValidatorErrorsKey: errors,
		NSLocalizedDescriptionKey: description
	};
	return [NSError errorWithDomain:ParameterValidatorErrorDomain code:1 userInfo:userInfo];
}

+ (NSString *)stringFromValidationErrorKey:(NSArray *)aKey {
	NSMutableArray *components = [NSMutableArray array];
	for (id component in aKey)
		[components addObject:[component description]];
	return [components componentsJoinedByString:@"."];
}

@end


@implementation NSError (ParameterValidatorErrors)

- (NSArray *)underlyingValidationErrorsForKey:(NSArray *)errorKey {
	NSMutableArray *found = [NSMutableArray array];

	if (!errorKey || ![errorKey count]) return found;

	id firstComponent = errorKey[0];
	NSArray *matchingSuberrors = [self directUnderlyingValidationErrorsForKey:firstComponent];

	if ([errorKey count] > 1) {
		NSArray *subkey = [errorKey subarrayWithRange:NSMakeRange(1,[errorKey count]-1)];
		for (NSError *suberror in matchingSuberrors) {
			[found addObjectsFromArray:[suberror underlyingValidationErrorsForKey:subkey]];
		}
	} else {
		[found addObjectsFromArray:matchingSuberrors];
	}

	return found;
}

- (NSArray *)directUnderlyingValidationErrorsForKey:(id)aKey {
	NSMutableArray *found = [NSMutableArray array];

	for (NSArray *errorDesc in [[self userInfo] objectForKey:ParameterValidatorUnderlyingValidatorErrorsKey]) {
		if (![errorDesc[0] isEqual:aKey]) continue;
		[found addObject:errorDesc[1]];
	}

	return found;
}

- (NSError *)errorByFlatteningFirstValidationError {
	if ([self code] == ParameterValidatorErrorCodeBranch) {
		NSArray *firstKey = [ParameterValidator underlyingErrorKeys:self][0];
		NSError *firstError = [self underlyingValidationErrorsForKey:firstKey][0];
		return [ParameterValidator leafError:@"parameter %@ %@",
			[ParameterValidator stringFromValidationErrorKey:firstKey],
			[firstError localizedDescription]
		];
	}

	return [ParameterValidator leafError:@"parameter %@", [self localizedDescription]];
}

@end


NSString *ParameterValidatorErrorDomain = @"com.tancred.parametervalidator";
NSInteger ParameterValidatorErrorCodeLeaf = 0;
NSInteger ParameterValidatorErrorCodeBranch = 1;

NSString *ParameterValidatorUnderlyingValidatorErrorsKey = @"UnderlyingValidatorErrors";
