#import <Foundation/Foundation.h>

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
@property (copy) NSNumber *min;
@property (copy) NSNumber *max;
- (instancetype)length:(NSNumber *)limit; // min == max
- (instancetype)min:(NSNumber *)limit;
- (instancetype)max:(NSNumber *)limit;
@end

@interface HexstringFieldValidator : StringFieldValidator
//- (instancetype)bits:(NSUInteger)limit; // minBits == maxBits
//- (instancetype)minBits:(NSUInteger)limit;
//- (instancetype)maxBits:(NSUInteger)limit;
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
