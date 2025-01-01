ABSTRACT_TYPE(/datum/bioEffect/power)
/datum/bioEffect/power
	name = "parent_power"
	id = "power_parent_do_not_use"
	effectType = EFFECT_TYPE_POWER
	cooldown = 600
	probability = 66
	blockCount = 3
	blockGaps = 2
	stability_loss = 10
	var/using = 0
	var/ability_path = null
	var/datum/targetable/geneticsAbility/ability = null

	New()
		..()
		check_ability_owner()

	disposing()
		src.owner = null
		if (ability)
			ability.owner = null
			qdel(ability)
		src.ability = null
		..()

	OnAdd()
		..()
		check_ability_owner()

	OnRemove()
		..()
		if (src.ability)
			src.ability.holder.removeAbilityInstance(src.ability)

	proc/check_ability_owner()
		if (ispath(ability_path))
			var/datum/targetable/geneticsAbility/AB = src.owner?.abilityHolder?.addAbility(src.ability_path)
			if (!AB)
				return
			ability = AB
			AB.cooldown = src.cooldown
			AB.linked_power = src
			icon = AB.icon
			icon_state = AB.icon_state
			AB.owner = src.owner
			src.owner.abilityHolder.updateButtons() //have to manually update because the cooldown is stored on the bioeffect

	//varedit support for cooldowns
	onVarChanged(variable, oldval, newval)
		. = ..()
		if (variable == "cooldown" && istype(src.ability))
			src.ability.cooldown = newval
			src.ability.holder?.updateButtons()

/datum/bioEffect/power/cryokinesis
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
	ability_path = /datum/targetable/geneticsAbility/cryokinesis

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

		target.visible_message(SPAN_ALERT("<b>[owner]</b> points at [target]!"))
		playsound(target, 'sound/effects/bamf.ogg', 50, 0)
		particleMaster.SpawnSystem(new /datum/particleSystem/tele_wand(get_turf(target),"8x8snowflake","#88FFFF"))

		var/obj/decal/icefloor/B
		for (var/turf/TF in range(linked_power.power - 1,T))
			B = new /obj/decal/icefloor(TF)
			SPAWN(80 SECONDS)
				B.dispose()

		for (var/mob/living/L in T.contents)
			if (L == owner && linked_power.safety)
				continue
			boutput(L, SPAN_NOTICE("You are struck by a burst of ice cold air!"))
			if(L.getStatusDuration("burning"))
				L.delStatus("burning")
			L.bodytemperature = 100
			if (linked_power.power > 1)
				new /obj/icecube(get_turf(L), L)

		return

	cast_misfire(atom/target)
		if (..())
			return 1

		owner.visible_message(SPAN_ALERT("<b>[owner]</b> points at [target]!"))
		playsound(owner.loc, 'sound/effects/bamf.ogg', 50, 0)
		particleMaster.SpawnSystem(new /datum/particleSystem/tele_wand(get_turf(owner),"8x8snowflake","#88FFFF"))

		if (!linked_power.safety)
			boutput(owner, SPAN_ALERT("Your cryokinesis misfires and freezes you!"))
			if(owner.getStatusDuration("burning"))
				owner.delStatus("burning")
			owner.bodytemperature = 100
			new /obj/icecube(get_turf(owner), owner)
		else
			boutput(owner, SPAN_ALERT("Your cryokinesis misfires!"))
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
	var/target_path = /obj/item

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
		var/list/items = get_filtered_atoms_in_touch_range(owner, mattereater.target_path) - owner.organHolder?.stomach?.stomach_contents
		if (ismob(owner.loc) || istype(owner.loc, /obj/))
			for (var/atom/A in owner.loc.contents)
				if (istype(A, mattereater.target_path))
					items += A

		for(var/obj/item/item as anything in items) // augh body bags
			if(istype(item, /obj/item/body_bag) && item.w_class >= W_CLASS_BULKY)
				items -= item

		if (linked_power.power > 1)
			items += get_filtered_atoms_in_touch_range(owner, /obj/the_server_ingame_whoa)
			//So people can still get the meat ending

		if (!length(items))
			boutput(usr, SPAN_ALERT("You can't find anything nearby to eat."))
			using = FALSE
			return

		var/obj/the_object = tgui_input_list(owner, "Which item do you want to eat?", "Matter Eater", items)
		if (!the_object || (!istype(the_object, /obj/the_server_ingame_whoa) && the_object.anchored))
			using = FALSE
			return TRUE

		if (!(the_object in get_filtered_atoms_in_touch_range(owner, mattereater.target_path)) && !istype(the_object, /obj/the_server_ingame_whoa))
			owner.show_text(SPAN_ALERT("Man, that thing is long gone, far away, just let it go."))
			using = FALSE
			return TRUE

		var/area/cur_area = get_area(owner)
		var/turf/cur_turf = get_turf(owner)
		if (isrestrictedz(cur_turf.z) && !cur_area.may_eat_here_in_restricted_z && (!owner.client || !owner.client.holder))
			owner.show_text(SPAN_ALERT("Man, this place really did a number on your appetite. You can't bring yourself to eat anything here."))
			using = FALSE
			return TRUE

		if (istype(the_object, /obj/the_server_ingame_whoa))
			var/obj/the_server_ingame_whoa/the_server = the_object
			the_server.eaten(owner)
			using = FALSE
			return
		if (istype(the_object, /obj/item/implant))
			var/obj/item/implant/implant = the_object
			if (implant.owner)
				implant.on_remove(implant.owner)
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner

			// First, restore a little hunger, and heal our organs
			if (isitem(the_object))
				var/obj/item/the_item = the_object
				H.sims?.affectMotive("Hunger", (the_item.w_class + 1) * 5) // +1 so tiny items still give a small boost
				owner.HealDamage("All", 5, 0)
				owner.UpdateDamageIcon()

		if (!QDELETED(the_object)) // Finally, ensure that the item is deleted regardless of what it is
			var/obj/item/I = the_object
			if(I.Eat(owner, owner, TRUE)) //eating can return false to indicate it failed
				I.storage?.hide_hud(owner)
				logTheThing(LOG_COMBAT, owner, "uses Matter Eater to eat [log_object(the_object)] at [log_loc(owner)].")
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
				owner.visible_message(SPAN_ALERT("[owner] eats [the_object]."))
				playsound(owner.loc, 'sound/items/eatfood.ogg', 50, FALSE)
				logTheThing(LOG_COMBAT, owner, "uses Matter Eater to eat [log_object(the_object)] at [log_loc(owner)].")
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
			owner.show_text(SPAN_ALERT("Man, this place really did a number on your appetite. You can't bring yourself to eat anything here."))
			using = 0
			return 1

		if (istype(the_object, /obj/the_server_ingame_whoa))
			var/obj/the_server_ingame_whoa/the_server = the_object
			the_server.eaten(owner)
			using = 0
			return
		owner.visible_message(SPAN_ALERT("[owner] tries to swallow [the_object] whole and nearly chokes on it."))
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
	cooldown = 100
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

	OnAdd()
		. = ..()
		ability?.doCooldown()

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
			boutput(usr, SPAN_ALERT("You can't jump right now!"))
			return 1

		var/jump_tiles = 10 * linked_power.power
		var/pixel_move = 8 * linked_power.power
		var/sleep_time = 1 / linked_power.power

		if (istype(owner.loc,/turf/))
			var/turf/T = owner.loc
			if (T.turf_flags & CAN_BE_SPACE_SAMPLE || T.throw_unlimited || owner.no_gravity)
				var/push_off = FALSE
				for(var/atom/A in oview(1, T))
					if (A.stops_space_move)
						push_off = TRUE
						break
				if(!push_off)
					boutput(usr, SPAN_ALERT("Your leg muscles tense, but there's nothing to push off of!"))
					return TRUE
			usr.visible_message(SPAN_ALERT("<b>[owner]</b> takes a huge leap!"))
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
			boutput(owner, SPAN_ALERT("You leap and slam your head against the inside of [container]! Ouch!"))
			owner.changeStatus("unconscious", 5 SECONDS)
			owner.changeStatus("knockdown", 5 SECONDS)
			container.visible_message(SPAN_ALERT("<b>[owner.loc]</b> emits a loud thump and rattles a bit."))
			playsound(container, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, TRUE)
			animate_storage_thump(container)

		return

	cast_misfire()
		if (..())
			return 1

		if (ismob(owner.loc))
			boutput(usr, SPAN_ALERT("You can't jump right now!"))
			return 1

		var/jump_tiles = 10 * linked_power.power
		var/pixel_move = 8 * linked_power.power
		var/sleep_time = 0.5 / linked_power.power

		if (istype(owner.loc,/turf/))
			var/turf/T = owner.loc
			if (T.turf_flags & CAN_BE_SPACE_SAMPLE || T.throw_unlimited || owner.no_gravity)
				var/push_off = FALSE
				for(var/atom/A in oview(1, T))
					if (A.stops_space_move)
						push_off = TRUE
						break
				if(!push_off)
					boutput(usr, SPAN_ALERT("Your leg muscles tense, but there's nothing to push off of!"))
					return TRUE
			usr.visible_message(SPAN_ALERT("<b>[owner]</b> leaps far too high and comes crashing down hard!"))
			playsound(owner.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1)
			playsound(owner.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 50, 1)
			var/prevLayer = owner.layer
			owner.layer = EFFECTS_LAYER_BASE
			owner.changeStatus("knockdown", 10 SECONDS)
			owner.changeStatus("stunned", 5 SECONDS)

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
			boutput(owner, SPAN_ALERT("You leap and slam your head against the inside of [container]! Ouch!"))
			owner.changeStatus("knockdown", 10 SECONDS)
			owner.changeStatus("stunned", 5 SECONDS)
			container.visible_message(SPAN_ALERT("<b>[owner.loc]</b> emits a loud thump and rattles a bit."))
			playsound(container, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, TRUE)
			animate_storage_thump(container)

		return TRUE

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
			boutput(owner, SPAN_ALERT("While \"be yourself\" is pretty good advice, that would be taking it a bit too literally."))
			return 1
		if (BOUNDS_DIST(target, owner) > 0 && !owner.bioHolder.HasEffect("telekinesis"))
			boutput(owner, SPAN_ALERT("You must be within touching distance of [target] for this to work."))
			return 1

		if (!ishuman(target))
			boutput(owner, SPAN_ALERT("[target] does not seem to be compatible with this ability."))
			return 1
		var/mob/living/carbon/human/H = target
		if (!H.bioHolder || H.mutantrace?.dna_mutagen_banned)
			boutput(owner, SPAN_ALERT("[target] does not seem to be compatible with this ability."))
			return 1

		if (!ishuman(owner))
			boutput(owner, SPAN_ALERT("Your body doesn't seem to be compatible with this ability."))
			return 1
		var/mob/living/carbon/human/H2= target
		if (!H2.bioHolder || H2.mutantrace?.dna_mutagen_banned)
			boutput(owner, SPAN_ALERT("Your body doesn't seem to be compatible with this ability."))
			return 1

		playsound(owner.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 50, 1)
		owner.visible_message(SPAN_ALERT("<b>[owner]</b> touches [target], then begins to shifts and contort!"))

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
			boutput(owner, SPAN_ALERT("[target] does not seem to be compatible with this ability."))
			return 1
		if (target == owner)
			boutput(owner, SPAN_ALERT("While \"be yourself\" is pretty good advice, that would be taking it a bit too literally."))
			return 1
		var/mob/living/carbon/human/H = target
		if (!H.bioHolder)
			boutput(owner, SPAN_ALERT("[target] does not seem to be compatible with this ability."))
			return 1

		if (BOUNDS_DIST(H, owner) > 0 && !owner.bioHolder.HasEffect("telekinesis"))
			boutput(owner, SPAN_ALERT("You must be within touching distance of [target] for this to work."))
			return 1

		playsound(owner.loc, 'sound/impact_sounds/Slimy_Hit_4.ogg', 50, 1)
		owner.visible_message(SPAN_ALERT("<b>[owner]</b> touches [target]... and nothing happens. Huh."))

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
			boutput(H, SPAN_NOTICE("This only works on human hair!"))
			return

		if (!HAS_FLAG(H.mutantrace.mutant_appearance_flags, HAS_HUMAN_HAIR) && !H.bioHolder.HasEffect("hair_growth"))
			boutput(H, SPAN_NOTICE("You don't have any hair!"))
			return

		if (H.bioHolder?.mobAppearance)
			var/datum/appearanceHolder/AHs = H.bioHolder.mobAppearance

			var/col1 = AHs.customizations["hair_bottom"].color
			var/col2 = AHs.customizations["hair_middle"].color
			var/col3 = AHs.customizations["hair_top"].color

			AHs.customizations["hair_bottom"].color = col3
			AHs.customizations["hair_middle"].color = col1
			AHs.customizations["hair_top"].color = col2

			H.visible_message(SPAN_NOTICE("<b>[H.name]</b>'s hair changes colors!"))
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

		if (istype(target, /obj/item/reagent_containers/food/snacks/pancake))
			dothepixelthing(target)
			src.holder.owner.visible_message(SPAN_ALERT(SPAN_BOLD("[src.holder.owner] blows up the pancakes with their mind!")), SPAN_ALERT("You blow up the pancakes with your mind!"))
			src.holder.owner.bioHolder?.RemoveEffect("telepathy")
			return

		var/mob/living/carbon/recipient = null
		if (iscarbon(target))
			recipient = target
		else if (ismob(target) && !iscarbon(target))
			boutput(owner, SPAN_ALERT("You can't transmit to [target] as they are too different from you mentally!"))
			return 1
		else
			var/turf/T = get_turf(target)
			for (var/mob/living/carbon/C in T.contents)
				recipient = C
				break

		if (!recipient)
			boutput(owner, SPAN_ALERT("There's nobody there to transmit a message to."))
			return 1

		if (recipient.bioHolder.HasEffect("psy_resist"))
			boutput(owner, SPAN_ALERT("You can't contact [recipient.name]'s mind at all!"))
			return 1

		if(isghostcritter(owner))
			boutput(owner, SPAN_ALERT("You can't contact [recipient.name]'s mind with your spectral brain!"))
			return 1

		if(!recipient.client || recipient.stat)
			boutput(owner, SPAN_ALERT("You can't seem to get through to [recipient.name] mentally."))
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
			boutput(owner, SPAN_ALERT("You can't transmit to [target] as they are too different from you mentally!"))
			return 1
		else
			var/turf/T = get_turf(target)
			for (var/mob/living/carbon/C in T.contents)
				recipient = C
				break

		if (!recipient)
			boutput(owner, SPAN_ALERT("There's nobody there to transmit a message to."))
			return 1

		if (recipient.bioHolder.HasEffect("psy_resist"))
			boutput(owner, SPAN_ALERT("You can't contact [recipient.name]'s mind at all!"))
			return 1

		if(!recipient.client || recipient.stat)
			boutput(recipient, SPAN_ALERT("You can't seem to get through to [recipient.name] mentally."))
			return 1

		var/msg = copytext( adminscrub(input(usr, "Message to [recipient.name]:","Telepathy") as text), 1, MAX_MESSAGE_LEN)
		if (!msg)
			return 1
		phrase_log.log_phrase("telepathy", msg)
		msg = uppertext(msg)

		owner.visible_message(SPAN_ALERT("<b>[owner]</b> puts [his_or_her(owner)] fingers to [his_or_her(owner)] temples and stares at [target] really hard."))
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
			boutput(owner, SPAN_ALERT("You can't read the thoughts of [target] as they are too different from you mentally!"))
			return 1
		else
			var/turf/T = get_turf(target)
			for (var/mob/living/carbon/C in T.contents)
				read = C
				break

		if (!read)
			boutput(owner, SPAN_ALERT("There's nobody there to read the thoughts of."))
			return 1

		if (read.bioHolder.HasEffect("psy_resist"))
			boutput(owner, SPAN_ALERT("You can't see into [read.name]'s mind at all!"))
			return 1

		if (isdead(read))
			boutput(owner, SPAN_ALERT("[read.name] is dead and cannot have [his_or_her(read)] mind read."))
			return

		boutput(owner, SPAN_NOTICE("Mind Reading of [read.name]:</b>"))
		var/pain_condition = read.health
		// lower health means more pain
		var/list/randomthoughts = list("what to have for lunch","the future","the past","money",
		"[his_or_her(read)] hair","what to do next","[his_or_her(read)] job","space","amusing things","sad things",
		"annoying things","happy things","something incoherent","something [he_or_she(read)] did wrong")
		var/thoughts = "thinking about [pick(randomthoughts)]"
		if (read.getStatusDuration("burning"))
			pain_condition -= 50
			thoughts = "preoccupied with the fire"
		if (read.getStatusDuration("radiation"))
			pain_condition -= 25

		switch(pain_condition)
			if (81 to INFINITY)
				boutput(owner, SPAN_NOTICE("<b>Condition</b>: [read.name] feels good."))
			if (61 to 80)
				boutput(owner, SPAN_NOTICE("<b>Condition</b>: [read.name] is suffering mild pain."))
			if (41 to 60)
				boutput(owner, SPAN_NOTICE("<b>Condition</b>: [read.name] is suffering significant pain."))
			if (21 to 40)
				boutput(owner, SPAN_NOTICE("<b>Condition</b>: [read.name] is suffering severe pain."))
			else
				boutput(owner, SPAN_NOTICE("<b>Condition</b>: [read.name] is suffering excruciating pain."))
				thoughts = "haunted by [his_or_her(read)] own mortality"

		switch(read.a_intent)
			if (INTENT_HELP)
				boutput(owner, SPAN_NOTICE("<b>Mood</b>: You sense benevolent thoughts from [read.name]."))
			if (INTENT_DISARM)
				boutput(owner, SPAN_NOTICE("<b>Mood</b>: You sense cautious thoughts from [read.name]."))
			if (INTENT_GRAB)
				boutput(owner, SPAN_NOTICE("<b>Mood</b>: You sense hostile thoughts from [read.name]."))
			if (INTENT_HARM)
				boutput(owner, SPAN_NOTICE("<b>Mood</b>: You sense cruel thoughts from [read.name]."))
				for(var/mob/living/L in view(7,read))
					if (L == read)
						continue
					thoughts = "thinking about punching [L.name]"
					break
			else
				boutput(owner, SPAN_NOTICE("<b>Mood</b>: You sense strange thoughts from [read.name]."))

		var/speech = steal_speech_text(read)
		if (length(speech))
			thoughts = "thinking about [speech]"

		if (ishuman(target))
			var/mob/living/carbon/human/H = read
			if (H.pin)
				boutput(owner, SPAN_NOTICE("<b>Numbers</b>: You sense the number [H.pin] is important to [H.name]."))
		boutput(owner, SPAN_NOTICE("<b>Thoughts</b>: [read.name] is currently [thoughts]."))

		if (read.bioHolder.HasEffect("empath"))
			boutput(read, SPAN_ALERT("You sense [owner.name] reading your mind."))
		else if (read.traitHolder.hasTrait("training_chaplain"))
			boutput(read, SPAN_ALERT("You sense someone intruding upon your thoughts..."))

	cast_misfire(atom/target)
		if (..())
			return 1

		var/mob/living/carbon/read = null
		if (iscarbon(target))
			read = target
		else if (ismob(read) && !iscarbon(target))
			boutput(owner, SPAN_ALERT("You can't read the thoughts of [target] as they are too different from you mentally!"))
			return 1
		else
			var/turf/T = get_turf(target)
			for (var/mob/living/carbon/C in T.contents)
				read = C
				break

		if (!read)
			boutput(owner, SPAN_ALERT("There's nobody there to read the thoughts of."))
			return 1

		if (read.bioHolder.HasEffect("psy_resist"))
			boutput(owner, SPAN_ALERT("You can't see into [read.name]'s mind at all!"))
			return 1

		if (isdead(read))
			boutput(owner, SPAN_ALERT("[read.name] is dead and cannot have [his_or_her(read)] mind read."))
			return

		boutput(read, SPAN_ALERT("Somehow, you sense <b>[owner]</b> trying and failing to read your mind!"))
		boutput(owner, SPAN_ALERT("You are mentally overwhelmed by a huge barrage of worthless data!"))
		owner.emote("scream")
		owner.changeStatus("unconscious", 5 SECONDS)
		owner.changeStatus("stunned", 7 SECONDS)

	/// Mostly stolen from laspgasp() (thanks pali)
	///
	/// Grab whatever they're typing from the say/whisper/radio menu, or the command bar. Separate proc so we can return if the target client goes null
	proc/steal_speech_text(mob/living/carbon/target)
		var/client/target_client = target.client
		var/enteredtext = winget(target_client, "mainwindow.input", "text") // grab the text from the input bar
		if (isnull(target_client)) return
		if (length(enteredtext) > 5 && copytext(enteredtext, 1, 6) == "say \"") // check if the player is trying to say something
			enteredtext = copytext(enteredtext, 6, 0) // grab the text they were trying to say
			enteredtext = "saying something like <i>\"[enteredtext]\"</i>, in an old-fashioned way."
		if (!length(enteredtext))
			for (var/window_type in list("say", "radiosay", "whisper"))
				enteredtext = winget(target_client, "[window_type]window.say-input", "text")
				if (isnull(target_client)) return
				if (length(enteredtext))
					switch(window_type)
						if ("say")
							enteredtext = "saying something like <i>\"[enteredtext]\"</i>"
						if ("radiosay")
							enteredtext = "saying something like <i>;\"[enteredtext]\"</i>"
						if ("whisper")
							enteredtext = "whispering something like <i>\"[enteredtext]\"</i>"
					break
		return enteredtext

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
			owner.visible_message(SPAN_ALERT("<b>[owner.name]</b> erupts into a huge column of flames! Holy shit!"))
			fireflash_melting(get_turf(owner), 3, 7000, 2000, chemfire = CHEM_FIRE_RED)
		else if (owner.is_heat_resistant())
			owner.show_message(SPAN_ALERT("Your body emits an odd burnt odor but you somehow cannot bring yourself to heat up. Huh."))
			return
		else
			owner.visible_message(SPAN_ALERT("<b>[owner.name]</b> suddenly bursts into flames!"))
			owner.set_burning(100)
		return

	cast_misfire()
		if (..())
			return 1

		playsound(owner.loc, 'sound/effects/bamf.ogg', 50, 0)
		owner.show_message(SPAN_ALERT("You accidentally expunge all heat from your body. Whoops!"))
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
			boutput(owner, SPAN_ALERT("You can't seem to turn incorporeal here."))
			return TRUE
		if (spell_invisibility(owner, 1, 0, 0, 1) == 1)
			if (!linked_power.safety)
				// If unsynchronized, you don't get to keep anything you have on you.
				// The original version of this power instead gibbed you instantly, which wasn't very fun,
				// and ended up as a newbie trap ("This sounds fun! *dead* oh.")
				// This way it's a nice tradeoff, and you can always just pick things back up
				boutput(owner, SPAN_ALERT("Everything you were carrying falls away as you dissolve!"))
				logTheThing(LOG_COMBAT, owner, "dropped all their equipment from unsynchronized power [name] at [log_loc(owner)].")
				owner.unequip_all()

			spell_invisibility(owner, 50)
			playsound(owner.loc, 'sound/effects/mag_phase.ogg', 25, 1, -1)


	cast_misfire()
		if (..())
			return TRUE
		if (istype(owner.loc, /obj/dummy/spell_invis))
			boutput(owner, SPAN_ALERT("You can't seem to turn incorporeal here."))
			return TRUE
		// Misfires still transform you, but bad things happen.

		if (spell_invisibility(owner, 1, 0, 0, 1) == 1)
			if (!linked_power.safety && ishuman(owner))
				// If unsynchronized, you drop a random organ. Hope it's not one of the important ones!
				var/list/possible_drops = list("heart", "left_lung","right_lung","left_kidney","right_kidney",
					"liver","spleen","pancreas","stomach","intestines","appendix","butt")
				var/obj/item/organ/O = owner.organHolder.drop_organ(pick(possible_drops))
				if (O)
					logTheThing(LOG_COMBAT, owner, "dropped organ [O] due to misfire of unsynchronized power [name] at [log_loc(owner)].")
					boutput(owner, SPAN_ALERT("You dissolve... mostly. Oops."))

			else
				// If synchronized, you drop a random item you were carrying.
				// This is a pretty weak downside, but at the same time,
				// to get here you've managed to synchronize it and paid the stability penalty.
				// We can afford to be nice.
				var/obj/item/I = owner.unequip_random()
				if (I)
					logTheThing(LOG_COMBAT, owner, "dropped item [I] due to misfire of unsynchronized Dissolve at [log_loc(owner)].")
					boutput(owner, SPAN_ALERT("\The [I] you were carrying falls away as you dissolve!"))

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
			boutput(owner, SPAN_ALERT("Farting is disabled."))
			return 1
		var/datum/bioEffect/power/superfart/SF = linked_power

		if (SF.farting)
			boutput(owner, SPAN_ALERT("You're already farting! Be patient!"))
			return 1

		owner.visible_message(SPAN_ALERT("<b>[owner.name]</b> hunches down and grits [his_or_her(owner)] teeth!"))
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
				owner.visible_message(SPAN_ALERT("<b>[owner.name]</b> swells up. That can't be good."))
				boutput(owner, SPAN_ALERT("<b>Oh god.</b>"))
				logTheThing(LOG_COMBAT, owner, "was gibbed by superfarting while containing anti_fart at [log_loc(owner)].")
				indigestion_gib()
				return 1

			owner.visible_message(SPAN_ALERT("<b>[owner.name]</b>[fart_string]"))
			while (sound_repeat > 0)
				sound_repeat--
				playsound(owner.loc, 'sound/voice/farts/superfart.ogg', sound_volume, 1, channel=VOLUME_CHANNEL_EMOTE)

			for(var/mob/living/V in range(get_turf(owner),fart_range))
				shake_camera(V,10,64)
				if (V == owner)
					continue

				V.changeStatus("knockdown", stun_time SECONDS)
				if(!V.anchored)
					boutput(V, SPAN_ALERT("You are sent flying!"))
					// why the hell was this set to 12 christ
					while (throw_repeat > 0)
						throw_repeat--
						step_away(V,get_turf(owner),throw_speed)
				else
					boutput(V, SPAN_ALERT("You are knocked down!"))

			var/toxic = owner.bioHolder.HasEffect("toxic_farts")
			if(toxic)
				var/turf/fart_turf = get_turf(owner)
				fart_turf.fluid_react_single("[toxic > 1 ?"very_":""]toxic_fart", toxic*2, airborne = 1)

			if (owner.getStatusDuration("burning"))
				fireflash(get_turf(owner), 3 * linked_power.power, chemfire = CHEM_FIRE_RED)

			SF.farting = 0
			if (linked_power.power > 1)
				for (var/turf/T in range(owner,6))
					animate_shake(T,5,rand(3,8),rand(3,8))

			// Superfarted on the bible? Off to hell.
			for (var/obj/item/bible/B in owner.loc)
				if(gib_user)
					owner.mind.damned = TRUE
				else
					owner.damn()
				break

			if (gib_user)
				owner.gib()

		else
			boutput(owner, SPAN_ALERT("You were interrupted and couldn't fart! Rude!"))
			SF.farting = 0
			return 1

		return

	proc/indigestion_gib()
		owner.emote("faint")
		owner.setStatus("knockdown", 20 SECONDS)
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

		if (!EB.stun_mode && ishuman(owner)) // remember to take off your headgear if you want to fire the laser
			var/mob/living/carbon/human/H = owner
			var/obj/item/I
			if (istype(H.glasses) && H.glasses.c_flags & COVERSEYES)
				I = H.glasses
			else if (istype(H.wear_mask) && H.wear_mask.c_flags & COVERSEYES)
				I = H.wear_mask
			else if (istype(H.head) && H.head.c_flags & COVERSEYES)
				I = H.head
			else if (istype(H.wear_suit) && H.wear_suit.c_flags & COVERSEYES)
				I = H.wear_suit
			if (istype(I)) // or it might go
				I.combust() // POOF
				holder.owner.visible_message(SPAN_COMBAT("<b>[holder.owner]'s [I.name] catches on fire!</b>"),\
				SPAN_COMBAT("<b>Your [I.name] catches on fire!</b> Maybe you should have taken it off first!"))
				return

		owner.visible_message(SPAN_ALERT("<b>[owner.name]</b> shoots eye beams!"))
		var/datum/projectile/laser/eyebeams/PJ = new projectile_path
		shoot_projectile_ST_pixel_spread(owner, PJ, T)

	cast_misfire(atom/target)
		if (..())
			return 1

		owner.visible_message(SPAN_ALERT("<b>[owner.name]'s</b> eyeballs catch on fire briefly!"))
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.take_eye_damage(5)

/datum/projectile/laser/eyebeams
	name = "optic laser"
	icon_state = "eyebeam"
	damage = 20
	cost = 20
	sname = "eye laser"
	dissipation_delay = 5
	shot_sound = 'sound/weapons/TaserOLD.ogg'
	color_red = 1
	color_green = 0
	color_blue = 1

/datum/projectile/laser/eyebeams/stun
	damage = 0
	stun = 20

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
			boutput(owner, SPAN_NOTICE("You get pumped up!"))
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
			boutput(owner, SPAN_ALERT("You get pumped up! ...maybe a bit too pumped up! You feel kinda sick..."))
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
			return TRUE
		if(linked_power.using)
			return TRUE

		var/obj/the_object = target

		var/base_path = /obj/item
		if (linked_power.power > 1)
			base_path = /obj

		var/list/items = get_filtered_atoms_in_touch_range(owner,base_path)

		if(target)
			if (!(target in items))
				return TRUE
		else
			if (!items.len)
				boutput(usr, SPAN_ALERT("You can't find anything nearby to touch."))
				return TRUE

			linked_power.using = 1
			the_object = input("Which item do you want to transmute?","Midas Touch") as null|obj in items
			if (!the_object)
				last_cast = 0
				linked_power.using = 0
				return TRUE

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
				logTheThing(LOG_COMBAT, owner, "uses [name] to transmute [log_object(the_object)] into [linked.transmute_material] at [log_loc(owner)].")
				owner.visible_message(SPAN_ALERT("[owner] touches [the_object], turning it to [linked.transmute_material]!"))
				the_object.setMaterial(getMaterial(linked.transmute_material))
			else
				logTheThing(LOG_COMBAT, owner, "uses [name] to transmute [log_object(the_object)] into gold at [log_loc(owner)].")
				owner.visible_message(SPAN_ALERT("[owner] touches [the_object], turning it to gold!"))
				the_object.setMaterial(getMaterial("gold"))
		linked_power.using = 0

	cast_misfire()
		if (..())
			return 1
		if(linked_power.using)
			return 1

		var/base_path = /obj/item
		if (linked_power.power > 1)
			base_path = /obj

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
			owner.visible_message(SPAN_ALERT("[owner] touches [the_object], turning it to flesh!"))
			logTheThing(LOG_COMBAT, owner, "uses [name] to transmute [log_object(the_object)] into flesh at [log_loc(owner)].")
			the_object.setMaterial(getMaterial("flesh"))
		linked_power.using = 0
		return

	logCast(atom/target)
		return

/datum/bioEffect/power/midas/pickle
	name = "Pickle Touch"
	id = "pickle"
	desc = "Allows the subject to induce spontaneous pickling at will."
	msgGain = "You suddenly smell vinegar."
	msgLose = "You feel less well preserved."
	transmute_material = "pickle"
	power = 2
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	ability_path = /datum/targetable/geneticsAbility/midas/pickle

/datum/targetable/geneticsAbility/midas/pickle
	name = "Pickle Touch"
	desc = "Instantly pickle an object"
	icon_state = "pickle"

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
			boutput(usr, SPAN_ALERT("You need to be closer to do that."))
			return 1

		if (!iscarbon(target))
			boutput(usr, SPAN_ALERT("This power won't work on that!"))
			return 1

		if (target == owner)
			boutput(usr, SPAN_ALERT("This power doesn't work when you touch yourself. Weirdo."))
			return 1

		var/mob/living/carbon/C = target
		owner.visible_message(SPAN_ALERT("<b>[owner] touches [C], enveloping [him_or_her(C)] in a soft glow!</b>"))
		boutput(C, SPAN_NOTICE("You feel your pain fading away."))
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
			boutput(usr, SPAN_ALERT("You need to be closer to do that."))
			return 1

		if (!iscarbon(target))
			boutput(usr, SPAN_ALERT("This power won't work on that!"))
			return 1

		if (target == owner)
			boutput(usr, SPAN_ALERT("This power doesn't work when you touch yourself. Weirdo."))
			return 1

		var/mob/living/carbon/C = target
		owner.visible_message(SPAN_ALERT("<b>[owner] touches [C], enveloping [him_or_her(C)] in a bright glow!</b>"))
		boutput(C, SPAN_NOTICE("Your pain fades away rapidly."))
		boutput(owner, SPAN_ALERT("You use too much life energy and hurt yourself!"))
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
	var/active = FALSE
	var/processing = FALSE
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

			owner.visible_message(SPAN_ALERT("<b>[owner] appears in a burst of blue light!</b>"))
			playsound(owner.loc, 'sound/effects/ghost2.ogg', 50, 0)
			SPAWN(0.7 SECONDS)
				animate(owner, alpha = 255, time = 5, easing = LINEAR_EASING)
				animate(color = "#FFFFFF", time = 5, easing = LINEAR_EASING)
				active = FALSE
				processing = FALSE
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
			boutput(owner, SPAN_ALERT("That won't work here."))
			return TRUE
		if (P.processing)
			return TRUE

		P.processing = TRUE

		if (!P.active)
			if (istype(owner.loc, /obj/dummy/spell_invis/)) // check for if theres a spell_invis object we havent placed (from biomass manipulation)
				// before this, dimension shift and biomass manipulation resulted in strange behavior, including being sent to nullspace.
				boutput(owner, SPAN_ALERT("That won't work here."))
				P.processing = FALSE
				return TRUE
			P.active = TRUE
			P.last_loc = get_turf(owner)
			owner.canmove = 0
			owner.restrain_time = TIME + 0.7 SECONDS
			owner.visible_message(SPAN_ALERT("<b>[owner] vanishes in a burst of blue light!</b>"))
			playsound(owner.loc, 'sound/effects/ghost2.ogg', 50, 0)
			animate(owner, color = "#0000FF", time = 5, easing = LINEAR_EASING)
			animate(alpha = 0, time = 5, easing = LINEAR_EASING)
			SPAWN(0.7 SECONDS)
				owner.canmove = 1
				owner.restrain_time = 0
				var/obj/dummy/spell_invis/dimshift/invis_object = new /obj/dummy/spell_invis/dimshift(get_turf(owner), owner, P)
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
		owner.visible_message(SPAN_ALERT("<b>[owner]</b> raises [his_or_her(owner)] hands into the air!"))
		playsound(owner.loc, 'sound/voice/heavenly.ogg', 50, 0)
		var/strength = 1 + 6 * linked_power.power
		var/time = 300 * linked_power.power
		new /obj/photokinesis_light(T,P.red,P.green,P.blue,strength,time)

/obj/photokinesis_light
	name = ""
	desc = ""
	density = 0
	anchored = ANCHORED
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
		owner.visible_message(SPAN_ALERT("<b>[owner]</b> raises [his_or_her(owner)] hands into the air!"))
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
		owner.visible_message(SPAN_ALERT("<b>[owner] breathes fire!</b>"))
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
			fireflash(F,0.5,temp, chemfire = CHEM_FIRE_RED)

	cast_misfire(atom/target)
		if (..())
			return 1

		owner.visible_message(SPAN_ALERT("<b>[owner] manages to set [himself_or_herself(owner)] on fire!</b>"))
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
		owner.visible_message(SPAN_ALERT("<b>[owner.name] makes a weird noise!</b>"))
		playsound(owner.loc, 'sound/musical_instruments/WeirdHorn_0.ogg', 50, 0)
		var/count = 0
		for (var/mob/living/L in range(7,owner))
			if (L.hearing_check(1))
				if(count++ > (4 + src.linked_power.power * 3)) break
				if(locate(/obj/item/bible) in get_turf(L))
					owner.visible_message(SPAN_ALERT("<b>A mysterious force smites [owner.name] for inciting blasphemy!</b>"))
					owner.gib()
				else
					L.emote("fart")

	cast_misfire()
		if (..())
			return 1
		owner.visible_message(SPAN_ALERT("<b>[owner.name] makes a really weird noise!</b>"))
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
		if (..())
			return
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "telekinesishead", layer = MOB_LAYER)

	OnAdd()
		. = ..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.set_body_icon_dirty()

	OnRemove()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.set_body_icon_dirty()
		. = ..()

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

		. = ..()
		owner.visible_message(SPAN_ALERT("<b>[owner.name]</b> makes a gesture at [T.name]!"))

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

		owner.visible_message(SPAN_ALERT("<b>[owner.name]</b> makes a gesture at [T.name]!"))

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
		if(..())
			return
		if (!src.active)
			return
		if (!isliving(owner))
			return

		var/mob/living/L = owner
		var/turf/T = get_turf(L)

		if (!isturf(T) || T.is_lit())
			src.cloak_decloak(2)
		else if (can_act(src.owner))
			src.cloak_decloak(1)

/datum/targetable/geneticsAbility/darkcloak
	name = "Cloak of Darkness"
	icon_state = "darkcloak"
	desc = "Activate or deactivate your cloak of darkness."
	targeted = FALSE
	cooldown = 0
	can_act_check = FALSE
	has_misfire = FALSE
	do_logs = FALSE

	cast(atom/T)
		var/datum/bioEffect/power/darkcloak/DC = linked_power
		. = ..()
		if (DC.active)
			boutput(usr, "You stop using your cloak of darkness.")
			DC.active = 0
			DC.cloak_decloak(2)
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
	do_logs = FALSE

	cast(atom/T)
		var/datum/bioEffect/power/chameleon/CH = linked_power
		. = ..()
		if (CH.active)
			boutput(usr, "You stop using your chameleon cloaking.")
			CH.active = 0
			CH.UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_ATTACKED_PRE))
			CH.decloak()
		else
			boutput(usr, "You start using your chameleon cloaking.")
			CH.last_moved = TIME
			CH.active = 1
			CH.RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_ATTACKED_PRE), /datum/bioEffect/power/chameleon/proc/decloak)
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
		owner.visible_message(SPAN_ALERT("<b>[owner] horfs up a huge stream of puke!</b>"))
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
		var/base_path = /obj
		var/list/items = get_filtered_atoms_in_touch_range(owner,base_path)
		if(!the_object)
			if (!items.len)
				boutput(usr, "/red You can't find anything nearby to spray ink on.")
				return 1

			the_object = input("Which item do you want to color?","Ink Glands") as null|obj in items
			if (!the_object)
				last_cast = 0
				return 1
		if (!(the_object in items))
			return 1

		var/datum/bioEffect/power/ink/I = linked_power
		if (!linked_power)
			owner.visible_message("[owner] spits on [the_object]. Gross.")
		else
			owner.visible_message(SPAN_ALERT("[owner] sprays ink onto [the_object]!"))
			the_object.color = I.color
		return 0

/datum/bioEffect/power/shoot_limb
	name = "Vestigial Ballistics"
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
		if(src.safety && src.stability_loss)
			src.owner.bioHolder.genetic_stability += src.stability_loss
			src.stability_loss = 0

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
						boutput(owner, SPAN_ALERT("The pressure in one of your joints built up too high! One of your limbs flew off!"))
						owner.changeStatus("knockdown", 4 SECONDS)
						return
				while (do_count < 5)


/datum/targetable/geneticsAbility/shoot_limb
	name = "Vestigial Ballistics"
	desc = "OOOOWWWWWW!!!!!!!!"
	icon_state = "shoot_limb"
	targeted = TRUE
	needs_hands = FALSE //hehe
	var/range = 9
	var/throw_power = 1
	var/limb_force = 20

	proc/hit_callback(var/datum/thrown_thing/thr)
		for(var/mob/living/carbon/hit in get_turf(thr.thing))
			hit.changeStatus("knockdown", 5 SECONDS)
			hit.force_laydown_standup()
			break

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
					var/datum/callback/callback = (SL?.stun_mode) ? CALLBACK(src, PROC_REF(hit_callback)) : null
					thrown_limb.throw_at(target, range, throw_power * (linked_power.power), end_throw_callback=callback)
					//without snychronizer, you take damage and bleed on usage of the power
					if (!linked_power.safety)
						new thrown_limb.streak_decal(owner.loc)
						var/damage = rand(5,15)
						var/do_bleed = TRUE
						if(thrown_limb.kind_of_limb & LIMB_SKELLY)
							damage /= 2.5
							do_bleed = FALSE
						random_brute_damage(H, damage)
						if(do_bleed)
							take_bleeding_damage(H, null, damage)
						if(prob(60)) owner.emote("scream")

						//reset the time until the ability spontaniously fires
						var/datum/bioEffect/power/shoot_limb/pwr = linked_power
						if (istype(pwr))
							pwr.count = 0

					owner.visible_message(SPAN_ALERT("<b>[thrown_limb][linked_power.power > 1 ? " violently " : " "]bursts off of its socket and flies towards [target]!</b>"))
					logTheThing(LOG_COMBAT, owner, "shoot_limb [!linked_power.safety ? "Accidently" : ""] at [ismob(target)].")
					SPAWN(1 SECOND)
						if (thrown_limb)
							thrown_limb.throwforce = tmp_force

ABSTRACT_TYPE(/datum/bioEffect/power/critter)
/datum/bioEffect/power/critter
	id = "critter_do_not_use"

/datum/bioEffect/power/critter/peck
	name = "Aviornis Rostriformis "
	desc = "Generates a hardened keratin area between the mouth and nose."
	id = "beak_peck"
	msgGain = "You feel your mouth and nose become more difficult to move."
	msgLose = "You feel your face return to normal."
	cooldown = 10 SECONDS
	occur_in_genepools = 0
	stability_loss = 15
	ability_path = /datum/targetable/geneticsAbility/wrapper/peck
	var/color = "#888888"

/datum/targetable/geneticsAbility/wrapper/peck
	wrapped_ability = /datum/targetable/critter/peck
	start_on_cooldown = TRUE
	has_misfire = FALSE
	needs_hands = FALSE

/datum/bioEffect/power/critter/snake_bite
	name = "Ophidentis Vipernox"
	desc = "Generates an enhanced structure of your fangs allowing for venom."
	id = "snake_bite"
	msgGain = "You become oddly aware of your canines and they feel different."
	msgLose = "You feel less aware of your teeth."
	cooldown = 20 SECONDS
	occur_in_genepools = 0
	stability_loss = 15
	ability_path = /datum/targetable/geneticsAbility/wrapper/snake_bite
	var/color = "#888888"

/datum/targetable/geneticsAbility/wrapper/snake_bite
	wrapped_ability = /datum/targetable/critter/wasp_sting/snake_bite
	start_on_cooldown = TRUE
	has_misfire = FALSE
	needs_hands = FALSE
	override_params = list("amt1"=5)


/datum/bioEffect/power/critter/scorpion_sting
	name = "Scorpiocauda Vipernox"
	desc = "Generates a hardened chitin tail like stucture."
	id = "scorpion_sting"
	msgGain = "You feel aware of something strange around your tail bone."
	msgLose = "You feel a bit more normal."
	cooldown = 20 SECONDS
	occur_in_genepools = 0
	stability_loss = 15
	ability_path = /datum/targetable/geneticsAbility/wrapper/scorpion_sting
	var/color = "#888888"

/datum/targetable/geneticsAbility/wrapper/scorpion_sting
	wrapped_ability = /datum/targetable/critter/wasp_sting/scorpion_sting
	start_on_cooldown = TRUE
	has_misfire = FALSE
	needs_hands = FALSE
	override_params = list("amt1"=2,"amt2"=5)

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
		var/base_path = /obj
		var/list/items = get_filtered_atoms_in_touch_range(owner,base_path)
		if(!the_object)
			if (!items.len)
				boutput(usr, "/red You can't find anything nearby to spray ink on.")
				return 1

			the_object = input("Which item do you want to color?","Ink Glands") as null|obj in items
			if (!the_object)
				last_cast = 0
				return 1
		if (!(the_object in items))
			return 1

		var/datum/bioEffect/power/ink/I = linked_power
		if (!linked_power)
			owner.visible_message("[owner] spits on [the_object]. Gross.")
		else
			owner.visible_message(SPAN_ALERT("[owner] sprays ink onto [the_object]!"))
			the_object.color = I.color
		return 0

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
