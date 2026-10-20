/datum/component/death_barf // interacts with mimic_stomach
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/obj/limb_list = list()

/datum/component/death_barf/Initialize()
	. = ..()
	RegisterSignal(src.parent, COMSIG_MOB_DEATH, PROC_REF(barf))

/datum/component/death_barf/proc/record_limb(atom/target) // called by eat_limb's gobble()
	if (target in src.limb_list)
		return
	LAZYLISTADD(src.limb_list, target)

/datum/component/death_barf/proc/barf()
	UnregisterSignal(src.parent, COMSIG_MOB_DEATH)
	var/pitch_counter = 2
	for (var/obj/eaten_thing in src.limb_list)
		eaten_thing.set_loc(get_turf(src.parent))
		ThrowRandom(eaten_thing, 10, 2, bonus_throwforce=10)
		if (!ON_COOLDOWN(global, "burp", 1 SECONDS))
			playsound(src.parent, 'sound/voice/burp_alien.ogg', 60, 0, pitch=pitch_counter)
			if (pitch_counter >= 0)
				pitch_counter -= 0.5
		sleep(0.2 SECONDS)
	playsound(src, 'sound/voice/burp_alien.ogg', 60, 1, pitch=-2)
	src.RemoveComponent(/datum/component/death_barf)
