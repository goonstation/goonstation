/// Namespace for DWAINE errors.
CREATE_NAMESPACE(DWAINE, ERR)

//------------ DWAINE Program Signal Errors ------------//
CREATE_NAMESPACE(DWAINE, ERR, SIG)
/// The command was carried out successfully.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/SUCCESS = 0)
/// The command could not be carried out successfully.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/GENERIC = (1 << 0))
/// The command could not be carried out successfully, as a target was required and could not be found.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/NOTARGET = (1 << 1))
/// The command could not be carried out successfully, as the command was not recognised.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/BADCOMMAND = (1 << 2))
/// The command could not be carried out successfully, as a user was required and could not be found.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/NOUSR = (1 << 3))
/// The command could not be carried out successfully, as a result of an I/O error.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/IOERR = (1 << 4))
/// The command could not be carried out successfully, as a file was required and could not be found.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/NOFILE = (1 << 5))
/// The command could not be carried out successfully, as write permission was required.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/NOWRITE = (1 << 6))

/// User defined signal 1. This indicates an application-specific error condition has occured.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/USR1 = (1 << 7))
/// User defined signal 2. This indicates an application-specific error condition has occured.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/USR2 = (1 << 8))
/// User defined signal 3. This indicates an application-specific error condition has occured.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/USR3 = (1 << 9))
/// User defined signal 4. This indicates an application-specific error condition has occured.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/USR4 = (1 << 10))

/// If a command is expected to return a number, it will be signed with the databit to signify that it is not an error condition.
ADD_TO_NAMESPACE(DWAINE, ERR, SIG)(var/const/DATABIT = (1 << 15))


//------------ DWAINE Shell Errors ------------//
CREATE_NAMESPACE(DWAINE, ERR, SHELL)

//------------ DWAINE Shell Builtin Errors ------------//
CREATE_NAMESPACE(DWAINE, ERR, SHELL, BUILTIN)
/// The command was carried out successfully.
ADD_TO_NAMESPACE(DWAINE, ERR, SHELL, BUILTIN)(var/const/SUCCESS = 0)
/// The command has instructed the shell to halt processing.
ADD_TO_NAMESPACE(DWAINE, ERR, SHELL, BUILTIN)(var/const/BREAK = 1)
/// The command has instructed the shell to move to the next line of the script.
ADD_TO_NAMESPACE(DWAINE, ERR, SHELL, BUILTIN)(var/const/CONTINUE = 2)


//------------ DWAINE Shell Executable Errors ------------//
CREATE_NAMESPACE(DWAINE, ERR, SHELL, EXEC)
/// The file was unable to be executed.
ADD_TO_NAMESPACE(DWAINE, ERR, SHELL, EXEC)(var/const/FAILURE = 0)
/// The file was executed successfully.
ADD_TO_NAMESPACE(DWAINE, ERR, SHELL, EXEC)(var/const/SUCCESS = 1)
/// The script was unable to be executed.
ADD_TO_NAMESPACE(DWAINE, ERR, SHELL, EXEC)(var/const/SCRIPT_ERROR = 2)
/// A stack overflow error was encountered. In this case, `DWAINE::SHELL::CONSTS::MAX_SCRIPT_ITERATIONS` was exceeded.
ADD_TO_NAMESPACE(DWAINE, ERR, SHELL, EXEC)(var/const/STACK_OVERFLOW = 3)


//------------ DWAINE Shell Script Errors ------------//
CREATE_NAMESPACE(DWAINE, ERR, SHELL, SCRIPT)
/// The script was executed successfully.
ADD_TO_NAMESPACE(DWAINE, ERR, SHELL, SCRIPT)(var/const/SUCCESS = 0)
/// A stack overflow error was encountered.
ADD_TO_NAMESPACE(DWAINE, ERR, SHELL, SCRIPT)(var/const/STACK_OVERFLOW = -1)
/// A stack underflow error was encountered.
ADD_TO_NAMESPACE(DWAINE, ERR, SHELL, SCRIPT)(var/const/STACK_UNDERFLOW = -2)
/// An undefined error was encountered.
ADD_TO_NAMESPACE(DWAINE, ERR, SHELL, SCRIPT)(var/const/UNDEFINED = -3)
