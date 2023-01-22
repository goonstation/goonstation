/datum/component/snowballs
	var/turf/source_turf

TYPEINFO(/datum/component/snowballs)
	initialization_args = list()

/datum/component/snowballs/Initialize()
	. = ..()
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE
	else
		source_turf = parent
	RegisterSignal(parent, COMSIG_ATTACKHAND, .proc/start_snowball)

/datum/component/snowballs/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATTACKHAND)
	. = ..()

/datum/component/snowballs/proc/start_snowball(turf/T, mob/user)
	if(!ON_COOLDOWN(source_turf, "snowball", 6 SECONDS))
		actions.start(new /datum/action/bar/icon/callback(user, T, rand(3 SECONDS, 5 SECONDS), /datum/component/snowballs/proc/form_snowball,
		list(user), 'icons/misc/xmas.dmi', "snowball", null, null, src), user)
		return TRUE

/datum/component/snowballs/proc/form_snowball(mob/user)
	user.visible_message("<b>[user]</b> gathers up some snow and rolls it into a snowball!", "You gather up some snow and roll it into a snowball!")
	var/obj/item/reagent_containers/food/snacks/snowball/S = new /obj/item/reagent_containers/food/snacks/snowball(user.loc)
	S.color = source_turf.color
	user.put_in_hand_or_drop(S)
	return
