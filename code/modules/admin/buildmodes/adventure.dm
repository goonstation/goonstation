// TODO: Unfuck this

/datum/buildmode/adventure
	name = "Adventure"
	desc = {"***********************************************************<br>
Click on the secondary adventure button to begin your adventure journey!<br>
***********************************************************"}
	icon_state = "buildadventure"
	var/tmp/atom/movable/screen/buildmode/buildadventure/adventure_mode
	var/tmp/datum/adventure_submode/submode
	var/tmp/list/submodes = list()

	New()
		..()
		adventure_mode = new(null, holder, src)
		extra_buttons += adventure_mode
		for (var/smt in childrentypesof(/datum/adventure_submode))
			var/datum/adventure_submode/SM = new smt(holder, src)
			submodes += SM.name
			submodes[SM.name] = SM

	copy()
		var/list/copy_env = list()
		copy_env[holder] = holder
		var/datum/buildmode/adventure/new_mode = semi_deep_copy(src, null, copy_env)
		return new_mode

	click_left(atom/object, var/ctrl, var/alt, var/shift)
		if (!submode)
			boutput(usr, "<span class='alert'>Select an adventure mode first.</span>")
			return
		submode.click_left(object, ctrl, alt, shift)
	click_right(atom/object, var/ctrl, var/alt, var/shift)
		if (!submode)
			boutput(usr, "<span class='alert'>Select an adventure mode first.</span>")
			return
		submode.click_right(object, ctrl, alt, shift)
	click_raw(var/atom/object, location, control, params)
		if (!submode)
			boutput(usr, "<span class='alert'>Select an adventure mode first.</span>")
			return
		submode.click_raw(object, location, control, params)

	proc/select_submode()
		var/which = input("Select adventure mode", "Adventure mode", submode ? submode.name : null) as null|anything in submodes
		if (!which)
			return
		if (submode)
			submode.deselected()
		submode = submodes[which]
		submode.selected()
		src.update_button_text(submode.name)

/datum/adventure_submode
	var/name = "Adventure submode"
	var/datum/buildmode_holder/holder
	var/datum/buildmode/adventure/adventure

	New(H, A)
		..()
		holder = H
		adventure = A

	proc/click_left(atom/object, var/ctrl, var/alt, var/shift)
	proc/click_right(atom/object, var/ctrl, var/alt, var/shift)
	proc/click_raw(var/atom/object, location, control, params)
	proc/selected()
	proc/settings(var/ctrl, var/alt, var/shift)
	proc/deselected()


/atom/movable/screen/buildmode/buildadventure
	name = "Click to set adventure settings"
	density = 1
	anchored = ANCHORED
	layer = HUD_LAYER + 1
	plane = PLANE_HUD
	dir = NORTH
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildadventure"
	screen_loc = "NORTH,WEST+4"
	var/datum/buildmode_holder/holder = null
	var/datum/buildmode/adventure/parent = null

	New(L, H, A)
		..()
		holder = H
		parent = A

	clicked(var/list/pa)
		if ("left" in pa)
			parent.select_submode()
		else if (("right" in pa) && parent.submode)
			parent.submode.settings(("ctrl" in pa), ("alt" in pa), ("shift" in pa))
