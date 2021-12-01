/datum/targetable/werewolf/werewolf_spread_affliction
	name = "Spread affliction"
	desc = "Removes the affliction from you and passes it to another space man."
	targeted = 1
	target_nodamage_check = 1
	max_range = 1
	cooldown = 2000
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
			boutput(M, __red("How could you afflict yourself with your own affliction?"))
			return 1
		if (get_dist(M, target) > src.max_range)
			boutput(M, __red("[target] is too far away."))
			return 1
		if (!ishuman(target)) // Critter mobs include robots and combat drones. There's not a lot of meat on them.
			boutput(M, __red("[target] probably wouldn't make a very good werewolf."))
			return 1
		if (target.stat == 2) //can't pass affliction on to the dead
			boutput(M, __red("A dead [target] probably wouldn't make a very good werewolf."))
			return 1
		if (target.canmove)
			boutput(M, __red("[target] is moving around too much."))
			return 1
		logTheThing("combat", M, target, "starts to afflict [constructTarget(target,"combat")] at [log_loc(M)].")
		actions.start(new/datum/action/bar/private/icon/werewolf_spread_affliction(target, src), M)
		return 0
/datum/action/bar/private/icon/werewolf_spread_affliction
	duration = 100
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "werewolf_spread_affliction"
	icon = 'icons/mob/critter_ui.dmi'
	icon_state = "werewolf_spread_affliction"
	var/mob/living/target
	var/datum/targetable/werewolf/werewolf_spread_affliction/spread
	var/last_complete = 0
	New(Target, Spread)
		target = Target
		spread = Spread
		..()
	onStart()
		..()
		var/mob/living/M = owner
		var/datum/abilityHolder/A = spread.holder
		if (!spread || get_dist(M, target) > spread.max_range || target == null || M == null || !ishuman(target) || !ishuman(M) || !A || !istype(A))
			interrupt(INTERRUPT_ALWAYS)
			return
		// It's okay when the victim expired half-way through the spread, we're interrupted, find a new "victim"
		if (target.stat == 2)
			interrupt(INTERRUPT_ALWAYS)
			return
		A.locked = 1
		playsound(M.loc, pick('sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
		M.visible_message("<span class='alert'><B>[M] lunges at [target]!</b></span>")
	onUpdate()
		..()
		var/mob/living/M = owner
		var/datum/abilityHolder/A = spread.holder
		if (!spread || get_dist(M, target) > spread.max_range || target == null || M == null || !ishuman(target) || !ishuman(M) || !A || !istype(A))
			interrupt(INTERRUPT_ALWAYS)
			return
		var/done = TIME - started
		var/complete = max(min((done / duration), 1), 0)
		if (complete >= 0.1 && last_complete < 0.1)
			if (M.werewolf_attack(target, "spread") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return
		if (complete >= 0.3 && last_complete < 0.3)
			if (M.werewolf_attack(target, "spread") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return
		if (complete >= 0.5 && last_complete < 0.5)
			if (M.werewolf_attack(target, "spread") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return
		if (complete >= 0.7 && last_complete < 0.7)
			if (M.werewolf_attack(target, "spread") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return
		if (complete >= 0.8 && last_complete < 0.8)
			if (M.werewolf_attack(target, "spread") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return
		if (complete >= 0.9 && last_complete < 0.9)
			if (M.werewolf_attack(target, "spread") != 1)
				boutput(M, __red("[target] is moving around too much."))
				interrupt(INTERRUPT_ALWAYS)
				return
		last_complete = complete
	onEnd()
		..()
		var/datum/abilityHolder/A = spread.holder
		var/mob/living/M = owner
		var/mob/living/carbon/human/HH = target
		// AH parent var for AH.locked vs. specific one for the feed objective.
		// Critter mobs only use one specific type of abilityHolder for instance.
		if (istype(A, /datum/abilityHolder/werewolf))
			var/datum/abilityHolder/werewolf/W = A
			if (iswizard(HH))
				boutput(M, __red("[HH]'s magic stops the affliction from taking hold!"))
			else if (isvampire(HH))
				boutput(M, __red("[HH] doesn't seem to be affected by the bite much at all!"))
			else if (ischangeling(HH))
				boutput(M, __red("Your teeth seem to sink into [HH]'s skin but can't grab purchase. You don't think it's worth it trying to infect them!"))
			else if (isabomination(HH))
				boutput(M, __red("This abomination doesn't seem to be able to take any werewolf DNA into its collective!"))
			else if (iswrestler(HH))
				boutput(M, __red("A Werewolf Wrestler?! As if anyone can imagine something so ridiculous!"))
			else if (ishuman(HH))
				if (isturf(M.loc) && isturf(HH.loc))
					if (!HH.disease_resistance_check("/datum/ailment/disease/lycanthropy","Lycanthropy"))
						HH.make_werewolf(1)
						HH.full_heal()
						HH.setStatus("weakened", 15 SECONDS)
						HH.werewolf_transform() // Not really a fan of this. I wish werewolves all suffered from lycanthropy and that should be how you pass it on, but w/e
						remove_antag(M, null, 0, 1)
						boutput(W, __red("You passed your terribly affliction onto [HH]! You are no longer a werewolf!"))
						logTheThing("combat", M, target, "turns [constructTarget(target,"combat")] into a werewolf at [log_loc(M)].")
		if (A && istype(A))
			A.locked = 0
	onInterrupt()
		..()
		var/datum/abilityHolder/A = spread.holder
		boutput(owner, __red("Your spread was interrupted."))
		if (A && istype(A))
			A.locked = 0
