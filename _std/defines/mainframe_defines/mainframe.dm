//------------ Generic Commands ------------//
/// The absolute path from the root directory of the provided path.
#define ABSOLUTE_PATH(PATH, CURRENT_PATH) (findtext(PATH, "/", 1, 2) ? PATH : ("[CURRENT_PATH][(CURRENT_PATH == "/") ? "" : "/"][PATH]"))
/// Global list representing the standard exit command packet.
var/global/list/generic_exit_list = list("command" = DWAINE_COMMAND_EXIT)
/// Exit the current running program.
#define mainframe_prog_exit src.signal_program(1, global.generic_exit_list)


//------------ Misc ------------//
#define MIN_NUKE_TIME 120
#define MAX_NUKE_TIME 600
