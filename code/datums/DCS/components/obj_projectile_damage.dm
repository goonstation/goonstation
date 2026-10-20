/datum/component/obj_projectile_damage
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/obj/decal/cleanable/gib_type = /obj/decal/cleanable/machine_debris
	var/do_gib = TRUE
	var/do_streak = TRUE

TYPEINFO(/datum/component/obj_projectile_damage)
	initialization_args = list()

/datum/component/obj_projectile_damage/Initialize(var/obj/decal/cleanable/gib_type = /obj/decal/cleanable/machine_debris, var/do_gib = TRUE, var/do_streak = TRUE)
	. = ..()
	if(!istype(parent, /obj))
		return COMPONENT_INCOMPATIBLE
	src.gib_type = gib_type
	src.do_gib = do_gib
	src.do_streak = do_streak
	RegisterSignal(parent, COMSIG_ATOM_HITBY_PROJ, PROC_REF(projectile_collide))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))

/datum/component/obj_projectile_damage/proc/projectile_collide(owner, var/obj/projectile/P)
	var/obj/O = parent
	if(P.proj_data.damage_type & (D_KINETIC | D_ENERGY | D_SLASHING))
		if (O && (O._health/O._max_health) <= 0.5 && prob((1 - O._health/O._max_health) * 60))
			var/obj/decal/cleanable/gib = null
			if (src.do_gib)
				gib = make_cleanable(src.gib_type, O.loc)
			if (gib && src.do_streak)
				gib.streak_cleanable()
		hit_twitch(O)
		O.changeHealth(-round(((P.power/2)*P.proj_data.ks_ratio), 1.0))

/datum/component/obj_projectile_damage/proc/examine(mob/owner, mob/examiner, list/lines)
	var/obj/O = parent
	switch(O._health/O._max_health)
		if (0.6 to 0.9)
			lines += SPAN_ALERT("It is a little bit damaged.")
		if (0.3 to 0.6)
			lines += SPAN_ALERT("It looks pretty beaten up.")
		if (0 to 0.3)
			lines += SPAN_ALERT("<b>It seems to be on the verge of falling apart!</b>")

/datum/component/obj_projectile_damage/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_HITBY_PROJ, COMSIG_ATOM_EXAMINE))
	. = ..()
