#import "DictionaryValidator.h"
#import "ParameterValidator.h"
#import "Error.h"

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

