#define ITEM_ABILITIES_WRAP_AT 15

//i did a bit of work to make these more versatile?
//im not like, a code goddess or anything tho, so its not really that great
//you can now make targeted item abilities
//item abilities also now check for statuses like stunned, and do a restrained check on the mob too
//also hopefully optimised it a tiny bit?

//oh my god what the fuck is going on in this file jesus wow
//save me from this freak horror show aaaaaa
////////////////////////////////////////////////////////////

/obj/ability_button/extinguisher_ab
	name = "Extinguish"
	icon_state = "extab"

	execute_ability()
		var/obj/item/extinguisher/E = the_item
		if(!istype(E) || !E.reagents || !E.reagents.total_volume || E.special) return

		for (var/reagent in E.banned_reagents)
			if (!E.reagents)
				return
			if (E.reagents.has_reagent(reagent))
				boutput(the_mob, "<span class='alert'>The nozzle is clogged!</span>")
				return

		for (var/reagent in E.melting_reagents)
			if (!E.reagents)
				return
			if (E.reagents.has_reagent(reagent))
				the_mob.visible_message("<span class='alert'>[E] melts!</span>")
				make_cleanable(/obj/decal/cleanable/molten_item,get_turf(the_mob))
				qdel(E)
				return

		the_mob.visible_message("<span class='alert'>[the_mob] prepares to spray the contents of the extinguisher all around \himself!</span>")

		E.special = 1
		the_mob.transforming = 1
		SPAWN_DBG(3 SECONDS) if (the_mob) the_mob.transforming = 0
		sleep(3 SECONDS)

		var/theturf
		var/list/spraybits = new/list()
		var/direction = NORTH
		if (the_mob)
			theturf = get_turf(the_mob)
		else
			theturf = get_turf(E)

		for(var/i=0, i<9, i++)
			if (!E.reagents || E.reagents.total_volume <= 0) break
			var/obj/effects/spray/S = new/obj/effects/spray(theturf)
			SPAWN_DBG(15 SECONDS) qdel(S)
			S.set_dir(direction)
			S.original_dir = direction
			direction = turn(direction,45)
			S.create_reagents(5)
			E.reagents.copy_to(S.reagents)
			E.reagents.remove_any(5)

			//var/icon/IC = icon(S.icon,S.icon_state)
			//IC.Blend(S.reagents.get_master_color(),ICON_MULTIPLY)
			//S.icon = IC
			spraybits += S

			/* // What the heck? This ran 8 times. Also the spraybits loop does the same exact thing below. commenting this out to prevent fluid duplication
			SPAWN_DBG(0)
				S.reagents.reaction(theturf, TOUCH)
				for(var/atom/A in theturf)
					if (istype(A,/obj/fluid)) continue
					S.reagents.reaction(A, TOUCH, 0, 0)
			*/

		if (the_mob) playsound(the_mob, 'sound/effects/spray.ogg', 75, 1, 0)
		//E.reagents.clear_reagents()

		sleep(0.5 SECONDS)
		E.special = 0

		SPAWN_DBG(0)
			//Center tile
			var/obj/effects/spray/S = spraybits[1]
			S.reagents.reaction(S.loc, TOUCH)
			for(var/atom/A in S.loc)
				if (S?.reagents) //Wire: fix for: Cannot execute null.reaction()
					S.reagents.reaction(A, TOUCH,0,0)
			if(is_blocked_turf(S.loc))
				spraybits -= S
				qdel(S)

			//Distance tiles
			for(var/i=0, i<3, i++)
				for(var/obj/effects/spray/SP in spraybits)
					SP.set_loc(get_step(SP.loc, SP.original_dir))
					SP.reagents.reaction(SP.loc, TOUCH)
					for(var/atom/A in SP.loc)
						if (SP?.reagents) //Wire: fix for: Cannot execute null.reaction()
							SP.reagents.reaction(A, TOUCH,0,0)
					if(is_blocked_turf(SP.loc))
						spraybits -= SP
						qdel(SP)
				sleep(0.5 SECONDS)
		..()

	OnDrop()
		if (the_mob) the_mob.transforming = 0

////////////////////////////////////////////////////////////

/obj/ability_button/mask_toggle
	name = "Toggle Welding Mask"
	icon_state = "weldup"

	execute_ability()
		var/obj/item/clothing/head/helmet/welding/W = the_item
		if(W.up)
			W.up = !W.up
			W.icon_state = "welding"
			boutput(the_mob, "You flip the mask down. The mask is now protecting you from eye damage.")
			if (!W.nodarken) //Used for The Welder
				W.see_face = !W.see_face
				W.color_r = 0.3 // darken
				W.color_g = 0.3
				W.color_b = 0.3
			the_mob.set_clothing_icon_dirty()
			icon_state = "weldup"

			W.flip_down()
		else
			W.up = !W.up
			W.see_face = !W.see_face
			W.icon_state = "welding-up"
			boutput(the_mob, "You flip the mask up. The mask is now providing greater armor to your head.")
			W.color_r = 1 // default
			W.color_g = 1
			W.color_b = 1
			the_mob.set_clothing_icon_dirty()
			icon_state = "welddown"

			W.flip_up()
		..()


/obj/ability_button/labcoat_toggle
	name = "(Un)Button Labcoat"
	icon_state = "labcoat"

	execute_ability()
		var/obj/item/clothing/suit/labcoat/W = the_item
		if(W.buttoned)
			W.unbutton()
		else
			W.button()
		..()

/obj/ability_button/magboot_toggle
	name = "(De)Activate Magboots"
	icon_state = "shieldceon"

	execute_ability()
		var/obj/item/clothing/shoes/magnetic/W = the_item
		if(W.magnetic)
			W.deactivate()
			boutput(the_mob, "You power off your magnetic boots")
		else
			W.activate()
			boutput(the_mob, "You power on your magnetic boots")
		the_mob.update_equipped_modifiers()
		the_mob.update_clothing()
		..()
////////////////////////////////////////////////////////////

/obj/ability_button/tank_valve_toggle
	name = "Toggle Tank Valve"
	icon_state = "airoff"

	OnDrop() // since tanks close when dropped this should always start off
		icon_state = "airoff"
		..()

	execute_ability()
		var/obj/item/tank/T = the_item
		if (!T) return
		T.toggle_valve() // the tank valve toggle handles the icon updates since its also used by tank/Topic
		..()

////////////////////////////////////////////////////////////
///////////Sonic + Rocket Shoe Abilities & Smoke////////////
////////////////////////////////////////////////////////////

/obj/ability_button/shoerocket
	name = "Activate Shoes"
	icon_state = "rocketshoes"
	var/explosion_chance = 3

	execute_ability()
		if(!the_item || !the_mob || !the_mob.canmove) return
		var/obj/item/clothing/shoes/rocket/R = the_item

		if(the_mob:shoes != the_item)
			boutput(the_mob, "<span class='alert'>You must be wearing the shoes to use them.</span>")
			return

		R.uses--

		if(R.uses < 0)
			the_item.name = "Empty Rocket Shoes"
			boutput(the_mob, "<span class='alert'>Your rocket shoes are empty.</span>")
			R.abilities.Cut()
			qdel(src)
			return

		playsound(get_turf(the_mob), 'sound/effects/bamf.ogg', 100, 1)

		if(prob(explosion_chance) || R.emagged)
			boutput(the_mob, "<span class='alert'>The rocket shoes blow up!</span>")
			explosion(src, get_turf(the_mob), -1, -1, 1, 1)
			qdel(the_item)
			qdel(src)
			return
		if( the_mob.buckled )
			SPAWN_DBG(0)
				the_mob.emote("scream")
				the_mob:canmove = 0
				for(var/i=0, i<30, i++)
					if(!the_mob)
						return
					the_mob.changeStatus("stunned", 10 SECONDS)
					the_mob.pixel_x = rand(-5,5)
					the_mob.pixel_y = rand(-5,5)
					if (!the_mob.buckled) //Runtime fix: Cannot read null.anchored
						the_mob.gib()
					if(!the_mob.buckled:anchored)
						step(the_mob.buckled, pick(cardinal))
					if(i>10)
						the_mob:update_burning(10)
						if(prob(30))
							the_mob.emote("scream")
						sleep(0.1 SECONDS)
					else
						the_mob:update_burning(1)
						sleep(0.3 SECONDS)
				the_mob.unlock_medal( "Too Fast Too Furious", 1 )
				the_mob.gib()

			return
		SPAWN_DBG(0)
			var/turf/curr = get_turf(the_mob)

			for(var/i=0, i<15, i++)
				curr = get_step(curr, the_mob.dir)

			the_mob.throw_unlimited = 1

			SPAWN_DBG(0)
				for(var/i=0, i<15, i++)
					if(isnull(the_mob))
						break
					var/obj/effect/smoketemp/A = unpool(/obj/effect/smoketemp)
					A.set_loc(the_mob.loc)
					SPAWN_DBG(1 SECOND)
						src = null // Detatch this from the parent proc so we get to stay alive if the shoes blow up.
						if(A)
							pool(A)
					sleep(0.1 SECONDS)

			the_mob.throw_at(curr, 16, 3)
			..()


/obj/ability_button/sonic
	name = "Activate Shoes"
	icon_state = "rocketshoes"

	execute_ability()
		if(!the_item || !the_mob || !the_mob.canmove) return
		var/obj/item/clothing/shoes/sonic/R = the_item

		if(the_mob:shoes != the_item)
			boutput(the_mob, "<span class='alert'>You must be wearing the shoes to use them.</span>")
			return

		playsound(get_turf(the_mob), "sound/effects/bamf.ogg", 100, 1)

		SPAWN_DBG(0)
			for(var/i=0, i<R.soniclength, i++)
				if(!the_mob) break
				var/obj/effect/smoketemp/A = unpool(/obj/effect/smoketemp)
				A.set_loc(the_mob.loc)
				SPAWN_DBG(1 SECOND)
					src = null
					if(A)
						pool(A)
				if (!step(the_mob, the_mob.dir) && R.sonicbreak) break
				sleep(10 - R.soniclevel)
			..()

/obj/effect/smoketemp
	name = "smoke"
	density = 0
	anchored = 0
	opacity = 0
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"

	pooled()
		..()
		icon = null
		icon_state = null

	unpooled()
		..()
		icon = initial(icon)
		icon_state = initial(icon_state)

////////////////////////////////////////////////////////////

/obj/ability_button/cebelt_toggle
	name = "Toggle overshield"
	icon_state = "shieldceon"

	execute_ability()
		var/obj/item/storage/belt/utility/prepared/ceshielded/C = the_item
		C.toggle()
		..()
		//if(C.active) icon_state = "shieldceoff"
		//else icon_state = "shieldceon"

////////////////////////////////////////////////////////////

/obj/ability_button/flashlight_toggle
	name = "Toggle Flashlight"
	icon_state = "on"

	execute_ability()
		var/obj/item/device/light/flashlight/J = the_item
		J.toggle()
		..()

////////////////////////////////////////////////////////////

/obj/ability_button/saw_toggle
	name = "Toggle Saw"
	icon_state = "saw"

	execute_ability()
		var/obj/item/saw/S = the_item
		S.attack_self(usr)
		..()

////////////////////////////////////////////////////////////

/obj/ability_button/cable_toggle
	name = "Toggle auto-laying mode"
	icon_state = "coil"

	execute_ability()
		var/obj/item/cable_coil/C = the_item
		C.attack_self(usr)
		..()

////////////////////////////////////////////////////////////

/obj/ability_button/flashlight_engiehelm
	name = "Toggle Helmet Light"
	icon_state = "on"

	execute_ability()
		var/obj/item/clothing/head/helmet/space/engineer/J = the_item

		J.flashlight_toggle(the_mob)
		if (J.on) src.icon_state = "off"
		else  src.icon_state = "on"
		..()

////////////////////////////////////////////////////////////

/obj/ability_button/flashlight_hardhat
	name = "Toggle Hardhat Light"
	icon_state = "on"

	execute_ability()
		var/obj/item/clothing/head/helmet/hardhat/J = the_item

		J.flashlight_toggle(the_mob)
		src.icon_state = J.on ? "off" : "on"
		..()

////////////////////////////////////////////////////////////

/obj/ability_button/tscanner_toggle
	name = "Toggle T-Scanner"
	icon_state = "on"

	execute_ability()
		var/obj/item/device/t_scanner/J = the_item
		J.attack_self(the_mob)
		if(J.on) icon_state = "off"
		else  icon_state = "on"
		..()

////////////////////////////////////////////////////////////

/obj/ability_button/meson_toggle
	name = "Toggle Meson Goggles"
	icon_state = "meson1"

	execute_ability()
		var/obj/item/clothing/glasses/meson/J = the_item
		J.attack_self(the_mob)
		if(J.on) icon_state = "meson1"
		else  icon_state = "meson0"
		..()

////////////////////////////////////////////////////////////

/obj/ability_button/nukie_meson_toggle
	name = "Toggle Helmet Scanner"
	icon_state = "meson0"

	execute_ability()
		var/obj/item/clothing/head/helmet/space/syndicate/specialist/engineer/J = the_item
		J.attack_self(the_mob)
		if(J.on) icon_state = "meson1"
		else  icon_state = "meson0"
		..()

////////////////////////////////////////////////////////////

/obj/ability_button/jetpack2_toggle
	name = "Toggle jetpack MKII"
	icon_state = "jet2on"

	execute_ability()
		var/obj/item/tank/jetpack/jetpackmk2/J = the_item
		J.toggle()
		if(J.on) icon_state = "jet2off"
		else  icon_state = "jet2on"
		..()

/obj/ability_button/jetpack_toggle
	name = "Toggle jetpack"
	icon_state = "jeton"

	execute_ability()
		var/obj/item/tank/jetpack/J = the_item
		J.toggle()
		if(J.on) icon_state = "jetoff"
		else  icon_state = "jeton"
		..()

////////////////////////////////////////////////////////////

/obj/ability_button/jetboot_toggle
	name = "Toggle jet boots"
	icon_state = "jeton"

	execute_ability()
		var/obj/item/clothing/shoes/jetpack/J = the_item
		J.toggle()
		icon_state = "jet[J.on ? "off" : "on"]"
		..()

////////////////////////////////////////////////////////////

/obj/ability_button/magtractor_toggle
	name = "Toggle High Power Mode"
	icon_state = "magtractor0"

	execute_ability()
		var/obj/item/magtractor/M = the_item
		if (!istype(M)) return
		M.toggleHighPower()
		icon_state = "magtractor[M.highpower]"
		..()

/obj/ability_button/magtractor_drop
	name = "Release Item"
	icon_state = "mag_drop0"
	// would look better at CENTER-4,SOUTH on ghost drones but CBA to move it there right now, would require some hacky nonsense

	execute_ability()
		var/obj/item/magtractor/M = the_item
		if (!istype(M) || !M.holding)
			return
		if (M.releaseItem() && !M.holding)
			icon_state = "mag_drop0"
		..()

////////////////////////////////////////////////////////////

/obj/ability_button/football_charge
	name = "Rush"
	icon_state = "rushon"
	cooldown = 100

	ability_allowed()
		if (!the_mob || !the_mob.canmove || the_mob.stat || the_mob.getStatusDuration("paralysis"))
			boutput(the_mob, "<span class='alert'>You need to be ready on your feet to use this ability.</span>")
			return 0

		if(ishuman(the_mob) && the_mob:wear_suit != the_item)
			boutput(the_mob, "<span class='alert'>You must be wearing [the_item] to use this ability.</span>")
			return 0

		if(!..())
			return 0

		return 1


	execute_ability()

		if (ticker && istype(ticker.mode, /datum/game_mode/football))
			if (the_mob.find_type_in_hand(/obj/item/football/the_big_one))
				src.cooldown = 100
			else
				src.cooldown = 30

		the_mob:rush()
		icon_state = "rushoff"

		..()
		return 1

	on_cooldown()
		..()
		icon_state = "rushon"


////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

/*
	Sniper scope zoom ability toggles
	Major help by: pali6
*/

/* this version just increases viewsize */
/obj/ability_button/scope_toggle_viewsize
	name = "Toggle Scope Zoom"
	icon_state = "airoff"
	cooldown = 10

	OnDrop()
		if(usr.client.widescreen)
			usr.client.view = "21x15"
		else
			usr.client.view = "15x15"
		icon_state = "airoff"
		..()

	execute_ability()
		if (usr.client.widescreen)
			if (usr.client.view == "21x15")
				usr.client.view = "28x20"
				icon_state = "airon"
			else
				usr.client.view = "21x15"
				icon_state = "airoff"
		else //not widescreen
			if (usr.client.view == "15x15")// 15x15 should be default for non-widescreen
				usr.client.view = "20x20"
				icon_state = "airon"
			else
				usr.client.view = "15x15"
				icon_state = "airoff"
		..()

////////////////////////////////////////////////////////////

/* this version moves the center of your view */

/obj/ability_button/scope_toggle
	name = "Toggle Scope"
	var/off_icon = "northoff"
	var/on_icon = "northon"
	var/distance = 200
	var/x_mult = 0
	var/y_mult = 0
	var/zoomed = 0

	New()
		icon_state = off_icon
		..()

	OnDrop()
		set_zoom(0)
		..()

	execute_ability()
		set_zoom(!zoomed)
		..()

/obj/ability_button/scope_toggle/proc/set_zoom(var/new_zoomed)
	if(new_zoomed == zoomed)
		return
	if(new_zoomed) // we unzoom all the other buttons
		for(var/obj/ability_button/scope_toggle/S in the_item.ability_buttons)
			S.set_zoom(0)
			zoomed = new_zoomed
			if(zoomed)
				usr.client.pixel_x += distance * x_mult
				usr.client.pixel_y += distance * y_mult
				icon_state = on_icon
			//todo playsound here
			else
				usr.client.pixel_x -= distance * x_mult
				usr.client.pixel_y -= distance * y_mult
				icon_state = off_icon

/obj/ability_button/scope_toggle/north
	name = "Zoom North"
	y_mult = 1
	on_icon = "northon"
	off_icon = "northoff"

/obj/ability_button/scope_toggle/south
	name = "Zoom South"
	y_mult = -1
	on_icon = "southon"
	off_icon = "southoff"

/obj/ability_button/scope_toggle/west
	name = "Zoom West"
	x_mult = -1
	on_icon = "weston"
	off_icon = "westoff"

/obj/ability_button/scope_toggle/east
	name = "Zoom East"
	x_mult = 1
	on_icon = "easton"
	off_icon = "eastoff"

////////////////////////////////////////////////////////////

//cancel-camera-view, but as a button
/obj/ability_button/reset_view
	name = "Reset view"
	icon_state = "jeton"

	execute_ability()
		//var/mob/M = holder.owner
		usr.set_eye(null)
		usr.client.view = world.view
		..()

//////////////////////////////////////////////////////////////////////////////
/mob/var/list/item_abilities = new/list()
/mob/var/need_update_item_abilities = 0

/mob/proc/update_item_abilities()
	if(!src.client || !need_update_item_abilities) return

	need_update_item_abilities = 0
	//src.client.screen -= src.item_abilities
	for(var/obj/ability_button/B in src.client.screen)
		src.client.screen -= B

	if(src.stat) return

	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		H.hud.update_ability_hotbar()

	// shifted all the stuff down there over to the hud file human.dm

	//var/pos_x = 1
	//var/pos_y = 0

	//for(var/obj/ability_button/B2 in src.item_abilities)
	//	B2.screen_loc = "NORTH-[pos_y],[pos_x]"
	//	src.client.screen += B2
	//	pos_x++
	//	if(pos_x > ITEM_ABILITIES_WRAP_AT)
	//		pos_x = 1
	//		pos_y++

//////////////////////////////////////////////////////////////////////////////

////////////////////////// Base vars & procs /////////////////////////////////

//If you want an item to have abilities, you need to make sure
//you add the stuff in the new proc here to its new proc, should it have one.
//You also need to add the pickup / dropped stuff if the item has custom ones.
//In some cases you might be able to use ..() instead.

// re: ^^^
// please just use ..() instead of copy/pasting this stuff unless you have a REALLY GOOD REASON to override New()!!
// tia, with love, haine

/obj/item/

	var/list/abilities = null//list("")
	var/list/ability_buttons = null//new/list()

	var/mob/the_mob = null

	New()
		if (islist(src.abilities))
			for(var/A in abilities)
				if(!ispath(A,/obj/ability_button))
					abilities -= A
					continue
				var/obj/ability_button/NB = new A(src)
				if (!islist(src.ability_buttons))
					ability_buttons = list()
				ability_buttons += NB

			for(var/obj/ability_button/B in ability_buttons)
				B.the_item = src
				B.name = B.name + " ([src.name])"
//		if(ability_buttons.len > 0)
//			SPAWN_DBG(0) check_abilities()
		..()

	proc/disposing_abilities()
		if (!isnull(ability_buttons))
			src.hide_buttons()
			for (var/obj/ability_button/A in ability_buttons)
				qdel(A)
			ability_buttons.len = 0
		src.the_mob = null

	proc/clear_mob()
		if (islist(src.ability_buttons))
			for(var/obj/ability_button/B in ability_buttons)
				B.the_mob = null
		the_mob = null

	proc/set_mob(var/mob/M)
		if(!M) return
		if (islist(src.ability_buttons))
			for(var/obj/ability_button/B in ability_buttons)
				B.the_mob = M
		the_mob = M

	proc/show_buttons()
		if(!the_mob || !islist(src.ability_buttons) || !ability_buttons.len) return
		if(!the_mob.item_abilities.Find(ability_buttons[1]))
			the_mob.item_abilities.Add(ability_buttons)
			the_mob.need_update_item_abilities = 1
			the_mob.update_item_abilities()

	proc/hide_buttons()
		if(!the_mob || !islist(src.ability_buttons)) return
		the_mob.item_abilities?.Remove(ability_buttons)
		the_mob.need_update_item_abilities = 1
		the_mob.update_item_abilities()
/*
	proc/check_abilities()
		if (!(src in heh))
			heh += src
			boutput(world, "heh len = [heh.len]")
		if(!the_mob)
			SPAWN_DBG(3 SECONDS) check_abilities()
			return

		if(!(src in the_mob.get_equipped_items()))
			hide_buttons()
		else
			if(istype(src,/obj/item/clothing/suit/wizrobe))
				clear_buttons()
			show_buttons()

		SPAWN_DBG(1 SECOND) check_abilities()
*/

	proc/clear_buttons()
		if(!the_mob) return
		the_mob.item_abilities = list()

//HEY this should be moved over to use /obj/screen/ability_button but it breaks a few paths and needs different procs and its outta my depth tbh
/obj/ability_button
	name = "baseButton"
	desc = ""
	icon = 'icons/misc/abilities.dmi'
	icon_state = "test"
	layer = HUD_LAYER
	plane = PLANE_HUD
	anchored = 1
	flags = NOSPLASH

	var/cooldown = 0
	var/last_use_time = 0

	var/targeted = 0 //does activating this ability let you click on something to target it?
	var/target_anything = 0 //can you target any atom, not just people?

	var/obj/item/the_item = null
	var/mob/the_mob = null

	RawClick()
		if(src.ability_allowed())
			if (src.targeted)
				if (src.the_mob.targeting_ability)
					src.the_mob.targeting_ability = null
					src.the_mob.update_cursor()
					return
				src.the_mob.targeting_ability = src
				src.the_mob.update_cursor()
			else
				src.execute_ability()

	attackby()
		return

	attack_hand()
		return

	//WIRE TOOLTIPS
	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.showHover(src, list(
				"params" = params,
				"title" = src.name,
				"content" = (src.desc ? src.desc : null)
			))

	MouseExited()
		if (usr.client.tooltipHolder)
			usr.client.tooltipHolder.hideHover()

	disposing() //probably best to do this?
		if (src.the_item)
			if(length(src.the_item.ability_buttons))
				src.the_item.ability_buttons -= src
			src.the_item = null
		if (src.the_mob) // TODO: remove from mob properly
			src.the_mob = null
		..()

	proc/ability_allowed()
		if (!src.the_item)
			return 0
		if (!src.the_mob)
			return 0
		if (src.the_mob.hasStatus(list("paralysis", "stunned", "weakened"))) //stun check
			return 0
		if (src.the_mob && ishuman(src.the_mob)) //cuff, straightjacket, nolimb check
			var/mob/living/carbon/human/H = the_mob
			if (H.restrained())
				return 0
		if (src.last_use_time && src.cooldown && ( src.last_use_time + cooldown ) > TIME)
			boutput(src.the_mob, "<span class='alert'>This ability is recharging. ([round((src.cooldown/10)-((TIME - src.last_use_time)/10))] seconds left)</span>")
			return 0
		return 1

	//Called when the cooldown has finished
	proc/on_cooldown()
		return

	//please call back to parent to trigger handle cooldown
	proc/execute_ability()
		src.handle_cooldown()
		return

	proc/OnDrop()
		return

	proc/handle_cooldown() //copy and pasted from Click() - which is dead now
		if (src.cooldown)
			src.last_use_time = TIME
			sleep(src.cooldown)
			src.on_cooldown()
