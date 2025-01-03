// Note: Hard hat and engineering space helmet can be found in helments.dm, the cake hat in hats.dm.

/obj/item/device/light
	var/on = 0
	var/icon_on = "flight1"
	var/icon_off = "flight0"
	var/col_r = 0.5
	var/col_g = 0.5
	var/col_b = 0.5
	var/brightness = 1
	var/height = 1
	var/datum/light/light
	var/light_type = /datum/light/point

	New()
		..()
		if(ispath(light_type))
			light = new light_type
			light.set_brightness(src.brightness)
			light.set_color(col_r, col_g, col_b)
			light.set_height(src.height)
			light.attach(src)

	pickup(mob/user)
		..()
		if (light)
			light.attach(user)

	dropped(mob/user)
		..()
		if (light)
			SPAWN(0)
				if (src.loc != user)
					light.attach(src)

	disposing()
		if(light)
			qdel(light)
		..()

TYPEINFO(/obj/item/device/light/flashlight)
	mats = 2

ADMIN_INTERACT_PROCS(/obj/item/device/light/flashlight, proc/toggle)

/obj/item/device/light/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon_state = "flight0"
	item_state = "flight"
	icon_on = "flight1"
	icon_off = "flight0"
	var/icon_broken = "flightbroken"
	w_class = W_CLASS_SMALL
	flags = TABLEPASS | CONDUCT
	c_flags = ONBELT
	m_amt = 50
	g_amt = 20
	var/emagged = 0
	var/broken = 0
	col_r = 0.9
	col_g = 0.8
	col_b = 0.7
	light_type = null
	brightness = 4.6

	var/datum/component/loctargeting/medium_directional_light/light_dir
	New(loc, R = initial(col_r), G = initial(col_g), B = initial(col_b))
		..()
		col_r = R
		col_g = G
		col_b = B
		light_dir = src.AddComponent(/datum/component/loctargeting/medium_directional_light, col_r * 255, col_g * 255, col_b  * 255, 210)
		light_dir.update(0)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if (user)
				user.show_text("You short out the voltage regulator in the lighting circuit.", "blue")
			src.emagged = 1
		else
			if (user)
				user.show_text("The regulator is already burned out.", "red")
			return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You repair the voltage regulators.", "blue")
		src.emagged = 0
		return 1

	attack_self(mob/user)
		src.toggle(user, TRUE)

	proc/toggle(var/mob/user, activated_inhand = FALSE)
		if (src.broken)
			name = "broken flashlight"
			return

		src.on = !src.on
		playsound(src, 'sound/items/penclick.ogg', 30, TRUE)
		if (src.on)
			set_icon_state(src.icon_on)
			if (src.emagged) // Burn them all!
				user?.apply_flash(60, 2, 0, 0, rand(2, 8), rand(1, 15), 0, 25, 100, stamina_damage = 70, disorient_time = 10)
				for (var/mob/M in oviewers(2, get_turf(src)))
					if (in_cone_of_vision(user, M)) // If the mob is in the direction we're looking
						var/mob/living/target = M
						if (istype(target))
							target.apply_flash(60, 8, 0, 0, rand(2, 8), rand(1, 15), 0, 30, 100, stamina_damage = 190, disorient_time = 50)
							logTheThing(LOG_COMBAT, user || usr, "flashes [constructTarget(target,"combat")] with an emagged flashlight.")
				user?.visible_message(SPAN_ALERT("The [src] in [user]'s hand bursts with a blinding flash!"), SPAN_ALERT("The bulb in your hand explodes with a blinding flash!"))
				on = 0
				light_dir.update(0)
				icon_state = icon_broken
				name = "broken [name]"
				src.broken = 1
				return
			else
				light_dir.update(1)
		else
			set_icon_state(src.icon_off)
			light_dir.update(0)

		if (activated_inhand)
			var/obj/ability_button/flashlight_toggle/flashlight_button = locate(/obj/ability_button/flashlight_toggle) in src.ability_buttons
			flashlight_button.icon_state = src.on ? "lighton" : "lightoff"

/obj/item/device/light/flashlight/abilities = list(/obj/ability_button/flashlight_toggle)

/obj/item/device/light/flashlight/security
	name = "security flashlight"
	desc = "A hand-held emergency flashlight used by Nanotrasen corporate security. Resistant to electromagnetic fields."
	icon_state = "flight_sec0"
	item_state = "flight_sec"
	icon_on = "flight_sec1"
	icon_off = "flight_sec0"

	emag_act(mob/user, obj/item/card/emag/E)
		return 0


ADMIN_INTERACT_PROCS(/obj/item/device/light/glowstick, proc/turnon, proc/burst)
/obj/item/device/light/glowstick // fuck yeah space rave
	icon = 'icons/obj/lighting.dmi'
	icon_state = "glowstick-green0"
	var/base_state = "glowstick-green"
	name = "emergency glowstick"
	desc = "A small tube that reacts chemicals in order to produce a larger radius of illumination than PDA lights. A label on it reads, WARNING: USE IN RAVES, DANCING, OR FUN WILL VOID WARRANTY."// I love the idea of a glowstick having a warranty so I'm leaving the description like this
	w_class = W_CLASS_SMALL
	flags =  TABLEPASS
	c_flags = ONBELT
	var/heated = 0
	col_r = 0
	col_g = 0.9
	col_b = 0.1
	brightness = 0.33
	height = 0.75
	var/color_name = "green"
	light_type = null
	var/datum/component/loctargeting/sm_light/light_c

	New()
		..()
		light_c = src.AddComponent(/datum/component/loctargeting/sm_light, col_r*255, col_g*255, col_b*255, 255 * brightness)
		light_c.update(0)

	HYPsetup_DNA(var/datum/plantgenes/passed_genes, var/obj/machinery/plantpot/harvested_plantpot, var/datum/plant/origin_plant, var/quality_status)
		var/type = pick(concrete_typesof(/obj/item/device/light/glowstick/))
		var/obj/item/device/light/glowstick/newstick = new type(src.loc)
		newstick.light_c.a = clamp(passed_genes?.get_effective_value("potency")/60, 0.33, 1) * 255
		newstick.turnon()
		qdel(src)
		return newstick

	proc/burst()
		var/turf/T = get_turf(src.loc)
		make_cleanable( /obj/decal/cleanable/generic,T)
		make_cleanable( /obj/decal/cleanable/greenglow,T)
		qdel(src)

	proc/turnon()
		on = 1
		icon_state = "[base_state][on]"
		light_c.update(1)

	//Can be heated. Has chance to explode when heated. After heating, can explode when thrown or fussed with!
	attackby(obj/item/W, mob/user)
		if ((isweldingtool(W) && W:try_weld(user,0,-1,0,0)) || istype(W, /obj/item/device/igniter) || ((istype(W, /obj/item/device/light/zippo) || istype(W, /obj/item/match) || istype(W, /obj/item/device/light/candle) || istype(W, /obj/item/clothing/mask/cigarette)) && W:on) || W.burning)
			user.visible_message(SPAN_ALERT("<b>[user]</b> heats [src] with [W]."))
			src.heated += 1
			if (src.heated >= 3 || prob(5 + (heated * 20)))
				user.visible_message(SPAN_ALERT("[src] bursts open, spraying hot liquid all over <b>[user]</b>! What a [pick("moron", "dummy", "chump", "doofus", "punk", "jerk", "bad idea")]!"))
				if (user.reagents)
					user.reagents.add_reagent("radium", 8, null, T0C + heated * 200)
				burst()
		else
			return ..()
	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if((temperature > T0C+400) && on)
			if(iscarbon(src.loc))
				if (src.loc.reagents)
					src.loc.reagents.add_reagent("radium", 5, null, T0C + heated * 200)
			src.visible_message(SPAN_ALERT("[src] bursts open, spraying hot liquid on [src.loc]!"))
			burst()

	throw_impact(atom/A, datum/thrown_thing/thr)
		..()
		if (heated > 0 && on && prob(30 + (heated * 20)))
			if(iscarbon(A))
				if (A.reagents)
					A.reagents.add_reagent("radium", 5, null, T0C + heated * 200)
			A.visible_message(SPAN_ALERT("[src] bursts open, spraying hot liquid on [A]!"))
			burst()

	attack_self(mob/user as mob)
		if (!on)
			boutput(user, SPAN_NOTICE("You crack [src]."))
			playsound(user.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
			src.turnon()
		else
			if (prob(10) || (heated > 0 && prob(20 + heated * 20)))
				user.visible_message(SPAN_NOTICE("<b>[user]</b> breaks [src]! What [pick("a clutz", "a putz", "a chump", "a doofus", "an oaf", "a jerk")]!"))
				playsound(user.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
				if (user.reagents)
					if (heated > 0)
						user.reagents.add_reagent("radium", 10, null, T0C + heated * 200)
					else
						user.reagents.add_reagent("radium", 10)
				burst()
			else
				user.visible_message(SPAN_NOTICE("<b>[user]</b> [pick("fiddles", "faffs around", "goofs around", "fusses", "messes")] with [src]."))

/obj/item/device/light/glowstick/green_on
	base_state = "glowstick-green"
	icon_state = "glowstick-green0"
	name = "emergency glowstick"
	desc = "For emergency use only. Not for use in illegal lightswitch raves."
	col_r = 0
	col_g = 0.9
	col_b = 0.1
	color_name = "green"
	New()
		..()
		turnon()

/obj/item/device/light/glowstick/white
	base_state = "glowstick-white"
	icon_state = "glowstick-white0"
	desc = "A regular emergency glowstick filtered for only the purest space light."
	col_r = 0.9
	col_g = 0.9
	col_b = 0.9
	color_name = "white"

/obj/item/device/light/glowstick/yellow
	base_state = "glowstick-yellow"
	icon_state = "glowstick-yellow0"
	desc = "A regular emergency glowstick full of lovely artificial sunshine!"
	col_r = 0.9
	col_g = 0.8
	col_b = 0.1
	color_name = "yellow"

/obj/item/device/light/glowstick/blue
	base_state = "glowstick-blue"
	icon_state = "glowstick-blue0"
	desc = "A regular emergency glowstick but somehow those madmen made it glow blue instead."
	col_r = 0.1
	col_g = 0.1
	col_b = 0.9
	color_name = "blue"

/obj/item/device/light/glowstick/purple
	base_state = "glowstick-purple"
	icon_state = "glowstick-purple0"
	desc = "A emergency glowstick, designed by the legendary Samuel L. Jackson."
	col_r = 0.6
	col_g = 0.1
	col_b = 0.9
	color_name = "purple"

/obj/item/device/light/glowstick/pink
	base_state = "glowstick-pink"
	icon_state = "glowstick-pink0"
	desc = "A regular emergency glowstick, 60% cuter!"
	col_r = 0.9
	col_g = 0.5
	col_b = 0.9
	color_name = "pink"

/obj/item/device/light/glowstick/cyan
	base_state = "glowstick-cyan"
	icon_state = "glowstick-cyan0"
	desc = "A regular emergency glowstick but somehow those madmen made it glow cyan instead."
	col_r = 0.1
	col_g = 0.9
	col_b = 0.9
	color_name = "cyan"

/obj/item/device/light/glowstick/orange
	base_state = "glowstick-orange"
	icon_state = "glowstick-orange0"
	desc = "A regular emergency glowstick but somehow those madmen made it glow orange instead."
	col_r = 0.9
	col_g = 0.6
	col_b = 0.1
	color_name = "orange"

/obj/item/device/light/glowstick/red
	base_state = "glowstick-red"
	icon_state = "glowstick-red0"
	desc = "A regular emergency glowstick edgy and red!"
	col_r = 0.9
	col_g = 0.1
	col_b = 0
	color_name = "red"

ADMIN_INTERACT_PROCS(/obj/item/device/light/candle, proc/light, proc/put_out)
/obj/item/device/light/candle
	name = "candle"
	desc = "It's a big candle."
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "candle-off"
	density = 0
	anchored = UNANCHORED
	opacity = 0
	icon_off = "candle-off"
	icon_on = "candle"
	col_r = 0.5
	col_g = 0.3
	col_b = 0

	attack_self(mob/user as mob)
		if (src.on)
			var/fluff = pick("snuff", "blow")
			user.visible_message("<b>[user]</b> [fluff]s out [src].",\
			"You [fluff] out [src].")
			src.put_out(user)

	attackby(obj/item/W, mob/user)
		if (!src.on)
			if (isweldingtool(W) && W:try_weld(user,0,-1,0,0))
				src.light(user, SPAN_ALERT("<b>[user]</b> casually lights [src] with [W], what a badass."))

			else if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
				src.light(user, SPAN_ALERT("Did [user] just light [his_or_her(user)] [src] with [W]? Holy Shit."))

			else if (istype(W, /obj/item/device/igniter))
				src.light(user, SPAN_ALERT("<b>[user]</b> fumbles around with [W]; a small flame erupts from [src]."))

			else if (istype(W, /obj/item/device/light/zippo) && W:on)
				src.light(user, SPAN_ALERT("With a single flick of their wrist, [user] smoothly lights [src] with [W]. Damn they're cool."))

			else if (istype(W, /obj/item/match) && W:on == MATCH_LIT) /// random bullshit go!
				src.light(user, SPAN_ALERT("<b>[user] lights [src] with [W]."))

			else if (istype(W, /obj/item/device/light/candle) && W:on)
				src.light(user, SPAN_ALERT("<b>[user] lights [src] with [W]. Flameception!"))

			else if (W.burning)
				src.light(user, SPAN_ALERT("<b>[user]</b> lights [src] with [W]. Goddamn."))

			else if (W.firesource)
				src.light(user, SPAN_ALERT("<b>[user]</b> lights [src] with [W]."))
				W.firesource_interact()
		else
			return ..()

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if (src.on == 0)
			if (temperature > (T0C + 430))
				src.visible_message(SPAN_ALERT("[src] ignites!"), group = "candle_ignite")
				src.light()

	process()
		if (src.on)
			var/turf/location = src.loc
			if (ismob(location))
				var/mob/M = location
				if (M.find_in_hand(src))
					location = M.loc
			var/turf/T = get_turf(src.loc)
			if (T)
				T.hotspot_expose(700,5)

	proc/light(var/mob/user as mob, var/message as text)
		if (!src) return
		if (!src.on)
			src.on = 1
			src.firesource = FIRESOURCE_OPEN_FLAME
			src.hit_type = DAMAGE_BURN
			src.force = 3
			src.icon_state = src.icon_on
			light.enable()
			processing_items |= src
		return

	proc/put_out(var/mob/user as mob)
		if (!src) return
		if (src.on)
			src.on = 0
			src.firesource = FALSE
			src.hit_type = DAMAGE_BLUNT
			src.force = 0
			src.icon_state = src.icon_off
			light.disable()
			processing_items -= src
		return

/obj/item/device/light/candle/spooky
	name = "spooky candle"
	desc = "It's a big candle. It's also floating."
	anchored = ANCHORED

	New()
		..()
		var/spookydegrees = rand(5, 20)

		SPAWN(rand(1, 10))
			animate(src, pixel_y = 32, transform = matrix(spookydegrees, MATRIX_ROTATE), time = 20, loop = -1, easing = SINE_EASING)
			animate(pixel_y = 0, transform = matrix(spookydegrees * -1, MATRIX_ROTATE), time = 20, loop = -1, easing = SINE_EASING)

/obj/item/device/light/candle/spooky/summon
	New()
		flick("candle-summon", src)
		..()

/obj/item/device/light/candle/haunted
	name = "haunted candle"
	desc = "As opposed to your more standard spooky candle. It smells horrid."
	edible = 1 // eat a haunted goddamn candle every day
	var/did_thing = 0

	New()
		..()

		if (!src.reagents)
			var/datum/reagents/R = new /datum/reagents(50)
			src.reagents = R
			R.my_atom = src

	// yes this is dumb as hell but it makes me laugh a bunch
		src.reagents.add_reagent("wax", 20)
		src.reagents.add_reagent("black_goop", 10)
		src.reagents.add_reagent("yuck", 10)
		src.reagents.add_reagent("ectoplasm", 10)
		return

	light(var/mob/user as mob, var/message as text)
		..()
		if(src.on && !src.did_thing)
			src.did_thing = 1
			//what should it do, other than this sound?? i tried a particle system but it didn't work :{
			playsound(src, pick('sound/ambience/station/Station_SpookyAtmosphere1.ogg','sound/ambience/station/Station_SpookyAtmosphere2.ogg'), 65, 0)

		return

/obj/item/device/light/candle/small
	name = "small candle"
	desc = "It's a little candle."
	icon = 'icons/obj/decoration.dmi'
	icon_state = "lil_candle0"
	icon_off = "lil_candle0"
	icon_on = "lil_candle1"
	brightness = 0.8

// lava lamp
/obj/item/device/light/lava_lamp
	name = "lava lamp"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lava_lamp-blue0"
	icon_on = "lava_lamp-blue1"
	icon_off = "lava_lamp-blue1"
	w_class = W_CLASS_BULKY
	desc = "An ancient relic from a simpler, more funky time."
	col_r = 0.85
	col_g = 0.45
	col_b = 0.35
	brightness = 0.8
	var/lamp_color

	New()
		. = ..()
		lamp_color = pick("blue", "pink", "orange")
		icon_state = "lava_lamp-[lamp_color]0"
		icon_on = "lava_lamp-[lamp_color]1"
		icon_off = "lava_lamp-[lamp_color]0"

	attack_self(mob/user as mob)
		playsound(src, 'sound/items/penclick.ogg', 30, TRUE)
		src.on = !src.on
		user.visible_message("<b>[user]</b> flicks [src.on ? "on" : "off"] the [src].")
		if (src.on)
			set_icon_state(src.icon_on)
			src.light.enable()
		else
			set_icon_state(src.icon_off)
			src.light.disable()

/obj/item/device/light/lava_lamp/activated
	New()
		..()
		on = 1
		set_icon_state(src.icon_on)
		src.light.enable()

/obj/item/device/light/magic_lantern
	name = "magical lantern"
	desc = "A magical lantern that burns with no fuel."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "wizard1"
	icon_on = "wizard1"
	icon_off = "wizard0"
	anchored = ANCHORED
	col_r = 1
	col_g = 0.9
	col_b = 0.9
	brightness = 0.8

	New()
		..()
		on = 1
		set_icon_state(src.icon_on)
		src.light.enable()

TYPEINFO(/obj/item/device/light/floodlight)
	mats = list("crystal" = 10,
				"conductive" = 1,
				"metal" = 4)
/obj/item/device/light/floodlight
	name = "floodlight"
	desc = "A floodlight that can illuminate a large area."
	icon = 'icons/obj/lighting.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "floodlight_item"
	w_class = W_CLASS_BULKY
	flags = TABLEPASS | CONDUCT
	rand_pos = FALSE
	m_amt = 50
	g_amt = 20
	col_r = 0.85
	col_g = 0.85
	col_b = 1.00
	brightness = 4.5
	light_type = /datum/light/cone
	var/outer_angular_size = 120
	var/inner_angular_size = 60
	var/inner_radius = 3
	var/switch_on = TRUE
	var/movable = TRUE
	var/rotatable = TRUE
	var/infinite_power = FALSE
	var/power_usage = 50 WATTS
	var/obj/item/cell/cell = null

	New()
		. = ..()
		var/datum/light/cone/light = src.light
		light.outer_angular_size = src.outer_angular_size
		light.inner_angular_size = src.inner_angular_size
		light.inner_radius = src.inner_radius

	onVarChanged(variable, oldval, newval)
		. = ..()
		if (variable in list("outer_angular_size", "inner_angular_size", "inner_radius", "col_r", "col_g", "col_b", "brightness"))
			var/enable_later = src.light.enabled
			var/datum/light/cone/light = src.light
			if (enable_later)
				light.disable(TRUE)
			light.outer_angular_size = src.outer_angular_size
			light.inner_angular_size = src.inner_angular_size
			light.inner_radius = src.inner_radius
			light.set_color(col_r, col_g, col_b)
			light.set_brightness(brightness)
			if (enable_later)
				light.enable(TRUE)

	mouse_drop(atom/over_object, src_location, over_location, over_control, params)
		. = ..()
		if (in_interact_range(src, usr) && can_act(usr) && rotatable)
			var/new_dir = get_dir(src, over_object)
			if (!new_dir || new_dir == src.dir)
				return
			src.set_dir(new_dir)

	set_dir(new_dir)
		if (new_dir == dir)
			return
		. = ..()
		src.light.move(x, y, z, new_dir)

	attack_self(mob/user)
		user.drop_item(src)
		src.set_dir(user.dir)
		src.pixel_x = 0
		src.pixel_y = 0
		for	(var/obj/item/I in user.equipped_list())
			if (iswrenchingtool(I))
				src.Attackby(I, user)
				return
		boutput(user, SPAN_NOTICE("You need a wrench to activate [src]."))

	proc/toggle()
		playsound(src, 'sound/misc/lightswitch.ogg', 50, TRUE, pitch=0.5)
		src.switch_on = !src.switch_on
		if (src.switch_on)
			processing_items |= src
		else
			processing_items -= src
		light_check()

	attack_hand(mob/user)
		if (src.anchored)
			toggle()
			return
		. = ..()

	attackby(obj/item/W, mob/user)
		if (iswrenchingtool(W))
			if (!isturf(src.loc))
				user.drop_item(src)
				if (isturf(src.loc))
					src.set_dir(user.dir)
					src.pixel_x = 0
					src.pixel_y = 0
			if (!isturf(src.loc))
				boutput(user, SPAN_NOTICE("[src] needs to be placed on the ground to be wrenched."))
				return
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			if (!src.anchored)
				src.visible_message(SPAN_NOTICE("[user] starts wrenching \the [src]."))
				SETUP_GENERIC_ACTIONBAR(user, src, 1 SECONDS, PROC_REF(anchor), list(user), src.icon, src.icon_state,\
					SPAN_NOTICE("[user] finishes wrenching \the [src]."), null)
			else if(movable)
				src.visible_message(SPAN_NOTICE("[user] starts unwrenching \the [src]."))
				SETUP_GENERIC_ACTIONBAR(user, src, 1 SECONDS, PROC_REF(unanchor), list(user), src.icon, src.icon_state,\
					SPAN_NOTICE("[user] finishes unwrenching \the [src]."), null)
		else if (ispryingtool(W))
			if (cell)
				boutput(user, SPAN_NOTICE("You pry [cell] out of [src]."))
				cell.set_loc(get_turf(src))
				cell = null
				light_check()
			else
				boutput(user, SPAN_NOTICE("There is no cell in [src]."))
		else if (istype(W, /obj/item/cell))
			if (cell)
				cell.set_loc(get_turf(src))
				boutput(user, SPAN_NOTICE("You replace [cell] in [src] with [W]."))
			else
				boutput(user, SPAN_NOTICE("You put [W] in [src]."))
			user.drop_item(W)
			cell = W
			W.set_loc(src)
			light_check()
		else
			return ..()

	proc/anchor(mob/user)
		if (!isturf(src.loc))
			return
		src.anchored = ANCHORED
		src.set_icon_state("floodlight")
		light_check()
		if (src.switch_on)
			processing_items |= src

	proc/unanchor(mob/user)
		if (!isturf(src.loc))
			return
		src.anchored = UNANCHORED
		src.set_icon_state("floodlight_item")
		if (src.switch_on)
			processing_items -= src
		light_check()

	get_desc()
		. = ..() + "\n"
		if (src.movable)
			. +=  " It can be wrenched to activate it."
		if (isnull(cell))
			. += " It has no APC-sized cell installed."
		else
			. += " [cell] is charged to [cell.charge]/[cell.maxcharge]."
		if (src.anchored)
			. += " It is wrenched to the ground."
			if (src.light.enabled)
				. += " It is currently on."
			else if (!src.switch_on)
				. += " It is currently off."
			else
				. += " It is currently out of power."
		else
			. += " It is not wrenched to the ground."

	process()
		..()
		light_check()
		if (light.enabled && power_usage > 0)
			var/area/area = get_area(src.loc)
			var/obj/machinery/power/apc/apc = area?.area_apc
			if (apc?.operating && apc?.lighting)
				area.use_power(src.power_usage, LIGHT)
			else if (apc?.operating && apc?.environ)
				area.use_power(src.power_usage, ENVIRON)
			else
				src.cell?.use(src.power_usage)

	proc/light_check()
		var/area/area = get_area(src.loc)
		var/obj/machinery/power/apc/apc = area?.area_apc
		var/has_power = apc?.operating && (apc?.lighting || apc?.environ)
		has_power |= src.cell?.charge >= src.power_usage
		has_power |= src.infinite_power
		if (src.anchored)
			src.UpdateOverlays(SafeGetOverlayImage("lever", src.icon, src.switch_on ? "floodlight-lever-on" : "floodlight-lever-off"), "lever")
		else
			src.UpdateOverlays(null, "lever")

		if (!src.anchored || !area || !has_power || !src.switch_on)
			if (src.light.enabled)
				src.light.disable()
				src.UpdateOverlays(null, "light")
				src.UpdateOverlays(null, "light-lightplane")
		else
			if (!src.light.enabled)
				src.light.attach_x = pixel_x / world.icon_size
				src.light.attach_y = pixel_y / world.icon_size
				src.light.enable()
				src.UpdateOverlays(image(src.icon, "floodlight-light"), "light")
				var/image/light_lightplane = image(src.icon, "floodlight-light")
				light_lightplane.plane = PLANE_SELFILLUM
				light_lightplane.alpha = 127
				src.UpdateOverlays(light_lightplane, "light-lightplane")

/obj/item/device/light/floodlight/with_cell
	New()
		..()
		cell = new /obj/item/cell/charged(src)


/obj/item/device/light/floodlight/starts_on
	New()
		..()
		anchor(null)

/obj/item/device/light/floodlight/starts_on/fixed
	movable = FALSE
	rotatable = FALSE
	infinite_power = TRUE
	power_usage = 0 WATTS

#define FLARE_UNLIT 1
#define FLARE_LIT 2
#define FLARE_BURNT 3

ADMIN_INTERACT_PROCS(/obj/item/roadflare, proc/light, proc/put_out)
/obj/item/roadflare
	name = "emergency flare"
	desc = "Space grade emergency flare that can burn in an 02 free environment. Estimated burn time 3-6 minutes."
	icon = 'icons/obj/lighting.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "roadflare"
	w_class = W_CLASS_SMALL
	throwforce = 1
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	burn_point = 220
	burn_output = 1200
	burn_possible = TRUE

	var/on = FLARE_UNLIT

	var/life_time = 0
	rand_pos = 1

	var/col_r = 0.95
	var/col_g = 0.7
	var/col_b = 0.25
	var/brightness = 0.4

	New()
		..()
		AddComponent(/datum/component/loctargeting/sm_light, col_r*255, col_g*255, col_b*255, 510 * brightness, FALSE)

	process()
		if (src.on == FLARE_LIT)
			if (world.time > life_time)
				var/location = src.loc
				if (ismob(location))
					var/mob/M = location
					src.put_out(M)
					return
				else
					src.put_out()
					return
			var/turf/T = get_turf(src.loc)
			if (T)
				T.hotspot_expose(900,5)

	proc/light(var/mob/user as mob)
		src.on = FLARE_LIT
		w_class = W_CLASS_BULKY
		src.firesource = FIRESOURCE_OPEN_FLAME
		src.icon_state = "roadflare-lit"

		playsound(user, 'sound/items/matchstick_light.ogg', 80, FALSE)
		SEND_SIGNAL(src, COMSIG_LIGHT_ENABLE)

		src.life_time = (world.time + rand(180 SECONDS,360 SECONDS))
		processing_items |= src
		if (istype(user))
			user.update_inhands()
		var/obj/particle_holder = src.UpdateParticles(new/particles/roadflare_smoke,"roadflare_smoke")
		if(!isturf(src.loc))
			particle_holder.invisibility = INVIS_ALWAYS

	set_loc(newloc, storage_check)
		. = ..()
		src.GetParticleHolder("roadflare_smoke")?.invisibility = isturf(src.loc) ? INVIS_NONE : INVIS_ALWAYS

	proc/put_out(mob/user)
		src.on = FLARE_BURNT
		w_class = W_CLASS_SMALL
		src.firesource = FALSE
		src.icon_state = "roadflare-burnt"
		src.item_state = "roadflare"
		src.name = "burnt-out emergency flare"

		playsound(src, 'sound/impact_sounds/burn_sizzle.ogg', 70, FALSE)
		SEND_SIGNAL(src, COMSIG_LIGHT_DISABLE)
		if (istype(user))
			user.update_inhands()
		processing_items.Remove(src)
		src.ClearSpecificParticles("roadflare_smoke")

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if (src.on == FLARE_UNLIT)
			if (temperature > T0C+200)
				src.visible_message(SPAN_ALERT("[src] ignites!"))
				src.light()

	ex_act(severity)
		..()
		if (QDELETED(src))
			return
		if (src.on == FLARE_UNLIT)
			src.visible_message(SPAN_ALERT("[src] ignites!"))
			src.light()

	afterattack(atom/target, mob/user as mob)
		if (src.on == FLARE_LIT)
			if (!ismob(target) && target.reagents)
				user.show_text("You heat [target].", "blue")
				target.reagents.temperature_reagents(4000,10)
				return

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if (src.on == FLARE_LIT)
			if (ishuman(target))
				if (check_target_immunity(target=target, ignore_everything_but_nodamage=FALSE, source=user))
					return ..()
				var/mob/living/carbon/human/H = target
				if (H.bleeding || ((H.organHolder && !H.organHolder.get_organ("butt")) && user.zone_sel.selecting == "chest"))
					src.cautery_surgery(H, user, 5, src.on)
					return ..()
				else
					user.visible_message(SPAN_ALERT("<b>[user]</b> pushes the burning [src] against [H]!"),\
					SPAN_ALERT("You press the burning end of [src] against [H]!"))
					logTheThing(LOG_COMBAT, user, "burns [constructTarget(target,"combat")] with an emergency flare at [log_loc(target)].")
					playsound(src.loc, 'sound/impact_sounds/burn_sizzle.ogg', 50, 1)
					H.TakeDamage("All", 0, rand(3,7))
					if (!H.stat && !ON_COOLDOWN(H, "burn_scream", 4 SECONDS))
						H.emote("scream")
					return
		else
			return ..()

	attack_self(mob/user)
		if (user.find_in_hand(src))
			if (src.on == FLARE_UNLIT)
				user.visible_message("<b>[user]</b> lights [src] with the striker cap.","You light [src] with the striker cap.")
				src.light(user)
				src.add_fingerprint(user)
				return
		else
			return ..()

#undef FLARE_UNLIT
#undef FLARE_LIT
#undef FLARE_BURNT

/particles/roadflare_smoke
	icon = 'icons/effects/effects.dmi'
	icon_state = list("smoke")
	color = "#ffffff"
	width = 150
	height = 200
	count = 15
	spawning = 0.25
	lifespan = generator("num", 20, 35, UNIFORM_RAND)
	fade = generator("num", 50, 100, UNIFORM_RAND)
	position = generator("box", list(4,5,0), list(6,10,0), UNIFORM_RAND)
	velocity = generator("box", list(-1,0.5,0), list(1,2,0), NORMAL_RAND)
	rotation = generator("num", 0, 180, NORMAL_RAND)
	scale = list(0.5, 0.5)
	gravity = list(0.07, 0.02, 0)
	grow = list(0.01, 0)
	fadein = 10
