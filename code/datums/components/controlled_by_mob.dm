/obj/movement_controller_dummy
	mouse_opacity = 0
	var/datum/movement_controller/movement_controller

	New(loc, movement_controller)
		. = ..()
		src.movement_controller = movement_controller

	get_movement_controller(mob/user)
		. = ..()
		return movement_controller

	handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
		return new/datum/gas_mixture{oxygen = 2; temperature = T20C}()

/datum/component/controlled_by_mob
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/obj/movement_controller_dummy
	var/mob/controlling_mob

/datum/component/controlled_by_mob/Initialize(mob/controlling_mob)
	if(!istype(parent, /obj))
		return COMPONENT_INCOMPATIBLE
	var/obj/O = parent
	src.controlling_mob = controlling_mob
	src.movement_controller_dummy = new/obj/movement_controller_dummy(null, new/datum/movement_controller/obj_control(O))
	src.movement_controller_dummy.name = O.name

/datum/component/controlled_by_mob/proc/change_mob(mob/new_mob)
	src.kick_out_mob()
	src.controlling_mob = new_mob
	src.reinsert_mob()

/datum/component/controlled_by_mob/proc/reinsert_mob()
	var/obj/O = parent
	controlling_mob.set_loc(movement_controller_dummy)
	controlling_mob.update_keymap()
	controlling_mob.client.eye = O

/datum/component/controlled_by_mob/proc/kick_out_mob()
	var/obj/O = parent
	if(src.controlling_mob && src.controlling_mob.use_movement_controller == movement_controller_dummy)
		src.controlling_mob.set_loc(get_turf(O))
		controlling_mob.update_keymap()
		controlling_mob.client.eye = controlling_mob

/datum/component/controlled_by_mob/RegisterWithParent()
	. = ..()
	src.reinsert_mob()

/datum/component/controlled_by_mob/UnregisterFromParent()
	. = ..()
	src.kick_out_mob()

/datum/component/controlled_by_mob/disposing()
	. = ..()
	src.controlling_mob = null
	qdel(movement_controller_dummy)
	src.movement_controller_dummy = null
