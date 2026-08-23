
ABSTRACT_TYPE(/obj/mesh/flock)
/obj/mesh/flock
	icon = 'icons/misc/featherzone.dmi'
	mat_changename = FALSE
	mat_changedesc = FALSE
	default_material = "gnesis"

	auto_connect = FALSE

// Flock-converted grilles
TYPEINFO(/obj/mesh/flock/barricade)
	mat_appearances_to_ignore = list("steel", "gnesis")
/obj/mesh/flock/barricade
	icon_state = "barricade-0"
	text = "<font color=#4d736d>+"
	density = TRUE
	uses_default_material_appearance = TRUE

	icon_state_prefix = "barricade"

	var/flock_id = "Reinforced barricade"
	var/repair_per_resource = 1

/obj/mesh/flock/barricade/New()
	. = ..()
	src.UpdateIcon()
	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection)

// flockdrones can always move through
/obj/mesh/flock/barricade/Crossed(atom/movable/AM)
	. = ..()
	var/mob/living/critter/flock/drone/drone = AM
	if(istype(drone) && !drone.floorrunning)
		animate_flock_passthrough(AM)
		. = TRUE
	else if(istype(AM,/mob/living/critter/flock))
		. = TRUE

/obj/mesh/flock/barricade/Cross(atom/movable/mover)
	return !src.density || istype(mover,/mob/living/critter/flock)

/obj/mesh/flock/barricade/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"[SPAN_FLOCKSAY("[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
			[SPAN_BOLD("ID:")] [src.flock_id]<br>\
			[SPAN_BOLD("System Integrity:")] [round((src.health/src.health_max)*100)]%<br>\
			[SPAN_BOLD("###=-")]")]"}

/obj/mesh/flock/barricade/hitby(atom/movable/AM, datum/thrown_thing/thr)
	..()
	src.visible_message(SPAN_ALERT("<B>[src] was hit by [AM].</B>"))
	playsound(src.loc, 'sound/impact_sounds/Metal_Hit_Light_1.ogg', 100, 1)
	if (ismob(AM))
		src.damage_blunt(5)
	else if (isobj(AM))
		var/obj/O = AM
		if (O.throwforce)
			src.damage_blunt((max(1, O.throwforce * (1 - (src.blunt_resist / 100)))) / 2) // we don't want people screaming right through these and you can still get through them by kicking/cutting/etc

/obj/mesh/flock/barricade/attack_hand(mob/user)
	if (user.a_intent != INTENT_HARM)
		return
	. = ..()

/obj/mesh/flock/barricade/bullet_act(obj/projectile/P)
	if (istype(P.proj_data, /datum/projectile/energy_bolt/flockdrone))
		return
	. = ..()

/obj/mesh/flock/barricade/special_update_icon(special_icon_state)
	if(special_icon_state != "cut")
		src.UpdateIcon()
		return // flock barriades only have "cut" special icons
	. = ..()

/obj/mesh/flock/barricade/proc/repair(resources_available)
	var/health_given = min(min(resources_available, FLOCK_REPAIR_COST) * src.repair_per_resource, src.health_max - src.health)
	src.health += health_given
	if (src.ruined)
		src.set_density(TRUE)
		src.ruined = FALSE
	src.UpdateIcon()
	return ceil(health_given / src.repair_per_resource)
