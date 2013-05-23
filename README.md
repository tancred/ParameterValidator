ParameterValidator
==================

ParameterValidator is a small Objective-C library
	for validating the contents of a dictionary.
	Currently in prototyping phase.

The Plan
--------

1. Rework error reporting?
	_Maybe return a structure of errors
	including type of error (mandatory/validation/superflous)
	and field name.
	Optionally report all errors instead of the first encountered._

2. Write short, succinct API usage here.

The API
-------------------

Just to get an idea of the idea.

```objective-c
DictionaryValidator *validator = [ParameterValidator dictionary];
[validator validate:@"age" with:[ParameterValidator number] atLeast:@0];
[validator validate:@"name" with:[[ParameterValidator string] min:@2];

id params = @{@"age": @42, @"name": @"Slartibartfast"};

NSError *validationError = nil;
if (![validator isPleasedWith:params error:&validationError]) {
	NSLog(@"validation failed: %@", [validationError localizedDescription]);
	return;
}

NSLog(@"Yay!");
```