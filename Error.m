#import "Error.h"

NSError *CreateError(NSInteger code, NSString *descriptionFormat, ...) {
	va_list args;
	va_start(args, descriptionFormat);
	NSError *error = CreateErrorFixedArgs(code, descriptionFormat, args);
	va_end(args);
	return error;
}

NSError *CreateErrorFixedArgs(NSInteger code, NSString *descriptionFormat, va_list args) {
	NSString *description = [[NSString alloc] initWithFormat:descriptionFormat arguments:args];
	return [NSError errorWithDomain:@"com.tancred.parametervalidator" code:code userInfo:@{NSLocalizedDescriptionKey: description}];
}
