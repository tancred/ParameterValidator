#import <Foundation/Foundation.h>

@interface DictionaryValidator : NSObject
@property BOOL allowsExtraParameters;
+ (instancetype)validator;
- (void)validate:(NSString *)name with:(id)validator;
- (BOOL)isPleasedWith:(NSDictionary *)parameters error:(NSError **)anError;
	// Allow multiple validators for a field? Allow contradictions?
@end
