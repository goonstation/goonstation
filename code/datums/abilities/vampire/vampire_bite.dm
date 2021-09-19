/datum/abilityHolder/vampire/var/list/blood_tally
/datum/abilityHolder/vampire/var/const/max_take_per_mob = 250

/datum/abilityHolder/vampire/proc/tally_bite(var/mob/living/carbon/human/target, var/blood_amt_taken)
	if (!src.blood_tally)
		src.blood_tally = list()

	if (!(target in src.blood_tally))
		src.blood_tally[target] = 0

	src.blood_tally[target] += blood_amt_taken

/datum/abilityHolder/vampire/proc/can_take_blood_from(var/mob/living/carbon/human/target)
	.= 1
	if (src.blood_tally)
		if (target in src.blood_tally)
			.= src.blood_tally[target] < max_take_per_mob


/datum/abilityHolder/vampire/proc/can_bite(var/mob/living/carbon/human/target, is_pointblank = 1)
	var/datum/abilityHolder/vampire/holder = src
	var/mob/living/M = holder.owner
	var/datum/abilityHolder/vampire/H = holder

	if (!M || !target)
		return 0

	if (!ishuman(target)) // Only humans use the blood system.
		boutput(M, __red("You can't seem to find any blood vessels."))
		return 0
	else
		var/mob/living/carbon/human/humantarget = target
		if (istype(humantarget.mutantrace, /datum/mutantrace/vampiric_thrall))
			boutput(M, __red("You cannot drink the blood of a thrall."))
			return 0

	if (M == target)
		boutput(M, __red("Why would you want to bite yourself?"))
		return 0

	if (ismobcritter(M) && !istype(H))
		boutput(M, __red("Critter mobs currently don't have to worry about blood. Lucky you."))
		return 0

	if (istype(H) && H.vamp_isbiting)
		if (vamp_isbiting != target)
			boutput(M, __red("You are already draining someone's blood!"))
			return 0

	if (is_pointblank && target.head && target.head.c_flags & (BLOCKCHOKE))
		boutput(M, __red("You need to remove their headgear first."))
		return 0

	if (check_target_immunity(target) == 1)
		target.visible_message("<span class='alert'><B>[M] bites [target], but fails to even pierce their skin!</B></span>")
		return 0

	if ((target.mind && target.mind.special_role == ROLE_VAMPTHRALL) && target.is_mentally_dominated_by(M))
		boutput(M, __red("You can't drink the blood of your own thralls!"))
		return 0

	if (isnpcmonkey(target))
		boutput(M, __red("Drink monkey blood?! That's disgusting!"))
		return 0

	if (!holder.can_take_blood_from(target))
		return 0

	return 1

/datum/abilityHolder/vampire/proc/do_bite(var/mob/living/carbon/human/HH, var/mult = 1, var/thrall = 0)
	.= 1
	var/mob/living/carbon/human/M = src.owner
	var/datum/abilityHolder/vampire/H = src


	if (HH.blood_volume <= 0)
		boutput(M, __red("This human is completely void of blood... Wow!"))
		return 0

	if (isdead(HH))
		if (prob(20))
			boutput(M, __red("The blood of the dead provides little sustenance..."))

		var/bitesize = 5 * mult
		M.change_vampire_blood(bitesize, 1)
		M.change_vampire_blood(bitesize, 0)
		H.tally_bite(HH,bitesize)
		if (HH.blood_volume < 20 * mult)
			HH.blood_volume = 0
		else
			HH.blood_volume -= 20 * mult
		if (istype(H)) H.blood_tracking_output()

	else if (HH.bioHolder && HH.traitHolder.hasTrait("training_chaplain"))
		M.visible_message("<span class='alert'><b>[M]</b> begins to crisp and burn!</span>", "<span class='alert'>You drank the blood of a holy man! It burns!</span>")
		M.emote("scream")
		if (M.get_vampire_blood() >= 20 * mult)
			M.change_vampire_blood(-20 * mult, 0)
		else
			M.change_vampire_blood(0, 0, 1)
		M.TakeDamage("chest", 0, 30 * mult)

	else
		if (isvampire(HH))
			var/bitesize = 20 * mult
			if (HH.get_vampire_blood() >= bitesize)
				HH.change_vampire_blood(-bitesize, 0)
				HH.change_vampire_blood(-bitesize, 1) // Otherwise, two vampires could perpetually feed off of each other, trading blood endlessly.

				M.change_vampire_blood(bitesize, 0)
				M.change_vampire_blood(bitesize, 1)
				H.tally_bite(HH,bitesize)
				if (istype(H))
					H.blood_tracking_output()
				if (prob(50))
					boutput(M, __red("This is the blood of a fellow vampire!"))
			else
				HH.change_vampire_blood(0, 0, 1)
				boutput(M, __red("[HH] doesn't have enough blood left to drink."))
				return 0
		else
			var/bitesize = 10 * mult
			M.change_vampire_blood(bitesize, 1)
			M.change_vampire_blood(bitesize, 0)
			H.tally_bite(HH,bitesize)
			if (HH.blood_volume < 20 * mult)
				HH.blood_volume = 0
			else
				HH.blood_volume -= 20 * mult
			//vampires heal, thralls don't
			if (!thrall)
				M.HealDamage("All", 3, 3)
				M.take_toxin_damage(-1)
				M.take_oxygen_deprivation(-1)

				if (mult >= 1) //mult is only 1 or greater during a pointblank true suck
					if (HH.blood_volume < 300 && prob(15))
						if (!HH.getStatusDuration("paralysis"))
							boutput(HH, __red("Your vision fades to blackness."))
						HH.changeStatus("paralysis", 10 SECONDS)
					else
						if (prob(65))
							HH.changeStatus("weakened", 1 SECOND)
							HH.stuttering = min(HH.stuttering + 3, 10)

			if (istype(H)) H.blood_tracking_output()

	if (!can_take_blood_from(HH) && (mult >= 1) && (isunconscious(HH) || HH.health <= 90))
		HH.death(0)

	if (istype(H))
		H.check_for_unlocks()

	eat_twitch(src.owner)
	playsound(src.owner.loc,"sound/items/drink.ogg", rand(10,50), 1, pitch = 1.4)
	HH.was_harmed(M, special = "vamp")

/datum/abilityHolder/vampiric_thrall/var/list/blood_tally
/datum/abilityHolder/vampiric_thrall/var/const/max_take_per_mob = 250

/datum/abilityHolder/vampiric_thrall/proc/can_take_blood_from(var/mob/living/carbon/human/target)
	.= 1
	if (src.blood_tally)
		if (target in src.blood_tally)
			.= src.blood_tally[target] < max_take_per_mob

/datum/abilityHolder/vampiric_thrall/proc/tally_bite(var/mob/living/carbon/human/target, var/blood_amt_taken)
	if (!src.blood_tally)
		src.blood_tally = list()

	if (!(target in src.blood_tally))
		src.blood_tally[target] = 0

	src.blood_tally[target] += blood_amt_taken

/datum/abilityHolder/vampiric_thrall/proc/can_bite(var/mob/living/carbon/human/target, is_pointblank = 1)
	var/datum/abilityHolder/vampiric_thrall/holder = src
	var/mob/living/M = holder.owner
	var/datum/abilityHolder/vampiric_thrall/H = holder

	if (!M || !target)
		return 0

	if (!ishuman(target)) // Only humans use the blood system.
		boutput(M, __red("You can't seem to find any blood vessels."))
		return 0
	else
		var/mob/living/carbon/human/humantarget = target
		if (istype(humantarget.mutantrace, /datum/mutantrace/vampiric_thrall))
			boutput(M, __red("You cannot drink the blood of a thrall."))
			return 0

	if (M == target)
		boutput(M, __red("Why would you want to bite yourself?"))
		return 0

	if (ismobcritter(M) && !istype(H))
		boutput(M, __red("Critter mobs currently don't have to worry about blood. Lucky you."))
		return 0

	if (istype(H) && H.vamp_isbiting)
		if (vamp_isbiting != target)
			boutput(M, __red("You are already draining someone's blood!"))
			return 0

	if (is_pointblank && target.head && target.head.c_flags & (BLOCKCHOKE))
		boutput(M, __red("You need to remove their headgear first."))
		return 0

	if (check_target_immunity(target) == 1)
		target.visible_message("<span class='alert'><B>[M] bites [target], but fails to even pierce their skin!</B></span>")
		return 0

	var/mob/master = null
	if(src.owner.mind && src.owner.mind.master)
		master = whois_ckey_to_mob_reference(src.owner.mind.master)
	if ((target.mind && target.mind.special_role == ROLE_VAMPTHRALL) && target.is_mentally_dominated_by(master))
		boutput(M, __red("You can't drink the blood of your master's thralls!"))
		return 0

	if (isnpcmonkey(target))
		boutput(M, __red("Drink monkey blood?! That's disgusting!"))
		return 0

	if (!holder.can_take_blood_from(target))
		return 0


	return 1

/datum/abilityHolder/vampiric_thrall/proc/do_bite(var/mob/living/carbon/human/HH, var/mult = 1, var/thrall = 0)
	.= 1
	var/mob/living/carbon/human/M = src.owner
	var/datum/abilityHolder/vampiric_thrall/H = src


	if (HH.blood_volume <= 0)
		boutput(M, __red("This human is completely void of blood... Wow!"))
		return 0

	if (isdead(HH))
		if (prob(20))
			boutput(M, __red("The blood of the dead provides little sustenance..."))

		var/bitesize = 5 * mult
		M.change_vampire_blood(bitesize, 1)
		M.change_vampire_blood(bitesize, 0)
		H.tally_bite(HH,bitesize)
		if (HH.blood_volume < 20 * mult)
			HH.blood_volume = 0
		else
			HH.blood_volume -= 20 * mult

	else if (HH.bioHolder && HH.traitHolder.hasTrait("training_chaplain"))
		M.visible_message("<span class='alert'><b>[M]</b> begins to crisp and burn!</span>", "<span class='alert'>You drank the blood of a holy man! It burns!</span>")
		M.emote("scream")
		if (M.get_vampire_blood() >= 20 * mult)
			M.change_vampire_blood(-20 * mult, 0)
		else
			M.change_vampire_blood(0, 0, 1)
		M.TakeDamage("chest", 0, 30 * mult)

	else
		if (isvampire(HH))
			var/bitesize = 20 * mult
			if (HH.get_vampire_blood() >= bitesize)
				HH.change_vampire_blood(-bitesize, 0)
				HH.change_vampire_blood(-bitesize, 1) // Otherwise, two vampires could perpetually feed off of each other, trading blood endlessly.

				M.change_vampire_blood(bitesize, 0)
				M.change_vampire_blood(bitesize, 1)
				H.tally_bite(HH,bitesize)
				if (prob(50))
					boutput(M, __red("This is the blood of a fellow vampire!"))
			else
				HH.change_vampire_blood(0, 0, 1)
				boutput(M, __red("[HH] doesn't have enough blood left to drink."))
				return 0
		else
			var/bitesize = 10 * mult
			M.change_vampire_blood(bitesize, 1)
			M.change_vampire_blood(bitesize, 0)
			H.tally_bite(HH,bitesize)
			if (HH.blood_volume < 20 * mult)
				HH.blood_volume = 0
			else
				HH.blood_volume -= 20 * mult
			//vampires heal, thralls don't
			if (!thrall)
				M.HealDamage("All", 3, 3)
				M.take_toxin_damage(-1)
				M.take_oxygen_deprivation(-1)

				if (mult >= 1) //mult is only 1 or greater during a pointblank true suck
					if (HH.blood_volume < 300 && prob(15))
						if (!HH.getStatusDuration("paralysis"))
							boutput(HH, __red("Your vision fades to blackness."))
						HH.changeStatus("paralysis", 10 SECONDS)
					else
						if (prob(65))
							HH.changeStatus("weakened", 1 SECOND)
							HH.stuttering = min(HH.stuttering + 3, 10)

	if (!can_take_blood_from(HH) && (mult >= 1) && (isunconscious(HH) || HH.health <= 90))
		HH.death(0)

	eat_twitch(src.owner)
	playsound(src.owner.loc,"sound/items/drink.ogg", rand(10,50), 1, pitch = 1.4)
	HH.was_harmed(M, special = "vamp")

/datum/targetable/vampire/blood_steal
	name = "Blood Steal"
	desc = "Steal blood from a victim at range. This ability will continue to channel until you move."
	icon_state = "bloodsteal"
	targeted = 1
	target_nodamage_check = 1
	max_range = 999
	cooldown = 45 SECONDS
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	sticky = 1
	unlock_message = "You have gained Hide Coffin. It allows you to hide a coffin somewhere on the station."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/V = holder

		if (actions.hasAction(M, "vamp_blood_suck"))
			boutput(M, __red("You are already performing a Bite action and cannot start a Blood Steal."))
			return 1

		actions.start(new/datum/action/bar/private/icon/vamp_ranged_blood_suc(M,V,target, src), M)

		return 0

/datum/action/bar/private/icon/vamp_ranged_blood_suc
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	id = "vamp_blood_suck_ranged"
	icon = 'icons/ui/actions.dmi'
	icon_state = "blood"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border-vampire"
	color_active = "#d73715"
	color_success = "#f21b1b"
	color_failure = "#8d1422"
	var/mob/living/carbon/human/M
	var/datum/abilityHolder/vampire/H
	var/mob/living/carbon/human/HH
	var/datum/targetable/vampire/blood_steal/ability

	New(user,vampabilityholder,target,biteabil)
		M = user
		H = vampabilityholder
		HH = target
		ability = biteabil
		..()

	onUpdate()
		..()
		if(get_dist(M, HH) > 7 || M == null || HH == null || HH.blood_volume <= 0)
			interrupt(INTERRUPT_ALWAYS)
			return


	onStart()
		..()
		if(M == null || HH == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!H.can_bite(HH, is_pointblank = 0))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (get_dist(M, HH) > 7)
			boutput(M, __red("That target is too far away!"))
			return

		if (istype(H))
			H.vamp_isbiting = HH
		HH.vamp_beingbitten = 1

		src.loopStart()

	loopStart()
		..()
		var/obj/projectile/proj = initialize_projectile_ST(HH, new/datum/projectile/special/homing/vamp_blood, M)
		var/tries = 10
		while (tries > 0 && (!proj || proj.disposed))
			proj = initialize_projectile_ST(HH, new/datum/projectile/special/homing/vamp_blood, M)
			tries--

		proj.special_data["vamp"] = H
		proj.special_data["victim"] = HH
		proj.targets = list(M)

		proj.launch()

		if (prob(25))
			boutput(HH, __red("Some blood is forced right out of your body!"))

		logTheThing("combat", M, HH, "steals blood from [constructTarget(HH,"combat")] at [log_loc(M)].")

	onEnd()
		if(get_dist(M, HH) > 7 || M == null || HH == null)
			..()
			interrupt(INTERRUPT_ALWAYS)
			src.end()
			return

		src.onRestart()

	onInterrupt() //Called when the action fails / is interrupted.
		if (state == ACTIONSTATE_RUNNING)
			if (HH.blood_volume <= 0)
				boutput(M, __red("[HH] doesn't have enough blood left to drink."))
			else if (!H.can_take_blood_from(H, HH))
				boutput(M, __red("You have drank your fill [HH]'s blood. It tastes all bland and gross now."))
			else
				boutput(M, __red("Your feast was interrupted."))

		if (ability)
			ability.doCooldown()
		src.end()

		..()

	proc/end()
		if (istype(H))
			H.vamp_isbiting = null
		if (HH)
			HH.vamp_beingbitten = 0 // Victim might have been gibbed, who knowns.



/datum/targetable/vampire/vampire_bite
	name = "Bite Victim"
	desc = "Bite the victim's neck to drain them of blood."
	icon_state = "bite"
	targeted = 1
	target_nodamage_check = 1
	max_range = 1
	cooldown = 0
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1
	dont_lock_holder = 1
	restricted_area_check = 2
	var/thrall = 0

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/H = holder

		if (!M || !target || !ismob(target))
			return 1

		if (get_dist(M, target) > src.max_range)
			boutput(M, __red("[target] is too far away."))
			return 1

		if (actions.hasAction(M, "vamp_blood_suck_ranged"))
			boutput(M, __red("You are already performing a Blood action and cannot start a Bite."))
			return 1

		var/mob/living/carbon/human/HH = target


		boutput(M, __blue("You bite [HH] and begin to drain them of blood."))
		HH.visible_message("<span class='alert'><B>[M] bites [HH]!</B></span>")

		actions.start(new/datum/action/bar/icon/vamp_blood_suc(M,H,HH,src), M)

		return 0

/datum/targetable/vampire/vampire_bite/thrall
	thrall = 1


/datum/action/bar/icon/vamp_blood_suc
	duration = 30
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "vamp_blood_suck"
	icon = 'icons/ui/actions.dmi'
	icon_state = "blood"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border-vampire"
	color_active = "#d73715"
	color_success = "#f21b1b"
	color_failure = "#8d1422"
	var/mob/living/carbon/human/M
	var/datum/abilityHolder/vampire/H
	var/mob/living/carbon/human/HH
	var/datum/targetable/vampire/vampire_bite/B

	New(user,vampabilityholder,target,biteabil)
		M = user
		H = vampabilityholder
		HH = target
		B = biteabil
		..()
		if (B.thrall)
			duration = 60


	onUpdate()
		..()
		if(get_dist(M, HH) > 1 || M == null || HH == null || B == null)
			interrupt(INTERRUPT_ALWAYS)
			return


	onStart()
		..()
		if(get_dist(M, HH) > 1 || M == null || HH == null || B == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (!H.can_bite(HH, is_pointblank = 1))
			interrupt(INTERRUPT_ALWAYS)
			return

		if (istype(H))
			H.vamp_isbiting = HH
		HH.vamp_beingbitten = 1

		src.loopStart()

	loopStart()
		..()
		logTheThing("combat", M, HH, "bites [constructTarget(HH,"combat")]'s neck at [log_loc(M)].")
		return

	onEnd()
		if(get_dist(M, HH) > 1 || M == null || HH == null || B == null)
			..()
			interrupt(INTERRUPT_ALWAYS)
			src.end()
			return

		if (!H.do_bite(HH,mult = 1.5, thrall = B.thrall))
			..()
			interrupt(INTERRUPT_ALWAYS)
			src.end()
			return

		src.onRestart()

	onInterrupt() //Called when the action fails / is interrupted.
		if (state == ACTIONSTATE_RUNNING)
			if (HH.blood_volume < 0)
				boutput(M, __red("[HH] doesn't have enough blood left to drink."))
			else if (!H.can_take_blood_from(H, HH))
				boutput(M, __red("You have drank your fill [HH]'s blood. It tastes all bland and gross now."))
			else
				boutput(M, __red("Your feast was interrupted."))

		src.end()

		..()

	proc/end()
		if (istype(H))
			H.vamp_isbiting = null
		if (HH)
			HH.vamp_beingbitten = 0 // Victim might have been gibbed, who knowns.
