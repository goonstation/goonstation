#define STATUS_WEAK 1
#define STATUS_STRONG 2

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
	anchored = ANCHORED
	flags = NOSPLASH
	event_handler_flags = USE_FLUID_ENTER
	layer = OBJ_LAYER-0.1
	stops_space_move = TRUE
	mat_changename = 1
	mechanics_interaction = MECHANICS_INTERACTION_SKIP_IF_FAIL
	material_amt = 0.2
	var/parts_type = /obj/item/furniture_parts/table
	default_material = null
	uses_default_material_appearance = FALSE
	var/auto = 0
	var/status = null //1=weak|welded, 2=strong|unwelded
	var/image/working_image = null
	var/slaps = 0
	var/hulk_immune = FALSE
	/// has a drawer storage
	var/has_drawer = FALSE
	/// list of contents to add to storage
	var/drawer_contents = null
	/// whether the storage can be accessed or not
	var/drawer_locked = FALSE
	/// id for key checks, keys with the same id can lock it
	var/lock_id = null
	HELP_MESSAGE_OVERRIDE({""})

	New(loc)
		..()
		START_TRACKING
		if (src.has_drawer)
			src.create_storage(/datum/storage/unholdable, spawn_contents = src.drawer_contents, slots = 13, max_wclass = W_CLASS_SMALL)

		#ifdef XMAS
		if(src.z == Z_LEVEL_STATION && current_state <= GAME_STATE_PREGAME)
			xmasify()
		#endif

		SPAWN(0)
			if (src.auto && src.materialless_icon_state() == "0") // if someone's set up a special icon state don't mess with it
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

	get_help_message(dist, mob/user)
		. = ..()
		. += "You can use a <b>wrench</b> on <span class='harm'>harm</span> intent to disassemble it. \
		You can also use a <b>screwdriver</b> on <span class='harm'>harm</span> intent to \
		[(src.has_drawer && src.drawer_locked) ? "pick the drawer's lock." : "adjust the shape of it."]"


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
		set_icon_state(num2text(cardinals))
		var/ordinals = connectdirs_to_byonddirs(connections)

		if((NORTHEAST & ordinals) == NORTHEAST)
			if (!src.working_image)
				src.working_image = image(src.icon, "NE")
			else
				working_image.icon_state = "NE"
			setMaterialAppearanceForImage(working_image)
			src.AddOverlays(working_image, "NEcorner")
		else
			src.ClearSpecificOverlays("NEcorner")
		if((SOUTHEAST & ordinals) == SOUTHEAST)
			if (!src.working_image)
				src.working_image = image(src.icon, "SE")
			else
				working_image.icon_state = "SE"
			setMaterialAppearanceForImage(working_image)
			src.AddOverlays(working_image, "SEcorner")
		else
			src.ClearSpecificOverlays("SEcorner")
		if((SOUTHWEST & ordinals) == SOUTHWEST)
			if (!src.working_image)
				src.working_image = image(src.icon, "SW")
			else
				working_image.icon_state = "SW"
			setMaterialAppearanceForImage(working_image)
			src.AddOverlays(working_image, "SWcorner")
		else
			src.ClearSpecificOverlays("SWcorner")

		if((NORTHWEST & ordinals) == NORTHWEST)
			if (!src.working_image)
				src.working_image = image(src.icon, "NW")
			else
				working_image.icon_state = "NW"
			setMaterialAppearanceForImage(working_image)
			src.AddOverlays(working_image, "NWcorner")
		else
			src.ClearSpecificOverlays("NWcorner")

	proc/deconstruct() //feel free to burn me alive because im stupid and couldnt figure out how to properly do it- Ze // im helping - haine
		var/obj/item/furniture_parts/P
		if (ispath(src.parts_type))
			P = new src.parts_type(src.loc)
		else
			P = new (src.loc)
		if (P && src.material)
			P.setMaterial(src.material)
		var/oldloc = src.loc
		qdel(src)
		for (var/obj/table/T in orange(1,oldloc))
			if (T.auto)
				T.set_up()

	/// Slam a dude on a table (harmfully)
	proc/harm_slam(mob/user, mob/victim)
		if (!victim.hasStatus("knockdown"))
			victim.changeStatus("knockdown", 3 SECONDS)
			victim.force_laydown_standup()
		src.visible_message(SPAN_ALERT("<b>[user] slams [victim] onto \the [src]!</b>"))
		playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, TRUE)
		src.material_trigger_when_attacked(victim, user, 1)


	/// Slam a dude on the table (gently, with great care)
	proc/gentle_slam(mob/user, mob/victim)
		if (!victim.hasStatus("knockdown"))
			victim.changeStatus("knockdown", 2 SECONDS)
			victim.force_laydown_standup()
		src.visible_message(SPAN_ALERT("[user] puts [victim] on \the [src]."))


	custom_suicide = 1
	suicide(var/mob/user as mob) //if this is TOO ridiculous just remove it idc
		if (!src.user_can_suicide(user))
			return 0
		var/hisher = his_or_her(user)
		user.visible_message(SPAN_ALERT("<b>[user] contorts [him_or_her(user)]self so that [hisher] head is underneath one of [src]'s legs and [hisher] heels are resting on top of it, then raises [hisher] feet and slams them back down over and over again!</b>"))
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
		if (src.has_drawer && src.storage.hud_shown(user))
			return ..()

		if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!G.affecting || G.affecting.buckled)
				return
			if (G.state == GRAB_PASSIVE)
				boutput(user, SPAN_ALERT("You need a tighter grip!"))
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

		else if (istype(W,/obj/item/sheet/wood))
			if (istype(src, /obj/table/reinforced/bar)) //why must you be so confusing
				return ..()
			if (status != STATUS_STRONG || !istype(src, /obj/table/reinforced/auto))
				boutput(user, SPAN_NOTICE("\The [src] is too weak to be modified!"))
				return
			if (W.amount < 5)
				boutput(user, SPAN_NOTICE("You need at least 5 planks to furnish the whole table."))
				return
			actions.start(new /datum/action/bar/icon/furnish_table(src,W), user)

		else if (istype(W, /obj/item/paint_can))
			return

		else if (isscrewingtool(W) && user.a_intent == INTENT_HARM)
			if (src.has_drawer && src.drawer_locked)
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_LOCKPICK), user)
				return
			else if (src.auto)
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_ADJUST), user)
				return

		else if (iswrenchingtool(W) && !src.status && user.a_intent == INTENT_HARM) // shouldn't have status unless it's reinforced, maybe? hopefully?
			if (istype(src, /obj/table/folding))
				actions.start(new /datum/action/bar/icon/fold_folding_table(src, W), user)
			else
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_DISASSEMBLE), user)
			return

		else if (istype(W, /obj/item/reagent_containers/food/drinks/bottle) && user.a_intent == "harm")
			var/obj/item/reagent_containers/food/drinks/bottle/B = W
			B.smash_on_thing(user, src)
			return

		else if (istype(W, /obj/item/device/key/filing_cabinet) && src.has_drawer)
			var/obj/item/device/key/K = W
			if (src.lock_id && src.lock_id == K.id)
				src.drawer_locked = !src.drawer_locked
				user.visible_message("[user] [!src.drawer_locked ? "un" : null]locks [src].")
				playsound(src, 'sound/items/Screwdriver2.ogg', 50, TRUE)
			else
				boutput(user, SPAN_ALERT("[K] doesn't seem to fit in [src]'s desk drawer lock."))
			return

		else if (istype(W, /obj/item/cloth/towel))
			user.visible_message(SPAN_NOTICE("[user] wipes down [src] with [W]."))

		else if (istype(W) && src.place_on(W, user, params))
			return
		// chance to smack satchels against a table when dumping stuff out of them, because that can be kinda funny
		else if (istype(W, /obj/item/satchel) && (user.get_brain_damage() <= 40 && rand(1, 10) < 10))
			return

		else
			return ..()

	attack_hand(mob/user)
		if (user.is_hulk() && !hulk_immune)
			user.visible_message(SPAN_ALERT("[user] destroys the table!"))
			if (prob(40))
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
			logTheThing(LOG_COMBAT, user, "uses hulk to smash a table at [log_loc(src)].")
			deconstruct()
			return

		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.w_uniform, /obj/item/clothing/under/misc/lawyer) && !H.equipped())
				slaps += 1
				src.visible_message(SPAN_ALERT("<b>[H] slams [his_or_her(H)] palms against [src]!</b>"))
				if (slaps > 10 && prob(1)) //owned
					if (H.hand && H.limbs && H.limbs.l_arm)
						H.limbs.l_arm.sever()
					if (!H.hand && H.limbs && H.limbs.r_arm)
						H.limbs.r_arm.sever()

				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
				src.material_trigger_when_attacked(user, user, 1)
				for (var/mob/N in AIviewers(user, null))
					if (N.client)
						shake_camera(N, 4, 8, 0.5)
				return
			if(ismonkey(H))
				actions.start(new /datum/action/bar/icon/railing_jump/table_jump(user, src), user)
				return

		if (src.has_drawer && src.drawer_locked)
			boutput(user, SPAN_ALERT("[src]'s desk drawer is locked!"))
			return

		return ..()

	Cross(atom/movable/mover)
		if (!src.density || (mover?.flags & TABLEPASS || istype(mover, /obj/newmeteor)))
			return TRUE
		var/obj/table = locate(/obj/table) in mover?.loc
		if (table && table.density)
			return TRUE
		return FALSE

	MouseDrop_T(atom/O, mob/user as mob, src_location, over_location, over_control, src_control, params)
		if (!in_interact_range(user, src) || !in_interact_range(user, O) || user.restrained() || user.getStatusDuration("unconscious") || user.sleeping || user.stat || user.lying)
			return

		if (ismob(O) && O == user)
			boutput(user, SPAN_ALERT("This table looks way too intimidating for you to scale on your own! You'll need a partner to help you over."))
			return

		if (!isitem(O))
			return

		var/obj/item/I = O
		if(I.equipped_in_slot && I.cant_self_remove)
			return
		I.stored?.transfer_stored_item(I, get_turf(I), user = user)
		if (istype(I,/obj/item/satchel))
			var/obj/item/satchel/S = I
			if (length(S.contents) < 1)
				boutput(user, SPAN_ALERT("There's nothing in [S]!"))
			else
				user.visible_message(SPAN_NOTICE("[user] dumps out [S]'s contents onto [src]!"))
				for (var/obj/item/thing in S.contents)
					thing.set_loc(src.loc)
				S.tooltip_rebuild = 1
				S.UpdateIcon()
				return
		if (isrobot(user) || user.equipped() != I || (I.cant_drop || I.cant_self_remove))
			return

		src.place_on(I, user, params, TRUE)


	mouse_drop(atom/over_object, src_location, over_location)
		if (usr == over_object && src.has_drawer && src.drawer_locked)
			boutput(usr, SPAN_ALERT("[src]'s desk drawer is locked!"))
			return
		..()

	Bumped(atom/AM)
		..()
		if(!ismonkey(AM))
			return
		var/mob/living/carbon/human/M = AM
		if(!isalive(M))
			return
		actions.start(new /datum/action/bar/icon/railing_jump/table_jump(M, src), M)

	hitby(atom/movable/AM, datum/thrown_thing/thr)
		. = ..()
		if (ismob(AM))
			if (AM != thr.thrown_by && (BOUNDS_DIST(thr.thrown_by, src) <= 0))
				var/remove_tablepass = HAS_FLAG(AM.flags, TABLEPASS) ? FALSE : TRUE //this sucks and should be a mob property x2 augh
				AM.flags |= TABLEPASS
				step(AM, get_dir(AM, src))
				if (remove_tablepass)
					REMOVE_FLAG(AM.flags, TABLEPASS)
				src.harm_slam(thr.thrown_by, AM)

	after_abcu_spawn()
		if(src.has_drawer)
			for(var/obj/I in src.storage.get_all_contents())
				qdel(I)


//Replacement for monkies walking through tables: They now parkour over them.
//Note: Max count of tables traversable is 2 more than the iteration limit
/datum/action/bar/icon/railing_jump/table_jump
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
			thr.end_throw_callback = CALLBACK(src, PROC_REF(unset_tablepass_callback))
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
	has_drawer = TRUE

TYPEINFO(/obj/table/round)
TYPEINFO_NEW(/obj/table/round)
	. = ..()
	smooth_list = typecacheof(/obj/table/round/auto)
/obj/table/round
	icon = 'icons/obj/furniture/table_round.dmi'
	parts_type = /obj/item/furniture_parts/table/round

	auto
		auto = 1

TYPEINFO_NEW(/obj/table/wood)
	. = ..()
	smooth_list = typecacheof(/obj/table/wood/auto)
TYPEINFO(/obj/table/wood)
	mat_appearances_to_ignore = list("wood")
/obj/table/wood
	name = "wooden table"
	desc = "A table made from solid oak, which is quite rare in space."
	icon = 'icons/obj/furniture/table_wood.dmi'
	parts_type = /obj/item/furniture_parts/table/wood
	uses_default_material_appearance = FALSE
	mat_changename = FALSE
	default_material = "wood"

	auto
		auto = 1

/obj/table/wood/auto/desk
	name = "wooden desk"
	desc = "A desk made of wood with a little drawer to store things in!"
	icon = 'icons/obj/furniture/table_wood_desk.dmi'
	parts_type = /obj/item/furniture_parts/table/wood/desk
	has_drawer = TRUE

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

TYPEINFO(/obj/table/mauxite)
TYPEINFO_NEW(/obj/table/mauxite)
	. = ..()
	smooth_list = typecacheof(/obj/table/mauxite/auto)
/obj/table/mauxite
	name = "table"
	icon = 'icons/obj/furniture/table.dmi'
	icon_state = "0$$mauxite"
	uses_default_material_appearance = TRUE
	mat_changename = TRUE
	default_material = "mauxite"

	auto
		auto = TRUE

/obj/table/folding
	name = "folding table"
	desc = "A table with a faux wood top designed for quick assembly and toolless disassembly."
	icon = 'icons/obj/furniture/table_folding.dmi'
	parts_type = /obj/item/furniture_parts/table/folding

	attack_hand(mob/user)
		if (user.is_hulk())
			user.visible_message(SPAN_ALERT("[user] collapses the [src] in one slam!"))
			playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
			deconstruct()
		else if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.w_uniform, /obj/item/clothing/under/misc/lawyer))
				slaps += 1
				src.visible_message(SPAN_ALERT("<b>[H] slams [his_or_her(H)] palms against [src]!</b>"))
				if (slaps > 2 && prob(50))
					src.visible_message(SPAN_ALERT("<b>The [src] collapses!</b>"))
					deconstruct()
				playsound(src.loc, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, 1)
				for (var/mob/N in AIviewers(user, null))
					if (N.client)
						shake_camera(N, 4, 8, 0.5)
			else
				actions.start(new /datum/action/bar/icon/fold_folding_table(src, null), user)
		return

	harm_slam(mob/user, mob/victim)
		if (!victim.hasStatus("knockdown"))
			victim.changeStatus("knockdown", 4 SECONDS)
			victim.force_laydown_standup()
		src.visible_message(SPAN_ALERT("<b>[user] slams [victim] onto \the [src], collapsing it instantly!</b>"))
		playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, TRUE)
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
		START_TRACKING_CAT(TR_CAT_NUKE_OP_STYLE)
		..()

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
	default_material = "glass"

	auto
		auto = TRUE

TYPEINFO(/obj/table/sleek)
TYPEINFO_NEW(/obj/table/sleek)
	. = ..()
	smooth_list = typecacheof(/obj/table/sleek/auto)
/obj/table/sleek
	name = "sleek metal table"
	desc = "A table with a reflective dark surface."
	icon = 'icons/obj/furniture/table_sleek.dmi'
	parts_type = /obj/item/furniture_parts/table/sleek

	auto
		auto = TRUE
TYPEINFO(/obj/table/monodesk)
TYPEINFO_NEW(/obj/table/monodesk)
	. = ..()
	smooth_list = typecacheof(/obj/table/monodesk/auto)
/obj/table/monodesk
	name = "monochrome desk"
	desc = "A sturdy desk with a little drawer to store things in!"
	icon = 'icons/obj/furniture/table_monochrome_desk.dmi'
	parts_type = /obj/item/furniture_parts/table/monodesk
	has_drawer = TRUE

	auto
		auto = TRUE
/obj/table/monodesk/auto/candystash
	desc = "One of the drawers seems to have something colorful peeking out."
	drawer_contents = list(/obj/item/kitchen/peach_rings,
				/obj/item/reagent_containers/food/snacks/candy/chocolate = 2,
				/obj/item/kitchen/gummy_worms_bag = 2,
				/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/butterscotch = 2,
				/obj/item/reagent_containers/food/snacks/candy/swirl_lollipop,
				/obj/item/reagent_containers/food/snacks/candy/hard_candy,
				/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/taffy/watermelon,
				/obj/item/reagent_containers/food/snacks/candy/wrapped_candy/caramel,
				/obj/item/clothing/mask/cigarette/nicofree,
				/obj/item/cigpacket/nicofree)

/obj/table/monodesk/auto/files
	desc = "The drawer seems to be stuffed with files and paper."
	drawer_contents = list(/obj/item/paper_bin,
				/obj/item/folder =4,
				/obj/item/paper/blueprint/chart,
				/obj/item/paper/blueprint/cog1,
				/obj/item/pen/fancy,
				/obj/item/pen,
				/obj/item/clipboard)

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

/obj/table/endtable_honey
	name = "block of solidified honey"
	desc = "Preferred work surface of Space Bees."
	icon = 'icons/obj/furniture/single_tables.dmi'
	icon_state = "endtablehoney"
	parts_type = /obj/item/furniture_parts/endtable_honey

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
	status = STATUS_STRONG
	parts_type = /obj/item/furniture_parts/table/reinforced
	HELP_MESSAGE_OVERRIDE(null)

	auto
		auto = 1

	get_help_message(dist, mob/user)
		if (src.status == STATUS_STRONG)
			return {"You can use a <b>welding tool</b> on [SPAN_HARM("harm")] intent to weaken it for disassembly."}
		else if (src.status == STATUS_WEAK)
			return{"
				You can use a <b>wrench</b> on [SPAN_HARM("harm")] intent to disassemble it,
				or a <b>welding tool</b> on [SPAN_HARM("harm")] intent to strengthen it.
			"}

	attackby(obj/item/W, mob/user)
		if (isweldingtool(W) && user.a_intent == "harm" && W:try_weld(user,1))
			if (src.status == STATUS_STRONG)
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_WEAKEN), user)
				return
			else if (src.status == STATUS_WEAK)
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_STRENGTHEN), user)
				return
			else
				return ..()
		else if (iswrenchingtool(W) && user.a_intent == "harm")
			if (src.status == STATUS_WEAK)
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_DISASSEMBLE), user)
				return
			else
				boutput(user, SPAN_ALERT("You need to weaken the [src.name] with a welding tool before you can disassemble it!"))
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
	has_drawer = TRUE
	auto
		auto = 1

/obj/table/reinforced/chemistry/auto/beakers //starts with 7 :B:eakers inside it, wow!!
	name = "beaker storage"
	drawer_contents = list(/obj/item/reagent_containers/glass/beaker = 7)

/obj/table/reinforced/chemistry/auto/basicsup
	name = "basic supply lab counter"
	desc = "Everything an aspiring chemist needs to start making chemicals!"
	drawer_contents = list(/obj/item/paper/book/from_file/pharmacopia,
				/obj/item/storage/box/beakerbox,
				/obj/item/reagent_containers/glass/beaker/large = 2,
				/obj/item/clothing/glasses/spectro,
				/obj/item/device/reagentscanner = 2,
				/obj/item/reagent_containers/dropper/mechanical = 2,
				/obj/item/reagent_containers/dropper = 2)

/obj/table/reinforced/chemistry/auto/auxsup
	name = "auxiliary supply lab counter"
	desc = "Extra supplies for the discerning chemist."
	drawer_contents = list(/obj/item/storage/box/patchbox,
				/obj/item/storage/box/syringes,
				/obj/item/clothing/glasses/spectro,
				/obj/item/device/reagentscanner,
				/obj/item/bunsen_burner,
				/obj/item/reagent_containers/dropper/mechanical,
				/obj/item/storage/box/lglo_kit,
				/obj/item/storage/box/beaker_lids,
				/obj/item/reagent_containers/glass/plumbing/condenser = 3,
				/obj/item/reagent_containers/glass/plumbing/condenser/fractional = 1,
				/obj/item/reagent_containers/glass/plumbing/dropper = 2)



/obj/table/reinforced/chemistry/auto/clericalsup
	name = "clerical supply lab counter"
	desc = "It's only science if you write it down! Or blow yourself up."
	drawer_contents = list(/obj/item/paper_bin = 2,
				/obj/item/hand_labeler,
				/obj/item/clipboard = 2,
				/obj/item/pen,
				/obj/item/stamp,
				/obj/item/device/audio_log,
				/obj/item/audio_tape = 2)


/obj/table/reinforced/chemistry/auto/firstaid
	name = "toxin care lab counter"
	desc = "These drawers have been labeled EMERGENCY TOXIN CARE, which means they're probably already close to empty."
	drawer_contents = list(/obj/item/storage/firstaid/toxin,
				/obj/item/reagent_containers/emergency_injector/calomel)

/obj/table/reinforced/chemistry/auto/chemstorage
	name = "chemical storage lab counter"
	desc = "A set of basic precursor chemicals to expedite order fulfillment, increase efficiency, and synergize your workflow. Whatever the fuck that means."
	drawer_contents = list(/obj/item/reagent_containers/food/drinks/fueltank,
				/obj/item/reagent_containers/glass/bottle/oil,
				/obj/item/reagent_containers/glass/bottle/phenol,
				/obj/item/reagent_containers/glass/bottle/acid,
				/obj/item/reagent_containers/glass/bottle/acetone,
				/obj/item/reagent_containers/glass/bottle/diethylamine,
				/obj/item/reagent_containers/glass/bottle/ammonia)

/obj/table/reinforced/chemistry/auto/drugs
	name = "seedy-looking lab counter"
	desc = ""
	drawer_contents = list(/obj/item/plant/herb/cannabis/spawnable = 2,
				/obj/item/device/light/zippo,
				/obj/item/reagent_containers/syringe/krokodil,
				/obj/item/reagent_containers/syringe/morphine,
				/obj/item/storage/pill_bottle/cyberpunk)

	get_desc(var/dist, var/mob/user)
		if (user.mind?.assigned_role == "Research Director")
			. = "<br>A stash of drugs provided in an attempt to placate your underlings. Stocking this drawer was your greatest mistake."
		else
			. = "<br>A stash of drugs, and maybe the only positive contribution the RD ever made to the station. Too bad they cheaped out on the selection."

/obj/table/reinforced/chemistry/auto/allinone
	name = "jam-packed lab counter"
	desc = "The drawers on these barely close, and rattle loudly when moved. Guess they tried to put too much crap in it."
	drawer_contents = list(/obj/item/paper/book/from_file/pharmacopia,
				/obj/item/storage/box/beakerbox = 2,
				/obj/item/storage/box/syringes,
				/obj/item/paper_bin,
				/obj/item/hand_labeler,
				/obj/item/reagent_containers/dropper/mechanical,
				/obj/item/reagent_containers/dropper,
				/obj/item/storage/firstaid/toxin,
				/obj/item/clothing/glasses/spectro,
				/obj/item/device/reagentscanner)


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

TYPEINFO_NEW(/obj/table/glass)
	. = ..()
	smooth_list = typecacheof(/obj/table/glass) // has to be the base type here or else regular glass tables won't connect to reinforced ones
TYPEINFO(/obj/table/glass)
	mat_appearances_to_ignore = list("glass")
/obj/table/glass
	name = "glass table"
	desc = "A table made of glass. It looks like it might shatter if you set something down on it too hard."
	icon = 'icons/obj/furniture/table_glass.dmi'
	default_material = "glass"
	parts_type = /obj/item/furniture_parts/table/glass
	var/glass_broken = GLASS_INTACT
	var/reinforced = 0

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
		src.visible_message(SPAN_ALERT("\The [src] shatters!"))
		playsound(src, "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
		if (src.material?.getID() in list("gnesis", "gnesisglass"))
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

		for(var/i_dir in cardinal)
			var/turf/T = get_step(src, i_dir)
			for(var/obj/table/glass/G in T)
				G.smash()

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
				src.visible_message(SPAN_ALERT("\The [src] starts to reform!"))

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
				src.visible_message(SPAN_ALERT("\The [src] fully reforms!"))
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
				var/datum/material/mat = S.material //hold a ref to this in case the sheet stack gets disposed by using the last sheet
				if (!S.material || !(S.material.getMaterialFlags() & MATERIAL_CRYSTAL))
					boutput(user, SPAN_ALERT("You have to use glass or another crystalline material to repair [src]!"))
				else if (S.change_stack_amount(-2))
					boutput(user, SPAN_NOTICE("You add glass to [src]!"))
					if (S.reinforcement)
						src.reinforced = 1
					if (mat)
						src.setMaterial(mat)
					src.repair()
				return
			else
				return ..()

		var/can_smash = FALSE

		var/smashprob = 1
		if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!G.affecting || G.affecting.buckled)
				return
			if (G.state == GRAB_PASSIVE)
				boutput(user, SPAN_ALERT("You need a tighter grip!"))
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

		else if (istype(W,/obj/item/sheet/wood) || istool(W, TOOL_SCREWING | TOOL_WRENCHING) || (istype(W, /obj/item/reagent_containers/food/drinks/bottle) && user.a_intent == "harm"))
			return ..()

		else if (istype(W, /obj/item/reagent_containers/food/drinks/bottle) && user.a_intent == "harm")
			var/obj/item/reagent_containers/food/drinks/bottle/B = W
			B.smash_on_thing(user, src)
			if(user.equipped())
				smashprob += 15
				can_smash = TRUE
			else
				return

		else if(istype(W, /obj/item/paint_can))
			return

		else
			can_smash = TRUE

		if (can_smash && istype(W)) // determine smash chance via item size and user clumsiness  :v
			if (user.bioHolder.HasEffect("clumsy"))
				smashprob += 25
			smashprob += (W.w_class / 6) * 10
			DEBUG_MESSAGE("[src] smashprob += ([W.w_class] / 6) * 10 (result [(W.w_class / 6) * 10])")

			if (src.reinforced)
				smashprob = round(smashprob / 2, 1)

			if (src.place_on(W, user, params))
				playsound(src, 'sound/impact_sounds/Crystal_Hit_1.ogg', 100, TRUE)
			else if (W && user.a_intent != "help")
				DEBUG_MESSAGE("[src] smashprob = ([smashprob] * 1.5) (result [(smashprob * 1.5)])")
				smashprob = (smashprob * 1.5)

			if (prob(smashprob))
				if (istype(W) && !isrobot(user))
					src.visible_message(SPAN_ALERT("[user] places [W] down on [src] too hard!"))
				src.smash()
				if (istype(W) && !isrobot(user))
					src.visible_message("\The [W] falls to the floor.")
			return

		else
			return ..()

	harm_slam(mob/user, mob/victim)
		if(src.glass_broken != GLASS_INTACT)
			return ..()
		victim.set_loc(src.loc)
		victim.changeStatus("knockdown", 4 SECONDS)
		src.visible_message(SPAN_ALERT("<b>[user] slams [victim] onto \the [src]!</b>"))
		playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, TRUE)
		src.material_trigger_when_attacked(victim, user, 1)
		if ((prob(src.reinforced ? 60 : 80)) || (user.bioHolder.HasEffect("clumsy") && (!src.reinforced || prob(90))))
			src.smash()
			random_brute_damage(victim, rand(20,40),1)
			take_bleeding_damage(victim, user, rand(20,40))
			if (prob(30) || user.bioHolder.HasEffect("clumsy"))
				boutput(user, SPAN_ALERT("You cut yourself on \the [src] as [victim] slams through the glass!"))
				random_brute_damage(user, rand(10,30),1)
				take_bleeding_damage(user, user, rand(10,30))

		if (isliving(user))
			var/mob/living/dude = user
			var/datum/gang/gang = dude.get_gang()
			gang?.do_vandalism(GANG_VANDALISM_TABLING, src.loc)

	hitby(atom/movable/AM, datum/thrown_thing/thr)
		..()
		if (ismob(AM))
			var/mob/M = AM
			if ((prob(src.reinforced ? 60 : 80)))
				logTheThing(LOG_COMBAT, thr.user, "throws [constructTarget(M,"combat")] into a glass table, breaking it")
				src.visible_message(SPAN_ALERT("[M] smashes through [src]!"))
				playsound(src, 'sound/impact_sounds/Generic_Hit_Heavy_1.ogg', 50, TRUE)
				src.smash()
				if (isliving(thr.thrown_by))
					var/mob/living/dude = thr.thrown_by
					var/datum/gang/gang = dude.get_gang()
					gang?.do_vandalism(GANG_VANDALISM_TABLING, src.loc)
				if (M.loc != src.loc)
					step(M, get_dir(M, src))
				if (ishuman(M))
					random_brute_damage(M, rand(30,50),1)
					take_bleeding_damage(M, M, rand(20,40))
		return

	place_on(obj/item/W as obj, mob/user as mob, params)
		..()
		if (. == 1) // successfully put thing on table, make a noise because we are a fancy special glass table
			playsound(src, 'sound/impact_sounds/Crystal_Hit_1.ogg', 100, TRUE)
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
		set_icon_state(num2text(dirs))

		if (src.glass_broken == GLASS_BROKEN)
			src.ClearSpecificOverlays("tabletop", "SWcorner", "SEcorner", "NEcorner", "NWcorner")
			src.set_density(0)
			return

		// check it out a new piece of hacky nonsense
		var/R = src.reinforced ? "R" : null
		if (!src.working_image)
			src.working_image = image(src.icon, "[R]g[num2text(dirs)]")
		else
			src.working_image.icon_state = "[R]g[num2text(dirs)]"
			setMaterialAppearanceForImage(working_image)
		src.AddOverlays(working_image, "tabletop")

		var/obj/table/WT = locate(auto_type) in get_step(src, WEST)
		var/obj/table/ST = locate(auto_type) in get_step(src, SOUTH)
		var/obj/table/ET = locate(auto_type) in get_step(src, EAST)
		var/obj/table/NT = locate(auto_type) in get_step(src, NORTH)

		// west, south, and southwest
		if (WT && ST)
			var/obj/table/SWT = locate(auto_type) in get_step(src, SOUTHWEST)
			if (SWT)
				working_image.icon_state = "[R]gSWs"
			else
				working_image.icon_state = "[R]gSW"
			setMaterialAppearanceForImage(working_image)
			src.UpdateOverlays(working_image, "SWcorner")
		else
			src.UpdateOverlays(null, "SWcorner")

		// south, east, and southeast
		if (ST && ET)
			var/obj/table/SET = locate(auto_type) in get_step(src, SOUTHEAST)
			if (SET)
				working_image.icon_state = "[R]gSEs"
			else
				working_image.icon_state = "[R]gSE"
			setMaterialAppearanceForImage(working_image)
			src.UpdateOverlays(working_image, "SEcorner")
		else
			src.UpdateOverlays(null, "SEcorner")

		// north, east, and northeast
		if (NT && ET)
			var/obj/table/NET = locate(auto_type) in get_step(src, NORTHEAST)
			if (NET)
				working_image.icon_state = "[R]gNEs"
			else
				working_image.icon_state = "[R]gNE"
			setMaterialAppearanceForImage(working_image)
			src.UpdateOverlays(working_image, "NEcorner")
		else
			src.UpdateOverlays(null, "NEcorner")

		// north, west, and northwest
		if (NT && WT)
			var/obj/table/NWT = locate(auto_type) in get_step(src, NORTHWEST)
			if (NWT)
				working_image.icon_state = "[R]gNWs"
			else
				working_image.icon_state = "[R]gNW"
			setMaterialAppearanceForImage(working_image)
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
		else if (interaction == TABLE_DISASSEMBLE && the_table.has_drawer)
			if (the_table.drawer_locked)
				boutput(owner, SPAN_ALERT("You can't disassemble [the_table] when its drawer is locked!"))
				interrupt(INTERRUPT_ALWAYS)
				return
			else if (length(the_table.storage.get_contents()))
				boutput(owner, SPAN_ALERT("You can't disassemble [the_table] while its drawer has stuff in it!"))
				interrupt(INTERRUPT_ALWAYS)
				return
		else if (interaction == TABLE_LOCKPICK)
			if (!the_table.has_drawer || !the_table.drawer_locked)
				interrupt(INTERRUPT_ALWAYS)
				return
			else if (prob(8))
				owner.visible_message(SPAN_ALERT("[owner] messes up while picking [the_table]'s lock!"))
				playsound(the_table, 'sound/items/Screwdriver2.ogg', 50, TRUE)
				interrupt(INTERRUPT_ALWAYS)
				return

	onStart()
		..()
		var/verbing = "doing something to"
		switch (interaction)
			if (TABLE_DISASSEMBLE)
				verbing = "disassembling"
				playsound(the_table, 'sound/items/Ratchet.ogg', 50, TRUE)
			if (TABLE_WEAKEN)
				verbing = "weakening"
				the_tool:try_weld(owner,0,-1)
			if (TABLE_STRENGTHEN)
				verbing = "strengthening"
				the_tool:try_weld(owner,0,-1)
			if (TABLE_ADJUST)
				verbing = "adjusting the shape of"
				playsound(the_table, 'sound/items/Screwdriver.ogg', 50, TRUE)
			if (TABLE_LOCKPICK)
				verbing = "picking the lock on"
				playsound(the_table, 'sound/items/Screwdriver2.ogg', 50, TRUE)
		owner.visible_message(SPAN_NOTICE("[owner] begins [verbing] [the_table]."))

	onEnd()
		..()
		var/verbens = "does something to"
		switch (interaction)
			if (TABLE_DISASSEMBLE)
				verbens = "disassembles"
				playsound(the_table, 'sound/items/Deconstruct.ogg', 50, TRUE)
				the_table.deconstruct()
			if (TABLE_WEAKEN)
				verbens = "weakens"
				the_table.status = STATUS_WEAK
			if (TABLE_STRENGTHEN)
				verbens = "strengthens"
				the_table.status = STATUS_STRONG
			if (TABLE_ADJUST)
				verbens = "adjusts the shape of"
				the_table.set_up()
			if (TABLE_LOCKPICK)
				verbens = "picks the lock on"
				if (the_table.has_drawer)
					the_table.drawer_locked = FALSE
				playsound(the_table, 'sound/items/Screwdriver2.ogg', 50, TRUE)
		owner.visible_message(SPAN_NOTICE("[owner] [verbens] [the_table]."))

/datum/action/bar/icon/fold_folding_table
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
			playsound(the_table, 'sound/items/Ratchet.ogg', 50, TRUE)
		else
			playsound(the_table, 'sound/items/Screwdriver2.ogg', 50, TRUE)
		owner.visible_message(SPAN_NOTICE("[owner] begins disassembling [the_table]."))

	onEnd()
		..()
		playsound(the_table, 'sound/items/Deconstruct.ogg', 50, TRUE)
		owner.visible_message(SPAN_NOTICE("[owner] disassembles [the_table]."))
		the_table.deconstruct()

/datum/action/bar/icon/furnish_table
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 5 SECONDS
	icon = 'icons/ui/actions.dmi'
	icon_state = "working"

	var/obj/table/reinforced/the_table
	var/obj/item/sheet/wood/the_planks

	New(var/obj/table/reinforced/rtable,var/obj/item/sheet/wood/planks)
		..()
		if (rtable)
			the_table = rtable
		if (planks)
			the_planks = planks

	onUpdate()
		..()
		var/mob/source = owner
		if (the_table == null || the_planks == null || BOUNDS_DIST(owner, the_table) > 0)
			interrupt(INTERRUPT_ALWAYS)
		else if (istype(source) && the_planks != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
		else if (the_table.status != STATUS_STRONG)
			boutput(owner, SPAN_NOTICE("\The [src] is too weak to be modified!"))
			interrupt(INTERRUPT_ALWAYS)
		else if (the_planks.amount < 5)
			boutput(owner, SPAN_NOTICE("You need at least 5 planks to furnish the whole table."))
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		if (the_planks.amount < 5)
			boutput(owner, SPAN_NOTICE("You need at least 5 planks to furnish the whole table."))
		owner.visible_message(SPAN_NOTICE("[owner] starts adding a faux wood finish to \the [the_table].")) //mwah
		playsound(the_table.loc, 'sound/items/zipper.ogg', 50, 1)

	onEnd()
		..()
		owner.visible_message(SPAN_NOTICE("[owner] finishes adding a faux wood finish to \the [the_table]."))
		var/obj/table/L = new /obj/table/reinforced/bar/auto(the_table.loc)
		L.layer = the_table.layer - 0.01
		the_planks.change_stack_amount(-5)
		qdel(the_table)
		return

#undef STATUS_WEAK
#undef STATUS_STRONG
