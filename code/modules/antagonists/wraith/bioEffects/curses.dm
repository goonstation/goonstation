////////////////////
//Wraith curses
////////////////////
/datum/bioEffect/blood_curse
	name = "Blood curse"
	desc = "Curse of blood."
	id = "blood_curse"
	effectType = EFFECT_TYPE_DISABILITY
	can_copy = 0
	isBad = 1
	occur_in_genepools = 0
	acceptable_in_mutini = 0
	probability = 0
	curable_by_mutadone = 0
	var/image/curse_icon

	OnAdd()
		if (ishuman(owner))
			owner.traitHolder?.addTrait("hemophilia")
		curse_icon = image('icons/mob/wraith_ui.dmi', owner, icon_state = "blood_status")
		curse_icon.blend_mode = BLEND_ADD
		curse_icon.plane = PLANE_ABOVE_LIGHTING
		curse_icon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		curse_icon.pixel_y = 28
		curse_icon.alpha = 170
		get_image_group(CLIENT_IMAGE_GROUP_CURSES).add_image(curse_icon)

	OnLife(mult)
		if (probmult(5))
			owner.emote("cough")
			var/turf/T = get_turf(owner)
			make_cleanable(/obj/decal/cleanable/blood,T)
		if (probmult(3))
			owner.visible_message("<span class='alert'>[owner] vomits a lot of blood!</span>")
			playsound(owner.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)
			bleed(owner, rand(5,8), 5)


	OnRemove()
		if (ishuman(owner))
			owner.traitHolder?.removeTrait("hemophilia")
		get_image_group(CLIENT_IMAGE_GROUP_CURSES).remove_image(curse_icon)
		. = ..()

/datum/bioEffect/blindness_curse
	name = "Blind curse"
	desc = "Curse of blindness."
	id = "blind_curse"
	effectType = EFFECT_TYPE_DISABILITY
	can_copy = 0
	isBad = 1
	occur_in_genepools = 0
	acceptable_in_mutini = 0
	probability = 0
	curable_by_mutadone = 0
	var/image/curse_icon

	OnAdd()
		. = ..()
		curse_icon = image('icons/mob/wraith_ui.dmi', owner, icon_state = "blood_status")
		curse_icon.blend_mode = BLEND_ADD
		curse_icon.plane = PLANE_ABOVE_LIGHTING
		curse_icon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		curse_icon.pixel_y = 28
		curse_icon.alpha = 170
		get_image_group(CLIENT_IMAGE_GROUP_CURSES).add_image(curse_icon)

	OnLife(mult)
		if (probmult(8) && ishuman(owner))
			owner.eye_damage += 10
			if (owner.eye_damage > 90)
				owner.emote("blink")
				boutput(owner, "<span class='alert'>A shadowy veil falls over your vision.</span>")
			else if (owner.eye_damage > 50)
				owner.emote("blink")
				boutput(owner, "<span class='alert'>You can't seem to be able to see things clearly anymore.</span>")
			else
				owner.emote("blink")
				boutput(owner, "<span class='notice'>You blink and notice that your vision is blurier than before.<span>")

	OnRemove()
		. = ..()
		get_image_group(CLIENT_IMAGE_GROUP_CURSES).remove_image(curse_icon)

/datum/bioEffect/weak_curse
	name = "Weakness curse"
	desc = "Curse of enfeeblement."
	id = "weak_curse"
	effectType = EFFECT_TYPE_DISABILITY
	can_copy = 0
	isBad = 1
	occur_in_genepools = 0
	acceptable_in_mutini = 0
	probability = 0
	curable_by_mutadone = 0
	var/image/curse_icon

	OnAdd()
		if (ishuman(owner))
			owner.setStatus("weakcurse", duration = null)
		curse_icon = image('icons/mob/wraith_ui.dmi', owner, icon_state = "weak_status")
		curse_icon.blend_mode = BLEND_ADD
		curse_icon.plane = PLANE_ABOVE_LIGHTING
		curse_icon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
		curse_icon.pixel_y = 28
		curse_icon.alpha = 170
		get_image_group(CLIENT_IMAGE_GROUP_CURSES).add_image(curse_icon)

	OnLife(mult)
		if (probmult(5))
			boutput(owner, "<span class='notice'>You suddenly feel very [pick("winded", "tired")].</span>")
			owner.changeStatus("slowed", 10 SECONDS)
		if (probmult(3))
			boutput(owner, pick("<span class='notice'>Your muscles tense up.</span>", "<span class='notice'>You feel light-headed.</span>", "<span class='notice'>Your legs almost give in.</span>"))
			owner.emote("pale")
		if (probmult(3))
			boutput(owner, pick("<span class='notice'>Your conscience slips.</span>", "<span class='notice'>You feel awfully drowsy.</span>"))
			owner.changeStatus("drowsy", 10 SECONDS)

	OnRemove()
		if (ishuman(owner))
			owner.delStatus("weakcurse")
		get_image_group(CLIENT_IMAGE_GROUP_CURSES).remove_image(curse_icon)
		. = ..()

/datum/bioEffect/rot_curse	//Also prevents eating entirely.
	name = "Rot curse"
	desc = "Curse of rot."
	id = "rot_curse"
	effectType = EFFECT_TYPE_DISABILITY
	can_copy = 0
	isBad = 1
	occur_in_genepools = 0
	acceptable_in_mutini = 0
	probability = 0
	curable_by_mutadone = 0
	var/image/curse_icon

	OnAdd()
		if (ishuman(owner))
			owner.bioHolder.AddEffect("stinky")
			curse_icon = image('icons/mob/wraith_ui.dmi', owner, icon_state = "rot_status")
			curse_icon.blend_mode = BLEND_ADD
			curse_icon.plane = PLANE_ABOVE_LIGHTING
			curse_icon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			curse_icon.pixel_y = 26
			curse_icon.alpha = 170
			get_image_group(CLIENT_IMAGE_GROUP_CURSES).add_image(curse_icon)

	OnLife(mult)
		if (probmult(5))
			owner.visible_message("<span class='alert'>[owner] suddenly vomits on the floor!</span>")
			owner.vomit(rand(3,5))
		if (probmult(3))
			owner.emote(pick("cough", "sneeze"))


	OnRemove()
		if (ishuman(owner))
			owner.bioHolder.RemoveEffect("stinky")
		get_image_group(CLIENT_IMAGE_GROUP_CURSES).remove_image(curse_icon)
		. = ..()
