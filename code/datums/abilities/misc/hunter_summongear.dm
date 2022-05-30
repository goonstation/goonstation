/datum/targetable/hunter/hunter_summongear
	name = "Recover gear"
	desc = "Teleports your hunting gear to your location."
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 40 SECONDS
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1
	hunter_only = 1

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M || !ishuman(M))
			return 1

		actions.start(new/datum/action/bar/private/icon/hunter_summongear(src), M)
		return 0

/datum/action/bar/private/icon/hunter_summongear
	duration = 5 SECONDS
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_ACTION
	id = "hunter_gearteleport"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"

	onStart()
		..()

		var/mob/living/M = owner

		if (M == null || !ishuman(M) || !isalive(M) || M.getStatusDuration("paralysis") > 0)
			interrupt(INTERRUPT_ALWAYS)
			return

		boutput(M, "<span class='alert'><B>Request acknowledged. You must stand still.</B></span>")

	onUpdate()
		..()

		var/mob/living/M = owner

		if (M == null || !ishuman(M) || !isalive(M) || M.getStatusDuration("weakened") || M.getStatusDuration("paralysis") > 0 || !isalive(M) || M.restrained())
			interrupt(INTERRUPT_ALWAYS)
			return

	onEnd()
		..()

		var/mob/living/M = owner
		var/gun_found = FALSE
		var/spear_found = FALSE
		var/cloak_found = FALSE
		for(var/HG in by_cat[TR_CAT_HUNTER_GEAR])
			if (istype(HG, /obj/item/gun/energy/plasma_gun/hunter))
				var/obj/item/gun/energy/plasma_gun/hunter/PG = HG
				if (M.mind?.key == PG.hunter_key)
					if (get_turf(M.loc) == get_turf(PG.loc))
						gun_found = TRUE
					else
						SEND_SIGNAL(PG, COMSIG_SEND_TO_MOB, M, TRUE)
						gun_found = TRUE
			else if (istype(HG, /obj/item/knife/butcher/hunterspear))
				var/obj/item/knife/butcher/hunterspear/HS = HG
				if (M.mind?.key == HS.hunter_key)
					if (get_turf(M.loc) == get_turf(HS.loc))
						spear_found = TRUE
					else
						SEND_SIGNAL(HS, COMSIG_SEND_TO_MOB, M, TRUE)
						spear_found = TRUE
			else if (istype(HG, /obj/item/cloaking_device/hunter))
				var/obj/item/cloaking_device/hunter/HC = HG
				if (M.mind?.key == HC.hunter_key)
					if (get_turf(M.loc) == get_turf(HC.loc))
						cloak_found = TRUE
					else
						SEND_SIGNAL(HC, COMSIG_SEND_TO_MOB, M, TRUE)
						cloak_found = TRUE
		if (!gun_found)
			boutput(M, "<span class='alert'>Your plasma gun is lost or destroyed!</span>")
		if (!spear_found)
			boutput(M, "<span class='alert'>Your hunting spear is lost or destroyed!</span>")
		if (!cloak_found)
			boutput(M, "<span class='alert'>Your cloaking device is lost or destroyed!</span>")

	onInterrupt()
		..()

		var/mob/living/M = owner
		boutput(M, "<span class='alert'>You were interrupted!</span>")
