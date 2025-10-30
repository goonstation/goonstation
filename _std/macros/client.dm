//home of some of our checks that check client stuff and other client stuff (and some player stuff because aa)

/// Returns true if given is a client
#define isclient(x) istype(x, /client)
/// Returns true if the given is a mind datum
#define ismind(x) istype(x, /datum/mind)

#define ADMIN_ONLY if(!src.holder) {boutput(src, SPAN_ADMIN("Only administrators may use this command.")); return}
#define DENY_TEMPMIN if(!src.holder || src.holder.tempmin) {boutput(src, SPAN_ADMIN("Only administrators may use this command.")); return}
#define MENTOR_ONLY if(!src.mentor) {boutput(src, SPAN_ADMIN("Only mentors may use this command.")); return}
#define USR_ADMIN_ONLY if(usr?.client && !usr.client.holder) {boutput(usr, SPAN_ADMIN("Only administrators may use this command.")); return}

#define SHOW_VERB_DESC do {\
	var/procpath/this_proc = __PROC__;\
	if(usr?.client?.check_key(KEY_EXAMINE)) {\
		boutput(usr, "<span class='helpmsg'>[this_proc.desc || "No verb desc found"]</span>");\
		return\
	}\
} while(FALSE)
