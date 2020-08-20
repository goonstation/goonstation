#define DESERIALIZE_ERROR 0
#define DESERIALIZE_OK 1
#define DESERIALIZE_NEED_POSTPROCESS 2
#define DESERIALIZE_NOT_IMPLEMENTED 4

/datum/sandbox
	var/list/context = list()

/proc/icon_serializer(var/savefile/F, var/path, var/datum/sandbox/sandbox, var/icon, var/icon_state)
	var/iname = "[icon]"
	F["[path].icon"] << iname
	F["[path].icon_state"] << icon_state
	if (!("icon" in sandbox.context))
		sandbox.context += "icon"
		sandbox.context["icon"] = list()
	if (!(iname in sandbox.context["icon"]))
		sandbox.context["icon"] += iname
		sandbox.context["icon"][iname] = icon
		F["ICONS.[iname]"] << icon

/datum/iconDeserializerData
	var/icon/icon
	var/icon_state

/proc/icon_deserializer(var/savefile/F, var/path, var/datum/sandbox/sandbox, var/defaultIcon, var/defaultState)
	var/iname
	var/datum/iconDeserializerData/IDS = new()
	IDS.icon = defaultIcon
	IDS.icon_state = defaultState
	F["[path].icon"] >> iname
	if (!fexists(iname))
		if ("[defaultIcon]" == iname) // fuck off byond fuck you
			F["[path].icon_state"] >> IDS.icon_state
		else
			if (!("icon_failures" in sandbox.context))
				sandbox.context += "icon_failures"
				sandbox.context["icon_failures"] = list("total" = 0)
			if (!(iname in sandbox.context["icon_failures"]))
				sandbox.context["icon_failures"] += iname
				sandbox.context["icon_failures"][iname] = 0
			sandbox.context["icon_failures"]["total"]++
			sandbox.context["icon_failures"][iname]++

			F["ICONS.[iname]"] >> IDS.icon
			if (!IDS.icon && usr)
				boutput(usr, "<span class='alert'>Fatal error: Saved copy of icon [iname] cannot be loaded. Local loading failed. Falling back to default icon.</span>")
			else if (IDS.icon)
				F["[path].icon_state"] >> IDS.icon_state
	else
		IDS.icon = icon(file(iname))
		F["[path].icon_state"] >> IDS.icon_state
	return IDS

/proc/matrix_serializer(var/savefile/F, var/path, var/datum/sandbox/sandbox, var/name, var/matrix/mx)
	var/base = "[path].[name]"
	F["[base].a"] << mx.a
	F["[base].b"] << mx.b
	F["[base].c"] << mx.c
	F["[base].d"] << mx.d
	F["[base].e"] << mx.e
	F["[base].f"] << mx.f

/proc/matrix_deserializer(var/savefile/F, var/path, var/datum/sandbox/sandbox, var/name, var/matrix/defMx = matrix())
	var/a
	var/b
	var/c
	var/d
	var/e
	var/f

	var/base = "[path].[name]"
	F["[base].a"] >> a
	if (!a)
		return defMx
	F["[base].d"] >> d
	if (!d)
		return defMx
	F["[base].b"] >> b
	F["[base].c"] >> c
	F["[base].e"] >> e
	F["[base].f"] >> f
	return new /matrix(a,b,c,d,e,f)

/**
  * The base type for nearly all physical objects in SS13
	*
  * Lots of functionality resides in this type.
  */
/atom
	layer = TURF_LAYER
	plane = PLANE_DEFAULT
	var/level = 2
	var/flags = FPRINT
	var/event_handler_flags = 0
	var/tmp/temp_flags = 0
	var/tmp/last_bumped = 0
	var/shrunk = 0

	/// Override for the texture size used by setTexture.
	var/texture_size = 0

	/// If hear_talk is triggered on this object, make my contents hear_talk as well
	var/open_to_sound = 0

	var/interesting = ""
	var/stops_space_move = 0

	/// Gets the atoms name with all the ugly prefixes things remove
	proc/clean_name()
		return strip_special(name)

	/// clean_name(), but encoded too since everything ever uses HTML in the game.
	proc/safe_name()
		return html_encode(strip_special(name))

	proc/RawClick(location,control,params)
		return

/* -------------------- name stuff -------------------- */
	/*
	to change names: either add or remove something with the appropriate proc(s) and then call atom.UpdateName()

	to add to names: call atom.name_prefix(text_to_add) or thing.name_suffix(text_to_add) depending on where you want it
		text_to_add will run strip_html() on the text, which also limits the text to MAX_MESSAGE_LEN

	to remove from names: call atom.remove_prefixes(num) or atom.remove_suffixes(num)
		num can be either a number (obviously) OR text (I had already named the var okay)
		if num is a number it'll remove that many things from the total amount of pre/suffixes, starting from the earliest one
		if num is text, it'll remove that specific text from the list, once
	*/


	var/list/name_prefixes = null// = list()
	var/list/name_suffixes = null// = list()
	var/num_allowed_prefixes = 10
	var/num_allowed_suffixes = 5
	var/image/worn_material_texture_image = null

	proc/name_prefix(var/text_to_add, var/return_prefixes = 0)
		if( !name_prefixes ) name_prefixes = list()
		var/prefix = ""
		if (istext(text_to_add) && length(text_to_add) && islist(src.name_prefixes))
			if (src.name_prefixes.len >= src.num_allowed_prefixes)
				src.remove_prefixes(1)
			src.name_prefixes += strip_html(text_to_add)
		if (return_prefixes)
			var/amt_prefixes = 0
			for (var/i in src.name_prefixes)
				if (amt_prefixes >= src.num_allowed_prefixes)
					prefix += " "
					break
				prefix += i + " "
				amt_prefixes ++
			return prefix

	proc/name_suffix(var/text_to_add, var/return_suffixes = 0)
		if( !name_suffixes ) name_suffixes = list()
		var/suffix = ""
		if (istext(text_to_add) && length(text_to_add) && islist(src.name_suffixes))
			if (src.name_suffixes.len >= src.num_allowed_suffixes)
				src.remove_suffixes(1)
			src.name_suffixes += strip_html(text_to_add)
		if (return_suffixes)
			var/amt_suffixes = 0
			for (var/i in src.name_suffixes)
				if (amt_suffixes >= src.num_allowed_suffixes)
					break
				suffix += " " + i
				amt_suffixes ++
			return suffix

	proc/remove_prefixes(var/num = 1)
		if (!num || !name_prefixes)
			return
		if (istext(num)) // :v
			src.name_prefixes -= num
			return
		if (islist(src.name_prefixes) && src.name_prefixes.len)
			for (var/i in src.name_prefixes)
				if (num <= 0 || !src.name_prefixes.len)
					return
				src.name_prefixes -= i
				num --

	proc/remove_suffixes(var/num = 1)
		if (!num || !name_suffixes)
			return
		if (istext(num))
			src.name_suffixes -= num
			return
		if (islist(src.name_suffixes) && src.name_suffixes.len)
			for (var/i in src.name_suffixes)
				if (num <= 0 || !src.name_suffixes.len)
					return
				src.name_suffixes -= i
				num --

	proc/UpdateName()
		src.name = "[name_prefix(null, 1)][initial(src.name)][name_suffix(null, 1)]"

/* -------------------- end name stuff -------------------- */

	/// Change the name of this atom when a material is applied?
	var/mat_changename = 1

	/// Change the desc of this atom when a material is applied?
	var/mat_changedesc = 1

	/// Change the appearance of this atom when a material is applied?
	var/mat_changeappearance = 1

	var/explosion_resistance = 0
	var/explosion_protection = 0 //Reduces damage from explosions

	/// Chemistry.
	var/datum/reagents/reagents = null

	disposing()
		material = null
		if (!isnull(reagents))
			qdel(reagents)
			reagents = null
		if (temp_flags & (HAS_PARTICLESYSTEM | HAS_PARTICLESYSTEM_TARGET))
			particleMaster.ClearSystemRefs(src)
		if (temp_flags & (HAS_BAD_SMOKE))
			ClearBadsmokeRefs(src)

		fingerprintshidden = null
		tag = null

		if(length(src.statusEffects))
			for(var/datum/statusEffect/effect in src.statusEffects)
				src.delStatus(effect)
			src.statusEffects = null
		..()

	proc/Turn(var/rot)
		src.transform = matrix(src.transform, rot, MATRIX_ROTATE)

	proc/Scale(var/scalex = 1, var/scaley = 1)
		src.transform = matrix(src.transform, scalex, scaley, MATRIX_SCALE)

	proc/Translate(var/x = 0, var/y = 0)
		src.transform = matrix(src.transform, x, y, MATRIX_TRANSLATE)

	proc/assume_air(datum/air_group/giver)
		giver.dispose()
		return null

	proc/remove_air(amount)
		return null

	proc/return_air()
		return null

/**
  * Convenience proc to see if a container is open for chemistry handling
	*
  * * returns true if open, false if closed
	*/
	proc/is_open_container()
		return flags & OPENCONTAINER

	proc/transfer_all_reagents(var/atom/A as turf|obj|mob, var/mob/user as mob)
		// trans from src to A
		if (!src.reagents || !A.reagents)
			return // what're we gunna do here?? ain't got no reagent holder

		if (!src.reagents.total_volume) // Check to make sure the from container isn't empty.
			boutput(user, "<span class='alert'>[src] is empty!</span>")
			return
		else if (A.reagents.total_volume == A.reagents.maximum_volume) // Destination Container is full, quit trying to do things what you can't do!
			boutput(user, "<span class='alert'>[A] is full!</span>") // Notify the user, then exit the process.
			return

		var/T //Placeholder for total volume transferred

		if ((A.reagents.total_volume + src.reagents.total_volume) > A.reagents.maximum_volume) // Check to make sure that both containers content's combined won't overfill the destination container.
			T = (A.reagents.maximum_volume - A.reagents.total_volume) // Dump only what fills up the destination container.
			logTheThing("combat", user, null, "transfers chemicals from [src] [log_reagents(src)] to [A] at [log_loc(A)].") // This wasn't logged. Call before trans_to (Convair880).
			src.reagents.trans_to(A, T) // Dump the amount of reagents.
			boutput(user, "<span class='notice'>You transfer [T] units into [A].</span>") // Tell the user they did a thing.
			return
		else
			T = src.reagents.total_volume // Just make T the whole dang amount then.
			logTheThing("combat", user, null, "transfers chemicals from [src] [log_reagents(src)] to [A] at [log_loc(A)].") // Ditto (Convair880).
			src.reagents.trans_to(A, T) // Dump it all!
			boutput(user, "<span class='notice'>You transfer [T] units into [A].</span>")
			return

/atom/proc/signal_event(var/event) // Right now, we only signal our container
	if(src.loc)
		src.loc.handle_event(event, src)

/atom/proc/handle_event(var/event, var/sender) //This is sort of like a version of Topic that is not for browsing.
	return

/atom/proc/serialize_icon(var/savefile/F, var/path, var/datum/sandbox/sandbox)
	icon_serializer(F, path, sandbox, icon, icon_state)

/atom/proc/deserialize_icon(var/savefile/F, path, var/datum/sandbox/sandbox)
	var/datum/iconDeserializerData/IDS = icon_deserializer(F, path, sandbox, icon, icon_state)
	icon = IDS.icon
	icon_state = IDS.icon_state

/atom/proc/serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
	return

/atom/proc/deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
	return DESERIALIZE_NOT_IMPLEMENTED

/atom/proc/deserialize_postprocess()
	return

/atom/proc/ex_act(var/severity=0,var/last_touched=0)
	return

/atom/proc/reagent_act(var/reagent_id,var/volume)
	if (!istext(reagent_id) || !isnum(volume) || volume < 1)
		return 1
	return 0

/atom/proc/emp_act()
	return

/atom/proc/emag_act(var/mob/user, var/obj/item/card/emag/E) //This is gonna be fun!
	return 0

/atom/proc/demag(var/mob/user) //hail satan full of grace
	return 0

/atom/proc/meteorhit(obj/meteor as obj)
	qdel(src)
	return

/atom/proc/allow_drop()
	return 1

//atom.event_handler_flags & USE_CHECKEXIT MUST EVALUATE AS TRUE OR THIS PROC WONT BE CALLED
/atom/proc/CheckExit(atom/mover, turf/target)
	//return !(src.flags & ON_BORDER) || src.CanPass(mover, target, 1, 0)
	return 1 // fuck it

//atom.event_handler_flags & USE_HASENTERED MUST EVALUATE AS TRUE OR THIS PROC WONT BE CALLED
/atom/proc/HasEntered(atom/movable/AM as mob|obj, atom/OldLoc)
	return

//atom.event_handler_flags & USE_HASENTERED MUST EVALUATE AS TRUE OR THIS PROC WONT BE CALLED EITHER
/atom/proc/HasExited(atom/movable/AM as mob|obj, atom/NewLoc)
	return

/atom/proc/ProximityLeave(atom/movable/AM as mob|obj)
	return

//atom.event_handler_flags & USE_PROXIMITY MUST EVALUATE AS TRUE OR THIS PROC WONT BE CALLED
/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/atom/proc/EnteredFluid(obj/fluid/F as obj, /atom/oldloc)
	.=0

/atom/proc/ExitedFluid(obj/fluid/F as obj, /atom/newloc)
	.=0

/atom/proc/EnteredAirborneFluid(obj/fluid/F as obj, /atom/old_loc)
	.=0

/atom/proc/set_icon_state(var/new_state)
	src.icon_state = new_state
	signal_event("icon_updated")

/*
/atom/MouseEntered()
	usr << output("[src.name]", "atom_label")
*/

/atom/movable/overlay/attackby(a, b)
	//Wire note: hascall check below added as fix for: undefined proc or verb /datum/targetable/changeling/monkey/attackby() (lmao)
	if (src.master && hascall(src.master, "attackby"))
		return src.master.attackby(a, b)
	return

/atom/movable/overlay/attack_hand(a, b, c, d, e)
	if (src.master)
		return src.master.attack_hand(a, b, c, d, e)
	return

/atom/movable/overlay/New()
	for(var/x in src.verbs)
		src.verbs -= x
	return

/atom/movable/overlay
	var/atom/master = null
	anchored = 1

/atom/movable/overlay/gibs
	icon_state = "blank"
	icon = 'icons/mob/mob.dmi'

/atom/movable/overlay/gibs/proc/delaydispose()
	SPAWN_DBG(3 SECONDS)
		if (src)
			dispose(src)

/atom/movable/overlay/disposing()
	master = null
	..()


/atom/movable
	layer = OBJ_LAYER
	var/turf/last_turf = 0
	var/last_move = null
	var/anchored = 0
	var/move_speed = 10
	var/l_move_time = 1
	var/throwing = 0
	var/throw_speed = 2
	var/throw_range = 7
	var/throwforce = 1
#if ASS_JAM //timestop var used for pausing thrown stuff midair
	var/throwing_paused = FALSE
#endif
	var/soundproofing = 5
	appearance_flags = LONG_GLIDE | PIXEL_SCALE
	var/l_spd = 0

	/// List of attached objects. Objects in this list will follow this atom around as it moves.
	var/list/attached_objs = null

	/// Continue moving until a wall or solid object is hit.
	var/no_gravity = 0

	/// how much it slows you down while pulling it, changed this from w_class because that's gunna cause issues with items that shouldn't fit in backpacks but also shouldn't slow you down to pull (sorry grayshift)
	var/p_class = 2.5


//some more of these event handler flag things are handled in set_loc far below . . .
/atom/movable/New()
	..()
	//hey this is mbc, there is probably a faster way to do this but i couldnt figure it out yet
	if (isturf(src.loc))
		var/turf/T = src.loc
		if (src.event_handler_flags & USE_CHECKEXIT)
			T.checkingexit++
		if (src.event_handler_flags & USE_CANPASS || src.density)
			if (bound_width + bound_height > 64)
				for(var/turf/BT in bounds(src))
					BT.checkingcanpass++
			else
				T.checkingcanpass++
		if (src.event_handler_flags & USE_HASENTERED)
			T.checkinghasentered++
		if (src.event_handler_flags & USE_PROXIMITY)
			T.checkinghasproximity++
		if(src.opacity)
			T.opaque_atom_count++

/atom/movable/disposing()
	if (temp_flags & MANTA_PUSHING)
		mantaPushList.Remove(src)
		temp_flags &= ~MANTA_PUSHING

	if (temp_flags & SPACE_PUSHING)
		EndSpacePush(src)

	src.attached_objs?.Cut()
	src.attached_objs = null

	last_turf = src.loc // instead rely on set_loc to clear last_turf
	set_loc(null)
	..()


/atom/movable/Move(NewLoc, direct)


	//mbc disabled for now, i dont think this does too much for visuals i cant hit 40fps anyway argh i cant even tell
	//tile glide smoothing:
	/*
	var/spd = world.timeofday - src.l_move_time //standing still for a while and then moving will result in a slow glide too. this is intentional and mimics the default glide behavior.
	if (spd != 0)
		if (spd <= 1 || (spd <= 2 && l_spd <= 2 && spd != l_spd)) //default glide seems to look better at max run speed?
			src.glide_size = 0
		else
			spd = min(spd,12 * world.tick_lag) //When spd greater than (12 * ticklag), glides start to look jittery. 12 is a magic number found through testing what looks good
			spd = max(spd, world.tick_lag)
			src.glide_size = (32 / spd) * world.tick_lag// * (world.tick_lag / CLIENTSIDE_TICK_LAG_SMOOTH)


	l_spd = spd
	*/

	//for (var/atom in src) //prevent bad glides while observing or riding in vehicles. this is meant to affect mobs but i think its faster not to typecheck
	//	var/atom/movable/A = atom
	//	A.glide_size = src.glide_size

	if (direct & (direct - 1))
		ignore_simple_light_updates = 1 //to avoid double-updating on diagonal steps when we are really only taking a single step

		if (direct & NORTH)
			if (direct & EAST)
				if (step(src, NORTH))
					step(src, EAST)
				else if (step(src, EAST))
					step(src, NORTH)
			else
				if (step(src, NORTH))
					step(src, WEST)
				else if (step(src, WEST))
					step(src, NORTH)
		else
			if (direct & EAST)
				if (step(src, SOUTH))
					step(src, EAST)
				else if (step(src, EAST))
					step(src, SOUTH)
			else
				if (step(src, SOUTH))
					step(src, WEST)
				else if (step(src, WEST))
					step(src, SOUTH)

		ignore_simple_light_updates = 0

		if(src.medium_lights)
			update_medium_light_visibility()
		if (src.mdir_lights)
			update_mdir_light_visibility(direct)

		return // this should in turn fire off its own slew of move calls, so don't do anything here

	var/atom/A = src.loc
	. = ..()
	src.move_speed = world.timeofday - src.l_move_time
	src.l_move_time = world.timeofday
	if ((A != src.loc && A && A.z == src.z))
		src.last_move = get_dir(A, src.loc)
		if (src.attached_objs && islist(src.attached_objs) && src.attached_objs.len)
			for (var/atom/movable/M in attached_objs)
				M.set_loc(src.loc)
		if (islist(src.tracked_blood))
			src.track_blood()
		actions.interrupt(src, INTERRUPT_MOVE)
		#ifdef COMSIG_MOVABLE_MOVED
		SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, A, direct)
		#endif
	//note : move is still called when we are steping into a wall. sometimes these are unnecesssary i think

	// sometimes last_turf isnt a turf. ok.
	if (last_turf && isturf(last_turf))
		if (src.event_handler_flags & USE_CHECKEXIT)
			last_turf.checkingexit = max(last_turf.checkingexit-1, 0)
		if (src.event_handler_flags & USE_CANPASS || src.density)
			if (bound_width + bound_height > 64)
				for(var/turf/T in bounds(last_turf.x*32, last_turf.y*32, bound_width/2, bound_height/2, last_turf.z))
					T.checkingcanpass = max(T.checkingcanpass-1, 0)
			else
				last_turf.checkingcanpass = max(last_turf.checkingcanpass-1, 0)
		if (src.event_handler_flags & USE_HASENTERED)
			last_turf.checkinghasentered = max(last_turf.checkinghasentered-1, 0)
		if (src.event_handler_flags & USE_PROXIMITY)
			last_turf.checkinghasproximity = max(last_turf.checkinghasproximity-1, 0)

	if (isturf(src.loc))
		last_turf = src.loc
		if (src.event_handler_flags & USE_CHECKEXIT)
			var/turf/T = src.loc
			if (T)
				T.checkingexit++
		if (src.event_handler_flags & USE_CANPASS || src.density)
			var/turf/T = src.loc
			if (T)
				if (bound_width + bound_height > 64)
					for(var/turf/BT in bounds(src))
						BT.checkingcanpass++
				else
					T.checkingcanpass++
		if (src.event_handler_flags & USE_HASENTERED)
			var/turf/T = src.loc
			if (T)
				T.checkinghasentered++
		if (src.event_handler_flags & USE_PROXIMITY)
			var/turf/T = src.loc
			if (T)
				T.checkinghasproximity++
	else
		last_turf = 0

	if (!ignore_simple_light_updates)
		if(src.medium_lights)
			update_medium_light_visibility()
		if (src.mdir_lights)
			update_mdir_light_visibility(direct)


/**
  * called once per player-invoked move, regardless of diagonal etc
  * called via pulls and mob steps
	*/
/atom/movable/proc/OnMove(source = null)

/atom/movable/proc/pull()
	//set name = "Pull"
	//set src in oview(1)
	//set category = "Local"

	if (!( usr ))
		return

	if(src.loc == usr)
		return

	// eyebots aint got no arms man, how can they be pulling stuff???????
	if (!isliving(usr))
		return
	if (isshell(usr))
		if (!ticker)
			return
		if (!ticker.mode)
			return
		if (!istype(ticker.mode, /datum/game_mode/construction))
			return
	// no pulling other mobs for ghostdrones (but they can pull other ghostdrones)
	else if (isghostdrone(usr) && ismob(src) && !isghostdrone(src))
		return

	if (isghostcritter(usr))
		var/mob/living/critter/C = usr
		if (!C.can_pull(src))
			boutput(usr,"<span class='alert'><b>[src] is too heavy for you pull in your half-spectral state!</b></span>")
			return

	if (iscarbon(usr) || issilicon(usr))
		add_fingerprint(usr)

	if (istype(src,/obj/item/old_grenade/light_gimmick))
		boutput(usr, "<span class='notice'>You feel your hand reach out and clasp the grenade.</span>")
		src.attack_hand(usr)
		return
	if (!( src.anchored ))
		var/mob/user = usr
		user.set_pulling(src)

		if (user.mob_flags & AT_GUNPOINT)
			for(var/obj/item/grab/gunpoint/G in user.grabbed_by)
				G.shoot()
	return

/atom/proc/get_desc(dist)

/**
  * a proc to completely override the standard formatting for examine text
	* to prevent more copy paste
	*/
/atom/proc/special_desc(dist, mob/user)
	return null

/atom/proc/examine(mob/user)
	RETURN_TYPE(/list)
	if(src.hiddenFrom && hiddenFrom.Find(user.client)) //invislist
		return list()

	var/dist = get_dist(src, user)
	if (istype(user, /mob/dead/target_observer))
		var/mob/dead/target_observer/target_observer_user = user
		dist = get_dist(src, target_observer_user.target)

	// added for custom examine behaviour override - cirr
	var/special_description = src.special_desc(dist, user)

	if(special_description)
		return list(special_description)
	//////////////////////////////

	. = list("This is \an [src.name].")

	// Added for forensics (Convair880).
	if (isitem(src) && src.blood_DNA)
		. = list("<span class='alert'>This is a bloody [src.name].</span>")
		if (src.desc)
			if (src.desc && src.blood_DNA == "--conductive_substance--")
				. += "<br>[src.desc] <span class='alert'>It seems to be covered in an odd azure liquid!</span>"
			else
				. += "<br>[src.desc] <span class='alert'>It seems to be covered in blood!</span>"
	else if (src.desc)
		. += "<br>[src.desc]"

	var/extra = src.get_desc(dist, usr)
	if (extra)
		. += " [extra]"

/atom/proc/MouseDrop_T()
	return

/atom/proc/attack_hand(mob/user as mob)
	if (flags & TGUI_INTERACTIVE)
		return ui_interact(user)
	return

/atom/proc/attack_ai(mob/user as mob)
	return

/atom/proc/hitby(atom/movable/AM as mob|obj)
	return

//mbc : sorry, i added a 'is_special' arg to this proc to avoid race conditions.
/atom/proc/attackby(obj/item/W as obj, mob/user as mob, params, is_special = 0)
	if (user && W && !(W.flags & SUPPRESSATTACK))  //!( istype(W, /obj/item/grab)  || istype(W, /obj/item/spraybottle) || istype(W, /obj/item/card/emag)))
		user.visible_message("<span class='combat'><B>[user] hits [src] with [W]!</B></span>")
	return

//This will looks stupid on objects larger than 32x32. Might have to write something for that later. -Keelin
/atom/proc/setTexture(var/texture = "damaged", var/blendMode = BLEND_MULTIPLY, var/key = "texture")
	var/image/I = getTexturedImage(src, texture, blendMode)//, key)
	if (!I)
		return
	src.UpdateOverlays(I, key)

	if(isitem(src) && key == "material")
		worn_material_texture_image = getTexturedWornImage(src, texture, blendMode)
	return

/proc/getTexturedImage(var/atom/A, var/texture = "damaged", var/blendMode = BLEND_MULTIPLY)//, var/key = "texture")
	if (!A)
		return
	var/icon/tex = null

	//Try to find an appropriately sized icon.
	if(istype(A, /atom/movable))
		var/atom/movable/M = A
		if(A.texture_size == 32 || ((M.bound_height == 32 && M.bound_width == 32) && !A.texture_size))
			tex = icon('icons/effects/atom_textures_32.dmi', texture)
		else if(A.texture_size == 64 || ((M.bound_height == 64 && M.bound_width == 64) && !A.texture_size))
			tex = icon('icons/effects/atom_textures_64.dmi', texture)
		else
			tex = icon('icons/effects/atom_textures_32.dmi', texture)
	else if (isicon(A))
		var/icon/I = A
		if(I.Height() > 32)
			tex = icon('icons/effects/atom_textures_64.dmi', texture)
		else
			tex = icon('icons/effects/atom_textures_32.dmi', texture)
	else
		if(A.texture_size == 32)
			tex = icon('icons/effects/atom_textures_32.dmi', texture)
		else if(A.texture_size == 64)
			tex = icon('icons/effects/atom_textures_64.dmi', texture)
		else
			tex = icon('icons/effects/atom_textures_32.dmi', texture)

	var/icon/mask = null
	mask = new(isicon(A) ? A : A.icon)
	mask.MapColors(1,1,1, 1,1,1, 1,1,1, 1,1,1)
	mask.Blend(tex, ICON_MULTIPLY)
	//mask is now a cut-out of the texture shaped like the object.
	var/image/finished = image(mask,"")
	finished.blend_mode = blendMode
	return finished

/proc/getTexturedWornImage(var/obj/item/A, var/texture = "damaged", var/blendMode = BLEND_MULTIPLY)
	if (!A)
		return
	var/icon/tex = null

	//Try to find an appropriately sized icon.
	if(istype(A, /atom/movable))
		var/atom/movable/M = A
		if(A.texture_size == 32 || ((M.bound_height == 32 && M.bound_width == 32) && !A.texture_size))
			tex = icon('icons/effects/atom_textures_32.dmi', texture)
		else if(A.texture_size == 64 || ((M.bound_height == 64 && M.bound_width == 64) && !A.texture_size))
			tex = icon('icons/effects/atom_textures_64.dmi', texture)
		else
			tex = icon('icons/effects/atom_textures_32.dmi', texture)
	else if (isicon(A))
		var/icon/I = A
		if(I.Height() > 32)
			tex = icon('icons/effects/atom_textures_64.dmi', texture)
		else
			tex = icon('icons/effects/atom_textures_32.dmi', texture)
	else
		if(A.texture_size == 32)
			tex = icon('icons/effects/atom_textures_32.dmi', texture)
		else if(A.texture_size == 64)
			tex = icon('icons/effects/atom_textures_64.dmi', texture)
		else
			tex = icon('icons/effects/atom_textures_32.dmi', texture)

	if (A && A.wear_image) //Wire: Fix for: Cannot read null.icon
		var/icon/mask = null
		mask = icon(A.wear_image.icon, A.wear_image.icon_state)
		mask.MapColors(1,1,1, 1,1,1, 1,1,1, 1,1,1)
		mask.Blend(tex, ICON_MULTIPLY)
		var/image/finished = image(mask,"")
		finished.blend_mode = blendMode
		return finished

	return null

/atom/MouseDrop(atom/over_object as mob|obj|turf)
	SPAWN_DBG( 0 )
		if (istype(over_object, /atom))
			if (isalive(usr))
				//To stop ghostdrones dragging people anywhere
				if (isghostdrone(usr) && ismob(src) && src != usr)
					return

				/* This was SUPPOSED to make the innerItem of items act on the mousedrop instead but it doesnt work for no reason
				if (isitem(src))
					var/obj/item/W = src
					if (W.useInnerItem && W.contents.len > 0)
						target = pick(W.contents)
				//world.log << "calling mousedrop_t on [over_object] with params: [src], [usr]"
				*/

				over_object.MouseDrop_T(src, usr)
			else
				if (istype(over_object, /obj/machinery)) // For cyborg docking stations (Convair880).
					var/obj/machinery/M = over_object
					if (M.allow_stunned_dragndrop == 1)
						M.MouseDrop_T(src, usr)
		return
	..()
	return

/atom/proc/relaymove()
	.= 0

/atom/proc/on_reagent_change(var/add = 0) // if the reagent container just had something added, add will be 1.
	return

/atom/proc/Bumped(AM as mob|obj)
	return

/atom/proc/contains(var/atom/A)
	if(!A)
		return 0
	for(var/atom/location = A.loc, location, location = location.loc)
		if(location == src)
			return 1

/atom/movable/Bump(var/atom/A as mob|obj|turf|area, yes)
	SPAWN_DBG( 0 )
		if ((A && yes)) //wtf
			A.last_bumped = world.timeofday
			A.Bumped(src)
		return
	..()
	return

// bullet_act called when anything is hit buy a projectile (bullet, tazer shot, laser, etc.)
// flag is projectile type, can be:
//PROJECTILE_TASER = 1   		taser gun
//PROJECTILE_LASER = 2			laser gun
//PROJECTILE_BULLET = 3			traitor pistol
//PROJECTILE_PULSE = 4			pulse rifle
//PROJECTILE_BOLT = 5			crossbow
//PROJECTILE_WEAKBULLET = 6		detective's revolver

//Return an atom if you want to make the projectile's effects affect that instead.

/atom/proc/bullet_act(var/obj/projectile/P)
	if(src.material) src.material.triggerOnBullet(src, src, P)
	return


/**
  * this handles RL_Lighting for luminous atoms and some child types override it for extra stuff
  * like the 2x2 pod camera. fixes that bug where you go through a warp portal but your camera doesn't update
  *
  * there are lots of old places in the code that set loc directly.
	* ignore them they'll be fixed later, please use this proc in the future
  */
/atom/movable/proc/set_loc(var/newloc as turf|mob|obj in world)
	SHOULD_CALL_PARENT(TRUE)
	if (loc == newloc)
		return src

	if (ismob(src)) // fuck haxploits
		if(src:client && src:client:player && src:client:player:shamecubed)
			loc = src:client:player:shamecubed
			return

	if (isturf(loc))
		loc.Exited(src, newloc)

	var/area/my_area = get_area(src)
	var/area/new_area = get_area(newloc)

	if(my_area != new_area && my_area)
		my_area.Exited(src, newloc)

	var/oldloc = loc
	loc = newloc
	 //Required for objects coming out of other objects / mobs; otherwise they will not call entered on the area when a mob drops items etc. This is not a perfect solution.
	if(((my_area != new_area && isturf(oldloc)) || !isturf(oldloc)) && new_area)
		new_area.Entered(src, oldloc)

	if(isturf(newloc))
		var/turf/nloc = newloc
		nloc.Entered(src, oldloc)

	if (islist(src.attached_objs) && attached_objs.len)
		for (var/atom/movable/M in src.attached_objs)
			M.set_loc(src.loc)


	// We only need to do any of these checks if one of the flags is set OR density = 1
	var/do_checks = (src.event_handler_flags & (USE_CHECKEXIT | USE_CANPASS | USE_HASENTERED | USE_HASENTERED)) || src.density == 1

	if (do_checks && last_turf && isturf(last_turf))
		if (src.event_handler_flags & USE_CHECKEXIT)
			last_turf.checkingexit = max(last_turf.checkingexit-1, 0)
		if (src.event_handler_flags & USE_CANPASS || src.density)
			if (bound_width + bound_height > 64)
				for(var/turf/T in bounds(last_turf.x*32, last_turf.y*32, bound_width/2, bound_height/2, last_turf.z))
					T.checkingcanpass = max(T.checkingcanpass-1, 0)
			else
				last_turf.checkingcanpass = max(last_turf.checkingcanpass-1, 0)
		if (src.event_handler_flags & USE_HASENTERED)
			last_turf.checkinghasentered = max(last_turf.checkinghasentered-1, 0)
		if (src.event_handler_flags & USE_PROXIMITY)
			last_turf.checkinghasproximity = max(last_turf.checkinghasproximity-1, 0)

	if (do_checks && isturf(src.loc))
		last_turf = src.loc
		if (src.event_handler_flags & USE_CHECKEXIT)
			last_turf.checkingexit++
		if (src.event_handler_flags & USE_CANPASS || src.density)
			if (bound_width + bound_height > 64)
				for(var/turf/T in bounds(src))
					T.checkingcanpass++
			else
				last_turf.checkingcanpass++
		if (src.event_handler_flags & USE_HASENTERED)
			last_turf.checkinghasentered++
		if (src.event_handler_flags & USE_PROXIMITY)
			last_turf.checkinghasproximity++
	else
		last_turf = 0

	if(src.medium_lights)
		update_medium_light_visibility()
	if (src.mdir_lights)
		update_mdir_light_visibility(src.dir)

	return src

//reason for having this proc is explained below
/atom/proc/set_density(var/newdensity)
	src.density = newdensity

/atom/movable/set_density(var/newdensity)
	//BASICALLY : if we dont have the USE_CANPASS flag, turf's checkingcanpass value relies entirely on our density.
	//It is probably important that we update this as density changes immediately. I don't think it breaks anything currently if we dont, but still important for future.
	if (src.density != newdensity)
		if (isturf(src.loc))
			if (!(src.event_handler_flags & USE_CANPASS))
				if(newdensity == 1)
					var/turf/T = src.loc
					if (T)
						if (bound_width + bound_height > 64)
							for(var/turf/BT in bounds(src))
								BT.checkingcanpass++
						else
							T.checkingcanpass++

				else
					var/turf/T = src.loc
					if (T)
						if (bound_width + bound_height > 64)
							for(var/turf/BT in bounds(src))
								BT.checkingcanpass = max(BT.checkingcanpass-1, 0)
						else
							T.checkingcanpass = max(T.checkingcanpass-1, 0)
	..()

//same as above :)
/atom/movable/setMaterial(var/datum/material/mat1, var/appearance = 1, var/setname = 1, var/copy = 1, var/use_descriptors = 0)
	var/prev_mat_triggeronentered = (src.material && src.material.triggersOnEntered && src.material.triggersOnEntered.len)
	..(mat1,appearance,setname,copy,use_descriptors)
	var/cur_mat_triggeronentered = (src.material && src.material.triggersOnEntered && src.material.triggersOnEntered.len)

	if (prev_mat_triggeronentered != cur_mat_triggeronentered)
		if (isturf(src.loc))
			if (!src.event_handler_flags & USE_HASENTERED)
				if(cur_mat_triggeronentered)
					var/turf/T = src.loc
					if (T)
						T.checkinghasentered++
				else
					var/turf/T = src.loc
					if (T)
						T.checkinghasentered = max(T.checkinghasentered-1, 0)


// standardized damage procs

/// Does x blunt damage to the atom
/atom/proc/damage_blunt(amount)

/// Does x piercing damage to the atom
/atom/proc/damage_piercing(amount)

/// Does x slashing damage to the atom
/atom/proc/damage_slashing(amount)

/// Does x corrosive damage to the atom
/atom/proc/damage_corrosive(amount)

/// Does x electricity damage to the atom
/atom/proc/damage_electricity(amount)

/// Does x radiation damage to the atom
/atom/proc/damage_radiation(amount)

/// does x heat damage to the atom
/atom/proc/damage_heat(amount)

/// Does x cold damage to the atom
/atom/proc/damage_cold(amount)

/proc/scaleatomall()
	var/scalex = input(usr,"X Scale","1 normal, 2 double etc","1") as num
	var/scaley = input(usr,"Y Scale","1 normal, 2 double etc","1") as num
	logTheThing("admin", usr, null, "scaled every goddamn atom by X:[scalex] Y:[scaley]")
	logTheThing("diary", usr, null, "scaled every goddamn atom by X:[scalex] Y:[scaley]", "admin")
	message_admins("[key_name(usr)] scaled every goddamn atom by X:[scalex] Y:[scaley]")
	for(var/atom/A in world)
		A.Scale(scalex,scaley)
		LAGCHECK(LAG_LOW)
	return

/proc/rotateatomall()
	var/rot = input(usr,"Rotation","Rotation","0") as num
	logTheThing("admin", usr, null, "rotated every goddamn atom by [rot] degrees")
	logTheThing("diary", usr, null, "rotated every goddamn atom by [rot] degrees", "admin")
	message_admins("[key_name(usr)] rotated every goddamn atom by [rot] degrees")
	for(var/atom/A in world)
		A.Turn(rot)
		LAGCHECK(LAG_LOW)
	return

/proc/scaleatom()
	var/atom/target = input(usr,"Target","Target") as mob|obj in world
	var/scalex = input(usr,"X Scale","1 normal, 2 double etc","1") as num
	var/scaley = input(usr,"Y Scale","1 normal, 2 double etc","1") as num
	logTheThing("admin", usr, null, "scaled [target] by X:[scalex] Y:[scaley]")
	logTheThing("diary", usr, null, "scaled [target] by X:[scalex] Y:[scaley]", "admin")
	message_admins("[key_name(usr)] scaled [target] by X:[scalex] Y:[scaley]")
	target.Scale(scalex, scaley)
	return

/proc/rotateatom()
	var/atom/target = input(usr,"Target","Target") as mob|obj in world
	var/rot = input(usr,"Rotation","Rotation","0") as num
	logTheThing("admin", usr, null, "rotated [target] by [rot] degrees")
	logTheThing("diary", usr, null, "rotated [target] by [rot] degrees", "admin")
	message_admins("[key_name(usr)] rotated [target] by [rot] degrees")
	target.Turn(rot)
	return


/atom/proc/interact(var/mob/user)
	if (isdead(user) || (!iscarbon(user) && !ismobcritter(user) && !issilicon(usr)))
		return

	if (!istype(src.loc, /turf) || user.stat || user.hasStatus(list("paralysis", "stunned", "weakened")) || user.restrained())
		return

	if (!can_reach(user, src))
		return

	if (user.client)
		user.client.Click(src,get_turf(src))
