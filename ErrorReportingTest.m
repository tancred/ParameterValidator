#import "ErrorReportingTest.h"
#import "ParameterValidator.h"


@implementation ErrorReportingTest

- (void)testCreateLeafError {
	NSError *actual = [ParameterValidator leafError:@"some %@", @"problem"];
	STAssertEqualObjects([actual domain], ParameterValidatorErrorDomain, nil);
	STAssertEquals([actual code], ParameterValidatorErrorCodeLeaf, nil);
	STAssertEqualObjects([actual localizedDescription], @"some problem", nil);
}

- (void)testCreateLeafErrorFromError {
	NSError *underlying = [NSError errorWithDomain:@"dom" code:13 userInfo:@{NSLocalizedDescriptionKey: @"sub-prob"}];
	NSError *actual = [ParameterValidator leafErrorFromError:underlying format:@"some %@", @"prob"];
	STAssertEqualObjects([actual domain], ParameterValidatorErrorDomain, nil);
	STAssertEquals([actual code], ParameterValidatorErrorCodeLeaf, nil);
	STAssertEqualObjects([actual localizedDescription], @"some prob sub-prob", nil);
}

- (void)testCreateBranchError {
	NSArray *underlying = @[
		@[ @"key1", [ParameterValidator leafError:@"error1"] ]
	];
	NSError *actual = [ParameterValidator branchErrorForKeyedErrors:underlying];
	STAssertEqualObjects([actual domain], ParameterValidatorErrorDomain, nil);
	STAssertEquals([actual code], ParameterValidatorErrorCodeBranch, nil);
	STAssertEqualObjects([actual localizedDescription], @"validation error for parameter 'key1': error1", nil);

	NSArray *actualUnderlying = [actual userInfo][ParameterValidatorUnderlyingValidatorErrorsKey];
	STAssertEquals([actualUnderlying count], (NSUInteger)1, nil);

	NSArray *underlyingErrorDesc = actualUnderlying[0];
	STAssertEquals([underlyingErrorDesc count], (NSUInteger)2, nil);
	STAssertEqualObjects(underlyingErrorDesc[0], @"key1", nil);

	NSError *theError = underlyingErrorDesc[1];
	STAssertEqualObjects([theError domain], ParameterValidatorErrorDomain, nil);
	STAssertEquals([theError code], ParameterValidatorErrorCodeLeaf, nil);
	STAssertEqualObjects([theError localizedDescription], @"error1", nil);
}

- (void)testCreateBranchErrorWithMultipleErrors {
	NSArray *underlying = @[
		@[ @"key1", [ParameterValidator leafError:@"error1"] ],
		@[ @"key2", [ParameterValidator leafError:@"error2"] ]
	];
	NSError *actual = [ParameterValidator branchErrorForKeyedErrors:underlying];
	STAssertEqualObjects([actual domain], ParameterValidatorErrorDomain, nil);
	STAssertEquals([actual code], ParameterValidatorErrorCodeBranch, nil);
	STAssertEqualObjects([actual localizedDescription], @"validation error for multiple parameters", nil);

	NSArray *actualUnderlying = [actual userInfo][ParameterValidatorUnderlyingValidatorErrorsKey];
	STAssertEquals([actualUnderlying count], (NSUInteger)2, nil);

	STAssertEqualObjects(actualUnderlying[0][0], @"key1", nil);
	STAssertEqualObjects([actualUnderlying[0][1] localizedDescription], @"error1", nil);

	STAssertEqualObjects(actualUnderlying[1][0], @"key2", nil);
	STAssertEqualObjects([actualUnderlying[1][1] localizedDescription], @"error2", nil);
}

- (void)testKeysForLeafError {
	NSError *error = [ParameterValidator leafError:@"some error"];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];
	STAssertEqualObjects(keys, (@[]), nil);
}

- (void)testKeysForNestedErrorWithOneSublevel {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator leafError:@"x"] ],
		@[ @2,    [ParameterValidator leafError:@"y"] ],
		@[ @"p3", [ParameterValidator leafError:@"z"] ],
	]];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];
	STAssertEqualObjects(keys, (@[ @[@"p1"], @[@2], @[@"p3"] ]), nil);
}

- (void)testKeysForNestedErrorWithTwoSublevels {
	NSError *error = [ParameterValidator branchErrorForKeyedErrors:@[
		@[ @"p1", [ParameterValidator branchErrorForKeyedErrors:@[
				@[ @"p2", [ParameterValidator leafError:@"x"] ],
			]]
		],
	]];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];
	STAssertEqualObjects(keys, (@[ @[@"p1", @"p2"] ]), nil);
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
	STAssertEqualObjects(keys, (@[ @[@"p1", @"p2.1"], @[@"p1", @22] ]), nil);
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
	STAssertEqualObjects(keys, (@[ @[@"p1", @"p2.1", @"p3.1"], @[@"p1", @"p2.1", @"p3.2"], @[@"p1", @"p2.2", @33], @[@"p1", @"p2.2", @34] ]), nil);
}

- (void)testKeysForNumberError {
	NSError *error = nil;
	[[ParameterValidator number] isPleasedWith:@"two" error:&error];
	STAssertEqualObjects([ParameterValidator underlyingErrorKeys:error], @[], nil);
}

- (void)testKeysForDictionaryTypeError {
	NSError *error = nil;
	[[ParameterValidator dictionary] isPleasedWith:@"string" error:&error];
	STAssertEqualObjects([ParameterValidator underlyingErrorKeys:error], @[], nil);
}

- (void)testKeysForArrayTypeError {
	NSError *error = nil;
	[[ParameterValidator array] isPleasedWith:@"string" error:&error];
	STAssertEqualObjects([ParameterValidator underlyingErrorKeys:error], @[], nil);
}

- (void)testKeysForDictionaryParameterError {
	DictionaryValidator *validator = [ParameterValidator dictionary];
	[validator validate:@"param" with:[[ParameterValidator validator] mandatory]];

	NSError *error = nil;
	[validator isPleasedWith:@{} error:&error];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];

	STAssertEqualObjects(keys, (@[ @[@"param"] ]), nil);
}

- (void)testKeysForMultipleDictionaryParameterErrors {
	DictionaryValidator *validator = [ParameterValidator dictionary];
	[validator validate:@"num" with:[ParameterValidator number]];
	[validator validate:@"arr" with:[ParameterValidator array]];
	[validator validate:@"str" with:[ParameterValidator string]];

	NSError *error = nil;
	[validator isPleasedWith:@{@"arr": @[]} error:&error];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];

	STAssertEqualObjects(keys, (@[ @[@"num"], @[@"str"] ]), nil);
}

- (void)testKeysForArrayParameterError {
	ArrayValidator *validator = [[ParameterValidator array] of:[ParameterValidator number]];

	NSError *error = nil;
	[validator isPleasedWith:@[@"string"] error:&error];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];

	STAssertEqualObjects(keys, (@[ @[@0] ]), nil);
}

- (void)testKeysForMultipleArrayParameterErrors {
	ArrayValidator *validator = [[ParameterValidator array] of:[ParameterValidator number]];

	NSError *error = nil;
	[validator isPleasedWith:@[@24, @"str1", @"str2", @25, @26] error:&error];
	NSArray *keys = [ParameterValidator underlyingErrorKeys:error];

	STAssertEqualObjects(keys, (@[ @[@1], @[@2] ]), nil);
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

	STAssertEqualObjects(keys, (@[ @[@"b",@"c",@"num"], @[@"b",@"c",@"str"] ]), nil);
}

@end
