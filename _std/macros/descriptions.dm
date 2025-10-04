// Adds a syndicate only description to any type. syndie_desc is shown to syndies and spiefs, alt_desc is shown to everyone else, both are optional.
#define SYNDICATE_STEALTH_DESCRIPTION(syndie_desc, alt_desc) \
	get_desc(dist, mob/user) { \
		. = ..(); \
		if(istrainedsyndie(user) || isspythief(user)) {. += SPAN_ALERT("<b> [syndie_desc]</b>")} \
		else {. += (" [alt_desc] ")} \
	}
