/obj
	var/real_name = null
	var/real_desc = null
	var/m_amt = 0	// metal
	var/g_amt = 0	// glass
	var/w_amt = 0	// waster amounts
	var/quality = 1
	var/adaptable = 0

	var/deconstruct_flags = DECON_NONE

	var/datum/artifact/artifact = null
	var/cannot_be_stored = FALSE
	var/move_triggered = 0
	var/object_flags = 0

	animate_movement = 2
//	desc = SPAN_ALERT("HI THIS OBJECT DOESN'T HAVE A DESCRIPTION MAYBE IT SHOULD???")
//heh no not really

	var/_health = 100
	var/_max_health = 100

	/// if gun/bullet related, forensic profile of it
	var/forensic_ID = null

	New()
		. = ..()
		if (HAS_FLAG(object_flags, HAS_DIRECTIONAL_BLOCKING))
			var/turf/T = get_turf(src)
			T?.UpdateDirBlocks()
		src.update_access_from_txt()
#ifdef CHECK_MORE_RUNTIMES
		if (src.req_access && !islist(src.req_access))
			stack_trace("[src] ([src.type]) initialized at \[[src.x], [src.y], [src.z]\] with non-list req_access >:(")
#endif

	Move(NewLoc, direct)
		if(usr==0) usr = null
		if (HAS_FLAG(object_flags, HAS_DIRECTIONAL_BLOCKING))
			var/turf/old_loc = get_turf(src)
			. = ..()
			var/turf/T = get_turf(NewLoc)
			T?.UpdateDirBlocks()
			old_loc?.UpdateDirBlocks()
		else
			. = ..()

	set_loc(newloc)
		if (HAS_FLAG(object_flags, HAS_DIRECTIONAL_BLOCKING))
			var/turf/old_loc = get_turf(src)
			. = ..()
			var/turf/T = get_turf(newloc)
			T?.UpdateDirBlocks()
			old_loc?.UpdateDirBlocks()
		else
			. = ..()

	set_dir(new_dir)
		. = ..()
		if (HAS_FLAG(object_flags, HAS_DIRECTIONAL_BLOCKING))
			var/turf/T = get_turf(src)
			T?.UpdateDirBlocks()

	proc/setHealth(var/value)
		var/prevHealth = _health
		_health = min(value, _max_health)
		updateHealth(prevHealth)

	proc/changeHealth(var/change = 0)
		var/prevHealth = _health
		_health += change
		_health = min(_health, _max_health)
		updateHealth(prevHealth)

	proc/updateHealth(var/prevHealth)
		if(_health <= 0)
			onDestroy()

	UpdateName()
		src.name = "[name_prefix(null, 1)][src.real_name ? src.real_name : initial(src.name)][name_suffix(null, 1)]"

	proc/move_callback(var/mob/M, var/turf/source, var/turf/target)
		return

	proc/onDestroy()
		qdel(src)
		return

	New()
		setupProperties()
		. = ..()

	ex_act(severity)
		src.material_trigger_on_explosion(severity)
		switch(severity)
			if(1)
				changeHealth(-100)
				return
			if(2)
				changeHealth(-70)
				return
			if(3)
				changeHealth(-40)
				return

	onMaterialChanged()
		..()
		if(istype(src.material))
			pressure_resistance = max(20, (src.material.getProperty("density") - 5) * ONE_ATMOSPHERE)
			throwforce = src.material.getProperty("hard")
			throwforce = max(throwforce, initial(throwforce))
			if(initial(src.opacity) && src.material.getAlpha() <= MATERIAL_ALPHA_OPACITY)
				set_opacity(0)
			else if(initial(src.opacity) && !src.opacity && src.material.getAlpha() > MATERIAL_ALPHA_OPACITY)
				set_opacity(1)

	disposing()
		for(var/mob/M in src.contents)
			M.set_loc(src.loc)
		tag = null
		if (artifact && !isnum(artifact))
			qdel(artifact)
			artifact = null
		remove_dialogs()
		..()

	UpdateName()
		if (isnull(src.real_name) && !isnull(src.name))
			src.real_name = src.name
		src.name = "[name_prefix(null, 1)][src.real_name || initial(src.name)][name_suffix(null, 1)]"

	proc/can_access_remotely(mob/user)
		. = FALSE

	/**
	* Determines whether or not the user can remote access devices.
	* This is typically limited to Borgs and AI things that have
	* inherent packet abilities.
	*/
	proc/can_access_remotely_default(mob/user)
		if(isAI(user))
			var/mob/living/silicon/ai/mainframe = user
			if(isAIeye(user))
				var/mob/living/intangible/aieye/aEye = user
				mainframe = aEye.mainframe
			if((mainframe.z == src.z) || (inunrestrictedz(src) && inonstationz(mainframe)))
				. = TRUE
		else if(issilicon(user))
			if (ishivebot(user) || isrobot(user))
				var/mob/living/silicon/robot/R = user
				return !R.module_active
			else if(isghostdrone(user))
				var/mob/living/silicon/ghostdrone/G = user
				return !G.active_tool
			. = TRUE

	proc/client_login(var/mob/user)
		return

	proc/clone(var/newloc = null)
		var/obj/O = new type()
		O.name = name
		O.quality = quality
		O.icon = icon
		O.icon_state = icon_state
		O.set_dir(src.dir)
		O.desc = desc
		O.pixel_x = pixel_x
		O.pixel_y = pixel_y
		O.color = color
		O.invisibility = invisibility
		O.alpha = alpha
		O.anchored = anchored
		O.set_density(density)
		O.set_opacity(opacity)
		if (material)
			O.setMaterial(material)
		O.transform = transform
		if (newloc)
			O.set_loc(newloc)
		return O

	proc/pixelaction(atom/target, params, mob/user, reach)
		return 0

	proc/can_arm_attach()
		return !(src.object_flags & NO_ARM_ATTACH )

	assume_air(datum/air_group/giver)
		if (loc)
			return loc.assume_air(giver)
		else
			return null

	remove_air(amount)
		if (loc)
			return loc.remove_air(amount)
		else
			return null

	return_air(direct = FALSE)
		if (loc && !direct)
			return loc.return_air()
		else
			return null

	proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request, mult)
		//Return: (NONSTANDARD)
		//		null if object handles breathing logic for lifeform
		//		datum/air_group to tell lifeform to process using that breath return
		//DEFAULT: Take air from turf to give to have mob process
		if (breath_request>0)
			var/datum/gas_mixture/environment = return_air()
			if (environment)
				var/breath_moles = TOTAL_MOLES(environment)*BREATH_PERCENTAGE*mult
				return remove_air(breath_moles)
			else
				return remove_air(breath_request * mult)
		else
			return null

	proc/initialize(player_caused_init) // Did a player cause the init of this object? Currently needed so atmos knows whether or not to call its neighbors, avoiding infinite loops.


	proc/shatter_chemically(var/projectiles = TRUE) //!shatter effect, caused by chemicals inside object, should return TRUE if object actually shatters
		return FALSE

	clamp_act(mob/clamper, obj/item/clamp)
		return src.shatter_chemically()

	proc/get_chemical_effect_position() //!how many pixels up or down chemistry reaction animations should shift, to fit the item it's reacting in
		return 7 //default is up a bit since most objects are centered

	attackby(obj/item/I, mob/user)
// grabsmash
		if (istype(I, /obj/item/grab/))
			var/obj/item/grab/G = I
			if  (!grab_smash(G, user))
				return ..()
			else return
		return ..()

	serialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		F["[path].type"] << type
		serialize_icon(F, path, sandbox)
		F["[path].name"] << name
		F["[path].dir"] << dir
		F["[path].desc"] << desc
		F["[path].color"] << color
		F["[path].density"] << density
		F["[path].opacity"] << opacity
		F["[path].anchored"] << anchored
		F["[path].pixel_x"] << pixel_x
		F["[path].pixel_y"] << pixel_y
		F["[path].layer"] << layer
		matrix_serializer(F, path, sandbox, "transform", transform)

	deserialize(var/savefile/F, var/path, var/datum/sandbox/sandbox)
		deserialize_icon(F, path, sandbox)
		F["[path].name"] >> name
		F["[path].dir"] >> dir
		F["[path].desc"] >> desc
		F["[path].color"] >> color
		F["[path].density"] >> density
		F["[path].opacity"] >> opacity
		set_opacity(opacity)
		F["[path].anchored"] >> anchored
		F["[path].pixel_x"] >> pixel_x
		F["[path].pixel_y"] >> pixel_y
		if (F["[path].layer"]) //I added this on 19/10/15, many people have older saves so this is here to not break them - Wire
			F["[path].layer"] >> layer
		transform = matrix_deserializer(F, path, sandbox, "transform", transform)
		return DESERIALIZE_OK

	deserialize_postprocess()
		return

/obj/bedsheetbin
	name = "linen bin"
	desc = "A bin for containing bedsheets."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bedbin"
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH
	var/amount = 23
	anchored = ANCHORED

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/clothing/suit/bedsheet))
			qdel(W)
			src.amount++
		return

	attack_hand(mob/user)
		add_fingerprint(user)
		if (src.amount >= 1)
			src.amount--
			new /obj/item/clothing/suit/bedsheet(src.loc)
			if (src.amount <= 0)
				src.icon_state = "bedbin0"
		else
			boutput(user, SPAN_ALERT("There's no bedsheets left in [src]!"))

	get_desc()
		. += "There's [src.amount ? src.amount : "no"] bedsheet[s_es(src.amount)] in [src]."

/obj/towelbin
	name = "towel bin"
	desc = "A bin for containing towels."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "bedbin"
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH
	var/amount = 23
	anchored = ANCHORED

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/clothing/under/towel))
			qdel(W)
			src.amount++
		return

	attack_hand(mob/user)
		add_fingerprint(user)
		if (src.amount >= 1)
			src.amount--
			new /obj/item/clothing/under/towel(src.loc)
			if (src.amount <= 0)
				src.icon_state = "bedbin0"
		else
			boutput(user, SPAN_ALERT("There's no towels left in [src]!"))

	get_desc()
		. += "There's [src.amount ? src.amount : "no"] towel[s_es(src.amount)] in [src]."

/obj/overlay
	name = "overlay"
	anchored = ANCHORED
	pass_unstable = FALSE
	mat_changename = 0
	mat_changedesc = 0
	event_handler_flags = IMMUNE_MANTA_PUSH | IMMUNE_TRENCH_WARP
	density = 0

	updateHealth()
		return

	meteorhit(obj/M as obj)
		if (isrestrictedz(src.z))
			return
		else
			return ..()

	ex_act(severity)
		if (isrestrictedz(src.z))
			return
		else
			return ..()

	track_blood()
		src.tracked_blood = null
		return

/obj/overlay/self_deleting
	New(newloc, deleteTimer)
		..()
		if (deleteTimer)
			SPAWN(deleteTimer)
				qdel(src)

/obj/projection
	name = "Projection"
	anchored = ANCHORED

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/proc/alter_health()
	return 1

/// Whether or not to hide something based on the value of hide, usually whether or not the turf is intact.
/obj/proc/hide(hide)
	return

/obj/proc/replace_with_explosive()
	var/obj/O = src
	if (alert("Are you sure? This will irreversibly replace this object with a copy that gibs the first person trying to touch it!", "Replace with explosive", "Yes", "No") == "Yes")
		message_admins("[key_name(usr)] replaced [O] ([log_loc(O)]) with an explosive replica.")
		logTheThing(LOG_ADMIN, usr, "replaced [O] ([log_loc(O)]) with an explosive replica.")
		var/obj/replica = new /obj/item/card/id/captains_spare/explosive(O.loc)
		replica.icon = O.icon
		replica.icon_state = O.icon_state
		replica.name = O.name
		replica.desc = O.desc
		replica.set_density(O.density)
		replica.set_opacity(O.opacity)
		replica.anchored = O.anchored
		replica.layer = O.layer - 0.05
		replica.pixel_x = O.pixel_x
		replica.pixel_y = O.pixel_y
		replica.set_dir(O.dir)
		qdel(O)

/obj/proc/place_on(obj/item/W as obj, mob/user as mob, params, imprecise = FALSE)
	. = FALSE
	if (!islist(params)) params = params2list(params)
	if (W && !isghostdrone(user) && W.should_place_on(src, params)) // im allowing borgs to do this when its specifically overridden into a mousedrop - mylie
		var/dirbuffer //*hmmpf* it's not like im a hacky coder or anything... (＃￣^￣)
		dirbuffer = W.dir //though actually this will preserve item rotation when placed on tables so they don't rotate when placed. (this is a niche bug with silverware, but I thought I might as well stop it from happening with other things <3)
		if (user)
			if (W.cant_drop) // this should handle borgs dropping their tools, anyway? - mylie
				return
			user.drop_item()
		if(W.dir != dirbuffer)
			W.set_dir(dirbuffer)
		W.set_loc(src.loc)
		if (imprecise) // place item imprecisely by randomising offset
			W.pixel_x = rand(-10, 10) // offsets avoid the edges just for niceness
			W.pixel_y = rand(-10, 10)
		else if (islist(params) && params["icon-y"] && params["icon-x"])
			W.pixel_x = text2num(params["icon-x"]) - 16
			W.pixel_y = text2num(params["icon-y"]) - 16
		if(W.layer <= src.layer)
			W.layer = src.layer + 0.1
		. = TRUE

/obj/proc/receive_silicon_hotkey(var/mob/user)
	//A wee stub to handle other objects implementing the AI keys
	//DEBUG_MESSAGE("[src] got a silicon hotkey from [user], containing: [user.client.check_key(KEY_OPEN) ? "KEY_OPEN" : ""] [user.client.check_key(KEY_BOLT) ? "KEY_BOLT" : ""] [user.client.check_key(KEY_SHOCK) ? "KEY_SHOCK" : ""]")
	return 0

/obj/proc/mob_flip_inside(var/mob/user)
	user.show_text(SPAN_ALERT("You leap and slam against the inside of [src]! Ouch!"))
	user.changeStatus("unconscious", 4 SECONDS)
	user.changeStatus("knockdown", 4 SECONDS)
	src.visible_message(SPAN_ALERT("<b>[src]</b> emits a loud thump and rattles a bit."))

	animate_storage_thump(src)

/obj/proc/mob_resist_inside(var/mob/user)
	return

/obj/hitby(atom/movable/AM, datum/thrown_thing/thr)
	. = ..()
	if(!.)
		. = 'sound/impact_sounds/Generic_Stab_1.ogg'
	if(!src.anchored)
		step(src, AM.dir)
	src.ArtifactStimulus("force", AM.throwforce)
	if(AM.throwforce >= 40)
		if(!src.anchored && !src.throwing)
			src.throw_at(get_edge_target_turf(src,get_dir(AM, src)), 10, 1)
		else if(AM.throwforce >= 80 && !isrestrictedz(src.z))
			src.meteorhit(AM)

/obj/proc/become_mimic()
	var/mob/living/critter/mimic/replacer = new(get_turf(src.loc))
	replacer.disguise_as(src)
	qdel(src)


/obj/proc/admin_command_obj_speak()
	set name = "Object Speak"
	var/msg = tgui_input_text(usr, "Speak message through [src]", "Speak", "")
	if (msg)
		src.obj_speak(msg)

/obj/proc/obj_speak(message)
	var/image/chat_maptext/chat_text = make_chat_maptext(src, message, "color: '#DDDDDD';", alpha = 255)

	var/list/mob/targets = null
	var/mob/holder = src
	while(holder && !istype(holder))
		holder = holder.loc
	ENSURE_TYPE(holder)
	if(!holder)
		targets = hearers(src, null)
	else
		targets = list(holder)
		chat_text.plane = PLANE_HUD
		chat_text.layer = 999

	for(var/mob/O in targets)
		O.show_message(SPAN_SAY("[SPAN_NAME("[src.name]")] says, [SPAN_MESSAGE("\"[message]\"")]"), 2, assoc_maptext = chat_text)

/obj/proc/ghost_observe_occupant(mob/viewer, mob/occupant)
	if(istype(viewer, /mob/dead/observer) && viewer.client && !viewer.client.keys_modifier && occupant)
		var/mob/dead/observer/O = viewer
		O.insert_observer(occupant)
		return TRUE

/obj/proc/after_abcu_spawn()

/// creates an id profile for any forenics purpose. override as needed
/obj/proc/CreateID()
	. = ""

	do
		for(var/i = 1 to 10) // 20 characters are way too fuckin' long for anyone to care about
			. += "[pick(numbersAndLetters)]"
	while(. in forensic_IDs)

/obj/proc/become_frame(mob/user, flatpack = FALSE)
	// Prevent glue based frame exploits
	var/atom/A = src
	A.unglue_attached_to()
	var/turf/target_loc = get_turf(src)
	var/obj/item/electronics/frame/F = null
	if (flatpack)
		F = new /obj/item/electronics/frame/flatpack(target_loc)
	else
		F = new(target_loc)
	F.name = "[src.name] frame"
	if(src.deconstruct_flags & DECON_DESTRUCT)
		F.store_type = src.type
		qdel(src)
	else
		F.deconstructed_thing = src
		if(ismob(src.loc))
			var/mob/M = src.loc
			M.u_equip(src)
		src.set_loc(F)
	// move frame to the location after object is gone, so crushers do not crusher themselves
	F.viewstat = 2
	F.secured = 2
	if (flatpack)
		F.icon_state = "dbox_alt"
	else
		F.icon_state = "dbox_big"
	F.w_class = W_CLASS_BULKY
	if(!QDELETED(src))
		src.was_deconstructed_to_frame(user)
		F.RegisterSignal(src, COMSIG_ATOM_ENTERED, TYPE_PROC_REF(/obj/item/electronics/frame, kickout))
	return F
