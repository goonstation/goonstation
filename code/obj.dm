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

	proc/move_trigger(var/mob/M, var/kindof)
		var/atom/movable/x = loc
		while (x && !isarea(x) && x != M)
			x = x.loc
		if (!x || isarea(x))
			return 0
		return 1

	animate_movement = 2
//	desc = "<span style=\"color:red\">HI THIS OBJECT DOESN'T HAVE A DESCRIPTION MAYBE IT SHOULD???</span>"
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
		src.visible_message("<span style=\"color:red\"><b>[src] is destroyed.</b></span>")
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

/obj/proc/updateUsrDialog()
	var/list/nearby = viewers(1, src)
	for(var/mob/M in nearby)
		if ((M.client && M.machine == src))
			if(istype(src, /obj/npc/trader)) //This is not great. But making dialogues and trader windows work together is tricky. Needs a better solution.
				var/obj/npc/trader/T = src
				T.openTrade(M)
			else
				src.attack_hand(M)
	if (issilicon(usr))
		if (!(usr in nearby))
			if (usr.client && usr.machine==src) // && M.machine == src is omitted because if we triggered this by using the dialog, it doesn't matter if our machine changed in between triggering it and this - the dialog is probably still supposed to refresh.
				src.attack_ai(usr)
	if (isAIeye(usr))
		var/mob/dead/aieye/E = usr
		if (E.client)
			src.attack_ai(E)

/obj/proc/updateDialog()
	var/list/nearby = viewers(1, src)
	for(var/mob/M in nearby)
		if ((M.client && M.machine == src))
			src.attack_hand(M)
	AutoUpdateAI(src)

/obj/item/proc/updateSelfDialogFromTurf()	//It's weird, yes. only used for spy stickers as of now
	var/list/nearby = viewers(1, get_turf(src))
	for(var/mob/M in nearby)
		if (isAI(M)) //Eyecam handling
			var/mob/living/silicon/ai/AI = M
			if (AI.deployed_to_eyecam)
				M = AI.eyecam
		if ((M.client && M.machine == src))
			src.attack_self(M)

	for(var/mob/living/silicon/ai/M in AIs)
		var/mob/AI = M
		if (M.deployed_to_eyecam)
			AI = M.eyecam
		if ((AI.client && AI.machine == src))
			src.attack_self(AI)

/obj/item/proc/updateSelfDialog()
	var/mob/M = src.loc
	if(istype(M))
		if (isAI(M)) //Eyecam handling
			var/mob/living/silicon/ai/AI = M
			if (AI.deployed_to_eyecam)
				M = AI.eyecam
		if(M.client && M.machine == src)
			src.attack_self(M)

/obj/bedsheetbin
	name = "linen bin"
	desc = "A bin for containing bedsheets."
	icon = 'icons/obj/items.dmi'
	icon_state = "bedbin"
	var/amount = 23.0
	anchored = 1.0

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/clothing/suit/bedsheet))
			qdel(W)
			src.amount++
		return

	attack_hand(mob/user as mob)
		add_fingerprint(user)
		if (src.amount >= 1)
			src.amount--
			new /obj/item/clothing/suit/bedsheet(src.loc)
			if (src.amount <= 0)
				src.icon_state = "bedbin0"
		else
			boutput(user, "There's no bedsheets left in [src]!")

	get_desc()
		. += "There's [src.amount ? src.amount : "no"] bedsheet[s_es(src.amount)] in [src]."

/obj/towelbin
	name = "towel bin"
	desc = "A bin for containing towels."
	icon = 'icons/obj/items.dmi'
	icon_state = "bedbin"
	var/amount = 23.0
	anchored = 1.0

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/clothing/under/towel))
			qdel(W)
			src.amount++
		return

	attack_hand(mob/user as mob)
		add_fingerprint(user)
		if (src.amount >= 1)
			src.amount--
			new /obj/item/clothing/under/towel(src.loc)
			if (src.amount <= 0)
				src.icon_state = "bedbin0"
		else
			boutput(user, "There's no towels left in [src]!")

	get_desc()
		. += "There's [src.amount ? src.amount : "no"] towel[s_es(src.amount)] in [src]."

/obj/securearea
	desc = "A warning sign which reads 'SECURE AREA'"
	name = "SECURE AREA"
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	anchored = 1.0
	opacity = 0
	density = 0
	layer=EFFECTS_LAYER_BASE

/obj/securearea/ex_act(severity)
	ex_act_third(severity)

/obj/joeq
	desc = "Here lies Joe Q. Loved by all. He was a terrorist. R.I.P."
	name = "Joe Q. Memorial Plaque"
	icon = 'icons/obj/decals.dmi'
	icon_state = "rip"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/fudad
	desc = "In memory of Arthur \"F. U. Dad\" Muggins, the bravest, toughest Vice Cop SS13 has ever known. Loved by all. R.I.P."
	name = "Arthur Muggins Memorial Plaque"
	icon = 'icons/obj/decals.dmi'
	icon_state = "rip"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/juggleplaque
	desc = "In loving and terrified memory of those who discovered the dark secret of Jugglemancy. \"E. Shirtface, Juggles the Clown, E. Klein, A.F. McGee,  J. Flarearms.\""
	name = "Funny-Looking Memorial Plaque"
	icon = 'icons/obj/decals.dmi'
	icon_state = "rip"
	anchored = 1.0
	opacity = 0
	density = 0

/obj/lattice
	desc = "A lightweight support lattice."
	name = "lattice"
	icon = 'icons/obj/structures.dmi'
	icon_state = "lattice"
	density = 0
	stops_space_move = 1
	anchored = 1.0
	layer = LATTICE_LAYER
	//	flags = CONDUCT

	blob_act(var/power)
		if(prob(75))
			qdel(src)
			return

	ex_act(severity)
		if(src.material)
			src.material.triggerExp(src, severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				qdel(src)
				return
			if(3.0)
				return
			else
		return

	attackby(obj/item/C as obj, mob/user as mob)

		if (istype(C, /obj/item/tile))

			C:build(get_turf(src))
			C:amount--
			playsound(src.loc, "sound/impact_sounds/Generic_Stab_1.ogg", 50, 1)
			C.add_fingerprint(user)

			if (C:amount < 1)
				user.u_equip(C)
				qdel(C)
			qdel(src)
			return
		if (istype(C, /obj/item/weldingtool) && C:welding)
			boutput(user, "<span style=\"color:blue\">Slicing lattice joints ...</span>")
			C:eyecheck(user)
			new /obj/item/rods/steel(src.loc)
			qdel(src)
		if (istype(C, /obj/item/rods))
			var/obj/item/rods/R = C
			if (R.amount >= 2)
				R.amount -= 2
				boutput(user, "<span style=\"color:blue\">You assemble a barricade from the lattice and rods.</span>")
				new /obj/lattice/barricade(src.loc)
				if (R.amount < 1)
					user.u_equip(C)
					qdel(C)
				qdel(src)
		return

/obj/lattice/barricade
	name = "barricade"
	desc = "A lattice that has been turned into a makeshift barricade."
	icon_state = "girder"
	density = 1
	var/strength = 2

	proc/barricade_damage(var/hitstrength)
		strength -= hitstrength
		playsound(src.loc, "sound/impact_sounds/Metal_Hit_Light_1.ogg", 50, 1)
		if (strength < 1)
			src.visible_message("The barricade breaks!")
			if (prob(50)) new /obj/item/rods/steel(src.loc)
			qdel(src)
			return

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weldingtool))
			var/obj/item/weldingtool/WELD = W
			if(WELD.welding)
				boutput(user, "<span style=\"color:blue\">You disassemble the barricade.</span>")
				WELD.eyecheck(user)
				var/obj/item/rods/R = new /obj/item/rods/steel(src.loc)
				R.amount = src.strength
				qdel(src)
				return
		else if (istype(W,/obj/item/rods))
			var/obj/item/rods/R = W
			var/difference = 5 - src.strength
			if (difference <= 0)
				boutput(user, "<span style=\"color:red\">This barricade is already fully reinforced.</span>")
				return
			if (R.amount > difference)
				R.amount -= difference
				src.strength = 5
				boutput(user, "<span style=\"color:blue\">You reinforce the barricade.</span>")
				boutput(user, "<span style=\"color:blue\">The barricade is now fully reinforced!</span>") // seperate line for consistency's sake i guess
				return
			else if (R.amount <= difference)
				R.amount -= difference
				src.strength = 5
				boutput(user, "<span style=\"color:blue\">You use up the last of your rods to reinforce the barricade.</span>")
				if (src.strength >= 5) boutput(user, "<span style=\"color:blue\">The barricade is now fully reinforced!</span>")
				if (R.amount < 1)
					user.u_equip(W)
					qdel(W)
				return
		else
			if (W.force > 8)
				user.lastattacked = src
				src.barricade_damage(W.force / 8)
				playsound(src.loc, "sound/impact_sounds/Metal_Hit_Light_1.ogg", 50, 1)
			..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0) src.barricade_damage(3)
			if(3.0) src.barricade_damage(1)
		return

	blob_act(var/power)
		src.barricade_damage(2 * power / 20)

	meteorhit()
		src.barricade_damage(1)

/obj/overlay
	name = "overlay"
	mat_changename = 0
	mat_changedesc = 0
	event_handler_flags = IMMUNE_MANTA_PUSH

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
			SPAWN_DBG(deleteTimer)
				qdel(src)

/obj/projection
	name = "Projection"
	anchored = 1.0

/obj/deskclutter
	name = "desk clutter"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "deskclutter"
	desc = "What a mess..."
	anchored = 1

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/proc/alter_health()
	return 1

/obj/proc/hide(h)
	return

/client/proc/replace_with_explosive(var/obj/O as obj in world)
	set name = "Replace with explosive replica"
	set desc = "Dick move."
	set category = "Special Verbs"
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


/obj/verb/interact_verb()
	set name = "Interact"
	set src in oview(1)
	set category = "Local"

	if (isdead(usr) || (!iscarbon(usr) && !iscritter(usr)))
		return

	if (!istype(src.loc, /turf) || usr.stat || usr.getStatusDuration("paralysis") || usr.getStatusDuration("stunned") || usr.getStatusDuration("weakened") || usr.restrained())
		return

	if (!can_reach(usr, src))
		return

	if (usr.client)
		usr.client.Click(src,get_turf(src))

/obj/proc/mob_flip_inside(var/mob/user)
	user.show_text("<span style=\"color:red\">You leap and slam against the inside of [src]! Ouch!</span>")
	user.changeStatus("paralysis", 40)
	user.changeStatus("weakened", 4 SECONDS)
	src.visible_message("<span style=\"color:red\"><b>[src]</b> emits a loud thump and rattles a bit.</span>")

	animate_storage_thump(src)

/obj/handcuffdispenser
	name = "handcuff dispenser"
	desc = "A handy dispenser for handcuffs."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dispenser_handcuffs"
	pixel_y = 28
	var/amount = 3

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/handcuffs))
			user.u_equip(W)
			qdel(W)
			src.amount++
			boutput(user, "<span style=\"color:blue\">You put a pair of handcuffs in the [src]. [amount] left in the dispenser.</span>")
			src.icon_state = "dispenser_handcuffs"
		return

	attack_hand(mob/user as mob)
		add_fingerprint(user)
		if (src.amount >= 1)
			src.amount--
			user.put_in_hand_or_drop(new/obj/item/handcuffs, user.hand)
			boutput(user, "<span style=\"color:red\">You take a pair of handcuffs from the [src]. [amount] left in the dispenser.</span>")
			if (src.amount <= 0)
				src.icon_state = "dispenser_handcuffs0"
		else
			boutput(user, "<span style=\"color:red\">There's no handcuffs left in the [src]!</span>")

/obj/latexglovesdispenser
	name = "latex gloves dispenser"
	desc = "A handy dispenser for latex gloves."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dispenser_gloves"
	pixel_y = 28
	var/amount = 3

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/clothing/gloves/latex))
			user.u_equip(W)
			qdel(W)
			src.amount++
			boutput(user, "<span style=\"color:blue\">You put a pair of latex gloves in the [src]. [amount] left in the dispenser.</span>")
			src.icon_state = "dispenser_gloves"
		return

	attack_hand(mob/user as mob)
		add_fingerprint(user)
		if (src.amount >= 1)
			src.amount--
			user.put_in_hand_or_drop(new/obj/item/clothing/gloves/latex, user.hand)
			boutput(user, "<span style=\"color:red\">You take a pair of latex gloves from the [src]. [amount] left in the dispenser.</span>")
			if (src.amount <= 0)
				src.icon_state = "dispenser_gloves0"
		else
			boutput(user, "<span style=\"color:red\">There's no latex gloves left in the [src]!</span>")

/obj/medicalmaskdispenser
	name = "medical mask dispenser"
	desc = "A handy dispenser for medical masks."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dispenser_mask"
	pixel_y = 28
	var/amount = 3

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/clothing/mask/medical))
			user.u_equip(W)
			qdel(W)
			src.amount++
			boutput(user, "<span style=\"color:blue\">You put a pair of medical masks in the [src]. [amount] left in the dispenser.</span>")
			src.icon_state = "dispenser_mask"
		return

	attack_hand(mob/user as mob)
		add_fingerprint(user)
		if (src.amount >= 1)
			src.amount--
			user.put_in_hand_or_drop(new/obj/item/clothing/mask/medical, user.hand)
			boutput(user, "<span style=\"color:red\">You take a pair of medical masks from the [src]. [amount] left in the dispenser.</span>")
			if (src.amount <= 0)
				src.icon_state = "dispenser_mask0"
		else
			boutput(user, "<span style=\"color:red\">There's no medical masks left in the [src]!</span>")

/obj/glassesdispenser
	name = "prescription glass dispenser"
	desc = "A handy dispenser for prescription glasses."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dispenser_glasses"
	pixel_y = 28
	var/amount = 3

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/clothing/glasses/regular))
			user.u_equip(W)
			qdel(W)
			src.amount++
			boutput(user, "<span style=\"color:blue\">You put a pair of prescription glass in the [src]. [amount] left in the dispenser.</span>")
			src.icon_state = "dispenser_glasses"
		return

	attack_hand(mob/user as mob)
		add_fingerprint(user)
		if (src.amount >= 1)
			src.amount--
			user.put_in_hand_or_drop(new/obj/item/clothing/glasses/regular, user.hand)
			boutput(user, "<span style=\"color:red\">You take a pair of prescription glass from the [src]. [amount] left in the dispenser.</span>")
			if (src.amount <= 0)
				src.icon_state = "dispenser_glasses0"
		else
			boutput(user, "<span style=\"color:red\">There's no prescription glass left in the [src]!</span>")
