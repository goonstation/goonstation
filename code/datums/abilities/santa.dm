//stole this from vampire. prevents runtimes. IDK why this isn't in the parent.
/atom/movable/screen/ability/topBar/santa
	clicked(params)
		var/datum/targetable/santa/spell = owner
		var/datum/abilityHolder/holder = owner.holder

		if (!istype(spell))
			return
		if (!spell.holder)
			return

		if(params["shift"] && params["ctrl"])
			if(owner.waiting_for_hotkey)
				holder.cancel_action_binding()
				return
			else
				owner.waiting_for_hotkey = 1
				src.UpdateIcon()
				boutput(usr, SPAN_NOTICE("Please press a number to bind this ability to..."))
				return

		if (!isturf(owner.holder.owner.loc))
			boutput(owner.holder.owner, SPAN_ALERT("You can't use this spell here."))
			return
		if (spell.targeted && usr.targeting_ability == owner)
			usr.targeting_ability = null
			usr.update_cursor()
			return
		if (spell.targeted)
			if (world.time < spell.last_cast)
				return
			owner.holder.owner.targeting_ability = owner
			owner.holder.owner.update_cursor()
		else
			SPAWN(0)
				spell.handleCast()
		return


/* 	/		/		/		/		/		/		Ability Holder		/		/		/		/		/		/		/		/		*/

/datum/abilityHolder/santa
	usesPoints = 0
	regenRate = 0
	tabName = "santa"
	// notEnoughPointsMessage = SPAN_ALERT("You need more blood to use this ability.")
	points = 0
	pointName = "points"
	var/stealthed = 0
	var/const/MAX_POINTS = 100

	New()
		..()

	disposing()
		..()

	onLife(var/mult = 1)
		if(..()) return


/datum/targetable/santa
	icon = 'icons/mob/santa_abilities.dmi'
	icon_state = "santa-template"
	cooldown = 0
	last_cast = 0
	pointCost = 0
	preferred_holder_type = /datum/abilityHolder/santa
	var/when_stunned = 0 // 0: Never | 1: Ignore mob.stunned and mob.weakened | 2: Ignore all incapacitation vars
	var/not_when_handcuffed = 0

	New()
		var/atom/movable/screen/ability/topBar/santa/B = new /atom/movable/screen/ability/topBar/santa(null)
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
			src.object = new /atom/movable/screen/ability/topBar/santa()
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

	castcheck()
		if (!holder)
			return 0

		var/mob/living/M = holder.owner

		if (!M)
			return 0

		if (!(iscarbon(M) || ismobcritter(M)))
			boutput(M, SPAN_ALERT("You cannot use any powers in your current form."))
			return 0

		if (!isdead(M))
			return 1
		if (!can_act(M, 0))
			boutput(M, SPAN_ALERT("You can't use this ability while incapacitated!"))
			return 0

		if (src.not_when_handcuffed && M.restrained())
			boutput(M, SPAN_ALERT("You can't use this ability when restrained!"))
			return 0

		return 1

	cast(atom/target)
		. = ..()

/datum/targetable/santa/heal
	name = "Santa Heal"
	desc = "Heal everyone around you."
	icon_state = "heal"
	targeted = 0
	cooldown = 1 MINUTES

	cast()
		. = ..()
		playsound(holder.owner.loc, 'sound/voice/heavenly.ogg', 50, 1, 0)
		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] calls on the power of Spacemas to heal everyone!</B>"))
		for (var/mob/living/M in view(holder.owner,5))
			M.HealDamage("All", 30, 30)

/datum/targetable/santa/gifts
	name = "Santa Gifts"
	desc = "Summon a whole bunch of Spacemas presents!"
	icon_state = "presents"
	targeted = 0
	cooldown = 2 MINUTES

	cast()
		. = ..()
		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] throws out a bunch of Spacemas presents from nowhere!</B>"))
		playsound(usr.loc, 'sound/machines/fortune_laugh.ogg', 25, 1, -1)
		holder.owner.transforming = 1
		var/to_throw = rand(3,12)

		var/list/nearby_turfs = list()

		for (var/turf/T in view(5,holder.owner))
			nearby_turfs += T

		while(to_throw > 0)
			var/obj/item/a_gift/festive/X = new /obj/item/a_gift/festive(holder.owner.loc)
			X.throw_at(pick(nearby_turfs), 16, 3)
			to_throw--
			sleep(0.2 SECONDS)
		holder.owner.transforming = 0

/datum/targetable/santa/food
	name = "Spacemas Goodies"
	desc = "Summon a whole bunch of festive snacks!"
	icon_state = "food"
	targeted = 0
	cooldown = 80 SECONDS

	cast()
		. = ..()
		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] casts out a whole shitload of snacks from nowhere!</B>"))
		playsound(holder.owner.loc, 'sound/machines/fortune_laugh.ogg', 25, 1, -1)
		holder.owner.transforming = 1
		var/to_throw = rand(6,18)

		var/list/nearby_turfs = list()

		for (var/turf/T in view(5,holder.owner))
			nearby_turfs += T

		var/snack
		while(to_throw > 0)
			snack = pick(santa_snacks)
			var/obj/item/X = new snack(holder.owner.loc)
			X.throw_at(pick(nearby_turfs), 16, 3)
			to_throw--
			sleep(0.1 SECONDS)
		holder.owner.transforming = 0

/datum/targetable/santa/warmth
	name = "Winter Hearth"
	desc = "Gives everyone near you temporary cold resistance."
	icon_state = "warmth"
	targeted = 0
	cooldown = 80 SECONDS

	cast()
		. = ..()
		playsound(holder.owner.loc, 'sound/effects/MagShieldUp.ogg', 60, 1, 0)
		holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] summons the warmth of a nice toasty fireplace!</B>"))
		for (var/mob/living/M in view(holder.owner,5))
			if (M.bioHolder && !M.bioHolder.HasOneOfTheseEffects("fire_resist", "cold_resist", "thermal_resist"))
				M.bioHolder.AddEffect("cold_resist", 0, 60) // this will wipe `thermal_vuln` still vOv

/datum/targetable/deploy
	name = "Deploy Elf"
	desc = ""
	icon = 'icons/mob/santa_abilities.dmi'
	icon_state = "santa-template"

	cast()
		. = ..()
		var/turf/T
		T = get_turf(holder.owner)
		new/obj/effect/supplymarker/safe(T, 3 SECONDS, /mob/living/carbon/human/elf, TRUE)
		SPAWN (7 SECONDS)
			var/mob/living/intangible/santa_target/reticle = holder.owner
			var/mob/living/carbon/human/elf/elf = locate(/mob/living/carbon/human/elf) in view(3, T)
			if (elf)
				elf.santa = reticle.santa
				holder.owner.mind.transfer_to(elf)
				playsound(T, 'sound/machines/fortune_laugh.ogg', 25, 1, -1)
			else
				if (reticle.santa)
					holder.owner.mind.transfer_to(reticle.santa) // if code fails get sent back to santa
				else
					holder.owner.visible_message("Couldn't find an elf or santa to return to. Call an admin!")
			qdel(reticle)

/datum/targetable/return_to_santa
	name = "Cancel Deployment"
	desc = ""
	icon = 'icons/mob/santa_abilities.dmi'
	icon_state = "santa-template"

	cast()
		. = ..()
		var/mob/living/intangible/santa_target/reticle = holder.owner
		if (reticle.santa)
			holder.owner.mind.transfer_to(reticle.santa)
			qdel(reticle)
		else
			holder.owner.visible_message("Santa not found, call an admin!")

/mob/living/intangible/santa_target
	name = ""
	desc = ""
	icon = 'icons/effects/128x128.dmi'
	icon_state = "reticle_small"
	nodamage = 0
	density = 0
	layer = 101
	can_lie = FALSE
	can_bleed = FALSE
	metabolizes = FALSE
	blood_id = null
	use_stamina = FALSE
	var/mob/santa

	New()
		..()
		pixel_y -= 48
		pixel_x -= 48
		see_invisible = INVIS_AI_EYE
		sight |= SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF
		APPLY_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src, INVIS_AI_EYE)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_EXAMINE_ALL_NAMES, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_NO_MOVEMENT_PUFFS, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_CANNOT_VOMIT, src)
		var/datum/abilityHolder/HS = src.add_ability_holder(/datum/abilityHolder/santa)
		HS.addAbility(/datum/targetable/deploy)
		HS.addAbility(/datum/targetable/return_to_santa)

/datum/targetable/santa/teleport
	name = "Call in Elf Support"
	desc = "Call in a faithful elf monkey to relay messages and gifts to the crew!"
	icon_state = "warp"
	targeted = 0
	cooldown = 80 SECONDS

	cast()
		. = ..()
		var/mob/living/intangible/santa_target/reticle = new /mob/living/intangible/santa_target (get_turf(holder.owner))
		reticle.santa = holder.owner
		holder.owner.mind.transfer_to(reticle)

/datum/targetable/santa/banish
	name = "Banish Krampus"
	desc = "Get rid of Krampus. He may return if Christmas Cheer goes too low again though."
	icon_state = "banish_krampus"
	targeted = 0
	cooldown = 10 SECONDS

	cast()
		. = ..()
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		for (var/mob/living/carbon/cube/meat/krampus/K in view(7,holder.owner))
			holder.owner.visible_message(SPAN_ALERT("<B>[holder.owner] makes a stern gesture at [K]!</B>"))
			boutput(K, SPAN_ALERT("You have been banished by Santa Claus!"))
			playsound(usr.loc, 'sound/effects/bamf.ogg', 25, 1, -1)
			smoke.set_up(1, 0, K.loc)
			smoke.attach(K)
			smoke.start()
			K.gib()
			krampus_spawned = 0
			return

		boutput(holder.owner, SPAN_ALERT("Can't find any Krampuses to banish! (you must be within 7 tiles)"))
