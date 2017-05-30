#import <XCTest/XCTest.h>
#import "ParameterValidator.h"

@interface ErrorReportingTest : XCTestCase
@end

@implementation ErrorReportingTest

- (void)testCreateLeafError {
	NSError *actual = [ParameterValidator leafError:@"some %@", @"problem"];
	XCTAssertEqualObjects([actual domain], ParameterValidatorErrorDomain);
	XCTAssertEqual([actual code], ParameterValidatorErrorCodeLeaf);
	XCTAssertEqualObjects([actual localizedDescription], @"some problem");
}

- (void)testCreateLeafErrorFromError {
	NSError *underlying = [NSError errorWithDomain:@"dom" code:13 userInfo:@{NSLocalizedDescriptionKey: @"sub-prob"}];
	NSError *actual = [ParameterValidator leafErrorFromError:underlying format:@"some %@", @"prob"];
	XCTAssertEqualObjects([actual domain], ParameterValidatorErrorDomain);
	XCTAssertEqual([actual code], ParameterValidatorErrorCodeLeaf);
	XCTAssertEqualObjects([actual localizedDescription], @"some prob sub-prob");
}

- (void)testCreateBranchError {
	NSArray *underlying = @[
		@[ @"key1", [ParameterValidator leafError:@"error1"] ]
	];
	NSError *actual = [ParameterValidator branchErrorForKeyedErrors:underlying];
	XCTAssertEqualObjects([actual domain], ParameterValidatorErrorDomain);
	XCTAssertEqual([actual code], ParameterValidatorErrorCodeBranch);
	XCTAssertEqualObjects([actual localizedDescription], @"validation error for parameter 'key1': error1");

	NSArray *actualUnderlying = [actual userInfo][ParameterValidatorUnderlyingValidatorErrorsKey];
	XCTAssertEqual([actualUnderlying count], (NSUInteger)1);

	NSArray *underlyingErrorDesc = actualUnderlying[0];
	XCTAssertEqual([underlyingErrorDesc count], (NSUInteger)2);
	XCTAssertEqualObjects(underlyingErrorDesc[0], @"key1");

	NSError *theError = underlyingErrorDesc[1];
	XCTAssertEqualObjects([theError domain], ParameterValidatorErrorDomain);
	XCTAssertEqual([theError code], ParameterValidatorErrorCodeLeaf);
	XCTAssertEqualObjects([theError localizedDescription], @"error1");
}

- (void)testCreateBranchErrorWithMultipleErrors {
	NSArray *underlying = @[
		@[ @"key1", [ParameterValidator leafError:@"error1"] ],
		@[ @"key2", [ParameterValidator leafError:@"error2"] ]
	];
	NSError *actual = [ParameterValidator branchErrorForKeyedErrors:underlying];
	XCTAssertEqualObjects([actual domain], ParameterValidatorErrorDomain);
	XCTAssertEqual([actual code], ParameterValidatorErrorCodeBranch);
	XCTAssertEqualObjects([actual localizedDescription], @"validation error for multiple parameters");

	NSArray *actualUnderlying = [actual userInfo][ParameterValidatorUnderlyingValidatorErrorsKey];
	XCTAssertEqual([actualUnderlying count], (NSUInteger)2);

	XCTAssertEqualObjects(actualUnderlying[0][0], @"key1");
	XCTAssertEqualObjects([actualUnderlying[0][1] localizedDescription], @"error1");

	XCTAssertEqualObjects(actualUnderlying[1][0], @"key2");
	XCTAssertEqualObjects([actualUnderlying[1][1] localizedDescription], @"error2");
}

- (void)testKeysForLeafError {
	NSError *error = [ParameterValidator leafError:@"some error"];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];
	XCTAssertEqualObjects(keys, (@[]));
}

- (void)testKeysForNestedErrorWithOneSublevel {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator leafError:@"x"] ],
		@[ @2,    [ParameterValidator leafError:@"y"] ],
		@[ @"p3", [ParameterValidator leafError:@"z"] ],
	]];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];
	XCTAssertEqualObjects(keys, (@[ @[@"p1"], @[@2], @[@"p3"] ]));
}

- (void)testKeysAreUnique {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p2", [ParameterValidator leafError:@"x"] ],
		@[ @"p1", [ParameterValidator leafError:@"y"] ],
		@[ @"p1", [ParameterValidator leafError:@"z"] ],
	]];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];
	XCTAssertEqualObjects(keys, (@[ @[@"p2"], @[@"p1"] ]));
}

- (void)testNestedKeysAreUnique {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p2", [ParameterValidator leafError:@"x"] ],
			]]
		],
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p2", [ParameterValidator leafError:@"y"] ],
			]]
		],
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p3", [ParameterValidator leafError:@"z"] ],
			]]
		],
	]];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];
	XCTAssertEqualObjects(keys, (@[ @[@"p1", @"p2"], @[@"p1", @"p3"] ]));
}

- (void)testKeysForNestedErrorWithTwoSublevels {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p2", [ParameterValidator leafError:@"x"] ],
			]]
		],
	]];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];
	XCTAssertEqualObjects(keys, (@[ @[@"p1", @"p2"] ]));
}

- (void)testKeysForNestedErrorWithTwoSublevelsAndTwoLeafs {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p2.1", [ParameterValidator leafError:@"x"] ],
				@[ @22,     [ParameterValidator leafError:@"y"] ],
			]]
		],
	]];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];
	XCTAssertEqualObjects(keys, (@[ @[@"p1", @"p2.1"], @[@"p1", @22] ]));
}

- (void)testKeysForNestedErrorWithTwoSublevelsAndTwoLeafsInSeparateSublevels {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p2.1", [ParameterValidator branchErrorForKeyedErrors:@[
						@[ @"p3.1", [ParameterValidator leafError:@"x"] ],
						@[ @"p3.2", [ParameterValidator leafError:@"y"]	]
					]]
				],
				@[ @"p2.2",	[ParameterValidator branchErrorForKeyedErrors:@[
						@[ @33, [ParameterValidator leafError:@"r"] ],
						@[ @34, [ParameterValidator leafError:@"s"] ]
					]]
				]
			]]
		],
	]];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];
	XCTAssertEqualObjects(keys, (@[ @[@"p1", @"p2.1", @"p3.1"], @[@"p1", @"p2.1", @"p3.2"], @[@"p1", @"p2.2", @33], @[@"p1", @"p2.2", @34] ]));
}

- (void)testErrorsForUnknownKey {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator leafError:@"x"] ],
	]];

	XCTAssertEqualObjects([error underlyingValidationErrorsForKey:@[@"xy"]], @[]);
	XCTAssertEqualObjects([error underlyingValidationErrorsForKey:@[]], @[]);
	XCTAssertEqualObjects([error underlyingValidationErrorsForKey:nil], @[]);
}

- (void)testErrorForKeyInNestedErrorWithOneSublevel {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator leafError:@"x"] ],
	]];

	NSArray *lookedUp = [error underlyingValidationErrorsForKey:@[@"p1"]];
	XCTAssertEqual([lookedUp count], (NSUInteger)1);
	XCTAssertEqualObjects([lookedUp[0] localizedDescription], @"x");
}

- (void)testErrorForRepeatedKeyInNestedErrorWithOneSublevel {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator leafError:@"x"] ],
		@[ @"p1", [ParameterValidator leafError:@"y"] ],
	]];

	NSArray *lookedUp = [error underlyingValidationErrorsForKey:@[@"p1"]];

	XCTAssertEqual([lookedUp count], (NSUInteger)2);
	XCTAssertEqualObjects([lookedUp[0] localizedDescription], @"x");
	XCTAssertEqualObjects([lookedUp[1] localizedDescription], @"y");
}

- (void)testErrorForKeyInNestedErrorWithTwoSublevels {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p2", [ParameterValidator leafError:@"x"] ],
			]]
		],
	]];

	NSArray *lookedUp = [error underlyingValidationErrorsForKey:@[@"p1",@"p2"]];
	XCTAssertEqual([lookedUp count], (NSUInteger)1);
	XCTAssertEqualObjects([lookedUp[0] localizedDescription], @"x");
}

- (void)testErrorForIntermediateKeyInNestedErrorWithTwoSublevels {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p2", [ParameterValidator leafError:@"x"] ],
			]]
		],
	]];

	NSArray *lookedUp = [error underlyingValidationErrorsForKey:@[@"p1"]];
	XCTAssertEqual([lookedUp count], (NSUInteger)1);
	XCTAssertEqualObjects([lookedUp[0] localizedDescription], @"validation error for parameter 'p2': x");
}

- (void)testErrorForRepeatedKeyInNestedErrorWithTwoSublevels {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p2", [ParameterValidator leafError:@"x"] ],
			]]
		],
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p2", [ParameterValidator leafError:@"y"] ],
			]]
		],
	]];

	NSArray *lookedUp = [error underlyingValidationErrorsForKey:@[@"p1",@"p2"]];
	XCTAssertEqual([lookedUp count], (NSUInteger)2);
	XCTAssertEqualObjects([lookedUp[0] localizedDescription], @"x");
	XCTAssertEqualObjects([lookedUp[1] localizedDescription], @"y");
}

- (void)testFlatteningFirstValidationError {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p2", [ParameterValidator leafError:@"x"] ],
			]]
		],
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p2", [ParameterValidator leafError:@"y"] ],
			]]
		],
	]];

	NSError *flattened = [error errorByFlatteningFirstValidationError];
	XCTAssertEqualObjects([flattened domain], ParameterValidatorErrorDomain);
	XCTAssertEqual([flattened code], ParameterValidatorErrorCodeLeaf);
	XCTAssertEqualObjects([flattened localizedDescription], @"parameter p1.p2 x");
}

- (void)testFlatteningFirstValidationErrorHandlesLeaf {
	NSError *error = [ParameterValidator leafError:@"x"];
	NSError *flattened = [error errorByFlatteningFirstValidationError];
	XCTAssertEqualObjects([flattened domain], ParameterValidatorErrorDomain);
	XCTAssertEqual([flattened code], ParameterValidatorErrorCodeLeaf);
	XCTAssertEqualObjects([flattened localizedDescription], @"parameter x");
}

- (void)testKeysForNumberError {
	NSError *error = nil;
	[[ParameterValidator number] isPleasedWith:@"two" error:&error];
	XCTAssertEqualObjects([ParameterValidator underlyingErrorKeys:error], @[]);
}

- (void)testKeysForDictionaryTypeError {
	NSError *error = nil;
	[[ParameterValidator dictionary] isPleasedWith:@"string" error:&error];
	XCTAssertEqualObjects([ParameterValidator underlyingErrorKeys:error], @[]);
}

- (void)testKeysForArrayTypeError {
	NSError *error = nil;
	[[ParameterValidator array] isPleasedWith:@"string" error:&error];
	XCTAssertEqualObjects([ParameterValidator underlyingErrorKeys:error], @[]);
}

- (void)testKeysForDictionaryParameterError {
	DictionaryValidator *validator = [ParameterValidator dictionary];
	[validator validate:@"param" with:[[ParameterValidator validator] mandatory]];

	NSError *error = nil;
	[validator isPleasedWith:@{} error:&error];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];

	XCTAssertEqualObjects(keys, (@[ @[@"param"] ]));
}

- (void)testKeysForMultipleDictionaryParameterErrors {
	DictionaryValidator *validator = [ParameterValidator dictionary];
	[validator validate:@"num" with:[ParameterValidator number]];
	[validator validate:@"arr" with:[ParameterValidator array]];
	[validator validate:@"str" with:[ParameterValidator string]];

	NSError *error = nil;
	[validator isPleasedWith:@{@"arr": @[]} error:&error];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];

	XCTAssertEqualObjects(keys, (@[ @[@"num"], @[@"str"] ]));
}

- (void)testKeysForArrayParameterError {
	ArrayValidator *validator = [[ParameterValidator array] of:[ParameterValidator number]];

	NSError *error = nil;
	[validator isPleasedWith:@[@"string"] error:&error];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];

	XCTAssertEqualObjects(keys, (@[ @[@0] ]));
}

- (void)testKeysForMultipleArrayParameterErrors {
	ArrayValidator *validator = [[ParameterValidator array] of:[ParameterValidator number]];

	NSError *error = nil;
	[validator isPleasedWith:@[@24, @"str1", @"str2", @25, @26] error:&error];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];

	XCTAssertEqualObjects(keys, (@[ @[@1], @[@2] ]));
}

- (void)testKeysForNestedDictionaryErrors {
	id c = [ParameterValidator dictionary];
	  [c validate:@"num" with:[ParameterValidator number]];
	  [c validate:@"hex" with:[ParameterValidator hexstring]];
	  [c validate:@"str" with:[ParameterValidator string]];
	id b = [[ParameterValidator dictionary] validate:@"c" with:c];
	id a = [[ParameterValidator dictionary] validate:@"b" with:b];

	id dict = @{
		@"b": @{
			@"c": @{
				@"num": @"not a num",
				@"hex": @"beef",
				@"str": @42
			}
		}
	};

	NSError *error = nil;
	[a isPleasedWith:dict error:&error];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];

	XCTAssertEqualObjects(keys, (@[ @[@"b",@"c",@"num"], @[@"b",@"c",@"str"] ]));
}

@end
