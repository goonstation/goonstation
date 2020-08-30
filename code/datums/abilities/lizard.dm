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

	proc/fix_colors(var/hex)
		var/list/L = hex_to_rgb_list(hex)
		for (var/i in L)
			L[i] = min(L[i], 190)
			L[i] = max(L[i], 50)
		if (L.len == 3)
			return rgb(L["r"], L["g"], L["b"])
		return rgb(22, 210, 22)

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
			return

		if (L?.bioHolder?.mobAppearance)
			var/datum/appearanceHolder/AHs = L.bioHolder.mobAppearance

			var/col1 = AHs.customization_first_color
			var/col2 = AHs.customization_second_color
			var/col3 = AHs.customization_third_color

			AHs.customization_first_color = col3
			AHs.customization_second_color = col1
			AHs.customization_third_color = col2

			L.visible_message("<span class='notice'><b>[L.name]</b> changes colors!</span>")
			L.update_body()

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
			return

		if (L?.bioHolder?.mobAppearance)
			var/datum/appearanceHolder/AHs = L.bioHolder.mobAppearance

			var/which_region = input(L, "Pick which region to color", "Where to color") as null | anything in src.regions

			if (!which_region)
				boutput(L, "<span class='notice'>You leave your pigmentation as-is.</span>")
				return

			var/coloration = input(L, "Please select skin color.", "Character Generation")  as null | color

			if (!coloration)
				boutput(L, "<span class='notice'>You think it looks fine the way it is.</span>")
				return

			actions.start(new/datum/action/bar/lizcolor(L, fix_colors(coloration), regions[which_region], which_region, AHs), L)
			return



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
				spot = "skin"
			if (2)
				AHliz.customization_second_color = color
				spot = "belly splotch"
			if (3)
				AHliz.customization_third_color = color
				spot = "head thing"
		L.visible_message("[L]'s [spot] changes color!", "<span class='notice'>Your [region_name] changes color!</span>")
		L.update_body()
		..()

	onInterrupt()
		boutput(L, "You were interrupted, snapping your [region_name] back to the color it was!")
		..()
