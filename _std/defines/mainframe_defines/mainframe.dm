//------------ Generic Commands ------------//
/// Global list representing the standard exit command packet.
var/global/list/generic_exit_list = list("command" = DWAINE_COMMAND_EXIT)
/// Exit the current running program.
#define mainframe_prog_exit src.signal_program(1, global.generic_exit_list)


//------------ Misc ------------//
#define MIN_NUKE_TIME 120
#define MAX_NUKE_TIME 600
