ParameterValidator
==================

ParameterValidator is a small Objective-C library
	for validating the contents of a dictionary.
	Currently in prototyping phase.

The Plan
--------

1. Write the hexstring and array field validators.

2. Rework the ParameterValidator class.
	_There's no reason it can't be a field validator,
	just like the other validators.
	Together with the array validator
	we should then be able to validate a nested object soup._

3. Rework error reporting?
	_Maybe return a structure of errors
	including type of error (mandatory/validation/superflous)
	and field name.
	Optionally report all errors instead of the first encountered._

4. Write short, succinct API usage here.

The API
-------------------

Just to get an idea of the idea.

```objective-c
ParameterValidator *validator = [ParameterValidator validator];
[validator validate:@"age" with:[FieldValidator number] atLeast:@0];
[validator validate:@"name" with:[[FieldValidator string] min:@2];

id params = @{@"age": @42, @"name": @"Slartibartfast"};

NSError *validationError = nil;
if (![validator isPleasedWith:params error:&validationError]) {
	NSLog(@"validation failed: %@", [validationError localizedDescription]);
	return;
}

NSLog(@"Yay!");
```