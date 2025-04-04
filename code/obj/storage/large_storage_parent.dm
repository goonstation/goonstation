// crates/closets/etc.  this shoulda been combined a while ago, but here we are.

// NOTE:
// Unlike old closets/etc, these things make their contents in the make_my_stuff() proc.
// DO NOT OVERRIDE New() ON THESE OKAY
// PLEASE JUST MAKE A MESS OF make_my_stuff() INSTEAD
// CALL YOUR PARENTS

#define RELAYMOVE_DELAY 1 SECOND

ABSTRACT_TYPE(/obj/storage)
ADMIN_INTERACT_PROCS(/obj/storage, proc/open, proc/close)
/obj/storage
	name = "storage"
	desc = "this is a parent item you shouldn't see!!"
	flags = NOSPLASH | FLUID_SUBMERGE
	event_handler_flags = USE_FLUID_ENTER  | NO_MOUSEDROP_QOL
	icon = 'icons/obj/large_storage.dmi'
	icon_state = "closed"
	density = 1
	open_to_sound = TRUE
	throwforce = 10
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	p_class = 2.5
	layer = STORAGE_LAYER
	var/intact_frame = 1 //Variable to create crates and fridges which cannot be closed anymore.
	var/secure = 0
	var/personal = 0
	var/registered = null
	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/icon_welded = "welded-closet"
	var/open_sound = 'sound/machines/click.ogg'
	var/close_sound = 'sound/machines/click.ogg'
	var/volume = 15
	var/max_capacity = 100 //Won't close past this many items.
	var/open = 0
	var/welded = 0
	var/image/weld_image
	//Offsets for the weld icon, rather than make icons for every slightly off crate or closet
	var/weld_image_offset_X = 0 //Positive is right, negative is left
	var/weld_image_offset_Y = 0 //Positive is up, negative is down
	/// If the storage needs a crowbar to open it
	var/needs_prying = FALSE
	/// If the storage is pried open, prevents closing
	var/pried_open = FALSE
	var/locked = 0
	var/emagged = 0
	var/jiggled = 0
	var/legholes = 0
	var/can_leghole = TRUE
	var/flip_health = 3
	var/can_flip_bust = 0 // Can the trapped mob damage this container by flipping?
	var/obj/item/card/id/scan = null
	var/datum/db_record/account = null
	var/last_relaymove_time
	var/is_short = 0 // can you not stand in it?  ie, crates?
	var/crunches_contents = 0 // for the syndicate trashcart & hotdog stand
	var/crunches_deliciously = 0 // :I
	var/owner_ckey = null // owner of the crunchy cart, so they don't get crunched
	var/opening_anim = null
	var/closing_anim = null
	var/last_attackhand = 0

	var/list/spawn_contents = list() // maybe better than just a bunch of stuff in New()?
	var/made_stuff

	var/grab_stuff_on_spawn = TRUE

	///Controls items that are 'inside' the crate, even when it's open. These will be dragged around with the crate until removed.
	var/datum/vis_storage_controller/vis_controller

	New()
		..()
		START_TRACKING
		weld_image = image(src.icon, src.icon_welded)
		weld_image.pixel_x = weld_image_offset_X
		weld_image.pixel_y = weld_image_offset_Y
		SPAWN(1 DECI SECOND)
			src.UpdateIcon()

			if (!src.open && grab_stuff_on_spawn)		// if closed, any item at src's loc is put in the contents
				for (var/atom/movable/A in src.loc)
					if (!A.anchored && src.is_acceptable_content(A) && !isintangible(A) && !istype(A, /mob/dead))
						A.set_loc(src)

	disposing()
		if(src.vis_controller)
			qdel(src.vis_controller)
			src.vis_controller = null
		STOP_TRACKING
		..()

	proc/make_my_stuff() // use this rather than overriding the container's New()
		. = 1
		if (!islist(src.spawn_contents))
			return 0

		var/i = 1
		for (var/thing in src.spawn_contents)
			var/amt = 1
			if(!istext(thing)) //cannot use ispath for reasons BYOND comprehension
				if (isnum(spawn_contents[thing])) //Instead of duplicate entries in the list, let's make them associative
					amt = abs(spawn_contents[thing])
				do
					var/atom/A = new thing(src)
					A.layer += 0.00001 * i
					i++
				while (--amt > 0)
			else if (thing in reagents_cache)
				var/turf/T = get_turf(src)
				var/vol = 1
				if (isnum(spawn_contents[thing])) //Instead of duplicate entries in the list, let's make them associative
					vol = abs(spawn_contents[thing])
				T.fluid_react_single(thing, vol)

	proc/get_welding_positions()
		var/start
		var/stop
		var/start_x
		var/start_y
		var/stop_x
		var/stop_y

		switch(icon_welded)
			if("welded-crate")
				start_x = -11
				start_y = -4
				stop_x = 11
				stop_y = -4
			if("welded-short-horizontal")
				start_x = -8
				stop_x = 8
			if("welded-closet")
				start_x = 6
				stop_x = 6
				start_y = -15
				stop_y = 8
			if("welded-coffin-4dirs")
				if(dir == NORTH || dir == SOUTH)
					start_x = -4
					stop_x = 4
					start_y = -13
					stop_y = -13
				else if(dir == WEST)
					start_x = -12
					stop_x = 14
					start_y = -12
					stop_y = -12
				else
					start_x = -14
					stop_x = 12
					start_y = -12
					stop_y = -12
			if("welded-coffin-1dir")
				start_x = -4
				stop_x = 4
				start_y = -13
				stop_y = -13

		start = list(start_x + src.weld_image_offset_X, start_y + src.weld_image_offset_Y)
		stop = list(stop_x + src.weld_image_offset_X, stop_y + src.weld_image_offset_Y)

		if(welded)
			. = list(stop,start)
		else
			. = list(start,stop)

	Entered(atom/movable/Obj, OldLoc)
		. = ..()
		if(src.open || length(contents) > src.max_capacity)
			Obj.set_loc(get_turf(src))

	update_icon()

		if (src.open)
			FLICK(src.opening_anim,src)
			src.icon_state = src.icon_opened
		else if (!src.open)
			FLICK(src.closing_anim,src)
			src.icon_state = src.icon_closed

		if (src.welded)
			src.UpdateOverlays(weld_image, "welded")
		else
			src.UpdateOverlays(null, "welded")

	emp_act()
		if (!src.open && length(src.contents))
			for (var/atom/A in src.contents)
				if (ismob(A))
					var/mob/M = A
					M.emp_act()
				if (isitem(A))
					var/obj/item/I = A
					I.emp_act()

	alter_health()
		. = get_turf(src)

	get_desc()
		. = ..()
		if (src.needs_prying && !src.open)
			. += " Its shut tightly."
		else if (src.pried_open)
			. += " The door has been pried open, it won't close anymore."

	Click(location, control, params)
		// lets you open when inside of it
		if((usr in src) && can_act(usr))
			src.Attackhand(usr)
			return
		. = ..()

	relaymove(mob/user as mob)
		if (is_incapacitated(user))
			return
		if (world.time < (src.last_relaymove_time + RELAYMOVE_DELAY))
			return
		src.last_relaymove_time = world.time

		if (istype(get_turf(src), /turf/space) || !get_turf(src))
			if (!istype(get_turf(src), /turf/space/fluid))
				return

		if (src.legholes)
			if (!src.anchored)
				step(src,user.dir)
				return
			else
				user.show_text("You try moving, but [src] seems to be stuck to the floor!", "red")
				return

		if (!src.open(user=user))
			if (!src.is_short && src.legholes)
				if (!src.anchored)
					step(src, pick(alldirs))
				else
					user.show_text("You try moving, but [src] seems to be stuck to the floor!", "red")
			if (!src.jiggled)
				src.jiggled = 1
				user.show_text("You kick at [src], but it doesn't budge!", "red")
				user.unlock_medal("IT'S A TRAP", 1)
				for (var/mob/M in hearers(src, null))
					M.show_text("<font size=[max(0, 5 - GET_DIST(src, M))]>THUD, thud!</font>", group = "storage_thud")
				playsound(src, 'sound/impact_sounds/Wood_Hit_1.ogg', 15, TRUE, -3)
				var/shakes = 5
				while (shakes > 0)
					shakes--
					src.pixel_x = rand(-5,5)
					src.pixel_y = rand(-5,5)
					sleep(0.1 SECONDS)
				src.pixel_x = 0
				src.pixel_y = 0
				SPAWN(0.5 SECONDS)
					src.jiggled = 0

			if (prob(10) && src.can_flip_bust)
				user.show_text(SPAN_ALERT("[src] [pick("cracks","bends","shakes","groans")]."))
				src.bust_out()

			return

		// if all else fails:
		src.open(user=user)
		src.visible_message(SPAN_ALERT("<b>[user]</b> kicks [src] open!"))

	attack_hand(mob/user)
		if(world.time == src.last_attackhand) // prevent double-attackhand when entering
			return
		if (!in_interact_range(src, user))
			return
		src.last_attackhand = world.time

		interact_particle(user,src)
		add_fingerprint(user)
		if (src.welded)
			user.show_text("It won't open!", "red")
			return
		else if (!src.toggle(user))
			return src.Attackby(null, user)

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/satchel))
			if(src.secure && src.locked)
				user.show_text("Access Denied", "red")
				return
			if (count_turf_items() >= max_capacity || length(contents) >= max_capacity)
				user.show_text("[src] cannot fit any more items!", "red")
				return
			var/amt = length(I.contents)
			if (amt)
				user.visible_message(SPAN_NOTICE("[user] dumps out [I]'s contents into [src]!"))
				var/amtload = 0
				for (var/obj/item/C in I.contents)
					if(length(contents) >= max_capacity)
						break
					if (open)
						C.set_loc(src.loc)
					else
						C.set_loc(src)
					amtload++
				I:UpdateIcon()
				if (amtload)
					user.show_text("[amtload] [I:itemstring] dumped into [src]!", "blue")
				else
					user.show_text("No [I:itemstring] dumped!", "red")
				return

		if (src.open)
			if (isweldingtool(I))
				var/obj/item/weldingtool/weldingtool = I
				if(weldingtool.welding)
					if (src._health <= 0 && !src.pried_open)
						if(!weldingtool.try_weld(user, 1, burn_eyes = TRUE))
							return
						src._health = src._max_health
						src.visible_message(SPAN_ALERT("[user] repairs [src] with [I]."))
					else if (!src.is_short && !src.legholes)
						if (!src.can_leghole)
							boutput(user, SPAN_ALERT("You can't cut holes in that!"))
							return
						if (!weldingtool.try_weld(user, 1))
							return
						src.legholes = 1
						src.visible_message(SPAN_ALERT("[user] adds some holes to the bottom of [src] with [I]."))
					return
				if(!issilicon(user))
					if(user.drop_item())
						weldingtool?.set_loc(src.loc)
					return

			else if (iswrenchingtool(I))
				actions.start(new /datum/action/bar/icon/storage_disassemble(src, I), user)
				return
			else if (!issilicon(user))
				if (istype(I, /obj/item/grab))
					return src.MouseDrop_T(I:affecting, user)	//act like they were dragged onto the closet
				if(user.drop_item())
					if(I)
						I.set_loc(src.loc)
				return

		else if (!src.open)
			if (isweldingtool(I))
				if (!I:try_weld(user, 1, burn_eyes = TRUE))
					return
				var/positions = src.get_welding_positions()
				actions.start(new /datum/action/bar/private/welding(user, src, 2 SECONDS, /obj/storage/proc/weld_action, \
					list(I, user), null, positions[1], positions[2]),user)
				return
			else if (ispryingtool(I) && src.needs_prying)
				SETUP_GENERIC_PRIVATE_ACTIONBAR(user, src, 1 SECOND, /obj/storage/proc/pry_open, user, I.icon, I.icon_state,\
				"[user] pries open \the [src]", INTERRUPT_ACTION | INTERRUPT_STUNNED)

		if (src.secure)
			if (src.emagged)
				user.show_text("It appears to be broken.", "red")
				return
			else if (src.personal)
				var/obj/item/card/id/ID = get_id_card(I)
				if (!istype(ID))
					if (ishuman(user))
						var/mob/living/carbon/human/H = user
						if (H.wear_id)
							ID = H.wear_id
				if ((src.req_access && src.allowed(user)) || (ID && length(ID.registered) && (src.registered == ID.registered || !src.registered)))
					//they can open all lockers, or nobody owns this, or they own this locker
					src.locked = !( src.locked )
					user.visible_message(SPAN_NOTICE("The locker has been [src.locked ? null : "un"]locked by [user]."))
					src.UpdateIcon()
					if (!src.registered)
						src.registered = ID.registered
						src.name = "[ID.registered]'s [src.name]"
						src.desc = "Owned by [ID.registered]."
					for (var/mob/M in src.contents)
						src.log_me(user, M, src.locked ? "locks" : "unlocks")
					return
			else if (!src.personal && src.allowed(user))
				if (!src.open)
					src.locked = !src.locked
					user.visible_message(SPAN_NOTICE("[src] has been [src.locked ? null : "un"]locked by [user]."))
					src.UpdateIcon()
					for (var/mob/M in src.contents)
						src.log_me(user, M, src.locked ? "locks" : "unlocks")
					return
				else
					src.close()
					return

			if (secure != 2)
				if (!src.locked)
					src.open()
				else
					user.show_text("Access Denied", "red")
			user.unlock_medal("Rookie Thief", 1)
			return

		else
			return ..()

	onMaterialChanged()
		. = ..()
		if(isnull(src.material))
			return
		var/found_negative = (src.material.getID() == "negativematter")
		if(!found_negative)
			for(var/datum/material/parent_mat in src.material.getParentMaterials())
				if(parent_mat.getID() == "negativematter")
					found_negative = TRUE
					break
		if(found_negative)
			src.AddComponent(/datum/component/extradimensional_storage/storage)

	proc/pry_open(var/mob/user)
		playsound(src, 'sound/items/Crowbar.ogg', 60, 1)
		src.pried_open = TRUE
		src.locked = FALSE
		src.open = TRUE
		src.dump_direct_contents(user)
		src.UpdateIcon()
		p_class = initial(p_class)

	proc/weld_action(obj/item/W, mob/user)
		if(src.open)
			return
		if (!src.welded)
			src.weld(1, user)
			src.visible_message(SPAN_ALERT("[user] welds [src] closed with [W]."))
		else
			src.weld(0, user)
			src.visible_message(SPAN_ALERT("[user] unwelds [src] with [W]."))

	proc/check_if_enterable(var/atom/movable/thing, var/skip_penalty=0)
		//return 1 if an atom can enter, 0 if not (this is used for scooting over crates and dragging things into crates)
		var/mob/living/L = thing
		if(istype(L) && L.buckled)
			return FALSE
		var/turf/dest_turf = get_turf(src)
		var/turf/orig_turf = get_turf(thing)
		if (orig_turf == dest_turf) return TRUE
		var/no_go

		//Mostly copy pasted from turf/Enter. Sucks, but we need an object rather than a boolean
		//First, check for directional blockers on the entering object's tile
		for(var/obj/obstacle in orig_turf)
			if(obstacle == thing)
				continue
			if(!obstacle.CheckExit(thing, dest_turf))
				no_go = obstacle
				break

		//next, check if the turf itself prevents something from entering it (i.e. it's a wall)
		if (isnull(no_go))
			no_go = !dest_turf.Enter(L) ? dest_turf : null

		//finally, check if there's anything else on the turf that would prevent us from entering it (e.g. dense objects)
		if(isnull(no_go))
			for(var/atom/A in dest_turf)
				if(A != src && !A.Cross(L))
					no_go = A
					break

		if(no_go)
			if (istype(L))
				L.show_text("You bump into \the [no_go] as you try to scoot over \the [src].", "red")
			thing.Bump(no_go)
			. = FALSE
		else
			. = TRUE

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		var/turf/T = get_turf(src)
		if (!in_interact_range(user, src) || !in_interact_range(user, O) || user.restrained() || user.getStatusDuration("unconscious") || user.sleeping || user.stat || user.lying || isAI(user))
			return

		if (!src.is_acceptable_content(O))
			return

		if (isitem(O) && (O:cant_drop || (issilicon(user) && O.loc == user))) //For borg held items
			boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
			return

		src.add_fingerprint(user)

		if (src.is_short && O == user)
			if(!check_if_enterable(user))
				return

			if (iscarbon(O))
				var/mob/living/carbon/M = user
				if (M.bioHolder && M.bioHolder.HasEffect("clumsy") && prob(40))
					user.visible_message(SPAN_ALERT("<b>[user]</b> trips over [src]!"),\
					SPAN_ALERT("You trip over [src]!"))
					playsound(user.loc, 'sound/impact_sounds/Generic_Hit_2.ogg', 15, 1, -3)
					user.set_loc(T)
					if (!user.hasStatus("knockdown"))
						user.changeStatus("knockdown", 10 SECONDS)
					JOB_XP(user, "Clown", 3)
					return
				else
					user.show_text("You scoot around [src].")
					user.set_loc(T)
					return
			if (issilicon(O))
				user.show_text("You scoot around [src].")
				user.set_loc(T)
				return

		if (src.locked)
			user.show_text("You'll have to unlock [src] first.", "red")
			return

		if (src.welded)
			user.show_text("[src] is welded shut!", "red")
			return

		if (!src.open)
			src.open(user=user)

		if (count_turf_items() >= max_capacity)
			user.show_text("[src] is too full!", "red")
			return

		if (O.loc == user)
			var/obj/item/I = O
			if(istype(I) && I.cant_drop)
				return
			if(istype(I) && I.equipped_in_slot && I.cant_self_remove)
				return
			user.u_equip(O)
			O.set_loc(get_turf(user))

		else if(istype(O, /obj/item))
			var/obj/item/I = O
			I.stored?.transfer_stored_item(I, get_turf(I), user = user)

		SPAWN(0.5 SECONDS)
			var/stuffed = FALSE
			var/list/draggable_types = list(
				/obj/item/plant = "produce",
				/obj/item/reagent_containers/food/snacks = "food",
				/obj/item/casing = "ammo casings",
				/obj/item/raw_material = "materials",
				/obj/item/material_piece = "processed materials",
				/obj/item/paper = "paper",
				/obj/item/tile = "floor tiles",
				/obj/item/reagent_containers/food/fish = "fish")
			for(var/drag_type in draggable_types)
				if(!istype(O, drag_type))
					continue
				stuffed = TRUE
				var/type_name = draggable_types[drag_type]
				user.visible_message(SPAN_NOTICE("[user] begins quickly stuffing [type_name] into [src]!"),\
				SPAN_NOTICE("You begin quickly stuffing [type_name] into [src]!"))
				var/staystill = user.loc
				for (var/obj/thing in view(1,user))
					if(!istype(thing, drag_type))
						continue
					if (QDELETED(thing))
						continue
					if (thing.anchored)
						continue
					if (thing in user)
						continue
					if (!check_if_enterable(thing))
						continue
					if (thing.loc == src || thing.loc == src.loc) // we're already there!
						continue
					thing.set_loc(T)
					SEND_SIGNAL(thing,COMSIG_ATTACKHAND,user) //triggers radiation/explsion/glue stuff
					sleep(0.5)
					if (!src.open)
						break
					if (user.loc != staystill)
						break
					if (length(T.contents) >= max_capacity)
						break
				user.show_text("You finish stuffing [type_name] into [src]!", "blue")
				SPAWN(0.5 SECONDS)
					if (src.open)
						src.close()
			if(!stuffed)
				if(check_if_enterable(O) && in_interact_range(user, src) && in_interact_range(user, O))
					O.set_loc(T)
					if (user != O)
						user.visible_message(SPAN_ALERT("[user] stuffs [O] into [src]!"),\
						SPAN_ALERT("You stuff [O] into [src]!"))
					SPAWN(0.5 SECONDS)
						if (src.open)
							src.close()
		return ..()

	attack_ai(mob/user)
		if (can_reach(user, src) <= 1 && (isrobot(user) || isshell(user)))
			. = src.Attackhand(user)

	alter_health()
		. = get_turf(src)

	ex_act(severity)
		switch (severity)
			if (1)
				dump_contents()
				qdel(src)
			if (2)
				if (prob(50))
					dump_contents()
					qdel(src)
			if (3)
				if (prob(5))
					dump_contents()
					qdel(src)

	blob_act(var/power)
		if (prob(power * 2.5))
			dump_contents()
			qdel(src)

	meteorhit(obj/O as obj)
		if(istype(O,/obj/newmeteor/))
			if(O.icon_state == "flaming")
				src.dump_contents()
				qdel(src)
		else
			src.dump_contents()
			qdel(src)
		return

	proc/is_acceptable_content(var/atom/A)
		. = TRUE
		if (!A || !(isobj(A) || ismob(A)))
			return 0
		if (istype(A, /obj/fakeobject/skeleton)) // uuuuuuugh
			return 1
		if (isobj(A) && ((A.density && !istype(A, /obj/critter)) || A:anchored || A == src || istype(A, /obj/decal) || istype(A, /atom/movable/screen) || istype(A, /obj/storage) || istype(A, /obj/tug_cart)))
			return 0

	var/obj/storage/entangled
	proc/open(var/entangleLogic, var/mob/user)
		if (src.open)
			return 0
		if (!src.can_open())
			return 0
		else
			FLICK(src.opening_anim,src)

		if(entangled && !entangleLogic && !entangled.can_close())
			visible_message(SPAN_ALERT("It won't budge!"))
			return 0

		if(entangled && !entangleLogic)
			entangled.entangled = src
			entangled.close(1)
			for(var/atom/movable/AM in entangled)
				AM.set_loc(src.open ? src.loc : src)

		if (user)
			src.dump_direct_contents(user)
		else
			src.dump_direct_contents()
		if (!is_short)
			src.set_density(0)
		src.open = 1
		src.UpdateIcon()
		p_class = initial(p_class)
		playsound(src.loc, src.open_sound, volume, 1, -3)
		return 1

	proc/close(var/entangleLogic)
		FLICK(src.closing_anim,src)
		if (!src.open)
			return 0
		if (src._health <= 0)
			visible_message(SPAN_ALERT("[src] can't close; it's been smashed open!"))
			return 0
		if (src.pried_open)
			visible_message(SPAN_ALERT("[src] can't close; the prying broke its hinges!"))
			return 0
		if (!src.can_close())
			visible_message(SPAN_ALERT("[src] can't close; looks like it's too full!"))
			return 0
		if (!src.intact_frame())
			visible_message(SPAN_ALERT("[src] can't close; the door is completely bend out of shape!"))
			return 0

		if(entangled && !entangleLogic && !entangled.can_open())
			visible_message(SPAN_ALERT("It won't budge!"))
			return 0
		if (!is_short)
			src.set_density(1)
		src.open = 0

		for (var/obj/O in get_turf(src))
			if (src.is_acceptable_content(O))
				O.set_loc(src)
		vis_controller?.hide()

		for (var/mob/M in get_turf(src))
			if (isobserver(M) || iswraith(M) || isintangible(M) || islivingobject(M))
				continue
			if (M.anchored || M.buckled)
				continue
			if (src.is_short && (M != src.loc) && !isdead(M))
				if (!M.lying)
					step_away(M, src, 1)
					continue
#ifdef HALLOWEEN
			if (halloween_mode && prob(5)) //remove the prob() if you want, it's just a little broken if dudes are constantly teleporting
				var/list/obj/storage/myPals = list()
				for_by_tcl(O, /obj/storage)
					if (O.z != src.z || O.open || !O.can_open() || isrestrictedz(O.z))
						continue
					myPals.Add(O)

				var/obj/storage/warp_dest = pick(myPals)
				M.set_loc(warp_dest)
				M.show_text("You are suddenly thrown elsewhere!", "red")
				M.playsound_local(M.loc, "warp", 50, 1)
				continue
#endif
			if (src.crunches_contents)
				src.crunch(M)
			M.set_loc(src)

		recalcPClass()

		if(entangled && !entangleLogic)
			entangled.entangled = src
			for(var/atom/movable/AM in src)
				AM.set_loc(entangled.open ? entangled.loc : entangled)
			entangled.open(1)

		src.UpdateIcon()
		playsound(src.loc, src.close_sound, volume, 1, -3)
		SEND_SIGNAL(src, COMSIG_OBJ_STORAGE_CLOSED)
		return 1

	proc/recalcPClass()
		var/maxPClass = 0
		for (var/atom/movable/O in contents)
			if (ishuman(O)) // can't use p_class for human mobs as we need to use the heavier one regardless of whether they're standing/lying down
				maxPClass = max(maxPClass, 3) //horay magic number
			else
				maxPClass = max(maxPClass, O.p_class)
		p_class = initial(p_class) + maxPClass

	proc/can_open()
		. = TRUE
		if (src.welded || src.locked || src.needs_prying)
			return 0

	proc/count_turf_items()
		var/turf/T = get_turf(src)
		var/crate_contents = length(T.contents)
		for(var/obj/O in T.contents)
			if(!isitem(O) || O == src || O.anchored)
				crate_contents--
			if(O.cannot_be_stored)
				crate_contents = INFINITY //too big to fit on the locker, it wont close
		return crate_contents

	proc/can_close()
		. = TRUE
		var/turf/T = get_turf(src)
		if (!T) return 0
		if (count_turf_items() > max_capacity)
			return 0
		for (var/obj/storage/S in T)
			if (S != src)
				return 0

	proc/intact_frame()
		. = TRUE
		if (!src.intact_frame)
			return 0

	proc/dump_direct_contents(mob/user)
		if(src.spawn_contents && make_my_stuff()) //Make the stuff when the locker is first opened.
			spawn_contents = null

		var/newloc = get_turf(src)
		vis_controller?.show()
		for (var/obj/O in src)
			if (!(O in vis_controller?.vis_items))
				O.set_loc(newloc)
			if(istype(O,/obj/item/mousetrap))
				var/obj/item/mousetrap/our_trap = O
				if(our_trap.armed && user)
					INVOKE_ASYNC(our_trap, TYPE_PROC_REF(/obj/item/mousetrap, triggered), user)

		for (var/mob/M in src)
			M.set_loc(newloc)

	proc/dump_vis_contents()
		if (src.vis_controller && length(src.vis_controller.vis_items))
			for (var/atom/movable/AM in src.vis_controller.vis_items)
				AM.set_loc(src.loc)
			src.vis_controller.vis_items = list()

	proc/dump_contents(mob/user)
		src.dump_direct_contents(user)
		src.dump_vis_contents()

	proc/toggle(var/mob/user)
		if (src.open)
			return src.close()
		return src.open(user=user)

	proc/unlock()
		if (src.locked)
			src.locked = FALSE
			src.visible_message("[src] clicks[src.open ? "" : " unlocked"].")
			src.UpdateIcon()

	//why is everything defined on the parent type aa
	proc/lock()
		if (!src.locked)
			src.locked = TRUE
			src.visible_message("[src] clicks[src.open ? "" : " locked"].")
			src.UpdateIcon()

	proc/bust_out()
		if (src.flip_health)
			src.visible_message(SPAN_ALERT("[src] [pick("cracks","bends","shakes","groans")]."))
			src.flip_health--
		if (src.flip_health <= 0)
			src.visible_message(SPAN_ALERT("[src] breaks apart!"))
			src.dump_contents()
			SPAWN(1 DECI SECOND)
				var/newloc = get_turf(src)
				make_cleanable( /obj/decal/cleanable/machine_debris,newloc)
				qdel(src)

	proc/weld(var/shut = 0, var/mob/weldman as mob)
		if (shut)
			weldman.visible_message(SPAN_ALERT("[weldman] welds [src] shut."))
			src.welded = 1
		else
			weldman.visible_message(SPAN_ALERT("[weldman] unwelds [src].")) // walt-fuck_you.ogg
			src.welded = 0
		src.UpdateIcon()
		for (var/mob/M in src.contents)
			src.log_me(weldman, M, src.welded ? "welds" : "unwelds")

	proc/crunch(var/mob/M as mob)
		if (!M)
			return

		if (M.ckey && (M.ckey == owner_ckey))
			return
		src.locked = TRUE
		M.show_text("Is it getting... smaller in here?", "red")
		SPAWN(5 SECONDS)
			if (M in src.contents)
				playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 75, 1)
				M.show_text("<b>OH JESUS CHRIST</b>", "red")
				bleed(M, 500, 5)
				src.log_me(usr && ismob(usr) ? usr : null, M, "uses trash compactor")
				var/mob/living/carbon/cube/meatcube = M.make_cube(null, rand(10,15), get_turf(src))
				if (src.crunches_deliciously)
					meatcube.name = "hotdog"
					var/obj/item/reagent_containers/food/snacks/hotdog/syndicate/snoopdog = new /obj/item/reagent_containers/food/snacks/hotdog/syndicate(src)
					snoopdog.victim = meatcube

				for (var/obj/item/I in M)
					if (istype(I, /obj/item/implant))
						I.set_loc(meatcube)
					else
						I.set_loc(src)

			src.locked = FALSE

	// Added (Convair880).
	proc/log_me(var/mob/user, var/mob/occupant, var/action = "")
		if (!src || !occupant || !ismob(occupant) || !action)
			return

		logTheThing(LOG_STATION, user, "[action] [src] with [constructTarget(occupant,"station")] inside at [log_loc(src)].")
		return

	verb/toggle_verb()
		set src in oview(1)
		set name = "Open / Close"
		set desc = "Open or close the closet/crate/whatever. Woah!"
		set category = "Local"

		if (usr.stat || !usr.can_use_hands() || isAI(usr) || !can_reach(usr, src))
			return

		return toggle()

	verb/move_inside()
		set src in oview(1)
		set name = "Move Inside"
		set desc = "Enter the closet/crate/whatever. Wow!"
		set category = "Local"

		if (usr.stat || !usr.can_use_hands() || usr.loc == src || isAI(usr))
			return

		if (src.locked)
			return

		if (src.open)
			usr.step_towards_movedelay(src)
			sleep(1 SECOND)
			if (usr.loc == src.loc)
				if (src.is_short)
					usr.lying = 1
				src.close()
		else if (src.open(user=usr))
			usr.step_towards_movedelay(src)
			sleep(1 SECOND)
			if (usr.loc == src.loc)
				if (src.is_short)
					usr.lying = 1
				src.close()
		return

	mob_flip_inside(var/mob/user)
		..(user)
		if (prob(33) && src.can_flip_bust)
			user.show_text(SPAN_ALERT("[src] [pick("cracks","bends","shakes","groans")]."))
			src.bust_out()

/datum/action/bar/icon/storage_disassemble
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	duration = 20
	icon = 'icons/obj/items/tools/wrench.dmi'
	icon_state = "wrench"

	var/obj/storage/the_storage
	var/obj/item/wrench/the_wrench

	New(var/obj/storage/S, var/obj/item/wrench/W, var/duration_i)
		..()
		if (S)
			the_storage = S
		if (W)
			the_wrench = W
			icon = the_wrench.icon
			icon_state = the_wrench.icon_state
		if (duration_i)
			duration = duration_i
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if (H.traitHolder.hasTrait("carpenter") || H.traitHolder.hasTrait("training_engineer"))
				duration = round(duration / 2)

	onUpdate()
		..()
		if (!the_storage || !the_wrench || !owner || BOUNDS_DIST(owner, the_storage) > 0)
			interrupt(INTERRUPT_ALWAYS)
			return
		var/mob/source = owner
		if (istype(source) && the_wrench != source.equipped())
			interrupt(INTERRUPT_ALWAYS)

	onStart()
		..()
		playsound(the_storage, 'sound/items/Ratchet.ogg', 50, TRUE)
		owner.visible_message(SPAN_NOTICE("[owner] begins taking apart [the_storage]."))

	onEnd()
		..()
		playsound(the_storage, 'sound/items/Deconstruct.ogg', 50, TRUE)
		owner.visible_message(SPAN_NOTICE("[owner] takes apart [the_storage]."))
		the_storage.dump_contents(owner)
		var/obj/item/I = new /obj/item/sheet(get_turf(the_storage))
		if (the_storage.material)
			I.setMaterial(the_storage.material)
		else
			var/datum/material/M = getMaterial("steel")
			I.setMaterial(M)
		qdel(the_storage)

//this is written out manually because the linter got very angry when I tried to use .. in the macro version
TYPEINFO(/obj/storage/secure)
TYPEINFO_NEW(/obj/storage/secure)
	. = ..()
	admin_procs += list(/obj/storage/proc/lock, /obj/storage/proc/unlock)
/obj/storage/secure
	name = "secure storage"
	icon_state = "secure"
	flip_health = 6
	secure = 1
	locked = 1
	icon_closed = "secure"
	icon_opened = "secure-open"
	var/icon_greenlight = "greenlight"
	var/icon_redlight = "redlight"
	var/icon_sparks = "sparks"
	var/always_display_locks = 0
	var/radio_control = FREQ_SECURE_STORAGE
	var/net_id

	New()
		..()
		if (isnum(src.radio_control))
			radio_control = clamp(round(radio_control), 1000, 1500)
			src.net_id = generate_net_id(src)
			MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, null, radio_control)

	update_icon()
		..()
		if (!src.open)
			src.icon_state = src.icon_closed

		if(!src.open || always_display_locks)
			if (src.emagged)
				src.UpdateOverlays(image(src.icon, src.icon_sparks), "sparks")
			else if (src.locked)
				src.UpdateOverlays(image(src.icon, src.icon_redlight), "light")
			else
				src.UpdateOverlays(image(src.icon, src.icon_greenlight), "light")
		else
			src.UpdateOverlays(null, "sparks")
			src.UpdateOverlays(null, "light")

	receive_signal(datum/signal/signal)
		if (!src.radio_control)
			return

		var/sender = signal.data["sender"]
		if (!signal || signal.encryption || !sender)
			return

		if (signal.data["address_1"] == src.net_id)
			var/datum/signal/reply = get_free_signal()
			reply.source = src
			reply.data["sender"] = src.net_id
			reply.data["address_1"] = sender
			switch (lowertext(signal.data["command"]))
				if ("help")
					if (!signal.data["topic"])
						reply.data["description"] = "Secure Storage"
						reply.data["topics"] = "status,lock,unlock"
					else
						reply.data["topic"] = signal.data["topic"]
						switch (lowertext(signal.data["topic"]))
							if ("status")
								reply.data["description"] = "Returns the status of the secure storage. No arguments"
							if ("lock")
								reply.data["description"] = "Locks the secure storage. Requires NETPASS_SECURITY"
								reply.data["args"] = "pass"
							if ("unlock")
								reply.data["description"] = "Unlocks the secure storage. Requires NETPASS_SECURITY"
								reply.data["args"] = "pass"
							else
								reply.data["description"] = "ERROR: UNKNOWN TOPIC"
				if ("status")
					reply.data["command"] = "lock=[locked]&open=[open]"
				if ("lock")
					. = 0
					if (signal.data["pass"] == netpass_security)
						. = 1
						src.lock()
					if (.)
						reply.data["command"] = "ack"
					else
						reply.data["command"] = "nack"
						reply.data["data"] = "badpass"
				if ("unlock")
					. = 0
					if (signal.data["pass"] == netpass_security)
						. = 1
						src.unlock()
					if (.)
						reply.data["command"] = "ack"
					else
						reply.data["command"] = "nack"
						reply.data["data"] = "badpass"
				else
					return //COMMAND NOT RECOGNIZED
			SPAWN(0.5 SECONDS)
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, reply, 2)

		else if (signal.data["address_1"] == "ping")
			var/datum/signal/reply = get_free_signal()
			reply.source = src
			reply.data["address_1"] = sender
			reply.data["command"] = "ping_reply"
			reply.data["device"] = "WNET_SECLOCKER"
			reply.data["netid"] = src.net_id
			SPAWN(0.5 SECONDS)
				SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, reply, 2)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged) // secure crates checked for being locked/welded but so long as you aren't telling the thing to open I don't see why that was needed
			src.emagged = 1
			src.locked = 0
			src.UpdateIcon()
			playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
			if (user)
				user.show_text("You short out the lock on [src].", "blue")
			return 1
		return 0

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		else if (src.emagged)
			src.emagged = 0
			src.UpdateIcon()
			if (user)
				user.show_text("You repair the lock on [src].", "blue")
			return 1

#undef RELAYMOVE_DELAY

