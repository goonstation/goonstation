//------------ DWAINE Setup Filepaths ------------//
/// Filepath that corresponds to the directory for user record files.
#define setup_filepath_users "/usr"
/// Filepath that corresponds to the directory for personal user directories.
#define setup_filepath_users_home "/home"
/// Filepath that corresponds to the directory for device and pseudo-device files.
#define setup_filepath_drivers "/dev"
/// Filepath that corresponds to the directory for device file prototypes. Prototypes are named after the ID of their respective device, excluding the "pnet_" prefix.
#define setup_filepath_drivers_proto "/sys/drvr"
/// Filepath that corresponds to the directory for mounted file systems, such as databanks.
#define setup_filepath_volumes "/mnt"
/// Filepath that corresponds to the directory for the OS, including the kernel, shell, and login program.
#define setup_filepath_system "/sys"
/// Filepath that corresponds to the directory for configuration files.
#define setup_filepath_config "/conf"
/// Filepath that corresponds to the directory for binaries (executable files). It contains fundamental system utilities, including system commands, such as `ls` or `cd`.
#define setup_filepath_commands "/bin"
/// Filepath that corresponds to the directory for information files pertaining to active processes.
#define setup_filepath_process "/proc"
