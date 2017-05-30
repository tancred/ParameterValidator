CC = clang
PLATFORM_SDK_PATH=$(shell xcrun --show-sdk-platform-path)
PLATFORM_FRAMEWORKS_PATH=$(PLATFORM_SDK_PATH)/Developer/Library/Frameworks
CFLAGS = -Wall -fobjc-arc -F$(PLATFORM_FRAMEWORKS_PATH)
PROGS = validparams

default: validparams
	DYLD_FRAMEWORK_PATH=$(PLATFORM_FRAMEWORKS_PATH) ./validparams 2>&1 | xcpretty -cs

validparams: validparams.o \
ParameterValidator.o \
DictionaryValidatorTest.o \
ParameterValidatorTest.o \
NumberValidatorTest.o \
StringValidatorTest.o \
HexstringValidatorTest.o \
ArrayValidatorTest.o \
ErrorReportingTest.o
	$(CC) -o $@ $(CFLAGS) $^ -framework Foundation -framework XCTest

validparams.o: validparams.m
ParameterValidator.o: ParameterValidator.m ParameterValidator.h

DictionaryValidatorTest.o: DictionaryValidatorTest.m ParameterValidator.h
ParameterValidatorTest.o: ParameterValidatorTest.m ParameterValidator.h
NumberValidatorTest.o: NumberValidatorTest.m ParameterValidator.h
StringValidatorTest.o: StringValidatorTest.m ParameterValidator.h
HexstringValidatorTest.o: HexstringValidatorTest.m ParameterValidator.h
ArrayValidatorTest.o: ArrayValidatorTest.m ParameterValidator.h
ErrorReportingTest.o: ErrorReportingTest.m ParameterValidator.h

%.o: %.m
	$(CC) -c $(CFLAGS) $<

clean:
	rm -f $(PROGS)
	rm -f *.o
