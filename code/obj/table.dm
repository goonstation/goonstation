/obj/table
	name = "table"
	desc = "A metal table strong enough to support a substantial amount of weight, but easily made portable by unsecuring the bolts with a wrench."
	icon = 'icons/obj/furniture/table.dmi'
	icon_state = "0"
	density = 1
	anchored = 1.0
	flags = NOSPLASH
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS
	layer = OBJ_LAYER-0.1
	mat_changename = 1
	var/auto_type = /obj/table/auto
	var/parts_type = /obj/item/furniture_parts/table
	var/auto = 0
	var/status = null //1=weak|welded, 2=strong|unwelded
	var/image/working_image = null
	var/has_storage = 0
	var/obj/item/storage/desk_drawer/desk_drawer = null
	var/slaps = 0


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

		SPAWN_DBG(0)
			if (src.auto && ispath(src.auto_type) && src.icon_state == "0") // if someone's set up a special icon state don't mess with it
				src.set_up()
				SPAWN_DBG(0)
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

	proc/set_up()
		if (!ispath(src.auto_type))
			return
		var/dirs = 0
		for (var/direction in cardinal)
			var/turf/T = get_step(src, direction)
			if (locate(src.auto_type) in T)
				dirs |= direction
		icon_state = num2text(dirs)

		//christ this is ugly
		//seconded, its also broken for tables in diagonal directions // maybe not any more?
		var/obj/table/WT = locate(src.auto_type) in get_step(src, WEST)
		var/obj/table/ST = locate(src.auto_type) in get_step(src, SOUTH)
		var/obj/table/ET = locate(src.auto_type) in get_step(src, EAST)
		var/obj/table/NT = locate(src.auto_type) in get_step(src, NORTH)

		// west, south, and southwest
		if (WT && ST)
			var/obj/table/SWT = locate(src.auto_type) in get_step(src, SOUTHWEST)
			if (SWT)
				if (!src.working_image)
					src.working_image = image(src.icon, "SW")
				else
					working_image.icon_state = "SW"
				src.UpdateOverlays(working_image, "SWcorner")
			else
				src.UpdateOverlays(null, "SWcorner")
		else
			src.UpdateOverlays(null, "SWcorner")

		// south, east, and southeast
		if (ST && ET)
			var/obj/table/SET = locate(src.auto_type) in get_step(src, SOUTHEAST)
			if (SET)
				if (!src.working_image)
					src.working_image = image(src.icon, "SE")
				else
					working_image.icon_state = "SE"
				src.UpdateOverlays(working_image, "SEcorner")
			else
				src.UpdateOverlays(null, "SEcorner")
		else
			src.UpdateOverlays(null, "SEcorner")

		// north, east, and northeast
		if (NT && ET)
			var/obj/table/NET = locate(src.auto_type) in get_step(src, NORTHEAST)
			if (NET)
				if (!src.working_image)
					src.working_image = image(src.icon, "NE")
				else
					working_image.icon_state = "NE"
				src.UpdateOverlays(working_image, "NEcorner")
			else
				src.UpdateOverlays(null, "NEcorner")
		else
			src.UpdateOverlays(null, "NEcorner")

		// north, west, and northwest
		if (NT && WT)
			var/obj/table/NWT = locate(src.auto_type) in get_step(src, NORTHWEST)
			if (NWT)
				if (!src.working_image)
					src.working_image = image(src.icon, "NW")
				else
					working_image.icon_state = "NW"
				src.UpdateOverlays(working_image, "NWcorner")
			else
				src.UpdateOverlays(null, "NWcorner")
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

	custom_suicide = 1
	suicide(var/mob/user as mob) //if this is TOO ridiculous just remove it idc
		if (!src.user_can_suicide(user))
			return 0
		var/hisher = his_or_her(user)
		user.visible_message("<span class='alert'><b>[user] contorts [him_or_her(user)]self so that [hisher] head is underneath one of [src]'s legs and [hisher] heels are resting on top of it, then raises [hisher] feet and slams them back down over and over again!</b></span>")
		user.TakeDamage("head", 175, 0)
		SPAWN_DBG(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return 1

	ex_act(severity)
		switch (severity)
			if (1.0)
				//SN src = null
				qdel(src)
				return
			if (2.0)
				if (prob(50))
					//SN src = null
					qdel(src)
					return
				else
					src.deconstruct()
					return
			if (3.0)
				if (prob(25))
					src.deconstruct()
					return
			else
				return
		return

	disposing()
		var/turf/OL = get_turf(src)
		if (src.desk_drawer && src.desk_drawer.contents.len)
			for (var/atom/movable/A in src.desk_drawer)
				A.set_loc(OL)
			var/obj/O = src.desk_drawer
			src.desk_drawer = null
			qdel(O)

		loc = null
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

	attackby(obj/item/W as obj, mob/user as mob, params)
		if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!G.affecting || G.affecting.buckled)
				return
			if (!G.state)
				boutput(user, "<span class='alert'>You need a tighter grip!</span>")
				return
			G.affecting.set_loc(src.loc)
			if (user.a_intent == "harm")
				if (istype(src, /obj/table/folding))
					if (!G.affecting.hasStatus("weakened"))
						G.affecting.changeStatus("weakened", 4 SECONDS)
						G.affecting.force_laydown_standup()
					src.visible_message("<span class='alert'><b>[G.assailant] slams [G.affecting] onto \the [src], collapsing it instantly!</b></span>")
					playsound(get_turf(src), "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
					deconstruct()
				else
					if (!G.affecting.hasStatus("weakened"))
						G.affecting.changeStatus("weakened", 3 SECONDS)
						G.affecting.force_laydown_standup()
					src.visible_message("<span class='alert'><b>[G.assailant] slams [G.affecting] onto \the [src]!</b></span>")
					playsound(get_turf(src), "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
					if (src.material)
						src.material.triggerOnAttacked(src, G.assailant, G.affecting, src)
			else
				if (!G.affecting.hasStatus("weakened"))
					G.affecting.changeStatus("weakened", 2 SECONDS)
					G.affecting.force_laydown_standup()
				src.visible_message("<span class='alert'>[G.assailant] puts [G.affecting] on \the [src].</span>")
			if (G.affecting.bioHolder.HasEffect("fat")) // fatties crash through the table instead :V
				deconstruct()
			qdel(W)
			return

		else if (istype(W, /obj/item/plank))
			if (status == 2)
				if (istype(src, /obj/table/reinforced/bar)) //why must you be so confusing
					boutput(user, "<span class='notice'>You can't add more than one finish, that's just illogical!</span>")
					return
				else if (istype(src, /obj/table/reinforced/auto))
					boutput(user, "<span class='notice'>Now adding a faux wood finish to \the [src]</span>") //mwah
					playsound(src.loc, "sound/items/zipper.ogg", 50, 1)
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

		else if (isscrewingtool(W))
			if (istype(src.desk_drawer) && src.desk_drawer.locked)
				actions.start(new /datum/action/bar/icon/table_tool_interact(src, W, TABLE_LOCKPICK), user)
				return
			else if (src.auto && ispath(src.auto_type))
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
			src.desk_drawer.attackby(W, user)
			return

		else if (istype(W) && src.place_on(W, user, params))
			return

		else
			return ..()

	attack_hand(mob/user as mob)
		if (user.is_hulk())
			user.visible_message("<span class='alert'>[user] destroys the table!</span>")
			if (prob(40))
				playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
			deconstruct()
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

				playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
				if (src.material)
					src.material.triggerOnAttacked(src, user, user, src)
				for (var/mob/N in AIviewers(usr, null))
					if (N.client)
						shake_camera(N, 4, 1, 0.5)
			if(ismonkey(H))
				actions.start(new /datum/action/bar/icon/railing_jump/table_jump(user, src), user)
		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0)) return 1

		if (!src.density || (mover.flags & TABLEPASS || istype(mover, /obj/newmeteor)) )
			return 1
		else
			return 0

	MouseDrop_T(atom/O, mob/user as mob)
		if (!in_range(user, src) || !in_range(user, O) || user.restrained() || user.getStatusDuration("paralysis") || user.sleeping || user.stat || user.lying)
			return

		if (ismob(O) && O == user)
			boutput(usr, "<span class='alert'>This table looks way too intimidating for you to scale on your own! You'll need a partner to help you over.</span>")
			return

		if (!isitem(O))
			return

		var/obj/item/I = O
		if (istype(I,/obj/item/satchel))
			var/obj/item/satchel/S = I
			if (S.contents.len < 1)
				boutput(usr, "<span class='alert'>There's nothing in [S]!</span>")
			else
				user.visible_message("<span class='notice'>[user] dumps out [S]'s contents onto [src]!</span>")
				for (var/obj/item/thing in S.contents)
					thing.set_loc(src.loc)
				S.desc = "A leather bag. It holds 0/[S.maxitems] [S.itemstring]."
				S.satchel_updateicon()
				return
		if (isrobot(user) || user.equipped() != I || (I.cant_drop || I.cant_self_remove))
			return
		user.drop_item()
		if (I.loc != src.loc)
			step(I, get_dir(I, src))
		return

	MouseDrop(atom/over_object, src_location, over_location)
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
	var/const/throw_range = 7
	var/const/iteration_limit = 5

	getLandingLoc()
		var/iteration = 0
		var/turf/target = get_step(the_railing, ownerMob.dir)
		var/obj/table/maybe_table = locate(/obj/table) in target
		while(maybe_table && iteration < iteration_limit)
			iteration++
			target = get_step(target, ownerMob.dir)
			maybe_table = locate(/obj/table) in target
			duration += 1 SECOND
		return target

	sendOwner()
		var/const/throw_speed = 0.5
		if (istype(ownerMob, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = ownerMob
			if (!(M.flags & TABLEPASS))
				var/tables_traveled = duration/(1 SECONDS)
				SPAWN_DBG((tables_traveled/throw_speed) DECI SECONDS)
					M.flags &= !TABLEPASS
			M.flags ^= TABLEPASS

		ownerMob.throw_at(jump_target, throw_range, throw_speed)
		for(var/O in AIviewers(ownerMob))
			var/mob/M = O //inherently typed list
			var/the_text = "[ownerMob] jumps over [the_railing]."
			if (is_athletic_jump) // athletic jumps are more athletic!!
				the_text = "[ownerMob] swooces right over [the_railing]!"
			M.show_text("[the_text]", "red")
		logTheThing("combat", ownerMob, the_railing, "[is_athletic_jump ? "leaps over %the_railing% with [his_or_her(ownerMob)] athletic trait" : "crawls over %the_railing%"].")

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

/obj/table/round
	icon = 'icons/obj/furniture/table_round.dmi'
	auto_type = /obj/table/round/auto
	parts_type = /obj/item/furniture_parts/table/round

	auto
		auto = 1

/obj/table/wood
	name = "wooden table"
	desc = "A table made from solid oak, which is quite rare in space."
	icon = 'icons/obj/furniture/table_wood.dmi'
	auto_type = /obj/table/wood/auto
	parts_type = /obj/item/furniture_parts/table/wood

	auto
		auto = 1

/obj/table/wood/auto/desk
	name = "wooden desk"
	desc = "A desk made of wood with a little drawer to store things in!"
	icon = 'icons/obj/furniture/table_wood_desk.dmi'
	parts_type = /obj/item/furniture_parts/table/wood/desk
	has_storage = 1

/obj/table/wood/round
	icon = 'icons/obj/furniture/table_wood_round.dmi'
	auto_type = /obj/table/wood/round/auto
	parts_type = /obj/item/furniture_parts/table/wood/round

	auto
		auto = 1

/obj/table/folding
	name = "folding table"
	desc = "A table with a faux wood top designed for quick assembly and toolless disassembly."
	icon = 'icons/obj/furniture/table_folding.dmi'
	parts_type = /obj/item/furniture_parts/table/folding

	attack_hand(mob/user as mob)
		if (user.is_hulk())
			user.visible_message("<span class='alert'>[user] collapses the [src] in one slam!</span>")
			playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
			deconstruct()
		else if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (istype(H.w_uniform, /obj/item/clothing/under/misc/lawyer))
				slaps += 1
				src.visible_message("<span class='alert'><b>[H] slams their palms against [src]!</b></span>")
				if (slaps > 2 && prob(50))
					src.visible_message("<span class='alert'><b>The [src] collapses!</b></span>")
					deconstruct()
				playsound(src.loc, "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
				for (var/mob/N in AIviewers(usr, null))
					if (N.client)
						shake_camera(N, 4, 1, 0.5)
			else
				actions.start(new /datum/action/bar/icon/fold_folding_table(src, null), user)
		return

/* ======================================== */
/* ---------------------------------------- */
/* ======================================== */

/obj/table/reinforced
	name = "reinforced table"
	desc = "A table made from reinforced metal, it is quite strong and it requires welding and wrenching to disassemble it."
	icon = 'icons/obj/furniture/table_reinforced.dmi'
	status = 2
	auto_type = /obj/table/reinforced/auto
	parts_type = /obj/item/furniture_parts/table/reinforced

	auto
		auto = 1

	attackby(obj/item/W as obj, mob/user as mob)
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
				return ..()
		else
			return ..()

/obj/table/reinforced/bar
	name = "bar table"
	desc = "A reinforced table with a faux wooden finish to make you feel at ease."
	icon = 'icons/obj/furniture/table_bar.dmi'
	auto_type = /obj/table/reinforced/bar/auto
	parts_type = /obj/item/furniture_parts/table/reinforced/bar

	auto
		auto = 1

/obj/table/reinforced/roulette
	name = "roulette table"
	desc = "A reinforced table with different betting markings on it."
	icon = 'icons/obj/gambling.dmi'
	icon_state = "roulette_e"
	auto_type = null
	parts_type = /obj/item/furniture_parts/table/reinforced/roulette

/obj/table/reinforced/chemistry
	name = "lab counter"
	desc = "A labratory countertop made from a paper composite, which is very heat resistant."
	icon = 'icons/obj/furniture/table_chemistry.dmi'
	auto_type = /obj/table/reinforced/chemistry/auto
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

/obj/table/reinforced/industrial
	name = "industrial table"
	desc = "An industrial table that looks like it has been made out of a scaffolding."
	icon = 'icons/obj/furniture/table_industrial.dmi'
	auto_type = /obj/table/reinforced/industrial/auto
	parts_type = /obj/item/furniture_parts/table/reinforced/industrial

	auto
		auto = 1

/* ======================================== */
/* ---------------------------------------- */
/* ======================================== */

/obj/table/glass
	name = "glass table"
	desc = "A table made of glass. It looks like it might shatter if you set something down on it too hard."
	icon = 'icons/obj/furniture/table_glass.dmi'
	mat_appearances_to_ignore = list("glass")
	parts_type = /obj/item/furniture_parts/table/glass
	auto_type = /obj/table/glass // has to be the base type here or else regular glass tables won't connect to reinforced ones
	var/glass_broken = 0
	var/reinforced = 0
	var/default_material = "glass"

	auto
		auto = 1

	frame
		name = "glass table frame"
		parts_type = /obj/item/furniture_parts/table/glass/frame
		glass_broken = 1

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
			var/datum/material/M
			M = getMaterial(default_material)
			src.setMaterial(M)

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
		playsound(get_turf(src), "sound/impact_sounds/Glass_Shatter_[rand(1,3)].ogg", 100, 1)
		for (var/i=rand(3,4), i>0, i--)
			var/obj/item/raw_material/shard/glass/G = unpool(/obj/item/raw_material/shard/glass)
			G.set_loc(src.loc)
			if (src.material)
				G.setMaterial(src.material)
		src.glass_broken = 1
		src.removeMaterial()
		src.parts_type = /obj/item/furniture_parts/table/glass/frame
		src.set_density(0)
		src.set_up()

	proc/repair()
		src.glass_broken = 0
		src.UpdateName()
		src.parts_type = src.reinforced ? /obj/item/furniture_parts/table/glass/reinforced : /obj/item/furniture_parts/table/glass
		src.set_density(initial(src.density))
		src.set_up()

	ex_act(severity)
		if (src.glass_broken)
			return ..()
		if (severity == 2.0)
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

	attack_hand(mob/user as mob)
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

	attackby(obj/item/W as obj, mob/user as mob, params)
		if (src.glass_broken)
			if (istype(W, /obj/item/sheet))
				var/obj/item/sheet/S = W
				if (!S.material || !S.material.material_flags & MATERIAL_CRYSTAL)
					boutput(user, "<span class='alert'>You have to use glass or another crystalline material to repair [src]!</span>")
					return
				else if (S.amount >= 1)
					boutput(user, "<span class='notice'>You add glass to [src]!</span>")
					if (S.reinforcement)
						src.reinforced = 1
					if (S.material)
						src.setMaterial(S.material)
					src.repair()
					S.amount--
					if (S.amount <= 0)
						user.u_equip(S)
						qdel(S)
				else // there's none!
					user.u_equip(S)
					qdel(S)
				return
			else
				return ..()

		var/smashprob = 1
		if (istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if (!G.affecting || G.affecting.buckled)
				return
			if (!G.state)
				boutput(user, "<span class='alert'>You need a tighter grip!</span>")
				return
			if (user.a_intent == "harm")
				G.affecting.set_loc(src.loc)
				G.affecting.changeStatus("weakened", 4 SECONDS)
				src.visible_message("<span class='alert'><b>[G.assailant] slams [G.affecting] onto \the [src]!</b></span>")
				playsound(get_turf(src), "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
				if (src.material)
					src.material.triggerOnAttacked(src, G.assailant, G.affecting, src)
				if ((prob(src.reinforced ? 60 : 80)) || (G.assailant.bioHolder.HasEffect("clumsy") && (!src.reinforced || prob(90))) || (G.affecting.bioHolder.HasEffect("fat") && (!src.reinforced || prob(80))))
					src.smash()
					random_brute_damage(G.affecting, rand(20,40),1)
					take_bleeding_damage(G.affecting, G.assailant, rand(20,40))
					if (prob(30) || G.assailant.bioHolder.HasEffect("clumsy") || G.affecting.bioHolder.HasEffect("fat"))
						boutput(user, "<span class='alert'>You cut yourself on \the [src] as [G.affecting] slams through the glass!</span>")
						random_brute_damage(G.assailant, rand(10,30),1)
						take_bleeding_damage(G.assailant, G.assailant, rand(10,30))
					qdel(W)
					return
			else
				G.affecting.set_loc(src.loc)
				G.affecting.changeStatus("weakened", 4 SECONDS)
				src.visible_message("<span class='alert'>[G.assailant] puts [G.affecting] on \the [src].</span>")
				if (G.assailant.bioHolder.HasEffect("clumsy"))
					smashprob += 25
				else
					smashprob += 10
			if (G.affecting.bioHolder.HasEffect("fat") && (!src.reinforced || prob(80)))
				src.smash()
				qdel(W)
				return
			qdel(W)

		else if (istype(W, /obj/item/plank) || istool(W, TOOL_SCREWING | TOOL_WRENCHING) || (istype(W, /obj/item/reagent_containers/food/drinks/bottle) && user.a_intent == "harm"))
			return ..()

		else if (istype(W, /obj/item/reagent_containers/food/drinks/bottle) && user.a_intent == "harm")
			var/obj/item/reagent_containers/food/drinks/bottle/B = W
			B.smash_on_thing(user, src)
			SPAWN_DBG(0)
				if (B)
					smashprob += 15
				else
					return

		else if (istype(W)) // determine smash chance via item size and user clumsiness  :v
			if (user.bioHolder.HasEffect("clumsy"))
				smashprob += 25
			smashprob += (W.w_class / 6) * 10
			DEBUG_MESSAGE("[src] smashprob += ([W.w_class] / 6) * 10 (result [(W.w_class / 6) * 10])")

			if (src.reinforced)
				smashprob = round(smashprob / 2, 1)

			if (src.place_on(W, user, params))
				playsound(get_turf(src), "sound/impact_sounds/Crystal_Hit_1.ogg", 100, 1)
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

	hitby(AM as mob|obj)
		..()
		if (ismob(AM))
			var/mob/M = AM
			if ((prob(src.reinforced ? 60 : 80)) || (M.bioHolder.HasEffect("fat") && (!src.reinforced || prob(80))))
				src.visible_message("<span class='alert'>[M] smashes through [src]!</span>")
				playsound(get_turf(src), "sound/impact_sounds/Generic_Hit_Heavy_1.ogg", 50, 1)
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
			playsound(get_turf(src), "sound/impact_sounds/Crystal_Hit_1.ogg", 100, 1)
			return 1

	set_up()
		if (!ispath(src.auto_type))
			return
		var/dirs = 0
		for (var/direction in cardinal)
			var/turf/T = get_step(src, direction)
			if (locate(src.auto_type) in T)
				dirs |= direction
		icon_state = num2text(dirs)

		if (src.glass_broken)
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

		var/obj/table/WT = locate(src.auto_type) in get_step(src, WEST)
		var/obj/table/ST = locate(src.auto_type) in get_step(src, SOUTH)
		var/obj/table/ET = locate(src.auto_type) in get_step(src, EAST)
		var/obj/table/NT = locate(src.auto_type) in get_step(src, NORTH)

		// west, south, and southwest
		if (WT && ST)
			var/obj/table/SWT = locate(src.auto_type) in get_step(src, SOUTHWEST)
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
			var/obj/table/SET = locate(src.auto_type) in get_step(src, SOUTHEAST)
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
			var/obj/table/NET = locate(src.auto_type) in get_step(src, NORTHEAST)
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
			var/obj/table/NWT = locate(src.auto_type) in get_step(src, NORTHWEST)
			if (NWT)
				working_image.icon_state = "[R]gNWs"
				src.UpdateOverlays(working_image, "NWcorner")
			else
				working_image.icon_state = "[R]gNW"
				src.UpdateOverlays(working_image, "NWcorner")
		else
			src.UpdateOverlays(null, "NWcorner")

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
			if (H.traitHolder.hasTrait("carpenter"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (the_table == null || the_tool == null || owner == null || get_dist(owner, the_table) > 1)
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
				playsound(get_turf(the_table), "sound/items/Screwdriver2.ogg", 50, 1)
				interrupt(INTERRUPT_ALWAYS)
				return

	onStart()
		..()
		var/verbing = "doing something to"
		switch (interaction)
			if (TABLE_DISASSEMBLE)
				verbing = "disassembling"
				playsound(get_turf(the_table), "sound/items/Ratchet.ogg", 50, 1)
			if (TABLE_WEAKEN)
				verbing = "weakening"
				playsound(get_turf(the_table), "sound/items/Welder.ogg", 50, 1)
			if (TABLE_STRENGTHEN)
				verbing = "strengthening"
				playsound(get_turf(the_table), "sound/items/Welder.ogg", 50, 1)
			if (TABLE_ADJUST)
				verbing = "adjusting the shape of"
				playsound(get_turf(the_table), "sound/items/Screwdriver.ogg", 50, 1)
			if (TABLE_LOCKPICK)
				verbing = "picking the lock on"
				playsound(get_turf(the_table), "sound/items/Screwdriver2.ogg", 50, 1)
		owner.visible_message("<span class='notice'>[owner] begins [verbing] [the_table].</span>")

	onEnd()
		..()
		var/verbens = "does something to"
		switch (interaction)
			if (TABLE_DISASSEMBLE)
				verbens = "disassembles"
				playsound(get_turf(the_table), "sound/items/Deconstruct.ogg", 50, 1)
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
				playsound(get_turf(the_table), "sound/items/Screwdriver2.ogg", 50, 1)
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
		if (the_table == null || owner == null || get_dist(owner, the_table) > 1)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_tool != source.equipped())
			interrupt(INTERRUPT_ALWAYS)
			return

	onStart()
		..()
		if (the_tool)
			playsound(get_turf(the_table), "sound/items/Ratchet.ogg", 50, 1)
		else
			playsound(get_turf(the_table), "sound/items/Screwdriver2.ogg", 50, 1)
		owner.visible_message("<span class='notice'>[owner] begins disassembling [the_table].</span>")

	onEnd()
		..()
		playsound(get_turf(the_table), "sound/items/Deconstruct.ogg", 50, 1)
		owner.visible_message("<span class='notice'>[owner] disassembles [the_table].</span>")
		the_table.deconstruct()
