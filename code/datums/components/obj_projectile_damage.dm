/datum/component/obj_projectile_damage
	dupe_mode = COMPONENT_DUPE_UNIQUE

TYPEINFO(/datum/component/obj_projectile_damage)
	initialization_args = list()

/datum/component/obj_projectile_damage/Initialize()
	. = ..()
	if(!istype(parent, /obj))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ATOM_HITBY_PROJ, .proc/projectile_collide)
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, .proc/examine)

/datum/component/obj_projectile_damage/proc/projectile_collide(owner, var/obj/projectile/P)
	var/obj/O = parent
	if(P.proj_data.damage_type & (D_KINETIC | D_ENERGY | D_SLASHING))
		if (O && (O._health/O._max_health) <= 0.5 && prob((1 - O._health/O._max_health) * 60))
			var/obj/decal/cleanable/machine_debris/gib = make_cleanable(/obj/decal/cleanable/machine_debris, O.loc)
			gib.streak_cleanable()
		hit_twitch(O)
		O.changeHealth(-round(((P.power/2)*P.proj_data.ks_ratio), 1.0))

/datum/component/obj_projectile_damage/proc/examine(mob/owner, mob/examiner, list/lines)
	var/obj/O = parent
	switch(O._health/O._max_health)
		if (0.6 to 0.9)
			lines += "<span class='alert'>It is a little bit damaged.</span>"
		if (0.3 to 0.6)
			lines += "<span class='alert'>It looks pretty beaten up.</span>"
		if (0 to 0.3)
			lines += "<span class='alert'><b>It seems to be on the verge of falling apart!</b></span>"

/datum/component/obj_projectile_damage/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_HITBY_PROJ, COMSIG_ATOM_EXAMINE))
	. = ..()
