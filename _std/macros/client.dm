//home of some of our checks that check client stuff and other client stuff (and some player stuff because aa)

/// Returns true if given is a client
#define isclient(x) istype(x, /client)
/// Returns true if the given is a mind datum
#define ismind(x) istype(x, /datum/mind)
/// Returns true if the given mob is hellbanned
#define ishellbanned(x) x?.client?.hellbanned

#define admin_only if(!src.holder) {boutput(src, "Only administrators may use this command."); return}
#define mentor_only if(!src.mentor) {boutput(src, "Only mentors may use this command."); return}
#define usr_admin_only if(usr?.client && !usr.client.holder) {boutput(usr, "Only administrators may use this command."); return}
