// Converted everything related to werewolves from client procs to ability holders and used
// the opportunity to do some clean-up as well (Convair880).

// Added kyle2143's werewolf patch (Gannets).

/* 	/		/		/		/		/		/		Setup		/		/		/		/		/		/		/		/		*/

/mob/proc/make_werewolf(var/force=0)
	if (ishuman(src))
		var/datum/abilityHolder/werewolf/A = src.get_ability_holder(/datum/abilityHolder/werewolf)
		if (A && istype(A))
			return
		var/datum/abilityHolder/werewolf/W = src.add_ability_holder(/datum/abilityHolder/werewolf)
		//W.addAbility(/datum/targetable/werewolf/werewolf_transform)
		W.addAbility(/datum/targetable/werewolf/werewolf_feast)
		W.addAbility(/datum/targetable/werewolf/werewolf_pounce)
		W.addAbility(/datum/targetable/werewolf/werewolf_thrash)
		W.addAbility(/datum/targetable/werewolf/werewolf_throw)
		W.addAbility(/datum/targetable/werewolf/werewolf_tainted_saliva)
		W.addAbility(/datum/targetable/werewolf/werewolf_defense)
		// W.addAbility(/datum/targetable/werewolf/werewolf_spread_affliction)	//not using for now, but could be fun later ish.
		if (force)
			W.addAbility(/datum/targetable/werewolf/werewolf_transform)
			boutput(src, "<span class='alert'>You are a full werewolf, you can transform immediately!</span>")
		else
			SPAWN_DBG(W.awaken_time)
				handle_natural_werewolf(W)

		src.resistances += /datum/ailment/disease/lycanthropy

		if (src.mind && src.mind.special_role != "omnitraitor")
			SHOW_WEREWOLF_TIPS(src)

	else return

/mob/proc/handle_natural_werewolf(var/datum/abilityHolder/werewolf/W)
	src.emote("shiver")
	boutput(src, "<span class='alert'><b>You feel feral!</b></span>")
	sleep(5 SECONDS)
	if (!src.getStatusDuration("weakened") && !src.getStatusDuration("paralysis"))
		boutput(src, "<span class='alert'><b>You suddenly feel very weak.</b></span>")
		src.emote("collapse")
	SPAWN_DBG(8 SECONDS)
		if (!src.getStatusDuration("weakened"))
			src.emote("collapse")
		boutput(src, "<span class='alert'><b>Your body feels as if it's on fire! You think it's... IT'S CHANGING! You should probably get somewhere private!</b></span>")
		sleep(rand(300, 500))
		src.emote("scream")
		if (!src.getStatusDuration("weakened") && !src.getStatusDuration("paralysis"))
			src.emote("collapse")
		W.addAbility(/datum/targetable/werewolf/werewolf_transform)
		src.werewolf_transform(0, 0) // Not really a fan of this. I wish werewolves all suffered from lycanthropy and that should be how you pass it on, but w/e

////////////////////////////////////////////// Helper procs //////////////////////////////

// Avoids C&P code for that werewolf disease.
/mob/proc/werewolf_transform(var/source_is_lycanthrophy = 0, var/message_type = 0)
	if (ishuman(src))
		var/mob/living/carbon/human/M = src
		var/which_way = 0

		if ((!M.mutantrace || istype(M.mutantrace, /datum/mutantrace/virtual))|| source_is_lycanthrophy == 1)//the istype fixes you needing to transform twice in vr
			M.jitteriness = 0
			M.delStatus("stunned")
			M.delStatus("weakened")
			M.delStatus("paralysis")
			M.delStatus("slowed")
			M.delStatus("disorient")
			M.change_misstep_chance(-INFINITY)
			M.stuttering = 0
			M.drowsyness = 0


			playsound(M.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 50, 1, -1)
			SPAWN_DBG(0.5 SECONDS)
				if (M?.mutantrace && istype(M.mutantrace, /datum/mutantrace/werewolf))
					M.emote("howl")

			M.visible_message("<span class='alert'><B>[M] [pick("metamorphizes", "transforms", "changes")] into a werewolf! Holy shit!</B></span>")
			if (message_type == 0)
				boutput(M, __blue("<h3>You are now a werewolf.</h3>"))
			else
				boutput(M, __blue("<h3>You are now a werewolf. You can remain in this form indefinitely or change back at any time.</h3>"))

			if (source_is_lycanthrophy == 1 && M.mutantrace)
				qdel(M.mutantrace)

			M.set_mutantrace(/datum/mutantrace/werewolf) //this proc handles body updates etc

			//when in werewolf form, get more max health or regenerate
			// M.maxhealth = 200
			// M.health =
			if (src.bioHolder)
				src.bioHolder.AddEffect("regenerator")
				boutput(src, "<span class='alert'>You will now heal over time!</span>")

			if (M.hasStatus("handcuffed"))
				if (M.handcuffs.werewolf_cant_rip())
					boutput(M, __red("You can't seem to break free from these silver handcuffs."))
				else
					M.visible_message("<span class='alert'><B>[M] rips apart the [M.handcuffs] with pure brute strength!</b></span>")
					M.handcuffs.destroy_handcuffs(M)

			which_way = 0

		else
			if (source_is_lycanthrophy == 1) // Werewolf disease is human -> WW only.
				return

			boutput(M, __blue("<h3>You transform back into your human form.</h3>"))

			M.set_mutantrace(null) //this proc handles body updates etc

			if (src.bioHolder)
				src.bioHolder.RemoveEffect("regenerator")
				boutput(src, "<span class='alert'>You will no longer heal over time!</span>")

			//Changing back removes all the implants in you, wolves should have a non-surgery way to remove bullets. considering silver is so harmful
			for(var/obj/item/implant/I in M)
				// if (istype(I, /obj/item/implant/projectile))
				boutput(M, "<span class='alert'>\an [I] falls out of your abdomen.</span>")
				I.on_remove(M)
				M.implant.Remove(I)
				I.set_loc(M.loc)
				continue

			which_way = 1

		logTheThing("combat", M, null, "[which_way == 0 ? "transforms into a werewolf" : "changes back into human form"] at [log_loc(M)].")
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
				boutput(M, __red("Monkey flesh just isn't the real deal..."))
				healing /= 2
			else if (isdead(HH))
				boutput(M, __red("Fresh meat would be much preferable to this cadaver..."))
				healing /= 2
			else if (HH.health < -150)
				boutput(M, __red("[target] is pretty mangled. There's not a lot of flesh left..."))
				healing /= 1.5
			else
				if (iscluwne(HH))
					boutput(M, __red("That tasted awful!"))
					healing /= 2
					M.take_toxin_damage(5)
				else if (iswerewolf(HH) || ishunter(HH) || isabomination(HH))
					boutput(M, __blue("That tasted fantastic!"))
					healing *= 2
				else if (HH.nutrition > 100)
					boutput(M, __blue("That tasted amazing!"))
					M.unlock_medal("Space Ham", 1)
					healing *= 2
				else if (HH.mind && HH.mind.assigned_role == "Clown")
					boutput(M, __blue("That tasted funny, huh."))
					M.unlock_medal("That tasted funny", 1)
				else
					boutput(M, __blue("That tasted good!"))
					M.unlock_medal("Space Ham", 1) //new way to acquire

			HH.add_fingerprint(M) // Just put 'em on the mob itself, like pulling does. Simplifies forensic analysis a bit.
			M.werewolf_audio_effects(HH, "feast")

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
				HH.setStatus("weakened",rand(30,60))
				if (prob(70) && HH.stat != 2)
					HH.emote("scream")
		if ("pounce")
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
			if (prob(75)) target.setStatus("weakened",30)
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

	var/sound_playing = 0

	switch (type)
		if ("disarm")
			playsound(src.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
			SPAWN_DBG(0.1 SECONDS)
				if (src) playsound(src.loc, "swing_hit", 50, 1)

		if ("swipe")
			if (prob(50))
				playsound(src.loc, pick('sound/voice/animal/werewolf_attack1.ogg', 'sound/voice/animal/werewolf_attack2.ogg', 'sound/voice/animal/werewolf_attack3.ogg'), 50, 1)
			else
				playsound(src.loc, pick('sound/impact_sounds/Flesh_Tear_1.ogg', 'sound/impact_sounds/Flesh_Tear_2.ogg'), 50, 1, -1)

			SPAWN_DBG(0.1 SECONDS)
				if (src) playsound(src.loc, "sound/impact_sounds/Flesh_Tear_3.ogg", 40, 1, -1)

		if ("feast")
			if (sound_playing == 0) // It's a long audio clip.
				playsound(src.loc, "sound/voice/animal/wendigo_maul.ogg", 80, 1)
				sound_playing = 1
				SPAWN_DBG(6 SECONDS)
					sound_playing = 0

			playsound(src.loc, pick('sound/impact_sounds/Flesh_Tear_1.ogg', 'sound/impact_sounds/Flesh_Tear_2.ogg'), 50, 1, -1)
			playsound(src.loc, "sound/items/eatfood.ogg", 50, 1, -1)
			if (prob(40))
				playsound(target.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			SPAWN_DBG(1 SECOND)
				if (src && ishuman(src) && prob(50))
					src.emote("burp")

	return

//////////////////////////////////////////// Ability holder /////////////////////////////////////////

/obj/screen/ability/topBar/werewolf
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
			SPAWN_DBG(0)
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
		if (src.owner && src.owner.mind && src.owner.mind.special_role == "werewolf")
			for (var/datum/objective/specialist/werewolf/feed/O in src.owner.mind.objectives)
				src.feed_objective = O

			if (src.feed_objective && istype(src.feed_objective))
				.["Feedings:"] = src.feed_objective.feed_count

		return

//percent, give number 0.0-1.0
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
		var/obj/screen/ability/topBar/werewolf/B = new /obj/screen/ability/topBar/werewolf(null)
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
			src.object = new /obj/screen/ability/topBar/werewolf()
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
			boutput(M, __red("You cannot use any powers in your current form."))
			return 0

		if (M.transforming)
			boutput(M, __red("You can't use any powers right now."))
			return 0

		if (werewolf_only == 1 && !iswerewolf(M))
			boutput(M, __red("You must be in your wolf form to use this ability."))
			return 0

		if (incapacitation_check(src.when_stunned) != 1)
			boutput(M, __red("You can't use this ability while incapacitated!"))
			return 0

		if (src.not_when_handcuffed == 1 && M.restrained())
			boutput(M, __red("You can't use this ability when restrained!"))
			return 0

		return 1

	cast(atom/target)
		. = ..()
		actions.interrupt(holder.owner, INTERRUPT_ACT)
		return
