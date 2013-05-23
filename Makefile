CC = clang
CFLAGS = -Wall -fobjc-arc -F/Applications/Xcode.app/Contents/Developer/Library/Frameworks
PROGS = validparams

default: validparams
	DYLD_FRAMEWORK_PATH=/Applications/Xcode.app/Contents/Developer/Library/Frameworks ./validparams

validparams: validparams.o \
DictionaryValidator.o FieldValidator.o Error.o \
DictionaryValidatorTest.o \
FieldValidatorTest.o \
NumberFieldValidatorTest.o \
StringFieldValidatorTest.o \
HexstringFieldValidatorTest.o \
ArrayFieldValidatorTest.o
	$(CC) -o $@ $(CFLAGS) $^ -framework Foundation -framework SenTestingKit

validparams.o: validparams.m
DictionaryValidator.o: DictionaryValidator.m DictionaryValidator.h FieldValidator.h Error.h
FieldValidator.o: FieldValidator.m FieldValidator.h Error.h
Error.o: Error.m Error.h

DictionaryValidatorTest.o: DictionaryValidatorTest.m DictionaryValidatorTest.h DictionaryValidator.h FieldValidator.h
FieldValidatorTest.o: FieldValidatorTest.m FieldValidatorTest.h FieldValidator.h
NumberFieldValidatorTest.o: NumberFieldValidatorTest.m NumberFieldValidatorTest.h FieldValidator.h
StringFieldValidatorTest.o: StringFieldValidatorTest.m StringFieldValidatorTest.h FieldValidator.h
HexstringFieldValidatorTest.o: HexstringFieldValidatorTest.m HexstringFieldValidatorTest.h FieldValidator.h
ArrayFieldValidatorTest.o: ArrayFieldValidatorTest.m ArrayFieldValidatorTest.h FieldValidator.h

%.o: %.m
	$(CC) -c $(CFLAGS) $<

clean:
	rm -f $(PROGS)
	rm -f *.o
