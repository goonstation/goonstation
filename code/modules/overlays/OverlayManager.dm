/var/list/screenOverlayLibrary = list()

/mob/var/list/screenoverlays = list()
//Please note that overlays are saved on a per mob basis.
//You need to make sure that they are updated (added to the client screen) in the life proc and on mob login. Or in other ways if not applicable.
//You also need to make sure they are removed in those proc and on logout and on ghosting
//For convenience i have tagged all related additions in other files with "ov1"

/mob/proc/addOverlayComposition(var/compType) //Adds composition type to active compositions on mob
	if(!ispath(compType))return
	if(!screenOverlayLibrary.Find(compType))return
	var/instance = screenOverlayLibrary[compType]
	if(screenoverlays.Find(instance))return //Only one instance per overlay Type. Keep this. Im serious. Else mobs will end up with 324598762 blind overlays
	screenoverlays.Add(instance)
	return

/mob/proc/removeOverlayComposition(var/compType) //Removes composition type from active compositions on mob
	if(!ispath(compType)) return
	if(!screenOverlayLibrary.Find(compType)) return
	var/instance = screenOverlayLibrary[compType]
	if(screenoverlays.Find(instance))
		screenoverlays.Remove(instance)
	return

/mob/proc/hasOverlayComposition(var/compType) //Does that mob have the overlay active?
	if(!ispath(compType)) return
	if(!screenOverlayLibrary.Find(compType)) return
	var/instance = screenOverlayLibrary[compType]
	return screenoverlays.Find(instance)

/mob/proc/updateOverlaysClient(var/client/CL) //Updates the overlays of current mob to given client
	removeOverlaysClient(CL)
	addOverlaysClient(CL)
	return

/mob/proc/addOverlaysClient(var/client/CL) //Adds the overlays of current mob to given client
	if(!CL) return
	for(var/datum/overlayComposition/C in screenoverlays)
		for(var/atom/movable/screen/screenoverlay/S in C.instances)
			CL.screen += S

/mob/proc/removeOverlaysClient(var/client/CL) //Removes all overlays of given client
	if(!CL) return
	for(var/atom/movable/screen/screenoverlay/S in CL.screen)
		CL.screen -= S

//Because dead mobs don't have a life loop
/mob/dead/addOverlayComposition()
	..()
	updateOverlaysClient(src.client)

/mob/dead/removeOverlayComposition()
	..()
	updateOverlaysClient(src.client)

/atom/movable/screen/screenoverlay
	name = ""
	icon = 'icons/effects/overlays/cloudy.dmi'
	layer = HUD_LAYER_UNDER_2
	plane = PLANE_HUD
	screen_loc = "CENTER-7,CENTER-7"

/datum/overlayDefinition
	var/d_icon = 'icons/effects/overlays/cloudy.dmi'
	var/d_icon_state = "cloudy"
	var/d_alpha = 255
	var/d_color = "#ffffff"
	var/d_blend_mode = 1
	var/d_layer = HUD_LAYER_UNDER_2		//18 is just below the ui but above everything else.
	var/d_plane = PLANE_HUD
	var/d_mouse_opacity = 0 //In case you want it to block clicks. For blindness and such.
	var/do_wide_fill = 1 //If true, use underlays to 'fill out' the area that extends to the sides in widescreen
	var/d_screen_loc = "CENTER-7,CENTER-7"

//list of overlay composition stored on mob
//list is applied in life proc?! and login

/datum/overlayComposition
	var/list/definitions = list()
	var/list/instances = list()

	New()

		var/list/added_for_fill = list()

		for(var/datum/overlayDefinition/D in definitions)
			var/atom/movable/screen/screenoverlay/S = new()
			S.icon = D.d_icon
			S.icon_state = D.d_icon_state
			S.alpha = D.d_alpha
			S.color = D.d_color
			S.blend_mode = D.d_blend_mode
			S.layer = D.d_layer
			S.plane = D.d_plane
			S.mouse_opacity = D.d_mouse_opacity
			S.screen_loc = D.d_screen_loc

			instances.Add(S)

			if (!D.do_wide_fill) continue

			var/matrix/flip = matrix()
			flip.Scale(-1,1)

			var/atom/movable/screen/screenoverlay/fill_left = new()
			fill_left.icon = D.d_icon
			fill_left.icon_state = D.d_icon_state
			fill_left.alpha = D.d_alpha
			fill_left.color = D.d_color
			fill_left.blend_mode = D.d_blend_mode
			fill_left.layer = D.d_layer
			fill_left.plane = D.d_plane
			fill_left.mouse_opacity = D.d_mouse_opacity
			//fill_left.filters = filter (type="blur", size=0.5)
			fill_left.transform = flip
			//fill_left.pixel_x = -480
			fill_left.screen_loc = "LEFT-12,CENTER-7"
			fill_left.appearance_flags = TILE_BOUND | PIXEL_SCALE

			var/atom/movable/screen/screenoverlay/fill_right = new()
			fill_right.icon = D.d_icon
			fill_right.icon_state = D.d_icon_state
			fill_right.alpha = D.d_alpha
			fill_right.color = D.d_color
			fill_right.blend_mode = D.d_blend_mode
			fill_right.layer = D.d_layer
			fill_right.plane = D.d_plane
			fill_right.mouse_opacity = D.d_mouse_opacity
			//fill_right.filters = filter (type="blur", size=0.5)
			fill_right.transform = flip
			//fill_right.pixel_x = 480
			fill_right.screen_loc = "RIGHT+12,CENTER-7"
			fill_right.appearance_flags = TILE_BOUND | PIXEL_SCALE

			added_for_fill += fill_left
			added_for_fill += fill_right

		for(var/atom/movable/screen/screenoverlay/S in added_for_fill)
			instances.Add(S)

		return ..()

	proc/removeFromMob(var/mob/M)
		return

	proc/addToMob(var/mob/M) //Do not allow more than once instance of any given type. There is a reason for this,
		return

// Debug stuff

/proc/removerlays()
	for(var/atom/movable/screen/screenoverlay/F in world)
		del(F)
		LAGCHECK(LAG_LOW)

	return

/proc/overlaytest()
	var/numover = input(usr, "How many overlays?") as null|num
	if (!numover)
		return
	var/list/overlist = list()
	for(var/i=0, i<numover, i++)
		var/atom/movable/screen/screenoverlay/O = createover(i)
		if(O) overlist.Add(O)

	boutput(usr, "<b><font color=\"gold\"> [overlist.len] overlays defined.</font></b>")

	if(overlist.len)
		for(var/atom/movable/screen/screenoverlay/F in overlist)
			F.add_to_client(usr.client)

		switch(alert("Would you like to add these overlays to everyone?",,"Yes","No"))
			if("Yes")
				for(var/client/C in clients)
					if(C == usr.client) continue
					for(var/atom/movable/screen/screenoverlay/F in overlist)
						F.add_to_client(C)
			if("No")
				for(var/atom/movable/screen/screenoverlay/F in overlist)
					usr.client.screen -= F
			 return

	return

/proc/createover(var/i)
/*
	var/atom/movable/screen/screenoverlay/F = new()

	var/state = input(usr, "Icon state?","Overlay #[i]", "wiggle") in icon_states(icon('icons/effects/480x480.dmi'))
	var/blendm = input(usr, "Blend mode?","Overlay #[i] (1=normal,2=add,3=sub,4=mult)", 1) in list(1, 2, 3, 4)
	var/ialpha = input(usr, "Alpha?","Overlay #[i] (1-255 opaque)", 255) as num
	var/icolor = input(usr, "Color?","Overlay #[i] (hex)", "#ffffff")
	var/ilayer = input(usr, "Layer?","Overlay #[i]", HUD_LAYER_UNDER_2) as num

	if(length(state) && blendm && ialpha && length(icolor))
		F.icon_state = state
		F.blend_mode = blendm
		F.alpha = clamp(ialpha, 0, 255)
		F.color = icolor
		F.layer = ilayer

		return F
*/
	return null

// END Debug stuff

// Compositions below ...

/* commented out until tobba can fix it (please fix it tobba I do not know how) and replacement added below with the blinded_l & blinded_r overlays
/datum/overlayComposition/blinded
	New()
		var/datum/overlayDefinition/spot = new()
		spot.d_icon = 'icons/effects/overlays/knockout2.dmi'
		spot.d_icon_state = "knockout2"
		spot.d_blend_mode = 3 //sub
		spot.d_mouse_opacity = 1 //its gonna be use for blindness. Dont let them click stuff.
		definitions.Add(spot)

		var/datum/overlayDefinition/fluff = new()
		fluff.d_icon = 'icons/effects/overlays/meatysmall.dmi'
		fluff.d_icon_state = "meatysmall"
		fluff.d_blend_mode = 3 //sub
		fluff.d_color = "#eeeeee"
		definitions.Add(fluff)

		return ..()
*/
/datum/overlayComposition/flashed
	New()
		var/datum/overlayDefinition/beam = new()
		beam.d_icon = 'icons/effects/overlays/beamout.dmi'
		beam.d_icon_state = "beamout"
		beam.d_blend_mode = 2 //add
		beam.d_color = "#eeeeee"
		definitions.Add(beam)

		var/datum/overlayDefinition/spot = new()
		spot.d_icon = 'icons/effects/overlays/meatysmall.dmi'
		spot.d_icon_state = "meatysmall"
		spot.d_blend_mode = 2 //add
		spot.d_color = "#eeeeee"
		definitions.Add(spot)
		return ..()

/datum/overlayComposition/smoke
	New()
		var/datum/overlayDefinition/spot = new()
		spot.d_icon = 'icons/effects/overlays/knockout.dmi'
		spot.d_icon_state = "knockout"
		spot.d_blend_mode = 3 //sub
		spot.d_color = "#eeeeee"
		definitions.Add(spot)

		var/datum/overlayDefinition/one = new()
		one.d_icon = 'icons/effects/overlays/cloudy.dmi'
		one.d_icon_state = "cloudy"
		one.d_blend_mode = 3 //sub
		one.d_color = "#aaaaaa"
		definitions.Add(one)

		var/datum/overlayDefinition/two = new()
		two.d_icon = 'icons/effects/overlays/cloudy.dmi'
		two.d_icon_state = "cloudy"
		two.d_blend_mode = 2 //add
		two.d_color = "#bbbbbb"
		definitions.Add(two)

		return ..()

/datum/overlayComposition/heat
	New()
		var/datum/overlayDefinition/part1 = new()
		part1.d_icon = 'icons/effects/overlays/meatysmall.dmi'
		part1.d_icon_state = "meatysmall"
		part1.d_blend_mode = 2
		part1.d_color = "#ff0000"
		part1.d_alpha = 100
		definitions.Add(part1)

		var/datum/overlayDefinition/part2 = new()
		part2.d_icon = 'icons/effects/overlays/cloudy.dmi'
		part2.d_icon_state = "cloudy"
		part2.d_blend_mode = 2
		part2.d_color = "#ffff00"
		part1.d_alpha = 100
		definitions.Add(part2)
		return ..()

/datum/overlayComposition/anima
	New()
		var/datum/overlayDefinition/zero = new()
		zero.d_icon = 'icons/effects/overlays/beamout.dmi'
		zero.d_icon_state = "beamout"
		zero.d_blend_mode = 4
		zero.d_color = "#5C0E80"
		zero.d_alpha = 255
		definitions.Add(zero)
		return ..()

/datum/overlayComposition/triplemeth
	New()
		var/datum/overlayDefinition/zero = new()
		zero.d_icon = 'icons/effects/overlays/meatysmall.dmi'
		zero.d_icon_state = "meatysmall"
		zero.d_blend_mode = 2
		zero.d_color = "#ff0000"
		zero.d_alpha = 75
		definitions.Add(zero)

		var/datum/overlayDefinition/one = new()
		one.d_icon = 'icons/effects/overlays/cloudy.dmi'
		one.d_icon_state = "cloudy"
		one.d_blend_mode = 2
		one.d_color = "#00ff00"
		one.d_alpha = 75
		definitions.Add(one)

		var/datum/overlayDefinition/two = new()
		two.d_icon = 'icons/effects/overlays/beamout.dmi'
		two.d_icon_state = "beamout"
		two.d_blend_mode = 2
		two.d_color = "#0000ff"
		two.d_alpha = 75
		definitions.Add(two)

		return ..()

/datum/overlayComposition/static_noise
	var/special_blend = BLEND_DEFAULT
	New()
		var/datum/overlayDefinition/zero = new()
		zero.d_icon = 'icons/effects/overlays/noise.dmi'
		zero.d_icon_state = "noise"
		zero.d_blend_mode = BLEND_DEFAULT
		zero.d_color = "#bbbbbb"
		zero.d_mouse_opacity = 1
		definitions.Add(zero)

		return ..()

/datum/overlayComposition/static_noise/sub
	special_blend = BLEND_SUBTRACT

/datum/overlayComposition/low_signal
	New()
		var/datum/overlayDefinition/dither = new()
		dither.d_icon = 'icons/effects/overlays/weldingmask.dmi'
		dither.d_icon_state = "weldingmask"
		dither.d_alpha = 240
		dither.d_blend_mode = 2
		dither.d_mouse_opacity = 0
		definitions.Add(dither)

		var/datum/overlayDefinition/zero = new()
		zero.d_icon = 'icons/effects/overlays/noise.dmi'
		zero.d_icon_state = "noise"
		zero.d_blend_mode = 5
		zero.d_color = "#111"
		zero.d_alpha = 100
		zero.d_mouse_opacity = 0
		definitions.Add(zero)

		return ..()


/datum/overlayComposition/weldingmask
	New()
		var/datum/overlayDefinition/dither = new()
		dither.d_icon = 'icons/effects/overlays/weldingmask.dmi'
		dither.d_icon_state = "weldingmask"
		dither.d_blend_mode = 2
		dither.d_mouse_opacity = 0
		definitions.Add(dither)

		return ..()

/datum/overlayComposition/steelmask
	New()
		var/datum/overlayDefinition/dither = new()
		dither.d_icon = 'icons/effects/overlays/weldingmask.dmi'
		dither.d_icon_state = "steelmask"
		dither.d_blend_mode = 2
		dither.d_mouse_opacity = 0
		definitions.Add(dither)

		return ..()


// temporary blindness overlay until the other one is fixed
/datum/overlayComposition/limited_sight
	New()
		var/datum/overlayDefinition/dither = new()
		dither.d_icon = 'icons/effects/overlays/knockout2t.dmi'
		dither.d_icon_state = "knockout2t"
		dither.d_blend_mode = 2
		dither.d_mouse_opacity = 0 // fuck not being able to click on things, if we want blindness to have disadvantages then find something else
		dither.d_screen_loc = "CENTER-7,CENTER-7"
		definitions.Add(dither)

		return ..()

// temporary blindness overlay until the other one is fixed
/datum/overlayComposition/blinded
	New()
		var/datum/overlayDefinition/dither = new()
		dither.d_icon = 'icons/effects/overlays/knockout2t.dmi'
		dither.d_icon_state = "knockout2t"
		dither.d_blend_mode = 2
		dither.d_mouse_opacity = 0 // fuck not being able to click on things, if we want blindness to have disadvantages then find something else
		dither.d_screen_loc = "CENTER-7,CENTER-7"
		definitions.Add(dither)

		var/datum/overlayDefinition/meaty = new()
		meaty.d_icon = 'icons/effects/overlays/meatyC.dmi'
		meaty.d_icon_state = "meatyC"
		meaty.d_blend_mode = 2
		meaty.d_alpha = 30//140
		//meaty.d_color = "#610306"
		definitions.Add(meaty)
		return ..()

/datum/overlayComposition/blinded_r_eye
	New()
		var/datum/overlayDefinition/dither = new()
		dither.d_icon = 'icons/effects/overlays/Rtrans.dmi'
		dither.d_icon_state = "Rtrans"
		dither.d_blend_mode = 2
		//dither.d_mouse_opacity = 1
		//dither.do_wide_fill = 0
		definitions.Add(dither)

		var/datum/overlayDefinition/meaty = new()
		meaty.d_icon = 'icons/effects/overlays/meatyR.dmi'
		meaty.d_icon_state = "meatyR"
		meaty.d_blend_mode = 2
		meaty.d_alpha = 90
		meaty.d_color = "#610306"
		//meaty.do_wide_fill = 0
		definitions.Add(meaty)
		return ..()

/datum/overlayComposition/blinded_l_eye
	New()
		var/datum/overlayDefinition/dither = new()
		dither.d_icon = 'icons/effects/overlays/Ltrans.dmi'
		dither.d_icon_state = "Ltrans"
		dither.d_blend_mode = 2
		//dither.d_mouse_opacity = 1
		//dither.do_wide_fill = 0
		definitions.Add(dither)

		var/datum/overlayDefinition/meaty = new()
		meaty.d_icon = 'icons/effects/overlays/meatyL.dmi'
		meaty.d_icon_state = "meatyL"
		meaty.d_blend_mode = 2
		meaty.d_alpha = 90
		meaty.d_color = "#610306"
		//meaty.do_wide_fill = 0
		definitions.Add(meaty)

		return ..()

/datum/overlayComposition/shuttle_warp
	var/warp_dir = "warp"
	New()
		var/datum/overlayDefinition/warp = new()
#if defined(HALLOWEEN) && defined(SECRETS_ENABLED)
		warp.d_icon = '+secret/icons/effects/overlays/warp.dmi'
#else
		warp.d_icon = 'icons/effects/overlays/warp.dmi'
#endif
		warp.d_icon_state = src.warp_dir
		warp.d_blend_mode = 1
		warp.d_layer = BACKGROUND_LAYER
		warp.d_plane = PLANE_FLOOR
		definitions.Add(warp)

		return ..()

/datum/overlayComposition/shuttle_warp/ew
	warp_dir = "warp_ew"

/datum/overlayComposition/flockmindcircuit
	var/alpha = 140

	New()
		var/datum/overlayDefinition/flockmindcircuit = new()
		flockmindcircuit.d_icon = 'icons/effects/overlays/flockmindcircuit.dmi'
		flockmindcircuit.d_icon_state = "flockmindcircuit"
		flockmindcircuit.d_blend_mode = BLEND_DEFAULT
		flockmindcircuit.d_alpha = src.alpha
		definitions.Add(flockmindcircuit)

		return ..()

	flocktrace_death
		alpha = 40

/datum/overlayComposition/sniper_scope
	New()
		var/datum/overlayDefinition/sniper_scope = new()
		sniper_scope.d_icon = 'icons/effects/overlays/sniper_scope.dmi'
		sniper_scope.d_icon_state = "sniper_scope"
		sniper_scope.do_wide_fill = 0
		definitions.Add(sniper_scope)

		return ..()


/datum/overlayComposition/ironsight_vignette
	New()
		var/datum/overlayDefinition/vignette = new()
		vignette.d_icon = 'icons/effects/overlays/ironsight_vignette.dmi'
		vignette.d_icon_state = "ironsight_vignette"
		vignette.d_blend_mode = 2
		vignette.d_screen_loc = "CENTER-10,CENTER-7"
		vignette.do_wide_fill = 0
		definitions.Add(vignette)

		return ..()

/datum/overlayComposition/ironsight_vignette_scope
	New()
		var/datum/overlayDefinition/vignette = new()
		vignette.d_icon = 'icons/effects/overlays/ironsight_vignette.dmi'
		vignette.d_icon_state = "ironsight_vignette_scope"
		vignette.d_blend_mode = 2
		vignette.d_screen_loc = "CENTER-10,CENTER-7"
		vignette.do_wide_fill = 0
		definitions.Add(vignette)

		return ..()
    
/datum/overlayComposition/telephoto
	New()
		var/datum/overlayDefinition/telephoto = new()
		telephoto.d_icon = 'icons/effects/overlays/sniper_scope.dmi'
		telephoto.d_icon_state = "telephoto"
		telephoto.do_wide_fill = 1
		definitions.Add(telephoto)

		return ..()



/datum/overlayComposition/insanity
	New()
		var/datum/overlayDefinition/insanity = new()
		insanity.d_icon = 'icons/effects/overlays/insanity.dmi'
		insanity.d_icon_state = "insanity"
		insanity.d_blend_mode = 2
		insanity.do_wide_fill = 0
		//insanity.d_alpha = 190
		insanity.d_screen_loc = "CENTER-10,CENTER-7"
		definitions.Add(insanity)

		return ..()

/datum/overlayComposition/insanity_light
	New()
		var/datum/overlayDefinition/insanity = new()
		insanity.d_icon = 'icons/effects/overlays/insanity.dmi'
		insanity.d_icon_state = "insanity"
		insanity.d_blend_mode = 2
		insanity.do_wide_fill = 0
		insanity.d_alpha = 120
		insanity.d_screen_loc = "CENTER-10,CENTER-7"
		definitions.Add(insanity)

		return ..()

/datum/overlayComposition/silicon_rad_light
	New()
		var/datum/overlayDefinition/interference = new()
		interference.d_icon = 'icons/effects/overlays/silicon_rad_light.dmi'
		interference.d_icon_state = "interference"
		interference.d_mouse_opacity = FALSE
		interference.d_color = "#999999"
		interference.d_alpha = 100
		definitions.Add(interference)
		return ..()

/datum/overlayComposition/silicon_rad_medium
	New()
		var/datum/overlayDefinition/interference = new()
		interference.d_icon = 'icons/effects/overlays/silicon_rad_medium.dmi'
		interference.d_icon_state = "interference"
		interference.d_mouse_opacity = FALSE
		interference.d_color = "#777777"
		interference.d_alpha = 150
		definitions.Add(interference)
		return ..()

/datum/overlayComposition/silicon_rad_heavy
	New()
		var/datum/overlayDefinition/interference = new()
		interference.d_icon = 'icons/effects/overlays/silicon_rad_heavy.dmi'
		interference.d_icon_state = "interference"
		interference.d_mouse_opacity = FALSE
		interference.d_color = "#555555"
		interference.d_alpha = 200
		definitions.Add(interference)
		return ..()

/datum/overlayComposition/silicon_rad_extreme
	New()
		var/datum/overlayDefinition/interference = new()
		interference.d_icon = 'icons/effects/overlays/silicon_rad_extreme.dmi'
		interference.d_icon_state = "interference"
		interference.d_mouse_opacity = FALSE
		interference.d_color = "#999999"
		interference.d_alpha = 150
		definitions.Add(interference)
		return ..()
