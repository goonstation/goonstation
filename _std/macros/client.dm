//home of some of our checks that check client stuff and other client stuff (and some player stuff because aa)

/// Returns true if given is a client
#define isclient(x) istype(x, /client)
/// Returns true if the given is a mind datum
#define ismind(x) istype(x, /datum/mind)

#define ADMIN_ONLY if(!src.holder) {boutput(src, "<span class='admin'>Only administrators may use this command.</span>"); return}
#define DENY_TEMPMIN if(!src.holder || src.holder.tempmin) {boutput(src, "<span class='admin'>Only administrators may use this command.</span>"); return}
#define MENTOR_ONLY if(!src.mentor) {boutput(src, "<span class='admin'>Only mentors may use this command.</span>"); return}
#define USR_ADMIN_ONLY if(usr?.client && !usr.client.holder) {boutput(usr, "<span class='admin'>Only administrators may use this command.</span>"); return}
