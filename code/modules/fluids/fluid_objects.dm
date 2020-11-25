/*
 * Fluid Drains
 * Fluid Channels
 * Fluid Spawners
 */


///////////////////
//////Drainage/////
///////////////////

/obj/machinery/drainage
	anchored = 1
	density = 0
	icon = 'icons/obj/fluid.dmi'
	var/base_icon = "drain"
	icon_state = "drain"
	plane = PLANE_FLOOR //They're supposed to be embedded in the floor.
	name = "drain"
	desc = "A drainage pipe embedded in the floor to prevent flooding. Where does the drain go? Nobody knows."
	var/turf/my_turf
	var/clogged = 0 //temporary block
	var/welded = 0 //permanent block
	var/drain_min = 2
	var/drain_max = 7
	mats = 8
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER


	big
		base_icon = "bigdrain"
		icon_state = "bigdrain"
		mats = 12
		drain_min = 6
		drain_max = 14

	New()
		my_turf = get_turf(src)
		START_TRACKING
		..()

	disposing()
		. = ..()
		STOP_TRACKING

	process()
		if (!my_turf)
			my_turf = get_turf(src)
			if (!my_turf) return
		if (my_turf.active_liquid)
			if (clogged)
				clogged--
				return
			if (welded)
				return

			var/obj/fluid/F = my_turf.active_liquid
			if (F.group)
				F.group.queued_drains += rand(drain_min,drain_max)
				F.group.last_drain = my_turf
				if (!F.group.draining)
					F.group.add_drain_process()

				playsound(src.loc, "sound/misc/drain_glug.ogg", 50, 1)

				//moved to fluid process
				//F.group.reagents.skip_next_update = 1
				//F.group.drain(F,rand(drain_min,drain_max)) //420 drain it



	attackby(obj/item/I as obj, mob/user as mob)
		if (isweldingtool(I))
			if(!I:try_weld(user, 2))
				return

			if (!src.welded)
				src.welded = 1
				logTheThing("station", user, null, "welded [name] shut at [log_loc(user)].")
				user.show_text("You weld the drain shut.")
			else
				logTheThing("station", user, null, "un-welded [name] at [log_loc(user)].")
				src.welded = 0
				user.show_text("You unseal the drain with your welder.")

			if (src.clogged)
				src.clogged = 0
				user.show_text("The drain clog melts away.")

			src.update_icon()
			return
		if (istype(I,/obj/item/material_piece/cloth))
			var/obj/item/material_piece/cloth/C = I
			src.clogged += (20 * C.amount) //One piece of cloth clogs for about 1 minute. (cause the machine loop updates ~3 second interval)
			user.show_text("You stuff [I] into the drain.")
			logTheThing("station", user, null, "clogs [name] shut temporarily at [log_loc(user)].")
			pool(I)
			src.update_icon()
			return

		return ..()

	proc/update_icon()
		if (clogged)
			icon_state = "[base_icon]_clogged"
		else if (welded)
			icon_state = "[base_icon]_welded"
		else
			icon_state = "[base_icon]"

///////////////////
//////Channel//////
///////////////////

/obj/channel
	anchored = 1
	density = 0
	icon = 'icons/obj/fluid.dmi'
	icon_state = "channel"
	name = "channel"
	desc = "A channel that can restrict liquid flow in one direction."
	flags = ALWAYS_SOLID_FLUID
	var/required_to_pass = 150 //fluid on the side that my Dir points to will need this amount to be able to cross

	New()
		..()
		src.invisibility = 100

///////////////////
//////spawner//////
///////////////////

//use these to have fluids be built into areas of a map on load
//spawn fluid, then delete self

/obj/fluid_spawner
	var/reagent_id = "water"
	var/amount = 10
	var/delay = 600
	icon = 'icons/effects/mapeditor.dmi'
	icon_state = "fluid_spawn"

	var/datum/reagents/R

	event_handler_flags = IMMUNE_MANTA_PUSH

	New()
		..()
		SPAWN_DBG(delay)
			R = new /datum/reagents(amount)
			R.add_reagent(reagent_id, amount)

			var/turf/T = get_turf(src)
			if (istype(T))
				T.fluid_react(R,amount)
				R.clear_reagents()

				qdel(src)

	shortdelay
		amount = 50
		delay = 10

	shortdelaybig
		amount = 5000
		delay = 10


	polluted_filth
		delay = 35
		amount = 1250
		reagent_id = "sewage"

		madness
			amount = 166
			reagent_id = "madness_toxin"

		blood
			amount = 175
			reagent_id = "blood"

		black_goop
			amount = 148
			reagent_id = "black_goop"

		green_goop
			amount = 143
			reagent_id = "green_goop"

		yuck
			amount = 150
			reagent_id = "yuck"

		salmonella
			amount = 135
			reagent_id = "salmonella"

		bathsalts
			amount = 130
			reagent_id = "bathsalts"

		ecoli
			amount = 136
			reagent_id = "e.coli"

		crank
			amount = 145
			reagent_id = "crank"


///////////////////
//////canister//////
///////////////////


/obj/machinery/fluid_canister
	anchored = 0
	density = 1
	icon = 'icons/obj/fluid.dmi'
	var/base_icon = "blue"
	icon_state = "blue0"
	name = "fluid canister"
	desc = "A canister that can drink large amounts of fluid and spit it out somewhere else. Gross."
	var/bladder = 20000 //how much I can hold
	var/slurp = 10 //tiles of fluid to drain per tick
	var/piss = 500 //amt of reagents to piss out per tick
	mats = 20
	deconstruct_flags = DECON_CROWBAR | DECON_WELDER

	var/slurping = 0
	var/pissing = 0

	var/contained = 0

	var/static/image/overlay_image = image('icons/obj/fluid.dmi')

	New()
		..()
		src.reagents = new /datum/reagents(bladder)
		src.reagents.my_atom = src
		update_icon()


	ex_act(severity)
		var/turf/T = get_turf(src)
		T.fluid_react(src.reagents, src.reagents.total_volume)
		src.reagents.clear_reagents()
		..(severity)
		qdel(src)

	is_open_container()
		.= -1

	disposing()
		if (src.reagents.total_volume > 0)
			var/turf/T = get_turf(src)
			if (T.active_liquid)
				var/obj/fluid/F = T.active_liquid
				if (F.group)
					src.reagents.trans_to_direct(F.group.reagents,src.reagents.total_volume)
			else
				T.fluid_react(src.reagents,src.reagents.total_volume)
		..()

	process()
		if(contained) return
		if (slurping)
			if (src.reagents.total_volume < bladder)
				var/turf/T = get_turf(src)
				if (T.active_liquid && T.active_liquid.group && T.active_liquid.group.reagents)
					T.active_liquid.group.drain(T.active_liquid,slurp,src)
					if (prob(80))
						playsound(src.loc, "sound/impact_sounds/Liquid_Slosh_1.ogg", 50, 0.1, 0.7)
				update_icon()

		else if (pissing)
			if (src.reagents.total_volume > 0)
				var/turf/T = get_turf(src)
				if (T.active_liquid)
					var/obj/fluid/F = T.active_liquid
					if (F.group)
						src.reagents.trans_to_direct(F.group.reagents,min(piss,src.reagents.total_volume))
				else
					if (istype(T, /turf/space/fluid))
						src.reagents.clear_reagents()
					else T.fluid_react(src.reagents,min(piss,src.reagents.total_volume))

				update_icon()

	proc/update_icon()
		var/amt = round((src.reagents.total_volume / bladder) * 12,1)
		icon_state = "[base_icon][amt]"

		if (slurping)
			overlay_image.icon_state = "w_2"
		else if (pissing)
			overlay_image.icon_state = "w_1"
		else
			overlay_image.icon_state = "w_off"

		UpdateOverlays(overlay_image, "working")

	Topic(href, href_list)
		if (usr.stat || usr.restrained())
			return
		if (get_dist(src, usr) <= 1)
			src.add_dialog(usr)

			if (href_list["slurp"])
				slurping = 1
				pissing = 0
				update_icon()

			if (href_list["piss"])
				slurping = 0
				pissing = 1
				update_icon()

			if (href_list["off"])
				slurping = 0
				pissing = 0
				update_icon()

			src.updateUsrDialog()
			src.add_fingerprint(usr)
		else
			usr.Browse(null, "window=fluid_canister")
			return
		return

	attack_hand(var/mob/user as mob)
		src.add_dialog(user)
		var/offtext
		var/intext
		var/outtext
		var/activetext
		var/width = 400
		var/height = 200

		offtext = "<A href='?src=\ref[src];off=1'>OFF</A>"
		intext = "<A href='?src=\ref[src];slurp=1'>IN</A>"
		outtext = "<A href='?src=\ref[src];piss=1'>OUT</A>"

		activetext = "OFF"
		if (slurping) activetext = "IN"
		if (pissing) activetext = "OUT"

		var/output_text = {"<div id="canister">
								<div class="header">
									<B>[name]</B><BR>
									Pump : [activetext]<BR>
									Set: [offtext] - [intext] - [outtext]<BR><BR>
									Volume: [src.reagents.total_volume] units<BR>
								</div>
								<hr>
							</div>"}

		user.Browse(output_text, "window=fluid_canister;size=[width]x[height]")
		onclose(user, "fluid_canister")
		return

/obj/machinery/fluid_canister/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/atmosporter))
		var/obj/item/atmosporter/porter = W
		if (porter.contents.len >= porter.capacity) boutput(user, "<span class='alert'>Your [W] is full!</span>")
		else
			user.visible_message("<span class='notice'>[user] collects the [src].</span>", "<span class='notice'>You collect the [src].</span>")
			src.contained = 1
			src.set_loc(W)
			elecflash(user)
	..()
///////////////////
//////canister/////
///////////////////

/obj/sea_ladder_deployed
	name = "deployed sea ladder"
	desc = "A deployable sea ladder that will allow you to descend to and ascend from the trench."
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder_on"

	var/obj/sea_ladder_deployed/linked_ladder
	var/obj/item/sea_ladder/og_ladder_item = 0
	anchored = 1

	verb/fold_up()
		set name = "Fold Up"
		set src in oview(1)
		set category = "Local"

		if (!og_ladder_item)
			if (linked_ladder?.og_ladder_item)
				og_ladder_item = linked_ladder.og_ladder_item
			else
				og_ladder_item = new /obj/item/sea_ladder(src.loc)
		og_ladder_item.set_loc(usr.loc)

		if (linked_ladder)
			qdel(linked_ladder)
		qdel(src)

	attack_hand(var/mob/user)
		if (!linked_ladder) return
		var/turf/target = 0

		for(var/turf/T in orange(1,linked_ladder))
			if (!istype(T,/turf/space/fluid/warp_z5))
				target = T
				break

		if (!target)
			user.show_text("This ladder does not lead to solid flooring!")
		else
			user.set_loc(target)
			user.show_text("You climb [src].")


/obj/item/sea_ladder
	name = "sea ladder"
	desc = "A deployable sea ladder that will allow you to descend to and ascend from the trench."
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder_off"
	item_state = "folded_chair"
	w_class = 4.0
	throwforce = 10
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 9
	stamina_damage = 30
	stamina_cost = 20
	stamina_crit_chance = 6
	var/c_color = null
	mats = 7

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_LARGE)

	afterattack(atom/target, mob/user as mob)
		if (istype(target,/turf/space/fluid/warp_z5))
			var/turf/space/fluid/warp_z5/hole = target
			hole.try_build_turf_list() //in case we dont have one yet

			user.show_text("You deploy [src].")
			playsound(src.loc, "sound/effects/airbridge_dpl.ogg", 60, 1)

			var/obj/sea_ladder_deployed/L = new /obj/sea_ladder_deployed(hole)
			L.linked_ladder = new /obj/sea_ladder_deployed(pick(hole.L))
			L.linked_ladder.linked_ladder = L

			user.drop_item()
			src.set_loc(L)
			L.og_ladder_item = src
			L.linked_ladder.og_ladder_item = src

			..()


/obj/naval_mine
	name = "naval mine"
	desc = "This looks explosive!"
	icon = 'icons/obj/sealab_objects.dmi'
	icon_state = "mine_0"
	density = 1
	anchored = 0

	mats = 16
	deconstruct_flags = DECON_WRENCH | DECON_WELDER | DECON_MULTITOOL
	flags = FPRINT

	var/active = 1

	var/powerupsfx = 'sound/items/miningtool_on.ogg'
	var/powerdownsfx = 'sound/items/miningtool_off.ogg'

	var/boom_str = 26

	var/datum/light/point/light = 0
	var/init = 0

	New()
		..()
		animate_bumble(src)
		if (current_state == GAME_STATE_PLAYING)
			initialize()

	disposing()
		light = 0
		..()

	initialize()
		..()
		if (!init)
			init = 1
			if (!light)
				light = new
				light.attach(src)
			light.set_brightness(1)
			light.set_color(1, 0.4, 0.4)
			light.set_height(3)
			light.enable()

	get_desc()
		. += "It is [active ? "armed" : "disarmed"]."


	ex_act(severity)
		return //nah

	proc/boom()
		if (src.active)
			logTheThing("bombing", src.fingerprintslast, null, "A naval mine explodes at [log_loc(src)]. Last touched by [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"].")
			src.blowthefuckup(boom_str)


	attack_hand(var/mob/living/carbon/human/user as mob)
		src.add_fingerprint(user)

		active = !active
		if (active)
			playsound(src.loc, powerupsfx, 50, 1, 0.1, 1)
			user.visible_message("<span class='notice'>[user] activates [src].</span>", "<span class='notice'>You activate [src].</span>")
		else
			playsound(src.loc, powerdownsfx, 50, 1, 0.1, 1)
			user.visible_message("<span class='notice'>[user] disarms [src].</span>","<span class='notice'>You disarm [src].</span>")

	attackby(obj/item/I, mob/user)
		if (isscrewingtool(I) || ispryingtool(I) || ispulsingtool(I))
			src.attack_hand(user)
		else
			boom()

	Bumped(M as mob|obj)
		if (!istype(M,/mob/living/critter/aquatic) && !istype(M,/obj/critter/gunbot))
			boom()

	bullet_act(var/obj/projectile/P)
		boom()


	standard
		name = "standard naval mine"

	rusted
		name = "rusted naval mine"
		icon_state = "mine_1"
		boom_str = 15

	vandalized
		name = "vandalized naval mine"
		icon_state = "mine_2"
		boom_str = 29

	syndicate
		name = "syndicate naval mine"
		icon_state = "mine_3"
		boom_str = 32
