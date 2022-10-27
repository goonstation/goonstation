/datum/bioEffect/power
	name = "Cryokinesis"
	desc = "Allows the subject to control ice and cold."
	id = "cryokinesis"
	msgGain = "You notice a strange cold tingle in your fingertips."
	msgLose = "Your fingers feel warmer."
	effectType = EFFECT_TYPE_POWER
	cooldown = 600
	probability = 66
	blockCount = 3
	blockGaps = 2
	stability_loss = 10
	var/using = 0
	var/safety = 0
	var/ability_path = /datum/targetable/geneticsAbility/cryokinesis
	var/datum/targetable/geneticsAbility/ability = /datum/targetable/geneticsAbility/cryokinesis

	New()
		..()
		check_ability_owner()

	disposing()
		src.owner = null
		if (ability)
			ability.dispose()
			ability.owner = null
		src.ability = null
		..()

	OnAdd()
		..()
		if (ishuman(owner))
			check_ability_owner()
			var/mob/living/carbon/human/H = owner
			H.hud.update_ability_hotbar()
		return

	OnRemove()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.hud)
				H.hud.update_ability_hotbar()
		return

	proc/check_ability_owner()
		if (ispath(ability_path))
			var/datum/targetable/geneticsAbility/AB = new ability_path(src)
			ability = AB
			AB.linked_power = src
			icon = AB.icon
			icon_state = AB.icon_state
			AB.owner = src.owner

/datum/targetable/geneticsAbility/cryokinesis
	name = "Cryokinesis"
	desc = "Exert control over cold and ice."
	icon_state = "cryokinesis"
	targeted = TRUE
	target_anything = TRUE

	cast(atom/target)
		if (..())
			return 1

		var/turf/T = get_turf(target)

		target.visible_message("<span class='alert'><b>[owner]</b> points at [target]!</span>")
		playsound(target.loc, 'sound/effects/bamf.ogg', 50, 0)
		particleMaster.SpawnSystem(new /datum/particleSystem/tele_wand(get_turf(target),"8x8snowflake","#88FFFF"))

		var/obj/decal/icefloor/B
		for (var/turf/TF in range(linked_power.power - 1,T))
			B = new /obj/decal/icefloor(TF)
			SPAWN(80 SECONDS)
				B.dispose()

		for (var/mob/living/L in T.contents)
			if (L == owner && linked_power.safety)
				continue
			boutput(L, "<span class='notice'>You are struck by a burst of ice cold air!</span>")
			if(L.getStatusDuration("burning"))
				L.delStatus("burning")
			L.bodytemperature = 100
			if (linked_power.power > 1)
				new /obj/icecube(get_turf(L), L)

		return

	cast_misfire(atom/target)
		if (..())
			return 1

		owner.visible_message("<span class='alert'><b>[owner]</b> points at [target]!</span>")
		playsound(owner.loc, 'sound/effects/bamf.ogg', 50, 0)
		particleMaster.SpawnSystem(new /datum/particleSystem/tele_wand(get_turf(owner),"8x8snowflake","#88FFFF"))

		if (!linked_power.safety)
			boutput(owner, "<span class='alert'>Your cryokinesis misfires and freezes you!</span>")
			if(owner.getStatusDuration("burning"))
				owner.delStatus("burning")
			owner.bodytemperature = 100
			new /obj/icecube(get_turf(owner), owner)
		else
			boutput(owner, "<span class='alert'>Your cryokinesis misfires!</span>")
			if(owner.getStatusDuration("burning"))
				owner.delStatus("burning")

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/mattereater
	name = "Matter Eater"
	desc = "Allows the subject to eat just about anything without harm."
	id = "mattereater"
	msgGain = "You feel hungry."
	msgLose = "You don't feel quite so hungry anymore."
	cooldown = 300
	probability = 66
	blockCount = 4
	blockGaps = 2
	stability_loss = 5
	ability_path = /datum/targetable/geneticsAbility/mattereater
	var/target_path = /obj/item/

/datum/targetable/geneticsAbility/mattereater
	name = "Matter Eater"
	desc = "Eat just about anything!"
	icon_state = "mattereater"
	targeted = FALSE
	needs_hands = FALSE
	var/using = FALSE

	cast()
		if (..())
			return TRUE
		if (using)
			return TRUE
		using = TRUE

		var/datum/bioEffect/power/mattereater/mattereater = linked_power
		var/list/items = get_filtered_atoms_in_touch_range(owner, mattereater.target_path)
		if (ismob(owner.loc) || istype(owner.loc, /obj/))
			for (var/atom/A in owner.loc.contents)
				if (istype(A, mattereater.target_path))
					items += A

		if (linked_power.power > 1)
			items += get_filtered_atoms_in_touch_range(owner, /obj/the_server_ingame_whoa)
			//So people can still get the meat ending

		if (!length(items))
			boutput(usr, "<span class='alert'>You can't find anything nearby to eat.</span>")
			using = FALSE
			return

		var/obj/the_object = input("Which item do you want to eat?","Matter Eater") as null|obj in items
		if (!the_object || (!istype(the_object, /obj/the_server_ingame_whoa) && the_object.anchored))
			using = FALSE
			return TRUE

		if (!(the_object in get_filtered_atoms_in_touch_range(owner, mattereater.target_path)) && !istype(the_object, /obj/the_server_ingame_whoa))
			owner.show_text("<span class='alert'>Man, that thing is long gone, far away, just let it go.</span>")
			using = FALSE
			return TRUE

		var/area/cur_area = get_area(owner)
		var/turf/cur_turf = get_turf(owner)
		if (isrestrictedz(cur_turf.z) && !cur_area.may_eat_here_in_restricted_z && (!owner.client || !owner.client.holder))
			owner.show_text("<span class='alert'>Man, this place really did a number on your appetite. You can't bring yourself to eat anything here.</span>")
			using = FALSE
			return TRUE

		if (istype(the_object, /obj/the_server_ingame_whoa))
			var/obj/the_server_ingame_whoa/the_server = the_object
			the_server.eaten(owner)
			using = FALSE
			return

		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner

			// First, restore a little hunger, and heal our organs
			if (isitem(the_object))
				var/obj/item/the_item = the_object
				H.sims?.affectMotive("Hunger", (the_item.w_class + 1) * 5) // +1 so tiny items still give a small boost
				for(var/A in owner.organs)
					var/obj/item/affecting = null
					if (!owner.organs[A])
						continue
					affecting = owner.organs[A]
					if (!isitem(affecting))
						continue
					affecting.heal_damage(4, 0)
				owner.UpdateDamageIcon()

		if (!QDELETED(the_object)) // Finally, ensure that the item is deleted regardless of what it is
			var/obj/item/I = the_object
			if(I)
				if(I.Eat(owner, owner, TRUE)) //eating can return false to indicate it failed
					// Organs and body parts have special behaviors we need to account for
					if (ishuman(owner))
						var/mob/living/carbon/human/H = owner
						if (istype(the_object, /obj/item/organ))
							var/obj/item/organ/organ_obj = the_object
							if (organ_obj.donor)
								H.organHolder.drop_organ(the_object,H) //hide it inside self so it doesn't hang around until the eating is finished
						else if (istype(the_object, /obj/item/parts))
							var/obj/item/parts/part = the_object
							part.delete()
							H.hud.update_hands()
			else //Eat() handles qdel, visible message and sound playing, so only do that when we don't have Eat()
				owner.visible_message("<span class='alert'>[owner] eats [the_object].</span>")
				playsound(owner.loc, 'sound/items/eatfood.ogg', 50, FALSE)
				qdel(the_object)



		using = FALSE



	cast_misfire()
		if (..())
			return 1
		if (using)
			return 1
		using = 1

		var/datum/bioEffect/power/mattereater/mattereater = linked_power
		var/list/items = get_filtered_atoms_in_touch_range(owner, mattereater.target_path)
		if (ismob(owner.loc) || istype(owner.loc, /obj/))
			for (var/atom/A in owner.loc.contents)
				if (istype(A, mattereater.target_path))
					items += A

		if (linked_power.power > 1)
			items += get_filtered_atoms_in_touch_range(owner, /obj/the_server_ingame_whoa)
			//So people can still get the meat ending

		if (!items.len)
			boutput(usr, "/red You can't find anything nearby to eat.")
			using = 0
			return

		var/obj/the_object = input("Which item do you want to eat?","Matter Eater") as null|obj in items
		if (!the_object)
			using = 0
			return 1

		var/area/cur_area = get_area(owner)
		var/turf/cur_turf = get_turf(owner)
		if (isrestrictedz(cur_turf.z) && !cur_area.may_eat_here_in_restricted_z && (!owner.client || !owner.client.holder))
			owner.show_text("<span class='alert'>Man, this place really did a number on your appetite. You can't bring yourself to eat anything here.</span>")
			using = 0
			return 1

		if (istype(the_object, /obj/the_server_ingame_whoa))
			var/obj/the_server_ingame_whoa/the_server = the_object
			the_server.eaten(owner)
			using = 0
			return
		owner.visible_message("<span class='alert'>[owner] tries to swallow [the_object] whole and nearly chokes on it.</span>")
		playsound(owner.loc, 'sound/items/eatfood.ogg', 50, 0)
		playsound(owner.loc, 'sound/misc/meat_plop.ogg', 50, 0)
		using = 0
		return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/jumpy
	name = "Jumpy"
	desc = "Allows the subject to leap great distances."
	id = "jumpy"
	msgGain = "Your leg muscles feel taut and strong."
	msgLose = "Your leg muscles shrink back to normal."
	cooldown = 30
	probability = 99
	blockCount = 4
	blockGaps = 2
	stability_loss = 10
	ability_path = /datum/targetable/geneticsAbility/jumpy

/datum/bioEffect/power/jumpy/jumpsuit // granted by the frog jumpsuit
	id = "jumpy_suit"
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	curable_by_mutadone = 0
	can_reclaim = 0
	can_scramble = 0
	can_research = 0
	can_make_injector = 0
	reclaim_fail = 100

/datum/targetable/geneticsAbility/jumpy
	name = "Jumpy"
	desc = "Take a big leap forward."
	icon_state = "jumpy"
	needs_hands = FALSE
	targeted = 0

	cast()
		if (..())
			return 1

		if (ismob(owner.loc))
			boutput(usr, "<span class='alert'>You can't jump right now!</span>")
			return 1

		//store both x and y as transforms mid jump can cause unwanted pixel offsetting
		var/jump_tiles = 10 * linked_power.power
		var/pixel_move = 8 * linked_power.power
		var/sleep_time = 1 / linked_power.power

		if (istype(owner.loc,/turf/))
			usr.visible_message("<span class='alert'><b>[owner]</b> takes a huge leap!</span>")
			playsound(owner.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1)
			var/prevLayer = owner.layer
			owner.layer = EFFECTS_LAYER_BASE

			animate(owner,
				pixel_y = pixel_move * jump_tiles / 2,
				time = sleep_time * jump_tiles / 2,
				easing = EASE_OUT | CIRCULAR_EASING,
				flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
			animate(
				pixel_y = -pixel_move * jump_tiles / 2,
				time = sleep_time * jump_tiles / 2,
				easing = EASE_IN | CIRCULAR_EASING,
				flags = ANIMATION_RELATIVE)

			SPAWN(0)
				for(var/i=0, i < jump_tiles, i++)
					step(owner, owner.dir)
					sleep(sleep_time)

				owner.layer = prevLayer

		if (istype(owner.loc,/obj/))
			var/obj/container = owner.loc
			boutput(owner, "<span class='alert'>You leap and slam your head against the inside of [container]! Ouch!</span>")
			owner.changeStatus("paralysis", 5 SECONDS)
			owner.changeStatus("weakened", 5 SECONDS)
			container.visible_message("<span class='alert'><b>[owner.loc]</b> emits a loud thump and rattles a bit.</span>")
			playsound(container, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1)
			animate_storage_thump(container)

		return

	cast_misfire()
		if (..())
			return 1

		if (ismob(owner.loc))
			boutput(usr, "<span class='alert'>You can't jump right now!</span>")
			return 1

		//store both x and y as transforms mid jump can cause unwanted pixel offsetting
		var/original_x_offset = owner.pixel_x
		var/original_y_offset = owner.pixel_y
		var/jump_tiles = 10 * linked_power.power
		var/pixel_move = 8 * linked_power.power
		var/sleep_time = 0.5 / linked_power.power

		if (istype(owner.loc,/turf/))
			usr.visible_message("<span class='alert'><b>[owner]</b> leaps far too high and comes crashing down hard!</span>")
			playsound(owner.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1)
			playsound(owner.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 50, 1)
			var/prevLayer = owner.layer
			owner.layer = EFFECTS_LAYER_BASE
			owner.changeStatus("weakened", 10 SECONDS)
			owner.changeStatus("stunned", 5 SECONDS)

			SPAWN(0)
				for(var/i=0, i < jump_tiles, i++)
					if(i < jump_tiles / 2)
						owner.pixel_y += pixel_move
					else
						owner.pixel_y -= pixel_move
					sleep(sleep_time)

				owner.pixel_x = original_x_offset
				owner.pixel_y = original_y_offset
				owner.layer = prevLayer

		if (istype(owner.loc,/obj/))
			var/obj/container = owner.loc
			boutput(owner, "<span class='alert'>You leap and slam your head against the inside of [container]! Ouch!</span>")
			owner.changeStatus("paralysis", 5 SECONDS)
			owner.changeStatus("weakened", 5 SECONDS)
			container.visible_message("<span class='alert'><b>[owner.loc]</b> emits a loud thump and rattles a bit.</span>")
			playsound(owner.loc, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1)
			SPAWN(0)
				var/wiggle = 6
				while(wiggle > 0)
					wiggle--
					container.pixel_x = rand(-3,3)
					container.pixel_y = rand(-3,3)
					sleep(0.1 SECONDS)
				container.pixel_x = 0
				container.pixel_y = 0

		return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/polymorphism
	name = "Polymorphism"
	desc = "Enables the subject to reconfigure their appearance to mimic that of others."
	id = "polymorphism"
	msgGain = "You don't feel entirely like yourself somehow."
	msgLose = "You feel secure in your identity."
	cooldown = 1800
	probability = 66
	blockCount = 4
	blockGaps = 4
	stability_loss = 15
	ability_path = /datum/targetable/geneticsAbility/polymorphism

/datum/targetable/geneticsAbility/polymorphism
	name = "Polymorphism"
	desc = "Mimic the appearance of others."
	icon_state = "polymorphism"
	targeted = 1

	cast(atom/target)
		if (..())
			return 1

		if (target == owner)
			boutput(owner, "<span class='alert'>While \"be yourself\" is pretty good advice, that would be taking it a bit too literally.</span>")
			return 1
		if (BOUNDS_DIST(target, owner) > 0 && !owner.bioHolder.HasEffect("telekinesis"))
			boutput(owner, "<span class='alert'>You must be within touching distance of [target] for this to work.</span>")
			return 1

		if (!ishuman(target))
			boutput(owner, "<span class='alert'>[target] does not seem to be compatible with this ability.</span>")
			return 1
		var/mob/living/carbon/human/H = target
		if (!H.bioHolder || H.mutantrace?.dna_mutagen_banned)
			boutput(owner, "<span class='alert'>[target] does not seem to be compatible with this ability.</span>")
			return 1

		if (!ishuman(owner))
			boutput(owner, "<span class='alert'>Your body doesn't seem to be compatible with this ability.</span>")
			return 1
		var/mob/living/carbon/human/H2= target
		if (!H2.bioHolder || H2.mutantrace?.dna_mutagen_banned)
			boutput(owner, "<span class='alert'>Your body doesn't seem to be compatible with this ability.</span>")
			return 1

		playsound(owner.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 50, 1)
		owner.visible_message("<span class='alert'><b>[owner]</b> touches [target], then begins to shifts and contort!</span>")

		SPAWN(1 SECOND)
			if(H && owner)
				playsound(owner.loc, 'sound/impact_sounds/Flesh_Break_2.ogg', 50, 1)
				owner.bioHolder.CopyOther(H.bioHolder, copyAppearance = 1, copyPool = 0, copyEffectBlocks = 0, copyActiveEffects = 0)
				owner.real_name = H.real_name
				owner.name = H.name
				if(owner.bioHolder?.mobAppearance?.mutant_race)
					owner.set_mutantrace(owner.bioHolder.mobAppearance.mutant_race.type)
				else
					owner.set_mutantrace(null)
				if(ishuman(owner))
					var/mob/living/carbon/human/O = owner
					O.update_colorful_parts()
		return

	cast_misfire(atom/target)
		if (..())
			return 1

		if (!ishuman(target))
			boutput(owner, "<span class='alert'>[target] does not seem to be compatible with this ability.</span>")
			return 1
		if (target == owner)
			boutput(owner, "<span class='alert'>While \"be yourself\" is pretty good advice, that would be taking it a bit too literally.</span>")
			return 1
		var/mob/living/carbon/human/H = target
		if (!H.bioHolder)
			boutput(owner, "<span class='alert'>[target] does not seem to be compatible with this ability.</span>")
			return 1

		if (BOUNDS_DIST(H, owner) > 0 && !owner.bioHolder.HasEffect("telekinesis"))
			boutput(owner, "<span class='alert'>You must be within touching distance of [target] for this to work.</span>")
			return 1

		playsound(owner.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 50, 1)
		owner.visible_message("<span class='alert'><b>[owner]</b> touches [target]... and nothing happens. Huh.</span>")

		return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*  / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /  */
/* / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /  */

/datum/bioEffect/power/colorshift
	name = "Trichochromatic Shift"
	desc = "Enables the subject to shift their hair color to a different region."
	id = "colorshift"
	msgGain = "Your hair itches."
	msgLose = "You feel more confident in your hair color."
	cooldown = 600
	probability = 66
	blockCount = 4
	blockGaps = 4
	stability_loss = 0
	ability_path = /datum/targetable/geneticsAbility/colorshift

/datum/targetable/geneticsAbility/colorshift
	name = "Trichochromatic Shift"
	desc = "Swap the colors of your hair around."
	icon_state = "polymorphism"
	needs_hands = FALSE
	targeted = 0

	cast()
		if (..())
			return 1

		var/mob/living/carbon/human/H
		if (ishuman(owner))
			H = owner
		else
			boutput(H, "<span class='notice'>This only works on human hair!</span>")
			return

		if (istype(H.mutantrace, /datum/mutantrace/lizard))
			boutput(H, "<span class='notice'>You don't have any hair!</span>")
			return
		else if (H.mutantrace?.override_hair && !istype(H.mutantrace, /datum/mutantrace/cow))
			boutput(H, "<span class='notice'>Whatever hair you have isn't affected!</span>")
			return

		if (H.bioHolder?.mobAppearance)
			var/datum/appearanceHolder/AHs = H.bioHolder.mobAppearance

			var/col1 = AHs.customization_first_color
			var/col2 = AHs.customization_second_color
			var/col3 = AHs.customization_third_color

			AHs.customization_first_color = col3
			AHs.customization_second_color = col1
			AHs.customization_third_color = col2

			H.visible_message("<span class='notice'><b>[H.name]</b>'s hair changes colors!</span>")
			H.update_colorful_parts()

/* / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / */
/* / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / */
/* / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / */

/datum/bioEffect/power/telepathy
	name = "Telepathy"
	desc = "Allows the subject to project their thoughts into the minds of other organics."
	id = "telepathy"
	msgGain = "You can hear your own voice echoing in your mind."
	msgLose = "Your mental voice fades away."
	probability = 99
	blockCount = 4
	blockGaps = 2
	stability_loss = 0
	ability_path = /datum/targetable/geneticsAbility/telepathy

/datum/targetable/geneticsAbility/telepathy
	name = "Telepathy"
	desc = "Transmit psychic messages to others."
	icon_state = "telepathy"
	needs_hands = FALSE
	targeted = 1

	cast(atom/target)
		if (..())
			return 1

		var/mob/living/carbon/recipient = null
		if (iscarbon(target))
			recipient = target
		else if (ismob(target) && !iscarbon(target))
			boutput(owner, "<span class='alert'>You can't transmit to [target] as they are too different from you mentally!</span>")
			return 1
		else
			var/turf/T = get_turf(target)
			for (var/mob/living/carbon/C in T.contents)
				recipient = C
				break

		if (!recipient)
			boutput(owner, "<span class='alert'>There's nobody there to transmit a message to.</span>")
			return 1

		if (recipient.bioHolder.HasEffect("psy_resist"))
			boutput(owner, "<span class='alert'>You can't contact [recipient.name]'s mind at all!</span>")
			return 1

		if(!recipient.client || recipient.stat)
			boutput(recipient, "<span class='alert'>You can't seem to get through to [recipient.name] mentally.</span>")
			return 1

		var/msg = copytext( adminscrub(input(usr, "Message to [recipient.name]:","Telepathy") as text), 1, MAX_MESSAGE_LEN)
		if (!msg)
			return 1
		phrase_log.log_phrase("telepathy", msg)

		var/psyname = "A psychic voice"
		if (recipient.bioHolder.HasOneOfTheseEffects("telepathy","empath"))
			psyname = "[owner.name]"

		boutput(recipient, "<span style='color: #BD33D9'><b>[psyname]</b> echoes, \"<i>[msg]</i>\"</span>")
		boutput(owner, "<span style='color: #BD33D9'>You echo \"<i>[msg]</i>\" to <b>[recipient.name]</b>.</span>")

		logTheThing(LOG_TELEPATHY, owner, "TELEPATHY to [constructTarget(recipient,"telepathy")]: [msg]")

		return

	cast_misfire(atom/target)
		if (..())
			return 1

		var/mob/living/carbon/recipient = null
		if (iscarbon(target))
			recipient = target
		else if (ismob(target) && !iscarbon(target))
			boutput(owner, "<span class='alert'>You can't transmit to [target] as they are too different from you mentally!</span>")
			return 1
		else
			var/turf/T = get_turf(target)
			for (var/mob/living/carbon/C in T.contents)
				recipient = C
				break

		if (!recipient)
			boutput(owner, "<span class='alert'>There's nobody there to transmit a message to.</span>")
			return 1

		if (recipient.bioHolder.HasEffect("psy_resist"))
			boutput(owner, "<span class='alert'>You can't contact [recipient.name]'s mind at all!</span>")
			return 1

		if(!recipient.client || recipient.stat)
			boutput(recipient, "<span class='alert'>You can't seem to get through to [recipient.name] mentally.</span>")
			return 1

		var/msg = copytext( adminscrub(input(usr, "Message to [recipient.name]:","Telepathy") as text), 1, MAX_MESSAGE_LEN)
		if (!msg)
			return 1
		phrase_log.log_phrase("telepathy", msg)
		msg = uppertext(msg)

		owner.visible_message("<span class='alert'><b>[owner]</b> puts their fingers to their temples and stares at [target] really hard.</span>")
		owner.say(msg)

		logTheThing(LOG_TELEPATHY, owner, "TELEPATHY misfire to [constructTarget(recipient,"telepathy")]: [msg]")

		return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/empath
	name = "Empathic Thought"
	desc = "The subject becomes able to read the minds of others for certain information."
	id = "empath"
	msgGain = "You suddenly notice more about others than you did before."
	msgLose = "You no longer feel able to sense intentions."
	probability = 99
	blockCount = 3
	blockGaps = 2
	stability_loss = 5
	ability_path = /datum/targetable/geneticsAbility/empath

/datum/targetable/geneticsAbility/empath
	name = "Mind Reader"
	desc = "Read the minds of others for information."
	icon_state = "empath"
	needs_hands = FALSE
	targeted = 1

	cast(atom/target)
		if (..())
			return 1

		var/mob/living/carbon/read = null
		if (iscarbon(target))
			read = target
		else if (ismob(read) && !iscarbon(target))
			boutput(owner, "<span class='alert'>You can't read the thoughts of [target] as they are too different from you mentally!</span>")
			return 1
		else
			var/turf/T = get_turf(target)
			for (var/mob/living/carbon/C in T.contents)
				read = C
				break

		if (!read)
			boutput(owner, "<span class='alert'>There's nobody there to read the thoughts of.</span>")
			return 1

		if (read.bioHolder.HasEffect("psy_resist"))
			boutput(owner, "<span class='alert'>You can't see into [read.name]'s mind at all!</span>")
			return 1

		if (isdead(read))
			boutput(owner, "<span class='alert'>[read.name] is dead and cannot have their mind read.</span>")
			return
		if (read.health < 0)
			boutput(owner, "<span class='alert'>[read.name] is dying, and their thoughts are too scrambled to read.</span>")
			return

		boutput(usr, "<span class='notice'>Mind Reading of [read.name]:</b></span>")
		var/pain_condition = read.health
		// lower health means more pain
		var/list/randomthoughts = list("what to have for lunch","the future","the past","money",
		"their hair","what to do next","their job","space","amusing things","sad things",
		"annoying things","happy things","something incoherent","something they did wrong")
		var/thoughts = "thinking about [pick(randomthoughts)]"
		if (read.getStatusDuration("burning"))
			pain_condition -= 50
			thoughts = "preoccupied with the fire"
		if (read.getStatusDuration("radiation"))
			pain_condition -= 25

		switch(pain_condition)
			if (81 to INFINITY)
				boutput(owner, "<span class='notice'><b>Condition</b>: [read.name] feels good.</span>")
			if (61 to 80)
				boutput(owner, "<span class='notice'><b>Condition</b>: [read.name] is suffering mild pain.</span>")
			if (41 to 60)
				boutput(owner, "<span class='notice'><b>Condition</b>: [read.name] is suffering significant pain.</span>")
			if (21 to 40)
				boutput(owner, "<span class='notice'><b>Condition</b>: [read.name] is suffering severe pain.</span>")
			else
				boutput(owner, "<span class='notice'><b>Condition</b>: [read.name] is suffering excruciating pain.</span>")
				thoughts = "haunted by their own mortality"

		switch(read.a_intent)
			if (INTENT_HELP)
				boutput(owner, "<span class='notice'><b>Mood</b>: You sense benevolent thoughts from [read.name].</span>")
			if (INTENT_DISARM)
				boutput(owner, "<span class='notice'><b>Mood</b>: You sense cautious thoughts from [read.name].</span>")
			if (INTENT_GRAB)
				boutput(owner, "<span class='notice'><b>Mood</b>: You sense hostile thoughts from [read.name].</span>")
			if (INTENT_HARM)
				boutput(owner, "<span class='notice'><b>Mood</b>: You sense cruel thoughts from [read.name].</span>")
				for(var/mob/living/L in view(7,read))
					if (L == read)
						continue
					thoughts = "thinking about punching [L.name]"
					break
			else
				boutput(owner, "<span class='notice'><b>Mood</b>: You sense strange thoughts from [read.name].</span>")

		if (ishuman(target))
			var/mob/living/carbon/human/H = read
			if (H.pin)
				boutput(owner, "<span class='notice'><b>Numbers</b>: You sense the number [H.pin] is important to [H.name].</span>")
		boutput(owner, "<span class='notice'><b>Thoughts</b>: [read.name] is currently [thoughts].</span>")

		if (read.bioHolder.HasEffect("empath"))
			boutput(read, "<span class='alert'>You sense [owner.name] reading your mind.</span>")
		else if (read.traitHolder.hasTrait("training_chaplain"))
			boutput(read, "<span class='alert'>You sense someone intruding upon your thoughts...</span>")
		return

	cast_misfire(atom/target)
		if (..())
			return 1

		var/mob/living/carbon/read = null
		if (iscarbon(target))
			read = target
		else if (ismob(read) && !iscarbon(target))
			boutput(owner, "<span class='alert'>You can't read the thoughts of [target] as they are too different from you mentally!</span>")
			return 1
		else
			var/turf/T = get_turf(target)
			for (var/mob/living/carbon/C in T.contents)
				read = C
				break

		if (!read)
			boutput(owner, "<span class='alert'>There's nobody there to read the thoughts of.</span>")
			return 1

		if (read.bioHolder.HasEffect("psy_resist"))
			boutput(owner, "<span class='alert'>You can't see into [read.name]'s mind at all!</span>")
			return 1

		if (isdead(read))
			boutput(owner, "<span class='alert'>[read.name] is dead and cannot have their mind read.</span>")
			return
		if (read.health < 0)
			boutput(owner, "<span class='alert'>[read.name] is dying, and their thoughts are too scrambled to read.</span>")
			return

		boutput(read, "<span class='alert'>Somehow, you sense <b>[owner]</b> trying and failing to read your mind!</span>")
		boutput(owner, "<span class='alert'>You are mentally overwhelmed by a huge barrage of worthless data!</span>")
		owner.emote("scream")
		owner.changeStatus("paralysis", 5 SECONDS)
		owner.changeStatus("stunned", 7 SECONDS)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/immolate
	name = "Incendiary Mitochondria"
	desc = "The subject becomes able to convert excess cellular energy into thermal energy."
	id = "immolate"
	msgGain = "You suddenly feel rather hot."
	msgLose = "You no longer feel uncomfortably hot."
	cooldown = 600
	probability = 66
	blockCount = 3
	blockGaps = 2
	stability_loss = 10
	ability_path = /datum/targetable/geneticsAbility/immolate

/datum/targetable/geneticsAbility/immolate
	name = "Immolate"
	desc = "Wreath yourself in burning flames."
	icon_state = "immolate"
	needs_hands = FALSE
	targeted = 0

	cast()
		if (..())
			return 1

		playsound(owner.loc, 'sound/effects/mag_fireballlaunch.ogg', 50, 0)

		if (linked_power.power > 1)
			owner.visible_message("<span class='alert'><b>[owner.name]</b> erupts into a huge column of flames! Holy shit!</span>")
			fireflash_sm(get_turf(owner), 3, 7000, 2000)
		else if (owner.is_heat_resistant())
			owner.show_message("<span class='alert'>Your body emits an odd burnt odor but you somehow cannot bring yourself to heat up. Huh.</span>")
			return
		else
			owner.visible_message("<span class='alert'><b>[owner.name]</b> suddenly bursts into flames!</span>")
			owner.set_burning(100)
		return

	cast_misfire()
		if (..())
			return 1

		playsound(owner.loc, 'sound/effects/bamf.ogg', 50, 0)
		owner.show_message("<span class='alert'>You accidentally expunge all heat from your body. Whoops!</span>")
		owner.bodytemperature = 0

		return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/melt
	name = "Self Biomass Manipulation"
	desc = "The subject becomes able to transform the matter of their cells into a liquid state."
	id = "melt"
	msgGain = "You feel strange and jiggly."
	msgLose = "You feel more solid."
	cooldown = 1200
	probability = 66
	blockCount = 3
	blockGaps = 2
	stability_loss = 5
	ability_path = /datum/targetable/geneticsAbility/melt

/datum/targetable/geneticsAbility/melt
	name = "Dissolve"
	desc = "Transform yourself into a liquid state."
	icon_state = "melt"
	needs_hands = FALSE
	targeted = 0

	cast()
		if (..())
			return TRUE
		if (istype(owner.loc, /obj/dummy/spell_invis)) // stops biomass manipulation and dimension shift from messing with eachother.
			boutput(owner, "<span class='alert'>You can't seem to turn incorporeal here.</span>")
			return TRUE
		if (spell_invisibility(owner, 1, 0, 0, 1) == 1)
			if (!linked_power.safety)
				// If unsynchronized, you don't get to keep anything you have on you.
				// The original version of this power instead gibbed you instantly, which wasn't very fun,
				// and ended up as a newbie trap ("This sounds fun! *dead* oh.")
				// This way it's a nice tradeoff, and you can always just pick things back up
				boutput(owner, "<span class='alert'>Everything you were carrying falls away as you dissolve!</span>")
				owner.unequip_all()

			spell_invisibility(owner, 50)
			playsound(owner.loc, 'sound/effects/mag_phase.ogg', 25, 1, -1)


	cast_misfire()
		if (..())
			return TRUE
		if (istype(owner.loc, /obj/dummy/spell_invis))
			boutput(owner, "<span class='alert'>You can't seem to turn incorporeal here.</span>")
			return TRUE
		// Misfires still transform you, but bad things happen.

		if (spell_invisibility(owner, 1, 0, 0, 1) == 1)
			if (!linked_power.safety && ishuman(owner))
				// If unsynchronized, you drop a random organ. Hope it's not one of the important ones!
				var/list/possible_drops = list("heart", "left_lung","right_lung","left_kidney","right_kidney",
					"liver","spleen","pancreas","stomach","intestines","appendix","butt")
				var/obj/item/organ/O = owner.organHolder.drop_organ(pick(possible_drops))
				if (O)
					boutput(owner, "<span class='alert'>You dissolve... mostly. Oops.</span>")

			else
				// If synchronized, you drop a random item you were carrying.
				// This is a pretty weak downside, but at the same time,
				// to get here you've managed to synchronize it and paid the stability penalty.
				// We can afford to be nice.
				var/obj/item/I = owner.unequip_random()
				if (I)
					boutput(owner, "<span class='alert'>\The [I] you were carrying falls away as you dissolve!</span>")

			spell_invisibility(owner, 50)
			playsound(owner.loc, 'sound/effects/mag_phase.ogg', 25, 1, -1)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/superfart
	name = "High-Pressure Intestines"
	desc = "Vastly increases the gas capacity of the subject's digestive tract."
	id = "superfart"
	msgGain = "You feel bloated and gassy."
	msgLose = "You no longer feel gassy. What a relief!"
	cooldown = 900
	probability = 33
	blockCount = 4
	blockGaps = 3
	stability_loss = 15
	ability_path = /datum/targetable/geneticsAbility/superfart
	var/farting = 0

/datum/targetable/geneticsAbility/superfart
	name = "Superfart"
	desc = "Unleash a gigantic fart!"
	icon_state = "superfart"
	needs_hands = FALSE
	targeted = 0

	cast()
		if (..())
			return 1

		if (!farting_allowed)
			boutput(owner, "<span class='alert'>Farting is disabled.</span>")
			return 1
		var/datum/bioEffect/power/superfart/SF = linked_power

		if (SF.farting)
			boutput(owner, "<span class='alert'>You're already farting! Be patient!</span>")
			return 1

		owner.visible_message("<span class='alert'><b>[owner.name]</b> hunches down and grits their teeth!</span>")
		SF.farting = 1
		var/stun_time = 3 * linked_power.power
		var/fart_range = 6 * linked_power.power
		var/gib_user = 0
		var/throw_speed = 15 * linked_power.power
		var/throw_repeat = 3 * linked_power.power
		var/sound_volume = 50 * linked_power.power
		var/sound_repeat = 1 * linked_power.power
		var/fart_string = " unleashes a [pick("tremendous","gigantic","colossal")] fart!"

		if(linked_power.power > 1 && !linked_power.safety)
			gib_user = 1
			fart_string = "'s body is torn apart like a wet paper bag by [his_or_her(owner)] unbelievably powerful farting!"
			owner.unlock_medal("Shit Fest", 1)

		sleep(3 SECONDS)
		if (can_act(owner))
			if(owner.reagents.has_reagent("anti_fart"))
				owner.visible_message("<span class='alert'><b>[owner.name]</b> swells up. That can't be good.</span>")
				boutput(owner, "<span class='alert'><b>Oh god.</b></span>")
				logTheThing(LOG_COMBAT, owner, "was gibbed by superfarting while containing anti_fart at [log_loc(owner)].")
				indigestion_gib()
				return 1

			owner.visible_message("<span class='alert'><b>[owner.name]</b>[fart_string]</span>")
			while (sound_repeat > 0)
				sound_repeat--
				playsound(owner.loc, 'sound/voice/farts/superfart.ogg', sound_volume, 1, channel=VOLUME_CHANNEL_EMOTE)

			for(var/mob/living/V in range(get_turf(owner),fart_range))
				shake_camera(V,10,64)
				if (V == owner)
					continue
				boutput(V, "<span class='alert'>You are sent flying!</span>")

				V.changeStatus("weakened", stun_time SECONDS)
				// why the hell was this set to 12 christ
				while (throw_repeat > 0)
					throw_repeat--
					step_away(V,get_turf(owner),throw_speed)
			var/toxic = owner.bioHolder.HasEffect("toxic_farts")
			if(toxic)
				var/turf/fart_turf = get_turf(owner)
				fart_turf.fluid_react_single("[toxic > 1 ?"very_":""]toxic_fart", toxic*2, airborne = 1)

			if (owner.getStatusDuration("burning"))
				fireflash(get_turf(owner), 3 * linked_power.power)

			SF.farting = 0
			if (linked_power.power > 1)
				for (var/turf/T in range(owner,6))
					animate_shake(T,5,rand(3,8),rand(3,8))

			// Superfarted on the bible? Off to hell.
			for (var/obj/item/storage/bible/B in owner.loc)
				if(gib_user)
					owner.mind.damned = TRUE
				else
					owner.damn()
				break

			if (gib_user)
				owner.gib()

		else
			boutput(owner, "<span class='alert'>You were interrupted and couldn't fart! Rude!</span>")
			SF.farting = 0
			return 1

		return

	proc/indigestion_gib()
		owner.emote("faint")
		owner.setStatus("weakened", 20 SECONDS)
		owner.make_jittery(50)
		sleep(1 SECOND)
		owner.emote("scream")
		playsound(owner.loc, 'sound/impact_sounds/Flesh_Tear_1.ogg', 100, 1)
		owner.TakeDamage("chest", 25, 0, 0, DAMAGE_BLUNT)
		owner.make_jittery(250)
		sleep(1 SECOND)
		owner.emote("scream")
		playsound(owner.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 100, 1)
		owner.TakeDamage("chest", 25, 0, 0, DAMAGE_BLUNT)
		owner.make_jittery(500)

		var/scream_time = 2
		var/scream_decrement = 0.25

		while(scream_time > 0)
			playsound(owner.loc, pick('sound/impact_sounds/Flesh_Break_1.ogg','sound/impact_sounds/Flesh_Tear_1.ogg','sound/impact_sounds/Flesh_Tear_2.ogg'), 100, 1)
			owner.emote("scream")
			sleep(scream_time SECONDS)
			scream_time -= scream_decrement
		owner.buttgib()
		return


/datum/bioEffect/power/superfart/griff
	name = "Very-High-Pressure Intestines"
	desc = "Immensely increases the gas capacity of the subject's digestive tract to near infinite levels."
	id = "superfartgriff"
	msgGain = "You feel INCREDIBLY bloated and gassy."
	msgLose = "You no longer feel INCREDIBLY gassy. What a relief!"

	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0

	stability_loss = 0
	cooldown = 200

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/eyebeams
	name = "Optic Energizer"
	desc = "Imbues the subject's eyes with the potential to project concentrated thermal energy."
	id = "eyebeams"
	msgGain = "Your eyes ache and burn."
	msgLose = "Your eyes stop aching."
	cooldown = 80
	probability = 33
	blockCount = 3
	blockGaps = 5
	stability_loss = 10
	ability_path = /datum/targetable/geneticsAbility/eyebeams
	var/projectile_path = "/datum/projectile/laser/eyebeams"
	var/stun_mode = 0

/datum/targetable/geneticsAbility/eyebeams
	name = "Eyebeams"
	desc = "Shoot lasers from your eyes."
	icon_state = "eyebeams"
	targeted = TRUE
	target_anything = TRUE
	needs_hands = FALSE

	cast(atom/target)
		if (..())
			return 1

		var/turf/T = get_turf(target)

		var/datum/bioEffect/power/eyebeams/EB = linked_power
		var/projectile_path = ispath(EB.projectile_path) ? EB.projectile_path : text2path(EB.projectile_path)
		if(linked_power.power > 1)
			projectile_path = /datum/projectile/laser
		else if(EB.stun_mode) //used by superhero for nonlethal stun
			projectile_path = /datum/projectile/laser/eyebeams/stun
		if (!ispath(projectile_path))
			projectile_path = /datum/projectile/laser/eyebeams

		owner.visible_message("<span class='alert'><b>[owner.name]</b> shoots eye beams!</span>")
		var/datum/projectile/laser/eyebeams/PJ = new projectile_path
		shoot_projectile_ST(owner, PJ, T)

	cast_misfire(atom/target)
		if (..())
			return 1

		owner.visible_message("<span class='alert'><b>[owner.name]'s</b> eyeballs catch on fire briefly!</span>")
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.take_eye_damage(5)

/datum/projectile/laser/eyebeams
	name = "optic laser"
	icon_state = "eyebeam"
	power = 20
	cost = 20
	sname = "eye laser"
	dissipation_delay = 5
	shot_sound = 'sound/weapons/TaserOLD.ogg'
	color_red = 1
	color_green = 0
	color_blue = 1

/datum/projectile/laser/eyebeams/stun
	ks_ratio = 0

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/adrenaline
	name = "Adrenaline Rush"
	desc = "Enables the user to voluntarily empty glands of stimulants. May be dangerous with repeated use."
	id = "adrenaline"
	probability = 66
	blockCount = 4
	blockGaps = 4
	cooldown = 600
	msgGain = "You feel hype!"
	msgLose = "You don't feel so pumped anymore."
	stability_loss = 15
	ability_path = /datum/targetable/geneticsAbility/adrenaline

/datum/targetable/geneticsAbility/adrenaline
	name = "Adrenaline Rush"
	desc = "Infuse your bloodstream with stimulants."
	icon_state = "adrenaline"
	targeted = FALSE
	needs_hands = FALSE
	can_act_check = FALSE

	cast()
		if (..())
			return 1
		var/multiplier = linked_power.power
		if (owner.reagents)
			boutput(owner, "<span class='notice'>You get pumped up!</span>")
			owner.emote("scream")
			owner.reagents.add_reagent("epinephrine",20 * multiplier)
			owner.reagents.add_reagent("salicylic_acid",20 * multiplier)
			if(linked_power.safety)
				owner.reagents.add_reagent("methamphetamine",max(0,20 - owner.reagents.get_reagent_amount("methamphetamine")))
				owner.reagents.add_reagent("energydrink",max(0,5 - owner.reagents.get_reagent_amount("energydrink")))
			else
				owner.reagents.add_reagent("methamphetamine",20 * multiplier)
				owner.reagents.add_reagent("energydrink",5 * multiplier)

	cast_misfire()
		if (..())
			return 1
		var/multiplier = 4
		if (owner.reagents)
			boutput(owner, "<span class='alert'>You get pumped up! ...maybe a bit too pumped up! You feel kinda sick...</span>")
			owner.emote("scream")
			owner.reagents.add_reagent("epinephrine",20 * multiplier)
			owner.reagents.add_reagent("salicylic_acid",20 * multiplier)
			if(linked_power.safety)
				owner.reagents.add_reagent("methamphetamine",max(0,20 - owner.reagents.get_reagent_amount("methamphetamine")))
				owner.reagents.add_reagent("energydrink",max(0,5 - owner.reagents.get_reagent_amount("energydrink")))
			else
				owner.reagents.add_reagent("methamphetamine",20 * multiplier)
				owner.reagents.add_reagent("energydrink",5 * multiplier)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/midas
	name = "Midas Touch"
	desc = "Allows the subject to transmute materials at will."
	id = "midas"
	msgGain = "Your fingers sparkle and gleam."
	msgLose = "Your fingers return to normal."
	cooldown = 300
	probability = 99
	blockCount = 2
	blockGaps = 4
	stability_loss = 5
	ability_path = /datum/targetable/geneticsAbility/midas
	var/transmute_material = "gold"

/datum/targetable/geneticsAbility/midas
	name = "Midas Touch"
	desc = "Transmute an object to gold by touching it."
	icon_state = "midas"
	targeted = FALSE

	cast(atom/target)
		if (..())
			return 1
		if(linked_power.using)
			return 1

		var/obj/the_object = target

		if(!target)
			var/base_path = /obj/item/
			if (linked_power.power > 1)
				base_path = /obj/

			var/list/items = get_filtered_atoms_in_touch_range(owner,base_path)
			if (!items.len)
				boutput(usr, "/red You can't find anything nearby to touch.")
				return 1

			linked_power.using = 1
			the_object = input("Which item do you want to transmute?","Midas Touch") as null|obj in items
			if (!the_object)
				last_cast = 0
				linked_power.using = 0
				return 1

		if(isitem(the_object))
			var/obj/item/the_item = the_object
			if(the_item.amount > 1)
				var/obj/item/split_item = the_item.split_stack(1)
				split_item.set_loc(get_turf(the_item))
				the_object = split_item

		if (!linked_power)
			owner.visible_message("[owner] touches [the_object].")
		else
			if (istype(linked_power,/datum/bioEffect/power/midas))
				var/datum/bioEffect/power/midas/linked = linked_power
				owner.visible_message("<span class='alert'>[owner] touches [the_object], turning it to [linked.transmute_material]!</span>")
				the_object.setMaterial(getMaterial(linked.transmute_material))
			else
				owner.visible_message("<span class='alert'>[owner] touches [the_object], turning it to gold!</span>")
				the_object.setMaterial(getMaterial("gold"), copy = FALSE)
		linked_power.using = 0
		return

	cast_misfire()
		if (..())
			return 1
		if(linked_power.using)
			return 1

		var/base_path = /obj/item/
		if (linked_power.power > 1)
			base_path = /obj/

		var/list/items = get_filtered_atoms_in_touch_range(owner,base_path)
		if (!items.len)
			boutput(usr, "/red You can't find anything nearby to touch.")
			return 1

		linked_power.using = 1
		var/obj/the_object = input("Which item do you want to transmute?","Midas Touch") as null|obj in items
		if (!the_object)
			last_cast = 0
			linked_power.using = 0
			return 1

		if(isitem(the_object))
			var/obj/item/the_item = the_object
			if(the_item.amount > 1)
				var/obj/item/split_item = the_item.split_stack(1)
				split_item.set_loc(get_turf(the_item))
				the_object = split_item

		if (!linked_power)
			owner.visible_message("[owner] touches [the_object].")
		else
			owner.visible_message("<span class='alert'>[owner] touches [the_object], turning it to flesh!</span>")
			the_object.setMaterial(getMaterial("flesh"), copy = FALSE)
		linked_power.using = 0
		return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// COMBINATION-ONLY EFFECTS BELOW

/datum/bioEffect/power/healing_touch
	name = "Healing Touch"
	desc = "Allows the subject to heal the wounds of others with a touch."
	id = "healing_touch"
	msgGain = "Your hands radiate a comforting aura."
	msgLose = "The aura around your hands dissipates."
	cooldown = 900
	occur_in_genepools = 0
	stability_loss = 10
	ability_path = /datum/targetable/geneticsAbility/healing_touch

/datum/targetable/geneticsAbility/healing_touch
	name = "Healing Touch"
	desc = "Soothe the wounds of others."
	icon_state = "healingtouch"
	targeted = TRUE

	cast(atom/target)
		if (..())
			return 1

		if (BOUNDS_DIST(target, owner) > 0 && !owner.bioHolder.HasEffect("telekinesis"))
			boutput(usr, "<span class='alert'>You need to be closer to do that.</span>")
			return 1

		if (!iscarbon(target))
			boutput(usr, "<span class='alert'>This power won't work on that!</span>")
			return 1

		if (target == owner)
			boutput(usr, "<span class='alert'>This power doesn't work when you touch yourself. Weirdo.</span>")
			return 1

		var/mob/living/carbon/C = target
		owner.visible_message("<span class='alert'><b>[owner] touches [C], enveloping them in a soft glow!</b></span>")
		boutput(C, "<span class='notice'>You feel your pain fading away.</span>")
		var/amount_to_heal = 25 * linked_power.power
		C.HealDamage("All", amount_to_heal, amount_to_heal)
		C.take_toxin_damage(0 - amount_to_heal)
		C.take_oxygen_deprivation(0 - amount_to_heal)
		C.take_brain_damage(0 - amount_to_heal)
		return

	cast_misfire(atom/target)
		if (..())
			return 1

		if (BOUNDS_DIST(target, owner) > 0 && !owner.bioHolder.HasEffect("telekinesis"))
			boutput(usr, "<span class='alert'>You need to be closer to do that.</span>")
			return 1

		if (!iscarbon(target))
			boutput(usr, "<span class='alert'>This power won't work on that!</span>")
			return 1

		if (target == owner)
			boutput(usr, "<span class='alert'>This power doesn't work when you touch yourself. Weirdo.</span>")
			return 1

		var/mob/living/carbon/C = target
		owner.visible_message("<span class='alert'><b>[owner] touches [C], enveloping them in a bright glow!</b></span>")
		boutput(C, "<span class='notice'>Your pain fades away rapidly.</span>")
		boutput(owner, "<span class='alert'>You use too much life energy and hurt yourself!</span>")
		var/amount_to_heal = 25 * linked_power.power
		C.HealDamage("All", amount_to_heal, amount_to_heal)
		owner.TakeDamage("All", amount_to_heal, amount_to_heal)
		C.take_toxin_damage(0 - amount_to_heal)
		owner.take_toxin_damage(amount_to_heal)
		C.take_oxygen_deprivation(0 - amount_to_heal)
		owner.take_oxygen_deprivation(amount_to_heal)
		C.take_brain_damage(0 - amount_to_heal)
		owner.take_brain_damage(amount_to_heal)
		return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/dimension_shift
	// cant get the scary shit to work so tOt for now
	name = "Dimension Shift"
	desc = "Phase out and hide in another dimension."
	id = "dimension_shift"
	msgGain = "You can see a faint blue light."
	msgLose = "The blue light fades away."
	cooldown = 900
	occur_in_genepools = 0
	stability_loss = 15
	ability_path = /datum/targetable/geneticsAbility/dimension_shift
	var/active = 0
	var/processing = 0
	var/atom/last_loc = null
	acceptable_in_mutini = 0

	OnRemove()
		..()
		if(active)
			processing = TRUE
			var/obj/dummy/spell_invis/invis_object
			if (istype(owner.loc,/obj/dummy/spell_invis/))
				invis_object = owner.loc
			owner.set_loc(last_loc)
			if (invis_object)
				qdel(invis_object)
			last_loc = null

			owner.visible_message("<span class='alert'><b>[owner] appears in a burst of blue light!</b></span>")
			playsound(owner.loc, 'sound/effects/ghost2.ogg', 50, 0)
			SPAWN(0.7 SECONDS)
				animate(owner, alpha = 255, time = 5, easing = LINEAR_EASING)
				animate(color = "#FFFFFF", time = 5, easing = LINEAR_EASING)
				active = 0
			processing = 0
		return

/datum/targetable/geneticsAbility/dimension_shift
	name = "Dimension Shift"
	desc = "Hide in another dimension to avoid hazards."
	icon_state = "dimensionshift"
	targeted = FALSE
	cooldown = 90 SECONDS
	has_misfire = FALSE

	cast()
		if (..())
			return TRUE

		if (!istype(linked_power,/datum/bioEffect/power/dimension_shift))
			return TRUE
		var/datum/bioEffect/power/dimension_shift/P = linked_power
		if (!istype(owner.loc,/turf/) && !istype(owner.loc,/obj/dummy/spell_invis/))
			boutput(owner, "<span class='alert'>That won't work here.</span>")
			return TRUE
		if (P.processing)
			return TRUE

		P.processing = TRUE

		if (!P.active)
			if (istype(owner.loc, /obj/dummy/spell_invis/)) // check for if theres a spell_invis object we havent placed (from biomass manipulation)
				// before this, dimension shift and biomass manipulation resulted in strange behavior, including being sent to nullspace.
				boutput(owner, "<span class='alert'>That won't work here.</span>")
				P.processing = FALSE
				return TRUE
			P.active = TRUE
			P.last_loc = get_turf(owner)
			owner.canmove = 0
			owner.restrain_time = TIME + 0.7 SECONDS
			owner.visible_message("<span class='alert'><b>[owner] vanishes in a burst of blue light!</b></span>")
			playsound(owner.loc, 'sound/effects/ghost2.ogg', 50, 0)
			animate(owner, color = "#0000FF", time = 5, easing = LINEAR_EASING)
			animate(alpha = 0, time = 5, easing = LINEAR_EASING)
			SPAWN(0.7 SECONDS)
				owner.canmove = 1
				owner.restrain_time = 0
				var/obj/dummy/spell_invis/invis_object = new /obj/dummy/spell_invis(get_turf(owner))
				invis_object.canmove = 0
				owner.set_loc(invis_object)
			P.processing = FALSE
			return TRUE
		else
			var/obj/dummy/spell_invis/invis_object
			if (istype(owner.loc,/obj/dummy/spell_invis/))
				invis_object = owner.loc
			if (isnull(P.last_loc))
				owner.set_loc(get_turf(owner)) // better safe than sorry.
			else // now it wont nullspace you if things go wrong.
				owner.set_loc(P.last_loc)
			if (invis_object)
				qdel(invis_object)
			P.last_loc = null

			owner.visible_message("<span class='alert'><b>[owner] appears in a burst of blue light!</b></span>")
			playsound(owner.loc, 'sound/effects/ghost2.ogg', 50, 0)
			SPAWN(0.7 SECONDS)
				animate(owner, alpha = 255, time = 5, easing = LINEAR_EASING)
				animate(color = "#FFFFFF", time = 5, easing = LINEAR_EASING)
				P.active = 0
			P.processing = 0

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/photokinesis
	name = "Photokinesis"
	desc = "Allows the subject to create a source of light."
	id = "photokinesis"
	msgGain = "Everything seems too dark!"
	msgLose = "It's too bright!"
	cooldown = 600
	occur_in_genepools = 0
	stability_loss = 0
	ability_path = /datum/targetable/geneticsAbility/photokinesis
	var/red = 0
	var/green = 0
	var/blue = 0

	New()
		..()
		red = rand(5,10) / 10
		green = rand(5,10) / 10
		blue = rand(5,10) / 10

/datum/targetable/geneticsAbility/photokinesis
	name = "Photokinesis"
	desc = "Create a strong source of light."
	icon_state = "photokinesis"
	targeted = TRUE
	has_misfire = FALSE

	cast(atom/target)
		if (..())
			return 1
		if (!istype(linked_power,/datum/bioEffect/power/photokinesis/))
			return 1
		var/datum/bioEffect/power/photokinesis/P = linked_power

		var/turf/T = get_turf(target)
		owner.visible_message("<span class='alert'><b>[owner]</b> raises [his_or_her(owner)] hands into the air!</span>")
		playsound(owner.loc, 'sound/voice/heavenly.ogg', 50, 0)
		var/strength = 1 + 6 * linked_power.power
		var/time = 300 * linked_power.power
		new /obj/photokinesis_light(T,P.red,P.green,P.blue,strength,time)

/obj/photokinesis_light
	name = ""
	desc = ""
	density = 0
	anchored = 1
	mouse_opacity = 0
	icon = null
	icon_state = null
	var/datum/light/light

	New(var/loc,var/color_R,var/color_G,var/color_B,var/strength = 7,var/time = 300)
		..()
		light = new /datum/light/point
		light.set_brightness(strength / 7)
		light.set_color(color_R, color_G, color_B)
		light.attach(src)
		light.enable()

		if (isnum(time))
			SPAWN(time)
				qdel(src)

	disposing()
		..()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/erebokinesis
	name = "Erebokinesis"
	desc = "Allows the subject to snuff out all light in an area."
	id = "erebokinesis"
	msgGain = "Everything seems too bright!"
	msgLose = "It's too dark!"
	cooldown = 600
	occur_in_genepools = 0
	stability_loss = 15
	ability_path = /datum/targetable/geneticsAbility/erebokinesis
	var/time = 0
	var/size = 0

	New()
		..()
		size = rand(4, 6)
		time = rand(100, 300)

/datum/targetable/geneticsAbility/erebokinesis
	name = "Erebokinesis"
	desc = "Create a field of darkness."
	icon_state = "erebokinesis"
	targeted = TRUE
	has_misfire = FALSE

	cast(atom/target)
		if (..())
			return 1
		if (!istype(linked_power,/datum/bioEffect/power/erebokinesis/))
			return 1
		var/datum/bioEffect/power/erebokinesis/P = linked_power
		var/field_size = P.size
		var/field_time = P.time
		field_size *= P.power
		field_time *= P.power

		var/turf/T = get_turf(target)
		owner.visible_message("<span class='alert'><b>[owner]</b> raises [his_or_her(owner)] hands into the air!</span>")
		playsound(owner.loc, 'sound/voice/chanting.ogg', 50, 0)
		new /obj/overlay/darkness_field(T, field_time, radius = 0.5 + field_size, max_alpha = 250)
		new /obj/overlay/darkness_field{plane = PLANE_SELFILLUM}(T, field_time, radius = 0.5 + field_size, max_alpha = 250)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/fire_breath
	name = "Fire Breath"
	desc = "Allows the subject to exhale fire."
	id = "fire_breath"
	msgGain = "Your throat is burning!"
	msgLose = "Your throat feels a lot better now."
	cooldown = 600
	occur_in_genepools = 0
	stability_loss = 10
	ability_path = /datum/targetable/geneticsAbility/fire_breath
	var/temperature = 1200
	var/range = 4

/datum/targetable/geneticsAbility/fire_breath
	name = "Fire Breath"
	desc = "Huff and puff, and burn their house down!"
	icon_state = "firebreath"
	targeted = TRUE

	cast(atom/target)
		if (..())
			return 1

		var/turf/T = get_turf(target)
		var/list/affected_turfs = getline(owner, T)
		var/datum/bioEffect/power/fire_breath/FB = linked_power
		var/range = FB.range * FB.power
		var/temp = FB.temperature * FB.power ** 2
		owner.visible_message("<span class='alert'><b>[owner] breathes fire!</b></span>")
		playsound(owner.loc, 'sound/effects/mag_fireballlaunch.ogg', 50, 0)
		var/turf/currentturf
		var/turf/previousturf
		for(var/turf/F in affected_turfs)
			previousturf = currentturf
			currentturf = F
			if(currentturf.density || istype(currentturf, /turf/space))
				break
			if(previousturf && LinkBlocked(previousturf, currentturf))
				break
			if (F == get_turf(owner))
				continue
			if (GET_DIST(owner,F) > range)
				continue
			tfireflash(F,0.5,temp)

	cast_misfire(atom/target)
		if (..())
			return 1

		owner.visible_message("<span class='alert'><b>[owner] manages to set themselves on fire!</b></span>")
		playsound(owner.loc, 'sound/effects/mag_fireballlaunch.ogg', 50, 0)
		owner.set_burning(100)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/brown_note
	name = "Brown Note"
	desc = "Allows the subject to emit noises that can cause involuntary flatus in others."
	id = "brown_note"
	msgGain = "You feel mischievous!"
	msgLose = "You want to behave yourself again."
	cooldown = 150
	blockCount = 1
	blockGaps = 3
	stability_loss = 15
	ability_path = /datum/targetable/geneticsAbility/brown_note

/datum/targetable/geneticsAbility/brown_note
	name = "Brown Note"
	desc = "Mess with others using the power of sound!"
	icon_state = "brownnote"
	needs_hands = FALSE
	targeted = FALSE

	cast()
		if (..())
			return 1
		owner.visible_message("<span class='alert'><b>[owner.name] makes a weird noise!</b></span>")
		playsound(owner.loc, 'sound/musical_instruments/WeirdHorn_0.ogg', 50, 0)
		var/count = 0
		for (var/mob/living/L in range(7,owner))
			if (L.hearing_check(1))
				if(count++ > (4 + src.linked_power.power * 3)) break
				if(locate(/obj/item/storage/bible) in get_turf(L))
					owner.visible_message("<span class='alert'><b>A mysterious force smites [owner.name] for inciting blasphemy!</b></span>")
					owner.gib()
				else
					L.emote("fart")

	cast_misfire()
		if (..())
			return 1
		owner.visible_message("<span class='alert'><b>[owner.name] makes a really weird noise!</b></span>")
		playsound(owner.loc, pick(soundCache), 50, 0)


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/telekinesis_drag
	name = "Telekinetic Pull"
	desc = "Allows the subject to influence physical objects through utilizing latent powers in their mind."
	id = "telekinesis_drag"
	effectType = EFFECT_TYPE_POWER
	probability = 8
	blockCount = 5
	blockGaps = 5
	reclaim_mats = 40
	msgGain = "You feel your consciousness expand outwards."
	msgLose = "Your conciousness closes inwards."
	stability_loss = 10
	ability_path = /datum/targetable/geneticsAbility/telekinesis

	OnMobDraw()
		if (disposed)
			return
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "telekinesishead", layer = MOB_LAYER)
		return

	OnAdd()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.set_body_icon_dirty()

	OnRemove()
		..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.set_body_icon_dirty()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/telekinesis
	name = "Telekinesis"
	desc = "Allows the subject to influence physical objects through utilizing latent powers in their mind."
	id = "telekinesis_command"
	effectType = EFFECT_TYPE_POWER
	probability = 8
	blockCount = 5
	blockGaps = 5
	reclaim_mats = 40
	msgGain = "You feel your consciousness expand outwards."
	msgLose = "Your conciousness closes inwards."
	stability_loss = 30
	occur_in_genepools = 0
	ability_path = /datum/targetable/geneticsAbility/telekinesis

/datum/targetable/geneticsAbility/telekinesis
	name = "Telekinetic Throw"
	icon_state = "tk"
	desc = "Command a few objects to hurl themselves at the target location."
	targeted = TRUE
	target_anything = TRUE
	needs_hands = FALSE
	cooldown = 20 SECONDS

	cast(atom/T)
		var/list/thrown = list()
		var/current_prob = 100
		var/modifier = 0.4

		modifier *= linked_power.power

		owner.visible_message("<span class='alert'><b>[owner.name]</b> makes a gesture at [T.name]!</span>")

		for (var/obj/O in view(7, owner))
			if (!O.anchored && isturf(O.loc))
				if (prob(current_prob))
					current_prob *= modifier // very steep. probably grabs 3 or 4 objects per cast -- much less effective than revenant command
					thrown += O
					animate_float(O)
		SPAWN(1 SECOND)
			for (var/obj/O in thrown)
				O.throw_at(T, 32, 2)

		return 0

	cast_misfire(atom/T)
		var/list/thrown = list()
		var/current_prob = 100
		var/modifier = 0.4

		modifier *= linked_power.power

		owner.visible_message("<span class='alert'><b>[owner.name]</b> makes a gesture at [T.name]!</span>")

		for (var/obj/O in view(7, owner))
			if (!O.anchored && isturf(O.loc))
				if (prob(current_prob))
					current_prob *= modifier // very steep. probably grabs 3 or 4 objects per cast -- much less effective than revenant command
					thrown += O
					animate_float(O)
		SPAWN(1 SECOND)
			for (var/obj/O in thrown)
				O.throw_at(owner, 32, 2)

		return 0

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/darkcloak
	name = "Cloak of Darkness"
	desc = "Enables the subject to bend low levels of light around themselves, creating a cloaking effect."
	id = "cloak_of_darkness"
	effectType = EFFECT_TYPE_POWER
	isBad = 0
	probability = 33
	blockGaps = 3
	blockCount = 3
	msgGain = "You begin to fade into the shadows."
	msgLose = "You become fully visible."
	lockProb = 40
	lockedGaps = 1
	lockedDiff = 3
	lockedChars = list("G","C","A","T")
	lockedTries = 8
	stability_loss = 15
	cooldown = 0
	var/active = 0
	ability_path = /datum/targetable/geneticsAbility/darkcloak

	proc/cloak_decloak(var/which_way = 1)
		if (!src.owner || !isliving(src.owner))
			return

		var/mob/living/L = owner
		if (which_way == 1)
			APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_INVISIBILITY, src, INVIS_INFRA)
			L.UpdateOverlays(overlay_image, id)
		else
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_INVISIBILITY, src)
			L.UpdateOverlays(null, id)

	OnAdd()
		active = 0
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
			overlay_image.color = "#333333"
		..()
		owner.UpdateOverlays(null, id)

	OnRemove()
		..()
		src.cloak_decloak(0)
		return

	OnLife(var/mult)
		if(..()) return
		if (isliving(owner))
			var/mob/living/L = owner
			var/turf/T = get_turf(L)

			if (T && isturf(T))
				var/area/A = get_area(T)
				if (istype(T, /turf/space) || (A && (istype(A, /area/shuttle/) || istype(A, /area/shuttle_transit_space) || A.name == "Space" || A.name == "Ocean")))
					src.cloak_decloak(2)

				else
					if (T.RL_GetBrightness() < 0.2 && can_act(owner) && src.active)
						src.cloak_decloak(1)
					else
						src.cloak_decloak(2)
			else
				src.cloak_decloak(2)
		return

/datum/targetable/geneticsAbility/darkcloak
	name = "Cloak of Darkness"
	icon_state = "darkcloak"
	desc = "Activate or deactivate your cloak of darkness."
	targeted = FALSE
	cooldown = 0
	can_act_check = FALSE
	has_misfire = FALSE

	cast(atom/T)
		var/datum/bioEffect/power/darkcloak/DC = linked_power
		if (DC.active)
			boutput(usr, "You stop using your cloak of darkness.")
			DC.active = 0
		else
			boutput(usr, "You start using your cloak of darkness.")
			DC.active = 1
		return 0

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/chameleon
	name = "Chameleon"
	desc = "The subject becomes able to subtly alter light patterns to become invisible, as long as they remain still."
	id = "chameleon"
	effectType = EFFECT_TYPE_POWER
	probability = 33
	blockCount = 3
	blockGaps = 3
	msgGain = "You feel one with your surroundings."
	msgLose = "You feel oddly exposed."
	lockProb = 40
	lockedGaps = 1
	lockedDiff = 3
	lockedChars = list("G","C","A","T")
	lockedTries = 8
	stability_loss = 15
	cooldown = 0
	var/last_moved = 0
	var/active = 0
	ability_path = /datum/targetable/geneticsAbility/chameleon

	OnAdd()
		active = 0
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "aurapulse", layer = MOB_LIMB_LAYER)
		..()
		owner.UpdateOverlays(null, id)

	OnRemove()
		..()
		if (isliving(owner))
			var/mob/living/L = owner
			L.UpdateOverlays(null, id)
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_INVISIBILITY, src)
		if (src.active)
			src.UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_ATTACKED_PRE))
		return

	OnLife(var/mult)
		if(..()) return
		if(!src.active) return
		if(isliving(owner))
			var/mob/living/L = owner
			if (TIME - last_moved >= 3 SECONDS && can_act(owner))
				L.UpdateOverlays(overlay_image, id)
				APPLY_ATOM_PROPERTY(src.owner, PROP_MOB_INVISIBILITY, src, INVIS_INFRA)

	proc/decloak()
		if(isliving(owner))
			var/mob/living/L = owner
			last_moved = TIME
			L.UpdateOverlays(null, id)
			REMOVE_ATOM_PROPERTY(src.owner, PROP_MOB_INVISIBILITY, src)

/datum/targetable/geneticsAbility/chameleon
	name = "Chameleon"
	icon_state = "chameleon"
	desc = "Activate or deactivate your chameleon cloak."
	targeted = FALSE
	cooldown = FALSE
	can_act_check = FALSE
	has_misfire = FALSE

	cast(atom/T)
		var/datum/bioEffect/power/chameleon/CH = linked_power
		if (CH.active)
			boutput(usr, "You stop using your chameleon cloaking.")
			CH.active = 0
			CH.UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_ATTACKED_PRE))
			CH.decloak()
		else
			boutput(usr, "You start using your chameleon cloaking.")
			CH.last_moved = TIME
			CH.active = 1
			CH.RegisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_ATTACKED_PRE), /datum/bioEffect/power/chameleon/proc/decloak)
		return 0

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/bigpuke
	name = "Mass Emesis"
	desc = "Allows the subject to expel chemicals via the mouth."
	id = "bigpuke"
	msgGain = "You feel sick."
	msgLose = "You feel much better!"
	cooldown = 30 SECONDS
	occur_in_genepools = FALSE
	stability_loss = 10
	ability_path = /datum/targetable/geneticsAbility/bigpuke
	var/range = 3

/datum/targetable/geneticsAbility/bigpuke
	name = "Mass Emesis"
	desc = "BLAAAAAAAARFGHHHHHGHH"
	icon_state = "bigpuke"
	targeted = TRUE
	has_misfire = FALSE
	needs_hands = FALSE
	var/puke_reagents = list("vomit" = 20)

	cast(atom/target)
		if (..())
			return 1

		var/turf/T = get_turf(target)
		var/list/line_turfs = getline(owner, T)
		var/list/affected_turfs = list()
		var/datum/bioEffect/power/bigpuke/BP = linked_power
		var/range = BP.range
		range *= BP.power
		owner.visible_message("<span class='alert'><b>[owner] horfs up a huge stream of puke!</b></span>")
		logTheThing(LOG_COMBAT, owner, "power-pukes [log_reagents(owner)] at [log_loc(owner)].")
		playsound(owner.loc, 'sound/misc/meat_plop.ogg', 50, 0)
		for (var/reagent_id in puke_reagents)
			owner.reagents.add_reagent(reagent_id, puke_reagents[reagent_id])
		var/turf/currentturf
		var/turf/previousturf
		for(var/turf/F in line_turfs)
			previousturf = currentturf
			currentturf = F
			if(currentturf.density || istype(currentturf, /turf/space))
				break
			if(previousturf && LinkBlocked(previousturf, currentturf))
				break
			if (F == get_turf(owner))
				continue
			if (GET_DIST(owner,F) > range)
				continue
			affected_turfs += F
		for(var/turf/F in affected_turfs)
			owner.reagents.reaction(F,TOUCH, owner.reagents.total_volume/length(affected_turfs))
			for(var/mob/living/L in F.contents)
				owner.reagents.reaction(L,TOUCH, owner.reagents.total_volume/length(affected_turfs))
			for(var/obj/O in F.contents)
				owner.reagents.reaction(O,TOUCH, owner.reagents.total_volume/length(affected_turfs))
		owner.reagents.clear_reagents()
		SEND_SIGNAL(owner, COMSIG_MOB_VOMIT, 10)
		return 0

/datum/bioEffect/power/bigpuke/acidpuke
	name = "Acidic Mass Emesis"
	id = "acid_bigpuke"
	ability_path = /datum/targetable/geneticsAbility/bigpuke/acid
	cooldown = 35 SECONDS

/datum/targetable/geneticsAbility/bigpuke/acid
	name = "Acidic Mass Emesis"
	puke_reagents = list("vomit" = 20, "gvomit" = 20, "pacid" = 10, "radium" = 5)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/bioEffect/power/ink
	name = "Ink Glands"
	desc = "Allows the subject to expel modified melanin."
	id = "inkglands"
	msgGain = "You feel artistic."
	msgLose = "You don't really feel artistic anymore."
	cooldown = 0
	occur_in_genepools = 0
	stability_loss = 2
	ability_path = /datum/targetable/geneticsAbility/ink
	var/color = "#888888"

	New()
		..()
		color = random_color()

/datum/targetable/geneticsAbility/ink
	name = "Ink Glands"
	desc = "Spray colorful ink onto an object."
	icon_state = "ink"
	targeted = FALSE
	has_misfire = FALSE
	needs_hands = FALSE

	cast(atom/target)
		if (..())
			return 1

		var/obj/the_object = target

		if(!the_object)
			var/base_path = /obj
			var/list/items = get_filtered_atoms_in_touch_range(owner,base_path)
			if (!items.len)
				boutput(usr, "/red You can't find anything nearby to spray ink on.")
				return 1

			the_object = input("Which item do you want to color?","Ink Glands") as null|obj in items
			if (!the_object)
				last_cast = 0
				return 1

		var/datum/bioEffect/power/ink/I = linked_power
		if (!linked_power)
			owner.visible_message("[owner] spits on [the_object]. Gross.")
		else
			owner.visible_message("<span class='alert'>[owner] sprays ink onto [the_object]!</span>")
			the_object.color = I.color
		return 0

/datum/bioEffect/power/shoot_limb
	name = "Vestigal Ballistics"
	desc = "Allows the subject to expel one of their limbs with considerable force."
	id = "shoot_limb"
	msgGain = "You feel intense pressure in your hip and shoulder joints."
	msgLose = "You joints feel much better!"
	cooldown = 600
	occur_in_genepools = 1
	probability = 10

	isBad = 1
	stability_loss = -15
	ability_path = /datum/targetable/geneticsAbility/shoot_limb
	var/count = 0
	var/const/ticks_to_explode = 200
	var/datum/targetable/geneticsAbility/shoot_limb/AB = null
	var/stun_mode = 0 // used by discount superhero

	OnLife(var/mult)
		..()

		if (count < ticks_to_explode)
			count += mult
			return
		else
			count = 0

		if (!src.safety && prob(70))



			if (ability)
				//Do I really even need this? I'm just putting it there in case the random turf is null. Which should never happen.
				var/do_count = 0
				do
					var/turf/T = locate(owner.x + rand(-3/2,3+2), owner.y+rand(-3/2,3/2), 1)
					if (T)
						if (ability.cast(T))
							return //no limbs left, no text!!!
						boutput(owner, "<span class='alert'>The pressure in one of your joints built up too high! One of your limbs flew off!</span>")
						owner.changeStatus("weakened", 4 SECONDS)
						return
				while (do_count < 5)


/datum/targetable/geneticsAbility/shoot_limb
	name = "Vestigal Ballistics"
	desc = "OOOOWWWWWW!!!!!!!!"
	icon_state = "shoot_limb"
	targeted = TRUE
	needs_hands = FALSE //hehe
	var/range = 9
	var/throw_power = 1
	var/limb_force = 20

	proc/hit_callback(var/datum/thrown_thing/thr)
		for(var/mob/living/carbon/hit in get_turf(thr.thing))
			hit.changeStatus("weakened", 5 SECONDS)
			hit.force_laydown_standup()
			break
		return 0

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			var/obj/item/parts/thrown_limb = null
			var/datum/bioEffect/power/shoot_limb/SL = linked_power

			if (H.has_limb("l_arm"))
				thrown_limb = H.limbs.l_arm.remove(0)
			else if (H.has_limb("r_leg"))
				thrown_limb = H.limbs.r_leg.remove(0)
			else if (H.has_limb("l_leg"))
				thrown_limb = H.limbs.l_leg.remove(0)
			else if (H.has_limb("r_arm"))
				thrown_limb = H.limbs.r_arm.remove(0)
			else
				return 1
			SPAWN(1 DECI SECOND)
				if (istype(thrown_limb))
					//double power if the ability is empowered (doesn't really do anything, but w/e)
					var/tmp_force = thrown_limb.throwforce
					thrown_limb.throwforce = limb_force* (throw_power+1)	//double damage if empowered
					var/callback = (SL?.stun_mode) ? /datum/targetable/geneticsAbility/shoot_limb/proc/hit_callback : null
					thrown_limb.throw_at(target, range, throw_power * (linked_power.power), end_throw_callback=callback)
					//without snychronizer, you take damage and bleed on usage of the power
					if (!linked_power.safety)
						new thrown_limb.streak_decal(owner.loc)
						var/damage = rand(5,15)
						random_brute_damage(H, damage)
						take_bleeding_damage(H, null, damage)
						if(prob(60)) owner.emote("scream")

						//reset the time until the ability spontaniously fires
						var/datum/bioEffect/power/shoot_limb/pwr = linked_power
						if (istype(pwr))
							pwr.count = 0

					owner.visible_message("<span class='alert'><b>[thrown_limb][linked_power.power > 1 ? " violently " : " "]bursts off of its socket and flies towards [target]!</b></span>")
					logTheThing(LOG_COMBAT, owner, "shoot_limb [!linked_power.safety ? "Accidently" : ""] at [ismob(target)].")
					SPAWN(1 SECOND)
						if (thrown_limb)
							thrown_limb.throwforce = tmp_force

////////////////
// Admin Only //
////////////////

/datum/bioEffect/power/fade_out
	name = "Fading"
	desc = "Allows the subject to become visible or invisible at will."
	id = "fade"
	cooldown = 0
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	ability_path = /datum/targetable/geneticsAbility/fade

/datum/targetable/geneticsAbility/fade
	name = "Fade"
	desc = "Fade in and out. An admin power."
	icon_state = "template"
	targeted = FALSE
	can_act_check = FALSE
	has_misfire = FALSE
	var/active = FALSE
	var/fading = FALSE

	cast()
		if (..())
			return 0

		if (fading)
			boutput(usr, "/red Already fading. Please wait a bit.")

		if (active)
			fading = TRUE
			animate(owner, time = 10, alpha = 0, easing = LINEAR_EASING)
			fading = FALSE
		else
			fading = TRUE
			animate(owner, time = 10, alpha = 255, easing = LINEAR_EASING)
			fading = FALSE
