//------------ DWAINE Program Signal Errors ------------//
/// The command was carried out successfully.
#define ESIG_SUCCESS	0
/// The command could not be carried out successfully.
#define ESIG_GENERIC	(1 << 0)
/// The command could not be carried out successfully, as a target was required and could not be found.
#define ESIG_NOTARGET	(1 << 1)
/// The command could not be carried out successfully, as the command was not recognised.
#define ESIG_BADCOMMAND	(1 << 2)
/// The command could not be carried out successfully, as a user was required and could not be found.
#define ESIG_NOUSR		(1 << 3)
/// The command could not be carried out successfully, as a result of an I/O error.
#define ESIG_IOERR		(1 << 4)
/// The command could not be carried out successfully, as a file was required and could not be found.
#define ESIG_NOFILE		(1 << 5)
/// The command could not be carried out successfully, as write permission was required.
#define ESIG_NOWRITE	(1 << 6)

/// User defined signal 1. This indicates an application-specific error condition has occured.
#define ESIG_USR1		(1 << 7)
/// User defined signal 2. This indicates an application-specific error condition has occured.
#define ESIG_USR2		(1 << 8)
/// User defined signal 3. This indicates an application-specific error condition has occured.
#define ESIG_USR3		(1 << 9)
/// User defined signal 4. This indicates an application-specific error condition has occured.
#define ESIG_USR4		(1 << 10)

/// If a command is expected to return a number, it will be signed with the databit to signify that it is not an error condition.
#define ESIG_DATABIT	(1 << 15)


//------------ DWAINE Shell Builtin Errors ------------//
/// The command was carried out successfully.
#define BUILTIN_SUCCESS		0
/// The command has instructed the shell to halt processing.
#define BUILTIN_BREAK		1
/// The command has instructed the shell to move to the next line of the script.
#define BUILTIN_CONTINUE	2


//------------ DWAINE Shell Executable Errors ------------//
/// The file was unable to be executed.
#define EXEC_FAILURE		0
/// The file was executed successfully.
#define EXEC_SUCCESS		1
/// The script was unable to be executed.
#define EXEC_SCRIPT_ERROR	2
/// A stack overflow error was encountered. In this case, `MAX_SCRIPT_ITERATIONS` was exceeded.
#define EXEC_STACK_OVERFLOW	3


//------------ DWAINE Shell Script Errors ------------//
/// The script was executed successfully.
#define SCRIPT_SUCCESS			0
/// A stack overflow error was encountered.
#define SCRIPT_STACK_OVERFLOW	-1
/// A stack underflow error was encountered.
#define SCRIPT_STACK_UNDERFLOW	-2
/// An undefined error was encountered.
#define SCRIPT_UNDEFINED		-3
