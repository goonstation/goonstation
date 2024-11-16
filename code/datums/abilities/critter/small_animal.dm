
// a lot of these are probably gunna just be copy/paste jobs because eh.
/datum/targetable/critter/bite/small
	name = "Bite"
	desc = "Bite down on a mob, causing a little damage."
	cooldown = 50
	sound_bite = 'sound/impact_sounds/Flesh_Crush_1.ogg'
	brute_damage = 5

	cast(atom/target)
		if (..())
			return 1
		playsound(target, src.sound_bite, 100, 1, -1)
		var/mob/MT = target
		MT.TakeDamageAccountArmor("All", src.brute_damage, 0, 0, DAMAGE_CRUSH)
		holder.owner.visible_message(SPAN_COMBAT("<b>[holder.owner] bites [MT]!</b>"), SPAN_COMBAT("You bite [MT]!"))
		return 0

/datum/targetable/critter/peck
	name = "Peck"
	desc = "Peck at a mob."
	icon_state = "scuffed_peck"
	cooldown = 10 SECONDS
	targeted = TRUE
	target_anything = TRUE
	var/take_eyes = FALSE

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to peck there."))
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to peck."))
			return 1

		var/mob/MT = target
		if (iscarbon(MT) && prob(60))
			holder.owner.visible_message(SPAN_COMBAT("<B>[holder.owner]</B> pecks [MT] in the eyes!"))
			playsound(target, 'sound/impact_sounds/Flesh_Stab_2.ogg', 30, TRUE)
			MT.take_eye_damage(rand(5,10)) //High variance because the bird might not hit well
			if (src.take_eyes && ishuman(MT) && prob(20))
				var/mob/living/carbon/human/H = MT
				var/chosen_eye = prob(50) ? "left_eye" : "right_eye"
				var/obj/item/organ/eye/E = H.get_organ(chosen_eye)
				if (!E)
					if (chosen_eye == "left_eye")
						chosen_eye = "right_eye"
					else
						chosen_eye = "left_eye"
					E = H.get_organ(chosen_eye)
				if (E)
					holder.owner.visible_message(SPAN_COMBAT("<B>[holder.owner] [pick("tears","yanks","rips")] [MT]'s eye out! <i>Holy shit!!</i></B>"))
					E = H.drop_organ(chosen_eye)
					playsound(target, 'sound/impact_sounds/Flesh_Stab_1.ogg', 50, TRUE)
					if (holder.owner.put_in_hand_or_drop(E))
						E.set_loc(holder.owner)
					else
						E.set_loc(holder.owner.loc)
			return 0
		else if (isrobot(MT))
			var/mob/living/silicon/robot/R = MT
			if (prob(10))
				holder.owner.visible_message(SPAN_COMBAT("<B>[holder.owner]</B> bites [R] and snips an important-looking cable!"))
				R.compborg_take_critter_damage(null, 0 ,rand(40,70))
				return 0
			else
				holder.owner.visible_message(SPAN_COMBAT("<B>[holder.owner]</B> bites [R]!"))
				R.compborg_take_critter_damage(null, rand(1,5),0)
				return 0
		else
			holder.owner.visible_message(SPAN_COMBAT("<B>[holder.owner]</B> bites [MT]!"))
			playsound(target, "swing_hit", 30, 0)
			random_brute_damage(MT, 3,1)
			return 0

/datum/targetable/critter/peck/crow
	icon_state = "peck_crow"
	take_eyes = 1

/datum/targetable/critter/pounce
	name = "Pounce"
	desc = "Pounce on a mob, causing a short stun."
	cooldown = 20 SECONDS
	icon_state = "pounce_polymorph"
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to pounce on there."))
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to pounce on."))
			return 1
		var/mob/MT = target
		playsound(target, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, TRUE, -1)
		MT.changeStatus("stunned", 2 SECONDS)
		MT.changeStatus("knockdown", 2 SECONDS)
		if (prob(25))
			holder.owner.visible_message(SPAN_COMBAT("<B>[holder.owner]</B> weaves around [MT]'s legs and trips [him_or_her(MT)]!"),\
			SPAN_COMBAT("You weave around [MT]'s legs and trip [him_or_her(MT)]!"))
			MT.changeStatus("knockdown", 2 SECONDS)
			return 0
		else
			holder.owner.visible_message(SPAN_COMBAT("<B>[holder.owner]</B> pounces on [MT]!"),\
			SPAN_COMBAT("You pounce on [MT]!"))
			return 0

/datum/targetable/critter/trip
	name = "Trip"
	desc = "Weave around the legs of a mob, causing them to trip."
	icon_state = "tail_trip"
	cooldown = 25 SECONDS
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to trip there."))
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to trip."))
			return 1
		var/mob/MT = target
		var/tostun = rand(0,3)
		var/toweak = rand(0,3)
		MT.changeStatus("stunned", tostun SECONDS)
		MT.changeStatus("knockdown", toweak SECONDS)
		holder.owner.visible_message(SPAN_COMBAT("<B>[holder.owner]</B> weaves around [MT]'s legs!"),\
		SPAN_COMBAT("You weave around [MT]'s legs!"))
		if (toweak)
			MT.visible_message(SPAN_COMBAT("<B>[MT]</B> trips!"))
		return 0

/datum/targetable/critter/wasp_sting
	name = "Sting"
	desc = "Sting a mob, injecting them with venom."
	cooldown = 5 SECONDS
	targeted = TRUE
	icon_state = "waspbee_sting"
	target_anything = TRUE
	var/attack_verb = "sting"
	var/venom1 = "histamine"
	var/amt1 = 12
	var/venom2 = "toxin"
	var/amt2 = 2

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to [attack_verb] there."))
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to [attack_verb]."))
			return 1
		var/mob/MT = target
		holder.owner.visible_message(SPAN_COMBAT("<b>[holder.owner] [attack_verb]s [MT]!</b>"),\
		SPAN_COMBAT("You [attack_verb] [MT]!"))
		playsound(target, 'sound/impact_sounds/Generic_Stab_1.ogg', 50, TRUE)
		if (MT.reagents)
			MT.reagents.add_reagent(venom1, amt1)
			MT.reagents.add_reagent(venom2, amt2)
		else // um idk??  do some damage w/e
			MT.TakeDamageAccountArmor("All", rand(2,8), 0, 0, DAMAGE_STAB)
		return 0

	scorpion_sting
		icon_state = "scorpion_sting"
		cooldown = 12 SECONDS
		venom1 = "neurodepressant"
		amt1 = 5
		venom2 = "toxin"
		amt2 = 10

	snake_bite
		name = "Bite"
		desc = "Bite a mob, injecting them with venom."
		icon_state = "snake_bite"
		cooldown = 8 SECONDS
		attack_verb = "bite"
		venom1 = "hemotoxin"
		amt1 = 12
		amt2 = 0

/datum/targetable/critter/pincer_grab
	name = "Grab"
	desc = "Grab a mob with your pincers, immobilizing them for a bit"
	cooldown = 15 SECONDS
	targeted = TRUE
	icon_state = "pincer_grab"
	target_anything = TRUE


	cast(atom/target)
		if (!holder)
			return

		var/mob/living/M = holder.owner

		if (!M)
			return

		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, SPAN_ALERT("Nothing to grab there."))
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, SPAN_ALERT("That is too far away to grab."))
			return 1
		var/mob/MT = target
		holder.owner.visible_message(SPAN_COMBAT("<b>[holder.owner] grabs [MT] with [his_or_her(holder.owner)] pincers!</b>"),\
		SPAN_COMBAT("You grab [MT]!"))
		playsound(target, 'sound/impact_sounds/Generic_Hit_1.ogg', 50, TRUE)
		playsound(target, 'sound/items/Wirecutter.ogg', 80, TRUE, channel=VOLUME_CHANNEL_EMOTE)
		MT.TakeDamageAccountArmor("All", 0, 0, rand(5,15), DAMAGE_STAB)
		APPLY_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "pincergrab")
		APPLY_ATOM_PROPERTY(MT, PROP_MOB_CANTMOVE, "pincergrab")
		SPAWN(3 SECONDS)
			REMOVE_ATOM_PROPERTY(M, PROP_MOB_CANTMOVE, "pincergrab")
			REMOVE_ATOM_PROPERTY(MT, PROP_MOB_CANTMOVE, "pincergrab")
		return 0

/datum/targetable/critter/hootat
	name = "Hoot seductively"
	desc = "Hoot seductively . . ."
	cooldown = 100
	icon_state = "hootat"

	cast(atom/target)
		if (disabled)
			return 1
		if (..())
			return 1
		holder.owner.visible_message(SPAN_COMBAT("<b>[holder.owner] hoots seductively!</b>"),\
		SPAN_COMBAT("You hoot seductively!"))
		playsound(holder.owner, 'sound/voice/animal/hoot.ogg', 90, 0)
		flick("bhooty-flap", holder.owner)
		var/obj/decal/D = new/obj/decal(holder.owner.loc)
		D.name = ""
		D.icon = 'icons/effects/effects.dmi'
		D.icon_state = "hearts"
		D.anchored = ANCHORED
		D.layer = EFFECTS_LAYER_2
		holder.owner.attached_objs += D
		SPAWN(4 SECONDS)
			qdel(D)


/datum/targetable/critter/drink_blood
	name = "Drink Blood"
	desc = "Drink from a source of blood."
	cooldown = 5 SECONDS
	icon = 'icons/mob/spell_buttons.dmi'
	icon_state = "bite"
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		if (..())
			return TRUE
		if (target == holder.owner)
			return TRUE
		if (!isliving(holder.owner))
			return TRUE

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/critter/C = holder

		actions.start(new/datum/action/bar/private/icon/bat_drink_blood(M, C, target, src), M)

		return TRUE

/datum/action/bar/private/icon/bat_drink_blood
	duration = 10
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_STUNNED
	icon = 'icons/ui/actions.dmi'
	icon_state = "blood"
	bar_icon_state = "bar-vampire"
	border_icon_state = "border-vampire"
	color_active = "#d73715"
	color_success = "#f21b1b"
	color_failure = "#8d1422"
	var/mob/living/critter/small_animal/bat/mini_vampire
	var/datum/abilityHolder/critter/C
	var/atom/target
	var/datum/targetable/critter/drink_blood/ability

	/// amount of blood a single sip this bat takes contains.
	var/const/blood_sip_amt = 20

	New(user, vampabilityholder, target, biteabil)
		src.mini_vampire = user
		src.C = vampabilityholder
		src.target = target
		src.ability = biteabil
		..()

	onUpdate()
		..()
		if(GET_DIST(src.mini_vampire, src.target) > 7 || src.mini_vampire == null || src.target == null || length(src.mini_vampire.drink_targets) < 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		if (ishuman(src.target))
			var/mob/living/carbon/human/H = src.target
			if(H.blood_volume <= 0)
				interrupt(INTERRUPT_ALWAYS)
				return
		else if (istype(target, /obj/item/reagent_containers/))
			var/obj/item/reagent_containers/container = target
			if(!container.reagents.has_reagent("blood", blood_sip_amt))
				interrupt(INTERRUPT_ALWAYS)
				return
		else if (istype(target, /obj/fluid))
			var/obj/fluid/F = target
			if (!F.group || F.name != "blood")
				interrupt(INTERRUPT_ALWAYS)
				return

	onStart()
		..()
		if(src.mini_vampire == null || src.target == null)
			interrupt(INTERRUPT_ALWAYS)
			return

		if (GET_DIST(src.mini_vampire, src.target) > 7)
			boutput(src.mini_vampire, SPAN_ALERT("That target is too far away!"))
			return

		if (ishuman(target))
			var/mob/living/carbon/human/H = target

			if (H.blood_volume < blood_sip_amt)
				H.blood_volume = 0
			else
				if (prob(30))
					take_bleeding_damage(H, null, 5, DAMAGE_CUT, 0, get_turf(src.mini_vampire))
					src.mini_vampire.visible_message(SPAN_ALERT("<B>Whoops, looks like [src.mini_vampire] bit down a bit too hard."))
				H.blood_volume -= blood_sip_amt
				// fresh blood is the quenchiest. Bats get more blood points this way
				src.mini_vampire.amount_of_blood += blood_sip_amt * 2
				src.mini_vampire.blood_volume += blood_sip_amt * 2
			src.mini_vampire.health += 2

		else if (istype(target, /obj/item/reagent_containers/))
			var/obj/item/reagent_containers/container = target
			container.reagents.remove_reagent("blood", blood_sip_amt)
			src.mini_vampire.amount_of_blood += blood_sip_amt
			src.mini_vampire.blood_volume += blood_sip_amt
			src.mini_vampire.health ++

		else if (istype(target, /obj/fluid))
			var/obj/fluid/F = target
			if (F.group)
				F.group.queued_drains += 1
				F.group.last_drain = get_turf(F)
				if (!F.group.draining)
					F.group.add_drain_process()

			src.mini_vampire.amount_of_blood += blood_sip_amt
			src.mini_vampire.blood_volume += max(blood_sip_amt, F.group.amt_per_tile)
			src.mini_vampire.health ++

		else
			interrupt(INTERRUPT_ALWAYS)

		playsound(src.mini_vampire.loc,'sound/items/drink.ogg', rand(10,50), 1)
		eat_twitch(src.mini_vampire)

		if (istype(src.mini_vampire, /mob/living/critter/small_animal/bat/doctor))
			JOB_XP(target, "Medical Doctor", 1)
		src.mini_vampire.visible_message("[src.mini_vampire] finishes drinking blood from [target] for now. That cutie looks pretty satisfied.")
		src.mini_vampire.drink_targets.Cut()

		logTheThing(LOG_COMBAT, src.mini_vampire, "steals blood from [constructTarget(src.target,"combat")] at [log_loc(src.mini_vampire)].")

	onInterrupt()
		if (state == ACTIONSTATE_RUNNING)
			if (ishuman(src.target))
				var/mob/living/carbon/human/H = src.target
				if (H.blood_volume <= 0)
					boutput(src.mini_vampire, SPAN_ALERT("[src.target] doesn't have enough blood left to drink."))
				else
					boutput(src.mini_vampire, SPAN_ALERT("Your feast was interrupted."))
			else
				boutput(src.mini_vampire, SPAN_ALERT("Your feast was interrupted."))

		if (ability)
			ability.doCooldown()

		..()
