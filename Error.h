#import <Foundation/Foundation.h>

extern NSError *CreateError(NSInteger code, NSString *descriptionFormat, ...) NS_FORMAT_FUNCTION(2, 3);
extern NSError *CreateErrorFixedArgs(NSInteger code, NSString *descriptionFormat, va_list args) NS_FORMAT_FUNCTION(2, 0);
