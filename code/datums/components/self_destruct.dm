/datum/component/self_destruct
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/mob/tracked_mob = null

TYPEINFO(/datum/component/self_destruct)
	initialization_args = list()

/datum/component/self_destruct/Initialize(tracked_mob)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(ismob(tracked_mob))
		RegisterSignal(tracked_mob, COMSIG_MOB_DEATH, .proc/destruct)

/datum/component/self_destruct/proc/destruct(datum/source)
	var/obj/item/I = src.parent
	SPAWN(2 SECONDS)
		I.visible_message("<span class='alert'>\The [I] <b>self destructs!</b></span>", "<span class='alert'>You hear a small explosion!</b></span>")
		new /obj/effect/supplyexplosion(I.loc)
		if(ismob(I.loc))
			var/mob/holding_mob = I.loc
			holding_mob.u_equip(I)
			I.dropped(holding_mob)
		qdel(I)

/datum/component/self_destruct/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_DEATH)
	. = ..()
