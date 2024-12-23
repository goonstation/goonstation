//home of some of our checks that check client stuff and other client stuff (and some player stuff because aa)

/// Returns true if given is a client
#define isclient(x) istype(x, /client)
/// Returns true if the given is a mind datum
#define ismind(x) istype(x, /datum/mind)

#define ADMIN_ONLY if(!src.holder) {boutput(src, SPAN_ADMIN("Only administrators may use this command.")); return}
#define DENY_TEMPMIN if(!src.holder || src.holder.tempmin) {boutput(src, SPAN_ADMIN("Only administrators may use this command.")); return}
#define MENTOR_ONLY if(!src.mentor) {boutput(src, SPAN_ADMIN("Only mentors may use this command.")); return}
#define USR_ADMIN_ONLY if(usr?.client && !usr.client.holder) {boutput(usr, SPAN_ADMIN("Only administrators may use this command.")); return}

#ifdef SPACEMAN_DMM //spaceman doesn't like ....... syntax, can't think why
	#define CURRENT_PROC_PATH null
#elif defined(OPENDREAM) || DM_VERSION >= 515 //OD has a sane version and byond added it too in 515
	#define CURRENT_PROC_PATH __PROC__
#else //aaand then there's 514
	#define CURRENT_PROC_PATH .......
#endif

#define SHOW_VERB_DESC do {\
	var/procpath/this_proc = CURRENT_PROC_PATH;\
	if(usr?.client.check_key(KEY_EXAMINE)) {\
		boutput(usr, "<span class='helpmsg'>[this_proc.desc || "No verb desc found"]</span>");\
		return\
	}\
} while(FALSE)
