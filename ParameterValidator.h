#import <Foundation/Foundation.h>

@interface ParameterValidator : NSObject
@property BOOL isOptional; // used by DictionaryValidator.

+ (instancetype)validator;
- (BOOL)isPleasedWith:(id)param error:(NSError **)anError;

- (instancetype)mandatory;
- (instancetype)optional;
@end

@interface NumberValidator : ParameterValidator
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

@interface StringValidator : ParameterValidator
@property (copy) NSNumber *min;
@property (copy) NSNumber *max;
- (instancetype)length:(NSNumber *)limit; // min == max
- (instancetype)min:(NSNumber *)limit;
- (instancetype)max:(NSNumber *)limit;
@end

@interface HexstringValidator : StringValidator
// note: add a "limit to chars in set" option to the string validator. Then the convenience constructor -hexstring could simple sets the charset. Unless we want something like the following:
//- (instancetype)bits:(NSUInteger)limit; // minBits == maxBits
//- (instancetype)minBits:(NSUInteger)limit;
//- (instancetype)maxBits:(NSUInteger)limit;
@end

@interface ArrayValidator : ParameterValidator
@property (strong) ParameterValidator *prototype;
- (instancetype)of:(ParameterValidator *)prototype;
@end

@interface DictionaryValidator : ParameterValidator
@property BOOL allowsExtraParameters;

- (instancetype)merciless;
- (instancetype)merciful;

- (instancetype)validate:(NSString *)name with:(id)validator;
@end

@interface ParameterValidator (ConstructionConvenience)
+ (NumberValidator *)number;
+ (StringValidator *)string;
+ (HexstringValidator *)hexstring;
+ (ArrayValidator *)array;
+ (DictionaryValidator *)dictionary;
@end

@interface ParameterValidator (ErrorReporting)
+ (NSArray *)underlyingErrorKeys:(NSError *)anError;

+ (NSError *)leafError:(NSString *)fmt, ... NS_FORMAT_FUNCTION(1, 2);
+ (NSError *)leafErrorFromError:(NSError *)anError format:(NSString *)fmt, ... NS_FORMAT_FUNCTION(2, 3);
+ (NSError *)branchErrorForKeyedErrors:(NSArray *)errors;
@end

@interface NSError (ParameterValidatorErrors)
- (NSArray *)underlyingValidationErrorsForKey:(NSArray *)errorKey;
@end

extern NSString *ParameterValidatorErrorDomain;
extern NSInteger ParameterValidatorErrorCodeLeaf;
extern NSInteger ParameterValidatorErrorCodeBranch;

extern NSString *ParameterValidatorUnderlyingValidatorErrorsKey;
