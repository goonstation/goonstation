/obj/item/inflatable_mob
	var/mob_type
	var/mob_name = "thing"
	var/datum/gas_mixture/air_contents = new
	HELP_MESSAGE_OVERRIDE("Use a gas tank on this to inflate.")

/obj/item/inflatable_mob/New()
	. = ..()
	src.name = "inflatable [src.mob_name]"
	src.air_contents.volume = 40 LITERS
	RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_setup))

/obj/item/inflatable_mob/proc/assembly_setup(var/manipulated_gorilla, var/obj/item/assembly/parent_assembly, var/mob/user, var/is_build_in)
	parent_assembly.target_item_prefix = src.mob_name

/obj/item/inflatable_mob/attackby(obj/item/tank/tank, mob/user, params)
	if (!istype(tank))
		return ..()
	src.apply_tank(tank, user)

/obj/item/inflatable_mob/proc/can_inflate(obj/item/tank/tank)
	return MIXTURE_PRESSURE(tank.air_contents) >= (ONE_ATMOSPHERE * 2)

/obj/item/inflatable_mob/proc/apply_tank(obj/item/tank/tank, mob/user = null)
	if (!src.can_inflate(tank))
		boutput(user, SPAN_ALERT("[tank] doesn't have enough pressure to inflate a [src.mob_name]!"))
		return FALSE
	tank.air_contents.share(src.air_contents)
	user?.u_equip(tank)
	tank.set_loc(src)
	var/mob/mob_instance = new src.mob_type(get_turf(src))
	if (src.material)
		mob_instance.setMaterial(src.material)
	mob_instance.forensic_holder = src.forensic_holder
	user?.u_equip(src)
	src.set_loc(mob_instance)
	APPLY_ATOM_PROPERTY(mob_instance, PROP_MOB_CANTMOVE, src)
	mob_instance.ai?.disable()
	var/matrix/original_transform = mob_instance.transform
	mob_instance.transform = matrix(mob_instance.transform, 0.1,0.1, MATRIX_SCALE)

	animate(mob_instance, transform = original_transform, time = 5 SECONDS, flags = ANIMATION_END_NOW)
	SPAWN(1 SECOND) //the longest sound effect I could find is still sliiightly too short
		playsound(mob_instance, 'sound/effects/inflate.ogg', 50, 1)
	SPAWN(5 SECONDS)
		REMOVE_ATOM_PROPERTY(mob_instance, PROP_MOB_CANTMOVE, src)
		mob_instance.ai?.enable()
		if(mob_instance.material)
			mob_instance.setMaterial(src.material) // May have broken material animations
		tank.set_loc(get_turf(mob_instance))
		qdel(src)

	return TRUE

/obj/item/inflatable_mob/gorilla
	desc = "A slab of thick, heavy duty rubber with a little orange connector port on the side."
	mob_type = /mob/living/critter/gorilla
	mob_name = "gorilla"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "inflatable_gorilla"
