CC = clang
CFLAGS = -Wall -fobjc-arc -F/Applications/Xcode.app/Contents/Developer/Library/Frameworks
PROGS = validparams

default: validparams
	DYLD_FRAMEWORK_PATH=/Applications/Xcode.app/Contents/Developer/Library/Frameworks ./validparams

validparams: validparams.o \
ParameterValidator.o \
Error.o \
DictionaryValidatorTest.o \
ParameterValidatorTest.o \
NumberValidatorTest.o \
StringValidatorTest.o \
HexstringValidatorTest.o \
ArrayValidatorTest.o
	$(CC) -o $@ $(CFLAGS) $^ -framework Foundation -framework SenTestingKit

validparams.o: validparams.m
ParameterValidator.o: ParameterValidator.m ParameterValidator.h Error.h
Error.o: Error.m Error.h

DictionaryValidatorTest.o: DictionaryValidatorTest.m DictionaryValidatorTest.h ParameterValidator.h
ParameterValidatorTest.o: ParameterValidatorTest.m ParameterValidatorTest.h ParameterValidator.h
NumberValidatorTest.o: NumberValidatorTest.m NumberValidatorTest.h ParameterValidator.h
StringValidatorTest.o: StringValidatorTest.m StringValidatorTest.h ParameterValidator.h
HexstringValidatorTest.o: HexstringValidatorTest.m HexstringValidatorTest.h ParameterValidator.h
ArrayValidatorTest.o: ArrayValidatorTest.m ArrayValidatorTest.h ParameterValidator.h

%.o: %.m
	$(CC) -c $(CFLAGS) $<

clean:
	rm -f $(PROGS)
	rm -f *.o
