/obj
	//var/datum/module/mod		//not used
	var/real_name = null
	var/real_desc = null
	var/m_amt = 0	// metal
	var/g_amt = 0	// glass
	var/w_amt = 0	// waster amounts
	var/quality = 1
	var/adaptable = 0

	var/is_syndicate = 0
	var/list/mats = 0
	var/deconstruct_flags = DECON_NONE

	var/mechanics_type_override = null //Fix for children of scannable items being reproduced in mechanics
	var/artifact = null
	var/move_triggered = 0
	var/object_flags = 0
	var/mob/living/buckled_mob

	proc/move_trigger(var/mob/M, var/kindof)
		var/atom/movable/x = loc
		while (x && !isarea(x) && x != M)
			x = x.loc
		if (!x || isarea(x))
			return 0
		return 1

	animate_movement = 2
//	desc = "<span class='alert'>HI THIS OBJECT DOESN'T HAVE A DESCRIPTION MAYBE IT SHOULD???</span>"
//heh no not really

	var/_health = 100
	var/_max_health = 100
	proc/setHealth(var/value)
		var/prevHealth = _health
		_health = min(value, _max_health)
		updateHealth(prevHealth)
		return
	proc/changeHealth(var/change = 0)
		var/prevHealth = _health
		_health += change
		_health = min(_health, _max_health)
		updateHealth(prevHealth)
		return
	proc/updateHealth(var/prevHealth)
		/*
		if(_health <= 0)
			onDestroy()
		else
			if((_health > 75) && !(prevHealth > 75))
				UpdateOverlays(null, "damage")
			else if((_health <= 75 && _health > 50) && !(prevHealth <= 75 && prevHealth > 50))
				setTexture("damage1", BLEND_MULTIPLY, "damage")
			else if((_health <= 50 && _health > 25) && !(prevHealth <= 50 && prevHealth > 25))
				setTexture("damage2", BLEND_MULTIPLY, "damage")
			else if((_health <= 25) && !(prevHealth <= 25))
				setTexture("damage3", BLEND_MULTIPLY, "damage")
		*/
		return
	proc/onDestroy()
		src.visible_message("<span class='alert'><b>[src] is destroyed.</b></span>")
		qdel(src)
		return

	New()
		setupProperties()
		. = ..()

	ex_act(severity)
		if(src.material)
			src.material.triggerExp(src, severity)
		switch(severity)
			if(1.0)
				changeHealth(-95)
				return
			if(2.0)
				changeHealth(-70)
				return
			if(3.0)
				changeHealth(-40)
				return
			else
		return

	proc/ex_act_third(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if (prob(66))
					qdel(src)
					return
			if(3.0)
				if (prob(33))
					qdel(src)
					return
			else
		return


	onMaterialChanged()
		..()
		if(istype(src.material))
			pressure_resistance = round((material.getProperty("density") + material.getProperty("density")) / 2)
			throwforce = round(max(material.getProperty("hard"),1) / 8)
			throwforce = max(throwforce, initial(throwforce))
			quality = src.material.quality
			if(initial(src.opacity) && src.material.alpha <= MATERIAL_ALPHA_OPACITY)
				RL_SetOpacity(0)
			else if(initial(src.opacity) && !src.opacity && src.material.alpha > MATERIAL_ALPHA_OPACITY)
				RL_SetOpacity(1)
		return

	disposing()
		mats = null
		if (artifact && !isnum(artifact))
			artifact:holder = null
		remove_dialogs()
		if (buckled_mob)
			unbuckle_mob(buckled_mob)
		..()

	proc/client_login(var/mob/user)
		return

	proc/clone(var/newloc = null)
		var/obj/O = new type()
		O.name = name
		O.quality = quality
		O.icon = icon
		O.icon_state = icon_state
		O.dir = dir
		O.desc = desc
		O.pixel_x = pixel_x
		O.pixel_y = pixel_y
		O.color = color
		O.invisibility = invisibility
		O.alpha = alpha
		O.anchored = anchored
		O.set_density(density)
		O.opacity = opacity
		if (material)
			O.setMaterial(material)
		O.transform = transform
		if (newloc)
			O.set_loc(newloc)
		return O

	proc/pixelaction(atom/target, params, mob/user, reach)
		return 0

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

	return_air()
		if (loc)
			return loc.return_air()
		else
			return null

	proc/handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
		//Return: (NONSTANDARD)
		//		null if object handles breathing logic for lifeform
		//		datum/air_group to tell lifeform to process using that breath return
		//DEFAULT: Take air from turf to give to have mob process
		if (breath_request>0)
			var/datum/gas_mixture/environment = return_air()
			if (environment)
				var/breath_moles = environment.total_moles()*BREATH_PERCENTAGE
				return remove_air(breath_moles)
			else
				return remove_air(breath_request)
		else
			return null

	proc/initialize()

	attackby(obj/item/I as obj, mob/user as mob)
// grabsmash
		if (istype(I, /obj/item/grab/))
			var/obj/item/grab/G = I
			if  (!grab_smash(G, user))
				return ..(I, user)
			else return
		return ..(I, user)


	MouseDrop(atom/over_object as mob|obj|turf)
		..()
		if (iswraith(usr))
			if(!src.anchored && isitem(src))
				src.throw_at(over_object, 7, 1)
				logTheThing("combat", usr, null, "throws \the [src] with wraith telekinesis.")

		else if(usr.bioHolder && usr.bioHolder.HasEffect("telekinesis_drag") && istype(src, /obj) && isturf(src.loc) && isalive(usr)  && usr.canmove && get_dist(src,usr) <= 7 )
			var/datum/bioEffect/TK = usr.bioHolder.GetEffect("telekinesis_drag")

			if(!src.anchored && (isitem(src) || TK.variant == 2))
				src.throw_at(over_object, 7, 1)
				logTheThing("combat", usr, null, "throws \the [src] with telekinesis.")

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
		RL_SetOpacity(opacity)
		F["[path].anchored"] >> anchored
		F["[path].pixel_x"] >> pixel_x
		F["[path].pixel_y"] >> pixel_y
		if (F["[path].layer"]) //I added this on 19/10/15, many people have older saves so this is here to not break them - Wire
			F["[path].layer"] >> layer
		transform = matrix_deserializer(F, path, sandbox, "transform", transform)
		return DESERIALIZE_OK

	deserialize_postprocess()
		return

/obj/proc/get_movement_controller(mob/user)
	return

/obj/proc/alter_health()
	return 1

/obj/proc/hide(h)
	return

/obj/proc/replace_with_explosive()
	var/obj/O = src
	if (alert("Are you sure? This will irreversibly replace this object with a copy that gibs the first person trying to touch it!", "Replace with explosive", "Yes", "No") == "Yes")
		message_admins("[key_name(usr)] replaced [O] ([showCoords(O.x, O.y, O.z)]) with an explosive replica.")
		logTheThing("admin", usr, null, "replaced [O] ([showCoords(O.x, O.y, O.z)]) with an explosive replica.")
		var/obj/replica = new /obj/item/card/id/captains_spare/explosive(O.loc)
		replica.icon = O.icon
		replica.icon_state = O.icon_state
		replica.name = O.name
		replica.desc = O.desc
		replica.set_density(O.density)
		replica.opacity = O.opacity
		replica.anchored = O.anchored
		replica.layer = O.layer - 0.05
		replica.pixel_x = O.pixel_x
		replica.pixel_y = O.pixel_y
		replica.dir = O.dir
		qdel(O)


/obj/disposing()
	for(var/mob/M in src.contents)
		M.set_loc(src.loc)
	tag = null
	..()

/obj/proc/place_on(obj/item/W as obj, mob/user as mob, params)
	if (W && !issilicon(user)) // no ghost drones should not be able to do this either, not just borgs
		if (user && !(W.cant_drop))
			user.drop_item()
			if (W && W.loc)
				W.set_loc(src.loc)
				if (islist(params) && params["icon-y"] && params["icon-x"])
					W.pixel_x = text2num(params["icon-x"]) - 16
					W.pixel_y = text2num(params["icon-y"]) - 16
				return 1
	return 0

/obj/proc/receive_silicon_hotkey(var/mob/user)
	//A wee stub to handle other objects implementing the AI keys
	//DEBUG_MESSAGE("[src] got a silicon hotkey from [user], containing: [user.client.check_key(KEY_OPEN) ? "KEY_OPEN" : ""] [user.client.check_key(KEY_BOLT) ? "KEY_BOLT" : ""] [user.client.check_key(KEY_SHOCK) ? "KEY_SHOCK" : ""]")
	return 0

/obj/proc/mob_flip_inside(var/mob/user)
	user.show_text("<span class='alert'>You leap and slam against the inside of [src]! Ouch!</span>")
	user.changeStatus("paralysis", 40)
	user.changeStatus("weakened", 4 SECONDS)
	src.visible_message("<span class='alert'><b>[src]</b> emits a loud thump and rattles a bit.</span>")

	animate_storage_thump(src)

