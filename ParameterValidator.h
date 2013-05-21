#import <Foundation/Foundation.h>

@interface ParameterValidator : NSObject
@property BOOL allowsExtraParameters;
+ (instancetype)validator;
- (void)requireField:(NSString *)name conformsTo:(id)validator;
- (BOOL)isPleasedWith:(id)parameters error:(NSError **)anError;
	// Params normally dictionary but should really just respond to -objectForKey: and -allKeys (for checking extra parameters).
	// Process validators in order registered
	// Allow multiple validators for a field? Allow contradictions?
@end
