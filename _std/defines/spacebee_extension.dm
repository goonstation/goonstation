
/// from the Discord the command will need this prefix in asay (that is after the base ; prefix) to be recognized
#define SPACEBEE_EXTENSION_ASAY_PREFIX ";"

/// server id of the server that processes commands with server_targeting = COMMAND_TARGETING_MAIN_SERVER
#define SPACEBEE_EXTENSION_MAIN_SERVER "main4"

/// values for the server_targeting var of commands, picks which server processes a given command

/// command requires a server key at the end - e.g. ;;gib2 pali6
#define COMMAND_TARGETING_SINGLE_SERVER 1
/// command is always ran on the main server
#define COMMAND_TARGETING_MAIN_SERVER 2
/// command is always ran on all servers at once
#define COMMAND_TARGETING_ALL_SERVERS 3
