// Adds a syndicate only description to any type. syndie_desc is shown to syndies and spiefs, alt_desc is shown to everyone else, both are optional.
// Do NOT forget to add REBUILD_USER to any items with a syndicate stealth description!
#define SYNDICATE_STEALTH_DESCRIPTION(syndie_desc, alt_desc) \
	get_desc(dist, mob/user) { \
		. = ..(); \
		if(istrainedsyndie(user) || isspythief(user)) {. += SPAN_ALERT(SPAN_BOLD("<br>[syndie_desc]"))} \
		else {. += (" [alt_desc] ")} \
	}

// Modifiys the description of the type based on the existance of a trait
// Do NOT forget to add REBUILD_USER to any items with a trait altered description!
#define TRAIT_ALTERED_DESCRIPTION(trait_id, trait_desc, no_trait_desc) \
	get_desc(dist, mob/user) { \
		. = ..(); \
		if(user.traitHolder.hasTrait(trait_id)) {. += (" [trait_desc]")} \
		else if(length(no_trait_desc)) {. += (" [no_trait_desc]")} \
	}
