
// dummy stuff so the linter doesn't compile on 514
#if DM_VERSION < 514

#ifndef SPACEMAN_DMM
#warn Please update your BYOND version to the version in /buildByond.conf in order to host the game properly.
#endif

#define NORMAL_RAND 69
proc/generator(type, A, B, rand)
	var/generator/gen = new
	gen.lower = A
	gen.upper = B
	return gen

/generator
	parent_type = /datum
	var/lower
	var/upper

	proc/Rand()
		return rand() * (upper - lower) + lower
#endif
