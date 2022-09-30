
TYPEINFO(/obj/table)
	/// Determines what types this table will smooth with
	var/smooth_list = null
TYPEINFO_NEW(/obj/table)
	. = ..()
	smooth_list = typecacheof(/obj/table/auto)
/obj/table
	name = "table"
	desc = "A metal table strong enough to support a substantial amount of weight, but easily made portable by unsecuring the bolts with a wrench."
	icon = 'icons/obj/furniture/table.dmi'
	icon_state = "0"
	density = 1
	anchored = 1
	flags = NOSPLASH
	event_handler_flags = USE_FLUID_ENTER
	layer = OBJ_LAYER-0.1
	stops_space_move = TRUE
	mat_changename = 1
	mechanics_interaction = MECHANICS_INTERACTION_SKIP_IF_FAIL
	var/parts_type = /obj/item/furniture_parts/table
	var/auto = 0
	var/status = null //1=weak|welded, 2=strong|unwelded
	var/image/working_image = null
	var/has_storage = 0
	var/obj/item/storage/desk_drawer/desk_drawer = null
	var/slaps = 0
	var/hulk_immune = FALSE


	New(loc, obj/a_drawer)
		..()
		if (src.has_storage)
			if (a_drawer)
				src.desk_drawer = a_drawer
				src.desk_drawer.set_loc(src)
			else
				src.desk_drawer = new(src)
		else if (a_drawer)
			a_drawer.set_loc(get_turf(src))

		#ifdef XMAS
		if(src.z == Z_LEVEL_STATION && current_state <= GAME_STATE_PREGAME)
			xmasify()
		#endif

		SPAWN(0)
			if (src.auto && src.icon_state == "0") // if someone's set up a special icon state don't mess with it
				src.set_up()
				SPAWN(0)
					for (var/obj/table/T in orange(1,src))
						if (T.auto)
							T.set_up()

		var/bonus = 0
		for (var/obj/O in loc)
			if (isitem(O))
				bonus += 4
			if (istype(O, /obj/table) && O != src)
				return
			if (istype(O, /obj/rack))
				return
		var/area/Ar = get_area(src)
		if (Ar)
			Ar.sims_score = min(Ar.sims_score + bonus, 100)

	proc/xmasify()
		var/in_cafeteria = istype(get_area(src), /area/station/crew_quarters/cafeteria)
		if(in_cafeteria && fixed_random(src.x / world.maxx, src.y / world.maxy) <= 0.2)
			var/obj/item/reagent_containers/food/drinks/eggnog/nog = new(src.loc)
			nog.layer += 0.1
		if(fixed_random(src.x / world.maxx, src.y / world.maxy) >= (in_cafeteria ? 0.6 : 0.9))
			var/obj/item/a_gift/festive/gift = new(src.loc)
			gift.layer += 0.1

	proc/set_up()
		var/connections = get_connected_directions_bitflag(get_typeinfo().smooth_list, cross_areas = TRUE, connect_diagonal = 1)
		var/cardinals = connections % 16
		icon_state = num2text(cardinals)
		var/ordinals = connectdirs_to_byonddirs(connections)

		if((NORTHEAST & ordinals) == NORTHEAST)
			if (!src.working_image)
				src.working_image = image(src.icon, "NE")
			else
				working_image.icon_state = "NE"
			src.UpdateOverlays(working_image, "NEcorner")
		else
			src.UpdateOverlays(null, "NEcorner")
		if((SOUTHEAST & ordinals) == SOUTHEAST)
			if (!src.working_image)
				src.working_image = image(src.icon, "SE")
			else
				working_image.icon_state = "SE"
			src.UpdateOverlays(working_image, "SEcorner")
		else
			src.UpdateOverlays(null, "SEcorner")
		if((SOUTHWEST & ordinals) == SOUTHWEST)
			if (!src.working_image)
				src.working_image = image(src.icon, "SW")
			else
				working_image.icon_state = "SW"
			src.UpdateOverlays(working_image, "SWcorner")
		else
			src.UpdateOverlays(null, "SWcorner")

		if((NORTHWEST & ordinals) == NORTHWEST)
			if (!src.working_image)
				src.working_image = image(src.icon, "NW")
			else
				working_image.icon_state = "NW"
			src.UpdateOverlays(working_image, "NWcorner")
		else
			src.UpdateOverlays(null, "NWcorner")

	proc/deconstruct() //feel free to burn me alive because im stupid and couldnt figure out how to properly do it- Ze // im helping - haine
		var/obj/item/furniture_parts/P
		if (ispath(src.parts_type))
			P = new src.parts_type(src.loc)
		else
			P = new (src.loc)
		if (src.desk_drawer) // this shouldn't happen but I wanna be careful
			P.contained_storage = src.desk_drawer
			src.desk_drawer.set_loc(P)
			src.desk_drawer = null
		if (P && src.material)
			P.setMaterial(src.material)
		var/oldloc = src.loc
		qdel(src)
		for (var/obj/table/T in orange(1,oldloc))
			if (T.auto)
				T.set_up()

	/// Slam a dude on a table (harmfully)
	proc/harm_slam(mob/user, mob/victim)
		if (!victim.hasStatus("weakened"))
			victim.changeStatus("weakened", 3 SECONDS)
			victim.force_laydown_standup()
		src.visible_message("<span class='alert'><b>[user] slams [victim] onto \the [src]!</b></span>")
		playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
		if (src.material)
			src.material.triggerOnAttacked(src, user, victim, src)


	/// Slam a dude on the table (gently, with great care)
	proc/gentle_slam(mob/user, mob/victim)
		if (!victim.hasStatus("weakened"))
			victim.changeStatus("weakened", 2 SECONDS)
			victim.force_laydown_standup()
		src.visible_message("<span class='alert'>[user] puts [victim] on \the [src].</span>")


	custom_suicide = 1
	suicide(var/mob/user as mob) //if this is TOO ridiculous just remove it idc
		if (!src.user_can_suicide(user))
			return 0
		var/hisher = his_or_her(user)
		user.visible_message("<span class='alert'><b>[user] contorts [him_or_her(user)]self so that [hisher] head is underneath one of [src]'s legs and [hisher] heels are resting on top of it, then raises [hisher] feet and slams them back down over and over again!</b></span>")
		user.TakeDamage("head", 175, 0)
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	ex_act(severity)
		switch (severity)
			if (1)
				qdel(src)
				return
			if (2)
				if (prob(50))
					qdel(src)
					return
				else
					src.deconstruct()
					return
			if (3)
				if (prob(25))
					src.deconstruct()
					return
			else
				return
		return

	disposing()
		var/turf/OL = get_turf(src)
		if (src.desk_drawer && length(src.desk_drawer.contents))
			for (var/atom/movable/A in src.desk_drawer)
				A.set_loc(OL)
			var/obj/O = src.desk_drawer
			src.desk_drawer = null
			qdel(O)

		if (!OL)
			return
		if (!(locate(/obj/table) in OL) && !(locate(/obj/rack) in OL))
			var/area/Ar = OL.loc
			for (var/obj/item/I in OL)
				Ar.sims_score -= 4
			Ar.sims_score = max(Ar.sims_score, 0)
		..()

	blob_act(var/power)
		if (prob(power * 2.5))
			deconstruct()

	meteorhit()
		deconstruct()

	attackby(obj/item/W, mob/user, params)
		if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!G.affecting || G.affecting.buckled)
				return
			if (G.state == GRAB_PASSIVE)
				boutput(user, "<span class='alert'>You need a tighter grip!</span>")
				return
			var/mob/grabbed = G.affecting

			var/remove_tablepass = HAS_FLAG(grabbed.flags, TABLEPASS) ? FALSE : TRUE //this sucks and should be a mob property. love
			grabbed.flags |= TABLEPASS
			step(grabbed, get_dir(grabbed, src))
			if (remove_tablepass) REMOVE_FLAG(grabbed.flags, TABLEPASS)

			if (user.a_intent == "harm")
				src.harm_slam(user, grabbed)
				logTheThing(LOG_COMBAT, user, "slams [constructTarget(grabbed,"combat")] onto a table at [log_loc(grabbed)]")
			else
				src.gentle_slam(user, grabbed)
				logTheThing(LOG_STATION, user, "puts [constructTarget(grabbed,"combat")] onto a table at [log_loc(grabbed)]")
			qdel(W)
			return

		else if (istype(W, /obj/item/plank))
			if (status == 2)
				if (istype(src, /obj/table/reinforced/bar)) //why must you be so confusing
					boutput(user, "<span class='notice'>You can't add more than one finish, that's just illogical!</span>")
					return
				else if (istype(src, /obj/table/reinforced/auto))
					boutput(user, "<span class='notice'>Now adding a faux wood finish to \the [src]</span>") //mwah
					playsound(src.loc, 'sound/items/zipper.ogg', 50, 1)
					if(do_after(user,50))
						var/obj/table/L = new /obj/table/reinforced/bar/auto(src.loc)
						L.layer = src.layer - 0.01
						qdel(W)
						qdel(src)
						boutput(user, "<span class='notice'>You have added a faux wood finish to \the [src]</span>")
					return
				else
					boutput(user, "<span class='notice'>\The [src] is too weak to be modified!</span>")
			else
				boutput(user, "<span class='notice'>\The [src] is too weak to be modified!</span>")

		else if (istype(W, /obj/item/paint_can))
			return

		else if (isscrewingtool(W))
			if (istype(src.desk_drawer) && src.desk_drawer.locked)
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_LOCKPICK), user)
				return
			else if (src.auto)
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_ADJUST), user)
				return

		else if (iswrenchingtool(W) && !src.status) // shouldn't have status unless it's reinforced, maybe? hopefully?
			if (istype(src, /obj/table/folding))
				actions.start(new /datum/action/bar/icon/fold_folding_table(src, W), user)
			else
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_DISASSEMBLE), user)
			return

		else if (istype(W, /obj/item/reagent_containers/food/drinks/bottle) && user.a_intent == "harm")
			var/obj/item/reagent_containers/food/drinks/bottle/B = W
			B.smash_on_thing(user, src)
			return

		else if (istype(W, /obj/item/device/key/filing_cabinet) && src.desk_drawer)
			src.desk_drawer.Attackby(W, user)
			return

		else if (istype(W, /obj/item/cloth/towel))
			user.visible_message("<span class='notice'>[user] wipes down [src] with [W].</span>")

		else if (istype(W) && src.place_on(W, user, params))
			return

		else
			return ..()

	attack_hand(mob/user)
		if (user.is_hulk() && !hulk_immune)
			user.visible_message("<span class='alert'>[user] destroys the table!</span>")
			if (prob(40))
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
			logTheThing(LOG_COMBAT, user, "uses hulk to smash a table at [log_loc(src)].")
			deconstruct()
			return

		if (src.has_storage && src.desk_drawer)
			src.mouse_drop(user, src.loc, user.loc)

		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.w_uniform, /obj/item/clothing/under/misc/lawyer))
				slaps += 1
				src.visible_message("<span class='alert'><b>[H] slams their palms against [src]!</b></span>")
				if (slaps > 10 && prob(1)) //owned
					if (H.hand && H.limbs && H.limbs.l_arm)
						H.limbs.l_arm.sever()
					if (!H.hand && H.limbs && H.limbs.r_arm)
						H.limbs.r_arm.sever()

				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
				if (src.material)
					src.material.triggerOnAttacked(src, user, user, src)
				for (var/mob/N in AIviewers(user, null))
					if (N.client)
						shake_camera(N, 4, 8, 0.5)
			if(ismonkey(H))
				actions.start(new /datum/action/bar/icon/railing_jump/table_jump(user, src), user)
		return

	Cross(atom/movable/mover)
		if (!src.density || (mover?.flags & TABLEPASS || istype(mover, /obj/newmeteor)))
			return TRUE
		var/obj/table = locate(/obj/table) in mover?.loc
		if (table && table.density)
			return TRUE
		return FALSE

	MouseDrop_T(atom/O, mob/user as mob)
		if (!in_interact_range(user, src) || !in_interact_range(user, O) || user.restrained() || user.getStatusDuration("paralysis") || user.sleeping || user.stat || user.lying)
			return

		if (ismob(O) && O == user)
			boutput(user, "<span class='alert'>This table looks way too intimidating for you to scale on your own! You'll need a partner to help you over.</span>")
			return

		if (!isitem(O))
			return

		var/obj/item/I = O
		if(I.equipped_in_slot && I.cant_self_remove)
			return
		if(istype(O.loc, /obj/item/storage))
			var/obj/item/storage/storage = O.loc
			I.set_loc(get_turf(O))
			storage.hud.remove_item(O)
		if (istype(I,/obj/item/satchel))
			var/obj/item/satchel/S = I
			if (S.contents.len < 1)
				boutput(user, "<span class='alert'>There's nothing in [S]!</span>")
			else
				user.visible_message("<span class='notice'>[user] dumps out [S]'s contents onto [src]!</span>")
				for (var/obj/item/thing in S.contents)
					thing.set_loc(src.loc)
				S.desc = "A leather bag. It holds 0/[S.maxitems] [S.itemstring]."
				S.UpdateIcon()
				return
		if (isrobot(user) || user.equipped() != I || (I.cant_drop || I.cant_self_remove))
			return
		user.drop_item()
		if (I.loc != src.loc)
			step(I, get_dir(I, src))
		return

	mouse_drop(atom/over_object, src_location, over_location)
		if (usr && usr == over_object && src.desk_drawer)
			return src.desk_drawer.MouseDrop(over_object, src_location, over_location)
		..()

	Bumped(atom/AM)
		..()
		if(!ismonkey(AM))
			return
		var/mob/living/carbon/human/M = AM
		if(!isalive(M))
			return
		actions.start(new /datum/action/bar/icon/railing_jump/table_jump(M, src), M)

//Replacement for monkies walking through tables: They now parkour over them.
//Note: Max count of tables traversable is 2 more than the iteration limit
/datum/action/bar/icon/railing_jump/table_jump
	id = "table_jump"
	var/const/throw_range = 7
	var/const/iteration_limit = 5
	resumable = TRUE

	getLandingLoc()
		var/iteration = 0
		var/dir = get_dir(ownerMob, the_railing)
		var/turf/target = get_step(the_railing, dir)
		var/obj/table/maybe_table = locate(/obj/table) in target
		while(maybe_table && iteration < iteration_limit)
			iteration++
			target = get_step(target, dir)
			maybe_table = locate(/obj/table) in target
			duration += 1 SECOND
		return target

	do_bump()
		return FALSE // no bunp

	proc/unset_tablepass_callback(datum/thrown_thing/thr)
		thr.thing.flags &= ~TABLEPASS

	sendOwner()
		var/const/throw_speed = 0.5
		var/datum/thrown_thing/thr = ownerMob.throw_at(jump_target, throw_range, throw_speed)
		if(isnull(thr))
			return
		if(!(ownerMob.flags & TABLEPASS))
			ownerMob.flags |= TABLEPASS
			thr.end_throw_callback = .proc/unset_tablepass_callback
		for(var/O in AIviewers(ownerMob))
			var/mob/M = O //inherently typed list
			var/the_text = "[ownerMob] jumps over [the_railing]."
			if (is_athletic_jump) // athletic jumps are more athletic!!
				the_text = "[ownerMob] swooces right over [the_railing]!"
			M.show_text("[the_text]", "red")

/* ======================================== */
/* ---------------------------------------- */
/* ======================================== */

/obj/table/auto
	auto = 1

/obj/table/auto/desk // this type is special because it needs to connect with the default tables, so it's like the only thing that's a child of an /auto flavor of table
	name = "desk"
	desc = "A desk with a little drawer to store things in!"
	icon = 'icons/obj/furniture/table_desk.dmi'
	parts_type = /obj/item/furniture_parts/table/desk
	has_storage = 1

TYPEINFO(/obj/table/round)
TYPEINFO_NEW(/obj/table/round)
	. = ..()
	smooth_list = typecacheof(/obj/table/round/auto)
/obj/table/round
	icon = 'icons/obj/furniture/table_round.dmi'
	parts_type = /obj/item/furniture_parts/table/round

	auto
		auto = 1

TYPEINFO(/obj/table/wood)
TYPEINFO_NEW(/obj/table/wood)
	. = ..()
	smooth_list = typecacheof(/obj/table/wood/auto)
/obj/table/wood
	name = "wooden table"
	desc = "A table made from solid oak, which is quite rare in space."
	icon = 'icons/obj/furniture/table_wood.dmi'
	parts_type = /obj/item/furniture_parts/table/wood

	auto
		auto = 1

/obj/table/wood/auto/desk
	name = "wooden desk"
	desc = "A desk made of wood with a little drawer to store things in!"
	icon = 'icons/obj/furniture/table_wood_desk.dmi'
	parts_type = /obj/item/furniture_parts/table/wood/desk
	has_storage = 1

TYPEINFO(/obj/table/wood/round)
TYPEINFO_NEW(/obj/table/wood/round)
	. = ..()
	smooth_list = typecacheof(/obj/table/wood/round/auto)
/obj/table/wood/round
	icon = 'icons/obj/furniture/table_wood_round.dmi'
	parts_type = /obj/item/furniture_parts/table/wood/round

	auto
		auto = 1

TYPEINFO(/obj/table/regal)
TYPEINFO_NEW(/obj/table/regal)
	. = ..()
	smooth_list = typecacheof(/obj/table/regal/auto)
/obj/table/regal
	name = "regal table"
	desc = "Fancy."
	icon = 'icons/obj/furniture/table_regal.dmi'
	parts_type = /obj/item/furniture_parts/table/regal

	auto
		auto = 1

TYPEINFO(/obj/table/clothred)
TYPEINFO_NEW(/obj/table/clothred)
	. = ..()
	smooth_list = typecacheof(/obj/table/clothred/auto)
/obj/table/clothred
	name = "red event table"
	desc = "A regular table in disguise."
	icon = 'icons/obj/furniture/table_clothred.dmi'
	parts_type = /obj/item/furniture_parts/table/clothred

	auto
		auto = 1

TYPEINFO(/obj/table/neon)
TYPEINFO_NEW(/obj/table/neon)
	. = ..()
	smooth_list = typecacheof(/obj/table/neon/auto)
/obj/table/neon
	name = "neon table"
	desc = "It's almost painfully bright."
	icon = 'icons/obj/furniture/table_neon.dmi'
	parts_type = /obj/item/furniture_parts/table/neon

	auto
		auto = 1

TYPEINFO(/obj/table/scrap)
TYPEINFO_NEW(/obj/table/scrap)
	. = ..()
	smooth_list = typecacheof(/obj/table/scrap/auto)
/obj/table/scrap
	name = "scrap table"
	desc = "It's literally made of garbage."
	icon = 'icons/obj/furniture/table_scrap.dmi'
	parts_type = /obj/item/furniture_parts/table/scrap

	auto
		auto = 1

/obj/table/folding
	name = "folding table"
	desc = "A table with a faux wood top designed for quick assembly and toolless disassembly."
	icon = 'icons/obj/furniture/table_folding.dmi'
	parts_type = /obj/item/furniture_parts/table/folding

	attack_hand(mob/user)
		if (user.is_hulk())
			user.visible_message("<span class='alert'>[user] collapses the [src] in one slam!</span>")
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
			deconstruct()
		else if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.w_uniform, /obj/item/clothing/under/misc/lawyer))
				slaps += 1
				src.visible_message("<span class='alert'><b>[H] slams their palms against [src]!</b></span>")
				if (slaps > 2 && prob(50))
					src.visible_message("<span class='alert'><b>The [src] collapses!</b></span>")
					deconstruct()
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
				for (var/mob/N in AIviewers(user, null))
					if (N.client)
						shake_camera(N, 4, 8, 0.5)
			else
				actions.start(new /datum/action/bar/icon/fold_folding_table(src, null), user)
		return

	harm_slam(mob/user, mob/victim)
		if (!victim.hasStatus("weakened"))
			victim.changeStatus("weakened", 4 SECONDS)
			victim.force_laydown_standup()
		src.visible_message("<span class='alert'><b>[user] slams [victim] onto \the [src], collapsing it instantly!</b></span>")
		playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
		deconstruct()

TYPEINFO(/obj/table/syndicate)
TYPEINFO_NEW(/obj/table/syndicate)
	. = ..()
	smooth_list = typecacheof(/obj/table/syndicate/auto)
/obj/table/syndicate
	name = "crimson glass table"
	desc = "An industrial grade table with a crimson glass panel on the top. The glass looks extremely sturdy."
	icon = 'icons/obj/furniture/table_syndicate.dmi'
	parts_type = /obj/item/furniture_parts/table/syndicate

	New()
		..()
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

	auto
		auto = TRUE

TYPEINFO(/obj/table/nanotrasen)
TYPEINFO_NEW(/obj/table/nanotrasen)
	. = ..()
	smooth_list = typecacheof(/obj/table/nanotrasen/auto)
/obj/table/nanotrasen
	name = "azure glass table"
	desc = "An industrial grade table with an azure glass panel on the top. The glass looks extremely sturdy."
	icon = 'icons/obj/furniture/table_nanotrasen.dmi'
	parts_type = /obj/item/furniture_parts/table/nanotrasen

	auto
		auto = TRUE
/* ======================================== */
/* ---------------------------------------- */
/* ======================================== */

/obj/table/endtable_classic
	name = "vintage endtable"
	desc = "A vintage-styled wooden endtable, complete with decorative doily."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "endtable-classic"
	parts_type = /obj/item/furniture_parts/endtable_classic

/obj/table/endtable_gothic
	name = "gothic endtable"
	desc = "A gothic-styled wooden endtable, complete with decorative doily."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "endtable-gothic"
	parts_type = /obj/item/furniture_parts/endtable_gothic

/obj/table/podium_wood
	name = "wooden podium"
	desc = "A wooden podium. Looks official."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "podiumwood"
	parts_type = /obj/item/furniture_parts/podium_wood

/obj/table/podium_wood/nanotrasen
	name = "wooden podium"
	desc = "A wooden podium. Looks official. Comes with a NT-themed banner attached to the front."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "podiumwood-nt"
	parts_type = /obj/item/furniture_parts/podium_wood/nt

/obj/table/podium_wood/syndicate
	name = "wooden podium"
	desc = "A wooden podium. Looks official. Comes with a Syndicate-themed banner attached to the front."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "podiumwood-snd"
	parts_type = /obj/item/furniture_parts/podium_wood/syndie

/obj/table/podium_white
	name = "white podium"
	desc = "A white podium. Looks official."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "podiumwhite"
	parts_type = /obj/item/furniture_parts/podium_white

/obj/table/podium_white/nanotrasen
	name = "white podium"
	desc = "A white podium. Looks official. Comes with a NT-themed banner attached to the front."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "podiumwhite-nt"
	parts_type = /obj/item/furniture_parts/podium_white/nt

/obj/table/podium_white/syndicate
	name = "white podium"
	desc = "A white podium. Looks official. Comes with a Syndicate-themed banner attached to the front."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "podiumwhite-snd"
	parts_type = /obj/item/furniture_parts/podium_white/syndie

/* ======================================== */
/* ---------------------------------------- */
/* ======================================== */

TYPEINFO(/obj/table/reinforced)
TYPEINFO_NEW(/obj/table/reinforced)
	. = ..()
	smooth_list = typecacheof(/obj/table/reinforced/auto)
/obj/table/reinforced
	name = "reinforced table"
	desc = "A table made from reinforced metal, it is quite strong and it requires welding and wrenching to disassemble it."
	icon = 'icons/obj/furniture/table_reinforced.dmi'
	status = 2
	parts_type = /obj/item/furniture_parts/table/reinforced

	auto
		auto = 1

	attackby(obj/item/W, mob/user)
		if (isweldingtool(W) && W:try_weld(user,1))
			if (src.status == 2)
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_WEAKEN), user)
				return
			else if (src.status == 1)
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_STRENGTHEN), user)
				return
			else
				return ..()
		else if (iswrenchingtool(W))
			if (src.status == 1)
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_DISASSEMBLE), user)
				return
			else
				boutput(user, "<span class='alert'>You need to weaken the [src.name] with a welding tool before you can disassemble it!</span>")
				return
		else
			return ..()

TYPEINFO(/obj/table/reinforced/bar)
TYPEINFO_NEW(/obj/table/reinforced/bar)
	. = ..()
	smooth_list = typecacheof(/obj/table/reinforced/bar/auto)
/obj/table/reinforced/bar
	name = "bar table"
	desc = "A reinforced table with a faux wooden finish to make you feel at ease."
	icon = 'icons/obj/furniture/table_bar.dmi'
	parts_type = /obj/item/furniture_parts/table/reinforced/bar

	auto
		auto = 1

TYPEINFO(/obj/table/reinforced/roulette)
TYPEINFO_NEW(/obj/table/reinforced/roulette)
	. = ..()
	smooth_list = typecacheof()
/obj/table/reinforced/roulette
	name = "roulette table"
	desc = "A reinforced table with different betting markings on it."
	icon = 'icons/obj/gambling.dmi'
	icon_state = "roulette_e"
	parts_type = /obj/item/furniture_parts/table/reinforced/roulette

TYPEINFO(/obj/table/reinforced/chemistry)
TYPEINFO_NEW(/obj/table/reinforced/chemistry)
	. = ..()
	smooth_list = typecacheof(/obj/table/reinforced/chemistry/auto)
/obj/table/reinforced/chemistry
	name = "lab counter"
	desc = "A labratory countertop made from a paper composite, which is very heat resistant."
	icon = 'icons/obj/furniture/table_chemistry.dmi'
	parts_type = /obj/item/furniture_parts/table/reinforced/chemistry
	has_storage = 1

	auto
		auto = 1

/obj/table/reinforced/chemistry/beakers //starts with 7 :B:eakers inside it, wow!!
	var/list/stuff = list()
	name = "beaker storage"

	New()
		..()
		desc += " This one holds beakers in it! Wow!!"
		for (var/B=0, B<=7, B++)
			new /obj/item/reagent_containers/glass/beaker(src.desk_drawer)

TYPEINFO(/obj/table/reinforced/industrial)
TYPEINFO_NEW(/obj/table/reinforced/industrial)
	. = ..()
	smooth_list = typecacheof(/obj/table/reinforced/industrial/auto)
/obj/table/reinforced/industrial
	name = "industrial table"
	desc = "An industrial table that looks like it has been made out of a scaffolding."
	icon = 'icons/obj/furniture/table_industrial.dmi'
	parts_type = /obj/item/furniture_parts/table/reinforced/industrial

	auto
		auto = 1

/* ======================================== */
/* ---------------------------------------- */
/* ======================================== */

#define GLASS_INTACT 0
#define GLASS_BROKEN 1
#define GLASS_REFORMING 2

TYPEINFO(/obj/table/glass)
TYPEINFO_NEW(/obj/table/glass)
	. = ..()
	smooth_list = typecacheof(/obj/table/glass) // has to be the base type here or else regular glass tables won't connect to reinforced ones
/obj/table/glass
	name = "glass table"
	desc = "A table made of glass. It looks like it might shatter if you set something down on it too hard."
	icon = 'icons/obj/furniture/table_glass.dmi'
	mat_appearances_to_ignore = list("glass")
	parts_type = /obj/item/furniture_parts/table/glass
	var/glass_broken = GLASS_INTACT
	var/reinforced = 0
	var/default_material = "glass"

	auto
		auto = 1

	frame
		name = "glass table frame"
		parts_type = /obj/item/furniture_parts/table/glass/frame
		glass_broken = GLASS_BROKEN

		auto
			auto = 1

	reinforced
		name = "reinforced glass table"
		desc = "A table made of reinforced glass. It looks kinda sturdy, but I wouldn't go slamming things onto it."
		parts_type = /obj/item/furniture_parts/table/glass/reinforced
		reinforced = 1

		auto
			auto = 1

	New()
		..()
		if (!src.material && default_material)
			src.setMaterial(getMaterial(default_material), copy = FALSE)

	UpdateName()
		if (src.glass_broken)
			src.name = "glass table frame[name_suffix(null, 1)]"
		else
			src.name = name_prefix(null, 1)
			if (length(src.name)) // name_prefix() returned something so we have some kinda material, probably
				src.name = "[src.reinforced ? "reinforced " : null][src.name]table[name_suffix(null, 1)]"
			else
				src.name = "[initial(src.name)][name_suffix(null, 1)]"

	proc/smash()
		if (src.glass_broken)
			return
		src.visible_message("<span class='alert'>\The [src] shatters!</span>")
		playsound(src, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
		if (src.material?.mat_id in list("gnesis", "gnesisglass"))
			gnesis_smash()
		else
			for (var/i=0, i<2, i++)
				var/obj/item/raw_material/shard/glass/G = new /obj/item/raw_material/shard/glass
				G.set_loc(src.loc)
				if (src.material)
					G.setMaterial(src.material)
			src.glass_broken = GLASS_BROKEN
			src.removeMaterial()
			src.parts_type = /obj/item/furniture_parts/table/glass/frame
			src.set_density(0)
			src.set_up()

	proc/gnesis_smash()
		var/color = "#fff"
		if(src.color)
			color = src.color
		src.glass_broken = GLASS_BROKEN
		src.set_density(0)
		src.set_up()
		SPAWN(rand(2 SECONDS, 3 SECONDS))
			if(src.glass_broken == GLASS_BROKEN)
				src.glass_broken = GLASS_REFORMING
				src.set_up()
				src.set_density(initial(src.density))
				src.visible_message("<span class='alert'>\The [src] starts to reform!</span>")

				var/filter
				var/size=rand()*2.5+4
				var/regrow_duration = rand(8 SECONDS, 12 SECONDS)
				var/loops = 5
				var/duration= round(regrow_duration / loops, 2)

				// Ripple inwards
				add_filter("gnesis regrowth", 1, ripple_filter(x=0, y=0, size=size, repeat=rand()*2.5+3, radius=0, flags=WAVE_BOUNDED))
				filter = get_filter("gnesis regrowth")
				animate(filter, size=0, time=0, loop=loops, radius=12, flags=ANIMATION_PARALLEL)
				animate(size=size, radius=0, time=duration)

				// Flash
				animate(src, color = "#2ca", time = duration/2, loop = loops, easing = SINE_EASING, flags=ANIMATION_PARALLEL)
				animate(color = "#298", time = duration/2, loop = loops, easing = SINE_EASING)
				sleep(regrow_duration)

				// Remove filter and reset color
				remove_filter("gnesis regrowth")
				animate(src, loop=0, color=color, time=duration/2)
				src.visible_message("<span class='alert'>\The [src] fully reforms!</span>")
				src.glass_broken = GLASS_INTACT

	proc/repair()
		src.glass_broken = GLASS_INTACT
		src.UpdateName()
		src.parts_type = src.reinforced ? /obj/item/furniture_parts/table/glass/reinforced : /obj/item/furniture_parts/table/glass
		src.set_density(initial(src.density))
		src.set_up()

	ex_act(severity)
		if (src.glass_broken)
			return ..()
		if (severity == 2)
			if (prob(25))
				src.smash()
				return
			else
				return ..()
		else if (severity == 3.0)
			if (prob(25))
				src.smash()
				return
			else
				return ..()
		else
			return ..()

	meteorhit()
		if (prob(25))
			src.smash()
		else
			return ..()

	attack_hand(mob/user)
		if (src.glass_broken)
			return ..()
		..()
		if (!src) // vOv
			return
		var/smashprob = 1
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.w_uniform, /obj/item/clothing/under/misc/lawyer))
				..()
				if (!src || !src.loc)
					return
				smashprob += 10
				if (user.bioHolder.HasEffect("clumsy"))
					smashprob += 25
		if (src.reinforced)
			smashprob = round(smashprob / 2, 1)
		if (prob(smashprob))
			src.smash()

	attackby(obj/item/W, mob/user, params)
		if (src.glass_broken == GLASS_BROKEN)
			if (istype(W, /obj/item/sheet))
				var/obj/item/sheet/S = W
				if (!S.material || !(S.material.material_flags & MATERIAL_CRYSTAL))
					boutput(user, "<span class='alert'>You have to use glass or another crystalline material to repair [src]!</span>")
				else if (S.change_stack_amount(-1))
					boutput(user, "<span class='notice'>You add glass to [src]!</span>")
					if (S.reinforcement)
						src.reinforced = 1
					if (S.material)
						src.setMaterial(S.material)
					src.repair()
				return
			else
				return ..()

		var/smashprob = 1
		if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!G.affecting || G.affecting.buckled)
				return
			if (G.state == GRAB_PASSIVE)
				boutput(user, "<span class='alert'>You need a tighter grip!</span>")
				return
			var/mob/grabbed = G.affecting
			// duplicated as hell but i'm leaving it cleaner than I found it
			var/remove_tablepass = HAS_FLAG(grabbed.flags, TABLEPASS) ? FALSE : TRUE //this sucks and should be a mob property. love
			grabbed.flags |= TABLEPASS
			step(grabbed, get_dir(grabbed, src))
			if (remove_tablepass) REMOVE_FLAG(grabbed.flags, TABLEPASS)

			if (user.a_intent == "harm")
				logTheThing(LOG_COMBAT, user, "slams [constructTarget(grabbed,"combat")] onto a glass table")
				src.harm_slam(user, grabbed)
			else
				logTheThing(LOG_STATION, user, "puts [constructTarget(grabbed,"combat")] onto a glass table")
				src.gentle_slam(user, grabbed)

		else if (istype(W, /obj/item/plank) || istool(W, TOOL_SCREWING | TOOL_WRENCHING) || (istype(W, /obj/item/reagent_containers/food/drinks/bottle) && user.a_intent == "harm"))
			return ..()

		else if (istype(W, /obj/item/reagent_containers/food/drinks/bottle) && user.a_intent == "harm")
			var/obj/item/reagent_containers/food/drinks/bottle/B = W
			B.smash_on_thing(user, src)
			SPAWN(0)
				if (B)
					smashprob += 15
				else
					return

		else if(istype(W, /obj/item/paint_can))
			return

		else if (istype(W)) // determine smash chance via item size and user clumsiness  :v
			if (user.bioHolder.HasEffect("clumsy"))
				smashprob += 25
			smashprob += (W.w_class / 6) * 10
			DEBUG_MESSAGE("[src] smashprob += ([W.w_class] / 6) * 10 (result [(W.w_class / 6) * 10])")

			if (src.reinforced)
				smashprob = round(smashprob / 2, 1)

			if (src.place_on(W, user, params))
				playsound(src, 'sound/impact_sounds/Crystal_Hit_1.ogg', 100, 1)
			else if (W && user.a_intent != "help")
				DEBUG_MESSAGE("[src] smashprob = ([smashprob] * 1.5) (result [(smashprob * 1.5)])")
				smashprob = (smashprob * 1.5)

			if (prob(smashprob))
				if (istype(W) && !isrobot(user))
					src.visible_message("<span class='alert'>[user] places [W] down on [src] too hard!</span>")
				src.smash()
				if (istype(W) && !isrobot(user))
					src.visible_message("\The [W] falls to the floor.")
			return

		else
			return ..()

	harm_slam(mob/user, mob/victim)
		victim.set_loc(src.loc)
		victim.changeStatus("weakened", 4 SECONDS)
		src.visible_message("<span class='alert'><b>[user] slams [victim] onto \the [src]!</b></span>")
		playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
		if (src.material)
			src.material.triggerOnAttacked(src, user, victim, src)
		if ((prob(src.reinforced ? 60 : 80)) || (user.bioHolder.HasEffect("clumsy") && (!src.reinforced || prob(90))))
			src.smash()
			random_brute_damage(victim, rand(20,40),1)
			take_bleeding_damage(victim, user, rand(20,40))
			if (prob(30) || user.bioHolder.HasEffect("clumsy"))
				boutput(user, "<span class='alert'>You cut yourself on \the [src] as [victim] slams through the glass!</span>")
				random_brute_damage(user, rand(10,30),1)
				take_bleeding_damage(user, user, rand(10,30))

	hitby(atom/movable/AM, datum/thrown_thing/thr)
		..()
		if (ismob(AM))
			var/mob/M = AM
			if ((prob(src.reinforced ? 60 : 80)))
				logTheThing(LOG_COMBAT, thr.user, "throws [constructTarget(M,"combat")] into a glass table, breaking it")
				src.visible_message("<span class='alert'>[M] smashes through [src]!</span>")
				playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
				src.smash()
				if (M.loc != src.loc)
					step(M, get_dir(M, src))
				if (ishuman(M))
					random_brute_damage(M, rand(30,50),1)
					take_bleeding_damage(M, M, rand(20,40))
		return

	place_on(obj/item/W as obj, mob/user as mob, params)
		..()
		if (. == 1) // successfully put thing on table, make a noise because we are a fancy special glass table
			playsound(src, 'sound/impact_sounds/Crystal_Hit_1.ogg', 100, 1)
			return 1

	set_up()

		// todo: fix this gross patchwork shit so it's not just one type
		var/typeinfo/obj/table/typinfo = get_typeinfo()
		var/smoothlist = typinfo.smooth_list
		if (!length(smoothlist))
			return
		var/auto_type = smoothlist[1] //so hacky

		var/dirs = 0
		for (var/direction in cardinal)
			var/turf/T = get_step(src, direction)
			if (locate(auto_type) in T)
				dirs |= direction
		icon_state = num2text(dirs)

		if (src.glass_broken == GLASS_BROKEN)
			src.UpdateOverlays(null, "tabletop")
			src.UpdateOverlays(null, "SWcorner")
			src.UpdateOverlays(null, "SEcorner")
			src.UpdateOverlays(null, "NEcorner")
			src.UpdateOverlays(null, "NWcorner")
			return

		// check it out a new piece of hacky nonsense
		var/R = src.reinforced ? "R" : null
		if (!src.working_image)
			src.working_image = image(src.icon, "[R]g[num2text(dirs)]")
		else
			src.working_image.icon_state = "[R]g[num2text(dirs)]"
		src.UpdateOverlays(working_image, "tabletop")

		var/obj/table/WT = locate(auto_type) in get_step(src, WEST)
		var/obj/table/ST = locate(auto_type) in get_step(src, SOUTH)
		var/obj/table/ET = locate(auto_type) in get_step(src, EAST)
		var/obj/table/NT = locate(auto_type) in get_step(src, NORTH)

		// west, south, and southwest
		if (WT && ST)
			var/obj/table/SWT = locate(auto_type) in get_step(src, SOUTHWEST)
			if (SWT)
				working_image.icon_state = "[R]gSWs"
				src.UpdateOverlays(working_image, "SWcorner")
			else
				working_image.icon_state = "[R]gSW"
				src.UpdateOverlays(working_image, "SWcorner")
		else
			src.UpdateOverlays(null, "SWcorner")

		// south, east, and southeast
		if (ST && ET)
			var/obj/table/SET = locate(auto_type) in get_step(src, SOUTHEAST)
			if (SET)
				working_image.icon_state = "[R]gSEs"
				src.UpdateOverlays(working_image, "SEcorner")
			else
				working_image.icon_state = "[R]gSE"
				src.UpdateOverlays(working_image, "SEcorner")
		else
			src.UpdateOverlays(null, "SEcorner")

		// north, east, and northeast
		if (NT && ET)
			var/obj/table/NET = locate(auto_type) in get_step(src, NORTHEAST)
			if (NET)
				working_image.icon_state = "[R]gNEs"
				src.UpdateOverlays(working_image, "NEcorner")
			else
				working_image.icon_state = "[R]gNE"
				src.UpdateOverlays(working_image, "NEcorner")
		else
			src.UpdateOverlays(null, "NEcorner")

		// north, west, and northwest
		if (NT && WT)
			var/obj/table/NWT = locate(auto_type) in get_step(src, NORTHWEST)
			if (NWT)
				working_image.icon_state = "[R]gNWs"
				src.UpdateOverlays(working_image, "NWcorner")
			else
				working_image.icon_state = "[R]gNW"
				src.UpdateOverlays(working_image, "NWcorner")
		else
			src.UpdateOverlays(null, "NWcorner")

#undef GLASS_INTACT
#undef GLASS_BROKEN
#undef GLASS_REFORMING

/* ======================================== */
/* ---------------------------------------- */
/* ======================================== */

/obj/table/virtual
	desc = "A simulated table. Fortunately the kind that's less of a pain in the ass to deal with."
	icon = 'icons/effects/VR.dmi'
	icon_state = "table"

/* ======================================== */
/* ---------------------------------------- */
/* ======================================== */

/datum/action/bar/icon/table_tool_interact
	id = "table_tool_interact"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 50
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/table/the_table
	var/obj/item/the_tool
	var/interaction = TABLE_DISASSEMBLE

	New(var/obj/table/tabl, var/obj/item/tool, var/interact, var/duration_i)
		..()
		if (tabl)
			the_table = tabl
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state
		if (interact)
			interaction = interact
		if (duration_i)
			duration = duration_i
		if (ishuman(owner) && interaction != TABLE_LOCKPICK)
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (the_table == null || the_tool == null || owner == null || BOUNDS_DIST(owner, the_table) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return
		else if (interaction == TABLE_DISASSEMBLE && the_table.desk_drawer)
			if (the_table.desk_drawer.locked)
				boutput(owner, "<span class='alert'>You can't disassemble [the_table] when its drawer is locked!</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
			else if (the_table.desk_drawer.contents.len)
				boutput(owner, "<span class='alert'>You can't disassemble [the_table] while its drawer has stuff in it!</span>")
				interrupt(INTERRUPT_ALWAYS)
				return
		else if (interaction == TABLE_LOCKPICK)
			if (!the_table.desk_drawer || !the_table.desk_drawer.locked)
				interrupt(INTERRUPT_ALWAYS)
				return
			else if (prob(8))
				owner.visible_message("<span class='alert'>[owner] messes up while picking [the_table]'s lock!</span>")
				playsound(the_table, 'sound/items/Screwdriver2.ogg', 50, 1)
				interrupt(INTERRUPT_ALWAYS)
				return

	onStart()
		..()
		var/verbing = "doing something to"
		switch (interaction)
			if (TABLE_DISASSEMBLE)
				verbing = "disassembling"
				playsound(the_table, 'sound/items/Ratchet.ogg', 50, 1)
			if (TABLE_WEAKEN)
				verbing = "weakening"
				playsound(the_table, 'sound/items/Welder.ogg', 50, 1)
			if (TABLE_STRENGTHEN)
				verbing = "strengthening"
				playsound(the_table, 'sound/items/Welder.ogg', 50, 1)
			if (TABLE_ADJUST)
				verbing = "adjusting the shape of"
				playsound(the_table, 'sound/items/Screwdriver.ogg', 50, 1)
			if (TABLE_LOCKPICK)
				verbing = "picking the lock on"
				playsound(the_table, 'sound/items/Screwdriver2.ogg', 50, 1)
		owner.visible_message("<span class='notice'>[owner] begins [verbing] [the_table].</span>")

	onEnd()
		..()
		var/verbens = "does something to"
		switch (interaction)
			if (TABLE_DISASSEMBLE)
				verbens = "disassembles"
				playsound(the_table, 'sound/items/Deconstruct.ogg', 50, 1)
				the_table.deconstruct()
			if (TABLE_WEAKEN)
				verbens = "weakens"
				the_table.status = 1
			if (TABLE_STRENGTHEN)
				verbens = "strengthens"
				the_table.status = 2
			if (TABLE_ADJUST)
				verbens = "adjusts the shape of"
				the_table.set_up()
			if (TABLE_LOCKPICK)
				verbens = "picks the lock on"
				if (the_table.desk_drawer)
					the_table.desk_drawer.locked = 0
				playsound(the_table, 'sound/items/Screwdriver2.ogg', 50, 1)
		owner.visible_message("<span class='notice'>[owner] [verbens] [the_table].</span>")

/datum/action/bar/icon/fold_folding_table
	id = "fold_folding_table"
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 15
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/table/the_table
	var/obj/item/the_tool

	New(var/obj/table/tabl, var/obj/item/tool)
		..()
		if (tabl)
			the_table = tabl
		if (tool)
			the_tool = tool
			icon = the_tool.icon
			icon_state = the_tool.icon_state

	onUpdate()
		..()
		if (the_table == null || owner == null || BOUNDS_DIST(owner, the_table) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (the_tool)
			playsound(the_table, 'sound/items/Ratchet.ogg', 50, 1)
		else
			playsound(the_table, 'sound/items/Screwdriver2.ogg', 50, 1)
		owner.visible_message("<span class='notice'>[owner] begins disassembling [the_table].</span>")

	onEnd()
		..()
		playsound(the_table, 'sound/items/Deconstruct.ogg', 50, 1)
		owner.visible_message("<span class='notice'>[owner] disassembles [the_table].</span>")
		the_table.deconstruct()
