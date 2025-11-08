//See mechComp_signals.dm  for  mechanics_holder - How Messages get passed around.

//TODO:
// - Message Datum pooling and recycling.

#define IN_CABINET (istype(src.stored?.linked_item,/obj/item/storage/mechanics))
#define CONTAINER_LIGHT_TIME 2 // process()es to light up for when one component is triggered. this adds up to MAX_CONTAINER_LIGHT_TIME
#define MAX_CONTAINER_LIGHT_TIME 10 // max process()es to light up for
#define CABINET_CAPACITY 23
#define HANDHELD_CAPACITY 6
#define WIFI_NOISE_COOLDOWN 5 SECONDS
#define WIFI_NOISE_VOLUME 30
#define LIGHT_UP_HOUSING SPAWN(0) src.light_up_housing()
#define SEND_COOLDOWN_ID "MechComp send cooldown"

// mechanics containers for mechanics components (read: portable horn [read: vuvuzela] honkers! yaaaay!)
//

TYPEINFO(/obj/item/storage/mechanics/housing_large)
	mats = list("bohrum" = 100,
				"conductive" = 50)

TYPEINFO(/obj/item/storage/mechanics/housing_handheld)
	mats = list("bohrum" = 80,
				"conductive_high" = 40)

/obj/item/storage/mechanics // generic
	name="Generic MechComp Housing"
	desc="You should not bee seeing this! Call 1-800-CODER or just crusher it"
	icon='icons/misc/mechanicsExpansion.dmi'
	can_hold=list(/obj/item/mechanics, /obj/item/device/gps)
	var/list/users = list() // le chumps who have opened the housing
	deconstruct_flags = DECON_NONE
	slots=1
	var/num_f_icons = 0 // how many fill icons i have
	var/light_time=0
	var/light_color = list(0, 255, 255, 255)
	var/open = TRUE
	var/welded = FALSE
	var/can_be_welded = FALSE
	var/can_be_anchored = UNANCHORED
	var/default_hat_y = 0
	var/default_hat_x = 0
	var/amount_of_prevent_move_comps = 0
	custom_suicide = TRUE

	New()
		processing_items |= src //this thing is a dang storage
		..()

	process()
		if (src.light_time>0)
			src.light_time--
			src.UpdateIcon()

	proc/light_up()
		src.light_time += CONTAINER_LIGHT_TIME
		src.light_time = max(src.light_time, MAX_CONTAINER_LIGHT_TIME)
		src.UpdateIcon()

	ex_act(severity)
		switch(severity)
			if (1)
				src.dispose() // disposing upon being blown up unlike all those decorative rocks on cog2
				return
			if (2)
				if(prob(25))
					src.dispose()
					return
				src.open = TRUE
				src.welded = FALSE
				src.UpdateIcon()
				return
			if (3)
				if(prob(50) && !src.welded)
					src.open = TRUE
					src.UpdateIcon()
				return
		return
	suicide(var/mob/user as mob) // lel
		if (!src.user_can_suicide(user))
			return FALSE
		user.visible_message(SPAN_ALERT("<b>[user] stares into the [src], trying to make sense of its function!</b>"))
		SPAWN(3 SECONDS)
			user.visible_message(SPAN_ALERT("<b>[user]'s brain melts!</b>"))
			playsound(user, 'sound/effects/mindkill.ogg', 50)
			user.take_brain_damage(69*420)
		SPAWN(20 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return
	attack_self(mob/user as mob)
		if(!(user in src.users) && istype(user))
			src.users+=user
		return ..()
	attack_hand(mob/user)
		if(!(user in src.users) && istype(user))
			src.users+=user
		return ..()

	attackby(obj/item/W, mob/user)
		if (isscrewingtool(W))
			if(src.welded)
				boutput(user,SPAN_ALERT("The [src] is welded shut."))
				return
			src.opens_if_worn=!src.open
			src.open=!src.open
			playsound(src.loc,'sound/items/screwdriver.ogg',50)
			if(!src.open)
				src.close_storage_menus()
			else
				src.light_time=0
			src.UpdateIcon()
			return TRUE
		else if (iswrenchingtool(W))
			if(!src.can_be_anchored)
				boutput(user,SPAN_ALERT("[src] cannot be anchored to the ground."))
				return
			if(!src.open || src.welded)
				boutput(user,SPAN_ALERT("You are unable to access the [src]'s bolts as they are on the inside."))
				return
			if(!isturf(src.loc) && !src.anchored)
				boutput(user,SPAN_ALERT("You cannot anchor a component housing inside something else."))
				return
			src.anchored=!src.anchored
			notify_cabinet_state()
			playsound(src.loc,'sound/items/Ratchet.ogg',50)
			boutput(user,SPAN_NOTICE("You [src.anchored ? "anchor the [src] to" : "unsecure the [src] from"] the ground"))
			if (!src.anchored)
				src.destroy_outside_connections() //burn those bridges
			return TRUE
		else if (isweldingtool(W))
			if (!src.can_be_welded)
				boutput(user,SPAN_ALERT("[src]'s cover cannot be welded shut."))
				return
			if (src.open)
				boutput(user,"Why would you want to weld something <i>open?</i>")
				return
			if(W:try_weld(user, 1))
				src.welded=!src.welded
				boutput(user,SPAN_NOTICE("You [src.welded ? "" : "un"]weld the [src]'s cover"))
				src.UpdateIcon()
				return TRUE
		else if (src.open || !istype(W,/obj/item/mechanics))
			..()
			src.UpdateIcon()
		return TRUE

	update_icon()
		if(src.welded)
			src.icon_state=initial(src.icon_state)+"_w"
		else if(src.open)
			// ugly warning, the istype() is 1 when there's a trigger in the container
			//	it subtracts 1 from the list of contents when there's a trigger
			//	doing arithmatic on bools is probably not good!
			var/has_trigger = istype(locate(/obj/item/mechanics/trigger/trigger) in src.contents,/obj/item/mechanics/trigger/trigger)
			var/len_contents = src.contents.len - has_trigger
			if(src.num_f_icons && len_contents)
				src.icon_state=initial(src.icon_state)+"_f[min(src.num_f_icons-1,round((len_contents*src.num_f_icons)/(src.slots-has_trigger)))]"
			else
				src.icon_state=initial(src.icon_state)
		else
			src.icon_state=initial(src.icon_state)+"_closed"
		if(src.light_time > 0)
			src.icon_state += "_e"
			src.add_medium_light("cabinet_light", src.light_color)
		else
			src.remove_medium_light("cabinet_light")

	proc/close_storage_menus() // still ugly but probably quite better performing
		for(var/mob/chump in src.users)
			for(var/datum/hud/storage/hud in chump.huds)
				if(hud.master==src.storage) hud.close_button.clicked()
		src.users = list() // gee golly i hope garbage collection does its job
		return TRUE

	proc/notify_cabinet_state()
		for (var/obj/item/mechanics/comp in src.contents)
			comp.cabinet_state_change(src)

	proc/destroy_outside_connections()
		//called when the cabinet is unanchored
		var/discons=0
		for (var/atom/comp in src.contents)
			if(SEND_SIGNAL(comp, _COMSIG_MECHCOMP_COMPATIBLE) != 1)
				continue
			var/pointer_container[1] //A list of size 1, to store the address of the list we want
			SEND_SIGNAL(comp, _COMSIG_MECHCOMP_GET_OUTGOING, pointer_container)
			var/list/connected_outgoing = pointer_container[1]
			SEND_SIGNAL(comp, _COMSIG_MECHCOMP_GET_INCOMING, pointer_container)
			var/list/connected_incoming = pointer_container[1]
			for(var/atom/M in connected_outgoing)
				if (M.loc==src)
					continue
				SEND_SIGNAL(comp, _COMSIG_MECHCOMP_RM_OUTGOING, M)
				SEND_SIGNAL(M, _COMSIG_MECHCOMP_RM_INCOMING, comp)
				discons++
			for(var/atom/M in connected_incoming)
				if (M.loc==src)
					continue
				SEND_SIGNAL(comp, _COMSIG_MECHCOMP_RM_INCOMING, M)
				SEND_SIGNAL(M, _COMSIG_MECHCOMP_RM_OUTGOING, comp)
				discons++
		return discons

	proc/unanchor_movement_comps()
		// called when a cabinet_prevent_move comp is first added
		var/removed_comp_amount = 0
		for (var/atom/comp in src.contents)
			var/obj/item/mechanics/movement/mov_comp = comp
			if (!istype(mov_comp))
				continue
			if (mov_comp.level == UNDERFLOOR)
				mov_comp.level = OVERFLOOR
				mov_comp.anchored = UNANCHORED
				mov_comp.clear_owner()
				mov_comp.loosen()
				removed_comp_amount++
		return removed_comp_amount

	disposing()
		..()
		processing_items.Remove(src)
		src.contents=null
		return
	mouse_drop(atom/target)
		if(!istype(usr))
			return
		if(src.open && target == usr)
			if(!(usr in src.users))
				src.users+=usr
			return ..()
		if(!src.anchored && target != usr)
			return ..()
		return
	get_desc()
		.+="[src.welded ? " It is welded shut." : ""][src.open ? " Its cover has been opened." : ""]\
		[src.anchored ? "It is [src.open || src.welded ? "also" : ""] anchored to the ground." : ""]"

	housing_large // chonker
		can_be_welded = TRUE
		can_be_anchored = ANCHORED
		slots=CABINET_CAPACITY // wew, dont use this in-hand or equipped!
		name="Component Cabinet" // i tried to replace "23" below with "[CABINET_CAPACITY]", but byond
									 // thinks it's not a constant and refuses to work with it.
		desc="A rather chunky cabinet for storing up to 23 active mechanic components\
		 at once.<br>It can only be connected to external components when bolted to the floor.<br>"
		w_class = W_CLASS_GIGANTIC //Shouldn't be stored in a backpack
		throwforce = 10
		num_f_icons=3
		density=1
		anchored = UNANCHORED
		icon_state="housing_cabinet"
		flags = EXTRADELAY | CONDUCT
		light_color = list(0, 179, 255, 255)
		default_hat_y = 14

		New()
			AddComponent(/datum/component/hattable, FALSE, FALSE, default_hat_y)
			..()

		attack_hand(mob/user)
			if (istype(user,/mob/living/object) && user == src.loc) // prevent wacky nullspace bug
				return
			if(src.loc==user)
				src.set_loc(get_turf(src))
				user.drop_item()
				return
			return mouse_drop(user)

		attack_self(mob/user as mob)
			if (istype(user,/mob/living/object) && user == src.loc)
				return
			src.set_loc(get_turf(user))
			user.drop_item()

		mouse_drop(atom/target)
		// thanks, whoever hardcoded that pick-up action into obj/item/mouse_drop()!
			if(istype(target,/atom/movable/screen/hud))
				return
			if(target.loc!=get_turf(target) && !isturf(target)) //return if dragged onto an item in another object (i.e backpacks on players)
				return // you used to be able to pick up cabinets by dragging them to your backpack
			return ..()

	housing_handheld
		var/obj/item/mechanics/trigger/trigger/the_trigger
		slots=HANDHELD_CAPACITY + 1 // One slot used by the permanent button
		name="Device Frame"
		desc="A massively shrunken component cabinet fitted with a handle and an external\
		 button. Due to the average mechanic's low arm strength, it only holds 6 components." // same as above
		 												//if you change the capacity, remember to manually update this string
		w_class = W_CLASS_NORMAL // fits in backpacks but not pockets. no quickdraw honk boxess
		density=0
		anchored=UNANCHORED
		num_f_icons=1
		icon_state="housing_handheld"
		flags = EXTRADELAY | TABLEPASS | CONDUCT
		c_flags = ONBELT
		light_color = list(51, 0, 0, 0)
		spawn_contents=list(/obj/item/mechanics/trigger/trigger)
		default_hat_y = 7
		default_hat_x = -1

		New()
			AddComponent(/datum/component/hattable, FALSE, FALSE, default_hat_y, default_hat_x)
			..()

		proc/find_trigger() // find the trigger comp, return TRUE if found.
			if (!istype(src.the_trigger))
				src.the_trigger = (locate(/obj/item/mechanics/trigger/trigger) in src.contents)
				if (!istype(src.the_trigger)) //no trigger?
					for(var/obj/item in src.contents)
						item.set_loc(get_turf(src)) // kick out any mechcomp
					qdel(src) // delet
					return FALSE
			return TRUE
		attack_self(mob/user as mob)
			if(src.open)
				if(!(user in src.users))
					src.users+=user
				return ..() // you can just use the trigger manually from the UI
			if(src.find_trigger() && !src.open && src.loc==user)
				return src.the_trigger.Attackhand(user)

#undef CONTAINER_LIGHT_TIME
#undef MAX_CONTAINER_LIGHT_TIME
#undef CABINET_CAPACITY
#undef HANDHELD_CAPACITY
/obj/item/mechanics/trigger/trigger // stolen code from the Button
	name = "Device Trigger"
	desc = "This component is the integral button of a device frame. It cannot be removed from the device. Can be used by clicking on the device when the device's cover is closed"
	icon_state = "button_comp_button_unpressed"
	var/icon_up = "button_comp_button_unpressed"
	var/icon_down = "button_comp_button_pressed"
	density = 1
	anchored= ANCHORED
	level=1
	w_class = W_CLASS_BULKY

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)

	attackby(obj/item/W, mob/user)
		if(iswrenchingtool(W)) // prevent unanchoring
			return FALSE
		if(istype(W, /obj/item/storage/mechanics/housing_handheld))
			src.attack_hand()
			return FALSE
		. = ..()

	attack_hand(mob/user)
		..()
		if (!istype(src.stored?.linked_item,/obj/item/storage/mechanics/housing_handheld))
			qdel(src) //if outside the gun, delet
			return
		if(level == UNDERFLOOR)
			src.icon_state=icon_down
			SPAWN(1 SECOND)
				src.UpdateIcon()
			LIGHT_UP_HOUSING
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG)
			playsound(src,'sound/machines/keypress.ogg',30)
		else
			qdel(src) // it's somehow been unanchored or something, kill it
		return
	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		qdel(src)// never should be outside of the gun (in someone's hands), so kill it
		return
	update_icon()
		icon_state = icon_up

// Put these into Mechanic's locker
/obj/item/electronics/frame/mech_cabinet
	name = "Component Cabinet frame"
	store_type = /obj/item/storage/mechanics/housing_large
	viewstat = 2
	secured = 2
	icon_state = "dbox"

TYPEINFO(/obj/item/mechanics)
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_DEVICE)

/obj/item/mechanics
	name = "testhing"
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "comp_unk"
	item_state = "swat_suit"
	flags = EXTRADELAY | TABLEPASS | CONDUCT
	object_flags = NO_GHOSTCRITTER
	plane = PLANE_NOSHADOW_BELOW
	w_class = W_CLASS_TINY
	level = 2

	speech_verb_say = list("squawks", "beeps", "boops", "says", "screeches")
	voice_sound_override = 'sound/machines/reprog.ogg'

	/// whether or not this component is prevented from being anchored in cabinets
	var/cabinet_banned = FALSE
	/// whether or not this component can only be used in cabinets
	var/cabinet_only = FALSE
	/// whether or not this component prevents the Movement Component from being anchored in cabinets
	var/cabinet_prevent_move = FALSE
	/// if true makes it so that only one component can be wrenched on the tile
	var/one_per_tile = FALSE
	// override disconnect all on unanchor/anchor. this is mostly for the bomb :|
	var/dont_disconnect_on_change = FALSE
	var/under_floor = 0
	var/can_rotate = 0
	var/cooldown_time = 3 SECONDS
	var/when_next_ready = 0
	var/list/particle_list
	var/mob/owner = null
	var/process_fast = FALSE //Process will be called at 2.8s intervals instead of 0.4

	New()
		particle_list = new/list()
		AddComponent(/datum/component/mechanics_holder)
		processing_mechanics |= src
		return ..()


	disposing()
		processing_mechanics.Remove(src)
		clear_owner()
		..()


	proc

		cutParticles()
			if(length(particle_list))
				for(var/datum/particleSystem/mechanic/M in particle_list)
					M.Die()
				particle_list.Cut()
			return
		light_up_housing( ) // are we in a housing? if so, tell it to light up
			var/obj/item/storage/mechanics/the_container = src.stored?.linked_item
			if(istype(the_container,/obj/item/storage/mechanics)) // wew lad i hope this compiles
				the_container.light_up()

		clear_owner()
			UnregisterSignal(owner, COMSIG_PARENT_PRE_DISPOSING)
			owner = null

		set_owner(mob/user)
			RegisterSignal(user, COMSIG_PARENT_PRE_DISPOSING, PROC_REF(clear_owner))
			owner = user




	process()
		if(level == OVERFLOOR || under_floor)
			cutParticles()
			return
		var/pointer_container[1] //A list of size 1, to store the address of the list we want
		SEND_SIGNAL(src, _COMSIG_MECHCOMP_GET_OUTGOING, pointer_container)
		var/list/connected_outgoing = pointer_container[1]
		if(length(particle_list) != length(connected_outgoing))
			cutParticles()
			for(var/atom/X in connected_outgoing)
				particle_list.Add(particleMaster.SpawnSystem(new /datum/particleSystem/mechanic(src.loc, X.loc)))


	attack_hand(mob/user)
		if(level == UNDERFLOOR)
			return
		if(issilicon(user) || isAI(user))
			return
		else return ..(user)

	attack_ai(mob/user as mob)
		return src.Attackhand(user)
	proc/secure()
	proc/loosen()
	proc/cabinet_state_change(var/obj/item/storage/mechanics/container)

	proc/rotate()
		src.set_dir(turn(src.dir, -90))

	proc/check_wrenching_conditions(var/mob/user)
		//We need only to check conditions when the object is non-wrenched. Because else it can always be loosened
		if(src.level == OVERFLOOR)
			if(!isturf(src.loc) && !(IN_CABINET)) // allow items to be deployed inside housings, but not in other stuff like toolboxes
				boutput(user, SPAN_ALERT("[src] needs to be on the ground  [src.cabinet_banned ? "" : "or in a component housing"] for that to work."))
				return FALSE
			if (IN_CABINET && istype(src, /obj/item/mechanics/movement))
				var/obj/item/storage/mechanics/cabinet = src.stored?.linked_item
				if (cabinet.amount_of_prevent_move_comps > 0)
					boutput(user, SPAN_ALERT("[src] is not allowed since an anchored component is preventing cabinet movement."))
					return FALSE
			if(IN_CABINET && src.cabinet_banned)
				boutput(user,SPAN_ALERT("[src] is not allowed in component housings."))
				return FALSE
			if(!IN_CABINET && src.cabinet_only)
				boutput(user,SPAN_ALERT("[src] is not allowed outside of component housings."))
				return FALSE
		return TRUE


	proc/wrench_action(var/mob/user, var/obj/item/used_wrench)
		// we need to check if the component didn't moved during our action bar and all other conditions are still true
		if (!in_interact_range(src, user) || !can_act(user) || !src.check_wrenching_conditions(user))
			return
		switch(level)
			if(UNDERFLOOR) //Level 1 = wrenched into place
				boutput(user, "You detach the [src] from the [istype(src.stored?.linked_item,/obj/item/storage/mechanics) ? "housing" : "underfloor"] and deactivate it.")
				logTheThing(LOG_STATION, user, "detaches a <b>[src]</b> from the [istype(src.stored?.linked_item,/obj/item/storage/mechanics) ? "housing" : "underfloor"] and deactivates it at [log_loc(src)].")
				level = OVERFLOOR
				anchored = UNANCHORED
				if (src.cabinet_prevent_move && IN_CABINET)
					var/obj/item/storage/mechanics/cabinet = src.stored?.linked_item
					cabinet.amount_of_prevent_move_comps--
				clear_owner()
				loosen()
				if(src.material && src.material.getMaterialFlags() & MATERIAL_CRYSTAL)
					user.visible_message(SPAN_NOTICE("[src] breaks under the strain of the operation."))
					var/turf/target_turf = get_turf(src)
					var/obj/item/raw_material/shard/new_shard = new /obj/item/raw_material/shard(target_turf)
					new_shard.setMaterial(src.material)
					playsound(target_turf, pick('sound/impact_sounds/Glass_Shatter_1.ogg','sound/impact_sounds/Glass_Shatter_2.ogg','sound/impact_sounds/Glass_Shatter_3.ogg'), 100, 1)
					qdel(src)
			if(OVERFLOOR) //Level 2 = loose
				if (IN_CABINET && src.cabinet_prevent_move)
					var/obj/item/storage/mechanics/cabinet = src.stored?.linked_item
					cabinet.amount_of_prevent_move_comps++
					if (cabinet.amount_of_prevent_move_comps == 1 && cabinet.unanchor_movement_comps() > 0)
						boutput(user, SPAN_ALERT("The cabinet unanchored all movement components!"))
				boutput(user, "You attach the [src] to the [istype(src.stored?.linked_item,/obj/item/storage/mechanics) ? "housing" : "underfloor"] and activate it.")
				logTheThing(LOG_STATION, user, "attaches a <b>[src]</b> to the [istype(src.stored?.linked_item,/obj/item/storage/mechanics) ? "housing" : "underfloor"]  at [log_loc(src)].")
				level = UNDERFLOOR
				anchored = ANCHORED
				set_owner(user)
				secure()
		var/turf/T = src.loc
		if(isturf(T))
			hide(T.intact)
		else
			hide()
		if (!src.dont_disconnect_on_change)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)
		if(src && !QDELETED(src))
			src.material_trigger_when_attacked(used_wrench, user, 1)
		return TRUE

	attackby(obj/item/W, mob/user)
		if (ispryingtool(W))
			if (can_rotate)
				if (!anchored)
					rotate()
				else
					boutput(user, "You must unsecure the [src] in order to rotate it.")
			return TRUE
		else if(iswrenchingtool(W))
			if(src.material && src.material.getProperty("density") > 0)
				if(!src.check_wrenching_conditions(user))
					//we need to check the wrenching conditions manually here, else you get an action bar even though the action actually doesn't work
					return TRUE
				//work time calculation, 0.8 seconds per density, half when you have training, half for wrenching in, double for crystal material since loosening it breaks it.
				var/work_time = src.material.getProperty("density") * 0.8 SECONDS
				if(src.level == OVERFLOOR)
					work_time *= 0.5
				if(src.material.getMaterialFlags() & MATERIAL_CRYSTAL)
					work_time *= 2
				if(user.traitHolder && (user.traitHolder.hasTrait("carpenter") || user.traitHolder.hasTrait("training_engineer")))
					work_time *= 0.5
				// now, let's keep the result in reasonable values, even if you are untrained and should have no business working with this
				work_time = clamp(work_time, 1 SECONDS, 10 SECONDS)
				//now we set the action bar in motion
				user.visible_message(SPAN_NOTICE("[user] begins tampering with [src]."))
				SETUP_GENERIC_ACTIONBAR(user, src, work_time, PROC_REF(wrench_action), list(user, W), W.icon, W.icon_state, null, INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)
			else
				src.wrench_action(user)
			return TRUE
		return ..()

	pixelaction(atom/target, params, mob/user)
		var/turf/hit_turf = target
		if (!istype(hit_turf) || !hit_turf || hit_turf.density || !can_reach(user, hit_turf))
			..()
			return FALSE
		src.place_to_turf_by_grid(user, params, hit_turf, grid = 2, centered = 1, offsetx = 0, offsety = 2)

	pick_up_by(var/mob/M)
		if(level == OVERFLOOR)
			return ..()
		//If it's anchored, it can't be picked up!

	pickup()
		if(level == UNDERFLOOR)
			return
		SEND_SIGNAL(src,COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)
		return ..()

	dropped()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)
		return ..()

	mouse_drop(atom/over_object, src_location, over_location, over_control, params)
		if(level == OVERFLOOR || (istype(over_object, /obj/item/mechanics) && over_object.level == OVERFLOOR))
			boutput(usr, SPAN_ALERT("Both components need to be secured into place before they can be connected."))
			return

		SEND_SIGNAL(src,_COMSIG_MECHCOMP_DROPCONNECT, over_object, usr)

	hide(var/intact)
		under_floor = (intact && level==UNDERFLOOR)
		UpdateIcon()

/obj/item/mechanics/cashmoney
	name = "Payment component"
	desc = ""
	icon_state = "comp_money"
	density = 0
	cooldown_time = 1 SECOND
	var/price = 100
	var/code = null
	var/collected = 0
	var/thank_string = ""

	get_desc()
		. += {"<br><span class='notice'>Collected money: [collected]<br>
		Current price: [price] credits</span>"}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"eject money", PROC_REF(emoney))
		// SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Price",PROC_REF(setPrice))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Code",PROC_REF(setCode))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Thank-String",PROC_REF(setThank))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Eject Money",PROC_REF(checkEjectMoney))

	proc/emoney(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return
		if(input.signal == code)
			ejectmoney()

	proc/setPrice(obj/item/W as obj, mob/user as mob)
		if (code)
			var/codecheck = strip_html_tags(input(user,"Please enter current code:","Code check","") as text)
			if (codecheck != code)
				boutput(user, SPAN_ALERT("[bicon(src)]: Incorrect code entered."))
				return FALSE
		var/inp = input(user,"Enter new price:","Price setting", price) as num
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(!isnull(inp))
			if (inp <= 0)
				user.show_text("Please set a price higher than zero.", "red")
				return FALSE
			if (inp > 1000000) // ...and just to be on the safe side. Should be plenty.
				inp = 1000000
				user.show_text("[src] is not designed to handle such large transactions. Input has been set to the allowable limit.", "red")
			price = inp
			tooltip_rebuild = TRUE
			boutput(user, "Price set to [inp]")
			return TRUE
		return FALSE

	proc/setCode(obj/item/W as obj, mob/user as mob)
		if (code)
			var/codecheck = adminscrub(input(user,"Please enter current code:","Code check","") as text)
			if (codecheck != code)
				boutput(user, SPAN_ALERT("[bicon(src)]: Incorrect code entered."))
				return FALSE
		var/inp = adminscrub(input(user,"Please enter new code:","Code setting","dosh") as text)
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(inp))
			code = inp
			boutput(user, "Code set to [inp]")
			return TRUE
		return FALSE

	proc/setThank(obj/item/W as obj, mob/user as mob)
		thank_string = adminscrub(input(user,"Please enter string:","string","Thanks for using this mechcomp service!") as text)
		return TRUE

	proc/checkEjectMoney(obj/item/W as obj, mob/user as mob)
		if(code)
			var/codecheck = strip_html_tags(input(user,"Please enter current code:","Code check","") as text)
			if(!in_interact_range(src, user) || user.stat)
				return FALSE
			if (codecheck != code)
				boutput(user, SPAN_ALERT("[bicon(src)]: Incorrect code entered."))
				return FALSE
		ejectmoney()

	attackby(obj/item/W, mob/user)
		if(..(W, user))
			return TRUE
		if (istype(W, /obj/item/currency/spacecash) && !ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			LIGHT_UP_HOUSING
			if (src.price <= 0)
				src.price = initial(src.price)
			if (W.amount >= price)
				user.drop_item()
				if (length(thank_string))
					src.say("[thank_string]")

				if (W.amount > price)
					// Dispense change if they overpaid
					var/obj/item/currency/spacecash/C = new /obj/item/currency/spacecash(user.loc, W.amount - price)
					user.put_in_hand_or_drop(C)

				collected += price
				tooltip_rebuild = TRUE

				qdel(W)

				logTheThing(LOG_STATION, user, "pays [price] credit to activate the mechcomp payment component at [log_loc(src)].")
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"payment=[price]&total=[collected]&customer=[user.name]")
				FLICK("comp_money1", src)
				return TRUE
			else
				src.say("Insufficient funds. Price: [src.price].")
				return FALSE

		if (istype(W, /obj/item/card/id) && !ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			LIGHT_UP_HOUSING
			if (src.price <= 0)
				src.price = initial(src.price)
			var/obj/item/card/id/perp_id = W
			// largely stolen from the gene booth. thanks, gene booth.
			//subtract from perp bank account
			var/datum/db_record/account = null
			account = FindBankAccountByName(perp_id.registered)

			if (account)
				if (account["current_money"] >= src.price)
					account["current_money"] -= src.price
					if (length(thank_string))
						src.say("[thank_string]")
					collected += price
					tooltip_rebuild = TRUE

					logTheThing(LOG_STATION, user, "pays [price] credit to activate the mechcomp payment component at [log_loc(src)].")
					SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"payment=[price]&total=[collected]&customer=[user.name]")
					FLICK("comp_money1", src)
					return TRUE
				else
					src.say("Insufficient funds on card. Price: [src.price]. Available: [round(account["current_money"])].")
			else
				src.say("No bank account found for [perp_id.registered] found.")

		return FALSE


	proc/ejectmoney()
		if (collected)
			var/obj/item/currency/spacecash/S = new /obj/item/currency/spacecash
			S.setup(get_turf(src), collected)
			collected = 0
			tooltip_rebuild = TRUE

/obj/item/mechanics/flushcomp
	name = "Flusher component"
	desc = ""
	icon_state = "comp_flush"
	cooldown_time = 2 SECONDS
	cabinet_banned = TRUE


	var/obj/disposalpipe/trunk/trunk = null
	var/datum/gas_mixture/air_contents
	var/max_capacity = 100

	New()
		. = ..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"flush", PROC_REF(flushp))

	disposing()
		if(air_contents)
			qdel(air_contents)
			air_contents = null
		trunk = null
		..()

	attackby(obj/item/W, mob/user)
		if(..(W, user))
			if(src.level == UNDERFLOOR) //wrenched down
				trunk = locate() in src.loc
				if(trunk)
					trunk.linked = src
					air_contents = new /datum/gas_mixture
			else if (src.level == OVERFLOOR) //loose
				trunk?.linked = null
				if(air_contents)
					qdel(air_contents)
				air_contents = null
				trunk = null
			return TRUE
		return FALSE

	proc/flushp(var/datum/mechanicsMessage/input)
		var/count = 0
		if(level == OVERFLOOR)
			return
		if(input?.signal && !ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time) && trunk && !trunk.disposed)
			for(var/atom/movable/M in src.loc)
				if(M == src || M.anchored || isAI(M) || istype(M, /obj/projectile))
					continue
				if(count == src.max_capacity)
					break
				M.set_loc(src)
				count++
			flushit()

	proc/flushit()
		if(!trunk)
			return
		if(trunk.loc != src.loc)
			trunk = null
			return
		LIGHT_UP_HOUSING
		var/obj/disposalholder/H = new /obj/disposalholder

		H.init(src)

		ZERO_GASES(air_contents)

		FLICK("comp_flush1", src)
		sleep(1 SECOND)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, FALSE, 0)

		H.start(src) // start the holder processing movement

	proc/expel(var/obj/disposalholder/H)

		var/turf/target
		playsound(src, 'sound/machines/hiss.ogg', 50, FALSE, 0)
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))

			AM.set_loc(get_turf(src))
			AM.pipe_eject(0)
			AM?.throw_at(target, 5, 1)

		H.vent_gas(loc)
		qdel(H)

	return_air(direct = FALSE)
		return air_contents

/obj/item/mechanics/thprint
	name = "Thermal printer"
	desc = ""
	icon_state = "comp_tprint"
	cooldown_time = 5 SECONDS
	var/paper_name = "thermal paper"
	cabinet_banned = TRUE
	plane = PLANE_DEFAULT
	var/paper_left = 10
	var/process_cycle = 0

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"print", PROC_REF(print))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Paper Name",PROC_REF(setPaperName))

	proc/print(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			return
		if(input)
			LIGHT_UP_HOUSING
			FLICK("comp_tprint1",src)
			if(paper_left > 0)
				playsound(src.loc, 'sound/machines/printer_thermal.ogg', 35, 0, -10)
				var/obj/item/paper/thermal/P = new/obj/item/paper/thermal(src.loc)
				P.info = strip_html_tags(html_decode(input.signal))
				P.name = paper_name
				paper_left--
				processing_mechanics |= src
			else
				playsound(src.loc, 'sound/machines/click.ogg', 35, 1, -10)

	proc/setPaperName(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter name:","name setting", paper_name) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		paper_name = adminscrub(inp)
		boutput(user, "String set to [paper_name]")
		return TRUE

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == OVERFLOOR && GET_DIST(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.set_loc(target)

	process()
		. = ..()
		var/turf/T = get_turf(src)
		if(T && !ON_COOLDOWN(T, "ambient_paper_generation", 30 SECONDS))
			paper_left++
			if(paper_left >= 10)
				processing_mechanics -= src

/obj/item/mechanics/pscan
	name = "Paper scanner"
	desc = ""
	icon_state = "comp_pscan"
	var/del_paper = 1
	var/thermal_only = 1

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Paper Consumption",PROC_REF(toggleConsume))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Thermal Paper Mode",PROC_REF(toggleThermal))

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == OVERFLOOR && GET_DIST(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.set_loc(target)

	proc/toggleConsume(obj/item/W as obj, mob/user as mob)
		del_paper = !del_paper
		boutput(user, "[del_paper ? "Now consuming paper":"Now NOT consuming paper"]")
		return TRUE

	proc/toggleThermal(obj/item/W as obj, mob/user as mob)
		thermal_only = !thermal_only
		boutput(user, "[thermal_only ? "Now accepting only thermal paper":"Now accepting any paper"]")
		return TRUE

	attackby(obj/item/W, mob/user)
		if(..(W, user))
			return TRUE
		else if (istype(W, /obj/item/paper) && !ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			if(thermal_only && !istype(W, /obj/item/paper/thermal))
				boutput(user, SPAN_ALERT("This scanner only accepts thermal paper."))
				return FALSE
			LIGHT_UP_HOUSING
			FLICK("comp_pscan1",src)
			playsound(src.loc, 'sound/machines/twobeep2.ogg', 90, 0)
			var/obj/item/paper/P = W
			var/saniStr = strip_html_tags(sanitize(html_encode(P.info)))
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,saniStr)
			if(del_paper)
				qdel(W)
			return TRUE
		return FALSE

//todo: merge with the secscanner?
/obj/mechbeam
	//Would use the /obj/beam but its not extensible enough.
	name = "trip laser"
	desc = "A beam of light that will trigger a device when passed."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ibeam"
	anchored = ANCHORED
	event_handler_flags = USE_FLUID_ENTER

	var/obj/item/mechanics/triplaser/holder

	New(var/loc, var/obj/item/mechanics/triplaser/t)
		holder = t
		..()

	proc/tripped()
		if (!holder)
			qdel(src)
		else
			holder.tripped()

	Crossed(atom/movable/AM as mob|obj)
		..()
		if (isobserver(AM) || !AM.density)
			return
		if (!istype(AM, /obj/mechbeam))
			SPAWN(0) tripped()

/obj/item/mechanics/triplaser
	name = "Trip laser"
	desc = "Fires a signal when someone passes through the beam."
	icon = 'icons/obj/networked.dmi'
	icon_state = "secdetector0"
	can_rotate = 1
	cabinet_banned = TRUE // abusable. B&
	one_per_tile = TRUE //also abusable
	var/range = 5
	var/list/beamobjs = new/list(5)//just to avoid someone doing something dumb and making it impossible for us to clear out the beams
	var/active = FALSE
	var/sendstr = "1"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", PROC_REF(toggle))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Range",PROC_REF(setRange))

	proc/setRange(obj/item/W as obj, mob/user as mob)
		var/rng = input("Range is limited between 1-5.", "Enter a new range", range) as num
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		range = clamp(rng, 1, 5)
		boutput(user, SPAN_NOTICE("Range set to [range]!"))
		if(level == UNDERFLOOR)
			rebeam()
		return TRUE

	proc/toggle()
		if(active)
			loosen()
		else
			secure()
	loosen()
		active = FALSE
		for(var/beam in beamobjs)
			qdel(beam)
	secure()
		rebeam()

	rotate()
		..()
		if(level == UNDERFLOOR)
			rebeam()

	disposing()
		loosen()
		..()

	proc/tripped()
		LIGHT_UP_HOUSING
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG, null)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == OVERFLOOR && GET_DIST(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.set_loc(target)

	proc/rebeam()
		loosen()
		active = TRUE
		beamobjs = list()
		var/turf/lastturf = get_step(get_turf(src), dir)
		for(var/i = 1, i<range, i++)
			if(lastturf.opacity || !lastturf.Enter(src)) // bootlegging src as an Enter arg. shouldn't matter
				break
			var/obj/mechbeam/newbeam = new(lastturf, src)
			newbeam.set_dir(src.dir)
			beamobjs[++beamobjs.len] = newbeam
			lastturf = get_step(lastturf, dir)

/obj/item/mechanics/hscan
	name = "Hand scanner"
	desc = ""
	icon_state = "comp_hscan"
	var/send_name = FALSE

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal Type",PROC_REF(toggleSig))

	proc/toggleSig(obj/item/W as obj, mob/user as mob)
		send_name = !send_name
		boutput(user, "[send_name ? "Now sending user NAME":"Now sending user FINGERPRINT"]")
		return TRUE

	attack_hand(mob/user)
		if(level == UNDERFLOOR && !ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			if(ishuman(user) && user.bioHolder)
				LIGHT_UP_HOUSING
				FLICK("comp_hscan1",src)
				playsound(src.loc, 'sound/machines/twobeep2.ogg', 90, 0)
				var/sendstr = (send_name ? user.real_name : user.bioHolder.fingerprints)
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,sendstr)
			else
				boutput(user, SPAN_ALERT("The hand scanner can only be used by humanoids."))
				return
		else return ..(user)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == OVERFLOOR && GET_DIST(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.set_loc(target)

#define GRAVITON_ITEM_COOLDOWN 10
#define GRAVITON_CONTAINER_COOLDOWN 35
#define GRAVITON_CONTAINER_FAIL_SOUND_VOLUME 30
#define GRAVITON_CONTAINER_FAIL_SOUND_COOLDOWN 10
#define GRAVITON_CONTAINER_COOLDOWN_ID "Graviton container cooldown"
#define GRAVITON_CONTAINER_FAIL_SOUND_COOLDOWN_ID "Graviton container fail sound cooldown"
/obj/item/mechanics/accelerator
	name = "Graviton accelerator"
	desc = ""
	icon_state = "comp_accel"
	can_rotate = 1
	var/active = FALSE
	event_handler_flags = USE_FLUID_ENTER

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", PROC_REF(activateproc))

	proc/drivecurrent(var/obj/item/storage/mechanics/container = null)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING

		if(container)
			if(ON_COOLDOWN(container, GRAVITON_CONTAINER_COOLDOWN_ID, GRAVITON_CONTAINER_COOLDOWN) || container.anchored) // Cooldown is shared between all gravitons in locker
				if(ON_COOLDOWN(container, GRAVITON_CONTAINER_FAIL_SOUND_COOLDOWN_ID, GRAVITON_CONTAINER_FAIL_SOUND_COOLDOWN)) // cooldown in a cooldown
					playsound(src, 'sound/machines/buzz-sigh.ogg', GRAVITON_CONTAINER_FAIL_SOUND_VOLUME, 0, 0)
				return
			throwstuff(container, 3)
		else
			var/count = 0
			for(var/atom/movable/M in src.loc)
				if(M.anchored) continue
				count++
				if(M == src) continue
				throwstuff(M)
				if(count > 50)
					return

	proc/activateproc(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		if(input)
			if(active)
				return
			particleMaster.SpawnSystem(new /datum/particleSystem/gravaccel(src.loc, src.dir))

			var/obj/item/storage/mechanics/container  = src.stored?.linked_item
			var/in_container = istype(container,/obj/item/storage/mechanics)
			SPAWN(0)
				icon_state = "[under_floor ? "u":""]comp_accel1"
				active = TRUE
				drivecurrent(container)
				sleep(0.5 SECONDS)
				if (!in_container)
					drivecurrent() // Gravitons in lockers only bonk once
				sleep(2.5 SECONDS)
				icon_state = "[under_floor ? "u":""]comp_accel"
				active = FALSE

	proc/throwstuff(atom/movable/AM as mob|obj, range = 50)
		if(level == OVERFLOOR || AM.anchored || AM == src)
			return
		if(AM.throwing)
			return
		var/atom/target = get_edge_target_turf(AM, src.dir)
		var/datum/thrown_thing/thr = AM.throw_at(target, range, 1)
		thr?.user = owner

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(level == OVERFLOOR)
			return
		if(active)
			throwstuff(AM)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_accel"
#undef GRAVITON_ITEM_COOLDOWN
#undef GRAVITON_CONTAINER_COOLDOWN
#undef GRAVITON_CONTAINER_FAIL_SOUND_VOLUME
#undef GRAVITON_CONTAINER_FAIL_SOUND_COOLDOWN
#undef GRAVITON_CONTAINER_COOLDOWN_ID
#undef GRAVITON_CONTAINER_FAIL_SOUND_COOLDOWN_ID

/// Tesla Coil mechanics component - zaps people
/obj/item/mechanics/zapper
	name = "Tesla Coil"
	desc = ""
	icon_state = "comp_zap"
	cooldown_time = 1 SECOND
	cabinet_banned = TRUE
	one_per_tile = TRUE
	var/zap_power = 2

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"zap", PROC_REF(eleczap))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Power",PROC_REF(setPower))

	proc/eleczap(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			return
		var/area/AR = get_area(src)
		if(!AR.powered(EQUIP) || AR.area_apc?.cell?.percent() < 35)
			return
		AR.use_power(0.5 KILO WATTS, EQUIP)
		LIGHT_UP_HOUSING
		elecflash(src.loc, 0, power = zap_power, exclude_center = 0)

	proc/setPower(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Power(1 - 3):","Power setting", zap_power) as num
		if(!in_interact_range(src, user) || !isalive(user))
			return FALSE
		inp = clamp(round(inp), 1, 3)
		zap_power = inp
		boutput(user, "Power set to [inp]")
		return TRUE

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_zap"

	get_desc()
		. = ..()
		var/area/AR = get_area(src)
		if(!AR.powered(EQUIP) || AR.area_apc?.cell?.percent() < 35)
			. += " It does not seem to have enough power from the APC."

/obj/item/mechanics/pausecomp
	name = "Delay Component"
	desc = ""
	icon_state = "comp_wait"
	var/active = FALSE
	var/delay = 10
	var/changesig = FALSE

	get_desc()
		. += "<br>[SPAN_NOTICE("Current Delay: [delay]")]"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"delay", PROC_REF(delayproc))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Delay",PROC_REF(setDelay))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal Changing",PROC_REF(toggleDefault))

	proc/setDelay(obj/item/W as obj, mob/user as mob)
		var/inp = input(user, "Enter delay in 10ths of a second:", "Set delay", 10) as num
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		inp = max(inp, 10)
		if(!isnull(inp))
			delay = inp
			tooltip_rebuild = TRUE
			boutput(user, "Set delay to [inp]")
			return TRUE
		return FALSE

	proc/toggleDefault(obj/item/W as obj, mob/user as mob)
		changesig = !changesig
		boutput(user, "Signal changing now [changesig ? "on":"off"]")
		return TRUE

	proc/delayproc(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		if(input)
			if(active)
				return
			LIGHT_UP_HOUSING
			SPAWN(0)
				if(src)
					icon_state = "[under_floor ? "u":""]comp_wait1"
					active = TRUE
				sleep(delay)
				if(src)
					var/transmissionStyle = changesig ? COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG : COMSIG_MECHCOMP_TRANSMIT_MSG
					SEND_SIGNAL(src,transmissionStyle,input)
					icon_state = "[under_floor ? "u":""]comp_wait"
					active = FALSE

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_wait"

//If two signals arrive within the timeframe: send the set signal
/obj/item/mechanics/andcomp
	name = "AND Component"
	desc = ""
	icon_state = "comp_and"
	var/timeframe = 3 SECONDS
	var/inp1 = FALSE
	var/inp2 = FALSE

	get_desc()
		. += "<br>[SPAN_NOTICE("Current Time Frame: [timeframe]")]"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 1", PROC_REF(fire1))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 2", PROC_REF(fire2))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Time Frame",PROC_REF(setTime))

	proc/setTime(obj/item/W as obj, mob/user as mob)
		var/inp = input(user, "Enter Time Frame in 10ths of a second:", "Set Time Frame", timeframe) as num
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(!isnull(inp))
			timeframe = inp
			tooltip_rebuild = TRUE
			boutput(user, "Set Time Frame to [inp]")
			return TRUE
		return FALSE

	proc/fire1(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		if(inp1)
			return
		LIGHT_UP_HOUSING
		inp1 = TRUE

		if(inp2)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,input)
			inp1 = FALSE
			inp2 = FALSE
			return

		SPAWN(timeframe)
			inp1 = FALSE

	proc/fire2(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		if(inp2)
			return
		LIGHT_UP_HOUSING
		inp2 = TRUE

		if(inp1)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,input)
			inp1 = FALSE
			inp2 = FALSE
			return

		SPAWN(timeframe)
			inp2 = FALSE

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_and"

/obj/item/mechanics/orcomp
	name = "OR Component"
	desc = ""
	icon_state = "comp_or"
	var/triggerSignal = "1"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 1", PROC_REF(fire))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 2", PROC_REF(fire))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 3", PROC_REF(fire))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 4", PROC_REF(fire))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 5", PROC_REF(fire))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 6", PROC_REF(fire))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 7", PROC_REF(fire))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 8", PROC_REF(fire))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 9", PROC_REF(fire))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 10", PROC_REF(fire))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Trigger Field",PROC_REF(setTrigger))

	proc/setTrigger(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Signal:","Signal setting", triggerSignal) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(inp))
			inp = strip_html_tags(html_decode(inp))
			triggerSignal = inp
			boutput(user, "Signal set to [inp]")
			return TRUE
		return FALSE

	proc/fire(var/datum/mechanicsMessage/input)
		if(level == UNDERFLOOR && input.signal == triggerSignal)
			LIGHT_UP_HOUSING
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,input)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_or"

/obj/item/mechanics/wifisplit
	name = "Signal Splitter Component"
	desc = ""
	icon_state = "comp_split"
	var/triggerSignal = "1"

	get_desc()
		. += "<br>[SPAN_NOTICE("Current Trigger Field: [triggerSignal]")]"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"split", PROC_REF(split))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set trigger", PROC_REF(set_trigger_by_signal))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Trigger Field",PROC_REF(setTrigger))

	proc/set_trigger_by_signal(var/datum/mechanicsMessage/input)
		if(level == 2)
			return
		src.triggerSignal = input.signal
		src.tooltip_rebuild = TRUE

	proc/setTrigger(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Signal:","Signal setting", triggerSignal) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(inp))
			inp = strip_html_tags(html_decode(inp))
			triggerSignal = inp
			tooltip_rebuild = TRUE
			boutput(user, "Signal set to [inp]")
			return TRUE
		return FALSE

	proc/split(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		var/list/converted = params2complexlist(input.signal)
		if(length(converted))
			if(triggerSignal in converted)
				input.signal = converted[triggerSignal]
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG, input)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_split"

/obj/item/mechanics/regreplace
	name = "RegEx Replace Component"
	desc = ""
	icon_state = "comp_regrep"
	var/expressionpatt = "original"
	var/expressionrepl = "replacement"
	var/expressionflag = "g"

	get_desc()
		. += {"<br/>[SPAN_NOTICE("Current Pattern: [html_encode(expressionpatt)]")]<br/>
		[SPAN_NOTICE("Current Replacement: [html_encode(expressionrepl)]")]<br/>
		[SPAN_NOTICE("Current Flags: [html_encode(expressionflag)]")]<br/>
		Your replacement string can contain $0-$9 to insert that matched group(things between parenthesis)<br/>
		$` will be replaced with the text that came before the match, and $' will be replaced by the text after the match.<br/>
		$0 or $& will be the entire matched string."}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"replace string", PROC_REF(checkstr))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set pattern", PROC_REF(setPatternSignal))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set replacement", PROC_REF(setReplacementSignal))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set flags", PROC_REF(setFlagsSignal))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Pattern",PROC_REF(setPattern))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Replacement",PROC_REF(setReplacement))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Flags",PROC_REF(setFlags))

	proc/setPattern(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Pattern:","Pattern setting", expressionpatt) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(inp))
			expressionpatt = inp
			inp = sanitize(html_encode(inp))
			boutput(user, "Pattern set to [inp]")
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/setPatternSignal(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		expressionpatt = input.signal
		tooltip_rebuild = TRUE

	proc/setReplacement(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Replacement:","Replacement setting", expressionrepl) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(inp))
			expressionrepl = inp
			inp = sanitize(html_encode(inp))
			boutput(user, "Replacement set to [inp]")
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/setReplacementSignal(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		expressionrepl = input.signal
		tooltip_rebuild = TRUE

	proc/setFlags(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Flags:","Flags setting", expressionflag) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(inp))
			expressionflag = inp
			inp = sanitize(html_encode(inp))
			boutput(user, "Flags set to [inp]")
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/setFlagsSignal(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		expressionflag = input.signal
		tooltip_rebuild = TRUE

	proc/checkstr(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !length(expressionpatt))
			return
		LIGHT_UP_HOUSING
		var/regex/R = new(expressionpatt,expressionflag)

		if(!R)
			return

		var/mod = R.Replace(input.signal, expressionrepl)
		mod = strip_html_tags(sanitize(html_encode(mod)))//U G H

		if(mod)
			input.signal = mod
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_regrep"

/obj/item/mechanics/regfind
	name = "RegEx Find Component"
	desc = ""
	icon_state = "comp_regfind"
	var/replacesignal = 0
	var/expressionTT = "\[a-zA-Z\]*"
	var/expressionpatt = "\[a-zA-Z\]*"
	var/expressionflag

	get_desc()
		. += {"<br><span class='notice'>Current Expression: [sanitize(html_encode(expressionTT))]<br>
		Replace Signal is [replacesignal ? "on.":"off."]</span>"}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"check string", PROC_REF(checkstr))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set regex", PROC_REF(setregex))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Expression Pattern",PROC_REF(setRegex))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Expression Flags",PROC_REF(setFlags))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal replacing",PROC_REF(toggleReplaceing))

	proc/setRegex(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Expression Pattern:","Expression setting", expressionpatt) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(inp))
			expressionpatt = inp
			expressionTT =("[expressionpatt]/[expressionflag]")
			inp = sanitize(html_encode(inp))
			boutput(user, "Expression Pattern set to [inp], Current Expression: [sanitize(html_encode(expressionTT))]")
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/setFlags(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Expression Flags:","Expression setting", expressionflag) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(inp))
			expressionflag = inp
			expressionTT =("[expressionpatt]/[expressionflag]")
			inp = sanitize(html_encode(inp))
			boutput(user, "Expression Flags set to [inp], Current Expression: [sanitize(html_encode(expressionTT))]")
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/toggleReplaceing(obj/item/W as obj, mob/user as mob)
		replacesignal = !replacesignal
		boutput(user, "[replacesignal ? "Now forwarding own Signal":"Now forwarding found String"]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/setregex(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		expressionpatt = input.signal
		expressionTT = ("[expressionpatt]/[expressionflag]")
		tooltip_rebuild = TRUE
	proc/checkstr(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !length(expressionTT))
			return
		LIGHT_UP_HOUSING
		var/regex/R = new(expressionpatt, expressionflag)

		if(!R)
			return

		if(R.Find(input.signal))
			if(replacesignal)
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,input)
			else
				input.signal = R.match
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_regfind"

/obj/item/mechanics/sigcheckcomp
	name = "Signal-Check Component"
	desc = ""
	icon_state = "comp_check"
	var/not = 0
	var/changesig = 0
	var/triggerSignal = "1"

	get_desc()
		. += {"<br><span class='notice'>[not ? "Component triggers when Signal is NOT found.":"Component triggers when Signal IS found."]<br>
		Replace Signal is [changesig ? "on.":"off."]<br>
		Currently checking for: [sanitize(html_encode(triggerSignal))]</span>"}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"check string", PROC_REF(checkstr))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set trigger", PROC_REF(settrigger))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Trigger-String",PROC_REF(setTrigger))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Invert Trigger",PROC_REF(invertTrigger))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Replace Signal",PROC_REF(toggleReplace))

	proc/setTrigger(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter String:","String setting","1") as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(inp))
			inp = adminscrub(inp)
			triggerSignal = inp
			boutput(user, "String set to [inp]")
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/invertTrigger(obj/item/W as obj, mob/user as mob)
		not = !not
		boutput(user, "[not ? "Component will now trigger when the String is NOT found.":"Component will now trigger when the String IS found."]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/toggleReplace(obj/item/W as obj, mob/user as mob)
		changesig = !changesig
		boutput(user, "Signal changing now [changesig ? "on":"off"]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/checkstr(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		var/transmissionStyle = changesig ? COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG : COMSIG_MECHCOMP_TRANSMIT_MSG
		if(findtext(input.signal, triggerSignal))
			if(!not)
				SEND_SIGNAL(src,transmissionStyle,input)
		else
			if(not)
				SEND_SIGNAL(src,transmissionStyle,input)

	proc/settrigger(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		triggerSignal = input.signal
		tooltip_rebuild = TRUE

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_check"

/obj/item/mechanics/dispatchcomp
	name = "Dispatch Component"
	desc = ""
	icon_state = "comp_disp"
	var/exact_match = FALSE
	var/single_output = FALSE

	//This stores all the relevant filters per output
	//Notably, this list doesn't remove entries when an output is removed.
	//So it will bloat over time...
	var/list/outgoing_filters

	get_desc()
		. += "<br>[SPAN_NOTICE("Exact match mode: [exact_match ? "on" : "off"]<br>Single output mode: [single_output ? "on" : "off"]")]"

	New()
		..()
		src.outgoing_filters = list()
		RegisterSignal(src, _COMSIG_MECHCOMP_DISPATCH_ADD_FILTER, PROC_REF(addFilter))
		RegisterSignal(src, _COMSIG_MECHCOMP_DISPATCH_RM_OUTGOING, PROC_REF(removeFilter))
		RegisterSignal(src, _COMSIG_MECHCOMP_DISPATCH_VALIDATE, PROC_REF(runFilter))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"dispatch", PROC_REF(dispatch))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle exact matching",PROC_REF(toggleExactMatching))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle single output mode",PROC_REF(toggleSingleOutput))

	disposing()
		var/list/signals = list(\
		_COMSIG_MECHCOMP_DISPATCH_ADD_FILTER,\
		_COMSIG_MECHCOMP_DISPATCH_RM_OUTGOING,\
		_COMSIG_MECHCOMP_DISPATCH_VALIDATE)
		UnregisterSignal(src, signals)
		src.outgoing_filters.Cut()
		..()

	loosen()
		src.outgoing_filters.Cut()

	proc/toggleExactMatching(obj/item/W as obj, mob/user as mob)
		exact_match = !exact_match
		boutput(user, "Exact match mode now [exact_match ? "on" : "off"]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/toggleSingleOutput(obj/item/W as obj, mob/user as mob)
		single_output = !single_output
		boutput(user, "Single output mode now [single_output ? "on" : "off"]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/dispatch(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		var/sent = SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		if(sent) animate_flash_color_fill(src,"#00FF00",2, 2)

	//This will get called from the component-datum when a device is being linked
	proc/addFilter(var/comsig_target, atom/receiver, mob/user)
		var/filter = input(user, "Add filters for this connection? (Comma-delimited list. Leave blank to pass all messages.)", "Intput Filters") as text
		if(!in_interact_range(src, user) || user.stat)
			return
		if (length(filter))
			if (!src.outgoing_filters[receiver]) src.outgoing_filters[receiver] = list()
			src.outgoing_filters.Add(receiver)
			src.outgoing_filters[receiver] = splittext(filter, ",")
			boutput(user, SPAN_SUCCESS("Only passing messages that [exact_match ? "match" : "contain"] [filter] to the [receiver.name]"))
		else
			boutput(user, SPAN_SUCCESS("Passing all messages to the [receiver.name]"))

	//This will get called from the component-datum when a device is being unlinked
	proc/removeFilter(var/comsig_target, atom/receiver)
		src.outgoing_filters.Remove(receiver)

	//Called when mechanics_holder tries to fire out signals
	proc/runFilter(var/comsig_target, atom/receiver, var/signal)
		if(!(receiver in src.outgoing_filters))
			return src.single_output? _MECHCOMP_VALIDATE_RESPONSE_HALT_AFTER : _MECHCOMP_VALIDATE_RESPONSE_GOOD //Not filtering this output, let anything pass
		for (var/filter in src.outgoing_filters[receiver])
			var/text_found = findtext(signal, filter)
			if (exact_match)
				text_found = text_found && (length(signal) == length(filter))
			if (text_found)
				return src.single_output? _MECHCOMP_VALIDATE_RESPONSE_HALT_AFTER : _MECHCOMP_VALIDATE_RESPONSE_GOOD //Signal validated, let it pass
		return TRUE //Signal invalid, halt it

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_disp"

/obj/item/mechanics/sigbuilder
	name = "Signal Builder Component"
	desc = ""
	icon_state = "comp_builder"
	var/buffer = ""
	var/bstr = ""
	var/astr = ""

	get_desc()
		. += {"<br><span class='notice'>Current Buffer Contents: [html_encode(sanitize(buffer))]<br>"
		Current starting String: [html_encode(sanitize(bstr))]<br>"
		Current ending String: [html_encode(sanitize(astr))]</span>"}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"add to string", PROC_REF(addstr))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"add to string + send", PROC_REF(addstrsend))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send", PROC_REF(sendstr))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"clear buffer", PROC_REF(clrbff))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set starting string", PROC_REF(setStartingStringSignal))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set ending string", PROC_REF(setEndingStringSignal))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set starting String",PROC_REF(setStartingStringManual))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set ending String",PROC_REF(setEndingStringManual))

	proc/setStartingStringManual(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter String:","String setting", bstr) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		setStartingString(inp)
		boutput(user, "String set to [bstr]")
		return TRUE

	proc/setStartingStringSignal(var/datum/mechanicsMessage/input)
		if (level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		setStartingString(input.signal)

	proc/setStartingString(var/inp)
		inp = strip_html_tags(inp)
		bstr = inp
		tooltip_rebuild = TRUE

	proc/setEndingStringManual(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter String:","String setting", astr) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		setEndingString(inp)
		boutput(user, "String set to [astr]")
		return TRUE

	proc/setEndingStringSignal(var/datum/mechanicsMessage/input)
		if (level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		setEndingString(input.signal)

	proc/setEndingString(var/inp)
		inp = strip_html_tags(inp)
		astr = inp
		tooltip_rebuild = TRUE

	proc/addstr(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		buffer = "[buffer][input.signal]"
		tooltip_rebuild = TRUE

	proc/addstrsend(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		buffer = "[buffer][input.signal]"
		tooltip_rebuild = TRUE
		sendstr(input)

	proc/sendstr(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		var/finished = "[bstr][buffer][astr]"
		finished = strip_html_tags(sanitize(finished))
		input.signal = finished
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		buffer = ""
		tooltip_rebuild = TRUE

	proc/clrbff(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		buffer = ""
		tooltip_rebuild = TRUE

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_builder"

/obj/item/mechanics/relaycomp
	name = "Relay Component"
	desc = ""
	icon_state = "comp_relay"
	cooldown_time = 0.4 SECONDS
	var/changesig = 0

	get_desc()
		. += "<br>[SPAN_NOTICE("Replace Signal is [changesig ? "on.":"off."]")]"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"relay", PROC_REF(relay))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal Changing",PROC_REF(toggleDefault))

	proc/toggleDefault(obj/item/W as obj, mob/user as mob)
		changesig = !changesig
		boutput(user, "Signal changing now [changesig ? "on":"off"]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/relay(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			return
		LIGHT_UP_HOUSING
		FLICK("[under_floor ? "u":""]comp_relay1", src)
		var/transmissionStyle = changesig ? COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG : COMSIG_MECHCOMP_TRANSMIT_MSG
		SPAWN(0) SEND_SIGNAL(src,transmissionStyle,input)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_relay"

#define FIFO_BUFFER 1
#define FILO_BUFFER 2
#define RANDOM_BUFFER 3
#define RING_BUFFER 4 //When I say ring buffer what I really mean is..
		//...FIFO queue with clobbering like an audio buffer

/obj/item/mechanics/buffercomp
	name = "Buffer Component"
	desc = ""
	icon_state = "comp_buffer"
	cooldown_time = 0.4 SECONDS
	process_fast = TRUE
	var/list/buffer = list()
	var/buffer_size = 30
	//I wanted to set this to the same limit as the selection component
	//But the selection compoment doesn't actually have a limit in the additem() proc
	//It kind of worries me
	var/buffer_max_size = 512
	var/ring_reader = 1
	var/ring_writer = 1

	var/buffer_model = RING_BUFFER
	var/buffer_string = "ring"
	var/buffer_desc = "This mode outputs from oldest to newest, overwriting the oldest signal when full."
	var/changesig = 0


	get_desc()
		. += "<br>[SPAN_NOTICE("Delay is [cooldown_time] (in 10ths of a second). <br> Buffer size is [buffer_size].\
		 <br> Buffer mode is [buffer_string].<br>[buffer_desc]")]"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"buffer", PROC_REF(buffer))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set buffer mode", PROC_REF(compSetModel))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Delay",PROC_REF(setDelay))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Buffer Mode",PROC_REF(userSetModel))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Buffer Size",PROC_REF(setBufferSize))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal Changing",PROC_REF(toggleDefault))

	proc/setModel(var/model)
		//Uppercase everything so signal input can be case insensitive
		model = uppertext(model)
		if(model == "FIFO")
			buffer_desc = "This mode outputs from oldest to newest, dropping signals when full."
			buffer_model = FIFO_BUFFER
		else if(model == "FILO")
			buffer_desc = "This mode outputs from newest to oldest, dropping signals when full."
			buffer_model = FILO_BUFFER
		else if(model == "RING")
			model = "ring"
			buffer_desc = "This mode outputs from oldest to newest, overwriting the oldest signal when full."
			buffer_model = RING_BUFFER
		else if(model == "RANDOM")
			model = "random"
			buffer_desc = "This mode outputs signals randomly, randomly overwriting previous signals when full."
			buffer_model = RANDOM_BUFFER
		else
			return FALSE

		buffer_string = model
		tooltip_rebuild = TRUE
		buffer.len = 0
		ring_reader = 1
		ring_writer = 1
		return TRUE

	proc/compSetModel(var/datum/mechanicsMessage/input)
		if(setModel(input.signal))
			LIGHT_UP_HOUSING

	proc/userSetModel(obj/item/W as obj, mob/user as mob)
		var/model = tgui_input_list(user, "Set the buffer mode to what?", "Mode Selector", list("FIFO","FILO","ring","random"), buffer_string)
		if(!in_interact_range(src, user) || !can_act(user) || isnull(model))
			return
		setModel(model)
		boutput(user, "You set the buffer mode to [model]")



	//Thanks delay component
	proc/setDelay(obj/item/W as obj, mob/user as mob)
		var/inp = tgui_input_number(user, "Enter delay in 10ths of a second:", "Set delay", cooldown_time, 60, 4)
		if(!in_interact_range(src, user) || !can_act(user) || isnull(inp))
			return
		inp = min(inp, 60)
		inp = max(4, inp)
		cooldown_time = inp
		tooltip_rebuild = TRUE
		boutput(user, "Set delay to [inp]")

	proc/setBufferSize(obj/item/W as obj, mob/user as mob)
		var/inp = tgui_input_number(user,"Set size of signal buffer","Buffer size", buffer_size,buffer_max_size,1)
		if(!in_interact_range(src, user) || !can_act(user) || isnull(inp))
			return

		if (isnull(inp))
			return
		inp = round(inp)
		inp = clamp(inp, 1, buffer_max_size)
		buffer_size = inp
		tooltip_rebuild = TRUE
		buffer.len = 0
		ring_reader = 1
		ring_writer = 1
		boutput(user,"You set the buffer size to [inp]")

	proc/toggleDefault(obj/item/W as obj, mob/user as mob)
		changesig = !changesig
		boutput(user, "Signal changing now [changesig ? "on":"off"]")
		tooltip_rebuild = TRUE

	proc/buffer(var/datum/mechanicsMessage/input)
		var/bufl = length(buffer)
		if(buffer_model == RING_BUFFER)
			if(bufl >= ring_writer)
				buffer[ring_writer] = input
			else
				buffer.Add(input)
			//Round and round we go
			//If the writer runs into the reader and the next item in the queue isn't null
			//That means that item is the oldest, jump the reader to it
			//Watch out for the edge
			if(ring_reader == ring_writer)
				if((ring_reader + 1) > buffer_size && !isnull(buffer[1]) )
					ring_reader = 1
				else if(bufl >= (ring_reader + 1) && !isnull(buffer[(ring_reader + 1)]))
					ring_reader++
			ring_writer = (ring_writer % buffer_size) + 1
			return

		if(buffer_model == RANDOM_BUFFER)
			if(bufl >= buffer_size)
				buffer[rand(1,(bufl))] = input
			else
				buffer.Add(input)
			return
		if(bufl >= buffer_size)
			return
		if(buffer_model == FIFO_BUFFER || buffer_model == FILO_BUFFER)
			buffer.Add(input)

	process()
		..()

		if(level == OVERFLOOR || ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			return

		var/bufl = (length(buffer))
		var/signal = null
		if(bufl > 0)

			if(buffer_model == FIFO_BUFFER)
				signal = buffer[1]
				buffer.Remove(buffer[1])
			if(buffer_model == FILO_BUFFER)
				signal = buffer[bufl]
				buffer.Remove(buffer[bufl])
			if(buffer_model == RING_BUFFER && bufl >= ring_reader && !isnull(buffer[ring_reader]) )
				signal = buffer[ring_reader]
				buffer[ring_reader] = null
				ring_reader++
				if(ring_reader > buffer_size)
					ring_reader = 1
			if(buffer_model == RANDOM_BUFFER)
				var/ran = rand(1,bufl)
				signal = buffer[ran]
				buffer.Remove(buffer[ran])

			if(isnull(signal))
				return

			LIGHT_UP_HOUSING
			FLICK("[under_floor ? "u":""]comp_buffer1", src)
			var/transmissionStyle = changesig ? COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG : COMSIG_MECHCOMP_TRANSMIT_MSG
			SPAWN(0) SEND_SIGNAL(src,transmissionStyle,signal)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_buffer"


#undef FIFO_BUFFER
#undef FILO_BUFFER
#undef RANDOM_BUFFER
#undef RING_BUFFER

/obj/item/mechanics/filecomp
	name = "File Component"
	desc = ""
	icon_state = "comp_file"
	var/datum/computer/file/stored_file

	get_desc()
		. += "<br>[SPAN_NOTICE("Stored file:[stored_file ? "<br>Name: [src.stored_file.name]<br>Extension: [src.stored_file.extension]<br>Contents: [src.stored_file.asText()]" : " NONE"]")]"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send file", PROC_REF(sendfile))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"add file to signal and send", PROC_REF(addandsendfile))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"save file", PROC_REF(storefile))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"delete file", PROC_REF(deletefile))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)

	disposing()
		if (src.stored_file)
			stored_file.dispose()
		..()

	proc/sendfile(var/datum/mechanicsMessage/input)
		if (level == OVERFLOOR || !src.stored_file)
			return
		LIGHT_UP_HOUSING
		input.data_file = src.stored_file.copy_file()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,input)
		animate_flash_color_fill(src,"#00FF00",2, 2)

	proc/addandsendfile(var/datum/mechanicsMessage/input)
		if (level == OVERFLOOR || !src.stored_file)
			return
		LIGHT_UP_HOUSING
		input.data_file = src.stored_file.copy_file()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		animate_flash_color_fill(src,"#00FF00",2, 2)

	proc/storefile(var/datum/mechanicsMessage/input)
		if (level == OVERFLOOR || !input.data_file)
			return
		LIGHT_UP_HOUSING
		src.stored_file = input.data_file.copy_file()
		tooltip_rebuild = TRUE
		animate_flash_color_fill(src,"#00FF00",2, 2)

	proc/deletefile(var/datum/mechanicsMessage/input)
		if (level == OVERFLOOR || !src.stored_file)
			return
		LIGHT_UP_HOUSING
		src.stored_file = null
		tooltip_rebuild = TRUE
		animate_flash_color_fill(src,"#00FF00",2, 2)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_file"

/obj/item/mechanics/wificomp
	name = "Wifi Component"
	desc = ""
	icon_state = "comp_radiosig"
	cooldown_time = 0.4 SECONDS
	var/forward_all = 0
	var/only_directed = 1

	var/net_id = null //What is our ID on the network?
	var/last_ping = 0
	var/range = null

	var/noise_enabled = TRUE
	var/frequency = FREQ_FREE

	get_desc()
		. += {"<br><span class='notice'>[forward_all ? "Sending full unprocessed Signals.":"Sending only processed sendmsg and pda Message Signals."]<br>
		[only_directed ? "Only reacting to Messages directed at this Component.":"Reacting to ALL Messages received."]<br>
		Current Frequency: [frequency]<br>
		Current Range: [isnull(range) ? "Unlimited" : range]<br>
		Current NetID: [net_id]</span>"}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send radio message", PROC_REF(send))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set frequency", PROC_REF(setfreq))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set range", PROC_REF(setrange))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Frequency",PROC_REF(setFreqManually))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Range",PROC_REF(setRangeManually))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle NetID Filtering",PROC_REF(toggleAddressFiltering))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Forward All",PROC_REF(toggleForwardAll))

		src.net_id = format_net_id("\ref[src]")
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(src.net_id, "main", frequency)

	proc/setFreqManually(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Frequency:","Frequency setting", frequency) as num
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(!isnull(inp))
			set_frequency(inp)
			boutput(user, "Frequency set to [inp]")
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/setRangeManually(obj/item/W as obj, mob/user as mob)
		var/inp = input(user, "Please enter the range (-1 for unlimited):", "Range setting", isnull(range) ? -1 : range) as num
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		inp = text2num_safe(inp)
		if(isnull(inp))
			return FALSE
		if(inp == -1)
			src.range = null
			boutput(user, "Range set to unlimited")
			tooltip_rebuild = TRUE
			return TRUE
		inp = clamp(inp, 0, 512)
		src.range = inp
		boutput(user, "Range set to [inp]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/toggleAddressFiltering(obj/item/W as obj, mob/user as mob)
		only_directed = !only_directed
		get_radio_connection_by_id(src, "main").update_all_hearing(!only_directed)
		boutput(user, "[only_directed ? "Now only reacting to Messages directed at this Component":"Now reacting to ALL Messages."]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/toggleForwardAll(obj/item/W as obj, mob/user as mob)
		forward_all = !forward_all
		boutput(user, "[forward_all ? "Now forwarding all Radio Messages as they are.":"Now processing only sendmsg and normal PDA messages."]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/setrange(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		var/newrange = text2num_safe(input.signal)
		if(isnull(newrange))
			return
		if(newrange == -1)
			src.range = null
			tooltip_rebuild = TRUE
			return
		newrange = clamp(newrange, 0, 512)
		src.range = newrange
		tooltip_rebuild = TRUE

	proc/setfreq(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		var/newfreq = text2num_safe(input.signal)
		if(!newfreq)
			return
		set_frequency(newfreq)

	proc/send(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		var/list/converted = params2complexlist(input.signal)
		if(!length(converted) || ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			return

		var/datum/signal/sendsig = get_free_signal()

		sendsig.source = src
		sendsig.data["sender"] = src.net_id

		for(var/X in converted)
			sendsig.data["[X]"] = "[converted[X]]"
			if(X == "command" && converted[X] == "text_message")
				logTheThing(LOG_PDAMSG, usr, "sends a PDA message <b>[input.signal]</b> using a wifi component at [log_loc(src)].")
		if(input.data_file)
			sendsig.data_file = input.data_file.copy_file()
		SPAWN(0)
			if(src.noise_enabled)
				src.noise_enabled = FALSE
				playsound(src, 'sound/machines/wifi.ogg', WIFI_NOISE_VOLUME, 0, 0)
				SPAWN(WIFI_NOISE_COOLDOWN)
					src.noise_enabled = TRUE
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, sendsig, src.range, "main")

		animate_flash_color_fill(src,"#FF0000",2, 2)

	receive_signal(datum/signal/signal)
		if(!signal || level == OVERFLOOR)
			return

		if((only_directed && signal.data["address_1"] == src.net_id) || !only_directed || (signal.data["address_1"] == "ping"))

			if((signal.data["address_1"] == "ping") && signal.data["sender"])
				var/datum/signal/pingsignal = get_free_signal()
				pingsignal.source = src
				pingsignal.data["device"] = "COMP_WIFI"
				pingsignal.data["netid"] = src.net_id
				pingsignal.data["address_1"] = signal.data["sender"]
				pingsignal.data["command"] = "ping_reply"
				pingsignal.data["data"] = "Wifi Component"

				SPAWN(0.5 SECONDS) //Send a reply for those curious jerks
					if(src.noise_enabled)
						src.noise_enabled = FALSE
						playsound(src, 'sound/machines/wifi.ogg', WIFI_NOISE_VOLUME, 0, 0)
						SPAWN(WIFI_NOISE_COOLDOWN)
							src.noise_enabled = TRUE
					SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pingsignal, src.range)

			if(signal.data["command"] == "text_message" && signal.data["batt_adjust"] == netpass_syndicate)
				var/packets = ""
				for(var/d in signal.data)
					packets += "[d]=[signal.data[d]]; "
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, strip_html_tags(html_decode("ERR_12939_CORRUPT_PACKET:" + stars(packets, 15))), null)
				animate_flash_color_fill(src,"#ff0000",2, 2)
				return

			if(signal.encryption)
				var/packets = ""
				for(var/d in signal.data)
					packets += "[d]=[signal.data[d]]; "
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, strip_html_tags(html_decode("[signal.encryption]" + stars(packets, signal.encryption_obfuscation))), null)
				animate_flash_color_fill(src,"#ff0000",2, 2)
				return

			if(forward_all)
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, strip_html_tags(html_decode(list2params(signal.data))), signal.data_file?.copy_file())
				animate_flash_color_fill(src,"#00FF00",2, 2)
				return

			else if(signal.data["command"] == "sendmsg" && signal.data["data"])
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, strip_html_tags(html_decode(signal.data["data"])), signal.data_file?.copy_file())
				animate_flash_color_fill(src,"#00FF00",2, 2)

			else if(signal.data["command"] == "text_message" && signal.data["message"])
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, strip_html_tags(html_decode(signal.data["message"])), null)
				animate_flash_color_fill(src,"#00FF00",2, 2)

			else if(signal.data["command"] == "setfreq" && signal.data["data"])
				var/newfreq = text2num_safe(signal.data["data"])
				if(!newfreq)
					return
				set_frequency(newfreq)
				animate_flash_color_fill(src,"#00FF00",2, 2)


	proc/set_frequency(new_frequency)
		if(!radio_controller)
			return
		tooltip_rebuild = TRUE
		new_frequency = clamp(new_frequency, 1000, 1500)
		frequency = new_frequency
		get_radio_connection_by_id(src, "main").update_frequency(frequency)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_radiosig"

#undef WIFI_NOISE_COOLDOWN
#undef WIFI_NOISE_VOLUME
/obj/item/mechanics/selectcomp
	name = "Selection Component"
	desc = ""
	icon_state = "comp_selector"
	var/list/signals
	var/current_index = 1
	var/announce = 0
	var/random = 0
	var/allowDuplicates = 1

	get_desc()
		. += {"<br><span class='notice'>[random ? "Sending random Signals.":"Sending selected Signals."]<br>
		[announce ? "Announcing Changes.":"Not announcing Changes."]<br>
		[allowDuplicates ? "Duplicate entries allowed." : "Duplicate entries not allowed."]<br>
		Current Selection: [(!current_index || current_index > length(signals) ||!length(signals)) ? "Empty":"[current_index] -> [signals[current_index]]"]<br>
		Currently contains [length(signals)] Items:<br></span>
		[signals.Join("<br>")]"}

	New()
		..()
		signals = new/list()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"add item", PROC_REF(additem))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"remove item", PROC_REF(remitem))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"remove all items", PROC_REF(remallitem))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"select item", PROC_REF(selitem))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"select item + send", PROC_REF(selitemplus))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"next", PROC_REF(next))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"previous", PROC_REF(previous))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"next + send", PROC_REF(nextplus))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send + next", PROC_REF(plusnext))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"previous + send", PROC_REF(previousplus))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send selected", PROC_REF(sendCurrent))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send selected + remove", PROC_REF(popitem))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send random", PROC_REF(sendRand))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Signal List",PROC_REF(setSignalList))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Signal List(Delimeted)",PROC_REF(setDelimetedList))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Announcements",PROC_REF(toggleAnnouncements))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Random",PROC_REF(toggleRandom))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Allow Duplicate Entries",PROC_REF(toggleAllowDuplicates))


	proc/setSignalList(obj/item/W as obj, mob/user as mob)
		var/numsig = input(user,"How many Signals would you like to define?","# Signals:", 3) as num
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		numsig = round(numsig)
		if(numsig > 10) //Needs a limit because nerds are nerds
			boutput(user, SPAN_ALERT("This component can't handle more than 10 signals!"))
			return FALSE
		if(numsig)
			signals.Cut()
			current_index = 1
			boutput(user, "Defining [numsig] Signals ...")
			for(var/i=0, i<numsig, i++)
				var/signew = input(user,"Content of Signal #[i]","Content:", "signal[i]") as text
				signew = adminscrub(signew) //SANITIZE THAT SHIT! FUCK!!!!
				if(length(signew))
					signals.Add(signew)
			boutput(user, "Set [numsig] Signals!")
			for(var/a in signals)
				boutput(user, a)
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/setDelimetedList(obj/item/W as obj, mob/user as mob)
		var/newsigs = ""
		newsigs = input(user, "Enter a string delimited by ; for every item you want in the list.", "Enter a thing. Max length is 2048 characters", newsigs)
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(!newsigs)
			boutput(user, SPAN_NOTICE("Signals remain unchanged!"))
			return FALSE
		if(length(newsigs) >= 2048)
			alert(user, "That's far too long. Trim it down some!")
			return FALSE
		var/list/built = splittext(newsigs, ";")
		for(var/i = 1, i <= length(built), i++)
			if(!built[i])
				built.Remove(built[i])
				i--
		signals = built
		current_index = 1
		boutput(user, SPAN_NOTICE("There are now [length(signals)] signals in the list."))
		tooltip_rebuild = TRUE
		return TRUE

	proc/toggleAnnouncements(obj/item/W as obj, mob/user as mob)
		announce = !announce
		boutput(user, "Announcements now [announce ? "on":"off"]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/toggleRandom(obj/item/W as obj, mob/user as mob)
		random = !random
		boutput(user, "[random ? "Now picking Items at random.":"Now using selected Items."]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/toggleAllowDuplicates(obj/item/W as obj, mob/user as mob)
		allowDuplicates = !allowDuplicates
		boutput(user, "[allowDuplicates ? "Allowing addition of duplicate items." : "Not allowing addition of duplicate items."]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/selitem(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return
		LIGHT_UP_HOUSING
		var/found_index = signals.Find(input.signal)
		if(found_index)
			current_index = found_index
			tooltip_rebuild = TRUE

		if(announce)
			src.say("Current Selection : [signals[current_index]]")
		return TRUE

	proc/selitemplus(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return
		LIGHT_UP_HOUSING
		if(selitem(input))
			sendCurrent(input)

	proc/remitem(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return
		LIGHT_UP_HOUSING
		if(input.signal in signals)
			signals.Remove(input.signal)
			if(current_index > length(signals))
				current_index = length(signals) ? length(signals) : 1 // Don't let current_index be 0
			tooltip_rebuild = TRUE
			if(announce)
				src.say("Removed : [input.signal]")

	proc/popitem(var/datum/mechanicsMessage/input)
		sendCurrent(input)
		remitem(input)

	proc/remallitem(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return
		LIGHT_UP_HOUSING
		signals.Cut()
		current_index = 1
		tooltip_rebuild = TRUE
		if(announce)
			src.say("Removed all signals.")

	proc/additem(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return
		LIGHT_UP_HOUSING
		if(allowDuplicates)
			signals.Add(input.signal)
			signals[input.signal] = 1
			tooltip_rebuild = TRUE
			if(announce)
				src.say("Added: [input.signal]")

		else
			if(!signals[input.signal])
				signals.Add(input.signal)
				signals[input.signal] = 1
				tooltip_rebuild = TRUE
				if(announce)
					src.say("Added: [input.signal]")
			else if(announce)
				src.say("Duplicate entry - rejected: [input.signal]")

	proc/sendRand(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return
		LIGHT_UP_HOUSING
		var/orig = random
		random = 1
		sendCurrent(input)
		random = orig

	proc/sendCurrent(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return FALSE
		LIGHT_UP_HOUSING
		if(random && length(signals))
			input.signal = pick(signals)
		else if(!current_index || current_index > length(signals) || !length(signals))
			return
		else
			input.signal = signals[current_index]

		SPAWN(0)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)

	proc/next(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !length(signals))
			return FALSE
		LIGHT_UP_HOUSING
		if(++current_index > length(signals))
			current_index = 1
		tooltip_rebuild = TRUE
		if(announce)
			src.say("Current Selection : [signals[current_index]]")
		return TRUE

	proc/nextplus(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		if(next(input))
			sendCurrent(input)

	proc/plusnext(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		sendCurrent(input)
		next(input)

	proc/previous(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !length(signals))
			return FALSE
		LIGHT_UP_HOUSING
		if(--current_index < 1)
			current_index = length(signals)
		tooltip_rebuild = TRUE
		if(announce)
			src.say("Current Selection : [signals[current_index]]")
		return TRUE

	proc/previousplus(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		if(previous(input))
			sendCurrent(input)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_selector"

/obj/item/mechanics/togglecomp
	name = "Toggle Component"
	desc = ""
	icon_state = "comp_toggle"
	var/on = 0
	var/signal_on = "1"
	var/signal_off = "0"

	get_desc()
		. += {"<br><span class='notice'>Currently [on ? "ON":"OFF"].<br>
		Current ON Signal: [signal_on]<br>
		Current OFF Signal: [signal_off]</span>"}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", PROC_REF(activate))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate and send", PROC_REF(activateplus))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"deactivate", PROC_REF(deactivate))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"deactivate and send", PROC_REF(deactivateplus))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", PROC_REF(toggle))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle and send", PROC_REF(toggleplus))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send", PROC_REF(send))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set On-Signal",PROC_REF(setOnSignal))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Off-Signal",PROC_REF(setOffSignal))

	proc/setOnSignal(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Signal:","Signal setting",signal_on) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(inp))
			inp = adminscrub(inp)
			signal_on = inp
			boutput(user, "On-Signal set to [inp]")
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/setOffSignal(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Signal:","Signal setting",signal_off) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(inp))
			inp = adminscrub(inp)
			signal_off = inp
			boutput(user, "Off-Signal set to [inp]")
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/activate(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		on = 1
		tooltip_rebuild = TRUE

	proc/activateplus(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		activate()
		send(input)

	proc/deactivate(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		on = 0
		tooltip_rebuild = TRUE

	proc/deactivateplus(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		deactivate()
		send(input)

	proc/toggle(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		on = !on
		tooltip_rebuild = TRUE

	proc/toggleplus(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		toggle()
		send(input)

	proc/send(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		input.signal = (on ? signal_on : signal_off)
		SPAWN(0)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_toggle[on ? "1":""]"

/obj/item/mechanics/telecomp
	name = "Teleport Component"
	desc = ""
	icon_state = "comp_tele"
	cabinet_banned = TRUE // potentially abusable. b&
	var/teleID = "tele1"
	var/send_only = 0
	var/image/telelight

	get_desc()
		. += {"<br><span class='notice'>Current ID: [teleID].<br>
		Send only Mode: [send_only ? "On":"Off"].</span>"}

	New()
		..()
		START_TRACKING
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", PROC_REF(activate))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send to ID", PROC_REF(activateDirect))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"setID", PROC_REF(setidmsg))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Teleporter ID",PROC_REF(setID))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Send-only Mode",PROC_REF(toggleSendOnly))
		telelight = image('icons/misc/mechanicsExpansion.dmi', icon_state="telelight")
		telelight.plane = PLANE_SELFILLUM
		telelight.alpha = 180
		telelight.appearance_flags |= RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM

	disposing()
		STOP_TRACKING
		return ..()

	proc/setID(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter ID:","ID setting",teleID) as text
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(inp))
			inp = adminscrub(inp)
			teleID = inp
			boutput(user, "ID set to [inp]")
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/toggleSendOnly(obj/item/W as obj, mob/user as mob)
		send_only = !send_only
		if(send_only)
			src.AddOverlays(image('icons/misc/mechanicsExpansion.dmi', icon_state = "comp_teleoverlay"), "sendonly")
		else
			src.ClearSpecificOverlays("sendonly")
		boutput(user, "Send-only Mode now [send_only ? "on":"off"]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/setidmsg(var/datum/mechanicsMessage/input)
		if(level == UNDERFLOOR && input.signal)
			LIGHT_UP_HOUSING
			teleID = input.signal
			tooltip_rebuild = TRUE
			src.say("ID Changed to : [input.signal]")

	proc/activateDirect(var/datum/mechanicsMessage/input)
		// Simply run the activate code but say "please use the signal instead of our id"
		src.activate(input, TRUE)

	proc/activate(var/datum/mechanicsMessage/input, use_signal_id = null)
		var/turf/myTurf = get_turf(src)
		if(level == OVERFLOOR || ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time) || isrestrictedz(myTurf.z))
			return
		LIGHT_UP_HOUSING
		FLICK("[under_floor ? "u":""]comp_tele1", src)
		var/list/destinations = new/list()

		// if we're using the signal id and this matches the signal, use the signal id
		// if we're not using signal id, then find ones matching ours
		var/targetTeleID = use_signal_id ? input.signal : src.teleID

		for_by_tcl(T, /obj/item/mechanics/telecomp)
			// Skip ourselves, disconnected pads, ones not on the ground, in restricted areas, send-only mode, or on the same turf.
			if (T == src || T.level == OVERFLOOR || !isturf(T.loc) || isrestrictedz(T.z) || T.send_only || get_turf(T) == get_turf(src)) continue

			// you used to be able to cross z-levels with mechcomp teles, but no longer
			if (T.z != src.z) continue

			if (T.teleID == targetTeleID)
				destinations.Add(T)

		if(length(destinations))
			var/atom/picked = pick(destinations)
			var/count_sent = 0
			playsound(src.loc, 'sound/mksounds/boost.ogg', 50, 1)
			particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(get_turf(src.loc))).Run()
			var/obj/projectile/proj = initialize_projectile_pixel_spread(src, new/datum/projectile/special/homing/mechcomp_warp, picked)
			var/tries = 5
			while (tries > 0 && (!proj || proj.disposed))
				proj = initialize_projectile_pixel_spread(src, new/datum/projectile/special/homing/mechcomp_warp, picked)
			proj.targets = list(picked)
			proj.event_handler_flags |= IMMUNE_SINGULARITY
			proj.has_atmosphere = TRUE
			for(var/atom/movable/AM in src.loc)
				if(AM == src || AM.invisibility || AM.anchored)
					continue
				continue_if_overlay_or_effect(AM)
				logTheThing(LOG_STATION, AM, "entered [src] at [log_loc(src)] targeting destination [log_loc(picked)]")
				AM.set_loc(proj)
				AM.changeStatus("teleporting", INFINITY)
				if(count_sent++ > 50) break //ratelimit
			input.signal = "to=[targetTeleID]&count=[count_sent]"
			proj.special_data["count_sent"] = count_sent
			proj.launch()
			SPAWN(0)
				// Origin pad gets "to=destination&count=123"
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		else
			// If nowhere to go, output an error
			input.signal = "to=[targetTeleID]&error=no destinations found"
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)


	update_icon()
		icon_state = "[under_floor ? "u":""]comp_tele"
		if(src.level == UNDERFLOOR)
			src.AddOverlays(telelight, "telelight")
		else
			src.ClearSpecificOverlays("telelight")

/obj/item/mechanics/ledcomp
	name = "LED Component"
	desc = ""
	icon_state = "comp_led"
	var/light_level = 2
	var/active = FALSE
	var/selcolor = "#FFFFFF"
	var/datum/light/light
	color = "#AAAAAA"

	get_desc()
		. += "<br>[SPAN_NOTICE("Current Color: [selcolor].")]"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", PROC_REF(toggle))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", PROC_REF(turnon))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"deactivate", PROC_REF(turnoff))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set rgb", PROC_REF(setrgb))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Color",PROC_REF(setColor))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Range",PROC_REF(setRange))

		light = new /datum/light/point
		light.attach(src)

	proc/setColor(obj/item/W as obj, mob/user as mob)
		var/red = input(user,"Red Color(0.0 - 1.0):","Color setting", 1.0) as num
		var/green = input(user,"Green Color(0.0 - 1.0):","Color setting", 1.0) as num
		var/blue = input(user,"Blue Color(0.0 - 1.0):","Color setting", 1.0) as num
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		red = clamp(red, 0.0, 1.0)
		green = clamp(green, 0.0, 1.0)
		blue = clamp(blue, 0.0, 1.0)
		selcolor = rgb(red * 255, green * 255, blue * 255)
		tooltip_rebuild = TRUE
		light.set_color(red, green, blue)
		return TRUE

	proc/setRange(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Range(1 - 7):","Range setting", light_level) as num
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		inp = clamp(round(inp), 1, 7)
		light.set_brightness(inp / 7)
		boutput(user, "Range set to [inp]")
		return TRUE

	pickup()
		active = FALSE
		light.disable()
		src.color = "#AAAAAA"
		return ..()

	proc/setrgb(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		if(length(input.signal) == 7 && copytext(input.signal, 1, 2) == "#")
			if(active)
				color = input.signal
			selcolor = input.signal
			tooltip_rebuild = TRUE
			SPAWN(0) light.set_color(GetRedPart(selcolor) / 255, GetGreenPart(selcolor) / 255, GetBluePart(selcolor) / 255)

	proc/turnon(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		active = TRUE
		light.enable()
		src.color = selcolor

	proc/turnoff(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		active = FALSE
		light.disable()
		src.color = "#AAAAAA"

	proc/toggle(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		if(active)
			turnoff(input)
		else
			turnon(input)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_led"

TYPEINFO(/obj/item/mechanics/miccomp)
	start_listen_effects = list(LISTEN_EFFECT_MICROPHONE_COMPONENT)
	start_listen_inputs = list(LISTEN_INPUT_OUTLOUD)
	start_listen_languages = list(LANGUAGE_ALL)

/obj/item/mechanics/miccomp
	name = "Microphone Component"
	desc = ""
	icon_state = "comp_mic"
	var/add_sender = FALSE

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Show-Source",PROC_REF(toggleSender))

	proc/toggleSender(obj/item/W as obj, mob/user as mob)
		add_sender = !add_sender
		boutput(user, "Show-Source now [add_sender ? "on":"off"]")
		return TRUE

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_mic"

/obj/item/mechanics/radioscanner
	name = "Radio Scanner Component"
	desc = ""
	icon_state = "comp_radioscanner"

	var/frequency = R_FREQ_DEFAULT

	get_desc()
		. += "<br>[SPAN_NOTICE("Current Frequency: [frequency]")]"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set frequency", PROC_REF(setfreq))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Frequency",PROC_REF(setFreqMan))
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT(null, "main", frequency)

	receive_signal(datum/signal/signal)
		if (!signal.data || !istype(signal.data["message"], /datum/say_message))
			return TRUE

		var/datum/say_message/message = signal.data["message"]
		src.hear_radio(message)

	proc/setFreqMan(obj/item/W as obj, mob/user as mob)
		var/inp = input(user, "New frequency ([R_FREQ_MINIMUM] - [R_FREQ_MAXIMUM]):", "Enter new frequency", frequency) as num
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(!isnull(inp))
			set_frequency(inp)
			boutput(user, "Frequency set to [frequency]")
			return TRUE
		return FALSE

	proc/setfreq(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		var/newfreq = text2num_safe(input.signal)
		if (!newfreq)
			return
		set_frequency(newfreq)

	proc/set_frequency(new_frequency)
		if (!radio_controller)
			return
		new_frequency = sanitize_frequency(new_frequency)
		src.say("New frequency: [new_frequency]")
		frequency = new_frequency
		get_radio_connection_by_id(src, "main").update_frequency(frequency)
		tooltip_rebuild = TRUE

	proc/hear_radio(datum/say_message/message)
		if (src.level == OVERFLOOR)
			return

		LIGHT_UP_HOUSING
		SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "name=[message.speaker_to_display]&message=[message.content]")
		animate_flash_color_fill(src, "#00FF00", 2, 2)

	update_icon()
		icon_state = "[under_floor ? "u" : ""]comp_radioscanner"

/obj/item/mechanics/synthcomp
	name = "Sound Synthesizer"
	desc = ""
	icon_state = "comp_synth"
	cooldown_time = 2 SECONDS

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input", PROC_REF(fire))

	proc/fire(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return
		if(ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			return
		LIGHT_UP_HOUSING
		// To prevent feedback loops, messages spoken by sound synthesisers are forbidden from being relayed.
		src.say("[input.signal]", message_params = list("can_relay" = FALSE))

	update_icon()
		icon_state = "comp_synth"

/obj/item/mechanics/trigger/pressureSensor
	name = "Pressure Sensor"
	desc = ""
	icon_state = "comp_pressure"
	var/tmp/limiter = 0
	var/changesig = FALSE
	cabinet_banned = TRUE // non-functional
	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal Changing",PROC_REF(toggleDefault))

	get_desc()
		. += "<br>[SPAN_NOTICE("Replace Signal is [changesig ? "on.":"off."]")]"

	proc/toggleDefault(obj/item/W as obj, mob/user as mob)
		changesig = !changesig
		boutput(user, "Signal changing now [changesig ? "on":"off"]")
		return TRUE

	Crossed(atom/movable/AM as mob|obj)
		..()
		if (level == OVERFLOOR || HAS_ATOM_PROPERTY(AM, PROP_ATOM_FLOATING) || istype(AM, /obj/item/dummy))
			return
		return_if_overlay_or_effect(AM)
		if (limiter && (ticker.round_elapsed_ticks < limiter))
			return
		LIGHT_UP_HOUSING
		limiter = ticker.round_elapsed_ticks + 10
		var/transmission_style = changesig ? COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG : COMSIG_MECHCOMP_TRANSMIT_SIGNAL
		var/output = changesig ? null : "[AM.name]"
		SEND_SIGNAL(src, transmission_style, output)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_pressure"

ADMIN_INTERACT_PROCS(/obj/item/mechanics/trigger/button, proc/press)
/obj/item/mechanics/trigger/button
	name = "Button"
	desc = "A button. Its red hue entices you to press it."
	icon_state = "button_comp_button_unpressed"
	var/icon_up = "button_comp_button_unpressed"
	var/icon_down = "button_comp_button_pressed"
	plane = PLANE_DEFAULT
	density = 0
	var/spooky = FALSE

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)

	attackby(obj/item/W, mob/user)
		if(..(W, user))
			return TRUE
		if(ispulsingtool(W))
			return // Don't press the button with a multitool, it brings up the config menu instead
		return src.Attackhand(user)

	attack_hand(mob/user)
		if(level == UNDERFLOOR)
			press(user)
			return TRUE
		return ..(user)

	proc/press(mob/user)
		set name = "Press"
		FLICK(icon_down, src)
		LIGHT_UP_HOUSING
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG, null)
		logTheThing(LOG_STATION, user || usr, "presses the mechcomp button at [log_loc(src)].")

	Click(location,control,params)
		..()
		if (!spooky)
			return
		var/lpm = params2list(params)
		if(istype(usr, /mob/dead/observer) && !lpm["ctrl"] && !lpm["shift"] && !lpm["alt"])
			src.Attackhand(usr)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == OVERFLOOR && GET_DIST(src, target) == 1)
			if(isturf(target))
				user.drop_item()
				if(isturf(target) && target.density)
					icon_up = "button_comp_switch_unpressed"
					icon_down = "button_comp_switch_pressed"
				else
					icon_up = "button_comp_button_unpressed"
					icon_down = "button_comp_button_pressed"
				icon_state = icon_up
				src.set_loc(target)
		return
	update_icon()
		icon_state = icon_up

	// 👻
	onMaterialChanged()
		. = ..()
		if(isnull(src.material))
			return
		spooky = (src.material.getID() == "soulsteel")

/obj/item/mechanics/trigger/buttonPanel
	name = "Button Panel"
	desc = ""
	icon_state = "comp_buttpanel"
	var/icon_up = "comp_buttpanel"
	var/icon_down = "comp_buttpanel1"
	var/list/active_buttons

	get_desc()
		. += "<br>[SPAN_NOTICE("Buttons:")]"
		for (var/button in src.active_buttons)
			. += "<br>[SPAN_NOTICE("Label: [button], Value: [src.active_buttons[button]]")]"

	New()
		..()
		active_buttons = list()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Add Button",PROC_REF(addButton))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Edit Button",PROC_REF(editButton))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Remove Button",PROC_REF(removeButton))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Button List",PROC_REF(setButtonList))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Remove All Buttons",PROC_REF(removeAllButtons))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT, "Add Button", PROC_REF(signalAddButton))

	proc/addButton(obj/item/W as obj, mob/user as mob)
		if(length(src.active_buttons) >= 10)
			boutput(user, SPAN_ALERT("There's no room to add another button - the panel is full"))
			return FALSE

		var/new_label = input(user, "Button label", "Button Panel") as text
		var/new_signal = input(user, "Button signal", "Button Panel") as text
		new_label = trimtext(new_label)
		new_signal = trimtext(new_signal)
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		if(length(new_label) && length(new_signal))
			new_label = adminscrub(new_label)
			new_signal = adminscrub(new_signal)
			if(new_label in src.active_buttons)
				boutput(user, "There's already a button with that label.")
				return FALSE
			src.active_buttons.Add(new_label)
			src.active_buttons[new_label] = new_signal
			boutput(user, "Added button with label: [new_label] and value: [new_signal]")
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/editButton(obj/item/W as obj, mob/user as mob)
		if(!length(src.active_buttons))
			boutput(user, SPAN_ALERT("[src] has no active buttons - there's nothing to edit!"))
			return FALSE

		var/to_edit = input(user, "Choose button to edit", "Button Panel") in src.active_buttons + "*CANCEL*"
		if(!in_interact_range(src, user) || !isalive(user))
			return FALSE
		if(!to_edit || to_edit == "*CANCEL*")
			return FALSE
		var/new_label = input(user, "Button label", "Button Panel", to_edit) as text
		var/new_signal = input(user, "Button signal", "Button Panel", src.active_buttons[to_edit]) as text
		new_label = trimtext(new_label)
		new_signal = trimtext(new_signal)
		if(!length(new_label) || !length(new_signal))
			return FALSE
		new_label = adminscrub(new_label)
		new_signal = adminscrub(new_signal)
		if(to_edit != new_label)
			if(new_label in src.active_buttons)
				boutput(user, SPAN_ALERT("There's already a button with that label."))
				return FALSE
			var/button_index = src.active_buttons.Find(to_edit)
			src.active_buttons.Insert(button_index, new_label)
			src.active_buttons.Remove(to_edit)
		src.active_buttons[new_label] = new_signal
		boutput(user, "Edited button with new label: [new_label] and new value: [new_signal]")
		tooltip_rebuild = TRUE
		return TRUE


	proc/removeButton(obj/item/W as obj, mob/user as mob)
		if(!length(src.active_buttons))
			boutput(user, SPAN_ALERT("[src] has no active buttons - there's nothing to remove!"))
		else
			var/to_remove = input(user, "Choose button to remove", "Button Panel") in src.active_buttons + "*CANCEL*"
			if(!in_interact_range(src, user) || user.stat)
				return FALSE
			if(!to_remove || to_remove == "*CANCEL*")
				return FALSE
			src.active_buttons.Remove(to_remove)
			boutput(user, "Removed button labeled [to_remove]")
			tooltip_rebuild = TRUE
			return TRUE
		return FALSE

	proc/setButtonList(obj/item/W as obj, mob/user as mob)
		var/button_list_text = ""
		for (var/index in src.active_buttons)
			button_list_text += "[index]=[src.active_buttons[index]];"
		var/inputted_text = adminscrub(tgui_input_text(user,
			"Enter a string to set the entire button list. 10 button limit. Formatting example: Button1=signal1;Button Two=Signal 2;",
			"Button Panel", button_list_text, multiline = TRUE, allowEmpty = TRUE))
		if (!inputted_text)
			return FALSE
		if (!in_interact_range(src, user) || !isalive(user))
			return FALSE

		var/list/work_list = list()
		var/button_count = 0
		for (var/index in splittext(inputted_text, ";"))
			var/first_equal_pos = findtext(index, "=")
			if (!first_equal_pos) continue
			var/new_label = trimtext(copytext(index, 1, first_equal_pos))
			var/new_signal = trimtext(copytext(index, first_equal_pos + 1))
			if (!new_label || !new_signal) continue
			work_list[new_label] = new_signal
			button_count++
			if (button_count >= 10) break
		if (!length(work_list))
			return FALSE
		src.active_buttons = work_list

		boutput(user, SPAN_NOTICE("Re-created [length(work_list)] buttons in [src]."))
		return TRUE

	proc/removeAllButtons(obj/item/W as obj, mob/user as mob)
		if (tgui_alert(user, "Remove ALL buttons?", "Button Panel", list("Yes", "No")) == "Yes")
			if (!in_interact_range(src, user) || !isalive(user))
				return FALSE
			src.active_buttons.Cut()
			boutput(user, SPAN_NOTICE("Removed all of [src]'s buttons."))
			return TRUE
		return FALSE

	proc/signalAddButton(var/datum/mechanicsMessage/input)
		if(length(src.active_buttons) >= 10)
			return FALSE

		var/targetValues = params2list(input.signal)
		var/succesfulAddition = 0
		var/new_label = ""
		var/new_signal = ""

		for(var/indx in targetValues)
			if(length(indx) && length(targetValues[indx]))
				new_label = adminscrub(indx)
				new_signal = adminscrub(targetValues[indx])
				if(new_label in src.active_buttons)
					continue
				src.active_buttons.Add(new_label)
				src.active_buttons[new_label] = new_signal
				succesfulAddition = 1
				tooltip_rebuild = TRUE

		return succesfulAddition



	attack_hand(mob/user)
		if (level == UNDERFLOOR)
			if (length(src.active_buttons))
				var/selected_button = input(user, "Press a button", "Button Panel") in src.active_buttons + "*CANCEL*"
				if (!selected_button || selected_button == "*CANCEL*" || !in_interact_range(src, user))
					return
				LIGHT_UP_HOUSING
				FLICK(icon_down, src)
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, src.active_buttons[selected_button])
				logTheThing(LOG_STATION, user, "presses the mechcomp button [selected_button] at [log_loc(src)].")
				return TRUE
			else
				boutput(user, SPAN_ALERT("[src] has no active buttons - there's nothing to press!"))
		else return ..(user)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == OVERFLOOR && in_interact_range(src, target))
			if(isturf(target))
				user.drop_item()
				src.set_loc(target)

	update_icon()
		icon_state = icon_up

// Updated these things for pixel bullets. Also improved user feedback and added log entries here and there (Convair880).
/obj/item/mechanics/gunholder
	name = "Gun Component"
	desc = ""
	icon_state = "comp_gun"
	density = 0
	can_rotate = 1
	cooldown_time = 1 SECOND
	var/obj/item/gun/Gun = null
	var/list/compatible_guns = list(/obj/item/gun/kinetic, /obj/item/gun/flamethrower, /obj/item/gun/reagent, /obj/item/gun/paintball)
	cabinet_banned = TRUE // non-functional thankfully
	get_desc()
		. += "<br>[SPAN_NOTICE("Current Gun: [Gun ? "[Gun] [Gun.canshoot(null) ? "(ready to fire)" : "(out of [istype(Gun, /obj/item/gun/energy) ? "charge)" : "ammo)"]"]" : "None"]")]"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"fire", PROC_REF(fire))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Remove Gun",PROC_REF(removeGun))

	proc/removeGun(obj/item/W as obj, mob/user as mob)
		if(Gun)
			logTheThing(LOG_STATION, user, "removes [Gun] from [src] at [log_loc(src)].")
			Gun.set_loc(get_turf(src))
			Gun = null
			tooltip_flags &= ~REBUILD_ALWAYS
			return TRUE
		boutput(user, SPAN_ALERT("There is no gun inside this component."))
		return FALSE

	attackby(obj/item/W, mob/user)
		if(..(W, user))
			return TRUE
		var/gun_fits = 0
		for(var/I in src.compatible_guns)
			if(istype(W, I))
				gun_fits = 1
				break

		if(gun_fits)
			if(!Gun)
				boutput(user, "You put the [W] inside the [src].")
				logTheThing(LOG_STATION, user, "adds [W] to [src] at [log_loc(src)].")
				user.drop_item()
				Gun = W
				Gun.set_loc(src)
				tooltip_flags |= REBUILD_ALWAYS
				return TRUE
			else
				boutput(user, "There is already a [Gun] inside the [src]")
		else
			user.show_text("The [W.name] isn't compatible with this component.", "red")
		return FALSE

	proc/getTarget()
		var/atom/trg = get_turf(src)
		for(var/mob/living/L in trg)
			return L
		for(var/i=0, i<7, i++)
			trg = get_step(trg, src.dir)
			for(var/mob/living/L in trg)
				return L
		return get_edge_target_turf(src, src.dir)

	proc/fire(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		if(ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			return
		LIGHT_UP_HOUSING
		if(input && Gun)
			if(Gun.canshoot(null))
				var/atom/target = getTarget()
				if(target)
					Gun.Shoot(get_turf(target), get_turf(src), src, called_target = target)
			else
				src.say("The [Gun.name] has no [istype(Gun, /obj/item/gun/energy) ? "charge" : "ammo"] remaining.")
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
		else
			src.say("No gun installed.")
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)

	update_icon()

		icon_state = "comp_gun"

/obj/item/mechanics/gunholder/recharging
	name = "E-Gun Component"
	desc = ""
	icon_state = "comp_gun2"
	density = 0
	compatible_guns = list(/obj/item/gun/energy)
	var/charging = 0

	get_desc()
		. = ..() // Please don't remove this again, thanks.
		. += charging ? "<br>[SPAN_NOTICE("Component is charging.")]" : null

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"recharge", PROC_REF(recharge))

	process()
		..()
		if(level == OVERFLOOR)
			if(charging)
				charging = 0
				tooltip_rebuild = TRUE

		if(!Gun && charging)
			charging = 0
			tooltip_rebuild = TRUE
			UpdateIcon()

		if(!istype(Gun, /obj/item/gun/energy) || !charging)
			return

		var/obj/item/gun/energy/E = Gun

		// Can't recharge the crossbow. Same as the other recharger.
		if (!(SEND_SIGNAL(E, COMSIG_CELL_CAN_CHARGE) & CELL_CHARGEABLE))
			src.say("This gun cannot be recharged manually.")
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
			charging = 0
			tooltip_rebuild = TRUE
			UpdateIcon()
			return

		else
			if (SEND_SIGNAL(E, COMSIG_CELL_CHARGE, 15) & CELL_FULL) // Same as other recharger.
				src.charging = 0
				tooltip_rebuild = TRUE
				src.UpdateIcon()
		E.UpdateIcon()

	proc/recharge(var/datum/mechanicsMessage/input)
		if(charging || !Gun || level == OVERFLOOR)
			return
		if(!istype(Gun, /obj/item/gun/energy))
			return
		charging = 1
		tooltip_rebuild = TRUE
		UpdateIcon()

	fire(var/datum/mechanicsMessage/input)
		if(charging)
			return
		return ..()

	update_icon()
		icon_state = charging ? "comp_gun2x" : "comp_gun2"
		return

/obj/item/mechanics/instrumentPlayer //Grayshift's musical madness
	name = "Instrument Player"
	desc = ""
	icon_state = "comp_instrument"
	density = 0
	var/obj/item/instrument = null
	var/pitchUnlocked = 0 // varedit this to 1 to permit really goofy pitch values!
	var/delay = 10
	var/sounds = null
	var/volume = 50
	var/anti_stack = TRUE

	get_desc()
		. += "<br>[SPAN_NOTICE("Current Instrument: [instrument ? "[instrument]" : "None"]")]"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"play", PROC_REF(fire))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Remove Instrument",PROC_REF(removeInstrument))

	proc/removeInstrument(obj/item/W as obj, mob/user as mob)
		if(instrument)
			logTheThing(LOG_STATION, user, "removes [instrument] from [src] at [log_loc(src)].")
			instrument.set_loc(get_turf(src))
			instrument = null
			tooltip_rebuild = TRUE
			return TRUE
		else
			boutput(user, SPAN_ALERT("There is no instrument inside this component."))
		return FALSE

	attackby(obj/item/W, mob/user)
		var/allow_polyphony = FALSE
		if (..(W, user))
			return TRUE
		else if (instrument) // Already got one, chief!
			boutput(user, "There is already \a [instrument] inside the [src].")
			return FALSE
		else if (istype(W, /obj/item/instrument)) //BLUH these aren't consolidated under any combined type hello elseif chain // i fix - haine
			var/obj/item/instrument/I = W
			if (!I.automatable)
				boutput(user, SPAN_ALERT("[I] doesn't fit in there!"))
			else
				instrument = I
				sounds = I.sounds_instrument
				volume = I.volume
				delay = I.note_time
				if(I.note_time < 1 SECOND)
					allow_polyphony = TRUE
		else if (istype(W, /obj/item/clothing/head/butt))
			instrument = W
			sounds = 'sound/voice/farts/poo2.ogg'
			volume = 100
			delay = 5
		else if (istype(W, /obj/item/clothing/shoes/clown_shoes))
			instrument = W
			sounds = list('sound/misc/clownstep1.ogg','sound/misc/clownstep2.ogg')
			volume = 50
			delay = 5
		else if (istype(W, /obj/item/artifact/instrument))
			var/obj/item/artifact/instrument/I = W
			instrument = I
			sounds = islist(I.sounds_instrument) ? I.sounds_instrument : list(I.sounds_instrument)
			volume = I.volume
			delay = I.spam_timer
		else // IT DON'T FIT
			user.show_text("\The [W] isn't compatible with this component.", "red")

		if (instrument) // You did it, boss. Now log it because someone will figure out a way to abuse it
			boutput(user, "You put [W] inside [src].")
			logTheThing(LOG_STATION, user, "adds [W] to [src] at [log_loc(src)].")
			user.drop_item()
			instrument.set_loc(src)
			tooltip_rebuild = TRUE
			anti_stack = !allow_polyphony
			return TRUE
		return FALSE

	proc/fire(var/datum/mechanicsMessage/input)
		if (level == OVERFLOOR || GET_COOLDOWN(src, SEND_COOLDOWN_ID) || !instrument || (anti_stack && ON_COOLDOWN((get_turf(src)), "instrument_anti_stacking", delay)))
			return
		LIGHT_UP_HOUSING
		var/signum = text2num_safe(input.signal)
		var/index = round(signum)
		var/volume_channel = VOLUME_CHANNEL_GAME
		if(sounds == 'sound/voice/farts/poo2.ogg')
			volume_channel = VOLUME_CHANNEL_EMOTE
		if (islist(sounds) && length(sounds) > 1 && index > 0 && index <= length(sounds))
			ON_COOLDOWN(src, SEND_COOLDOWN_ID, delay)
			FLICK("comp_instrument1", src)
			playsound(get_turf(src), sounds[index], volume, 0, channel=volume_channel)
		else if (signum &&((signum >= 0.1 && signum <= 2) || (signum <= -0.1 && signum >= -2) || pitchUnlocked))
			var/mod_delay = delay
			if(abs(signum) < 1)
				mod_delay /= abs(signum)
			ON_COOLDOWN(src, SEND_COOLDOWN_ID, mod_delay)
			FLICK("comp_instrument1", src)
			playsound(src, sounds, volume, 0, 0, signum, channel=volume_channel)
		else
			ON_COOLDOWN(src, SEND_COOLDOWN_ID, delay)
			FLICK("comp_instrument1", src)
			playsound(src, sounds, volume, 1, channel=volume_channel)

	update_icon()
		icon_state = "comp_instrument"

/obj/item/mechanics/math
	name = "Arithmetic Component"
	desc = "Do number things! Component list<br/>rng: Generates a random number from A to B<br/>add: Adds A + B<br/>sub: Subtracts A - B<br/>mul: Multiplies A * B<br/>div: Divides A / B<br/>pow: Power of A ^ B<br/>mod: Modulos A % B<br/>eq|neq|gt|lt|gte|lte: Equal/NotEqual/GreaterThan/LessThan/GreaterEqual/LessEqual -- will output 1 if true. Example: A GT B = 1 if A is larger than B"
	icon_state = "comp_arith"
	var/A = 1
	var/B = 1
	var/autoEval = TRUE
	var/floorResults = FALSE

	var/mode = "rng"
	get_desc()
		. = ..() // Please don't remove this again, thanks.
		. += "<br>[SPAN_NOTICE("Current Mode: [mode] | A = [A] | B = [B] | AutoEvaluate: [autoEval ? "ON" : "OFF"] | AutoFloor: [floorResults ? "ON" : "OFF"]")]"
	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set A", PROC_REF(setA))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set B", PROC_REF(setB))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Evaluate", PROC_REF(evaluate))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Mode", PROC_REF(compSetMode))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set A",PROC_REF(setAManually))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set B",PROC_REF(setBManually))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Mode",PROC_REF(setMode))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Auto-Evaluate",PROC_REF(toggleAutoEval))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Auto-Floor",PROC_REF(toggleAutoFloor))

	proc/setAManually(obj/item/W as obj, mob/user as mob)
		var/input = input("Set A to what?", "A", A) as num
		if(!in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE
		A = input
		tooltip_rebuild = TRUE
		return TRUE

	proc/setBManually(obj/item/W as obj, mob/user as mob)
		var/input = input("Set B to what?", "B", B) as num
		if(!in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE
		B = input
		tooltip_rebuild = TRUE
		return TRUE

	proc/setMode(obj/item/W as obj, mob/user as mob)
		mode = input("Set the math mode to what?", "Mode Selector", mode) in list("add","mul","div","sub","mod","pow","rng","eq","neq","gt","lt","gte","lte", "min", "max")
		tooltip_rebuild = TRUE
		return TRUE

	proc/toggleAutoEval(obj/item/W as obj, mob/user as mob)
		src.autoEval = !src.autoEval
		boutput(user, SPAN_NOTICE("Auto-Evaluate mode <b>[src.autoEval ? "ON" : "OFF"]</b>."))
		tooltip_rebuild = TRUE
		return TRUE

	proc/toggleAutoFloor(obj/item/W as obj, mob/user as mob)
		src.floorResults = !src.floorResults
		boutput(user, SPAN_NOTICE("Results will <b>[src.floorResults ? "be" : "not be"] floor()ed</b>."))
		tooltip_rebuild = TRUE
		return TRUE

	proc/setA(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		if (!isnull(text2num_safe(input.signal)))
			A = text2num_safe(input.signal)
			tooltip_rebuild = TRUE
			if (autoEval)
				src.evaluate()
	proc/setB(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		if (!isnull(text2num_safe(input.signal)))
			B = text2num_safe(input.signal)
			tooltip_rebuild = TRUE
			if (autoEval)
				src.evaluate()
	proc/compSetMode(var/datum/mechanicsMessage/input)
		LIGHT_UP_HOUSING
		tooltip_rebuild = TRUE
		if(input.signal in list("add","mul","div","sub","mod","pow","rng","eq","neq","gt","lt","gte","lte","min","max"))
			mode = input.signal
	proc/evaluate()
		switch(mode)
			if("add")
				. = A + B
			if("sub")
				. = A - B
			if("div")
				if (B == 0)
					src.say("Attempted division by zero!")
					return
				. = A / B
			if("mul")
				. = A * B
			if("mod")
				. = A % B
			if("pow")
				. = A ** B
			if("rng")
				. = rand(A, B)
			if("gt")
				. = A > B
			if("lt")
				. = A < B
			if("gte")
				. = A >= B
			if("lte")
				. = A <= B
			if("eq")
				. = A == B
			if("neq")
				. = A != B
			if("min")
				. = min(A, B)
			if("max")
				. = max(A, B)
			else
				return

		// to any curious developers wondering what this "boob operator" is,
		// it's apparently a way to check for NaN (not-a-number) values
		// (NaN is never equal to anything, even itself)
		if (. == .)
			if (src.floorResults && .)
				. = round(.)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[.]")

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_arith"


/obj/item/mechanics/counter
	name = "Counting Component"
	desc = "Count things! Adds (change) to the current value and outputs it when triggered. You can change the amount to change by, the starting value, and reset it as well."
	icon_state = "comp_counter"
	var/startingValue = 0
	var/currentValue = 0
	var/change = 1

	get_desc()
		. = ..() // Please don't remove this again, thanks.
		. += "<br>[SPAN_NOTICE("Current value: [currentValue] | Changes by [(change >= 0 ? "+" : "-")][change] | Starting value: [startingValue]")]"
	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Count", PROC_REF(doCounting))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Immediately Change By", PROC_REF(doImmediateChange))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Reset", PROC_REF(resetCounter))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Value", PROC_REF(setCurrentValue))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Change", PROC_REF(setChange))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Starting Value", PROC_REF(setStartingValue))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Change",PROC_REF(setChangeManually))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Current Value",PROC_REF(setCurrentValueManually))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Starting Value",PROC_REF(setStartingValueManually))

	proc/setStartingValueManually(obj/item/W as obj, mob/user as mob)
		var/input = input("Set starting value to what?", "Starting value", startingValue) as num
		if(!in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE
		startingValue = input
		tooltip_rebuild = TRUE
		return TRUE

	proc/setChangeManually(obj/item/W as obj, mob/user as mob)
		var/input = input("Set Change to what?", "Change", change) as num
		if(!in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE
		change = input
		tooltip_rebuild = TRUE
		return TRUE

	proc/setCurrentValueManually(obj/item/W as obj, mob/user as mob)
		var/input = input("Set current value to what?", "Current value", currentValue) as num
		if(!in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE
		currentValue = input
		tooltip_rebuild = TRUE
		return TRUE


	proc/setStartingValue(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		if (!isnull(text2num_safe(input.signal)))
			startingValue = text2num_safe(input.signal)
			tooltip_rebuild = TRUE
	proc/setChange(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		if (!isnull(text2num_safe(input.signal)))
			change = text2num_safe(input.signal)
			tooltip_rebuild = TRUE
	proc/resetCounter(var/datum/mechanicsMessage/input)
		// reset does not send the value
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		currentValue = startingValue
		tooltip_rebuild = TRUE
		. = currentValue
	proc/setCurrentValue(var/datum/mechanicsMessage/input)
		// setCurrentValue sends the signal with the current value
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		if (!isnull(text2num_safe(input.signal)))
			currentValue = text2num_safe(input.signal)
			tooltip_rebuild = TRUE
			. = currentValue
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[.]")

	proc/doImmediateChange(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		if (!isnull(text2num_safe(input.signal)))
			LIGHT_UP_HOUSING
			currentValue += text2num_safe(input.signal)
			. = currentValue
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[.]")

	proc/doCounting()
		currentValue += change
		. = currentValue
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[.]")

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_counter"


/obj/item/mechanics/clock
	name = "Clock Component"
	desc = "Clock! Tells you the current time. Also usable as a stopwatch."
	icon_state = "comp_clock"
	var/startTime = 0
	var/divisor = 1 SECOND

	get_desc()
		. = ..() // Please don't remove this again, thanks.
		. += "<br>[SPAN_NOTICE("Current stored time: [startTime] | Current time: [round(TIME)] | Time units: [divisor / 10] seconds")]"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Send Time", PROC_REF(sendTime))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Start Stopwatch", PROC_REF(startStopwatch))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Send Stopwatch Time", PROC_REF(sendStopwatchTime))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Send Stopwatch Time And Reset", PROC_REF(sendStopwatchTimeAndReset))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Time Units",PROC_REF(setTimeUnits))

	proc/sendTime()
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		. = round((TIME - round_start_time) / src.divisor)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[.]")

	proc/startStopwatch()
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		startTime = round(TIME)
		. = 0
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[.]")

	proc/sendStopwatchTime()
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		. = round((TIME - src.startTime) / src.divisor)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[.]")

	proc/sendStopwatchTimeAndReset()
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		. = round((TIME - src.startTime) / src.divisor)
		src.startTime = round(TIME)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[.]")

	proc/setTimeUnits(obj/item/W as obj, mob/user as mob)
		var/input = input(user, "Set units", "Clock Component") in list("Deciseconds", "Seconds", "Minutes", "Hours", "*CANCEL*")
		if(!in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE
		switch (input)
			if ("Deciseconds")
				src.divisor = 1
			if ("Seconds")
				src.divisor = 1 SECOND
			if ("Minutes")
				src.divisor = 1 MINUTE
			if ("Hours")
				src.divisor = 1 HOUR
		tooltip_rebuild = TRUE
		return TRUE

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_clock"


/obj/item/mechanics/interval_timer
	name = "Automatic Signaller Component"
	desc = "Outputs a signal on regular, configurable intervals."
	icon_state = "comp_clock"

	// Options for the length of time...
	var/intervalLength = 1 SECOND
	var/minimumInterval = 0.5 SECONDS
	var/maximumInterval = 60 SECONDS

	// how many times we should send it before shutting off (-1 = infinite)
	var/repeatCount = -1
	var/repeatCountLeft = -1

	// if we are active, and if we should be active
	// if these values do not match, reject activate/deactivate toggles until they do
	var/isActive = FALSE
	var/wantActive = FALSE


	get_desc()
		. = ..() // Please don't remove this again, thanks.
		. += "<br>[SPAN_NOTICE("Current interval length: [intervalLength / 10] sec.")]"

	loosen()
		wantActive = FALSE

	// if we're leaving then yeah stop this shit, just in case
	disposing()
		..()
		wantActive = FALSE
		repeatCount = 0

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Start",PROC_REF(setActiveManually))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Stop",PROC_REF(setInactiveManually))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Interval Length",PROC_REF(setIntervalLengthManually))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Repeat Count",PROC_REF(setRepeatCountManually))

		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Start",PROC_REF(setActive))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Stop",PROC_REF(setInactive))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Toggle On/Off",PROC_REF(toggleActive))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Interval Length",PROC_REF(setIntervalLength))
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set Repeat Count",PROC_REF(setRepeatCount))

	// no relation to the flock : )
	proc/startRepeatingTheSignal()
		if(level == OVERFLOOR)
			return

		// Do not start if we have already started
		if (isActive)
			return
		// Do not start if we have no signals to send
		if (repeatCount == 0)
			return

		// if we're here, we want this to start, so start it
		wantActive = TRUE
		repeatCountLeft = repeatCount
		SPAWN(-1)
			isActive = TRUE
			// we set ourselves as active, and then check every time that
			// 1. we exist
			// 2. we are still active (should always be the case)
			// 3. we still *want* to be active
			// 4. we have some signals left to send (not > 0, because -1 is infinite)
			while (src && isActive && wantActive && repeatCountLeft != 0)
				// decrement repeat counter
				if (repeatCountLeft > 0) repeatCountLeft--

				LIGHT_UP_HOUSING
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG, null)
				animate_flash_color_fill(src,"#00FF00",1, 2)
				sleep(intervalLength)

			// if/when we break out of the loop, we're done forever
			// no more active
			isActive = FALSE


	// Very basic calls because most of the logic is shared
	// and this does not output signals on start/stop
	proc/setActive()
		startRepeatingTheSignal()

	proc/setInactive()
		wantActive = FALSE

	proc/toggleActive()
		if (src.wantActive)
			wantActive = FALSE
		else
			startRepeatingTheSignal()

	proc/setActiveManually(obj/item/W as obj, mob/user as mob)
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		startRepeatingTheSignal()
		return TRUE

	proc/setInactiveManually(obj/item/W as obj, mob/user as mob)
		if(!in_interact_range(src, user) || user.stat)
			return FALSE
		wantActive = FALSE
		return TRUE

	proc/setIntervalLengthManually(obj/item/W as obj, mob/user as mob)
		var/input = input(user, "Time between signals? (in deciseconds (0.1s))", "Interval Component", intervalLength) as num | null
		if(!in_interact_range(src, user) || user.stat || isnull(input) || !isnum_safe(input))
			return FALSE

		if (input > maximumInterval || input < minimumInterval)
			return FALSE
		intervalLength = input

		tooltip_rebuild = TRUE
		return TRUE

	proc/setRepeatCountManually(obj/item/W as obj, mob/user as mob)
		var/input = input(user, "Number of signals to send? (-1 for infinite)", "Interval Component", repeatCount) as num | null
		if(!in_interact_range(src, user) || user.stat || isnull(input) || !isnum_safe(input))
			return FALSE

		if (input == 0)
			return FALSE
		repeatCount = input
		return TRUE

	proc/setIntervalLength(var/datum/mechanicsMessage/input)
		var/input_num = text2num_safe(input.signal)
		if (!isnull(input_num))
			if (input_num > maximumInterval || input_num < minimumInterval)
				return
			intervalLength = input_num
			tooltip_rebuild = TRUE

	proc/setRepeatCount(var/datum/mechanicsMessage/input)
		var/input_num = text2num_safe(input.signal)
		if (!isnull(input_num))
			// I don't care about checking for values below -1 here,
			// because anything below 0 is effectively infinite
			repeatCount = input_num

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_clock"


/obj/item/mechanics/association
	name = "Association Component"
	desc = ""
	icon_state = "comp_ass"
	var/list/map
	var/mode = 0 // 0=Mutable, 1=Immutable, 2=List

	New()
		..()
		map = list()
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "add association(s)", PROC_REF(addItems))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "remove association", PROC_REF(removeItem))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "send value", PROC_REF(sendValue))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "send associations as signal", PROC_REF(sendMapAsSignal))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set mode", PROC_REF(setMode))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "add association", PROC_REF(addItemManual))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "remove association", PROC_REF(removeItemManual))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "view all associations", PROC_REF(getMapAsString))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "clear all associations", PROC_REF(clear))

	get_desc()
		. += {"<br><span class='notice'>Mode: [mode == 0 ? "Mutable" : mode == 1 ? "Immutable" : "List"]<br>
		[getDescAssociations()]</span>"}

	proc/getDescAssociations()
		var/list/mapLines = new/list()
		var/endloop = min(10, map.len)
		for (var/i = 1 to endloop)
			if (!isnull(map[i]))
				var/key = map[i]
				var/val = map[key]
				mapLines.Add("[key]: [val]")
		if (length(map) > 10)
			mapLines.Add("Use a multitool to view all associations")
		return length(mapLines) ? mapLines.Join("<br>") : ""

	proc/getMapAsString(obj/item/W as obj, mob/user as mob)
		var/list/mapLines = new/list()
		for (var/key in map)
			mapLines.Add("[key]: [map[key]]")
		boutput(user, "[length(mapLines) ? mapLines.Join("<br>") : ""]")

	proc/addItems(var/datum/mechanicsMessage/input)
		if (level == OVERFLOOR || !input)
			return
		LIGHT_UP_HOUSING
		var/list/inputList = params2list(input.signal)
		var/added = 0
		for (var/inputKey in inputList)
			if (isnull(inputList[inputKey]) || inputList[inputKey] == "" || (islist(inputList[inputKey]) && inputList[inputKey][1] == "")) continue
			var/list/inputValue = islist(inputList[inputKey]) ? inputList[inputKey] : list(inputList[inputKey])
			if (mode == 0) // Mutable
				if (isnull(map[inputKey])) map.Add(inputKey)
				map[inputKey] = inputValue[1]
				added = 1
			else if (mode == 1) // Immutable
				if (!isnull(map[inputKey])) continue
				map.Add(inputKey)
				map[inputKey] = inputValue[1]
				added = 1
			else // List
				if (isnull(map[inputKey]))
					map.Add(inputKey)
					map[inputKey] = inputValue.Join(",")
				else
					map[inputKey] = "[map[inputKey]],[inputValue.Join(",")]"
				added = 1

		if (added)
			animate_flash_color_fill(src,"#00FF00",2, 2)
			tooltip_rebuild = TRUE

	proc/removeItem(var/datum/mechanicsMessage/input)
		if (level == OVERFLOOR || !input)
			return
		LIGHT_UP_HOUSING
		if (isnull(map[input.signal]))
			return
		map.Remove(input.signal)
		animate_flash_color_fill(src,"#00FF00",2, 2)
		tooltip_rebuild = TRUE

	proc/sendValue(var/datum/mechanicsMessage/input)
		if (level == OVERFLOOR || !input)
			return
		LIGHT_UP_HOUSING
		if (isnull(map[input.signal]))
			return
		input.signal = map[input.signal]
		SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_MSG, input)
		animate_flash_color_fill(src,"#00FF00",2, 2)

	proc/sendMapAsSignal(var/datum/mechanicsMessage/input)
		if (level == OVERFLOOR || !input)
			return
		LIGHT_UP_HOUSING
		input.signal = list2params(src.map)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_MSG, input)
		animate_flash_color_fill(src,"#00FF00",2, 2)

	proc/setMode(obj/item/W as obj, mob/user as mob)
		var/input = input(user, "Set mode", "Association Component") in list("Mutable", "Immutable", "List", "*CANCEL*")
		if (!in_interact_range(src, user) || user.stat)
			return FALSE
		if (!input || input == "*CANCEL*")
			return FALSE
		mode = input == "Mutable" ? 0 : input == "Immutable" ? 1 : 2
		boutput(user, "Mode set to [input]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/addItemManual(obj/item/W as obj, mob/user as mob)
		var/inputKey = input(user, "Add key", "Association Component") as text
		if (isnull(inputKey))
			return FALSE
		var/inputValue = input(user, "Add value", "Association Component") as text
		if (isnull(inputKey))
			return FALSE
		if (!in_interact_range(src, user) || user.stat)
			return FALSE
		if (mode == 0) // Mutable
			if (isnull(map[inputKey])) map.Add(inputKey)
			map[inputKey] = inputValue
		else if (mode == 1) // Immutable
			if (!isnull(map[inputKey]))
				boutput(user, "IMMUTABLE MODE ERROR: An association already exists for that key")
				return FALSE
			map.Add(inputKey)
			map[inputKey] = inputValue
		else // List
			if (isnull(map[inputKey]))
				map.Add(inputKey)
				map[inputKey] = inputValue
			else
				map[inputKey] = "[map[inputKey]],[inputValue]"
		boutput(user, "Set value of [inputKey] to [map[inputKey]]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/removeItemManual(obj/item/W as obj, mob/user as mob)
		if (!length(map))
			boutput(user, SPAN_ALERT("[src] has no associations - there's nothing to remove!"))
			return FALSE
		var/input = input(user, "Remove association", "Association Component") in map + "*CANCEL*"
		if (!in_interact_range(src, user) || user.stat)
			return FALSE
		if (!input || input == "*CANCEL*")
			return FALSE
		var/removedValue = map[input]
		map.Remove(input)
		boutput(user, "Removed key [input] and value [removedValue]")
		tooltip_rebuild = TRUE
		return TRUE

	proc/clear(obj/item/W as obj, mob/user as mob)
		map.Cut()
		boutput(user, "Associations map cleared")
		return TRUE

	update_icon()
		icon_state = "[under_floor ? "u" : ""]comp_ass"

/obj/mecharrow
	name = ""
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "connectionArrow"


/obj/item/mechanics/screen
	name = "Letter Display Component"
	desc = ""
	icon_state = "comp_screen"
	cabinet_banned = TRUE

	var/letter_index = 1
	var/display_letter = null

	get_desc()
		. = ..()
		. += "<br><span class='notice'>Letter Index: [src.letter_index]"
		if (src.level == OVERFLOOR || src.display_letter != null)
			. += " | Currently Displaying: '[src.display_letter]'"
		. += "</span>"

	secure()
		src.display(" ")

	loosen()
		src.display_letter = null
		src.icon_state = "comp_screen"
	New()
		..()
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set letter index", PROC_REF(setLetterIndex))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set color", PROC_REF(setColorManually))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "input", PROC_REF(fire))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set color", PROC_REF(setColor))

	proc/setLetterIndex(obj/item/W as obj, mob/user as mob)
		var/input = input("Which letter from the input string to take? (1-indexed; negative numbers start from the end)", "Letter Index", letter_index) as num
		if (!in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE
		if (letter_index == 0)
			return FALSE
		letter_index = input
		tooltip_rebuild = TRUE
		. = TRUE

	proc/setColorManually(obj/item/W as obj, mob/user as mob)
		var/input = input(user, "Which color?", "Letter Display Component") in list("Blue", "Green", "Red", "Gray", "*CANCEL*")
		if (!in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE
		if (letter_index == 0)
			return FALSE
		switch(input)
			if ("Blue")
				src.actualSetColor("blue")
			if ("Green")
				src.actualSetColor("green")
			if ("Red")
				src.actualSetColor("red")
			if ("Gray")
				src.actualSetColor("gray")

		. = TRUE

	proc/actualSetColor(var/color_name)
		// letter display components are blue and light blue with a gray border
		// these color matrixes switch blue for the target color,
		// or in the case of grayscale, turn everything off and use blue alone
		switch(color_name)
			if ("blue")
				src.color = null
			if ("green")
				src.color = list(list(1, 0, 0, 0), list(0, 0, 1, 0), list(0, 1, 0, 0))
			if ("red")
				src.color = list(list(0, 0, 1, 0), list(0, 1, 0, 0), list(1, 0, 0, 0))
			if ("gray")
				src.color = list(list(0, 0, 0, 0), list(0, 0, 0, 0), list(1, 1, 1, 0))




	proc/setColor(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return
		var/signal = input.signal
		src.actualSetColor(signal)


	proc/fire(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return
		var/signal = input.signal
		if (length(signal) < abs(src.letter_index))
			src.display(" ") // If the string is shorter than we expect, fill excess screens with spaces
			return
		var/letter = copytext(signal, src.letter_index, src.letter_index + 1)
		src.display(letter)

	proc/display(var/letter as text)
		letter = uppertext(letter)
		switch(letter)
			if (" ") src.setDisplayState(" ", "comp_screen_blank")
			if ("!") src.setDisplayState("!", "comp_screen_exclamation_mark")
			if ("-") src.setDisplayState("!", "comp_screen_dash")
			if (".") src.setDisplayState("!", "comp_screen_period")
			if ("*") src.setDisplayState("*", "comp_screen_asterisk")
			if ("%") src.setDisplayState("*", "comp_screen_percent")
			else
				var/ascii = text2ascii(letter)
				if((ascii >= text2ascii("A") && ascii <= text2ascii("Z")) || (ascii >= text2ascii("0") && ascii <= text2ascii("9")))
					src.setDisplayState(letter, "comp_screen_[letter]")
				else
					src.setDisplayState("?", "comp_screen_question_mark") // Any unknown characters should display as ? instead.

	proc/setDisplayState(var/new_letter as text, var/new_icon_state as text)
		src.display_letter = new_letter
		src.icon_state = new_icon_state


/obj/item/mechanics/message_sign
	name = "message sign component"
	desc = "Can display up to three lines of text."
	icon='icons/obj/large/96x32.dmi'
	icon_state = "mechcomp_ledsign"
	cabinet_banned = TRUE
	two_handed = 1     // it's big
	w_class = W_CLASS_BULKY // too big to fit in a bag
	pixel_w = -32
	var/display_text = null
	var/display_color = "#dd9922"
	var/display_vertical = "vm"
	var/display_horizontal = "c"
	var/display_font = "pixel"
	var/display_font_size = 6

	maptext_width = 92
	maptext_x = 2

	get_desc()
		. = ..()
		. += "<br>[SPAN_NOTICE("Current text: [src.display_text] | Color: [display_color]")]"

	secure()
		src.display_text = ""
		src.maptext = ""

	loosen()
		src.display_text = ""
		src.maptext = ""

	New()
		..()
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set text", PROC_REF(setTextManually))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set color", PROC_REF(setColorManually))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set alignment", PROC_REF(setAlignmentManually))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set font", PROC_REF(setFontManually))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set text", PROC_REF(setText))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "set color", PROC_REF(setColor))

	proc/setColor(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return
		var/signal = input.signal
		src.actualSetColor(signal)
	proc/setColorManually(obj/item/W as obj, mob/user as mob)
		var/input = input(user, "Text color", "Color", src.display_color) as color | null
		if (!input || !in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE

		src.actualSetColor(input)
		tooltip_rebuild = TRUE
		. = TRUE
	proc/actualSetColor(var/color_input)
		if(level == OVERFLOOR)
			return
		LIGHT_UP_HOUSING
		if(length(color_input) == 7 && copytext(color_input, 1, 2) == "#")
			display_color = color_input
			tooltip_rebuild = TRUE
			src.display()

	proc/sanitize_text(text)
		. = replacetext(html_encode(text), "|n", "<br>")
		var/static/regex/bullshit_byond_parser_url_regex = new(@"(https?|byond)://", "ig")
		// byond automatically promotes URL-like text in maptext to links, which is an awful idea
		// it also parses protocols in a nonsensical way - for example ahttp://foo.bar is the letter a followed by a http:// protocol link
		// hence the special regex. I don't know if any other protocols are included in this by byond but ftp is not so I'm giving up here
		var/oldtext = null
		while(!cmptext(oldtext, .)) //repeat until all protocols are killed.
			oldtext = .
			. = replacetext(., bullshit_byond_parser_url_regex, "")

	proc/setText(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR || !input)
			return
		var/signal = input.signal
		if (length(signal) > MAX_MESSAGE_LEN)
			return
		src.display_text = src.sanitize_text(input.signal)
		src.display()

	proc/setTextManually(obj/item/W as obj, mob/user as mob)
		if (isghostdrone(user))
			boutput(user, "You're a ghostdrone, so you probably shouldn't be doing this.")
			return FALSE
		var/input = input(user, "Message Text", "Text", replacetext(html_decode(src.display_text), "<br>", "|n")) as text | null
		if (!input || !in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE

		src.display_text = src.sanitize_text(input)
		logTheThing(LOG_STATION, src, "Message sign component text was manually set to [src.display_text] by [key_name(user)] at [log_loc(src)]")
		src.display()
		tooltip_rebuild = TRUE
		. = TRUE


	proc/setAlignmentManually(obj/item/W as obj, mob/user as mob)
		var/vertical = input(user, "Vertical Alignment?", "Message Sign Component", "middle") in list("top", "middle", "bottom") | null
		// these ones do not bail if you pick "no" since it will just not do anything
		if (!in_interact_range(src, user) || user.stat)
			return FALSE
		var/horizontal = input(user, "Horizontal Alignment?", "Message Sign Component", "center") in list("left", "center", "right") | null
		if (!in_interact_range(src, user) || user.stat)
			return FALSE

		switch (vertical)
			if ("top")
				display_vertical = "vt"
			if ("middle")
				display_vertical = "vm"
			if ("bottom")
				display_vertical = "vb"

		switch (horizontal)
			if ("left")
				display_horizontal = "l"
			if ("center")
				display_horizontal = "c"
			if ("right")
				display_horizontal = "r"

		src.display()

	proc/setFontManually(obj/item/W as obj, mob/user as mob)
		var/font = input(user, "Which font?", "Message Sign Component", display_font) in list("pixel", "vga", "xfont") | null
		if (!in_interact_range(src, user) || user.stat || isnull(font))
			return FALSE

		display_font = font

		if (font == "pixel")
			var/size = input(user, "What font size? (5-8)", "Message Sign Component", (display_font_size ? display_font_size : 6)) as num | null
			display_font_size = 6
			var/size_safe = text2num_safe(size)
			if (!in_interact_range(src, user) || user.stat || isnull(font))
				src.display()
				return FALSE
			if (!isnull(size_safe) && size_safe >= 5 && size_safe <= 8)
				display_font_size = size_safe
		else
			display_font_size = null

		src.display()


	proc/display()
		src.maptext = "<span class='[display_horizontal] [display_vertical] [display_font]' style='[display_font_size ? "font-size: [display_font_size]px; " : ""]color: [display_color];'>[display_text]</span>"




/// allows cabinets to move around
/obj/item/mechanics/movement
	name = "Movement Component"
	desc = "Allows a cabinet to move around."
	icon_state = "comp_move"
	cooldown_time = 1 SECOND
	cabinet_only = TRUE
	one_per_tile = TRUE
	var/move_lag = 10

	New()
		..()
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "walk", PROC_REF(do_walk))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "step", PROC_REF(do_step))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "Set walk delay", PROC_REF(set_speed))

	secure()
		if (istype(src.stored?.linked_item, /obj/item/storage/mechanics/housing_handheld))
			src.stored.linked_item.AddComponent(/datum/component/legs/four)
		else
			src.loc.AddComponent(/datum/component/legs/six)

	loosen()
		var/datum/component/C
		if (istype(src.stored?.linked_item, /obj/item/storage/mechanics/housing_handheld))
			C = src.stored.linked_item.GetComponent(/datum/component/legs/four)
		else
			C = src.loc.GetComponent(/datum/component/legs/six)
		if (C)
			C.RemoveComponent()
		src.stop_moving()

	cabinet_state_change(var/obj/item/storage/mechanics/container)
		if (container.anchored)
			src.stop_moving()

	proc/do_walk(var/datum/mechanicsMessage/input)
		if (ON_COOLDOWN(src, "movement_delay", move_lag))
			return
		var/direction = text2num_safe(input.signal)
		if (!isnum_safe(direction))
			direction = dirname_to_dir(input.signal)
		if (!(direction in alldirs) && direction != 0)
			return
		var/obj/item/storage/S = src.stored?.linked_item
		if (!walk_check(S))
			return
		set_glide_size(S)
		walk(S, direction, move_lag, (32 / move_lag) * world.tick_lag)
		set_glide_size(S)
		if (direction == 0)
			UnregisterSignal(S, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC))
			REMOVE_ATOM_PROPERTY(S, PROP_ATOM_FLOATING, "mech-component")
		else
			RegisterSignals(S, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC), PROC_REF(movement_stuff), TRUE)
			APPLY_ATOM_PROPERTY(S, PROP_ATOM_FLOATING, "mech-component")

	proc/do_step(var/datum/mechanicsMessage/input)
		if (ON_COOLDOWN(src, "movement_delay", move_lag))
			return
		var/direction = text2num_safe(input.signal)
		if (!direction)
			direction = dirname_to_dir(input.signal)
		if (!(direction in alldirs)) // without this someone could pass 16 or 32 to jump across z-levels, welcome to the forbidden UP and DOWN dirs
			return
		var/obj/item/storage/S = src.stored?.linked_item
		if (!walk_check(S))
			return
		set_glide_size(S)
		step(S, direction, (32 / move_lag) * world.tick_lag)
		UnregisterSignal(S, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC))

	/// set our glide size in case it was changed
	/// check if we are in a container or space and stop in that case
	proc/movement_stuff()
		var/obj/item/storage/S = src.stored?.linked_item
		if (!walk_check(S))
			stop_moving()
			return
		set_glide_size(S)

	proc/set_glide_size(var/obj/item/storage/S)
		S.glide_size = (32 / move_lag) * world.tick_lag
		S.animate_movement = FORWARD_STEPS

	/// checks if we may move right now
	proc/walk_check(var/obj/item/storage/S)
		if (!istype(S))
			return FALSE
		if (S.anchored)
			return FALSE
		if (!isturf(S.loc) || (istype(S.loc, /turf/space) && !istype(S.loc, /turf/space/fluid)))
			return FALSE
		return TRUE

	proc/stop_moving()
		var/obj/item/storage/S = src.stored?.linked_item
		if (!istype(S))
			return
		walk(S, 0)
		UnregisterSignal(S, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_SET_LOC))
		REMOVE_ATOM_PROPERTY(S, PROP_ATOM_FLOATING, "mech-component")

	proc/set_speed(obj/item/W as obj, mob/user as mob)
		// as fast as humans, but they can't sprint
		var/inp = input(user,"Please enter movement delay, lower is faster ([BASE_SPEED] - 20)", "Movement delay", src.move_lag) as num
		if(!in_interact_range(src, user) || !isalive(user))
			return FALSE
		inp = clamp(inp, BASE_SPEED, 20)
		move_lag = inp
		boutput(user, "You set the movement delay set to [inp].")
		return TRUE

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_move"




/obj/item/mechanics/screen_canvas
	name = "Pixel Display Component"
	desc = "Totally not a canvas hastily stuffed into a screen, somehow."

	icon_state = "comp_screen"

	// largely cribbed from /obj/item/canvas, but with the interactive parts removed.

	var/icon/base = null
	var/icon/art = null
	var/canvas_width = 26
	var/canvas_height = 26
	var/bottom = 4
	var/left = 4

	// are we updating the icon currently?
	// basically: don't icon = art more than once per tick-ish
	// see update logic below for more details
	var/tmp/updating = FALSE

	pixel_point = TRUE

	New()
		..()

		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "draw pixel", PROC_REF(drawPixel))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "reset canvas", PROC_REF(resetCanvas))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "reset canvas", PROC_REF(resetCanvas))

		init_canvas()

		// left = round((bound_width - canvas_width) / 2)
		// bottom = round((bound_height - canvas_height) / 2)

	proc/init_canvas()
		// these are subtly different from the canvas ones because they are not canvases.
		base = icon(src.icon, icon_state = "canvas_[canvas_width]x[canvas_height]")
		art = icon(src.icon, icon_state = "canvas_[canvas_width]x[canvas_height]_black")

		underlays += base
		icon = art

	proc/resetCanvas()
		var/new_color = "#000000"
		art.DrawBox(new_color, left, bottom, left + canvas_width, bottom + canvas_height)
		icon = art
		logTheThing(LOG_STATION, null, "[src] reset to color: [log_loc(src)]: canvas{\ref[src], -1, -1, [new_color]}")

	proc/drawPixel(var/datum/mechanicsMessage/input)
		if(level == OVERFLOOR)
			return
		var/list/params = params2list(input.signal)
		var/dot_x = text2num(params["x"])
		var/dot_y = text2num(params["y"])
		var/dot_x2 = text2num(params["x2"])
		var/dot_y2 = text2num(params["y2"])
		var/dot_color = params["color"]
		if (!isnull(dot_x) && !isnull(dot_y) && !isnull(dot_color))
			// note that we don't care if dot_x2 and dot_y2 are null.
			// technically we don't care about anything but y/k whatever
			drawPixelActual(dot_x, dot_y, dot_x2, dot_y2, dot_color)


	proc/drawPixelActual(dot_x, dot_y, dot_x2, dot_y2, dot_color)
		var/x = dot_x
		var/y = dot_y
		// these are updated later if dot_x2 and dot_y2 are valid
		var/x2 = x
		var/y2 = y

		if (x < 0 || y < 0 || x >= canvas_width || y > canvas_height)
			// you cannot embezzle pixels off the bezel, sorry.
			// you thought this would be the same comment as canvas.dm?
			// wrong. and so is drawing off the canvas.
			return

		// in this case, we check if they *are* in range
		// rather than checking if they *are not*
		// because if it's out of bounds we just don't copy it
		if (dot_x2 && dot_x2 >= 0 && dot_x2 < canvas_width)
			x2 = dot_x2
		if (dot_y2 && dot_y2 >= 0 && dot_y2 < canvas_height)
			y2 = dot_y2

		// color should be an actual color
		// byond: iscolor() pls
		if (length(dot_color) != 7 || copytext(dot_color, 1, 2) != "#")
			return

		// unlike the canvas, which operates on absolute-to-icon coordinates,
		// this one operates on realtive ones (e.g. 0,0 is the bottom of the drawable area,
		// not the icon itself)
		x += left
		y += bottom
		x2 += left
		y2 += bottom

		art.DrawBox(dot_color, x, y, x2, y2)
		if (!src.updating)
			// this should hopefully limit the icon sending code to just once per tick,
			// rather than whenever you send a signal, which can be multiple times/tick
			// the idea is to update it immediately once, then say "no more for now"
			// the next tick it updates the icon and turns off the flag again
			// this might allow for doubling (e.g. twice per 1/10) but that's
			// better than like, 25 times lol

			// immediately stop any other running one from doing this
			src.updating = TRUE
			// you get one for free now, for immediate updates
			src.icon = src.art

			SPAWN(1)
				// then a bit later, update again and unset the flag
				src.icon = src.art
				src.updating = FALSE

		// tracks how many things someone's drawn on it.
		// so you can tell if scrimblo made a cool scene and then dogshit2000 put obscenities on top or whatever.
		logTheThing(LOG_STATION, null, "draws on [src]: [log_loc(src)]: canvas{\ref[src], [x], [y], [dot_color], [x2], [y2]}")

/obj/item/mechanics/textmanip
	name = "Text manipulation component"
	desc = "Allows for controlling text you send in."
	icon_state = "comp_text"

	/// do we enforce lowercase(false)/uppercase(true) or leave it as is
	var/uppertext_mode = null
	/// do we limit the length of the output
	var/text_limit = null
	/// do we trim whitespace from the ends of the output
	var/trim_text = FALSE
	/// do we capitalize the first letter of the output
	var/cap_first = FALSE

	New()
		..()
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "Toggle UPPERCASE/lowercase",PROC_REF(setCapsMode))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "Set Length Limit on Text",PROC_REF(setTextLimit))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "Toggle Whitespace Trimming",PROC_REF(setTrimming))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "Toggle Capitalizing First Letter",PROC_REF(setFirstCap))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "Input", PROC_REF(parseText))

	get_desc()
		var/upp = "Disabled"
		if (src.uppertext_mode != null)
			upp = src.uppertext_mode ? "UPPERCASE" : "lowercase"
		. += "<br>[SPAN_NOTICE("Uppercase/Lowercase output: [upp]")]"

		. += "<br>[SPAN_NOTICE("Text length limit: [src.text_limit ? "[src.text_limit] characters" : "Disabled"]")]"
		. += "<br>[SPAN_NOTICE("Trim whitespace: [src.trim_text ? "Enabled" : "Disabled"]")]"
		. += "<br>[SPAN_NOTICE("First letter capitalized: [src.cap_first ? "Enabled" : "Disabled"]")]"

	proc/setCapsMode(var/datum/mechanicsMessage/input, mob/user)
		if (src.uppertext_mode == null)
			boutput(user, "Now forcing output text to be lowercase")
			src.uppertext_mode = FALSE
		else if (src.uppertext_mode == FALSE)
			boutput(user, "Now forcing output text to be uppercase")
			src.uppertext_mode = TRUE
		else if (src.uppertext_mode == TRUE)
			boutput(user, "Uppercase/lowercase output disabled")
			src.uppertext_mode = null

	proc/setTextLimit(var/datum/mechanicsMessage/input, mob/user)
		var/num = input(user, "Number of Characters allowed in text (leave blank to disable)", "Text length limit") as num|null
		if (num != null)
			src.text_limit = num
			boutput(user, "Now limiting text to [num] characters")
		else
			src.text_limit = null
			boutput(user, "Text limit removed")

	proc/setTrimming(var/datum/mechanicsMessage/input, mob/user)
		src.trim_text = !src.trim_text
		if (src.trim_text)
			boutput(user, "Now trimming whitespace from the ends of output text")
		else
			boutput(user, "Text whitespace trimming is now disabled")

	proc/setFirstCap(var/datum/mechanicsMessage/input, mob/user)
		src.cap_first = !src.cap_first
		if (src.cap_first)
			boutput(user, "Now Capitalizing first letter of text")
		else
			boutput(user, "First Letter Capitalization is now disabled")

	proc/parseText(var/datum/mechanicsMessage/input)
		var/text = input.signal

		if (src.cap_first)
			text = uppertext(copytext_char(text,1,2)) + copytext_char(text,2)
		if (src.uppertext_mode != null)
			text = src.uppertext_mode ? uppertext(text) : lowertext(text)
		if (src.text_limit)
			text = copytext_char(text,1,src.text_limit+1)
		if (src.trim_text)
			text = trimtext(text)

		if (!length(text) || src.text_limit == 0)
			return

		input.signal = text
		SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_MSG, input)


/obj/item/mechanics/bomb
	// this thing is a buggy piece of shit and is A D M I N - O N L Y
	// if you intend to make this player-available consider:
	// making it less bad
	name = "bomb"
	desc = "You may want to find somewhere else to be."
	icon_state = "bomb_disarmed"
	cabinet_banned = TRUE
	dont_disconnect_on_change = TRUE

	var/arm_code = null
	var/is_armed = FALSE
	var/boom_size = 50
	var/blowing_the_fuck_up = FALSE
	var/det_time = 2 SECONDS

	small
		name = "small bomb"
		desc = "A small bomb the size of a large bomb, you probably don't want to be on top of this when it goes."
		boom_size = 10

	big
		name = "strong bomb"
		desc = "All the fury of a tank-transfer-valve bomb in one easy package. You should probably run away."
		boom_size = 200

	bigger
		name = "very strong bomb"
		desc = "Bigger than a nerd's tank-transfer-valve bomb but not as big as the turbonerd's canister bomb, this occupies an unhappy middle. You should probably stop staring at it and run away."
		boom_size = 1000

	biggest
		name = "incredibly strong bomb"
		desc = "This looks like it contains the fury of an actual canister bomb. If this goes off there may not be a lot left to clean up."
		boom_size = 7500

	station_deleting
		name = "station deleting bomb"
		desc = "There is no running from this."
		boom_size = 1000000

	New()
		..()
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "arm", PROC_REF(arm))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "disarm", PROC_REF(disarm))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "detonate", PROC_REF(detonate))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "Set Code",PROC_REF(setSecretCode))

	proc/arm(var/datum/mechanicsMessage/input)
		if (blowing_the_fuck_up || is_armed || (arm_code && input.signal != arm_code))
			return

		src.is_armed = TRUE
		src.icon_state = "bomb_armed"
		src.visible_message(SPAN_SAY("[SPAN_NAME("[src]")] clunks ominously."))

	proc/disarm(var/datum/mechanicsMessage/input)
		if (blowing_the_fuck_up || !is_armed || (arm_code && input.signal != arm_code))
			return

		src.is_armed = FALSE
		src.icon_state = "bomb_disarmed"
		src.visible_message(SPAN_SAY("[SPAN_NAME("[src]")] clicks quietly."))

	proc/detonate(var/datum/mechanicsMessage/input)
		if (blowing_the_fuck_up || !is_armed || (arm_code && input.signal != arm_code))
			return

		blowing_the_fuck_up = TRUE
		src.visible_message(SPAN_SAY("[SPAN_NAME("[src]")] beeps!"))
		message_admins("A mechcomp bomb (<b>[src]</b>), power [boom_size], is detonating at [log_loc(src)].")
		logTheThing(LOG_BOMBING, null, "A mechcomp bomb (<b>[src]</b>), power [boom_size], is detonating at [log_loc(src)].")

		SPAWN(det_time)
			explosion_new(src, src.loc, boom_size)
			qdel(src)


	proc/setSecretCode(obj/item/W as obj, mob/user as mob)
		if (src.arm_code)
			var/input = input(user, "Current secret code?", "Secret Arming Code", null) as text | null
			if (isnull(input) || input != src.arm_code)
				boutput(user,SPAN_ALERT("That isn't the right code!"))
				return

		var/input = input(user, "Leave blank for none.", "Secret Arming Code", src.arm_code) as text | null
		if (!in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE

		if (input == "")
			arm_code = null
			boutput(user,SPAN_ALERT("You clear the arming code."))
		else
			arm_code = input
			boutput(user,SPAN_ALERT("You set the arming code. Hope you remembered it!"))

	attackby(obj/item/W, mob/user)
		// bug: you can still add/remove mechcomp connections to this
		// bug: unwrenching it removes all connections
		if (is_armed)
			boutput(user,SPAN_ALERT("You can't seem to interact with this at all while it's armed!"))
			return FALSE

		return ..(W, user)




/obj/item/mechanics/hangman
	name = "hangman game component"
	desc = "Imagine having to use a bunch of components to emulate this. Nobody would do that. Nobody."
	icon_state = "hangman"

	var/puzzle = null /// original puzzle string
	var/puzzle_filtered = null /// alphabetical-only version of the puzzle
	var/puzzle_current = null /// current alphabetical-only revealed puzzle
	var/solved = FALSE /// if the puzzle was solved
	var/guesses = 0 /// (single letter) guesses used so far
	var/bad_guesses = 0 /// (single letter) guesses used so far that didn't uncover anything
	var/list/letters = list() /// list of not-yet-guessed letters

	New()
		..()
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "guess", PROC_REF(guess))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "Set Puzzle", PROC_REF(setPuzzleAutomatically))
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "Set Puzzle", PROC_REF(setPuzzle))

	proc/setPuzzleAutomatically(var/datum/mechanicsMessage/input)
		if (input.signal != "")
			src.guesses = 0
			src.bad_guesses = 0
			src.solved = FALSE
			src.letters = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",\
			                   "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z")
			var/output_puzzle_text = src.filter_puzzle(input.signal)
			// src.obj_speak("new puzzle set: [src.puzzle] -- filtered: [src.puzzle_filtered] -- current: [src.puzzle_current]")
			SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "solved=[src.solved]&guesses=[src.guesses]&bad_guesses=[src.bad_guesses]&puzzle=[output_puzzle_text]")


	proc/setPuzzle(obj/item/W as obj, mob/user as mob)
		var/input = input(user, "Will use A-Z only.", "Set Puzzle", src.puzzle) as text | null
		if (!in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE

		if (input != "")
			boutput(user,SPAN_ALERT("You set the puzzle and reset the game."))
			// "there has to be a better way": yeah, probably. sue me.
			src.guesses = 0
			src.bad_guesses = 0
			src.solved = FALSE
			src.letters = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",\
			                   "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z")
			var/output_puzzle_text = src.filter_puzzle(input)
			SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "solved=[src.solved]&guesses=[src.guesses]&bad_guesses=[src.bad_guesses]&puzzle=[output_puzzle_text]")


	proc/filter_puzzle(new_puzzle)
		// internal puzzle state uses an all-lowercase, letter-only
		// only alphabetical characters go in the filtered puzzle
		var/regex/non_alpha = new(@"[^a-z]", "ig")

		src.puzzle = new_puzzle
		src.puzzle_filtered = lowertext(replacetext(new_puzzle, non_alpha, ""))
		return src.update_puzzle()

	// update the internal view of the puzzle,
	// and return the external view of it
	proc/update_puzzle()
		if (length(letters))
			// our search is "every letter not yet guessed" (ig for case insensitive + all matches)
			var/regex/filter_unguessed = new("\[[src.letters.Join("")]]", "ig")
			src.puzzle_current = replacetext(src.puzzle_filtered, filter_unguessed, "*")
			return replacetext(src.puzzle, filter_unguessed, "*")
		else
			// if there are no unguessed letters left then we don't really
			// have to do any work here, do we.
			src.puzzle_current = src.puzzle_filtered
			return src.puzzle


	proc/guess(var/datum/mechanicsMessage/input)
		if (!src.puzzle || src.solved)
			// if no puzzle or we're solved, nothing matters. life is empty
			return

		if (length(input.signal) == 1)
			// guess a letter
			var/letter = lowertext(input.signal)
			if (!letters.Find(letter))
				// if it is not a guessable letter, just do nothing.
				return

			// remove letter from the unguessed letters list
			letters -= letter
			src.guesses++

			// update current puzzle state and get output text
			var/output_puzzle_text = src.update_puzzle()
			src.solved = src.check_if_solved(src.puzzle_current)

			// get the # of instances of this letter in the puzzle
			// (remove all of the other letters and count how long it is)
			var/regex/filter_letter = new("\[^[letter]]", "ig")
			var/tmp_puz = replacetext(src.puzzle_current, filter_letter, "")
			var/letter_count = length(tmp_puz)

			if (src.solved)
				playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
				SPAWN(0.5 SECONDS)
					playsound(src.loc, 'sound/voice/yayyy.ogg', 50, 0)
			else if (letter_count)
				// if the letter was in here
				playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
			else
				// bad guess, no letters
				src.bad_guesses++
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)

			// return output values
			SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "solved=[src.solved]&guesses=[src.guesses]&bad_guesses=[src.bad_guesses]&guessed=[letter]&count=[letter_count]&puzzle=[output_puzzle_text]")

		else
			// guess the whole word
			// for ease of use we only care if it actually matches
			// invalid guesses don't count
			src.solved = src.check_if_solved(input.signal)
			if (src.solved)
				// all the letters are known, so just empty that list
				src.letters = list()
				var/output_puzzle_text = src.update_puzzle()
				playsound(src.loc, 'sound/voice/yayyy.ogg', 50, 0)
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, "solved=[src.solved]&guesses=[src.guesses]&bad_guesses=[src.bad_guesses]&puzzle=[output_puzzle_text]")


	proc/check_if_solved(possible_solution)
		// this ends up filtering out the unsolved puzzle's *s as well,
		// but that just means it won't match, so it's fine.
		var/regex/non_alpha = new(@"[^a-z]", "ig")
		possible_solution = lowertext(replacetext(possible_solution, non_alpha, ""))
		if (possible_solution == src.puzzle_filtered)
			return TRUE
		return FALSE



#undef IN_CABINET
#undef LIGHT_UP_HOUSING
