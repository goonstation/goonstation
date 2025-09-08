// Macro to quickly add syndicate-specific descriptions to stealth items to make them easily identifiable to traitors (and spiefs who use their gear)
#define SYNDICATE_STEALTH_DESCRIPTION(TYPE, syndie_desc, alt_desc) \
	TYPE/get_desc(dist, mob/user) { \
		..(); \
		if(istrainedsyndie(user) || isspythief(user)) {. += SPAN_ALERT("<b> [syndie_desc]</b>")} \
		else {. += (" [alt_desc]")} \
	}
