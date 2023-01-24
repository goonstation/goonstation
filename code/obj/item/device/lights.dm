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

/obj/item/device/light/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon_state = "flight0"
	item_state = "flight"
	icon_on = "flight1"
	icon_off = "flight0"
	var/icon_broken = "flightbroken"
	w_class = W_CLASS_SMALL
	flags = FPRINT | TABLEPASS | CONDUCT
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
		playsound(src, 'sound/items/penclick.ogg', 30, 1)
		if (src.on)
			set_icon_state(src.icon_on)
			if (src.emagged) // Burn them all!
				user.apply_flash(60, 2, 0, 0, rand(2, 8), rand(1, 15), 0, 25, 100, stamina_damage = 70, disorient_time = 10)
				for (var/mob/M in oviewers(2, get_turf(src)))
					if (in_cone_of_vision(user, M)) // If the mob is in the direction we're looking
						var/mob/living/target = M
						if (istype(target))
							target.apply_flash(60, 8, 0, 0, rand(2, 8), rand(1, 15), 0, 30, 100, stamina_damage = 190, disorient_time = 50)
							logTheThing(LOG_COMBAT, user, "flashes [constructTarget(target,"combat")] with an emagged flashlight.")
				user.visible_message("<span class='alert'>The [src] in [user]'s hand bursts with a blinding flash!</span>", "<span class='alert'>The bulb in your hand explodes with a blinding flash!</span>")
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
			user.visible_message("<span class='alert'><b>[user]</b> heats [src] with [W].</span>")
			src.heated += 1
			if (src.heated >= 3 || prob(5 + (heated * 20)))
				user.visible_message("<span class='alert'>[src] bursts open, spraying hot liquid all over <b>[user]</b>! What a [pick("moron", "dummy", "chump", "doofus", "punk", "jerk", "bad idea")]!</span>")
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
			src.visible_message("<span class='alert'>[src] bursts open, spraying hot liquid on [src.loc]!</span>")
			burst()

	throw_impact(atom/A, datum/thrown_thing/thr)
		..()
		if (heated > 0 && on && prob(30 + (heated * 20)))
			if(iscarbon(A))
				if (A.reagents)
					A.reagents.add_reagent("radium", 5, null, T0C + heated * 200)
			A.visible_message("<span class='alert'>[src] bursts open, spraying hot liquid on [A]!</span>")
			burst()

	attack_self(mob/user as mob)
		if (!on)
			boutput(user, "<span class='notice'>You crack [src].</span>")
			playsound(user.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
			src.turnon()
		else
			if (prob(10) || (heated > 0 && prob(20 + heated * 20)))
				user.visible_message("<span class='notice'><b>[user]</b> breaks [src]! What [pick("a clutz", "a putz", "a chump", "a doofus", "an oaf", "a jerk")]!</span>")
				playsound(user.loc, 'sound/impact_sounds/Generic_Snap_1.ogg', 50, 1)
				if (user.reagents)
					if (heated > 0)
						user.reagents.add_reagent("radium", 10, null, T0C + heated * 200)
					else
						user.reagents.add_reagent("radium", 10)
				burst()
			else
				user.visible_message("<span class='notice'><b>[user]</b> [pick("fiddles", "faffs around", "goofs around", "fusses", "messes")] with [src].</span>")

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

/obj/item/device/light/candle
	name = "candle"
	desc = "It's a big candle."
	icon = 'icons/obj/items/alchemy.dmi'
	icon_state = "candle-off"
	density = 0
	anchored = 0
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
				src.light(user, "<span class='alert'><b>[user]</b> casually lights [src] with [W], what a badass.</span>")

			else if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
				src.light(user, "<span class='alert'>Did [user] just light [his_or_her(user)] [src] with [W]? Holy Shit.</span>")

			else if (istype(W, /obj/item/device/igniter))
				src.light(user, "<span class='alert'><b>[user]</b> fumbles around with [W]; a small flame erupts from [src].</span>")

			else if (istype(W, /obj/item/device/light/zippo) && W:on)
				src.light(user, "<span class='alert'>With a single flick of their wrist, [user] smoothly lights [src] with [W]. Damn they're cool.</span>")

			else if ((istype(W, /obj/item/match) || istype(W, /obj/item/device/light/candle)) && W:on)
				src.light(user, "<span class='alert'><b>[user] lights [src] with [W].</span>")

			else if (W.burning)
				src.light(user, "<span class='alert'><b>[user]</b> lights [src] with [W]. Goddamn.</span>")

			else if (W.firesource)
				src.light(user, "<span class='alert'><b>[user]</b> lights [src] with [W].</span>")
				W.firesource_interact()
		else
			return ..()

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if (src.on == 0)
			if (temperature > (T0C + 430))
				src.visible_message("<span class='alert'> [src] ignites!</span>", group = "candle_ignite")
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
	anchored = 1

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
		playsound(src, 'sound/items/penclick.ogg', 30, 1)
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
	anchored = 1
	col_r = 1
	col_g = 0.9
	col_b = 0.9
	brightness = 0.8

	New()
		..()
		on = 1
		set_icon_state(src.icon_on)
		src.light.enable()
