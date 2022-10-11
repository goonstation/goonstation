/datum/targetable/hunter/hunter_taketrophy
	name = "Take trophy"
	desc = "Retrieves a trophy skull from the victim or severed head, mutilating them in the process."
	icon_state = "taketrophy"
	targeted = 1
	target_anything = 1
	target_nodamage_check = 1
	max_range = 1
	cooldown = 0
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1
	hunter_only = 1
	restricted_area_check = 2

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M || !target)
			return 1

		if (M == target)
			boutput(M, "<span class='alert'>Why would you want to take your own skull?</span>")
			return 1

		if (GET_DIST(M, target) > src.max_range)
			boutput(M, "<span class='alert'>[target] is too far away.</span>")
			return 1

		if (!istype(target, /obj/item/organ/head))
			if (!ishuman(target)) // Only human mobs and severed human heads have a skull.
				if (issilicon(target))
					boutput(M, "<span class='alert'>Mechanical trophies are of no interest to you.</span>")
					return 1

				else
					boutput(M, "<span class='alert'>There's no trophy to be found here.</span>")
					return 1

			else
				var/mob/living/carbon/human/HH = target
				if (isnpcmonkey(HH)) // Lesser form doesn't count.
					boutput(M, "<span class='alert'>This pitiful creature isn't worth your time.</span>")
					return 1

				if (!isdead(HH))
					boutput(M, "<span class='alert'>It would be dishonorable to do that to something you haven't killed yet!</span>")
					return 1

		else
			var/obj/item/organ/head/SH = target
			if (!(SH.skull && istype(SH.skull, /obj/item/skull/)))
				boutput(M, "<span class='alert'>The skull appears to be missing.</span>")
				return 1

		actions.start(new/datum/action/bar/private/icon/hunter_taketrophy(target, src), M)
		return 0

/datum/action/bar/private/icon/hunter_taketrophy
	duration = 60
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "hunter_taketrophy"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "grabbed"
	var/target
	var/datum/targetable/hunter/hunter_taketrophy/trophy

	New(Target, Trophy)
		target = Target
		trophy = Trophy
		..()

	onStart()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/A = trophy.holder

		if (ismob(target))
			var/mob/living/HH = target
			if (!trophy || GET_DIST(M, HH) > trophy.max_range || HH == null || M == null || !ishuman(HH) || !isdead(HH))
				interrupt(INTERRUPT_ALWAYS)
				return
		else
			var/obj/item/organ/head/SH = target
			if (!trophy || GET_DIST(M, SH) > trophy.max_range || SH == null || M == null || !istype(SH) || !(SH.skull && istype(SH.skull, /obj/item/skull/)))
				interrupt(INTERRUPT_ALWAYS)
				return

		M.visible_message("<span class='alert'><B>[M] unsheaths [his_or_her(M)] claws and begins to cut into [target]!</B></span>")
		A.locked = 1

	onUpdate()
		..()

		var/mob/living/M = owner

		if (ismob(target))
			var/mob/living/HH = target
			if (!trophy || GET_DIST(M, HH) > trophy.max_range || HH == null || M == null || !ishuman(HH) || !isdead(HH))
				interrupt(INTERRUPT_ALWAYS)
				return
		else
			var/obj/item/organ/head/SH = target
			if (!trophy || GET_DIST(M, SH) > trophy.max_range || SH == null || M == null || !istype(SH) || !(SH.skull && istype(SH.skull, /obj/item/skull/)))
				interrupt(INTERRUPT_ALWAYS)
				return

	onEnd()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/A = trophy.holder
		A.locked = 0

		var/tvalue = 0
		var/no_of_skulls = 0

		M.visible_message("<span class='alert'><b>[M] completely rips [target] apart!</b></span>")

		// Assign_gimmick_skull() takes care of skull replacements.
		if (ismob(target))
			var/mob/living/carbon/human/HH = target
			if (ishuman(HH))
				for (var/obj/item/W in HH)
					if (istype(W, /obj/item/skull/))
						var/obj/item/skull/S = W
						S.name = "[HH.real_name]'s skull"
						tvalue += S.value // Can might have another skull in their pocket, who knows.
						no_of_skulls++
						S.set_loc(get_turf(HH)) // We always want to drop that skull, since gib ejectables are a RNG thing.
					else
						HH.u_equip(W)
						if (W)
							W.set_loc(get_turf(HH))
							W.dropped(HH)
							W.layer = initial(W.layer)

				logTheThing(LOG_COMBAT, M, "uses take trophy on [constructTarget(HH,"combat")], gibbing them at [log_loc(M)].")
				HH.gib(1)

		else
			var/obj/item/organ/head/SH = target
			if (istype(SH) && SH.skull && istype(SH.skull, /obj/item/skull/))
				var/obj/item/skull/S2 = SH.skull
				tvalue += S2.value
				no_of_skulls++
				S2.set_loc(get_turf(SH))
				SH.UpdateIcon()

			gibs(get_turf(SH))
			qdel(SH)

		switch (no_of_skulls)
			if (0)
				boutput(M, "<span class='alert'><b>Their skull was missing. No trophy for you.</b></span>")
			if (1)
				if (tvalue <= 0)
					boutput(M, "<span class='alert'><b>This trophy is completely worthless!</b></span>")
				if (tvalue == 1)
					boutput(M, "<span class='notice'><b>This trophy has a value of [tvalue].</b></span>")
				if (tvalue > 1)
					boutput(M, "<span class='notice'><b>You have slain a powerful opponent!<br>This trophy has a value of [tvalue].</b></span>")
			else
				boutput(M, "<span class='notice'><b>You found mulitple trophies. They have a combined value of [tvalue].</b></span>")

	onInterrupt()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/A = trophy.holder

		A.locked = 0
		boutput(M, "<span class='alert'>Your attempt to take the trophy was interrupted!</span>")
