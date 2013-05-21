CC = clang
CFLAGS = -Wall -fobjc-arc -F/Applications/Xcode.app/Contents/Developer/Library/Frameworks
PROGS = validparams

default: validparams
	DYLD_FRAMEWORK_PATH=/Applications/Xcode.app/Contents/Developer/Library/Frameworks ./validparams

validparams: validparams.o
	$(CC) -o $@ $(CFLAGS) $^ -framework Foundation -framework SenTestingKit

validparams.o: validparams.m

%.o: %.m
	$(CC) -c $(CFLAGS) $<

clean:
	rm -f $(PROGS)
	rm -f *.o
