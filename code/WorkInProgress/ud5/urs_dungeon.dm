
/obj/adventurepuzzle/multi_element_link

	// Look, please don't break this. okay? Please please please don't break this. This is very breakable. You promise? Good.

	var/triggerer_id = null
	var/triggerable_id = null
	var/act_type = null
	var/list/triggerers = list()
	var/list/triggerables = list()
	var/is_unpress = 0

	New()
		..()
		if(current_state > GAME_STATE_PREGAME)
			SPAWN(0.1 SECONDS)
				src.initialize()

	initialize()
		src.link_elements()
		..()
		qdel(src)

	proc/link_elements()

		if(src.triggerer_id == src.triggerable_id)
			return // I literally just said NOT to break this, you PROMISED.


		if(length(adventure_elements_by_id[src.triggerer_id]))
			src.triggerers = adventure_elements_by_id[src.triggerer_id]

		if(length(adventure_elements_by_id[src.triggerable_id]))
			src.triggerables = adventure_elements_by_id[src.triggerable_id]

		if((src.triggerers.len > 0) && (src.triggerables.len > 0))

			for(var/Z in src.triggerers)

				for(var/W in src.triggerables)

					if(istype(W,/obj/adventurepuzzle/triggerable))

						var/obj/adventurepuzzle/triggerable/Y = W

						if(istype(Z,/obj/adventurepuzzle/triggerer/twostate))

							var/obj/adventurepuzzle/triggerer/twostate/X = Z

							if(is_unpress)
								X.triggered_unpress += Y
								X.triggered_unpress[Y] = act_type

							else
								X.triggered += Y
								X.triggered[Y] = act_type

						else if(istype(Z,/obj/adventurepuzzle/triggerer))

							var/obj/adventurepuzzle/triggerer/X = Z

							X.triggered += Y
							X.triggered[Y] = act_type

						else if(istype(Z,/obj/adventurepuzzle/triggerable/triggerer))

							var/obj/adventurepuzzle/triggerable/triggerer/X = Z

							X.triggered += Y
							X.triggered[Y] = act_type

						else if(istype(Z,/obj/item/adventurepuzzle/triggerer))

							var/obj/item/adventurepuzzle/triggerer/X = Z

							X.triggered += Y
							X.triggered[Y] = act_type


/obj/adventurepuzzle/triggerable/bomb


	name = "adventure bomb"
	invisibility = INVIS_ADVENTURE
	icon = 'icons/obj/items/assemblies.dmi'
	icon_state = "Pipe_Timed"
	density = 0
	opacity = 0
	anchored = 1
	var/trap_delay = 100
	var/next_trap = 0
	var/power = 100

	var/is_on = 1

	var/static/list/triggeracts = list("Activate" = "act", "Disable" = "off", "Destroy" = "del", "Do nothing" = "nop", "Enable" = "on")

	New()
		src.create_reagents(5000)
		..()

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch (act)
			if ("del")
				is_on = 0
				qdel(src)
			if ("act")
				if (is_on && next_trap <= world.time)
					explosion_new(src, get_turf(src), power)
					next_trap = world.time + trap_delay
			if ("off")
				is_on = 0
				return
			if ("on")
				is_on = 1
				return

/obj/adventurepuzzle/triggerable/targetable/portal

	name = "adventure portal"
	invisibility = INVIS_ADVENTURE
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = 0
	opacity = 0
	anchored = 1
	target = null
	var/my_portal = null
	var/start_on = 0
	var/invisible_portal = 0

	var/static/list/triggeracts = list("Disable" = "off", "Do nothing" = "nop", "Enable" = "on")

	New()
		..()
		if(start_on)
			SPAWN(1 SECOND)
				src.trigger("on")

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch(act)
			if ("on")
				if(my_portal)
					return
				if(!target)
					return
				var/obj/perm_portal/P = new /obj/perm_portal(get_turf(src))
				P.target = get_turf(target)
				if(src.invisible_portal)
					P.invisibility = 20
				src.my_portal = P
				return
			if ("off")
				qdel(my_portal)
				my_portal = null
				return

	setTarget(var/atom/A)
		..()

/obj/item/clothing/glasses/urs_dungeon_entry
	name = "\improper VR goggles"
	desc = "On the side it says \"A game for 2-4 Players\". Guess you'll need some friends to play with you."
	icon_state = "vr"
	item_state = "sunglasses"
	color = "#550000"
	var/target = null
	var/doing_login = 0
	var/turf/origin = null

	New()
		..()
		SPAWN(1 DECI SECOND)
			for(var/obj/adventurepuzzle/invisible/target_link/T)
				if (T.id == "UD-LANDING-ZONE")
					target = get_turf(T)


	equipped(var/mob/user, var/slot)
		..()
		var/mob/living/carbon/human/H = user
		if(!(user == usr))
			return
		if(istype(H) && slot == SLOT_GLASSES)
			origin = get_turf(H)
			SPAWN(1 SECOND)
				enter_urs_dungeon(user)
		return

	proc/enter_urs_dungeon(var/mob/living/carbon/human/H)
		if(target)
			if(doing_login)
				return
			doing_login = 1

			H.u_equip(src)
			src.set_loc(origin)
			H.unequip_all()

			var/mob/living/carbon/human/V = new(get_turf(src.target),H.client.preferences.AH, H.client.preferences, TRUE)
			if (!H.mind)
				H.mind = new /datum/mind()
				H.mind.ckey = H.ckey
				H.mind.key = H.key
				H.mind.current = H
				ticker.minds += H.mind

			V.update_colorful_parts()
			for(var/mob/O in AIviewers(src, null)) O.show_message("<span class='alert'>[H.name] disappears in a flash of light!!</span>", 1)
			H.emote("scream")
			playsound(H.loc, 'sound/weapons/flashbang.ogg', 25, 1)
			for (var/mob/N in viewers(src, null))
				if (GET_DIST(N, src) <= 6)
					N.apply_flash(20, 1)
				if (N.client)
					shake_camera(N, 6, 32)
			V.apply_flash(20,1)
			if (V.client)
				shake_camera(V, 6, 32)
			H.mind.transfer_to(V)
			playsound(V.loc, 'sound/ambience/music/VRtunes_edited.ogg', 10, 0)
			H.elecgib()
			doing_login = 0

			H.u_equip(src)
			H.drop_item(src)
			src.set_loc(origin)

/obj/item/clothing/glasses/urs_dungeon_exit
	name = "\improper VR goggles"
	desc = "About goddamn time."
	icon_state = "vr"
	item_state = "sunglasses"
	color = "#00CCCC"
	var/turf/origin = null

	New()
		..()
		origin = get_turf(src)

	equipped(var/mob/user, var/slot)
		..()
		var/mob/living/carbon/human/H = user
		if(istype(H) && slot == SLOT_GLASSES)
			SPAWN(1 SECOND)
				exit_urs_dungeon(user)
		return

	proc/exit_urs_dungeon(var/mob/living/carbon/human/H)

		H.u_equip(src)
		src.set_loc(origin)
		H.drop_item(src)

		var/list/L = list()
		for (var/turf/T3 in get_area_turfs(/area/station/crew_quarters,0))
			if (!T3.density)
				var/clear = 1
				for (var/obj/O in T3)
					if (O.density)
						clear = 0
						break
				if (clear)
					L += T3

		if(!(L.len > 0))
			for (var/turf/T3 in get_area_turfs(/area/station,0))
				if (!T3.density)
					var/clear = 1
					for (var/obj/O in T3)
						if (O.density)
							clear = 0
							break
					if (clear)
						L += T3

		for(var/mob/O in AIviewers(H, null)) O.show_message("<span class='alert'>[H.name] disappears in a flash of light!!</span>", 1)
		playsound(src.loc, 'sound/weapons/flashbang.ogg', 50, 1)

		for (var/mob/N in viewers(H, null))
			if (GET_DIST(N, src) <= 6)
				N.apply_flash(20, 1)
			if (N.client)
				shake_camera(N, 6, 32)

		H.set_loc(pick(L))

		H.unlock_medal("Virtual Ascension",1)

		H.u_equip(src)
		H.drop_item(src)
		src.set_loc(origin)

		return

/obj/adventurepuzzle/triggerable/adventure_announcement
	name = "announcer"
	desc = "A strange device that emits a very loud sound, truly the future."
	anchored = 1
	var/speaker_type
	var/message = null
	var/text_color = "#FF0000"
	var/sound  = null

	var/static/list/triggeracts = list("Do nothing" = "nop", "Announce message" = "announce")

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch (act)
			if ("announce")
				src.announce()
			else
				return

	proc/announce()
		var/area/our_area = get_area(src)
		our_area.sound_fx_2 = src.sound //assign even if null
		var/played = our_area.played_fx_2

		for (var/mob/M in our_area)
			if (src.sound && !played)
				if (M.client)
					M.client.playAmbience(our_area, AMBIENCE_FX_2, 50)
			if(src.message)
				M.show_message("<span class='game say bold'><span class='message'><span style='color: [src.text_color]'>[message]</span></span></span>", 2)

/area/adventure/urs_dungeon
	teleport_blocked = 2
	virtual = 0


/obj/adventurepuzzle/triggerable/puzzletile
	icon = 'icons/obj/puzzletile.dmi'
	icon_state = "tile_border"
	name = "Colored Tile"
	desc = "Some kind of coloured tile."
	density = 0
	opacity = 0
	anchored = 1



	var/is_on = 1

	var/red = 0
	var/green = 0
	var/blue = 0

	var/static/list/triggeracts = list("Do nothing" = "nop", "Toggle" = "toggle", "Turn on" = "on", "Turn off" = "off", "Add Red" = "ared", "Remove Red" = "rred","Add Blue" = "ablue", "Remove Blue" = "rblue", "Add Green" = "agreen", "Remove Green" = "rgreen")

	New()
		..()
		update_color()


	proc/on()
		if (!is_on)
			is_on = 1
			update_color()

	proc/off()
		if (is_on)
			is_on = 0
			update_color()

	proc/toggle()
		if (is_on)
			off()
		else
			on()

	proc/add_red()
		if(red<3)
			red++
			update_color()

	proc/remove_red()
		if(red>0)
			red--
		update_color()

	proc/add_blue()
		if(blue<3)
			blue++
		update_color()

	proc/remove_blue()
		if(blue>0)
			blue--
		update_color()

	proc/add_green()
		if(green<3)
			green++
		update_color()

	proc/remove_green()
		if(green>0)
			green--
		update_color()

	proc/update_color()
		var/new_color = "#"

		if(!is_on)
			new_color = "#222222"
		else
			switch (red)
				if(0)
					new_color += "88"
				if(1)
					new_color += "AA"
				if(2)
					new_color += "CC"
				if(3)
					new_color += "FF"

			switch (green)
				if(0)
					new_color += "88"
				if(1)
					new_color += "AA"
				if(2)
					new_color += "CC"
				if(3)
					new_color += "FF"

			switch (blue)
				if(0)
					new_color += "88"
				if(1)
					new_color += "AA"
				if(2)
					new_color += "CC"
				if(3)
					new_color += "FF"

		for(var/u in src.underlays)
			src.underlays -= u

		for(var/o in src.overlays)
			src.overlays -= o

		src.appearance_flags |= RESET_TRANSFORM
		src.appearance_flags |= RESET_COLOR
		src.appearance_flags |= PIXEL_SCALE
		src.appearance_flags &= ~KEEP_TOGETHER

		src.icon_state = "ring_inner"
		src.transform = matrix().Turn(40*red)
		src.overlays += src

		src.icon_state = "ring_middle"
		src.transform = matrix().Turn(40*red + 40*green)
		src.overlays += src

		src.icon_state = "ring_outer"
		src.transform = matrix().Turn(40*red + 40*green + 40*blue)
		src.overlays += src

		src.transform = null

		src.icon_state = "tile_border"
		src.overlays += src

		src.icon_state = "tile"
		src.color = new_color
		src.overlays += src
		src.color = null

		src.icon_state = "canvas"

		src.appearance_flags &= ~RESET_TRANSFORM
		src.appearance_flags &= ~RESET_COLOR
		src.appearance_flags &= ~PIXEL_SCALE
		src.appearance_flags |= KEEP_TOGETHER

	trigger_actions()
		return triggeracts

	trigger(var/act)
		switch (act)
			if ("on")
				src.on()
				return
			if ("off")
				src.off()
				return
			if ("toggle")
				src.toggle()
				return
			if ("ared")
				src.add_red()
				return
			if ("rred")
				src.remove_red()
				return
			if ("agreen")
				src.add_green()
				return
			if ("rgreen")
				src.remove_green()
				return
			if ("ablue")
				src.add_blue()
				return
			if ("rblue")
				src.remove_blue()
				return

/obj/storage/closet/syndi/hidden/shovel_me

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		return

	attack_hand(mob/user)
		return

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/shovel))
			user.visible_message("<span class='notice'>[user] digs in [src] with [W]!</span>")
			src.open()
		return


/obj/item/ursium
	name = "Magnetic Storage Ring"
	desc = "This thing pulses with a truly awesome power byond your wildest imagination."
	icon = 'icons/misc/ud5.dmi'
	icon_state = "urs_prize"
	opacity = 0
	density = 0
	anchored = 0
	var/ursium = 0
	var/s_time = 1
	var/content = null

/obj/item/ursium/proc/convert2energy(var/M)
	var/c_squared = 9e+16
	var/E = M*(c_squared)
	return E

/obj/item/ursium/U
	name = "Ursium storage ring"
	content = "Ursium"
	ursium = 1e-12		//pico-kilogram

/obj/item/ursium/antiU
	name = "Anti-Ursium storage ring"
	content = "Anti-Ursium"
	ursium = 1e-12		//pico-kilogram
	color = "#555555"

/obj/item/ursium/attackby(obj/item/ursium/F, mob/user)
	if(istype(src, /obj/item/ursium/antiU))
		if(istype(F, /obj/item/ursium/antiU))
			src.ursium += F.ursium
			F.ursium = 0
			boutput(user, "You have added the anti-Ursium to the storage ring, it now contains [src.ursium]kg")
		if(istype(F, /obj/item/ursium/U))
			/*
			src.ursium += F.ursium
			qdel(F)
			src:annihilation(src.ursium)
			*/
			boutput(user, "Nothing much happens. But you have the strong feeling Shitty Bill would like this.")
	if(istype(src, /obj/item/ursium/U))
		if(istype(F, /obj/item/ursium/U))
			src.ursium += F.ursium
			F.ursium = 0
			boutput(user, "You have added the Ursium to the storage ring, it now contains [src.ursium]kg")
		if(istype(F, /obj/item/ursium/antiU))
			/*
			src.ursium += F.ursium
			qdel(src)
			F:annihilation(F.ursium)
			*/
			boutput(user, "Nothing much happens. But you have the strong feeling Shitty Bill would like this.")

/obj/item/ursium/antiU/proc/annihilation(var/mass)

	var/strength = src.convert2energy(mass)

	if (strength < 773.0)
		var/turf/T = get_turf(src.loc)

		if (strength > (450+T0C))
			explosion(src, T, 0, 1, 2, 4)
		else
			if (strength > (300+T0C))
				explosion(src, T, 0, 0, 2, 3)

		qdel(src)
		return

	var/turf/ground_zero = get_turf(loc)

	var/ground_zero_range = round(strength / 387)
	explosion(src, ground_zero, ground_zero_range, ground_zero_range*2, ground_zero_range*3, ground_zero_range*4)
	qdel(src)
	return


/obj/item/ursium/examine(mob/user)
	. = ..()
	if(user && !user.stat)
		. += "A magnetic storage ring, it contains [ursium]kg of [content ? content : "nothing"]."

/obj/item/ursium/proc/injest(mob/M as mob)
	M.gib(1)
	qdel(src)
	return
/*
/obj/item/ursium/attack(mob/M, mob/user)
	if (user != M)
		user.visible_message("<span class='alert'>[user] is trying to force [M] to eat the [src.content]!</span>")
		if (do_mob(user, M, 40))
			user.visible_message("<span class='alert'>[user] forced [M] to eat the [src.content]!</span>")
			src.injest(M)
	else
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span class='alert'>[M] ate the [content ? content : "empty canister"]!</span>"), 1)
		src.injest(M)
*/

var/johnbill_ursdungeon_code = "0420"

/area/diner/arcade/New()
		..()
		var/list/insults = strings("johnbill.txt", "insults")
		johnbill_ursdungeon_code = random_hex(4)
		john_talk = "Eh [pick(insults)], so we got a couple a import sets in the wall there, uh... just don't let my bro at 'em. Again. [johnbill_ursdungeon_code] oughta do'er."

/obj/item/storage/secure/ssafe/diner_arcade
	configure_mode = 0
	random_code = 0
	spawn_contents = list(/obj/item/clothing/glasses/urs_dungeon_entry,/obj/item/clothing/glasses/urs_dungeon_entry,/obj/item/clothing/glasses/urs_dungeon_entry,/obj/item/spacecash/random/small,/obj/item/spacecash/random/small)
	New()
		..()
		src.code = johnbill_ursdungeon_code

/obj/item/paper/tug/diner_arcade_invoice
    name = "Big Yank's Space Tugs, Limited."
    desc = "Looks like a bill of sale."
    info = {"<b>Client:</b> Bill, John
            <br><b>Date:</b> TBD
            <br><b>Articles:</b> Structure, Static. Pressurized. Duplex.
            <br><b>Destination:</b> \"jes' hook it up anywhere it fits\"\[sic\]
            <br>
            <br><b>Total Charge:</b> 9,233 paid in full with bootleg cigarillos.
            <br>Big Yank's Cheap Tug"}
