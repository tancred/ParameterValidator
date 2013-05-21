#import "ParameterValidator.h"
#import "FieldValidator.h"
#import "Error.h"

@interface ParameterValidator ()
@property (strong) NSMutableArray *validators;
@end


@implementation ParameterValidator

+ (instancetype)validator {
	return [[self alloc] init];
}

- (id)init {
	if (!(self = [super init])) return nil;
	self.validators = [[NSMutableArray alloc] init];
	return self;
}

- (void)requireField:(NSString *)name conformsTo:(id)validator {
	[self.validators addObject:@{@"field":name, @"validator":validator}];
}

- (BOOL)isPleasedWith:(id)parameters error:(NSError **)anError {
	NSMutableSet *processedParameters = [NSMutableSet set];

	for (NSDictionary *each in self.validators) {
		NSString *fieldName = each[@"field"];
		FieldValidator *fieldValidator = each[@"validator"];

		[processedParameters addObject:fieldName];

		NSString *fieldValue = parameters[fieldName];
		if (!fieldValue) {
			if (fieldValidator.isOptional) continue;
			if (anError)
				*anError = CreateError(0, @"missing required parameter '%@'", fieldName);
			return NO;
		}

		NSError *fieldError = nil;
		if (![fieldValidator isPleasedWith:fieldValue error:&fieldError]) {
			if (anError)
				*anError = CreateError(0, @"parameter '%@' %@", fieldName, [fieldError localizedDescription]);
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

