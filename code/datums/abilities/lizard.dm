/mob/living/carbon/human/proc/give_lizard_powers()
	if (ishuman(src)) // not4long
		var/datum/abilityHolder/lizard/A = src.get_ability_holder(/datum/abilityHolder/lizard)
		if (A && istype(A))
			return
		var/datum/abilityHolder/lizard/W = src.add_ability_holder(/datum/abilityHolder/lizard)
		W.addAbility(/datum/targetable/lizardAbility/colorshift)
		W.addAbility(/datum/targetable/lizardAbility/colorchange)
		W.addAbility(/datum/targetable/lizardAbility/regrow_tail)
	else return

/mob/living/carbon/human/proc/remove_lizard_powers()
	if (ishuman(src))
		var/datum/abilityHolder/lizard/W = src.get_ability_holder(/datum/abilityHolder/lizard)
		if (W && istype(W))
			W.removeAbility(/datum/targetable/lizardAbility/colorshift)
			W.removeAbility(/datum/targetable/lizardAbility/colorchange)
			W.removeAbility(/datum/targetable/lizardAbility/regrow_tail)
			src.remove_ability_holder(/datum/abilityHolder/lizard)
	else return

/mob/living/carbon/human/proc/update_lizard_parts()
	if (ishuman(src))
		var/mob/living/carbon/human/liz = src
		if(!liz?.limbs)
			return
		if (istype(liz.limbs.l_arm, /obj/item/parts/human_parts/arm/mutant/lizard ))
			var/obj/item/parts/human_parts/LA = liz.limbs.l_arm
			LA.colorize_limb_icon()
			LA.set_skin_tone()
		if (istype(liz.limbs.r_arm, /obj/item/parts/human_parts/arm/mutant/lizard ))
			var/obj/item/parts/human_parts/RA = liz.limbs.r_arm
			RA.colorize_limb_icon()
			RA.set_skin_tone()
		if (istype(liz.limbs.l_leg, /obj/item/parts/human_parts/leg/mutant/lizard ))
			var/obj/item/parts/human_parts/LL = liz.limbs.l_leg
			LL.colorize_limb_icon()
			LL.set_skin_tone()
		if (istype(liz.limbs.r_leg, /obj/item/parts/human_parts/leg/mutant/lizard ))
			var/obj/item/parts/human_parts/RL = liz.limbs.r_leg
			RL.colorize_limb_icon()
			RL.set_skin_tone()
		if (liz.organHolder?.head)
			var/obj/item/organ/head/hed = liz.organHolder.head
			if(hed.head_type == HEAD_LIZARD)
				hed.UpdateIcon(/*makeshitup*/ null, /*ignore_transplant*/TRUE) // Chromatophores are chromatophores
			else
				hed.UpdateIcon(/*makeshitup*/ null, /*ignore_transplant*/FALSE)
		if (istype(liz?.organHolder.tail, /obj/item/organ/tail/lizard))
			var/obj/item/organ/tail/T = liz.organHolder.tail
			T.colorize_tail(liz.bioHolder.mobAppearance)
		liz?.bioHolder?.mobAppearance.UpdateMob()

/datum/abilityHolder/lizard
	topBarRendered = 1
	points = 0
	regenRate = 0	// eat some kidneys or something
	pointName = "Metachroitic Factor"

/datum/targetable/lizardAbility
	icon = 'icons/mob/genetics_powers.dmi'
	icon_state = "lizard"
	cooldown = 0
	last_cast = 0
	targeted = 0
	preferred_holder_type = /datum/abilityHolder/lizard
	var/mob/living/carbon/human/L

	onAttach(datum/abilityHolder/H)
		. = ..()
		if(ishuman(holder.owner))
			L = holder.owner
		return

/datum/targetable/lizardAbility/regrow_tail
	name = "Regrow Tail"
	desc = "Regrow your tail... (If cast while you have a tail, shoot off your tail and regrow a new one)"
	cooldown = 2 MINUTES
	targeted = 0
	pointCost = 2

	cast()
		if (..())
			return 1

		if (L.mutantrace && !istype(L.mutantrace, /datum/mutantrace/lizard) || !L.organHolder)
			boutput(L, "<span class='notice'>You don't have any chromatophores.</span>")
			return 1

		//shoot off tail
		if (L.organHolder?.tail)
			var/obj/critter/livingtail/C = new /obj/critter/livingtail(get_turf(src.holder.owner))
			playsound(src, 'sound/impact_sounds/Slimy_Splat_1.ogg', 30, 1)
			make_cleanable(/obj/decal/cleanable/blood/splatter, L.loc)
			C.tail_memory = L.organHolder.tail
			C.primary_color = L.organHolder.tail.organ_color_2
			C.secondary_color = L.organHolder.tail.organ_color_1
			C.setup_overlays()
			var/obj/item/organ/tail/lizard/T = L.organHolder.drop_organ("tail")
			T.set_loc(C)

		//simply make a new tail
		L.visible_message("<span class='notice'><b>[L.name]</b> visibly exerts [himself_or_herself(L)] and a new tail starts to sprout!</span>")
		L.organHolder.receive_organ(new/obj/item/organ/tail/lizard, "tail", 0.0, 1)


/datum/targetable/lizardAbility/colorshift
	name = "Chromatophore Shift"
	desc = "Swap the colors of your scales around."
	targeted = 0
	pointCost = 1

	cast()
		if (..())
			return 1

		if (L.mutantrace && !istype(L.mutantrace, /datum/mutantrace/lizard))
			boutput(L, "<span class='notice'>You don't have any chromatophores.</span>")
			return 1

		if (L?.bioHolder?.mobAppearance)
			var/datum/appearanceHolder/AHs = L.bioHolder.mobAppearance

			var/col1 = AHs.customization_first_color
			var/col2 = AHs.customization_second_color
			var/col3 = AHs.customization_third_color

			AHs.customization_first_color = col3
			AHs.customization_second_color = col1
			AHs.customization_third_color = col2
			AHs.s_tone = AHs.customization_first_color

			L.visible_message("<span class='notice'><b>[L.name]</b> changes colors!</span>")
			L.update_lizard_parts()

/datum/targetable/lizardAbility/colorchange
	name = "Chromatophore Activation"
	desc = "Change the color of your scales."
	targeted = 0
	pointCost = 5
	var/list/regions = list("Episcutus" = 1, "Ventral Aberration" = 2, "Sagittal Crest" = 3)

	cast()
		if (..())
			return 1

		if (L.mutantrace && !istype(L.mutantrace, /datum/mutantrace/lizard))
			boutput(L, "<span class='notice'>You're fresh out of chromatophores.</span>")
			return 1

		if (L?.bioHolder?.mobAppearance)
			var/datum/appearanceHolder/AHs = L.bioHolder.mobAppearance

			var/which_region = input(L, "Pick which region to color", "Where to color") as null | anything in src.regions

			if (!which_region)
				boutput(L, "<span class='notice'>You leave your pigmentation as-is.</span>")
				return 1

			var/coloration = input(L, "Please select skin color.", "Character Generation")  as null | color

			if (!coloration)
				boutput(L, "<span class='notice'>You think it looks fine the way it is.</span>")
				return 1

			actions.start(new/datum/action/bar/lizcolor(L, fix_colors(coloration), regions[which_region], which_region, AHs), L)


/datum/action/bar/lizcolor
	duration = 7 SECONDS
	interrupt_flags = INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "lizcolor"
	var/mob/living/carbon/human/L
	var/color
	var/region
	var/region_name
	var/datum/appearanceHolder/AHliz

	New(var/mob/living/carbon/human/M, var/clr, var/part, var/partname, var/AHs)
		L = M
		if (!AHs)
			interrupt(INTERRUPT_ALWAYS) // how...
			return
		color = clr
		region = part
		region_name = partname
		AHliz = AHs
		L.visible_message("[L] tenses up and starts changing color.", "<span class='notice'>You focus on your [region_name], trying to change its color.</span>")
		..()

	onEnd()
		if(prob(25))
			L.emote(pick("fart", "burp"))
		var/spot
		switch(region)
			if (1)
				AHliz.customization_first_color = color
				AHliz.s_tone = color
				spot = "skin"
			if (2)
				AHliz.customization_second_color = color
				spot = "belly splotch"
			if (3)
				AHliz.customization_third_color = color
				spot = "head thing"
		L.visible_message("[L]'s [spot] changes color!", "<span class='notice'>Your [region_name] changes color!</span>")
		L.update_lizard_parts()
		..()

	onInterrupt()
		boutput(L, "You were interrupted, snapping your [region_name] back to the color it was!")
		..()
