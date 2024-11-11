/datum/bioEffect/glowy
	name = "Glowy"
	desc = "Endows the subject with bioluminescent skin. Color and intensity may vary by subject."
	id = "glowy"
	icon_state = "glowy"
	probability = 99
	effectType = EFFECT_TYPE_POWER
	blockCount = 3
	blockGaps = 1
	msgGain = "Your skin begins to glow softly."
	msgLose = "Your glow fades away."
	var/list/color

	OnAdd()
		..()
		src.color = hsv2rgblist(randfloat(0, 360), randfloat(0, 100), 100)
		src.color += list(50 + 75 * power)
		owner.add_sm_light("glowy", src.color)

	onPowerChange(oldval, newval)
		. = ..()
		src.color[4] = 75 + 50 * power
		owner.add_sm_light("glowy", src.color)

	OnRemove()
		..()
		owner.remove_sm_light("glowy")

/datum/bioEffect/horns
	name = "Cranial Keratin Formation"
	desc = "Enables the growth of a compacted keratin formation on the subject's head."
	id = "horns"
	icon_state = "horns"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	msgGain = "A pair of horns erupt from your head."
	msgLose = "Your horns crumble away into nothing."
	var/hornstyle = "random"

	OnAdd()
		if(hornstyle == "random")
			hornstyle = pick("horns","horns_ram","horns_ramblk","horns_dark","horns_beige","horns_light","horns_sml","horns_unicorn")

		overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[hornstyle]", layer = MOB_LAYER)
		if (ismonkey(owner))
			overlay_image.pixel_y = -6
		..()

	onVarChanged(variable, oldval, newval)
		. = ..()
		if(variable == "hornstyle")
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[newval]", layer = MOB_LAYER)
			if(ismonkey(owner))
				overlay_image.pixel_y = -6
			owner.UpdateOverlays(overlay_image, id)

/datum/bioEffect/horns/evil //this is just for /proc/soulcheck
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	id = "demon_horns"
	hornstyle = "horns_devil"

/datum/bioEffect/particles
	name = "Dermal Glitter"
	desc = "Causes the subject's skin to shine and gleam."
	id = "shiny"
	icon_state = "dermal_glitter"
	effectType = EFFECT_TYPE_POWER
	probability = 66
	msgGain = "Your skin looks all blinged out."
	msgLose = "Your skin fades to a more normal state."
	var/system_path = /datum/particleSystem/sparkles

	OnAdd()
		. = ..()
		if (!particleMaster.CheckSystemExists(system_path, owner))
			particleMaster.SpawnSystem(new system_path(owner))

	OnRemove()
		. = ..()
		if (particleMaster.CheckSystemExists(system_path, owner))
			particleMaster.RemoveSystem(system_path, owner)

/datum/bioEffect/achromia
	name = "Achromia"
	desc = "The subject loses most of their skin pigmentation, with the remainder causing their skin take on a gray coloration."
	id = "achromia"
	probability = 99
	icon_state  = "achromia"
	var/holder_skin = null

	OnAdd()
		. = ..()
		if (!ishuman(owner))
			return

		var/mob/living/carbon/human/H = owner
		if (!H.bioHolder)
			return
		var/datum/appearanceHolder/AH = H.bioHolder.mobAppearance
		holder_skin = AH.s_tone
		var/list/L = hex_to_rgb_list(AH.s_tone)
		var/new_color = ((L[1] + L[2] + L[3]) / 3) - 20
		if (new_color < 0)
			new_color = 0
		AH.s_tone = rgb(new_color, new_color, new_color)
		H.update_colorful_parts()
		H.update_body()

	OnRemove()
		. = ..()
		if (!.)
			return
		if (!ishuman(owner))
			return

		var/mob/living/carbon/human/H = owner
		if (!H.bioHolder)
			return
		var/datum/appearanceHolder/AH = H.bioHolder.mobAppearance
		if (!AH)
			return
		AH.s_tone = holder_skin
		if(AH.mob_appearance_flags & FIX_COLORS) // human -> achrom -> lizard -> notachrom is *bright*
			AH.customizations["hair_bottom"].color = fix_colors(AH.customizations["hair_bottom"].color)
			AH.customizations["hair_middle"].color = fix_colors(AH.customizations["hair_middle"].color)
			AH.customizations["hair_top"].color = fix_colors(AH.customizations["hair_top"].color)
		H.update_colorful_parts()
		H.update_body()

/datum/bioEffect/color_changer
	name = "Melanin Suppressor"
	desc = "Shuts down all melanin production in the subject's body."
	id = "albinism"
	icon_state = "albinism"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	isBad = 1
	var/eye_color_to_use = "#FF0000"
	var/color_to_use = "#FFFFFF"
	var/skintone_to_use = "#FFFFFF"

	OnAdd()
		. = ..()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			for (var/ID in H.bioHolder.effects)
				if (istype(H.bioHolder.GetEffect(ID), /datum/bioEffect/color_changer) && ID != src.id)
					H.bioHolder.RemoveEffect(ID)
			var/datum/appearanceHolder/AH = H.bioHolder.mobAppearance
			AH.e_color_original = AH.e_color
			AH.customizations["hair_bottom"].color_original = AH.customizations["hair_bottom"].color
			AH.customizations["hair_middle"].color_original = AH.customizations["hair_middle"].color
			AH.customizations["hair_top"].color_original = AH.customizations["hair_top"].color
			AH.s_tone_original = AH.s_tone

			AH.e_color = eye_color_to_use
			AH.s_tone = skintone_to_use
			AH.customizations["hair_bottom"].color = color_to_use
			AH.customizations["hair_middle"].color = color_to_use
			AH.customizations["hair_top"].color = color_to_use
			H.update_colorful_parts()

	OnRemove()
		. = ..()
		if (!.)
			return
		if (ishuman(owner))
			if (QDELETED(owner))
				return
			var/mob/living/carbon/human/H = owner
			var/datum/appearanceHolder/AH = H.bioHolder.mobAppearance
			AH.e_color = AH.e_color_original
			AH.s_tone = AH.s_tone_original
			AH.customizations["hair_bottom"].color = AH.customizations["hair_bottom"].color_original
			AH.customizations["hair_middle"].color = AH.customizations["hair_middle"].color_original
			AH.customizations["hair_top"].color = AH.customizations["hair_top"].color_original
			if(AH.mob_appearance_flags & FIX_COLORS) // human -> blank -> lizard -> unblank is *bright*
				AH.customizations["hair_bottom"].color = fix_colors(AH.customizations["hair_bottom"].color)
				AH.customizations["hair_middle"].color = fix_colors(AH.customizations["hair_middle"].color)
				AH.customizations["hair_top"].color = fix_colors(AH.customizations["hair_top"].color)
			H.update_colorful_parts()

/datum/bioEffect/color_changer/black
	name = "Melanin Stimulator"
	desc = "Overstimulates the subject's melanin glands."
	id = "melanism"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	isBad = 1
	eye_color_to_use = "#572E0B"
	color_to_use = "#000000"
	skintone_to_use = "#000000"

/datum/bioEffect/color_changer/blank
	name = "Melanin Eraser"
	desc = "Shuts down all melanin production in subject's body, and eradicates all existing melanin."
	id = "blankman"
	msgGain = "You feel oddly plain."
	msgLose = "You don't feel boring anymore."
	icon_state  = "blank"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	isBad = 1
	color_to_use = "#FFFFFF"

	OnAdd()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			var/datum/appearanceHolder/AH = H.bioHolder.mobAppearance
			src.eye_color_to_use = AH.e_color
			//totally desaturate skintone
			var/skin_tone = hex_to_rgb_list(AH.s_tone)
			skin_tone = rgb2hsv(skin_tone[1], skin_tone[2], skin_tone[3])
			skin_tone[2] = 0
			skin_tone = hsv2rgb(skin_tone[1], skin_tone[2], skin_tone[3])
			src.skintone_to_use = skin_tone
		. = ..()

/datum/bioEffect/stinky
	name = "Apocrine Enhancement"
	desc = "Increases the amount of natural body substances produced from the subject's apocrine glands."
	id = "stinky"
	probability = 99
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	msgGain = "You feel sweaty."
	msgLose = "You feel much more hygienic."
	var/personalized_stink = null

	New()
		..()
		if (prob(5))
			src.personalized_stink = stinkString()

	OnLife(var/mult)
		if(..()) return
		if (owner.reagents.has_reagent("menthol"))
			return
		else if (prob(10))
			for(var/mob/living/carbon/C in view(6,get_turf(owner)))
				if (C == owner)
					continue
				if (ispug(C))
					boutput(C, SPAN_ALERT("Wow, [owner] sure [pick("stinks", "smells", "reeks")]!"), "stink_message")
				else if (src.personalized_stink)
					boutput(C, SPAN_ALERT("[src.personalized_stink]"), "stink_message")
				else
					boutput(C, SPAN_ALERT("[stinkString()]"), "stink_message")


/obj/effect/rt/dwarf
	icon = 'icons/effects/96x96.dmi'
	icon_state = "distort-dwarf"

/datum/bioEffect/dwarf
	name = "Dwarfism"
	desc = "Greatly reduces the overall size of the subject, resulting in markedly diminished height."
	id = "dwarf"
	msgGain = "Did everything just get bigger?"
	msgLose = "You feel tall!"
	icon_state  = "dwarf"
	var/filter = null
	var/tmp/obj/effect/rt/dwarf/distort = new
	var/size = 127

	OnAdd()
		. = ..()
		src.applyFilter()

	OnRemove()
		src.removeFilter()
		. = ..()

	disposing()
		qdel(src.distort)
		src.distort = null
		. = ..()

	// We need to fully remove and remake the filter in these cases because the filter reverts to its original size when the animation is interrupted
	// by another animation, like scan lines. Can't just animate to the correct size.
	onVarChanged(variable, oldval, newval)
		. = ..()
		if(variable == "size" && src.filter)
			src.removeFilter()
			src.applyFilter()

	onPowerChange(oldval, newval)
		. = ..()
		src.removeFilter()
		src.applyFilter()

	proc/applyFilter()
		owner.add_filter("dwarfism", 1, displacement_map_filter(size=src.size * power, render_source = src.distort.render_target))
		owner.vis_contents += src.distort
		src.filter = owner.get_filter("dwarfism")
		animate(src.filter, size=0, time=0)
		animate(size=src.size * power, time=0.7 SECONDS, easing=SINE_EASING)

	proc/removeFilter()
		owner.remove_filter("dwarfism")
		owner.vis_contents -= src.distort
		src.filter = null

/datum/bioEffect/drunk
	name = "Ethanol Production"
	desc = "Encourages growth of ethanol-producing symbiotic fungus in the subject's body."
	id = "drunk"
	icon_state = "ethanol_prod"
	isBad = 1
	msgGain = "You feel drunk!"
	msgLose = "You feel sober."
	probability = 99
	stability_loss = -5
	var/reagent_to_add = "ethanol"
	var/reagent_threshold = 80
	var/add_per_tick = 1

	OnLife(var/mult)
		if(..()) return
		var/mob/living/L = owner
		if (isdead(L))
			return
		var/reagent_id = islist(reagent_to_add) ? pick(reagent_to_add) : reagent_to_add
		if (L.reagents && L.reagents.get_reagent_amount(reagent_id) < reagent_threshold)
			L.reagents.add_reagent(reagent_id,add_per_tick * mult)

/datum/bioEffect/drunk/bee
	name = "Bee Production"
	desc = "Encourages growth of bees in the subject's body."
	id = "drunk_bee"
	isBad = 0
	msgGain = "Your stomach buzzes!"
	msgLose = "The buzzing in your stomach stops."
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	reagent_to_add = "bee"
	reagent_threshold = 12
	add_per_tick = 6 //ensures we always have bee sickness

/datum/bioEffect/drunk/pentetic
	name = "Pentetic Acid Production"
	desc = "This mutation somehow causes the subject's body to manufacture a potent chelating agent. How exactly it functions is completely unknown."
	id = "drunk_pentetic"
	msgGain = "You feel detoxified."
	msgLose = "You feel toxic."
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	reagent_to_add = "penteticacid"
	reagent_threshold = 12
	add_per_tick = 4

/datum/bioEffect/drunk/random
	name = "Chemical Production Modification"
	desc = {"This mutation somehow irreversibly alters the subject's body to function as an organic chemical factory, mass producing large quantities of seemingly random chemicals. The mechanism for this modification is currently unknown to medical and genetic science."}
	id = "drunk_random"
	msgGain = "You begin to sense an odd chemical taste in your mouth."
	msgLose = "The chemical taste in your mouth fades."
	occur_in_genepools = 1 //this is going to be very goddamn rare and very fucking difficult to unlock.
	mob_exclusive = /mob/living/carbon/human
	probability = 1
	blockCount = 5
	can_research = 0
	lockProb = 100
	blockGaps = 0
	lockedGaps = 10
	lockedDiff = 6
	lockedChars = list("G","C","A","T","U")
	stability_loss = 15
	lockedTries = 10
	curable_by_mutadone = 0
	can_scramble = 0
	can_reclaim = 0
	reagent_to_add = "honey"
	reagent_threshold = 500 //it never stops
	add_per_tick = 5 //even more difficult to remove without calomel or hunchback

	New()
		..()
		if (length(all_functional_reagent_ids) > 1)
			reagent_to_add = pick(all_functional_reagent_ids)
		else
			reagent_to_add = "water"

/datum/bioEffect/drunk/random/unstable
	name = "Unstable Chemical Production Modification"
	desc = {"This mutation somehow irreversibly alters the subject's body to function as an organic chemical factory, mass producing large quantities of seemingly random chemicals. The mechanism for this modification is currently unknown to medical and genetic science."}
	id = "drunk_random_unstable"
	probability = 0.25
	var/change_prob = 25
	add_per_tick = 7
	stability_loss = 25

	OnLife(var/mult)
		if (prob(src.change_prob) && length(all_functional_reagent_ids) > 1)
			reagent_to_add = pick(all_functional_reagent_ids)
		..()

/datum/bioEffect/bee
	name = "Apidae Metabolism"
	desc = {"Human worker clone batch #92 may contain inactive space bee DNA.
	If you do not have the authorization level to know that SS13 is staffed with clones, please forget this entire message."}
	id = "bee"
	msgGain = "You feel buzzed!"
	msgLose = "You lose your buzz."
	probability = 99

/datum/bioEffect/chime_snaps
	name = "Dactyl Crystallization"
	desc = "The subject's digits crystallize and, when struck together, emit a pleasant noise."
	id = "chime_snaps"
	icon_state = "chime_snaps"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	msgGain = "Your fingers and toes turn transparent and crystalline."
	msgLose = "Your fingers and toes return to normal."

/datum/bioEffect/aura
	name = "Dermal Glow"
	desc = "Causes the subject's skin to emit faint light patterns."
	id = "aura"
	icon_state = "aura"
	effectType = EFFECT_TYPE_POWER
	probability = 99
	msgGain = "You start to emit a pulsing glow."
	msgLose = "The glow in your skin fades."
	var/ovl_sprite = null
	var/color_hex = null

	New()
		..()
		ovl_sprite = pick("aurapulse","aurapulse-fast","aurapulse-slow","aurapulse-offset")
		color_hex = random_color()

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = ovl_sprite, layer = MOB_LIMB_LAYER)
			overlay_image.color = color_hex
		..()

/datum/bioEffect/chronal_additive_inversement
	name = "Chronal Additive Inversement"
	desc = "Causes the subject's age to become its additive inverse...somehow."
	id = "chronal_additive_inversement"
	effectType = EFFECT_TYPE_POWER
	probability = 66
	blockCount = 3
	blockGaps = 3
	msgGain = "You feel as if you're impossibly young."
	msgLose = "You feel like you're your own age again."
	stability_loss = 0

	OnAdd()
		holder.age = (0 - holder.age)
		..()
	OnRemove()
		holder.age = (0 - holder.age)
		..()

/datum/bioEffect/temporal_displacement
	name = "Temporal Displacement"
	desc = "The subject becomes displaced in time, aging them at random."
	id = "temporal_displacement"
	effectType = EFFECT_TYPE_POWER
	probability = 66
	blockCount = 3
	blockGaps = 3
	msgGain = "You feel like you're growing younger - no wait, older?"
	msgLose = "You feel like you're aging normally again."
	stability_loss = 0
	OnLife(var/mult)
		..()
		if (prob(33))
			holder.age = rand(-80, 80)


//////////////////////
// Combination Only //
//////////////////////

/datum/bioEffect/fire_aura
	name = "Blazing Aura"
	desc = "Causes the subject's skin to emit harmless false fire."
	id = "aura_fire"
	icon_state = "blazing_aura"
	effectType = EFFECT_TYPE_POWER
	occur_in_genepools = 0
	msgGain = "You burst into flames!"
	msgLose = "Your skin stops emitting fire."
	var/ovl_sprite = null
	var/color_hex = null

	New()
		..()
		color_hex = random_color()

	OnAdd()
		if (ishuman(owner))
			overlay_image = image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "fireaura", layer = MOB_LIMB_LAYER)
			overlay_image.color = color_hex
		..()

	onVarChanged(variable, oldval, newval)
		. = ..()
		if(variable == "color_hex")
			overlay_image.color = color_hex
			if(isliving(owner))
				var/mob/living/L = owner
				L.UpdateOverlays(overlay_image, id)

/datum/bioEffect/fire_aura/evil //this is just for /proc/soulcheck
	occur_in_genepools = 0
	probability = 0
	scanner_visibility = 0
	can_research = 0
	can_make_injector = 0
	can_copy = 0
	can_reclaim = 0
	can_scramble = 0
	curable_by_mutadone = 0
	id = "hell_fire"

	New()
		..()
		color_hex = "#680000"

/datum/bioEffect/reversedSounds
	name = "Antitemporal Inner Ear"
	desc = "Makes your inner ear travel back in time, causing you to hear sounds in reverse."
	id = "reversed_sounds"
	probability = 25
	msgGain = "You start hearing things backwards."
	msgLose = "You no longer hear things backwards."

	OnAdd()
		..()
		APPLY_ATOM_PROPERTY(owner, PROP_MOB_HEARD_PITCH, src, -1)

	OnRemove()
		REMOVE_ATOM_PROPERTY(owner, PROP_MOB_HEARD_PITCH, src)
		..()

/datum/bioEffect/slowSounds
	name = "Leisurely Inner Ear"
	desc = "Makes your inner ear chill out a little, meaning you hear things deeper and in slow motion."
	id = "slow_sounds"
	probability = 25
	msgGain = "You hear everything slowed down and deeper."
	msgLose = "You no longer hear everything slowed down and deeper."
	effect_group = "soundspeed"

	OnAdd()
		..()
		APPLY_ATOM_PROPERTY(owner, PROP_MOB_HEARD_PITCH, src, 0.5 / power)

	onPowerChange(oldval, newval)
		. = ..()
		APPLY_ATOM_PROPERTY(owner, PROP_MOB_HEARD_PITCH, src, 0.5 / power)

	OnRemove()
		REMOVE_ATOM_PROPERTY(owner, PROP_MOB_HEARD_PITCH, src)
		..()

/datum/bioEffect/fastSounds
	name = "Hurried Inner Ear"
	desc = "Your inner ear is full of performance enhancing drugs, it processes sounds really quickly and with higher pitch!"
	id = "fast_sounds"
	probability = 25
	msgGain = "You hear everything sped up and higher pitched."
	msgLose = "You no longer hear everything sped up and higher pitched."
	effect_group = "soundspeed"

	OnAdd()
		..()
		APPLY_ATOM_PROPERTY(owner, PROP_MOB_HEARD_PITCH, src, 2 * power)

	onPowerChange(oldval, newval)
		. = ..()
		APPLY_ATOM_PROPERTY(owner, PROP_MOB_HEARD_PITCH, src, 2 * power)

	OnRemove()
		REMOVE_ATOM_PROPERTY(owner, PROP_MOB_HEARD_PITCH, src)
		..()
