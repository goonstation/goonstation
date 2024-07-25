/*
 * Fluid Drains
 * Fluid Channels
 * Fluid Spawners
 */


///////////////////
//////Drainage/////
///////////////////

TYPEINFO(/obj/machinery/drainage)
	mats = 8

TYPEINFO(/obj/machinery/drainage/big)
	mats = 12

/obj/machinery/drainage
	name = "drain"
	desc = "A drainage pipe embedded in the floor to prevent flooding. Where does the drain go? Nobody knows."
	anchored = ANCHORED
	density = 0
	icon = 'icons/obj/fluid.dmi'
	var/base_icon = "drain"
	icon_state = "drain"
	plane = PLANE_FLOOR //They're supposed to be embedded in the floor.
	flags = FLUID_SUBMERGE | NOSPLASH
	var/clogged = 0 //temporary block
	var/welded = 0 //permanent block
	var/drain_min = 2
	var/drain_max = 7
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER


	big
		base_icon = "bigdrain"
		icon_state = "bigdrain"
		drain_min = 6
		drain_max = 14

	New()
		START_TRACKING
		..()

	disposing()
		. = ..()
		STOP_TRACKING

	process()
		var/turf/T = get_turf(src)
		if (!T)
			return
		if (T.active_liquid)
			if (clogged)
				clogged--
				return
			if (welded)
				return

			var/obj/fluid/F = T.active_liquid
			if (F.group)
				F.group.queued_drains += rand(drain_min,drain_max)
				F.group.last_drain = T
				if (!F.group.draining)
					F.group.add_drain_process()

				playsound(src.loc, 'sound/misc/drain_glug.ogg', 50, 1)

				//moved to fluid process
				//F.group.reagents.skip_next_update = 1
				//F.group.drain(F,rand(drain_min,drain_max)) //420 drain it



	attackby(obj/item/I, mob/user)
		if (isweldingtool(I))
			if(!I:try_weld(user, 2))
				return

			if (!src.welded)
				src.welded = 1
				logTheThing(LOG_STATION, user, "welded [name] shut at [log_loc(user)].")
				user.show_text("You weld the drain shut.")
			else
				logTheThing(LOG_STATION, user, "un-welded [name] at [log_loc(user)].")
				src.welded = 0
				user.show_text("You unseal the drain with your welder.")

			if (src.clogged)
				src.clogged = 0
				user.show_text("The drain clog melts away.")

			src.UpdateIcon()
			return
		if (istype(I,/obj/item/material_piece/cloth))
			var/obj/item/material_piece/cloth/C = I
			src.clogged += (20 * C.amount) //One piece of cloth clogs for about 1 minute. (cause the machine loop updates ~3 second interval)
			user.show_text("You stuff [I] into the drain.")
			logTheThing(LOG_STATION, user, "clogs [name] shut temporarily at [log_loc(user)].")
			qdel(I)
			src.UpdateIcon()
			return

		if (I.is_open_container() && I.reagents)
			boutput(user, SPAN_ALERT("You dump all the reagents into the drain.")) // we add NOSPLASH so the default beaker/glass-splash doesn't occur
			I.reagents.remove_any(I.reagents.total_volume) // just dump it all out
			return

		return ..()

	update_icon()
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
	anchored = ANCHORED
	density = 0
	icon = 'icons/obj/fluid.dmi'
	icon_state = "channel"
	name = "channel"
	desc = "A channel that can restrict liquid flow in one direction."
	flags = FLUID_DENSE
	var/required_to_pass = 150 //fluid on the side that my Dir points to will need this amount to be able to cross

	New()
		..()
		src.invisibility = INVIS_ALWAYS_ISH

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
	invisibility = INVIS_ADVENTURE

	var/datum/reagents/R

	event_handler_flags = IMMUNE_MANTA_PUSH

	New()
		..()
		SPAWN(delay)
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

	wine
		amount = 330
		reagent_id = "wine"

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


TYPEINFO(/obj/machinery/fluid_canister)
	mats = 20

/obj/machinery/fluid_canister
	anchored = UNANCHORED
	density = 1
	icon = 'icons/obj/fluid.dmi'
	var/base_icon = "blue"
	icon_state = "blue0"
	name = "fluid canister"
	desc = "A canister that can drink large amounts of fluid and spit it out somewhere else. Gross."
	var/bladder = 20000 //how much I can hold
	var/slurp = 10 //tiles of fluid to drain per tick
	var/piss = 500 //amt of reagents to piss out per tick
	deconstruct_flags = DECON_CROWBAR | DECON_WELDER

	var/slurping = 0
	var/pissing = 0

	var/contained = 0

	var/list/datum/contextAction/contexts = list()

	New()
		contextLayout = new /datum/contextLayout/experimentalcircle
		..()
		for(var/actionType in childrentypesof(/datum/contextAction/fluid_canister))
			src.contexts += new actionType()

		src.reagents = new /datum/reagents(bladder)
		src.reagents.my_atom = src
		UpdateIcon()

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
			if (src.reagents.total_volume < src.reagents.maximum_volume)
				var/turf/T = get_turf(src)
				if (T.active_liquid && T.active_liquid.group && T.active_liquid.group.reagents)
					T.active_liquid.group.drain(T.active_liquid,slurp,src)
					if (prob(80))
						playsound(src.loc, 'sound/impact_sounds/Liquid_Slosh_1.ogg', 25, 0.1, 0.7)
				UpdateIcon()

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

				UpdateIcon()

	update_icon()
		var/amt = round((src.reagents.total_volume / src.reagents.maximum_volume) * 12,1)
		icon_state = "[base_icon][amt]"

		var/overlay_istate = "w_off"
		if (slurping)
			overlay_istate = "w_2"
		else if (pissing)
			overlay_istate = "w_1"
		else
			overlay_istate = "w_off"

		AddOverlays(SafeGetOverlayImage("working", 'icons/obj/fluid.dmi', overlay_istate), "working")

		var/activetext = "OFF"
		if (slurping) activetext = "IN"
		if (pissing) activetext = "OUT"
		desc = initial(desc) + \
			" The pump is set to <em>[activetext]</em>." + \
			" It's currently holding <em>[src.reagents.total_volume] units</em>."

		for(var/datum/contextAction/fluid_canister/button in src.contexts)
			switch (button.type)
				if (/datum/contextAction/fluid_canister/off)
					button.icon_state = activetext == "OFF" ? "off" : "off_active"
				if (/datum/contextAction/fluid_canister/slurp)
					button.icon_state = activetext == "IN" ? "in_active" : "in"
				if (/datum/contextAction/fluid_canister/piss)
					button.icon_state = activetext == "OUT" ? "out_active" : "out"

	attack_hand(var/mob/user)
		user.showContextActions(src.contexts, src, src.contextLayout)
		return

/obj/machinery/fluid_canister/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/atmosporter))
		var/obj/item/atmosporter/porter = W
		if (length(porter.contents) >= porter.capacity) boutput(user, SPAN_ALERT("Your [W] is full!"))
		else
			user.visible_message(SPAN_NOTICE("[user] collects the [src]."), SPAN_NOTICE("You collect the [src]."))
			src.contained = 1
			src.set_loc(W)
			elecflash(user)
	..()

/obj/machinery/fluid_canister/proc/change_mode(var/mode)
	switch (mode)
		if (FLUID_CANISTER_MODE_OFF)
			slurping = 0
			pissing = 0
			UpdateIcon()
		if (FLUID_CANISTER_MODE_SLURP)
			slurping = 1
			pissing = 0
			UpdateIcon()
		if (FLUID_CANISTER_MODE_PISS)
			slurping = 0
			pissing = 1
			UpdateIcon()

/datum/contextAction/fluid_canister
	icon = 'icons/ui/context16x16.dmi'
	close_clicked = TRUE
	close_moved = TRUE
	desc = ""
	var/mode = FLUID_CANISTER_MODE_OFF

	execute(var/obj/machinery/fluid_canister/fluid_canister)
		if (!istype(fluid_canister))
			return
		fluid_canister.change_mode(src.mode)

	checkRequirements(obj/machinery/fluid_canister/fluid_canister, mob/user)
		. = can_act(user) && in_interact_range(fluid_canister, user)

	off
		name = "OFF"
		icon_state = "off"
		mode = FLUID_CANISTER_MODE_OFF
	slurp
		name = "IN"
		icon_state = "in"
		mode = FLUID_CANISTER_MODE_SLURP
	piss
		name = "OUT"
		icon_state = "out"
		mode = FLUID_CANISTER_MODE_PISS

///////////////////
//////canister/////
///////////////////

/obj/sea_ladder_deployed
	name = "deployed sea ladder"
	desc = "A deployable sea ladder that will allow you to descend to and ascend from the trench."
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder_on"
	event_handler_flags = IMMUNE_TRENCH_WARP

	var/obj/sea_ladder_deployed/linked_ladder
	var/obj/item/sea_ladder/og_ladder_item = 0
	anchored = ANCHORED

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

	Click(location, control, params)
		if (isobserver(usr))
			return src.attack_hand(usr)
		..()

	attack_ai(mob/user)
		if (can_act(user) && in_interact_range(src, usr))
			return src.attack_hand(user)
		. = ..()


TYPEINFO(/obj/item/sea_ladder)
	mats = 7

/obj/item/sea_ladder
	name = "sea ladder"
	desc = "A deployable sea ladder that will allow you to descend to and ascend from the trench."
	icon = 'icons/obj/fluid.dmi'
	icon_state = "ladder_off"
	item_state = "sea_ladder"
	w_class = W_CLASS_NORMAL
	throwforce = 10
	flags = TABLEPASS | CONDUCT
	force = 9
	stamina_damage = 30
	stamina_cost = 20
	stamina_crit_chance = 6
	var/c_color = null

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		BLOCK_SETUP(BLOCK_LARGE)

	afterattack(atom/target, mob/user as mob)
		. = ..()
		if (istype(target,/turf/space/fluid/warp_z5/realwarp))
			var/turf/space/fluid/warp_z5/realwarp/hole = target
			var/datum/component/pitfall/target_coordinates/targetzcomp = hole.GetComponent(/datum/component/pitfall/target_coordinates)
			targetzcomp.update_targets()
			deploy_ladder(hole, pick(targetzcomp.TargetList), user)

		else if (istype(target,/turf/space/fluid/warp_z5))
			var/turf/space/fluid/warp_z5/hole = target
			var/datum/component/pitfall/target_area/targetacomp = hole.GetComponent(/datum/component/pitfall/target_area)
			deploy_ladder(hole, pick(get_area_turfs(targetacomp.TargetArea)), user)

		else if(istype(target, /turf/space/fluid))
			var/turf/space/fluid/T = target
			if(T.linked_hole)
				deploy_ladder(T, T.linked_hole, user)
			else if(istype(T.loc, /area/trench_landing))
				deploy_ladder(T, pick(by_type[/turf/space/fluid/warp_z5/edge]), user)

	proc/deploy_ladder(turf/source, turf/dest, mob/user)
		user.show_text("You deploy [src].")
		playsound(src.loc, 'sound/effects/airbridge_dpl.ogg', 60, 1)

		var/obj/sea_ladder_deployed/L = new /obj/sea_ladder_deployed(source)
		L.linked_ladder = new /obj/sea_ladder_deployed(dest)
		L.linked_ladder.linked_ladder = L

		user.drop_item()
		src.set_loc(L)
		L.og_ladder_item = src
		L.linked_ladder.og_ladder_item = src

TYPEINFO(/obj/naval_mine)
	mats = 16

/obj/naval_mine
	name = "naval mine"
	desc = "This looks explosive!"
	icon = 'icons/obj/sealab_objects.dmi'
	icon_state = "mine_0"
	density = 1
	anchored = UNANCHORED

	deconstruct_flags = DECON_WRENCH | DECON_WELDER | DECON_MULTITOOL

	var/active = 1

	var/powerupsfx = 'sound/items/miningtool_on.ogg'
	var/powerdownsfx = 'sound/items/miningtool_off.ogg'

	var/boom_str = 26

	New()
		..()
		animate_bumble(src)
		add_simple_light("naval_mine", list(255, 102, 102, 40))

	get_desc()
		. += "It is [active ? "armed" : "disarmed"]."

	ex_act(severity)
		return //nah

	proc/boom()
		if (src.active)
			logTheThing(LOG_BOMBING, src.fingerprintslast, "A naval mine explodes at [log_loc(src)]. Last touched by [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"].")
			src.blowthefuckup(boom_str)


	attack_hand(var/mob/living/carbon/human/user)
		src.add_fingerprint(user)

		active = !active
		if (active)
			playsound(src.loc, powerupsfx, 50, 1, 0.1, 1)
			user.visible_message(SPAN_NOTICE("[user] activates [src]."), SPAN_NOTICE("You activate [src]."))
		else
			playsound(src.loc, powerdownsfx, 50, 1, 0.1, 1)
			user.visible_message(SPAN_NOTICE("[user] disarms [src]."),SPAN_NOTICE("You disarm [src]."))

	attackby(obj/item/I, mob/user)
		if (isscrewingtool(I) || ispryingtool(I) || ispulsingtool(I))
			src.Attackhand(user)
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
