//------------ DWAINE Setup Filepaths ------------//
CREATE_NAMESPACE(DWAINE, DIRECTORY)

/// Filepath that corresponds to the directory for user record files.
ADD_TO_NAMESPACE(DWAINE, DIRECTORY)(var/const/USERS = "/usr")
/// Filepath that corresponds to the directory for personal user directories.
ADD_TO_NAMESPACE(DWAINE, DIRECTORY)(var/const/HOME = "/home")
/// Filepath that corresponds to the directory for device and pseudo-device files.
ADD_TO_NAMESPACE(DWAINE, DIRECTORY)(var/const/DEVICES = "/dev")
/// Filepath that corresponds to the directory for device file prototypes. Prototypes are named after the ID of their respective device, excluding the "pnet_" prefix.
ADD_TO_NAMESPACE(DWAINE, DIRECTORY)(var/const/DRIVERS = "/sys/drvr")
/// Filepath that corresponds to the directory for mounted file systems, such as databanks.
ADD_TO_NAMESPACE(DWAINE, DIRECTORY)(var/const/MOUNTED = "/mnt")
/// Filepath that corresponds to the directory for the OS, including the kernel, shell, and login program.
ADD_TO_NAMESPACE(DWAINE, DIRECTORY)(var/const/SYSTEM = "/sys")
/// Filepath that corresponds to the directory for configuration files.
ADD_TO_NAMESPACE(DWAINE, DIRECTORY)(var/const/CONFIG = "/conf")
/// Filepath that corresponds to the directory for binaries (executable files). It contains fundamental system utilities, including system commands, such as `ls` or `cd`.
ADD_TO_NAMESPACE(DWAINE, DIRECTORY)(var/const/BINARIES = "/bin")
/// Filepath that corresponds to the directory for information files pertaining to active processes.
ADD_TO_NAMESPACE(DWAINE, DIRECTORY)(var/const/PROCESSES = "/proc")
