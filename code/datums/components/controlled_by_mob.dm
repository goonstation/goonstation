TYPEINFO(/datum/component/controlled_by_mob)
	initialization_args = list(
		ARG_INFO("controlling_mob", DATA_INPUT_MOB_REFERENCE, "Mob to control the component")
	)

/datum/component/controlled_by_mob
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/mob/controlling_mob
	var/control_from_inside = 0
	var/datum/movement_controller/movement_controller

/datum/component/controlled_by_mob/from_inside
	control_from_inside = 1

/datum/component/controlled_by_mob/Initialize(mob/controlling_mob)
	. = ..()
	if(!istype(parent, /obj))
		return COMPONENT_INCOMPATIBLE
	var/obj/O = parent
	src.controlling_mob = controlling_mob
	src.movement_controller = new/datum/movement_controller/obj_control(O)
	src.controlling_mob.override_movement_controller = src.movement_controller

/datum/component/controlled_by_mob/proc/change_mob(mob/new_mob)
	src.kick_out_mob()
	src.controlling_mob = new_mob
	src.reinsert_mob()

/datum/component/controlled_by_mob/proc/reinsert_mob()
	var/obj/O = parent
	if(src.control_from_inside)
		src.controlling_mob.set_loc(O)
		APPLY_ATOM_PROPERTY(src.controlling_mob,PROP_MOB_REBREATHING,src)
	else
		src.controlling_mob.client.eye = O
	src.controlling_mob.override_movement_controller = src.movement_controller
	controlling_mob.reset_keymap()

/datum/component/controlled_by_mob/proc/kick_out_mob()
	var/obj/O = parent
	if(src.controlling_mob)
		if(src.control_from_inside)
			src.controlling_mob.set_loc(get_turf(O))
			REMOVE_ATOM_PROPERTY(src.controlling_mob,PROP_MOB_REBREATHING,src)
		else
			controlling_mob.client.eye = controlling_mob
		src.controlling_mob.override_movement_controller = null
		controlling_mob.reset_keymap()

/datum/component/controlled_by_mob/RegisterWithParent()
	. = ..()
	src.reinsert_mob()

/datum/component/controlled_by_mob/UnregisterFromParent()
	. = ..()
	src.kick_out_mob()

/datum/component/controlled_by_mob/disposing()
	. = ..()
	src.controlling_mob = null
	qdel(src.movement_controller)
	src.movement_controller = null
