/datum/component/toggle_underwear
	var/underwear_hidden = FALSE
	var/underwear_style = "No Underwear"
	var/obj/item/clothing/under/undersuit = null
	var/obj/ability_button/underwear_toggle/toggle = new

/datum/component/toggle_underwear/Initialize()
	. = ..()
	if(!istype(parent, /obj/item/clothing/under))
		return COMPONENT_INCOMPATIBLE
	undersuit = parent
	LAZYLISTADD(undersuit.ability_buttons, parent)
	undersuit.ability_buttons += toggle
	toggle.the_item = undersuit
	toggle.name = toggle.name + " ([undersuit.name])"
	toggle.target = src
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, PROC_REF(on_remove))

/datum/component/toggle_underwear/proc/tuck_underwear(var/mob/living/carbon/human/H)
	var/datum/appearanceHolder/AH = H.bioHolder.mobAppearance
	if(!AH) return
	if(src.underwear_hidden)
		AH.underwear = src.underwear_style
		src.underwear_style = "No Underwear"
		boutput(H, SPAN_NOTICE("You untuck your underwear from [undersuit]"))
	else
		if(AH.underwear == "No Underwear")
			boutput(H, SPAN_ALERT("You don't have any underwear!"))
			return
		else
			src.underwear_style = AH.underwear
			AH.underwear = "No Underwear"
			boutput(H, SPAN_NOTICE("You tuck your underwear into [undersuit]"))
	src.underwear_hidden = !src.underwear_hidden
	H.update_body()

/datum/component/toggle_underwear/proc/on_remove(var/mob/user)
	var/datum/appearanceHolder/AH
	if(ishuman(user))
		AH = user.bioHolder.mobAppearance
	if(!AH) return
	if(src.underwear_hidden)
		AH.underwear = src.underwear_style
		src.underwear_hidden = FALSE
		src.underwear_style = "No Underwear"
		user.update_body()


/obj/ability_button/underwear_toggle
	name = "(Un)Tuck Underwear"
	requires_equip = TRUE
	var/datum/component/toggle_underwear/target
	execute_ability()
		if(!ishuman(the_mob))
			boutput(the_mob, SPAN_ALERT("You don't have any underwear!"))
			return
		src.target.tuck_underwear(src.the_mob)
		..()
