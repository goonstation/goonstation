// Converted everything related to werewolves from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

// Added kyle2143's werewolf patch (Gannets).

////////////////////////////////////////////// Helper procs //////////////////////////////

// Avoids C&P code for that werewolf disease.
/mob/proc/werewolf_transform()
	if (ishuman(src))
		var/mob/living/carbon/human/M = src
		var/which_way = 0

		// not a werewolf? Go become one!
		if (!istype(M.mutantrace, /datum/mutantrace/werewolf))
			/// Werewolf is typically a "temporary" MR, as few people start the round as a wolf. Or TF into a wolf while being a wolf
			if(istype(M.coreMR, /datum/mutantrace/werewolf)) // so if this somehow happens, uh. human?
				M.coreMR = null
			M.coreMR = M.mutantrace
			M.jitteriness = 0
			M.delStatus("stunned")
			M.delStatus("weakened")
			M.delStatus("paralysis")
			M.delStatus("slowed")
			M.delStatus("disorient")
			M.delStatus("radiation")
			M.take_radiation_dose(-INFINITY)
			M.delStatus("burning")
			M.delStatus("staggered")
			M.change_misstep_chance(-INFINITY)
			M.stuttering = 0
			M.delStatus("drowsy")

			//wolfing removes all the implants in you
			for(var/obj/item/implant/I in M)
				boutput(M, "<span class='alert'>\an [I] falls out of your abdomen.</span>")
				I.on_remove(M)
				M.implant.Remove(I)
				I.set_loc(M.loc)
				continue

			M.set_mutantrace(/datum/mutantrace/werewolf)

			playsound(M.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 50, 1, -1)
			SPAWN(0.5 SECONDS)
				if (M?.mutantrace && istype(M.mutantrace, /datum/mutantrace/werewolf))
					M.emote("howl")

			M.visible_message("<span class='alert'><B>[M] [pick("metamorphizes", "transforms", "changes")] into a werewolf! Holy shit!</B></span>")
			if (M.find_ailment_by_type(/datum/ailment/disease/lycanthropy))
				boutput(M, "<span class='alert'><h2>You've been turned into a werewolf!</h2> Your transformation was achieved by in-game means, you are <i>not</i> an antagonist unless you already were one.</span>")
			else
				boutput(M, "<span class='notice'><h3>You are now a werewolf. You can remain in this form indefinitely or change back at any time.</span></h3>")

			if (M.hasStatus("handcuffed"))
				if (M.handcuffs.werewolf_cant_rip())
					boutput(M, "<span class='alert'>You can't seem to break free from these silver handcuffs.</span>")
				else
					M.visible_message("<span class='alert'><B>[M] rips apart the [M.handcuffs] with pure brute strength!</b></span>")
					M.handcuffs.destroy_handcuffs(M)

			which_way = 0

		// iswolf?
		else
			boutput(M, "<span class='notice'><h3>You transform back into your original form.</span></h3>")

			M.set_mutantrace(M.coreMR) // return to monke/bove/herpe/etc

			//Changing back removes all the implants in you, wolves should have a non-surgery way to remove bullets. considering silver is so harmful
			for(var/obj/item/implant/I in M)
				boutput(M, "<span class='alert'>\an [I] falls out of your abdomen.</span>")
				I.on_remove(M)
				M.implant.Remove(I)
				I.set_loc(M.loc)
				continue

			which_way = 1

		logTheThing(LOG_COMBAT, M, "[which_way == 0 ? "transforms into a werewolf" : "changes back into human form"] at [log_loc(M)].")
		return

// There used to be more stuff here, most of which was moved to limb datums.
/mob/proc/werewolf_attack(var/mob/target = null, var/attack_type = "")
	if (!iswerewolf(src))
		return 0

	var/mob/living/carbon/human/M = src
	if (!ishuman(M))
		return 0

	if (!target || !ismob(target))
		return 0

	if (target == M)
		return 0

	if (check_target_immunity(target) == 1)
		target.visible_message("<span class='alert'><B>[M]'s swipe bounces off of [target] uselessly!</B></span>")
		return 0
	M.werewolf_tainted_saliva_transfer(target)

	var/damage = 0
	var/send_flying = 0 // 1: a little bit | 2: across the room

	switch (attack_type)
		if ("feast") // Only used by the feast ability.
			var/mob/living/carbon/human/HH = target

			if (!HH || !ishuman(HH))
				return 0

			var/healing = 0

			damage += rand(5,15)
			healing = damage - 5

			if (prob(40))
				HH.spread_blood_clothes(HH)
				M.spread_blood_hands(HH)

				var/obj/decal/cleanable/blood/gibs/G = null // For forensics.
				G = make_cleanable(/obj/decal/cleanable/blood/gibs,HH.loc)
				if (HH.bioHolder && HH.bioHolder.Uid && HH.bioHolder.bloodType)
					G.blood_DNA = HH.bioHolder.Uid
					G.blood_type = HH.bioHolder.bloodType

				M.visible_message("<span class='alert'><B>[M] messily [pick("rips", "tears")] out and [pick("eats", "devours", "wolfs down", "chows on")] some of [HH]'s [pick("guts", "intestines", "entrails")]!</B></span>")

			else
				HH.spread_blood_clothes(HH)

				M.visible_message("<span class='alert'><B>[M] [pick("chomps on", "chews off a chunk of", "gnaws on")] [HH]'s [pick("right arm", "left arm", "head", "right leg", "left leg")]!</B></span>")

			if (isnpcmonkey(HH))
				boutput(M, "<span class='alert'>Monkey flesh just isn't the real deal...</span>")
				healing /= 2
			else if (isdead(HH))
				boutput(M, "<span class='alert'>Fresh meat would be much preferable to this cadaver...</span>")
				healing /= 2
			else if (HH.health < -150)
				boutput(M, "<span class='alert'>[target] is pretty mangled. There's not a lot of flesh left...</span>")
				healing /= 1.5
			else
				if (iscluwne(HH))
					boutput(M, "<span class='alert'>That tasted awful!</span>")
					healing /= 2
					M.take_toxin_damage(5)
				else if (iswerewolf(HH) || ishunter(HH) || isabomination(HH))
					boutput(M, "<span class='notice'>That tasted fantastic!</span>")
					healing *= 2
				else if (HH.nutrition > 100)
					boutput(M, "<span class='notice'>That tasted amazing!</span>")
					M.unlock_medal("Space Ham", 1)
					healing *= 2
				else if (HH.mind && HH.mind.assigned_role == "Clown")
					boutput(M, "<span class='notice'>That tasted funny, huh.</span>")
					M.unlock_medal("That tasted funny", 1)
				else
					boutput(M, "<span class='notice'>That tasted good!</span>")
					M.unlock_medal("Space Ham", 1) //new way to acquire

			HH.add_fingerprint(M) // Just put 'em on the mob itself, like pulling does. Simplifies forensic analysis a bit.
			M.werewolf_audio_effects(HH, "feast")

			if (prob(60) && ishuman(target))
				var/mob/living/carbon/human/H = target
				//These are the non-essential organs. no brain, skull heart. I guess liver is kinda essential, but idk.
				var/list/choosable_organs = list("left_lung", "right_lung", "butt", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "pancreas", "appendix", "tail")
				var/obj/item/organ/organ = null
				var/count = 0
				//Do this search 5 times or until you find an organ.
				while (!organ && count <= 5)
					count++
					var/organ_name = pick(choosable_organs)
					organ = H.organHolder.get_organ(organ_name)

				if (organ)
					H.organHolder.drop_and_throw_organ(organ, src.loc, get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5)), rand(1,4), 1, 0)

			HH.changeStatus("weakened", 2 SECONDS)
			if (prob(33) && !isdead(HH))
				HH.emote("scream")

			M.remove_stamina(60) // Werewolves have a very large stamina and stamina regen boost.
			if (healing > 0)
				M.HealDamage("All", healing, healing)
				M.add_stamina(healing)

		if ("spread")
			var/mob/living/carbon/human/HH = target
			if (!HH || !ishuman(HH))
				return 0
			if (!HH.canmove)
				damage += rand(5,15)
				if (prob(40))
					HH.spread_blood_clothes(HH)
					M.spread_blood_hands(HH)
					var/obj/decal/cleanable/blood/gibs/G = null // For forensics.
					G = make_cleanable(/obj/decal/cleanable/blood/gibs, HH.loc)
					if (HH.bioHolder && HH.bioHolder.Uid && HH.bioHolder.bloodType)
						G.blood_DNA = HH.bioHolder.Uid
						G.blood_type = HH.bioHolder.bloodType
					M.visible_message("<span class='alert'><B>[M] sinks its teeth into [target]! !</B></span>")
				HH.add_fingerprint(M) // Just put 'em on the mob itself, like pulling does. Simplifies forensic analysis a bit.
				M.werewolf_audio_effects(HH, "feast")
				HH.setStatus("weakened",rand(3 SECONDS, 6 SECONDS))
				if (prob(70) && HH.stat != 2)
					HH.emote("scream")
		if ("pounce")
			if(isobserver(target) || isintangible(target))
				return
			wrestler_knockdown(M, target, 1)
			M.visible_message("<span class='alert'><B>[M] barrels through the air, slashing [target]!</B></span>")
			damage += rand(2,8)
			playsound(M.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
			if (prob(33) && target.stat != 2)
				target.emote("scream")
		if ("thrash")
			if (prob(75))
				wrestler_knockdown(M, target, 1)
				damage += rand(2,8)
			else
				wrestler_backfist(M, target)
				damage += rand(5,15)

			if (prob(60)) playsound(M.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
			if (prob(75)) target.setStatus("weakened", 3 SECONDS)
			if (prob(33) && target.stat != 2)
				target.emote("scream")

		else
			return 0

	switch (send_flying)
		if (1)
			wrestler_knockdown(M, target)

		if (2)
			wrestler_backfist(M, target)

	if (damage > 0)
		random_brute_damage(target, damage,1)
		target.UpdateDamageIcon()
		target.set_clothing_icon_dirty()

	return 1

// Also called by limb datums.
/mob/proc/werewolf_audio_effects(var/mob/target = null, var/type = "disarm")
	if (!src || !ismob(src) || !target || !ismob(target))
		return

	switch (type)
		if ("disarm")
			playsound(src.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
			SPAWN(0.1 SECONDS)
				if (src) playsound(src.loc, "swing_hit", 50, 1)

		if ("swipe")
			if (prob(50))
				playsound(src.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
			else
				playsound(src.loc, pick('sound/impact_sounds/Flesh_Tear_1.ogg', 'sound/impact_sounds/Flesh_Tear_2.ogg'), 50, 1, -1)

			SPAWN(0.1 SECONDS)
				if (src) playsound(src.loc, 'sound/impact_sounds/Flesh_Tear_3.ogg', 40, 1, -1)

		if ("feast")
			if (prob(60))
				playsound(src.loc, pick('sound/impact_sounds/Flesh_Tear_1.ogg', 'sound/impact_sounds/Flesh_Tear_2.ogg'), 50, 1, -1)
				playsound(src.loc, 'sound/items/eatfood.ogg', 50, 1, -1)

			if (prob(40))
				playsound(target.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)

			if (prob(30))
				playsound(src.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)

			SPAWN(1 SECOND)
				if (src && ishuman(src) && prob(10))
					src.emote("burp")

	return

//////////////////////////////////////////// Ability holder /////////////////////////////////////////

/atom/movable/screen/ability/topBar/werewolf
	clicked(params)
		var/datum/targetable/werewolf/spell = owner
		if (!istype(spell))
			return
		if (!spell.holder)
			return
		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, "<span class='alert'>You can't use this ability here.</span>")
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			usr.targeting_ability = owner
			usr.update_cursor()
		else
			SPAWN(0)
				spell.handleCast()
		return

/datum/abilityHolder/werewolf
	usesPoints = 0
	regenRate = 0
	tabName = "Werewolf"
	notEnoughPointsMessage = "<span class='alert'>You aren't strong enough to use this ability.</span>"
	var/datum/objective/specialist/werewolf/feed/feed_objective = null
	var/datum/reagents/tainted_saliva_reservoir = null
	var/awaken_time //don't really need this here, but admins might want to know when the werewolf's awaken time is.

	New()
		..()
		awaken_time = rand(5, 10)*100
		src.tainted_saliva_reservoir = new/datum/reagents(500)

	onAbilityStat() // In the 'Werewolf' tab.
		..()
		.= list()
		if (src.owner && src.owner.mind && src.owner.mind.special_role == ROLE_WEREWOLF)
			for (var/datum/objective/specialist/werewolf/feed/O in src.owner.mind.objectives)
				src.feed_objective = O

			if (src.feed_objective && istype(src.feed_objective))
				.["Feedings:"] = src.feed_objective.feed_count

		return

//percent, give number 0-1
/datum/abilityHolder/proc/lower_cooldowns(var/percent)
	for (var/datum/targetable/werewolf/A in src.abilities)
		A.cooldown = A.cooldown * (1-percent)

/////////////////////////////////////////////// Werewolf spell parent ////////////////////////////

/datum/targetable/werewolf
	icon = 'icons/mob/werewolf_ui.dmi'
	icon_state = "template"  // No custom sprites yet.
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/werewolf
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0
	var/werewolf_only = 0

	New()
		..()
		var/atom/movable/screen/ability/topBar/werewolf/B = new /atom/movable/screen/ability/topBar/werewolf(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B
		return

	updateObject()
		..()
		if (!src.object)
			src.object = new /atom/movable/screen/ability/topBar/werewolf()
			object.icon = src.icon
			object.owner = src
		if (src.last_cast > world.time)
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt] ([round((src.last_cast-world.time)/10)])"
			object.icon_state = src.icon_state + "_cd"
		else
			var/pttxt = ""
			if (pointCost)
				pttxt = " \[[pointCost]\]"
			object.name = "[src.name][pttxt]"
			object.icon_state = src.icon_state
		return

	proc/incapacitation_check(var/stunned_only_is_okay = 0)
		if (!holder)
			return 0

		var/mob/living/M = holder.owner
		if (!M || !ismob(M))
			return 0

		switch (stunned_only_is_okay)
			if (0)
				if (!isalive(M) || M.hasStatus(list("stunned", "paralysis", "weakened")))
					return 0
				else
					return 1
			if (1)
				if (!isalive(M) || M.getStatusDuration("paralysis") > 0)
					return 0
				else
					return 1
			else
				return 1

	castcheck()
		if (!holder)
			return 0

		var/mob/living/carbon/human/M = holder.owner

		if (!M)
			return 0

		if (!ishuman(M)) // Only humans use mutantrace datums.
			boutput(M, "<span class='alert'>You cannot use any powers in your current form.</span>")
			return 0

		if (M.transforming)
			boutput(M, "<span class='alert'>You can't use any powers right now.</span>")
			return 0

		if (werewolf_only == 1 && !iswerewolf(M))
			boutput(M, "<span class='alert'>You must be in your wolf form to use this ability.</span>")
			return 0

		if (incapacitation_check(src.when_stunned) != 1)
			boutput(M, "<span class='alert'>You can't use this ability while incapacitated!</span>")
			return 0

		if (src.not_when_handcuffed == 1 && M.restrained())
			boutput(M, "<span class='alert'>You can't use this ability when restrained!</span>")
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return
