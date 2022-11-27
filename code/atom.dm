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
	var/shrunk = 0
	var/list/cooldowns

	/// Override for the texture size used by setTexture.
	var/texture_size = 0

	/// Should points thrown at this take into account the click pixel value
	var/pixel_point = FALSE

	/// If hear_talk is triggered on this object, make my contents hear_talk as well
	var/open_to_sound = 0

	var/interesting = ""
	var/stops_space_move = 0
	/// Anything can speak... if it can speak
	var/obj/chat_maptext_holder/chat_text

	/// A multiplier that changes how an atom stands up from resting. Yes.
	var/rest_mult = 0

	proc/RawClick(location,control,params)
		return

	/// If atmos should be blocked by this - special behaviours handled in gas_cross() overrides
	var/gas_impermeable = FALSE

	var/list/atom_properties

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

	proc/name_prefix(var/text_to_add, var/return_prefixes = 0, var/prepend = 0)
		if( !name_prefixes ) name_prefixes = list()
		var/prefix = ""
		if (istext(text_to_add) && length(text_to_add) && islist(src.name_prefixes))
			if (src.name_prefixes.len >= src.num_allowed_prefixes)
				src.remove_prefixes(1)
			if(prepend)
				src.name_prefixes.Insert(1, strip_html(text_to_add))
			else
				src.name_prefixes += strip_html(text_to_add)
		if (return_prefixes)
			var/amt_prefixes = 0
			for (var/i in src.name_prefixes)
				if (amt_prefixes >= src.num_allowed_prefixes)
					prefix += " "
					break
				if(prepend)
					prefix = i + " " + prefix
				else
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
				amt_suffixes++
			return suffix

	proc/remove_prefixes(var/num = 1)
		if (!num || !name_prefixes)
			return
		if (istext(num)) // :v
			src.name_prefixes -= num
			return
		if (islist(src.name_prefixes) && length(src.name_prefixes))
			for (var/i in src.name_prefixes)
				if (num <= 0 || !length(src.name_prefixes))
					return
				src.name_prefixes -= i
				num--

	proc/remove_suffixes(var/num = 1)
		if (!num || !name_suffixes)
			return
		if (istext(num))
			src.name_suffixes -= num
			return
		if (islist(src.name_suffixes) && length(src.name_suffixes))
			for (var/i in src.name_suffixes)
				if (num <= 0 || !length(src.name_suffixes))
					return
				src.name_suffixes -= i
				num--

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

		fingerprints_full = null
		tag = null

		if(length(src.statusEffects))
			for(var/datum/statusEffect/effect as anything in src.statusEffects)
				src.delStatus(effect)
			src.statusEffects = null
		ClearAllParticles()
		atom_properties = null
		..()

	proc/Turn(var/rot)
		src.transform = matrix(src.transform, rot, MATRIX_ROTATE)

	proc/Scale(var/scalex = 1, var/scaley = 1)
		src.transform = matrix(src.transform, scalex, scaley, MATRIX_SCALE)

	// a turn-safe scale, for temporary anisotropic scales
	proc/SafeScale(var/scalex = 1, var/scaley = 1)
		var/rot = arctan(src.transform.b, src.transform.a)
		src.transform = matrix(matrix(matrix(src.transform, -rot, MATRIX_ROTATE), scaley, scalex, MATRIX_SCALE), rot, MATRIX_ROTATE)

	proc/SafeScaleAnim(var/scalex = 1, var/scaley = 1, var/anim_time=2 SECONDS, var/anim_easing=null)
		var/rot = arctan(src.transform.b, src.transform.a)
		var/matrix/new_transform = matrix(matrix(matrix(src.transform, -rot, MATRIX_ROTATE), scaley, scalex, MATRIX_SCALE), rot, MATRIX_ROTATE)
		animate(src, transform=new_transform, time=anim_time, easing=anim_easing)

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

		logTheThing(LOG_CHEMISTRY, user, "transfers chemicals from [src] [log_reagents(src)] to [A] at [log_loc(A)].") // Ditto (Convair880).
		var/T = src.reagents.trans_to(A, src.reagents.total_volume) // Dump it all!
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

// not actually overriden because we want to avoid the overhead if possible. This provides documentation
#ifdef SPACEMAN_DMM
/**
 * Override and return FALSE to prevent O from moving out of the tile where src is.
 * In order to override this properly be sure to have the `do_bump = TRUE` default argument AND
 * to call UNCROSS_BUMP_CHECK(O) in all branches where the return value can be FALSE (assign this return
 * value to `.` instead of doing an explicit `return`).
 */
/atom/Uncross(atom/movable/O, do_bump = TRUE)
	. = TRUE
	UNCROSS_BUMP_CHECK(O)
#endif

/// Wrapper around Uncross for when you want to call it manually with a target turf
/atom/proc/CheckExit(atom/movable/mover, turf/target, do_bump=FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)
	mover.movement_newloc = target
	return src.Uncross(mover, do_bump=do_bump)

/// This is the proc to check if a movable can cross this atom.
/// DO NOT put side effects in this proc, it is called for pathfinding
/// Seriously I mean it, you think it'll be fine and then it causes the teleporting gene booth bug
/atom/Cross(atom/movable/mover)
	return (!density)

/atom/Crossed(atom/movable/AM)
	SHOULD_CALL_PARENT(TRUE)
	#ifdef SPACEMAN_DMM // idk a tiny optimization to omit the parent call here, I don't think it actually breaks anything in byond internals
	..()
	#endif
	SEND_SIGNAL(src, COMSIG_ATOM_CROSSED, AM)

/atom/Entered(atom/movable/AM, atom/OldLoc)
	SHOULD_CALL_PARENT(TRUE)
	#ifdef SPACEMAN_DMM //im cargo culter
	..()
	#endif
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, AM, OldLoc)

/atom/proc/ProximityLeave(atom/movable/AM as mob|obj)
	return

//atom.event_handler_flags & USE_PROXIMITY MUST EVALUATE AS TRUE OR THIS PROC WONT BE CALLED
/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/atom/proc/EnteredFluid(obj/fluid/F as obj, atom/oldloc)
	.=0

/atom/proc/ExitedFluid(obj/fluid/F as obj)
	.=0

/atom/proc/EnteredAirborneFluid(obj/fluid/F as obj, atom/old_loc)
	.=0

/atom/proc/set_icon_state(var/new_state)
	src.icon_state = new_state
	signal_event("icon_updated")

/atom/proc/set_dir(var/new_dir)
#ifdef COMSIG_ATOM_DIR_CHANGED
	if (src.dir != new_dir)
		SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGED, src.dir, new_dir)
#endif
	src.dir = new_dir


/**
 * DO NOT CALL THIS PROC - Call UpdateIcon(...) Instead!
 *
 * Only override this proc!
 */
/atom/proc/update_icon(...)
	PROTECTED_PROC(TRUE)
	return

/// Call this proc inplace of update_icon(...)
/atom/proc/UpdateIcon(...)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (HAS_ATOM_PROPERTY(src, PROP_ATOM_NO_ICON_UPDATES)) return
	SEND_SIGNAL(src, COMSIG_ATOM_PRE_UPDATE_ICON)
	update_icon(arglist(args))
	SEND_SIGNAL(src, COMSIG_ATOM_POST_UPDATE_ICON)
	return

/*
/atom/MouseEntered()
	usr << output("[src.name]", "atom_label")
*/

/atom/proc/get_examine_tag(mob/examiner)
	return null

/atom/movable/overlay/attackby(a, b)
	//Wire note: hascall check below added as fix for: undefined proc or verb /datum/targetable/changeling/monkey/attackby() (lmao)
	if (src.master && hascall(src.master, "attackby"))
		return src.master.Attackby(a, b)

/atom/movable/overlay/attack_hand(a, b, c, d, e)
	if (src.master)
		return src.master.Attackhand(a, b, c, d, e)

/atom/movable/overlay/New()
	..()
	for(var/x in src.verbs)
		src.verbs -= x

/atom/movable/overlay
	var/atom/master = null
	anchored = 1

/atom/movable/overlay/gibs
	icon_state = "blank"
	icon = 'icons/mob/mob.dmi'

/atom/movable/overlay/gibs/proc/delaydispose()
	SPAWN(3 SECONDS)
		if (src)
			dispose(src)

/atom/movable/overlay/disposing()
	master = null
	..()


/atom/movable
	layer = OBJ_LAYER
	var/tmp/turf/last_turf = 0
	var/tmp/last_move = null
	var/anchored = 0
	var/move_speed = 10
	var/tmp/l_move_time = 1
	var/throwing = 0
	var/throw_speed = 2
	var/throw_range = 7
	var/throwforce = 1

	/// Temporary value to smuggle newloc to Uncross during Move-related procs
	var/tmp/atom/movement_newloc = null

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
	src.last_turf = isturf(src.loc) ? src.loc : null
	//hey this is mbc, there is probably a faster way to do this but i couldnt figure it out yet
	if (isturf(src.loc))
		var/turf/T = src.loc
		if (src.event_handler_flags & USE_PROXIMITY)
			T.checkinghasproximity++
			for (var/turf/T2 in range(1, T))
				T2.neighcheckinghasproximity++
		if(src.opacity)
			T.opaque_atom_count++
	if(!isnull(src.loc))
		src.loc.Entered(src, null)
		if(isturf(src.loc)) // call it on the area too
			src.loc.loc.Entered(src, null)
			for(var/atom/A in src.loc)
				if(A != src)
					A.Crossed(src)


/atom/movable/disposing()
	if (temp_flags & MANTA_PUSHING)
		mantaPushList.Remove(src)
		temp_flags &= ~MANTA_PUSHING

	if (temp_flags & SPACE_PUSHING)
		EndSpacePush(src)

	src.attached_objs?.Cut()
	src.attached_objs = null

	src.vis_locs = null // cleans up vis_contents of visual holders of this too

	last_turf = src.loc // instead rely on set_loc to clear last_turf
	set_loc(null)
	. = ..()


/atom/movable/Move(NewLoc, direct)
	SHOULD_CALL_PARENT(TRUE)
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_BLOCK_MOVE, NewLoc, direct))
		return

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

	if (!is_cardinal(direct))
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
	if(src.event_handler_flags & MOVE_NOCLIP)
		src.set_loc(NewLoc)
	else
		. = ..()
	src.move_speed = TIME - src.l_move_time
	src.l_move_time = TIME
	if (A != src.loc && A?.z == src.z)
		src.last_move = get_dir(A, src.loc)
		if (length(src.attached_objs))
			for (var/atom/movable/M as anything in attached_objs)
				M.set_loc(src.loc)
		if (islist(src.tracked_blood))
			src.track_blood()
		actions.interrupt(src, INTERRUPT_MOVE)
		SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, A, direct)
	//note : move is still called when we are steping into a wall. sometimes these are unnecesssary i think

	if(last_turf == src.loc)
		return

	if (isturf(last_turf))
		if (src.event_handler_flags & USE_PROXIMITY)
			last_turf.checkinghasproximity = max(last_turf.checkinghasproximity-1, 0)
			for (var/turf/T2 in range(1, last_turf))
				T2.neighcheckinghasproximity--
	if(isturf(src.loc))
		var/turf/T = src.loc
		if (src.event_handler_flags & USE_PROXIMITY)
			T.checkinghasproximity++
			for (var/turf/T2 in range(1, T))
				T2.neighcheckinghasproximity++

	last_turf = isturf(src.loc) ? src.loc : null

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

/// Base pull proc, returns 1 if the various checks for pulling fail, so that it can be overriden to add extra functionality without rewriting all the conditions.
/atom/movable/proc/pull(mob/user)
	if (!(user))
		return 1

	if(src.loc == user)
		return 1

	if (!isliving(user))
		return 1

	if (isintangible(user)) //can't pull shit if you can't touch shit
		return 1

	// no pulling other mobs for ghostdrones (but they can pull other ghostdrones)
	else if (isghostdrone(user) && ismob(src) && !isghostdrone(src))
		return 1

	if (isghostcritter(user))
		var/mob/living/critter/C = user
		if (!C.can_pull(src))
			boutput(user,"<span class='alert'><b>[src] is too heavy for you pull in your half-spectral state!</b></span>")
			return 1

	if (iscarbon(user) || issilicon(user))
		add_fingerprint(user)

	if (istype(src,/obj/item/old_grenade/light_gimmick))
		boutput(user, "<span class='notice'>You feel your hand reach out and clasp the grenade.</span>")
		src.Attackhand(user)
		return 1
	if (!( src.anchored ))
		user.set_pulling(src)

		if (user.mob_flags & AT_GUNPOINT)
			for(var/obj/item/grab/gunpoint/G in user.grabbed_by)
				G.shoot()

/atom/movable/set_dir(new_dir)
	..()
	if(src.medium_lights)
		update_medium_light_visibility()
	if (src.mdir_lights)
		update_mdir_light_visibility(src.dir)

/atom/proc/get_desc(dist)

/**
  * a proc to completely override the standard formatting for examine text
	* to prevent more copy paste
	*/
/atom/proc/special_desc(dist, mob/user)
	return null

/atom/proc/examine(mob/user)
	RETURN_TYPE(/list)

	var/dist = GET_DIST(src, user)
	if (istype(user, /mob/dead/target_observer))
		var/mob/dead/target_observer/target_observer_user = user
		dist = GET_DIST(src, target_observer_user.target)

	// added for custom examine behaviour override - cirr
	var/special_description = src.special_desc(dist, user)

	if(special_description)
		return list(special_description)

	. = list("This is \an [src.name].")

	// Added for forensics (Convair880).
	if (isitem(src) && src.blood_DNA)
		. = list("<span class='alert'>This is a bloody [src.name].</span>")
		if (src.desc)
			. += "<br>[src.desc] <span class='alert'>It seems to be covered in blood!</span>"
	else if (src.desc)
		. += "<br>[src.desc]"

	var/extra = src.get_desc(dist, user)
	if (extra)
		. += " [extra]"

	// handles PDA messaging shortcut for the AI
	if (isAI(user) && ishuman(src))
		var/mob/living/silicon/ai/mainframe
		var/mob/living/carbon/human/person = src
		if (isAIeye(user))
			var/mob/living/intangible/aieye/ai = user
			mainframe = ai.mainframe
		else
			mainframe = user

		// we need to check to see if any of these are PDAs so that we can render them to the ai.
		// these are where pdas can be visible in an inventory - lets check to see whats in them!
		var/list/inv_list = list()
		inv_list += person.get_slot(SLOT_BELT)
		inv_list += person.get_slot(SLOT_WEAR_ID)
		inv_list += person.get_slot(SLOT_L_HAND)
		inv_list += person.get_slot(SLOT_R_HAND)

		var/hasPDA = FALSE
		for (var/obj/item/device/pda2/pda in inv_list) // we only care about PDAs
			var/textToAdd
			if (pda.host_program.message_on && pda.owner) // is their messenger enabled, is their pda swiped in??
				textToAdd += "<br>[bicon(pda)][pda.name] - <a href='byond://?src=\ref[mainframe];net_id=[pda.net_id];owner=[pda.owner]'><u>*MESSAGE*</u></a>" // see ai.dm under Topic() to continue from here!
			else if (pda.owner) // ownerless PDAs will not render, but we'll tell the AI when someone's messenger is disabled!
				textToAdd += "<br>[bicon(pda)][pda.name] - *MESSENGER DISABLED*"
			. += textToAdd
			if (pda.owner) hasPDA = TRUE // we need at least ONE pda to be visible, or else we add the text below
		if (!hasPDA)
			. += "<br>*No PDA detected!*"

/// Override MouseDrop_T instead of this. Call this instead of MouseDrop_T, but you probably shouldn't!
/atom/proc/_MouseDrop_T(dropped, user, src_location, over_location, src_control, over_control, params)
	SHOULD_NOT_OVERRIDE(TRUE)
	SPAWN(0) // Yes, things break if this isn't a spawn.
		if(SEND_SIGNAL(src, COMSIG_ATOM_MOUSEDROP_T, dropped, user, src_location, over_location, src_control, over_control, params))
			return
		src.MouseDrop_T(dropped, user, src_location, over_location, over_control, src_control, params)

/atom/proc/MouseDrop_T(dropped, user, src_location, over_location, over_control, src_control, params)
	PROTECTED_PROC(TRUE)
	return

/atom/proc/Attackhand(mob/user as mob)
	SHOULD_NOT_OVERRIDE(1)
	if(SEND_SIGNAL(src, COMSIG_ATTACKHAND, user))
		return
	src.attack_hand(user)

/atom/proc/attack_hand(mob/user)
	PROTECTED_PROC(TRUE)
	if (flags & TGUI_INTERACTIVE)
		return ui_interact(user)
	return

/atom/proc/attack_ai(mob/user as mob)
	return

///wrapper proc for /atom/proc/attackby so that signals are always sent. Call this, but do not override it.
/atom/proc/Attackby(obj/item/W, mob/user, params, is_special = 0)
	SHOULD_NOT_OVERRIDE(1)
	if(SEND_SIGNAL(W, COMSIG_ITEM_ATTACKBY_PRE, src, user))
		return
	if(SEND_SIGNAL(src,COMSIG_ATTACKBY,W,user, params, is_special))
		return
	src.attackby(W, user, params, is_special)

//mbc : sorry, i added a 'is_special' arg to this proc to avoid race conditions.
///internal proc for when an atom is attacked by an item. Override this, but do not call it,
/atom/proc/attackby(obj/item/W, mob/user, params, is_special = 0)
	PROTECTED_PROC(TRUE)
	src.material?.triggerOnHit(src, W, user, 1)
	if (user && W && !(W.flags & SUPPRESSATTACK))
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

/proc/getTexturedIcon(var/atom/A, var/texture = "damaged")//, var/key = "texture")
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
	return mask

/proc/getTexturedImage(var/atom/A, var/texture = "damaged", var/blendMode = BLEND_MULTIPLY)//, var/key = "texture")
	if (!A)
		return
	var/mask = getTexturedIcon(A, texture)
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

	if (A?.wear_image) //Wire: Fix for: Cannot read null.icon
		var/icon/mask = null
		mask = icon(A.wear_image.icon, A.wear_image.icon_state)
		mask.MapColors(1,1,1, 1,1,1, 1,1,1, 1,1,1)
		mask.Blend(tex, ICON_MULTIPLY)
		var/image/finished = image(mask,"")
		finished.blend_mode = blendMode
		return finished

	return null

/// Override mouse_drop instead of this. Call this instead of mouse_drop, but you probably shouldn't!
/atom/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!isatom(over_object))
		return
	if (isalive(usr) && !isintangible(usr) && isghostdrone(usr) && ismob(src) && src != usr)
		return // Stops ghost drones from MouseDropping mobs
	over_object._MouseDrop_T(src, usr, src_location, over_location, src_control, over_control, params)
	if (SEND_SIGNAL(src, COMSIG_ATOM_MOUSEDROP, usr, over_object, src_location, over_location, src_control, over_control, params))
		return
	src.mouse_drop(over_object, src_location, over_location, src_control, over_control, params)

/atom/proc/mouse_drop(atom/over_object, src_location, over_location, src_control, over_control, params)
	PROTECTED_PROC(TRUE)
	return

/atom/proc/relaymove(mob/user, direction, delay, running)
	.= 0

/atom/proc/on_reagent_change(var/add = 0) // if the reagent container just had something added, add will be 1.
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_REAGENT_CHANGE)
	return

/atom/proc/Bumped(AM as mob|obj)
	SHOULD_NOT_SLEEP(TRUE)
	return

/// override this instead of Bump
/atom/movable/proc/bump(atom/A)
	SHOULD_NOT_SLEEP(TRUE)
	return

/atom/movable/Bump(var/atom/A as mob|obj|turf|area)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!(A.flags & ON_BORDER))
		for(var/atom/other in get_turf(A))
			if((other.flags & ON_BORDER) && !other.Cross(src))
				return
	if(!(src.flags & ON_BORDER))
		for(var/atom/other in get_turf(src))
			if((other.flags & ON_BORDER) && !other.CheckExit(src, get_turf(A)))
				return
	bump(A)
	if (!QDELETED(A))
		A.Bumped(src)
	..()

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
/atom/movable/proc/set_loc(atom/newloc)
	SHOULD_CALL_PARENT(TRUE)
	if(QDELETED(src) && !isnull(newloc))
		CRASH("Tried to call set_loc on [src] (\ref[src] [src.type]) to non-null location: [newloc] (\ref[newloc] [newloc?.type])")

	if (loc == newloc)
		SEND_SIGNAL(src, COMSIG_MOVABLE_SET_LOC, loc)
		return src

	if (ismob(src)) // fuck haxploits
		if(src:client && src:client:player && src:client:player:shamecubed)
			loc = src:client:player:shamecubed
			return

	var/area/my_area = get_area(src)
	var/area/new_area = get_area(newloc)

	var/atom/oldloc = loc
	loc = newloc

#ifdef RUNTIME_CHECKING
	if(oldloc == loc)
		stack_trace("loc change in set_loc denied - check for paradoxes")
#endif

	src.last_move = 0

	SEND_SIGNAL(src, COMSIG_MOVABLE_SET_LOC, oldloc)
	actions.interrupt(src, INTERRUPT_MOVE)

	oldloc?.Exited(src, newloc)

	if(isturf(oldloc))
		for(var/atom/A in oldloc)
			if(A != src)
				A.Uncrossed(src)

	// area.Exited called if we are on turfs and changing areas or if exiting a turf into a non-turf (just like Move does it internally)
	if((my_area != new_area || !isturf(newloc)) && isturf(oldloc))
		my_area.Exited(src, newloc)

	newloc?.Entered(src, oldloc)

	if(isturf(newloc))
		for(var/atom/A in newloc)
			if(A != src)
				A.Crossed(src)

	// area.Entered called if we are on turfs and changing areas or if entering a turf from a non-turf (just like Move does it internally)
	if((my_area != new_area || !isturf(oldloc)) && isturf(newloc))
		new_area.Entered(src, oldloc)

	if (islist(src.attached_objs) && length(attached_objs))
		for (var/atom/movable/M in src.attached_objs)
			M.set_loc(src.loc)

	if (isturf(last_turf) && (src.event_handler_flags & USE_PROXIMITY))
		last_turf.checkinghasproximity = max(last_turf.checkinghasproximity-1, 0)
		for (var/turf/T2 in range(1, last_turf))
			T2.neighcheckinghasproximity--

	if (isturf(src.loc))
		last_turf = src.loc
		if (src.event_handler_flags & USE_PROXIMITY)
			last_turf.checkinghasproximity++
			for (var/turf/T2 in range(1, last_turf))
				T2.neighcheckinghasproximity++
	else
		last_turf = null

	if(src.medium_lights)
		update_medium_light_visibility()
	if (src.mdir_lights)
		update_mdir_light_visibility(src.dir)

	return src

//reason for having this proc is explained below
/atom/proc/set_density(var/newdensity)
	src.density = HAS_ATOM_PROPERTY(src, PROP_ATOM_NEVER_DENSE) ? 0 : newdensity

/atom/proc/set_opacity(var/newopacity)
	SHOULD_CALL_PARENT(TRUE)

	if (newopacity == src.opacity)
		return // Why even bother

	var/oldopacity = src.opacity
	src.opacity = newopacity

	SEND_SIGNAL(src, COMSIG_ATOM_SET_OPACITY, oldopacity)

	if (isturf(src.loc))
		// Not a turf, so we must send a signal to the turf
		SEND_SIGNAL(src.loc, COMSIG_TURF_CONTENTS_SET_OPACITY, oldopacity, src)

	// Below is a "smart" signal on a turf that only get called when the opacity
	// actually changes in a meaningfull way. If atom is on a turf and we are
	// obscuring vision in a turf that was originally not obscured. Or we are on a
	// turf that is not obscuring vision, we were obscuring vision and are not
	// anymore.
	if (isturf(src.loc) && ((src.loc.opacity == 0 && src.opacity == 1) || (src.loc.opacity == 0 && oldopacity == 1 && src.opacity == 0)))
		var/turf/T = src.loc
		T.contents_set_opacity_smart(oldopacity, src)

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

// Setup USE_PROXIMITY turfs
/atom/proc/setup_use_proximity()
	src.event_handler_flags |= USE_PROXIMITY
	if (isturf(src.loc))
		var/turf/T = src.loc
		T.checkinghasproximity++
		for (var/turf/T2 in range(1, T))
			T2.neighcheckinghasproximity++

/atom/proc/remove_use_proximity()
	src.event_handler_flags = src.event_handler_flags & ~USE_PROXIMITY
	if (isturf(src.loc))
		var/turf/T = src.loc
		if (T.checkinghasproximity > 0)
			T.checkinghasproximity--
		for (var/turf/T2 in range(1, T))
			if (T2.neighcheckinghasproximity > 0)
				T2.neighcheckinghasproximity--

// auto-connecting sprites
/// Check a turf and its contents to see if they're a valid auto-connection target
/atom/proc/should_auto_connect(turf/T, connect_to = list(), list/exceptions = list(), cross_areas = TRUE)
	if (!T) // nothing to connect to
		return FALSE
	if (!cross_areas && (get_area(T) != get_area(src))) // don't connect across areas
		return FALSE

	// quick path, basically istype(T, anything in connect-except)
	if (connect_to[T.type] && !exceptions[T.type])
		return TRUE

	// slow 😩
	for (var/atom/movable/AM in T)
		if (!AM.anchored)
			continue
		if (connect_to[AM.type] && !exceptions[AM.type])
			return TRUE
	return FALSE

/**
 * Return a bitflag that represents all potential connected icon_states
 *
 * connecting with diagonal tiles require additional bitflags
 * i.e. there is a difference between N & E, and N & E & NE
 *
 * N, S, E, W, NE, SE, SW, NW
 *
 * 1, 2, 4, 8, 16, 32, 64, 128
 *
 * connect_diagonals 0 = no diagonal sprites, 1 = diagonal only if both adjacent cardinals are present, 2 = always allow diagonals
 */
/atom/proc/get_connected_directions_bitflag(list/valid_atoms = list(), list/exceptions = list(), cross_areas = TRUE, connect_diagonal = 0)
	var/ordir = null
	var/connected_directions = 0
	if (!valid_atoms || !islist(valid_atoms))
		return

	// cardinals first
	for (var/dir in cardinal)
		var/turf/CT = get_step(src, dir)
		if (should_auto_connect(CT, valid_atoms, exceptions, cross_areas))
			connected_directions |= dir

	if (connect_diagonal)
		for (var/i = 1 to 4)  // needed for bitshift
			ordir = ordinal[i]
			if (connect_diagonal < 2 && (ordir & connected_directions) != ordir)
				continue
			var/turf/OT = get_step(src, ordir)
			if (should_auto_connect(OT, valid_atoms, exceptions, cross_areas))
				connected_directions |= 8 << i
	return connected_directions

/proc/scaleatomall()
	var/scalex = input(usr,"X Scale","1 normal, 2 double etc","1") as num
	var/scaley = input(usr,"Y Scale","1 normal, 2 double etc","1") as num
	logTheThing(LOG_ADMIN, usr, "scaled every goddamn atom by X:[scalex] Y:[scaley]")
	logTheThing(LOG_DIARY, usr, "scaled every goddamn atom by X:[scalex] Y:[scaley]", "admin")
	message_admins("[key_name(usr)] scaled every goddamn atom by X:[scalex] Y:[scaley]")
	for(var/atom/A in world)
		A.Scale(scalex,scaley)
		LAGCHECK(LAG_LOW)
	return

/proc/rotateatomall()
	var/rot = input(usr,"Rotation","Rotation","0") as num
	logTheThing(LOG_ADMIN, usr, "rotated every goddamn atom by [rot] degrees")
	logTheThing(LOG_DIARY, usr, "rotated every goddamn atom by [rot] degrees", "admin")
	message_admins("[key_name(usr)] rotated every goddamn atom by [rot] degrees")
	for(var/atom/A in world)
		A.Turn(rot)
		LAGCHECK(LAG_LOW)
	return

/proc/scaleatom()
	var/atom/target = input(usr,"Target","Target") as mob|obj in world
	var/scalex = input(usr,"X Scale","1 normal, 2 double etc","1") as num
	var/scaley = input(usr,"Y Scale","1 normal, 2 double etc","1") as num
	logTheThing(LOG_ADMIN, usr, "scaled [target] by X:[scalex] Y:[scaley]")
	logTheThing(LOG_DIARY, usr, "scaled [target] by X:[scalex] Y:[scaley]", "admin")
	message_admins("[key_name(usr)] scaled [target] by X:[scalex] Y:[scaley]")
	target.Scale(scalex, scaley)
	return

/proc/rotateatom()
	var/atom/target = input(usr,"Target","Target") as mob|obj in world
	var/rot = input(usr,"Rotation","Rotation","0") as num
	logTheThing(LOG_ADMIN, usr, "rotated [target] by [rot] degrees")
	logTheThing(LOG_DIARY, usr, "rotated [target] by [rot] degrees", "admin")
	message_admins("[key_name(usr)] rotated [target] by [rot] degrees")
	target.Turn(rot)
	return

/atom/movable/proc/gift_wrap(var/style = FALSE, var/xmas_style = FALSE)
	var/obj/item/gift/G = new /obj/item/gift(src.loc)
	var/gift_type
	if(isitem(src))
		var/obj/item/gifted_item = src
		G.size = gifted_item.w_class
		G.w_class = G.size + 1
		gift_type = "gift[clamp(G.size, 1, 3)]"
		gifted_item.set_loc(G)
	else if(ismob(src) || istype(src, /obj/critter))
		G.size = 3
		G.w_class = G.size + 1
		gift_type = "strange"
		if(ismob(src))
			var/mob/gifted_mob = src
			gifted_mob.set_loc(G)
		else
			var/obj/critter/gifted_critter = src
			gifted_critter.set_loc(G)
	else
		var/obj/gifted_obj = src
		G.size = 3
		G.w_class = W_CLASS_BULKY
		gift_type = "gift3"
		gifted_obj.set_loc(G)
	var/random_style
	if (!style)
		if(!xmas_style)
			random_style = rand(1,8)
		else
			random_style = pick("r", "rs", "g", "gs")
		G.icon_state = "[gift_type]-[random_style]"
	else
		G.icon_state = "[gift_type]-[style]"
	G.gift = src

	return G
