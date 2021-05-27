
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
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites [MT]!</b></span>", "<span class='combat'>You bite [MT]!</span>")
		return 0

/datum/targetable/critter/peck
	name = "Peck"
	desc = "Peck at a mob."
	icon_state = "blind"
	cooldown = 100
	targeted = 1
	target_anything = 1
	var/take_eyes = 0

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, __red("Nothing to peck there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to peck."))
			return 1

		var/mob/MT = target
		if (iscarbon(MT) && prob(60))
			holder.owner.visible_message("<span class='combat'><B>[holder.owner]</B> pecks [MT] in the eyes!</span>")
			playsound(target, "sound/impact_sounds/Flesh_Stab_2.ogg", 30, 1)
			MT.take_eye_damage(rand(5,10)) //High variance because the bird might not hit well
			if (!isdead(MT))
				MT.emote("scream")
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
					holder.owner.visible_message("<span class='combat'><B>[holder.owner] [pick("tears","yanks","rips")] [MT]'s eye out! <i>Holy shit!!</i></B></span>")
					E = H.drop_organ(chosen_eye)
					playsound(target, "sound/impact_sounds/Flesh_Stab_1.ogg", 50, 1)
					if (holder.owner.put_in_hand_or_drop(E))
						E.set_loc(holder.owner)
					else
						E.set_loc(holder.owner.loc)
			return 0
		else if (isrobot(MT))
			var/mob/living/silicon/robot/R = MT
			if (prob(10))
				holder.owner.visible_message("<span class='combat'><B>[holder.owner]</B> bites [R] and snips an important-looking cable!</span>")
				R.compborg_take_critter_damage(null, 0 ,rand(40,70))
				MT.emote("scream")
				return 0
			else
				holder.owner.visible_message("<span class='combat'><B>[holder.owner]</B> bites [R]!</span>")
				R.compborg_take_critter_damage(null, rand(1,5),0)
				return 0
		else
			holder.owner.visible_message("<span class='combat'><B>[holder.owner]</B> bites [MT]!</span>")
			playsound(target, "swing_hit", 30, 0)
			random_brute_damage(MT, 3,1)
			return 0

/datum/targetable/critter/peck/crow
	take_eyes = 1

/datum/targetable/critter/pounce
	name = "Pounce"
	desc = "Pounce on a mob, causing a short stun."
	cooldown = 200
	targeted = 1
	target_anything = 1

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, __red("Nothing to pounce on there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to pounce on."))
			return 1
		var/mob/MT = target
		playsound(target, "sound/impact_sounds/Generic_Hit_1.ogg", 50, 1, -1)
		MT.changeStatus("stunned", 2 SECONDS)
		MT.changeStatus("weakened", 2 SECONDS)
		if (prob(25))
			holder.owner.visible_message("<span class='combat'><B>[holder.owner]</B> weaves around [MT]'s legs and trips [him_or_her(MT)]!</span>",\
			"<span class='combat'>You weave around [MT]'s legs and trip [him_or_her(MT)]!</span>")
			MT.changeStatus("weakened", 2 SECONDS)
			return 0
		else
			holder.owner.visible_message("<span class='combat'><B>[holder.owner]</B> pounces on [MT]!</span>",\
			"<span class='combat'>You pounce on [MT]!</span>")
			return 0

/datum/targetable/critter/trip
	name = "Trip"
	desc = "Weave around the legs of a mob, causing them to trip."
	cooldown = 250
	targeted = 1
	target_anything = 1

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, __red("Nothing to trip there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to trip."))
			return 1
		var/mob/MT = target
		var/tostun = rand(0,3)
		var/toweak = rand(0,3)
		MT.changeStatus("stunned", tostun SECONDS)
		MT.changeStatus("weakened", toweak SECONDS)
		holder.owner.visible_message("<span class='combat'><B>[holder.owner]</B> weaves around [MT]'s legs!</span>",\
		"<span class='combat'>You weave around [MT]'s legs!</span>")
		if (toweak)
			MT.visible_message("<span class='combat'><B>[MT]</B> trips!</span>")
		return 0

/datum/targetable/critter/wasp_sting
	name = "Sting"
	desc = "Sting a mob, injecting them with venom."
	cooldown = 50
	targeted = 1
	target_anything = 1
	var/venom1 = "histamine"
	var/amt1 = 12
	var/venom2 = "toxin"
	var/amt2 = 2

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, __red("Nothing to sting there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to sting."))
			return 1
		var/mob/MT = target
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] stings [MT]!</b></span>",\
		"<span class='combat'>You sting [MT]!</span>")
		if (MT.reagents)
			MT.reagents.add_reagent(venom1, amt1)
			MT.reagents.add_reagent(venom2, amt2)
		else // um idk??  do some damage w/e
			MT.TakeDamageAccountArmor("All", rand(2,8), 0, 0, DAMAGE_STAB)
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
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] hoots seductively!</b></span>",\
		"<span class='combat'>You hoot seductively!</span>")
		playsound(holder.owner, "sound/voice/animal/hoot.ogg", 90, 0)
		flick("bhooty-flap", holder.owner)
		var/obj/decal/D = new/obj/decal(holder.owner.loc)
		D.name = ""
		D.icon = 'icons/effects/effects.dmi'
		D.icon_state = "hearts"
		D.anchored = 1
		D.layer = EFFECTS_LAYER_2
		holder.owner.attached_objs += D
		SPAWN_DBG(4 SECONDS)
			qdel(D)

