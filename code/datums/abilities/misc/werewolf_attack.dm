/datum/targetable/werewolf/werewolf_feast
	name = "Maul victim"
	desc = "Feast on the target to quell your hunger."
	targeted = 1
	target_nodamage_check = 1
	max_range = 1
	cooldown = 0
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1
	werewolf_only = 1
	restricted_area_check = 2

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner

		if (!M || !target || !ismob(target))
			return 1

		if (M == target)
			boutput(M, __red("Why would you want to maul yourself?"))
			return 1

		if (get_dist(M, target) > src.max_range)
			boutput(M, __red("[target] is too far away."))
			return 1

		if (!ishuman(target)) // Critter mobs include robots and combat drones. There's not a lot of meat on them.
			boutput(M, __red("[target] probably wouldn't taste very good."))
			return 1

		if (target.canmove)
			boutput(M, __red("[target] is moving around too much."))
			return 1

		logTheThing("combat", M, target, "starts to maul %target% at [log_loc(M)].")
		actions.start(new/datum/action/bar/private/icon/werewolf_feast(target, src), M)
		return 0

/datum/action/bar/private/icon/werewolf_feast
	duration = 300
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "werewolf_feast"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "devour_over"
	var/mob/living/target
	var/datum/targetable/werewolf/werewolf_feast/feast
	var/last_complete = 0
	var/do_we_get_points = 0 // For the specialist objective. Did we feed on the target long enough?

	New(Target, Feast)
		target = Target
		feast = Feast
		..()

	onStart()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/A = feast.holder

		if (!feast || get_dist(M, target) > feast.max_range || target == null || M == null || !ishuman(target) || !ishuman(M) || !A || !istype(A))
			interrupt(INTERRUPT_ALWAYS)
			return

		// It's okay when the victim expired half-way through the feast, but plain corpses are too cheap.
		if (isdead(target))
			boutput(M, __red("Urgh, this cadaver tasted horrible. Better find some fresh meat."))
			target.visible_message("<span class='alert'><B>[M] completely rips [target]'s corpse to pieces!</B></span>")
			target.gib()
			interrupt(INTERRUPT_ALWAYS)
			return

		A.locked = 1
		playsound(M.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
		M.visible_message("<span class='alert'><B>[M] lunges at [target]!</b></span>")

	onUpdate()
		..()

		var/mob/living/M = owner
		var/datum/abilityHolder/A = feast.holder

		if (!feast || get_dist(M, target) > feast.max_range || target == null || M == null || !ishuman(target) || !ishuman(M) || !A || !istype(A))
			interrupt(INTERRUPT_ALWAYS)
			return

		var/done = world.time - started
		var/complete = max(min((done / duration), 1), 0)

		if (complete >= 0.1 && last_complete < 0.1)
			if (M.werewolf_attack(target, "feast") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return

		if (complete >= 0.2 && last_complete < 0.2)
			if (M.werewolf_attack(target, "feast") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return

		if (complete >= 0.3 && last_complete < 0.3)
			if (M.werewolf_attack(target, "feast") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return

		if (complete >= 0.4 && last_complete < 0.4)
			if (M.werewolf_attack(target, "feast") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return

		if (complete >= 0.5 && last_complete < 0.5)
			if (M.werewolf_attack(target, "feast") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return

		if (complete >= 0.6 && last_complete < 0.6)
			if (M.werewolf_attack(target, "feast") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return

		if (complete >= 0.7 && last_complete < 0.7)
			if (M.werewolf_attack(target, "feast") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return

			if (!isdead(target) && !(isnpcmonkey(target))) // Can't farm npc monkeys.
				src.do_we_get_points = 1

		if (complete >= 0.8 && last_complete < 0.8)
			if (M.werewolf_attack(target, "feast") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return

			if (!isdead(target) && !(isnpcmonkey(target)))
				src.do_we_get_points = 1

		if (complete >= 0.9 && last_complete < 0.9)
			if (M.werewolf_attack(target, "feast") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return

			if (!isdead(target) && !(isnpcmonkey(target)))
				src.do_we_get_points = 1

		last_complete = complete

	onEnd()
		..()

		var/datum/abilityHolder/A = feast.holder
		var/mob/living/M = owner
		var/mob/living/carbon/human/HH = target

		// AH parent var for AH.locked vs. specific one for the feed objective.
		// Critter mobs only use one specific type of abilityHolder for instance.
		if (istype(A, /datum/abilityHolder/werewolf))
			var/datum/abilityHolder/werewolf/W = A
			if (W.feed_objective && istype(W.feed_objective, /datum/objective/specialist/werewolf/feed/))
				if (src.do_we_get_points == 1)
					if (istype(HH) && HH.bioHolder)
						if (!W.feed_objective.mobs_fed_on.Find(HH.bioHolder.Uid))
							W.feed_objective.mobs_fed_on.Add(HH.bioHolder.Uid)
							W.feed_objective.feed_count++
							boutput(M, __blue("You finish chewing on [HH], but what a feast it was!"))
						else
							boutput(M, __red("You've mauled [HH] before and didn't like the aftertaste. Better find a different prey."))
					else
						boutput(M, __red("What a meagre meal. You're still hungry..."))
				else
					boutput(M, __red("What a meagre meal. You're still hungry..."))
			else
				boutput(M, __red("You finish chewing on [HH]."))
		else
			boutput(M, __red("You finish chewing on [HH]."))

		if (A && istype(A))
			A.locked = 0

	onInterrupt()
		..()

		var/datum/abilityHolder/A = feast.holder
		var/mob/living/M = owner
		var/mob/living/carbon/human/HH = target

		if (istype(A, /datum/abilityHolder/werewolf))
			var/datum/abilityHolder/werewolf/W = A
			if (W.feed_objective && istype(W.feed_objective, /datum/objective/specialist/werewolf/feed/))
				if (src.do_we_get_points == 1)
					if (istype(HH) && HH.bioHolder)
						if (!W.feed_objective.mobs_fed_on.Find(HH.bioHolder.Uid))
							W.feed_objective.mobs_fed_on.Add(HH.bioHolder.Uid)
							W.feed_objective.feed_count++
							boutput(M, __blue("Your feast was interrupted, but it satisfied your hunger for the time being."))
						else
							boutput(M, __red("You've mauled [HH] before and didn't like the aftertaste. Better find a different prey."))
					else
						boutput(M, __red("Your feast was interrupted and you're still hungry..."))
				else
					boutput(M, __red("Your feast was interrupted and you're still hungry..."))
			else
				boutput(M, __red("Your feast was interrupted."))
		else
			boutput(M, __red("Your feast was interrupted."))

		if (A && istype(A))
			A.locked = 0
