//------------ DWAINE System Calls ------------//
/**
 *	Send a message or file to a connected terminal device.
 *	Accepted data fields:
 *	- `"term"`: The net ID of the target terminal.
 *	- `"data"`: If sending a message, the content of that message. Otherwise acts as file data.
 *	- `"render"`: If sending a message, determines how that message should be displayed. Values may be combined using `|`.
 *		Accepted values:
 *		- `"clear"`: The screen should be cleared before the message is displayed.
 *		- `"multiline"`: `|n` should be interpreted as a line break.
 */
#define DWAINE_COMMAND_MSG_TERM	1

/**
 *	Send a log in request to the kernel.
 *	Accepted data fields:
 *	- `"name"`: The username of the user attempting to log in. Set to `"TEMP"` if attempting to login as a temporary user.
 *	- `"sysop"`: Whether the user is a superuser.
 *	- `"service"`: Whether the user connecting is a service terminal.
 *	- `"data"`: If attempting to login as a temporary user, the net ID of the user terminal.
 */
#define DWAINE_COMMAND_ULOGIN	2

/**
 *	Update the user's group.
 *	Accepted data fields:
 *	- `"group"`: The desired value of the `group` field on the user's record file.
 */
#define DWAINE_COMMAND_UGROUP	3

/**
 *	List all current users.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_ULIST	4

/**
 *	Send message to a connected user terminal. Cannot send messages to non-user terminals.
 *	Accepted data fields:
 *	- `"term"`: The net ID of the target user terminal.
 *	- `"data"`: The content of the message.
 */
#define DWAINE_COMMAND_UMSG		5

/**
 *	Acts as an alternate path for user input.
 *	Accepted data fields:
 *	- `"term"`: The net ID of the user terminal.
 *	- `"data"`: If a file is not provided, the content of the input.
 */
#define DWAINE_COMMAND_UINPUT	6

/**
 *	Send message to a specified driver.
 *	Accepted data fields:
 *	- `"target"`: The name or ID of the target driver.
 *	- `"mode"`: If `1`, search for drivers by name, if `0`, search by ID.
 *	- `"dcommand"`: The `"command"` field to pass to the driver.
 *	- `"dtarget"`: The `"target"` field to pass to the driver.
 */
#define DWAINE_COMMAND_DMSG		7

/**
 *	List all drivers of a specific terminal type.
 *	Accepted data fields:
 *	- `"dtag"`: The terminal type of the drivers to search for.
 *	- `"mode"`: If `1`, omit empty or invalid indexes, if `0`, do not.
 */
#define DWAINE_COMMAND_DLIST	8

/**
 *	Get the ID of a specific driver.
 *	Accepted data fields:
 *	- `"dtag"`: The terminal type of the drivers to search for.
 *	- `"dnetid"`: If `"dtag"` is not specified, the driver name to search for. Driver names correspond to the net ID of their respective device, excluding the "pnet_" prefix.
 */
#define DWAINE_COMMAND_DGET		9

/**
 *	Instruct the mainframe to recheck for devices now instead of waiting for the full timeout.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_DSCAN	10

/**
 *	Instruct the caller_prog to exit the current running program.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_EXIT		11

/**
 *	Run a task located at a specified filepath.
 *	Accepted data fields:
 *	- `"path"`: The filepath at which the task is located.
 *	- `"passusr"`: Whether to pass the user to the task.
 *	- `"args"`: The arguments to pass to the task.
 */
#define DWAINE_COMMAND_TSPAWN	12

/**
 *	Run a new child task of the calling program's type.
 *	Accepted data fields:
 *	- `"args"`: The arguments to pass to the task.
 */
#define DWAINE_COMMAND_TFORK	13

/**
 *	Terminate a child task of the calling program.
 *	Accepted data fields:
 *	- `"target"`: The ID of the target task.
 */
#define DWAINE_COMMAND_TKILL	14

/**
 *	List all child tasks of the calling program.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_TLIST	15

/**
 *	Instruct a program to exit the current running task.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_TEXIT	16

/**
 *	Get the computer file at the specified filepath.
 *	Accepted data fields:
 *	- `"path"`: The filepath at which the computer file is located.
 */
#define DWAINE_COMMAND_FGET		17

/**
 *	Delete the computer file at the specified filepath.
 *	Accepted data fields:
 *	- `"path"`: The filepath at which the computer file is located.
 */
#define DWAINE_COMMAND_FKILL	18

/**
 *	Adjust the permissions of the computer file at the specified filepath.
 *	Accepted data fields:
 *	- `"path"`: The filepath at which the computer file is located.
 *	- `"permission"`: The desired permission level of the computer file.
 */
#define DWAINE_COMMAND_FMODE	19

/**
 *	Adjust the owner and group of the computer file at the specified filepath.
 *	Accepted data fields:
 *	- `"path"`: The filepath at which the computer file is located.
 *	- `"owner"`: The desired owner of the computer file.
 *	- `"group"`: The desired group value of the computer file.
 */
#define DWAINE_COMMAND_FOWNER	20

/**
 *	Write a provided computer file to the specified path.
 *	Accepted data fields:
 *	- `"path"`: The filepath at which the computer file should be written to.
 *	- `"mkdir"`: Whether to create the filepath if it does not exist.
 *	- `"replace"`: If the computer file already exists, whether to overwrite it.
 *	- `"append"`: If the computer file already exists, whether to append the contents of the new file to it.
 */
#define DWAINE_COMMAND_FWRITE	21

/**
 *	Get the config file of the specified name.
 *	Accepted data fields:
 *	- `"fname"`: The name of the config file.
 */
#define DWAINE_COMMAND_CONFGET	22

/**
 *	Set up a mountpoint for a device driver.
 *	Accepted data fields:
 *	- `"id"`: The name of the device driver to set up a mountpoint for.
 *	- `"link"`: If set, the name of the symbolic link folder to set up for the mountpoint.
 */
#define DWAINE_COMMAND_MOUNT	23

/**
 *	Instruct a program to receive and handle a file.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_RECVFILE	24

/**
 *	Instruct a program to halt processing a script.
 *	No applicable data fields.
 */
#define DWAINE_COMMAND_BREAK	25

/**
 *	Reply to a request for information.
 *	Has unique data fields for each implementation, depending on the data requested.
 */
#define DWAINE_COMMAND_REPLY	30
