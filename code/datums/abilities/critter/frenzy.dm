// --------------------
// Brullbar style frenzy
// --------------------
/datum/targetable/critter/frenzy
	name = "Frenzy"
	desc = "Go into a bloody frenzy on a weakened target and rip them to shreds."
	cooldown = 35 SECONDS
	targeted = TRUE
	target_anything = TRUE
	icon_state = "frenzy"

	var/frenzy_low = 6 // minimum number of frenzies
	var/frenzy_high = 10 // max number of frenzies
	var/frenzy_damage = 6

	var/knockdown_dur = 1 SECONDS
	var/bleed_prob = 20
	var/bleed_damage = 5
	var/bleed_amount = 5

	var/start_sound = 'sound/voice/animal/brullbar_roar.ogg' // sound when we start frenzy
	var/list/attack_sounds = list("sound/voice/animal/brullbar_maul.ogg") // sounds for each frenzy
	var/list/attack_verbs = list("mauls", "claws", "slashes", "tears at", "lacerates", "mangles") // verbs for each frenzy

	cast(atom/target)
		if (disabled)
			return TRUE
		if (..())
			return TRUE
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			for (var/mob/living/M in target)
				if (is_incapacitated(M))
					target = M
					break
		if (target == holder.owner)
			return TRUE
		if (!ismob(target))
			boutput(holder.owner, SPAN_ALERT("Nothing to frenzy at there."))
			return TRUE
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to frenzy."))
			return TRUE
		var/mob/MT = target
		if (!is_incapacitated(MT))
			boutput(holder.owner, SPAN_ALERT("That is moving around far too much to pounce."))
			return TRUE
		playsound(holder.owner, start_sound, 80, 1)
		disabled = TRUE
		SPAWN(0)
			var/frenz = rand(frenzy_low, frenzy_high)
			APPLY_ATOM_PROPERTY(holder.owner, PROP_MOB_CANTMOVE, "frenzy")
			while (frenz > 0 && MT && !MT.disposed)
				MT.changeStatus("knockdown", knockdown_dur)
				APPLY_ATOM_PROPERTY(MT, PROP_MOB_CANTMOVE, "frenzy")
				if (MT.loc)
					holder.owner.set_loc(MT.loc)
				if (is_incapacitated(holder?.owner))
					break
				playsound(holder.owner, pick(attack_sounds), 70, 1)
				holder.owner.visible_message(SPAN_ALERT("<b>[holder.owner] [pick(attack_verbs)] [MT]!</b>"))
				holder.owner.set_dir((cardinal))
				holder.owner.pixel_x = rand(-5, 5)
				holder.owner.pixel_y = rand(-5, 5)
				random_brute_damage(MT, frenzy_damage, 1)
				take_bleeding_damage(MT, null, bleed_damage, DAMAGE_CUT, 0, get_turf(MT))
				if(prob(bleed_prob) && (!issilicon(MT))) // don't make quite so much mess
					bleed(MT, bleed_amount, bleed_amount, get_step(get_turf(MT), pick(alldirs)), 1)
				sleep(0.5 SECONDS)
				frenz--
			if (MT)
				REMOVE_ATOM_PROPERTY(MT, PROP_MOB_CANTMOVE, "frenzy")
			doCooldown()
			disabled = FALSE
			holder.owner.pixel_x = 0
			holder.owner.pixel_y = 0
			REMOVE_ATOM_PROPERTY(holder.owner, PROP_MOB_CANTMOVE, "frenzy")

		return FALSE

/datum/targetable/critter/frenzy/king
	cooldown = 40 SECONDS

	frenzy_low = 8
	frenzy_high = 10
	frenzy_damage = 9

	knockdown_dur = 2 SECONDS
	bleed_prob = 33
	bleed_damage = 8
	bleed_amount = 6

/datum/targetable/critter/frenzy/crabmaul
	name = "Crustaceous Frenzy"
	desc = "Go into a primal rage, snipping a weakened target to ribbons with your claws."
	cooldown = 1 MINUTE
	icon_state = "claw_maul"

	frenzy_low = 10
	frenzy_high = 20
	frenzy_damage = 4

	knockdown_dur = 1 SECOND
	bleed_prob = 20
	bleed_damage = 3
	bleed_amount = 2

	start_sound = 'sound/items/Scissor.ogg'
	attack_sounds = 'sound/items/Scissor.ogg'
	attack_verbs = list("claws", "slashes", "tears at", "lacerates", "pinches")

/datum/targetable/critter/frenzy/spiker	//Combo it with the tentacle throw to slap someone silly
	name = "Lash"
	desc = "Go into a bloody frenzy on a weakened target and rip them to shreds."
	cooldown = 50 SECONDS
	icon_state = "lash"
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	frenzy_low = 5
	frenzy_high = 5
	frenzy_damage = 7

	knockdown_dur = 1.5 SECONDS
	bleed_prob = 33
	bleed_damage = 15
	bleed_amount = 5

	start_sound = 'sound/impact_sounds/Flesh_Stab_1.ogg'
	attack_sounds = list("sound/impact_sounds/Flesh_Tear_3.ogg", "sound/impact_sounds/Flesh_Stab_1.ogg")
	attack_verbs = list("lashes at", "whips", "slashes", "tears at", "lacerates")

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

