/datum/component/gear_corrosion
	var/time_to_corrode = 90 SECONDS
	var/max_ttc = 90 SECONDS
	var/initial_chemprot
	var/initial_spacewear
	var/last_decay_ratio
	var/last_decay_time
	var/melt_filter
	var/obj/overlay/durability_pip/pip

TYPEINFO(/datum/component/gear_corrosion)
	initialization_args = list()

/datum/component/gear_corrosion/Initialize()
	. = ..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/show_pip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/hide_pip)

/datum/component/gear_corrosion/RegisterWithParent()
	. = ..()
	var/obj/item/object = src.parent
	if(object.acid_survival_time)
		max_ttc = object.acid_survival_time
		time_to_corrode = max_ttc
	pip = new
	object.vis_contents += pip
	src.initial_chemprot = object.getProperty("chemprot")
	src.initial_spacewear = object.c_flags & SPACEWEAR
	if(istype(object.loc, /mob/living))
		var/mob/living/to_notify = object.loc
		boutput(to_notify,"<span class='alert'>Your [object.name] begins deteriorating in contact with the acid.</span>")
		show_pip()

/datum/component/gear_corrosion/UnregisterFromParent()
	. = ..()
	var/atom/movable/object = src.parent
	object.vis_contents -= pip
	if(melt_filter)
		object.remove_filter("acid_displace")
		melt_filter = null
	pip = null

/datum/component/gear_corrosion/proc/show_pip()
	if(pip)
		pip.invisibility = INVIS_NONE

/datum/component/gear_corrosion/proc/hide_pip()
	if(pip)
		var/obj/object = src.parent
		if(!istype(object.loc, /mob/living)) //don't hide if it's going onto a mob
			pip.invisibility = INVIS_ALWAYS

/datum/component/gear_corrosion/proc/update_pip()
	if(pip)
		if(time_to_corrode <= 0)
			pip.icon_state = "pipoff"
		else
			var/decay_ratio = round((time_to_corrode/max_ttc) * 4.5) //little "slop" so the color progression feels more natural
			pip.icon_state = "pip[decay_ratio]"

/datum/component/gear_corrosion/proc/apply_decay(var/decay_time_amt = 1 SECOND) //currently tuned around being applied with fluidstep, this may need to be rolled into a process
	last_decay_time = TIME
	if(time_to_corrode == 0)
		return
	time_to_corrode -= decay_time_amt
	if(time_to_corrode <= 0)
		time_to_corrode = 0
		oof_the_gear() //kills the gear's chemprot and spaceworthiness. remember to keep original values to restore when mended
	var/decay_ratio = round((time_to_corrode/max_ttc) * 4.5)
	if(decay_ratio != last_decay_ratio)
		var/obj/object = src.parent
		if(!src.melt_filter && decay_ratio <= 1)
			object.add_filter("acid_displace", 0, displacement_map_filter(icon=icon('icons/effects/distort.dmi', "acid"), size=0))
			src.melt_filter = object.get_filter("acid_displace")
			animate(melt_filter, size=8, time=2 SECONDS, easing=SINE_EASING)

	update_pip()

/datum/component/gear_corrosion/proc/apply_mend()
	. = FALSE //return true if item needed repairing
	if(time_to_corrode < max_ttc)
		. = TRUE
		time_to_corrode = min(round(0.04 * max_ttc) + time_to_corrode, max_ttc) //repairs have an expenditure based on percentile of total health
	un_oof_the_gear()
	var/decay_ratio = round((time_to_corrode/max_ttc) * 4.5)
	if(decay_ratio != last_decay_ratio)
		var/obj/object = src.parent
		if(src.melt_filter && decay_ratio > 1)
			object.remove_filter("acid_displace", 0, displacement_map_filter(icon=icon('icons/effects/distort.dmi', "acid"), size=0))
			src.melt_filter = null

	update_pip()

/datum/component/gear_corrosion/proc/oof_the_gear()
	var/obj/item/object = src.parent
	object.setProperty("chemprot",0)
	object.c_flags &= ~SPACEWEAR

/datum/component/gear_corrosion/proc/un_oof_the_gear()
	var/obj/item/object = src.parent
	object.setProperty("chemprot",src.initial_chemprot)
	object.c_flags |= src.initial_spacewear

/obj/overlay/durability_pip
	name = "durability pip"
	desc = "Your gear has taken damage from acid, and will lose its protection if it degrades too much. It can be repaired with a nanoloom."
	icon = 'icons/ui/durability_pip.dmi'
	icon_state = "pip4"
	alpha = 180
	invisibility = INVIS_ALWAYS
	plane = PLANE_HUD
	layer = HUD_LAYER_3
	appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE

	New()
		..()
