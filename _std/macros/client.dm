//home of some of our checks that check client stuff and other client stuff (and some player stuff because aa)

#define isclient(x) istype(x, /client)
#define ismind(x) istype(x, /datum/mind)
#define ishellbanned(x) x?.client?.hellbanned

#define admin_only if(!src.holder) {boutput(src, "Only administrators may use this command."); return}
#define mentor_only if(!src.mentor) {boutput(src, "Only mentors may use this command."); return}
#define usr_admin_only if(usr && usr.client && !usr.client.holder) {boutput(usr, "Only administrators may use this command."); return}
