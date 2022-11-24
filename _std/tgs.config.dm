#define TGS_EXTERNAL_CONFIGURATION

#define TGS_DEFINE_AND_SET_GLOBAL(Name, Value) var/global/##Name = ##Value
#define TGS_READ_GLOBAL(Name) global.##Name
#define TGS_WRITE_GLOBAL(Name, Value) global.##Name = ##Value
#define TGS_WORLD_ANNOUNCE(message) boutput(world, "<B>[##message]</B>")
#define TGS_NOTIFY_ADMINS(event) message_admins("TGS: [##event]")
#define TGS_INFO_LOG(message) logTheThing(LOG_DIARY, null, "TGS Info: [##message]", "debug")
#define TGS_WARNING_LOG(message) logTheThing(LOG_DIARY, null, "TGS Warning: [##message]", "debug")
#define TGS_ERROR_LOG(message) logTheThing(LOG_DIARY, null, "TGS ERROR: [##message]", "debug")
#define TGS_PROTECT_DATUM(Path) // No VV?
#define TGS_CLIENT_COUNT length(clients)
