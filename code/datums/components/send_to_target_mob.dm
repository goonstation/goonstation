/datum/component/send_to_target_mob
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/obj/item/tracked_item = null

TYPEINFO(/datum/component/send_to_target_mob)
	initialization_args = list()

/datum/component/send_to_target_mob/Initialize(tracked_item)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(isitem(tracked_item))
		RegisterSignal(tracked_item, COMSIG_SEND_TO_MOB, .proc/send)

/datum/component/send_to_target_mob/proc/send(datum/source, var/mob/living/M, teleport_effect = FALSE, )
	var/obj/item/I = src.parent
	if (!I || !istype(I) || !M || !istype(M))
		return

	I.visible_message("<span class='alert'><b>The [I.name] is suddenly warped away!</b></span>")
	elecflash(I)

	if (ismob(I.loc))
		var/mob/M2 = I.loc
		M2.u_equip(I)
	if (istype(I.loc, /obj/item/storage))
		var/obj/item/storage/S_temp = I.loc
		var/datum/hud/storage/H_temp = S_temp.hud
		H_temp.remove_object(I)

	I.set_loc(get_turf(M))
	if (teleport_effect)
		flick("[initial(I.icon_state)]-tele", I)
	if (!M.put_in_hand(I))
		M.show_text("[I.name] summoned successfully. You can find it on the floor at your current location.", "blue")
	else
		M.show_text("[I.name] summoned successfully. You can find it in your hand.", "blue")

/datum/component/send_to_target_mob/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_SEND_TO_MOB)
	. = ..()
