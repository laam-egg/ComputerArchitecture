#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

int main(int argc, char* argv[]) {
	int retval = EXIT_FAILURE;
	bool someTestsFailed = false;

	if (argc < 4 || argc % 2 != 0) {
		fprintf(stderr, "Usage: test source_file.s sample_input1.txt sample_output1.txt [sample_input2.txt sample_output2.txt ...]\n");
		goto FAIL_WRONG_ARGUMENTS;
	}

	char const* srcFileName = argv[1];
	size_t srcFileNameLength = strlen(srcFileName);
	if (srcFileNameLength < 3 || !(
		srcFileName[srcFileNameLength-2] == '.'
		&& tolower(srcFileName[srcFileNameLength-1]) == 's'
		)
	) {
		fprintf(stderr, "ERROR: Invalid source file: \"%s\"\nSource file name must have the form: \"anyname.s\" or \"anyname.S\".\n", srcFileName);
		goto FAIL_INVALID_SOURCE_FILE;
	}
	size_t destFileNameLength = srcFileNameLength - 2 /*strip off the .s extension*/;
	char* destFileName = (char*)malloc( (destFileNameLength + 1) * sizeof(char) );
	if (destFileName == NULL) {
		fprintf(stderr, "ERROR: Cannot allocate memory for destination file name.\n");
		goto FAIL_CANNOT_ALLOCATE_destFileName;
	}
	strncpy(destFileName, srcFileName, destFileNameLength);
	destFileName[destFileNameLength] = '\0';

	// Compile and link the program
	char const cmdFormat[] = "as -o \"%s.o\" \"%s\" && ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -o \"%s\" \"%s.o\"";
	size_t cmdLength = strlen(cmdFormat)
		- 2 + destFileNameLength
		- 2 + srcFileNameLength
		- 2 + destFileNameLength
		- 2 + destFileNameLength;
	char* cmd = (char*)malloc( (cmdLength + 1) * sizeof(char) );
	if (cmd == NULL) {
		fprintf(stderr, "ERROR: Cannot allocate memory for complie-and-link command.\n");
		goto FAIL_CANNOT_ALLOCATE_cmd;
	}
	sprintf(cmd, cmdFormat, destFileName, srcFileName, destFileName, destFileName);
	if (EXIT_SUCCESS != system(cmd)) {
		fprintf(stderr, "ERROR: Compilation and/or linking process failed.\n");
		goto FAIL_COMPILATION_OR_LINKING;
	}
	free((void*)cmd);
	cmd = NULL;

	// Program compiled to executable file named destFileName.
	// Run it with specified inputs, and compare its outputs with the expected ones.
	bool destFileNameIsRunnablePath = (destFileName[0] == '/' || (destFileNameLength >= 3 && destFileName[0] == '.' && destFileName[1] == '/'));
	size_t executableFileNameLength = destFileNameLength + (destFileNameIsRunnablePath ? 2 : 0);
	char* executableFileName = (char*)malloc( (executableFileNameLength + 1) * sizeof(char) );
	if (executableFileName == NULL) {
		fprintf(stderr, "ERROR: Cannot allocate memory for executable file name.");
		goto FAIL_CANNOT_ALLOCATE_executableFileName;
	}
	if (destFileNameIsRunnablePath) {
		strcpy(executableFileName, destFileName);
	} else {
		executableFileName[0] = '.';
		executableFileName[1] = '/';
		strcpy((executableFileName + 2), destFileName);
	}

	char* actualOutputFileName = NULL;
	char* cmdRun = NULL;
	char* cmdDiff = NULL;
	for (int i = 2; i < argc; ++i) {
		char const* inputFileName = argv[i];
		char const* outputFileName = argv[++i];

		char const actualOutputExtension[] = ".actual";
		size_t actualOutputFileNameLength = strlen(outputFileName) + strlen(actualOutputExtension);
		actualOutputFileName = (char*)malloc(actualOutputFileNameLength + 1);
		if (actualOutputFileName == NULL) {
			fprintf(stderr, "ERROR: Cannot allocate memory for actual output file nane.\n");
			goto FAIL_CANNOT_ALLOCATE_actualOutputFileName;
		}
		sprintf(actualOutputFileName, "%s%s", outputFileName, actualOutputExtension);

		char const cmdRunFormat[] = "cat \"%s\" | \"%s\" > \"%s\"";
		size_t cmdRunLength = strlen(cmdRunFormat)
			- 2 + strlen(inputFileName)
			- 2 + executableFileNameLength
			- 2 + actualOutputFileNameLength;
		cmdRun = (char*)malloc(cmdRunLength + 1);
		if (cmdRun == NULL) {
			fprintf(stderr, "ERROR: Cannot allocate memory for run-command.\n");
			goto FAIL_CANNOT_ALLOCATE_cmdRun;
		}
		sprintf(cmdRun, cmdRunFormat, inputFileName, executableFileName, actualOutputFileName);

		if (EXIT_SUCCESS != system(cmdRun)) {
			fprintf(stderr, "ERROR: Cannot run the program for testing: %s\n", cmdRun);
			goto FAIL_CANNOT_RUN_PROGRAM;
		}

		// The program has been run with sample input.
		// Compare its output with the expected one.
		// diff:
		//     -u: Git-like diff with +/- instead of >/<
		//     -Z: Ignore trailing whitespace in a line
		//     -B: Ignore blank lines
		char const cmdDiffFormat[] = "diff -u --color -Z -B \"%s\" \"%s\"";
		size_t cmdDiffLength = strlen(cmdDiffFormat)
			- 2 + strlen(outputFileName)
			- 2 + actualOutputFileNameLength;
		char* cmdDiff = (char*)malloc( (cmdDiffLength + 1) * sizeof(char) );
		if (cmdDiff == NULL) {
			fprintf(stderr, "ERROR: Cannot allocate memory for run-diff command.\n");
			goto FAIL_CANNOT_ALLOCATE_cmdDiff;
		}
		sprintf(cmdDiff, cmdDiffFormat, outputFileName, actualOutputFileName);

		int diffRetVal = system(cmdDiff);
		// https://www.unix.com/programming/32189-how-get-system-function-executed-cmd-return-value.html
		if ((diffRetVal >> 8) == 1) {
			someTestsFailed = true;
		}
		else if (diffRetVal != 0) {
			fprintf(stderr, "ERROR: Cannot run diff command: %s\nExit code: %d\n", cmdDiff, (diffRetVal >> 8));
			goto FAIL_CANNOT_RUN_DIFF;
		}
		else {
			// This test succeeded. Delete actual output file.
			remove(actualOutputFileName);
		}

		free((void*)cmdDiff);
			cmdDiff = NULL;
		free((void*)actualOutputFileName);
			actualOutputFileName = NULL;
		free((void*)cmdRun);
			cmdRun = NULL;
	}

SUCCESSFULLY_EXIT:
	fprintf(stdout, "Ran all tests.\n");
	if (someTestsFailed) {
		fprintf(stderr, "Some tests failed.\n");
	} else {
		fprintf(stdout, "All tests passed.\n");
	}
	retval = EXIT_SUCCESS;

FAIL_CANNOT_RUN_DIFF:

	if (cmdDiff != NULL) free((void*)cmdDiff);
FAIL_CANNOT_ALLOCATE_cmdDiff:

FAIL_CANNOT_RUN_PROGRAM:

	if (cmdRun != NULL) free((void*)cmdRun);
FAIL_CANNOT_ALLOCATE_cmdRun:

	if (actualOutputFileName != NULL) free((void*)actualOutputFileName);
FAIL_CANNOT_ALLOCATE_actualOutputFileName:

	if (executableFileName != NULL) free((void*)executableFileName);
FAIL_CANNOT_ALLOCATE_executableFileName:

FAIL_COMPILATION_OR_LINKING:
	
	if (cmd != NULL) free((void*)cmd);
FAIL_CANNOT_ALLOCATE_cmd:

	if (destFileName != NULL) free((void*)destFileName);
FAIL_CANNOT_ALLOCATE_destFileName:

FAIL_INVALID_SOURCE_FILE:

FAIL_WRONG_ARGUMENTS:
	
	return retval;
}
