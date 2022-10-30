//See mechComp_signals.dm  for  mechanics_holder - How Messages get passed around.

//TODO:
// - Message Datum pooling and recycling.

#define IN_CABINET (istype(src.loc,/obj/item/storage/mechanics))
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
/obj/item/storage/mechanics // generic
	name="Generic MechComp Housing"
	desc="You should not bee seeing this! Call 1-800-CODER or just crusher it"
	icon='icons/misc/mechanicsExpansion.dmi'
	can_hold=list(/obj/item/mechanics)
	var/list/users = list() // le chumps who have opened the housing
	deconstruct_flags = DECON_NONE //nope, so much nope.
	slots=1
	var/num_f_icons = 0 // how many fill icons i have
	var/light_time=0
	var/light_color = list(0, 255, 255, 255)
	var/open=true
	var/welded=false
	var/can_be_welded=false
	var/can_be_anchored=false
	custom_suicide=true
	open_to_sound = TRUE

	New()
		processing_items |= src
		..()

	process()
		if (src.light_time>0)
			src.light_time--
			src.UpdateIcon()
			return

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
				src.open=true
				src.welded=false
				src.UpdateIcon()
				return
			if (3)
				if(prob(50) && !src.welded)
					src.open=true
					src.UpdateIcon()
				return
		return
	suicide(var/mob/user as mob) // lel
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] stares into the [src], trying to make sense of its function!</b></span>")
		SPAWN(3 SECONDS)
			user.visible_message("<span class='alert'><b>[user]'s brain melts!</b></span>")
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
				boutput(user,"<span class='alert'>The [src] is welded shut.</span>")
				return
			src.does_not_open_in_pocket=src.open
			src.open=!src.open
			playsound(src.loc,'sound/items/screwdriver.ogg',50)
			if(!src.open)
				src.close_storage_menus()
			else
				src.light_time=0
			src.UpdateIcon()
			return 1
		else if (iswrenchingtool(W))
			if(!src.can_be_anchored)
				boutput(user,"<span class='alert'>[src] cannot be anchored to the ground.</span>")
				return
			if(!src.open || src.welded)
				boutput(user,"<span class='alert'>You are unable to access the [src]'s bolts as they are on the inside.</span>")
				return
			if(!isturf(src.loc) && !src.anchored)
				boutput(user,"<span class='alert'>You cannot anchor a component housing inside something else.</span>")
				return
			src.anchored=!src.anchored
			notify_cabinet_state()
			playsound(src.loc,'sound/items/Ratchet.ogg',50)
			boutput(user,"<span class='notice'>You [src.anchored ? "anchor the [src] to" : "unsecure the [src] from"] the ground</span>")
			if (!src.anchored)
				src.destroy_outside_connections() //burn those bridges
			return 1
		else if (isweldingtool(W))
			if (!src.can_be_welded)
				boutput(user,"<span class='alert'>[src]'s cover cannot be welded shut.</span>")
				return
			if (src.open)
				boutput(user,"Why would you want to weld something <i>open?</i>")
				return
			if(W:try_weld(user, 1))
				src.welded=!src.welded
				boutput(user,"<span class='notice'>You [src.welded ? "" : "un"]weld the [src]'s cover</span>")
				src.UpdateIcon()
				return 1
		else if (src.open || !istype(W,/obj/item/mechanics))
			..()
			src.UpdateIcon()
		return 1

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
		return

	proc
		close_storage_menus() // still ugly but probably quite better performing
			for(var/mob/chump in src.users)
				for(var/datum/hud/storage/hud in chump.huds)
					if(hud.master==src) hud.close.clicked()
			src.users = list() // gee golly i hope garbage collection does its job
			return 1
		notify_cabinet_state()
			for (var/obj/item/mechanics/comp in src.contents)
				comp.cabinet_state_change(src)
		destroy_outside_connections()
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
	disposing()
		..()
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
		can_be_welded=true
		can_be_anchored=true
		slots=CABINET_CAPACITY // wew, dont use this in-hand or equipped!
		name="Component Cabinet" // i tried to replace "23" below with "[CABINET_CAPACITY]", but byond
									 // thinks it's not a constant and refuses to work with it.
		desc="A rather chunky cabinet for storing up to 23 active mechanic components\
		 at once.<br>It can only be connected to external components when bolted to the floor.<br>"
		w_class = W_CLASS_BULKY //all the weight
		num_f_icons=3
		density=1
		anchored=false
		icon_state="housing_cabinet"
		flags = FPRINT | EXTRADELAY | CONDUCT
		light_color = list(0, 179, 255, 255)

		attack_hand(mob/user)
			if(src.loc==user)
				src.set_loc(get_turf(src))
				user.drop_item()
				return
			return mouse_drop(user)

		attack_self(mob/user as mob)
			src.set_loc(get_turf(user))
			user.drop_item()
			return

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
		anchored=0
		num_f_icons=1
		icon_state="housing_handheld"
		flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT | ONBELT
		light_color = list(51, 0, 0, 0)
		spawn_contents=list(/obj/item/mechanics/trigger/trigger)

		proc/find_trigger() // find the trigger comp, return 1 if found.
			if (!istype(src.the_trigger))
				src.the_trigger = (locate(/obj/item/mechanics/trigger/trigger) in src.contents)
				if (!istype(src.the_trigger)) //no trigger?
					for(var/obj/item in src.contents)
						item.set_loc(get_turf(src)) // kick out any mechcomp
					qdel(src) // delet
					return false
			return true
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
	icon_state = "comp_button"
	var/icon_up = "comp_button"
	var/icon_down = "comp_button1"
	density = 1
	anchored= 1
	level=1
	w_class = W_CLASS_BULKY
	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
	attackby(obj/item/W, mob/user)
		if(iswrenchingtool(W)) // prevent unanchoring
			return 0
		if(..()) return 1
		return 1 //attack_hand(user) // was causing issues

	attack_hand(mob/user)
		..()
		if (!istype(src.loc,/obj/item/storage/mechanics/housing_handheld))
			qdel(src) //if outside the gun, delet
			return
		if(level == 1)
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
		return

// Put these into Mechanic's locker
/obj/item/electronics/frame/mech_cabinet
	name = "Component Cabinet frame"
	store_type = /obj/item/storage/mechanics/housing_large
	viewstat = 2
	secured = 2
	icon_state = "dbox"

/obj/item/mechanics
	name = "testhing"
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "comp_unk"
	item_state = "swat_suit"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	object_flags = NO_GHOSTCRITTER
	plane = PLANE_NOSHADOW_BELOW
	w_class = W_CLASS_TINY
	level = 2
	/// whether or not this component is prevented from being anchored in cabinets
	var/cabinet_banned = FALSE
	/// whether or not this component can only be used in cabinets
	var/cabinet_only = FALSE
	/// if true makes it so that only one component can be wrenched on the tile
	var/one_per_tile = FALSE
	var/under_floor = 0
	var/can_rotate = 0
	var/cooldown_time = 3 SECONDS
	var/when_next_ready = 0
	var/list/particle_list
	var/mob/owner = null

	New()
		particle_list = new/list()
		AddComponent(/datum/component/mechanics_holder)
		processing_items |= src
		return ..()


	disposing()
		processing_items.Remove(src)
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
			var/obj/item/storage/mechanics/the_container = src.loc
			if(istype(the_container,/obj/item/storage/mechanics)) // wew lad i hope this compiles
				the_container.light_up()
			return


		clear_owner()
			UnregisterSignal(owner, COMSIG_PARENT_PRE_DISPOSING)
			owner = null

		set_owner(mob/user)
			RegisterSignal(user, COMSIG_PARENT_PRE_DISPOSING, .proc/clear_owner)
			owner = user




	process()
		if(level == 2 || under_floor)
			cutParticles()
			return
		var/pointer_container[1] //A list of size 1, to store the address of the list we want
		SEND_SIGNAL(src, _COMSIG_MECHCOMP_GET_OUTGOING, pointer_container)
		var/list/connected_outgoing = pointer_container[1]
		if(length(particle_list) != length(connected_outgoing))
			cutParticles()
			for(var/atom/X in connected_outgoing)
				particle_list.Add(particleMaster.SpawnSystem(new /datum/particleSystem/mechanic(src.loc, X.loc)))

		return

	attack_hand(mob/user)
		if(level == 1) return
		if(issilicon(user) || isAI(user)) return
		else return ..(user)

	attack_ai(mob/user as mob)
		return src.Attackhand(user)
	proc/secure()
	proc/loosen()
	proc/cabinet_state_change(var/obj/item/storage/mechanics/container)

	proc/rotate()
		src.set_dir(turn(src.dir, -90))

	attackby(obj/item/W, mob/user)
		if (ispryingtool(W))
			if (can_rotate)
				if (!anchored)
					rotate()
				else
					boutput(user, "You must unsecure the [src] in order to rotate it.")
			return 1
		else if(iswrenchingtool(W))
			switch(level)
				if(1) //Level 1 = wrenched into place
					boutput(user, "You detach the [src] from the [istype(src.loc,/obj/item/storage/mechanics) ? "housing" : "underfloor"] and deactivate it.")
					logTheThing(LOG_STATION, user, "detaches a <b>[src]</b> from the [istype(src.loc,/obj/item/storage/mechanics) ? "housing" : "underfloor"] and deactivates it at [log_loc(src)].")
					level = 2
					anchored = 0
					clear_owner()
					loosen()
				if(2) //Level 2 = loose
					if(!isturf(src.loc) && !(IN_CABINET)) // allow items to be deployed inside housings, but not in other stuff like toolboxes
						boutput(user, "<span class='alert'>[src] needs to be on the ground  [src.cabinet_banned ? "" : "or in a component housing"] for that to work.</span>")
						return 0
					if(IN_CABINET && src.cabinet_banned)
						boutput(user,"<span class='alert'>[src] is not allowed in component housings.</span>")
						return
					if(!IN_CABINET && src.cabinet_only)
						boutput(user,"<span class='alert'>[src] is not allowed outside of component housings.</span>")
						return
					if(src.one_per_tile)
						for(var/obj/item/mechanics/Z in src.loc)
							if (Z.type == src.type && Z.level == 1)
								boutput(user,"<span class='alert'>No matter how hard you try, you are not able to think of a way to fit more than one [src] on a single tile.</span>")
								return
					if(anchored)
						boutput(user,"<span class='alert'>[src] is already attached to something somehow.</span>")
						return
					boutput(user, "You attach the [src] to the [istype(src.loc,/obj/item/storage/mechanics) ? "housing" : "underfloor"] and activate it.")
					logTheThing(LOG_STATION, user, "attaches a <b>[src]</b> to the [istype(src.loc,/obj/item/storage/mechanics) ? "housing" : "underfloor"]  at [log_loc(src)].")
					level = 1
					anchored = 1
					set_owner(user)
					secure()

			var/turf/T = src.loc
			if(isturf(T))
				hide(T.intact)
			else
				hide()

			SEND_SIGNAL(src,COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)
			return 1
		return ..()

	pick_up_by(var/mob/M)
		if(level != 1) return ..()
		//If it's anchored, it can't be picked up!

	pickup()
		if(level == 1) return
		SEND_SIGNAL(src,COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)
		return ..()

	dropped()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)
		return ..()

	mouse_drop(obj/O, null, var/src_location, var/control_orig, var/control_new, var/params)
		if(level == 2 || (istype(O, /obj/item/mechanics) && O.level == 2))
			boutput(usr, "<span class='alert'>Both components need to be secured into place before they can be connected.</span>")
			return ..()

		SEND_SIGNAL(src,_COMSIG_MECHCOMP_DROPCONNECT,O,usr)
		return

	proc/componentSay(var/string)
		string = trim(sanitize(html_encode(string)))
		for(var/mob/O in all_hearers(7, src.loc))
			O.show_message("<span class='game radio'><span class='name'>[src]</span><b> [bicon(src)] [pick("squawks", "beeps", "boops", "says", "screeches")], </b> <span class='message'>\"[string]\"</span></span>",2)

	hide(var/intact)
		under_floor = (intact && level==1)
		UpdateIcon()
		return

/obj/item/mechanics/cashmoney
	name = "Payment component"
	desc = ""
	icon_state = "comp_money"
	density = 0
	cooldown_time = 1 SECOND
	var/price = 100
	var/code = null
	var/collected = 0
	var/current_buffer = 0

	var/thank_string = ""

	get_desc()
		. += {"<br><span class='notice'>Collected money: [collected]<br>
		Current price: [price] credits</span>"}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"eject money", .proc/emoney)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Price",.proc/setPrice)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Code",.proc/setCode)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Thank-String",.proc/setThank)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Eject Money",.proc/checkEjectMoney)

	proc/emoney(var/datum/mechanicsMessage/input)
		if(level == 2 || !input) return
		if(input.signal == code)
			ejectmoney()
		return

	proc/setPrice(obj/item/W as obj, mob/user as mob)
		if (code)
			var/codecheck = strip_html_tags(input(user,"Please enter current code:","Code check","") as text)
			if (codecheck != code)
				boutput(user, "<span class='alert'>[bicon(src)]: Incorrect code entered.</span>")
				return 0
		var/inp = input(user,"Enter new price:","Price setting", price) as num
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(!isnull(inp))
			if (inp < 0)
				user.show_text("You cannot set a negative price.", "red") // Infinite credits exploit.
				return 0
			if (inp == 0)
				user.show_text("Please set a price higher than zero.", "red")
				return 0
			if (inp > 1000000) // ...and just to be on the safe side. Should be plenty.
				inp = 1000000
				user.show_text("[src] is not designed to handle such large transactions. Input has been set to the allowable limit.", "red")
			price = inp
			tooltip_rebuild = 1
			boutput(user, "Price set to [inp]")
			return 1
		return 0

	proc/setCode(obj/item/W as obj, mob/user as mob)
		if (code)
			var/codecheck = adminscrub(input(user,"Please enter current code:","Code check","") as text)
			if (codecheck != code)
				boutput(user, "<span class='alert'>[bicon(src)]: Incorrect code entered.</span>")
				return 0
		var/inp = adminscrub(input(user,"Please enter new code:","Code setting","dosh") as text)
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(inp))
			code = inp
			boutput(user, "Code set to [inp]")
			return 1
		return 0

	proc/setThank(obj/item/W as obj, mob/user as mob)
		thank_string = adminscrub(input(user,"Please enter string:","string","Thanks for using this mechcomp service!") as text)
		return 1

	proc/checkEjectMoney(obj/item/W as obj, mob/user as mob)
		if(code)
			var/codecheck = strip_html_tags(input(user,"Please enter current code:","Code check","") as text)
			if(!in_interact_range(src, user) || user.stat)
				return 0
			if (codecheck != code)
				boutput(user, "<span class='alert'>[bicon(src)]: Incorrect code entered.</span>")
				return 0
		ejectmoney()

	attackby(obj/item/W, mob/user)
		if(..(W, user)) return 1
		if (istype(W, /obj/item/spacecash) && !ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			LIGHT_UP_HOUSING
			current_buffer += W.amount
			if (src.price <= 0)
				src.price = initial(src.price)
			if (current_buffer >= price)
				if (length(thank_string))
					componentSay("[thank_string]")

				if (current_buffer > price)
					componentSay("Here is your change!")
					var/obj/item/spacecash/C = new /obj/item/spacecash(user.loc, current_buffer - price)
					user.put_in_hand_or_drop(C)

				collected += price
				tooltip_rebuild = 1
				current_buffer = 0

				user.drop_item()
				qdel(W)

				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG, null)
				flick("comp_money1", src)
				return 1
		return 0


	proc/ejectmoney()
		if (collected)
			var/obj/item/spacecash/S = new /obj/item/spacecash
			S.setup(get_turf(src), collected)
			collected = 0
			tooltip_rebuild = 1
		return

/obj/item/mechanics/flushcomp
	name = "Flusher component"
	desc = ""
	icon_state = "comp_flush"
	cooldown_time = 2 SECONDS
	cabinet_banned = true


	var/obj/disposalpipe/trunk/trunk = null
	var/datum/gas_mixture/air_contents
	var/max_capacity = 100

	New()
		. = ..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"flush", .proc/flushp)

	disposing()
		if(air_contents)
			qdel(air_contents)
			air_contents = null
		trunk = null
		..()

	attackby(obj/item/W, mob/user)
		if(..(W, user))
			if(src.level == 1) //wrenched down
				trunk = locate() in src.loc
				if(trunk)
					trunk.linked = src
					air_contents = new /datum/gas_mixture
			else if (src.level == 2) //loose
				if (trunk) //ZeWaka: Fix for null.linked
					trunk.linked = null
				if(air_contents)
					qdel(air_contents)
				air_contents = null
				trunk = null
			return 1
		return 0

	proc/flushp(var/datum/mechanicsMessage/input)
		var/count = 0
		if(level == 2) return
		if(input?.signal && !ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time) && trunk && !trunk.disposed)
			for(var/atom/movable/M in src.loc)
				if(M == src || M.anchored || isAI(M)) continue
				if(count == src.max_capacity)
					break
				M.set_loc(src)
				count++
			flushit()

	proc/flushit()
		if(!trunk) return
		if(trunk.loc != src.loc)
			trunk = null
			return
		LIGHT_UP_HOUSING
		var/obj/disposalholder/H = new /obj/disposalholder

		H.init(src)

		air_contents.zero()

		flick("comp_flush1", src)
		sleep(1 SECOND)
		playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)

		H.start(src) // start the holder processing movement

	proc/expel(var/obj/disposalholder/H)

		var/turf/target
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))

			AM.set_loc(src.loc)
			AM.pipe_eject(0)
			AM?.throw_at(target, 5, 1)

		H.vent_gas(loc)
		qdel(H)

/obj/item/mechanics/thprint
	name = "Thermal printer"
	desc = ""
	icon_state = "comp_tprint"
	cooldown_time = 5 SECONDS
	var/paper_name = "thermal paper"
	cabinet_banned = true
	plane = PLANE_DEFAULT

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"print", .proc/print)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Paper Name",.proc/setPaperName)

	proc/print(var/datum/mechanicsMessage/input)
		if(level == 2 || ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time)) return
		if(input)
			LIGHT_UP_HOUSING
			flick("comp_tprint1",src)
			playsound(src.loc, 'sound/machines/printer_thermal.ogg', 60, 0)
			var/obj/item/paper/thermal/P = new/obj/item/paper/thermal(src.loc)
			P.info = strip_html_tags(html_decode(input.signal))
			P.name = paper_name
		return

	proc/setPaperName(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter name:","name setting", paper_name) as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		paper_name = adminscrub(inp)
		boutput(user, "String set to [paper_name]")
		return 1

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && GET_DIST(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.set_loc(target)
		return

/obj/item/mechanics/pscan
	name = "Paper scanner"
	desc = ""
	icon_state = "comp_pscan"
	var/del_paper = 1
	var/thermal_only = 1

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Paper Consumption",.proc/toggleConsume)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Thermal Paper Mode",.proc/toggleThermal)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && GET_DIST(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.set_loc(target)
		return

	proc/toggleConsume(obj/item/W as obj, mob/user as mob)
		del_paper = !del_paper
		boutput(user, "[del_paper ? "Now consuming paper":"Now NOT consuming paper"]")
		return 1
	proc/toggleThermal(obj/item/W as obj, mob/user as mob)
		thermal_only = !thermal_only
		boutput(user, "[thermal_only ? "Now accepting only thermal paper":"Now accepting any paper"]")
		return 1

	attackby(obj/item/W, mob/user)
		if(..(W, user)) return 1
		else if (istype(W, /obj/item/paper) && !ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			if(thermal_only && !istype(W, /obj/item/paper/thermal))
				boutput(user, "<span class='alert'>This scanner only accepts thermal paper.</span>")
				return 0
			LIGHT_UP_HOUSING
			flick("comp_pscan1",src)
			playsound(src.loc, 'sound/machines/twobeep2.ogg', 90, 0)
			var/obj/item/paper/P = W
			var/saniStr = strip_html_tags(sanitize(html_encode(P.info)))
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,saniStr)
			if(del_paper)
				del(W)
			return 1
		return 0

//todo: merge with the secscanner?
/obj/mechbeam
	//Would use the /obj/beam but its not extensible enough.
	name = "trip laser"
	desc = "A beam of light that will trigger a device when passed."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ibeam"
	anchored = 1
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
		if (isobserver(AM) || !AM.density) return
		if (!istype(AM, /obj/mechbeam))
			SPAWN(0) tripped()

/obj/item/mechanics/triplaser
	name = "Trip laser"
	desc = "Fires a signal when someone passes through the beam."
	icon = 'icons/obj/networked.dmi'
	icon_state = "secdetector0"
	can_rotate = 1
	cabinet_banned = true // abusable. B&
	var/range = 5
	var/list/beamobjs = new/list(5)//just to avoid someone doing something dumb and making it impossible for us to clear out the beams
	var/active = 0
	var/sendstr = "1"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", .proc/toggle)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Range",.proc/setRange)

	proc/setRange(obj/item/W as obj, mob/user as mob)
		var/rng = input("Range is limited between 1-5.", "Enter a new range", range) as num
		if(!in_interact_range(src, user) || user.stat)
			return 0
		range = clamp(rng, 1, 5)
		boutput(user, "<span class='notice'>Range set to [range]!</span>")
		if(level == 1)
			rebeam()
		return 1

	proc/toggle()
		if(active)
			loosen()
		else
			secure()
	loosen()
		active = 0
		for(var/beam in beamobjs)
			qdel(beam)
	secure()
		rebeam()

	rotate()
		if(level == 1)
			rebeam()

	disposing()
		loosen()
		..()

	proc/tripped()
		LIGHT_UP_HOUSING
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG, null)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && GET_DIST(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.set_loc(target)
		return

	proc/rebeam()
		loosen()
		active = 1
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
	var/send_name = 0

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal Type",.proc/toggleSig)

	proc/toggleSig(obj/item/W as obj, mob/user as mob)
		send_name = !send_name
		boutput(user, "[send_name ? "Now sending user NAME":"Now sending user FINGERPRINT"]")
		return 1

	attack_hand(mob/user)
		if(level != 2 && !ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time))
			if(ishuman(user) && user.bioHolder)
				LIGHT_UP_HOUSING
				flick("comp_hscan1",src)
				playsound(src.loc, 'sound/machines/twobeep2.ogg', 90, 0)
				var/sendstr = (send_name ? user.real_name : user.bioHolder.fingerprints)
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,sendstr)
			else
				boutput(user, "<span class='alert'>The hand scanner can only be used by humanoids.</span>")
				return
		else return ..(user)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && GET_DIST(src, target) == 1)
			if(isturf(target) && target.density)
				user.drop_item()
				src.set_loc(target)
		return

/obj/item/mechanics/accelerator
	name = "Graviton accelerator"
	desc = ""
	icon_state = "comp_accel"
	can_rotate = 1
	cabinet_banned = true // non-functional
	var/active = 0
	event_handler_flags = USE_FLUID_ENTER

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", .proc/activateproc)

	proc/drivecurrent()
		if(level == 2) return
		LIGHT_UP_HOUSING
		var/count = 0
		for(var/atom/movable/M in src.loc)
			if(M.anchored) continue
			count++
			if(M == src) continue
			throwstuff(M)
			if(count > 50) return
			if(APPROX_TICK_USE > 100) return //fuck it, failsafe

	proc/activateproc(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(input)
			if(active) return
			particleMaster.SpawnSystem(new /datum/particleSystem/gravaccel(src.loc, src.dir))
			SPAWN(0)
				icon_state = "[under_floor ? "u":""]comp_accel1"
				active = 1
				drivecurrent()
				sleep(0.5 SECONDS)
				drivecurrent()
				sleep(2.5 SECONDS)
				icon_state = "[under_floor ? "u":""]comp_accel"
				active = 0
		return

	proc/throwstuff(atom/movable/AM as mob|obj)
		if(level == 2 || AM.anchored || AM == src) return
		if(AM.throwing) return
		var/atom/target = get_edge_target_turf(AM, src.dir)
		var/datum/thrown_thing/thr = AM.throw_at(target, 50, 1)
		thr?.user = (owner)
		return

	Crossed(atom/movable/AM as mob|obj)
		..()
		if(level == 2) return
		if(active)
			throwstuff(AM)
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_accel"
		return

/// Tesla Coil mechanics component - zaps people
/obj/item/mechanics/zapper
	name = "Tesla Coil"
	desc = ""
	icon_state = "comp_zap"
	cooldown_time = 1 SECOND
	cabinet_banned = true
	one_per_tile = true
	var/zap_power = 2

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"zap", .proc/eleczap)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Power",.proc/setPower)

	proc/eleczap(var/datum/mechanicsMessage/input)
		if(level == 2 || ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time)) return
		var/area/AR = get_area(src)
		if(!AR.powered(EQUIP) || AR.area_apc?.cell?.percent() < 35) return
		AR.use_power(0.5 KILO WATTS, EQUIP)
		LIGHT_UP_HOUSING
		elecflash(src.loc, 0, power = zap_power, exclude_center = 0)

	proc/setPower(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Power(1 - 3):","Power setting", zap_power) as num
		if(!in_interact_range(src, user) || !isalive(user))
			return 0
		inp = clamp(round(inp), 1, 3)
		zap_power = inp
		boutput(user, "Power set to [inp]")
		return 1

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
	var/active = 0
	var/delay = 10
	var/changesig = 0

	get_desc()
		. += "<br><span class='notice'>Current Delay: [delay]</span>"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"delay", .proc/delayproc)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Delay",.proc/setDelay)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal Changing",.proc/toggleDefault)

	proc/setDelay(obj/item/W as obj, mob/user as mob)
		var/inp = input(user, "Enter delay in 10ths of a second:", "Set delay", 10) as num
		if(!in_interact_range(src, user) || user.stat)
			return 0
		inp = max(inp, 10)
		if(!isnull(inp))
			delay = inp
			tooltip_rebuild = 1
			boutput(user, "Set delay to [inp]")
			return 1
		return 0

	proc/toggleDefault(obj/item/W as obj, mob/user as mob)
		changesig = !changesig
		boutput(user, "Signal changing now [changesig ? "on":"off"]")
		return 1

	proc/delayproc(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(input)
			if(active) return
			LIGHT_UP_HOUSING
			SPAWN(0)
				if(src)
					icon_state = "[under_floor ? "u":""]comp_wait1"
					active = 1
				sleep(delay)
				if(src)
					var/transmissionStyle = changesig ? COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG : COMSIG_MECHCOMP_TRANSMIT_MSG
					SEND_SIGNAL(src,transmissionStyle,input)
					icon_state = "[under_floor ? "u":""]comp_wait"
					active = 0
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_wait"
		return

//If two signals arrive within the timeframe: send the set signal
/obj/item/mechanics/andcomp
	name = "AND Component"
	desc = ""
	icon_state = "comp_and"
	var/timeframe = 30
	var/inp1 = 0
	var/inp2 = 0

	get_desc()
		. += "<br><span class='notice'>Current Time Frame: [timeframe]</span>"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 1", .proc/fire1)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 2", .proc/fire2)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Time Frame",.proc/setTime)

	proc/setTime(obj/item/W as obj, mob/user as mob)
		var/inp = input(user, "Enter Time Frame in 10ths of a second:", "Set Time Frame", timeframe) as num
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(!isnull(inp))
			timeframe = inp
			tooltip_rebuild = 1
			boutput(user, "Set Time Frame to [inp]")
			return 1
		return 0

	proc/fire1(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(inp1) return
		LIGHT_UP_HOUSING
		inp1 = 1

		if(inp2)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,input)
			inp1 = 0
			inp2 = 0
			return

		SPAWN(timeframe)
			inp1 = 0

		return

	proc/fire2(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(inp2) return
		LIGHT_UP_HOUSING
		inp2 = 1

		if(inp1)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,input)
			inp1 = 0
			inp2 = 0
			return

		SPAWN(timeframe)
			inp2 = 0

		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_and"
		return

/obj/item/mechanics/orcomp
	name = "OR Component"
	desc = ""
	icon_state = "comp_or"
	var/triggerSignal = "1"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 1", .proc/fire)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 2", .proc/fire)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 3", .proc/fire)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 4", .proc/fire)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 5", .proc/fire)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 6", .proc/fire)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 7", .proc/fire)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 8", .proc/fire)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 9", .proc/fire)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 10", .proc/fire)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Trigger Field",.proc/setTrigger)

	proc/setTrigger(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Signal:","Signal setting","1") as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(inp))
			inp = strip_html_tags(html_decode(inp))
			triggerSignal = inp
			boutput(user, "Signal set to [inp]")
			return 1
		return 0

	proc/fire(var/datum/mechanicsMessage/input)
		if(level != 2 && input.signal == triggerSignal)
			LIGHT_UP_HOUSING
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,input)
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_or"
		return

/obj/item/mechanics/wifisplit
	name = "Wifi Signal Splitter Component"
	desc = ""
	icon_state = "comp_split"
	var/triggerSignal = "1"

	get_desc()
		. += "<br><span class='notice'>Current Trigger Field: [triggerSignal]</span>"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"split", .proc/split)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Trigger Field",.proc/setTrigger)

	proc/setTrigger(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Signal:","Signal setting","1") as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(inp))
			inp = strip_html_tags(html_decode(inp))
			triggerSignal = inp
			boutput(user, "Signal set to [inp]")
			return 1
		return 0

	proc/split(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		var/list/converted = params2list(input.signal)
		if(length(converted))
			if(triggerSignal in converted)
				input.signal = converted[triggerSignal]
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG, input)
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_split"
		return

/obj/item/mechanics/regreplace
	name = "RegEx Replace Component"
	desc = ""
	icon_state = "comp_regrep"
	var/expressionpatt = "original"
	var/expressionrepl = "replacement"
	var/expressionflag = "g"

	get_desc()
		. += {"<br/><span class='notice'>Current Pattern: [html_encode(expressionpatt)]</span><br/>
		<span class='notice'>Current Replacement: [html_encode(expressionrepl)]</span><br/>
		<span class='notice'>Current Flags: [html_encode(expressionflag)]</span><br/>
		Your replacement string can contain $0-$9 to insert that matched group(things between parenthesis)<br/>
		$` will be replaced with the text that came before the match, and $' will be replaced by the text after the match.<br/>
		$0 or $& will be the entire matched string."}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"replace string", .proc/checkstr)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set pattern", .proc/setPatternSignal)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set replacement", .proc/setReplacementSignal)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set flags", .proc/setFlagsSignal)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Pattern",.proc/setPattern)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Replacement",.proc/setReplacement)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Flags",.proc/setFlags)

	proc/setPattern(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Pattern:","Pattern setting", expressionpatt) as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(inp))
			expressionpatt = inp
			inp = sanitize(html_encode(inp))
			boutput(user, "Pattern set to [inp]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/setPatternSignal(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		expressionpatt = input.signal
		tooltip_rebuild = 1

	proc/setReplacement(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Replacement:","Replacement setting", expressionrepl) as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(inp))
			expressionrepl = inp
			inp = sanitize(html_encode(inp))
			boutput(user, "Replacement set to [inp]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/setReplacementSignal(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		expressionrepl = input.signal
		tooltip_rebuild = 1

	proc/setFlags(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Flags:","Flags setting", expressionflag) as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(inp))
			expressionflag = inp
			inp = sanitize(html_encode(inp))
			boutput(user, "Flags set to [inp]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/setFlagsSignal(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		expressionflag = input.signal
		tooltip_rebuild = 1

	proc/checkstr(var/datum/mechanicsMessage/input)
		if(level == 2 || !length(expressionpatt)) return
		LIGHT_UP_HOUSING
		var/regex/R = new(expressionpatt,expressionflag)

		if(!R) return

		var/mod = R.Replace(input.signal, expressionrepl)
		mod = strip_html_tags(sanitize(html_encode(mod)))//U G H

		if(mod)
			input.signal = mod
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_regrep"
		return

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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"check string", .proc/checkstr)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set regex", .proc/setregex)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Expression Pattern",.proc/setRegex)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Expression Flags",.proc/setFlags)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal replacing",.proc/toggleReplaceing)

	proc/setRegex(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Expression Pattern:","Expression setting", expressionpatt) as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(inp))
			expressionpatt = inp
			expressionTT =("[expressionpatt]/[expressionflag]")
			inp = sanitize(html_encode(inp))
			boutput(user, "Expression Pattern set to [inp], Current Expression: [sanitize(html_encode(expressionTT))]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/setFlags(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Expression Flags:","Expression setting", expressionflag) as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(inp))
			expressionflag = inp
			expressionTT =("[expressionpatt]/[expressionflag]")
			inp = sanitize(html_encode(inp))
			boutput(user, "Expression Flags set to [inp], Current Expression: [sanitize(html_encode(expressionTT))]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/toggleReplaceing(obj/item/W as obj, mob/user as mob)
		replacesignal = !replacesignal
		boutput(user, "[replacesignal ? "Now forwarding own Signal":"Now forwarding found String"]")
		tooltip_rebuild = 1
		return 1

	proc/setregex(var/datum/mechanicsMessage/input)
		if(level == 2) return
		expressionpatt = input.signal
		expressionTT = ("[expressionpatt]/[expressionflag]")
		tooltip_rebuild = 1
	proc/checkstr(var/datum/mechanicsMessage/input)
		if(level == 2 || !length(expressionTT)) return
		LIGHT_UP_HOUSING
		var/regex/R = new(expressionpatt, expressionflag)

		if(!R) return

		if(R.Find(input.signal))
			if(replacesignal)
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,input)
			else
				input.signal = R.match
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_regfind"
		return

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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"check string", .proc/checkstr)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set trigger", .proc/settrigger)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Trigger-String",.proc/setTrigger)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Invert Trigger",.proc/invertTrigger)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Replace Signal",.proc/toggleReplace)

	proc/setTrigger(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter String:","String setting","1") as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(inp))
			inp = adminscrub(inp)
			triggerSignal = inp
			boutput(user, "String set to [inp]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/invertTrigger(obj/item/W as obj, mob/user as mob)
		not = !not
		boutput(user, "[not ? "Component will now trigger when the String is NOT found.":"Component will now trigger when the String IS found."]")
		tooltip_rebuild = 1
		return 1

	proc/toggleReplace(obj/item/W as obj, mob/user as mob)
		changesig = !changesig
		boutput(user, "Signal changing now [changesig ? "on":"off"]")
		tooltip_rebuild = 1
		return 1

	proc/checkstr(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		var/transmissionStyle = changesig ? COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG : COMSIG_MECHCOMP_TRANSMIT_MSG
		if(findtext(input.signal, triggerSignal))
			if(!not)
				SEND_SIGNAL(src,transmissionStyle,input)
		else
			if(not)
				SEND_SIGNAL(src,transmissionStyle,input)
		return

	proc/settrigger(var/datum/mechanicsMessage/input)
		if(level == 2) return
		triggerSignal = input.signal
		tooltip_rebuild = 1
	update_icon()
		icon_state = "[under_floor ? "u":""]comp_check"
		return

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
		. += "<br><span class='notice'>Exact match mode: [exact_match ? "on" : "off"]<br>Single output mode: [single_output ? "on" : "off"]</span>"

	New()
		..()
		src.outgoing_filters = list()
		RegisterSignal(src, list(_COMSIG_MECHCOMP_DISPATCH_ADD_FILTER), .proc/addFilter)
		RegisterSignal(src, list(_COMSIG_MECHCOMP_DISPATCH_RM_OUTGOING), .proc/removeFilter)
		RegisterSignal(src, list(_COMSIG_MECHCOMP_DISPATCH_VALIDATE), .proc/runFilter)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"dispatch", .proc/dispatch)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle exact matching",.proc/toggleExactMatching)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle single output mode",.proc/toggleSingleOutput)

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
		tooltip_rebuild = 1
		return 1

	proc/toggleSingleOutput(obj/item/W as obj, mob/user as mob)
		single_output = !single_output
		boutput(user, "Single output mode now [single_output ? "on" : "off"]")
		tooltip_rebuild = 1
		return 1

	proc/dispatch(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		var/sent = SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		if(sent) animate_flash_color_fill(src,"#00FF00",2, 2)
		return

	//This will get called from the component-datum when a device is being linked
	proc/addFilter(var/comsig_target, atom/receiver, mob/user)
		var/filter = input(user, "Add filters for this connection? (Comma-delimited list. Leave blank to pass all messages.)", "Intput Filters") as text
		if(!in_interact_range(src, user) || user.stat)
			return
		if (length(filter))
			if (!src.outgoing_filters[receiver]) src.outgoing_filters[receiver] = list()
			src.outgoing_filters.Add(receiver)
			src.outgoing_filters[receiver] = splittext(filter, ",")
			boutput(user, "<span class='success'>Only passing messages that [exact_match ? "match" : "contain"] [filter] to the [receiver.name]</span>")
		else
			boutput(user, "<span class='success'>Passing all messages to the [receiver.name]</span>")
		return

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
		return 1 //Signal invalid, halt it

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_disp"
		return

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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"add to string", .proc/addstr)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"add to string + send", .proc/addstrsend)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send", .proc/sendstr)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"clear buffer", .proc/clrbff)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set starting string", .proc/setStartingStringSignal)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set ending string", .proc/setEndingStringSignal)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set starting String",.proc/setStartingStringManual)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set ending String",.proc/setEndingStringManual)

	proc/setStartingStringManual(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter String:","String setting", bstr) as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		setStartingString(inp)
		boutput(user, "String set to [bstr]")
		return 1

	proc/setStartingStringSignal(var/datum/mechanicsMessage/input)
		if (level == 2) return
		LIGHT_UP_HOUSING
		setStartingString(input.signal)

	proc/setStartingString(var/inp)
		inp = strip_html_tags(inp)
		bstr = inp
		tooltip_rebuild = 1

	proc/setEndingStringManual(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter String:","String setting", astr) as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		setEndingString(inp)
		boutput(user, "String set to [astr]")
		return 1

	proc/setEndingStringSignal(var/datum/mechanicsMessage/input)
		if (level == 2) return
		LIGHT_UP_HOUSING
		setEndingString(input.signal)

	proc/setEndingString(var/inp)
		inp = strip_html_tags(inp)
		astr = inp
		tooltip_rebuild = 1

	proc/addstr(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		buffer = "[buffer][input.signal]"
		tooltip_rebuild = 1
		return

	proc/addstrsend(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		buffer = "[buffer][input.signal]"
		tooltip_rebuild = 1
		sendstr(input)
		return

	proc/sendstr(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		var/finished = "[bstr][buffer][astr]"
		finished = strip_html_tags(sanitize(finished))
		input.signal = finished
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		buffer = ""
		tooltip_rebuild = 1
		return

	proc/clrbff(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		buffer = ""
		tooltip_rebuild = 1
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_builder"
		return

/obj/item/mechanics/relaycomp
	name = "Relay Component"
	desc = ""
	icon_state = "comp_relay"
	var/changesig = 0

	get_desc()
		. += "<br><span class='notice'>Replace Signal is [changesig ? "on.":"off."]</span>"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"relay", .proc/relay)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal Changing",.proc/toggleDefault)

	proc/toggleDefault(obj/item/W as obj, mob/user as mob)
		changesig = !changesig
		boutput(user, "Signal changing now [changesig ? "on":"off"]")
		tooltip_rebuild = 1
		return 1

	proc/relay(var/datum/mechanicsMessage/input)
		if(level == 2 || ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time)) return
		LIGHT_UP_HOUSING
		flick("[under_floor ? "u":""]comp_relay1", src)
		var/transmissionStyle = changesig ? COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG : COMSIG_MECHCOMP_TRANSMIT_MSG
		SPAWN(0) SEND_SIGNAL(src,transmissionStyle,input)
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_relay"
		return

/obj/item/mechanics/filecomp
	name = "File Component"
	desc = ""
	icon_state = "comp_file"
	var/datum/computer/file/stored_file

	get_desc()
		. += "<br><span class='notice'>Stored file:[stored_file ? "<br>Name: [src.stored_file.name]<br>Extension: [src.stored_file.extension]<br>Contents: [src.stored_file.asText()]" : " NONE"]</span>"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send file", .proc/sendfile)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"add file to signal and send", .proc/addandsendfile)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"save file", .proc/storefile)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"delete file", .proc/deletefile)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)

	disposing()
		if (src.stored_file)
			stored_file.dispose()
		..()

	proc/sendfile(var/datum/mechanicsMessage/input)
		if (level == 2 || !src.stored_file) return
		LIGHT_UP_HOUSING
		input.data_file = src.stored_file.copy_file()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,input)
		animate_flash_color_fill(src,"#00FF00",2, 2)

	proc/addandsendfile(var/datum/mechanicsMessage/input)
		if (level == 2 || !src.stored_file) return
		LIGHT_UP_HOUSING
		input.data_file = src.stored_file.copy_file()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		animate_flash_color_fill(src,"#00FF00",2, 2)

	proc/storefile(var/datum/mechanicsMessage/input)
		if (level == 2 || !input.data_file) return
		LIGHT_UP_HOUSING
		src.stored_file = input.data_file.copy_file()
		tooltip_rebuild = 1
		animate_flash_color_fill(src,"#00FF00",2, 2)

	proc/deletefile(var/datum/mechanicsMessage/input)
		if (level == 2 || !src.stored_file) return
		LIGHT_UP_HOUSING
		src.stored_file = null
		tooltip_rebuild = 1
		animate_flash_color_fill(src,"#00FF00",2, 2)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_file"
		return

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

	var/noise_enabled = true
	var/frequency = FREQ_FREE

	get_desc()
		. += {"<br><span class='notice'>[forward_all ? "Sending full unprocessed Signals.":"Sending only processed sendmsg and pda Message Signals."]<br>
		[only_directed ? "Only reacting to Messages directed at this Component.":"Reacting to ALL Messages received."]<br>
		Current Frequency: [frequency]<br>
		Current NetID: [net_id]</span>"}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send radio message", .proc/send)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set frequency", .proc/setfreq)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Frequency",.proc/setFreqManually)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle NetID Filtering",.proc/toggleAddressFiltering)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Forward All",.proc/toggleForwardAll)

		MAKE_DEFAULT_RADIO_PACKET_COMPONENT("main", frequency)

		src.net_id = format_net_id("\ref[src]")

	proc/setFreqManually(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Frequency:","Frequency setting", frequency) as num
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(!isnull(inp))
			set_frequency(inp)
			boutput(user, "Frequency set to [inp]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/toggleAddressFiltering(obj/item/W as obj, mob/user as mob)
		only_directed = !only_directed
		get_radio_connection_by_id(src, "main").update_all_hearing(!only_directed)
		boutput(user, "[only_directed ? "Now only reacting to Messages directed at this Component":"Now reacting to ALL Messages."]")
		tooltip_rebuild = 1
		return 1

	proc/toggleForwardAll(obj/item/W as obj, mob/user as mob)
		forward_all = !forward_all
		boutput(user, "[forward_all ? "Now forwarding all Radio Messages as they are.":"Now processing only sendmsg and normal PDA messages."]")
		tooltip_rebuild = 1
		return 1

	proc/setfreq(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		var/newfreq = text2num_safe(input.signal)
		if(!newfreq) return
		set_frequency(newfreq)
		return

	proc/send(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		var/list/converted = params2list(input.signal)
		if(!length(converted) || ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time)) return

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
				src.noise_enabled = false
				playsound(src, 'sound/machines/wifi.ogg', WIFI_NOISE_VOLUME, 0, 0)
				SPAWN(WIFI_NOISE_COOLDOWN)
					src.noise_enabled = true
			SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, sendsig, src.range, "main")

		animate_flash_color_fill(src,"#FF0000",2, 2)
		return

	receive_signal(datum/signal/signal)
		if(!signal || level == 2)
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
						src.noise_enabled = false
						playsound(src, 'sound/machines/wifi.ogg', WIFI_NOISE_VOLUME, 0, 0)
						SPAWN(WIFI_NOISE_COOLDOWN)
							src.noise_enabled = true
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
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, strip_html_tags(html_decode("[signal.encryption]" + stars(packets, 15))), null)
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
				if(!newfreq) return
				set_frequency(newfreq)
				animate_flash_color_fill(src,"#00FF00",2, 2)

		return

	proc/set_frequency(new_frequency)
		if(!radio_controller) return
		tooltip_rebuild = 1
		new_frequency = clamp(new_frequency, 1000, 1500)
		frequency = new_frequency
		get_radio_connection_by_id(src, "main").update_frequency(frequency)

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_radiosig"
		return

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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"add item", .proc/additem)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"remove item", .proc/remitem)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"remove all items", .proc/remallitem)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"select item", .proc/selitem)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"select item + send", .proc/selitemplus)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"next", .proc/next)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"previous", .proc/previous)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"next + send", .proc/nextplus)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"previous + send", .proc/previousplus)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send selected", .proc/sendCurrent)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send selected + remove", .proc/popitem)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send random", .proc/sendRand)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Signal List",.proc/setSignalList)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Signal List(Delimeted)",.proc/setDelimetedList)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Announcements",.proc/toggleAnnouncements)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Random",.proc/toggleRandom)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Allow Duplicate Entries",.proc/toggleAllowDuplicates)


	proc/setSignalList(obj/item/W as obj, mob/user as mob)
		var/numsig = input(user,"How many Signals would you like to define?","# Signals:", 3) as num
		if(!in_interact_range(src, user) || user.stat)
			return 0
		numsig = round(numsig)
		if(numsig > 10) //Needs a limit because nerds are nerds
			boutput(user, "<span class='alert'>This component can't handle more than 10 signals!</span>")
			return 0
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
			tooltip_rebuild = 1
			return 1
		return 0

	proc/setDelimetedList(obj/item/W as obj, mob/user as mob)
		var/newsigs = ""
		newsigs = input(user, "Enter a string delimited by ; for every item you want in the list.", "Enter a thing. Max length is 2048 characters", newsigs)
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(!newsigs)
			boutput(user, "<span class='notice'>Signals remain unchanged!</span>")
			return 0
		if(length(newsigs) >= 2048)
			alert(user, "That's far too long. Trim it down some!")
			return 0
		var/list/built = splittext(newsigs, ";")
		for(var/i = 1, i <= length(built), i++)
			if(!built[i])
				built.Remove(built[i])
				i--
		signals = built
		current_index = 1
		boutput(user, "<span class='notice'>There are now [length(signals)] signals in the list.</span>")
		tooltip_rebuild = 1
		return 1

	proc/toggleAnnouncements(obj/item/W as obj, mob/user as mob)
		announce = !announce
		boutput(user, "Announcements now [announce ? "on":"off"]")
		tooltip_rebuild = 1
		return 1

	proc/toggleRandom(obj/item/W as obj, mob/user as mob)
		random = !random
		boutput(user, "[random ? "Now picking Items at random.":"Now using selected Items."]")
		tooltip_rebuild = 1
		return 1

	proc/toggleAllowDuplicates(obj/item/W as obj, mob/user as mob)
		allowDuplicates = !allowDuplicates
		boutput(user, "[allowDuplicates ? "Allowing addition of duplicate items." : "Not allowing addition of duplicate items."]")
		tooltip_rebuild = 1
		return 1

	proc/selitem(var/datum/mechanicsMessage/input)
		if(level == 2 || !input) return
		LIGHT_UP_HOUSING
		var/found_index = signals.Find(input.signal)
		if(found_index)
			current_index = found_index
			tooltip_rebuild = 1

		if(announce)
			componentSay("Current Selection : [signals[current_index]]")
		return 1

	proc/selitemplus(var/datum/mechanicsMessage/input)
		if(level == 2 || !input) return
		LIGHT_UP_HOUSING
		if(selitem(input))
			sendCurrent(input)
		return

	proc/remitem(var/datum/mechanicsMessage/input)
		if(level == 2 || !input) return
		LIGHT_UP_HOUSING
		if(input.signal in signals)
			signals.Remove(input.signal)
			if(current_index > length(signals))
				current_index = length(signals) ? length(signals) : 1 // Don't let current_index be 0
			tooltip_rebuild = 1
			if(announce)
				componentSay("Removed : [input.signal]")
		return

	proc/popitem(var/datum/mechanicsMessage/input)
		sendCurrent(input)
		remitem(input)
		return

	proc/remallitem(var/datum/mechanicsMessage/input)
		if(level == 2 || !input) return
		LIGHT_UP_HOUSING
		signals.Cut()
		current_index = 1
		tooltip_rebuild = 1
		if(announce)
			componentSay("Removed all signals.")
		return

	proc/additem(var/datum/mechanicsMessage/input)
		if(level == 2 || !input) return
		LIGHT_UP_HOUSING
		if(allowDuplicates)
			signals.Add(input.signal)
			signals[input.signal] = 1
			tooltip_rebuild = 1
			if(announce)
				componentSay("Added: [input.signal]")

		else
			if(!signals[input.signal])
				signals.Add(input.signal)
				signals[input.signal] = 1
				tooltip_rebuild = 1
				if(announce)
					componentSay("Added: [input.signal]")
			else if(announce)
				componentSay("Duplicate entry - rejected: [input.signal]")

	proc/sendRand(var/datum/mechanicsMessage/input)
		if(level == 2 || !input) return
		LIGHT_UP_HOUSING
		var/orig = random
		random = 1
		sendCurrent(input)
		random = orig
		return

	proc/sendCurrent(var/datum/mechanicsMessage/input)
		if(level == 2 || !input) return 0
		LIGHT_UP_HOUSING
		if(random)
			input.signal = pick(signals)
		else if(!current_index || current_index > length(signals) || !length(signals))
			return
		else
			input.signal = signals[current_index]

		SPAWN(0)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		return

	proc/next(var/datum/mechanicsMessage/input)
		if(level == 2 || !length(signals)) return 0
		LIGHT_UP_HOUSING
		if(++current_index > length(signals))
			current_index = 1
		tooltip_rebuild = 1
		if(announce)
			componentSay("Current Selection : [signals[current_index]]")
		return 1

	proc/nextplus(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(next(input))
			sendCurrent(input)
		return

	proc/previous(var/datum/mechanicsMessage/input)
		if(level == 2 || !length(signals)) return 0
		LIGHT_UP_HOUSING
		if(--current_index < 1)
			current_index = length(signals)
		tooltip_rebuild = 1
		if(announce)
			componentSay("Current Selection : [signals[current_index]]")
		return 1

	proc/previousplus(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(previous(input))
			sendCurrent(input)
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_selector"
		return

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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", .proc/activate)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate and send", .proc/activateplus)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"deactivate", .proc/deactivate)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"deactivate and send", .proc/deactivateplus)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", .proc/toggle)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle and send", .proc/toggleplus)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send", .proc/send)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set On-Signal",.proc/setOnSignal)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Off-Signal",.proc/setOffSignal)

	proc/setOnSignal(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Signal:","Signal setting",signal_on) as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(inp))
			inp = adminscrub(inp)
			signal_on = inp
			boutput(user, "On-Signal set to [inp]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/setOffSignal(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Signal:","Signal setting",signal_off) as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(inp))
			inp = adminscrub(inp)
			signal_off = inp
			boutput(user, "Off-Signal set to [inp]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/activate(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		on = 1
		tooltip_rebuild = 1
		return

	proc/activateplus(var/datum/mechanicsMessage/input)
		if(level == 2) return
		activate()
		send(input)
		return

	proc/deactivate(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		on = 0
		tooltip_rebuild = 1
		return

	proc/deactivateplus(var/datum/mechanicsMessage/input)
		if(level == 2) return
		deactivate()
		send(input)
		return

	proc/toggle(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		on = !on
		tooltip_rebuild = 1
		return

	proc/toggleplus(var/datum/mechanicsMessage/input)
		if(level == 2) return
		toggle()
		send(input)
		return

	proc/send(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		input.signal = (on ? signal_on : signal_off)
		SPAWN(0)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_toggle[on ? "1":""]"
		return

/obj/item/mechanics/telecomp
	name = "Teleport Component"
	desc = ""
	icon_state = "comp_tele"
	cabinet_banned = true // potentially abusable. b&
	var/teleID = "tele1"
	var/send_only = 0
	var/image/telelight

	get_desc()
		. += {"<br><span class='notice'>Current ID: [teleID].<br>
		Send only Mode: [send_only ? "On":"Off"].</span>"}

	New()
		..()
		START_TRACKING
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", .proc/activate)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"setID", .proc/setidmsg)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Teleporter ID",.proc/setID)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Send-only Mode",.proc/toggleSendOnly)
		telelight = image('icons/misc/mechanicsExpansion.dmi', icon_state="telelight")
		telelight.plane = PLANE_SELFILLUM
		telelight.alpha = 180

	disposing()
		STOP_TRACKING
		return ..()

	proc/setID(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter ID:","ID setting",teleID) as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(inp))
			inp = adminscrub(inp)
			teleID = inp
			boutput(user, "ID set to [inp]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/toggleSendOnly(obj/item/W as obj, mob/user as mob)
		send_only = !send_only
		if(send_only)
			src.UpdateOverlays(image('icons/misc/mechanicsExpansion.dmi', icon_state = "comp_teleoverlay"), "sendonly")
		else
			src.UpdateOverlays(null, "sendonly")
		boutput(user, "Send-only Mode now [send_only ? "on":"off"]")
		tooltip_rebuild = 1
		return 1

	proc/setidmsg(var/datum/mechanicsMessage/input)
		if(level == 1 && input.signal)
			LIGHT_UP_HOUSING
			teleID = input.signal
			tooltip_rebuild = 1
			componentSay("ID Changed to : [input.signal]")
		return

	proc/activate(var/datum/mechanicsMessage/input)
		if(level == 2 || ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time)) return
		LIGHT_UP_HOUSING
		flick("[under_floor ? "u":""]comp_tele1", src)
		particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(get_turf(src.loc))).Run()
		playsound(src.loc, 'sound/mksounds/boost.ogg', 50, 1)
		var/list/destinations = new/list()

		for_by_tcl(T, /obj/item/mechanics/telecomp)
			if(T == src || T.level == 2 || !isturf(T.loc)  || isrestrictedz(T.z)|| T.send_only) continue

#ifdef UNDERWATER_MAP
			if (!(T.z == 5 && src.z == 1) && !(T.z == 1 && src.z == 5)) //underwater : allow TP to/from trench
				if(T.z != src.z) continue
#else
			if (T.z != src.z) continue
#endif

			if (T.teleID == src.teleID)
				destinations.Add(T)

		if(length(destinations))
			var/atom/picked = pick(destinations)
			var/count_sent = 0
			particleMaster.SpawnSystem(new /datum/particleSystem/tpbeamdown(get_turf(picked.loc))).Run()
			for(var/atom/movable/M in src.loc)
				if(M == src || M.invisibility || M.anchored) continue
				logTheThing(LOG_COMBAT, M, "entered [src] at [log_loc(src)] and teleported to [log_loc(picked)]")
				M.set_loc(get_turf(picked.loc))
				count_sent++
			input.signal = count_sent
			SPAWN(0)
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
				SEND_SIGNAL(picked,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_tele"
		if(src.level == 1)
			src.UpdateOverlays(telelight, "telelight")
		else
			src.UpdateOverlays(null, "telelight")
		return

/obj/item/mechanics/ledcomp
	name = "LED Component"
	desc = ""
	icon_state = "comp_led"
	var/light_level = 2
	var/active = 0
	var/selcolor = "#FFFFFF"
	var/datum/light/light
	color = "#AAAAAA"

	get_desc()
		. += "<br><span class='notice'>Current Color: [selcolor].</span>"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", .proc/toggle)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", .proc/turnon)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"deactivate", .proc/turnoff)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set rgb", .proc/setrgb)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Color",.proc/setColor)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Range",.proc/setRange)

		light = new /datum/light/point
		light.attach(src)

	proc/setColor(obj/item/W as obj, mob/user as mob)
		var/red = input(user,"Red Color(0.0 - 1.0):","Color setting", 1.0) as num
		var/green = input(user,"Green Color(0.0 - 1.0):","Color setting", 1.0) as num
		var/blue = input(user,"Blue Color(0.0 - 1.0):","Color setting", 1.0) as num
		if(!in_interact_range(src, user) || user.stat)
			return 0
		red = clamp(red, 0.0, 1.0)
		green = clamp(green, 0.0, 1.0)
		blue = clamp(blue, 0.0, 1.0)
		selcolor = rgb(red * 255, green * 255, blue * 255)
		tooltip_rebuild = 1
		light.set_color(red, green, blue)
		return 1

	proc/setRange(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Range(1 - 7):","Range setting", light_level) as num
		if(!in_interact_range(src, user) || user.stat)
			return 0
		inp = clamp(round(inp), 1, 7)
		light.set_brightness(inp / 7)
		boutput(user, "Range set to [inp]")
		return 1

	pickup()
		active = 0
		light.disable()
		src.color = "#AAAAAA"
		return ..()

	proc/setrgb(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		if(length(input.signal) == 7 && copytext(input.signal, 1, 2) == "#")
			if(active)
				color = input.signal
			selcolor = input.signal
			tooltip_rebuild = 1
			SPAWN(0) light.set_color(GetRedPart(selcolor) / 255, GetGreenPart(selcolor) / 255, GetBluePart(selcolor) / 255)

	proc/turnon(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		active = 1
		light.enable()
		src.color = selcolor
		return

	proc/turnoff(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		active = 0
		light.disable()
		src.color = "#AAAAAA"
		return

	proc/toggle(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		if(active)
			turnoff(input)
		else
			turnon(input)
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_led"
		return

/obj/item/mechanics/miccomp
	name = "Microphone Component"
	desc = ""
	icon_state = "comp_mic"
	var/add_sender = 0

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Show-Source",.proc/toggleSender)

	proc/toggleSender(obj/item/W as obj, mob/user as mob)
		add_sender = !add_sender
		boutput(user, "Show-Source now [add_sender ? "on":"off"]")
		return 1

	hear_talk(mob/M as mob, msg, real_name, lang_id)
		if(level == 2) return
		LIGHT_UP_HOUSING
		var/message = msg[2]
		if(lang_id in list("english", ""))
			message = msg[1]
		message = strip_html(html_decode(message), no_fucking_autoparse = TRUE)
		var/heardname = M.name
		if(real_name)
			heardname = real_name
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,add_sender ? "[heardname] : [message]":"[message]")
		animate_flash_color_fill(src,"#00FF00",2, 2)
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_mic"
		return

/obj/item/mechanics/radioscanner
	name = "Radio Scanner Component"
	desc = ""
	icon_state = "comp_radioscanner"

	var/frequency = R_FREQ_DEFAULT

	get_desc()
		. += "<br><span style=\"color:blue\">Current Frequency: [frequency]</span>"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set frequency", .proc/setfreq)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Frequency",.proc/setFreqMan)
		MAKE_DEFAULT_RADIO_PACKET_COMPONENT("main", frequency)

	proc/setFreqMan(obj/item/W as obj, mob/user as mob)
		var/inp = input(user, "New frequency ([R_FREQ_MINIMUM] - [R_FREQ_MAXIMUM]):", "Enter new frequency", frequency) as num
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(!isnull(inp))
			set_frequency(inp)
			boutput(user, "Frequency set to [frequency]")
			return 1
		return 0

	proc/setfreq(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		var/newfreq = text2num_safe(input.signal)
		if (!newfreq) return
		set_frequency(newfreq)

	proc/set_frequency(new_frequency)
		if (!radio_controller) return
		new_frequency = sanitize_frequency(new_frequency)
		componentSay("New frequency: [new_frequency]")
		frequency = new_frequency
		get_radio_connection_by_id(src, "main").update_frequency(frequency)
		tooltip_rebuild = 1
	proc/hear_radio(atom/movable/AM, msg, lang_id)
		if (level == 2) return
		LIGHT_UP_HOUSING
		var/message = msg[2]
		if (lang_id in list("english", ""))
			message = msg[1]
		message = strip_html_tags(html_decode(message))
		var/heardname = null
		if (isobj(AM))
			heardname = AM.name
		else if (ismob(AM))
			heardname = AM:real_name
			if (ishuman(AM))
				var/mob/living/carbon/human/H = AM
				if (H.wear_mask && H.wear_mask.vchange)
					if (istype(H.wear_id, /obj/item/card/id))
						var/obj/item/card/id/ID = H.wear_id
						heardname = ID.registered
					else
						heardname = "Unknown"
				else if (H.vdisfigured)
					heardname = "Unknown"

		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"name=[heardname]&message=[message]")
		animate_flash_color_fill(src,"#00FF00",2, 2)
		return

	update_icon()
		icon_state = "[under_floor ? "u" : ""]comp_radioscanner"
		return

/obj/item/mechanics/synthcomp
	name = "Sound Synthesizer"
	desc = ""
	icon_state = "comp_synth"
	cooldown_time = 2 SECONDS

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input", .proc/fire)

	proc/fire(var/datum/mechanicsMessage/input)
		if(level == 2 || !input) return
		if(ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time)) return
		LIGHT_UP_HOUSING
		componentSay("[input.signal]")
		return

	update_icon()
		icon_state = "comp_synth"
		return

/obj/item/mechanics/trigger/pressureSensor
	name = "Pressure Sensor"
	desc = ""
	icon_state = "comp_pressure"
	var/tmp/limiter = 0
	cabinet_banned = true // non-functional
	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)

	Crossed(atom/movable/AM as mob|obj)
		..()
		if (level == 2 || isobserver(AM) || isintangible(AM))
			return
		if (limiter && (ticker.round_elapsed_ticks < limiter))
			return
		LIGHT_UP_HOUSING
		limiter = ticker.round_elapsed_ticks + 10
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG, null)
		return

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_pressure"
		return

/obj/item/mechanics/trigger/button
	name = "Button"
	desc = "A button. Its red hue entices you to press it."
	icon_state = "comp_button"
	var/icon_up = "comp_button"
	var/icon_down = "comp_button1"
	plane = PLANE_DEFAULT
	density = 1

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)

	attackby(obj/item/W, mob/user)
		if(..(W, user)) return 1
		if(ispulsingtool(W)) return // Don't press the button with a multitool, it brings up the config menu instead
		return attack_hand(user)

	attack_hand(mob/user)
		if(level == 1)
			flick(icon_down, src)
			LIGHT_UP_HOUSING
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG, null)
			logTheThing(LOG_STATION, user, "presses the mechcomp button at [log_loc(src)].")
			return 1
		return ..(user)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && GET_DIST(src, target) == 1)
			if(isturf(target))
				user.drop_item()
				if(isturf(target) && target.density)
					icon_up = "comp_switch"
					icon_down = "comp_switch2"
				else
					icon_up = "comp_button"
					icon_down = "comp_button2"
				icon_state = icon_up
				src.set_loc(target)
		return
	update_icon()
		icon_state = icon_up
		return

/obj/item/mechanics/trigger/buttonPanel
	name = "Button Panel"
	desc = ""
	icon_state = "comp_buttpanel"
	var/icon_up = "comp_buttpanel"
	var/icon_down = "comp_buttpanel1"
	var/list/active_buttons

	get_desc()
		. += "<br><span class='notice'>Buttons:</span>"
		for (var/button in src.active_buttons)
			. += "<br><span class='notice'>Label: [button], Value: [src.active_buttons[button]]</span>"

	New()
		..()
		active_buttons = list()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Add Button",.proc/addButton)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Remove Button",.proc/removeButton)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT, "Add Button", .proc/signalAddButton)

	proc/addButton(obj/item/W as obj, mob/user as mob)
		if(length(src.active_buttons) >= 10)
			boutput(user, "<span class='alert'>There's no room to add another button - the panel is full</span>")
			return 0

		var/new_label = input(user, "Button label", "Button Panel") as text
		var/new_signal = input(user, "Button signal", "Button Panel") as text
		if(!in_interact_range(src, user) || user.stat)
			return 0
		if(length(new_label) && length(new_signal))
			new_label = adminscrub(new_label)
			new_signal = adminscrub(new_signal)
			if(new_label in src.active_buttons)
				boutput(user, "There's already a button with that label.")
				return 0
			src.active_buttons.Add(new_label)
			src.active_buttons[new_label] = new_signal
			boutput(user, "Added button with label: [new_label] and value: [new_signal]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/removeButton(obj/item/W as obj, mob/user as mob)
		if(!length(src.active_buttons))
			boutput(user, "<span class='alert'>[src] has no active buttons - there's nothing to remove!</span>")
		else
			var/to_remove = input(user, "Choose button to remove", "Button Panel") in src.active_buttons + "*CANCEL*"
			if(!in_interact_range(src, user) || user.stat)
				return 0
			if(!to_remove || to_remove == "*CANCEL*")
				return 0
			src.active_buttons.Remove(to_remove)
			boutput(user, "Removed button labeled [to_remove]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/signalAddButton(var/datum/mechanicsMessage/input)
		if(length(src.active_buttons) >= 10)
			return 0

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
				tooltip_rebuild = 1

		return succesfulAddition



	attack_hand(mob/user)
		if (level == 1)
			if (length(src.active_buttons))
				var/selected_button = input(user, "Press a button", "Button Panel") in src.active_buttons + "*CANCEL*"
				if (!selected_button || selected_button == "*CANCEL*" || !in_interact_range(src, user)) return
				LIGHT_UP_HOUSING
				flick(icon_down, src)
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, src.active_buttons[selected_button])
				logTheThing(LOG_STATION, user, "presses the mechcomp button [selected_button] at [log_loc(src)].")
				return 1
			else
				boutput(user, "<span class='alert'>[src] has no active buttons - there's nothing to press!</span>")
		else return ..(user)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && in_interact_range(src, target))
			if(isturf(target))
				user.drop_item()
				src.set_loc(target)
		return

	update_icon()
		icon_state = icon_up
		return


// Updated these things for pixel bullets. Also improved user feedback and added log entries here and there (Convair880).
/obj/item/mechanics/gunholder
	name = "Gun Component"
	desc = ""
	icon_state = "comp_gun"
	density = 0
	can_rotate = 1
	var/obj/item/gun/Gun = null
	var/list/compatible_guns = list(/obj/item/gun/kinetic, /obj/item/gun/flamethrower)
	cabinet_banned = true // non-functional thankfully
	get_desc()
		. += "<br><span class='notice'>Current Gun: [Gun ? "[Gun] [Gun.canshoot() ? "(ready to fire)" : "(out of [istype(Gun, /obj/item/gun/energy) ? "charge)" : "ammo)"]"]" : "None"]</span>"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"fire", .proc/fire)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Remove Gun",.proc/removeGun)

	proc/removeGun(obj/item/W as obj, mob/user as mob)
		if(Gun)
			logTheThing(LOG_STATION, user, "removes [Gun] from [src] at [log_loc(src)].")
			Gun.set_loc(get_turf(src))
			Gun = null
			tooltip_flags &= ~REBUILD_ALWAYS
			return 1
		boutput(user, "<span class='alert'>There is no gun inside this component.</span>")
		return 0

	attackby(obj/item/W, mob/user)
		if(..(W, user)) return 1
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
				return 1
			else
				boutput(user, "There is already a [Gun] inside the [src]")
		else
			user.show_text("The [W.name] isn't compatible with this component.", "red")
		return 0

	proc/getTarget()
		var/atom/trg = get_turf(src)
		for(var/mob/living/L in trg)
			return get_turf(L)
		for(var/i=0, i<7, i++)
			trg = get_step(trg, src.dir)
			for(var/mob/living/L in trg)
				return get_turf(L)
		return get_edge_target_turf(src, src.dir)

	proc/fire(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		if(input && Gun)
			if(Gun.canshoot())
				var/atom/target = getTarget()
				if(target)
					Gun.shoot(target, get_turf(src), src)
			else
				src.visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"The [Gun.name] has no [istype(Gun, /obj/item/gun/energy) ? "charge" : "ammo"] remaining.\"</span>")
				playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
		else
			src.visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"No gun installed.\"</span>")
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
		return

	update_icon()

		icon_state = "comp_gun"
		return

/obj/item/mechanics/gunholder/recharging
	name = "E-Gun Component"
	desc = ""
	icon_state = "comp_gun2"
	density = 0
	compatible_guns = list(/obj/item/gun/energy)
	var/charging = 0

	get_desc()
		. = ..() // Please don't remove this again, thanks.
		. += charging ? "<br><span class='notice'>Component is charging.</span>" : null

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"recharge", .proc/recharge)

	process()
		..()
		if(level == 2)
			if(charging)
				charging = 0
				tooltip_rebuild = 1
			return

		if(!Gun && charging)
			charging = 0
			tooltip_rebuild = 1
			UpdateIcon()

		if(!istype(Gun, /obj/item/gun/energy) || !charging)
			return

		var/obj/item/gun/energy/E = Gun

		// Can't recharge the crossbow. Same as the other recharger.
		if (!(SEND_SIGNAL(E, COMSIG_CELL_CAN_CHARGE) & CELL_CHARGEABLE))
			src.visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"This gun cannot be recharged manually.\"</span>")
			playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
			charging = 0
			tooltip_rebuild = 1
			UpdateIcon()
			return

		else
			if (SEND_SIGNAL(E, COMSIG_CELL_CHARGE, 15) & CELL_FULL) // Same as other recharger.
				src.charging = 0
				tooltip_rebuild = 1
				src.UpdateIcon()
		E.UpdateIcon()
		return

	proc/recharge(var/datum/mechanicsMessage/input)
		if(charging || !Gun || level == 2) return
		if(!istype(Gun, /obj/item/gun/energy)) return
		charging = 1
		tooltip_rebuild = 1
		UpdateIcon()
		return

	fire(var/datum/mechanicsMessage/input)
		if(charging || level == 2) return
		if(ON_COOLDOWN(src, SEND_COOLDOWN_ID, src.cooldown_time)) return
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

	get_desc()
		. += "<br><span class='notice'>Current Instrument: [instrument ? "[instrument]" : "None"]</span>"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"play", .proc/fire)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Remove Instrument",.proc/removeInstrument)

	proc/removeInstrument(obj/item/W as obj, mob/user as mob)
		if(instrument)
			logTheThing(LOG_STATION, user, "removes [instrument] from [src] at [log_loc(src)].")
			instrument.set_loc(get_turf(src))
			instrument = null
			tooltip_rebuild = 1
			return 1
		else
			boutput(user, "<span class='alert'>There is no instrument inside this component.</span>")
		return 0

	attackby(obj/item/W, mob/user)
		if (..(W, user)) return 1
		else if (instrument) // Already got one, chief!
			boutput(user, "There is already \a [instrument] inside the [src].")
			return 0
		else if (istype(W, /obj/item/instrument)) //BLUH these aren't consolidated under any combined type hello elseif chain // i fix - haine
			var/obj/item/instrument/I = W
			instrument = I
			sounds = I.sounds_instrument
			volume = I.volume
			delay = I.note_time
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
			tooltip_rebuild = 1
			return 1
		return 0

	proc/fire(var/datum/mechanicsMessage/input)
		if (level == 2 || GET_COOLDOWN(src, SEND_COOLDOWN_ID) || !instrument) return
		LIGHT_UP_HOUSING
		var/signum = text2num_safe(input.signal)
		var/index = round(signum)
		if (length(sounds) > 1 && index > 0 && index <= length(sounds))
			ON_COOLDOWN(src, SEND_COOLDOWN_ID, delay)
			flick("comp_instrument1", src)
			playsound(get_turf(src), sounds[index], volume, 0)
		else if (signum &&((signum >= 0.1 && signum <= 2) || (signum <= -0.1 && signum >= -2) || pitchUnlocked))
			var/mod_delay = delay
			if(abs(signum) < 1)
				mod_delay /= abs(signum)
			ON_COOLDOWN(src, SEND_COOLDOWN_ID, mod_delay)
			flick("comp_instrument1", src)
			playsound(src, sounds, volume, 0, 0, signum)
		else
			ON_COOLDOWN(src, SEND_COOLDOWN_ID, delay)
			flick("comp_instrument1", src)
			playsound(src, sounds, volume, 1)
			return

	update_icon()
		icon_state = "comp_instrument"
		return

/obj/item/mechanics/math
	name = "Arithmetic Component"
	desc = "Do number things! Component list<br/>rng: Generates a random number from A to B<br/>add: Adds A + B<br/>sub: Subtracts A - B<br/>mul: Multiplies A * B<br/>div: Divides A / B<br/>pow: Power of A ^ B<br/>mod: Modulos A % B<br/>eq|neq|gt|lt|gte|lte: Equal/NotEqual/GreaterThan/LessThan/GreaterEqual/LessEqual -- will output 1 if true. Example: A GT B = 1 if A is larger than B"
	icon_state = "comp_arith"
	var/A = 1
	var/B = 1

	var/mode = "rng"
	get_desc()
		. = ..() // Please don't remove this again, thanks.
		. += "<br><span class='notice'>Current Mode: [mode] | A = [A] | B = [B]</span>"
	secure()
		icon_state = "comp_arith1"
	loosen()
		icon_state = "comp_arith"
	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set A", .proc/setA)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set B", .proc/setB)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Evaluate", .proc/evaluate)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set A",.proc/setAManually)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set B",.proc/setBManually)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Mode",.proc/setMode)

	proc/setAManually(obj/item/W as obj, mob/user as mob)
		var/input = input("Set A to what?", "A", A) as num
		if(!in_interact_range(src, user) || user.stat || isnull(input))
			return 0
		A = input
		tooltip_rebuild = 1
		return 1

	proc/setBManually(obj/item/W as obj, mob/user as mob)
		var/input = input("Set B to what?", "B", B) as num
		if(!in_interact_range(src, user) || user.stat || isnull(input))
			return 0
		B = input
		tooltip_rebuild = 1
		return 1

	proc/setMode(obj/item/W as obj, mob/user as mob)
		mode = input("Set the math mode to what?", "Mode Selector", mode) in list("add","mul","div","sub","mod","pow","rng","eq","neq","gt","lt","gte","lte")
		tooltip_rebuild = 1
		return 1

	proc/setA(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		if (!isnull(text2num_safe(input.signal)))
			A = text2num_safe(input.signal)
			tooltip_rebuild = 1
	proc/setB(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		if (!isnull(text2num_safe(input.signal)))
			B = text2num_safe(input.signal)
			tooltip_rebuild = 1
	proc/evaluate()
		switch(mode)
			if("add")
				. = A + B
			if("sub")
				. = A - B
			if("div")
				if (B == 0)
					src.visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"Attempted division by zero!\"</span>")
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
			else
				return
		if(. == .)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"[.]")

/obj/item/mechanics/association
	name = "Association Component"
	desc = ""
	icon_state = "comp_ass"
	var/list/map
	var/mode = 0 // 0=Mutable, 1=Immutable, 2=List

	New()
		..()
		map = list()
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "add association(s)", .proc/addItems)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "remove association", .proc/removeItem)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "send value", .proc/sendValue)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set mode", .proc/setMode)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "add association", .proc/addItemManual)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "remove association", .proc/removeItemManual)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "view all associations", .proc/getMapAsString)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "clear all associations", .proc/clear)

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
		if (map.len > 10)
			mapLines.Add("Use a multitool to view all associations")
		return length(mapLines) ? mapLines.Join("<br>") : ""

	proc/getMapAsString(obj/item/W as obj, mob/user as mob)
		var/list/mapLines = new/list()
		for (var/key in map)
			mapLines.Add("[key]: [map[key]]")
		boutput(user, "[length(mapLines) ? mapLines.Join("<br>") : ""]")

	proc/addItems(var/datum/mechanicsMessage/input)
		if (level == 2 || !input) return
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
			tooltip_rebuild = 1

	proc/removeItem(var/datum/mechanicsMessage/input)
		if (level == 2 || !input) return
		LIGHT_UP_HOUSING
		if (isnull(map[input.signal])) return
		map.Remove(input.signal)
		animate_flash_color_fill(src,"#00FF00",2, 2)
		tooltip_rebuild = 1

	proc/sendValue(var/datum/mechanicsMessage/input)
		if (level == 2 || !input) return
		LIGHT_UP_HOUSING
		if (isnull(map[input.signal])) return
		input.signal = map[input.signal]
		SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_MSG, input)
		animate_flash_color_fill(src,"#00FF00",2, 2)

	proc/setMode(obj/item/W as obj, mob/user as mob)
		var/input = input(user, "Set mode", "Association Component") in list("Mutable", "Immutable", "List", "*CANCEL*")
		if (!in_interact_range(src, user) || user.stat) return 0
		if (!input || input == "*CANCEL*") return 0
		mode = input == "Mutable" ? 0 : input == "Immutable" ? 1 : 2
		boutput(user, "Mode set to [input]")
		tooltip_rebuild = 1
		return 1

	proc/addItemManual(obj/item/W as obj, mob/user as mob)
		var/inputKey = input(user, "Add key", "Association Component") as text
		if (isnull(inputKey)) return 0
		var/inputValue = input(user, "Add value", "Association Component") as text
		if (isnull(inputKey)) return 0
		if (!in_interact_range(src, user) || user.stat) return 0
		if (mode == 0) // Mutable
			if (isnull(map[inputKey])) map.Add(inputKey)
			map[inputKey] = inputValue
		else if (mode == 1) // Immutable
			if (!isnull(map[inputKey]))
				boutput(user, "IMMUTABLE MODE ERROR: An association already exists for that key")
				return 0
			map.Add(inputKey)
			map[inputKey] = inputValue
		else // List
			if (isnull(map[inputKey]))
				map.Add(inputKey)
				map[inputKey] = inputValue
			else
				map[inputKey] = "[map[inputKey]],[inputValue]"
		boutput(user, "Set value of [inputKey] to [map[inputKey]]")
		tooltip_rebuild = 1
		return 1

	proc/removeItemManual(obj/item/W as obj, mob/user as mob)
		if (!length(map))
			boutput(user, "<span class='alert'>[src] has no associations - there's nothing to remove!</span>")
			return 0
		var/input = input(user, "Remove association", "Association Component") in map + "*CANCEL*"
		if (!in_interact_range(src, user) || user.stat) return 0
		if (!input || input == "*CANCEL*") return 0
		var/removedValue = map[input]
		map.Remove(input)
		boutput(user, "Removed key [input] and value [removedValue]")
		tooltip_rebuild = 1
		return 1

	proc/clear(obj/item/W as obj, mob/user as mob)
		map.Cut()
		boutput(user, "Associations map cleared")
		return 1

	update_icon()
		icon_state = "[under_floor ? "u" : ""]comp_ass"
		return

/obj/mecharrow
	name = ""
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "connectionArrow"


/obj/item/mechanics/screen
	name = "Letter Display Component"
	desc = ""
	icon_state = "comp_screen"
	cabinet_banned = true

	var/letter_index = 1
	var/display_letter = null

	get_desc()
		. = ..()
		. += "<br><span class='notice'>Letter Index: [src.letter_index]"
		if (src.level == 2 || src.display_letter != null)
			. += " | Currently Displaying: '[src.display_letter]'"
		. += "</span>"

	secure()
		src.display(" ")

	loosen()
		src.display_letter = null
		src.icon_state = "comp_screen"
	New()
		..()
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "set letter index", .proc/setLetterIndex)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "input", .proc/fire)

	proc/setLetterIndex(obj/item/W as obj, mob/user as mob)
		var/input = input("Which letter from the input string to take? (1-indexed)", "Letter Index", letter_index) as num
		if (!in_interact_range(src, user) || user.stat || isnull(input))
			return FALSE
		if (letter_index < 1)
			return FALSE
		letter_index = input
		tooltip_rebuild = TRUE
		. = TRUE

	proc/fire(var/datum/mechanicsMessage/input)
		if(level == 2 || !input) return
		var/signal = input.signal
		if (length(signal) < src.letter_index)
			src.display(" ") // If the string is shorter than we expect, fill excess screens with spaces
			return
		var/letter = copytext(signal, src.letter_index, src.letter_index + 1)
		src.display(letter)

	proc/display(var/letter as text)
		letter = uppertext(letter)
		switch(letter)
			if (" ") src.setDisplayState(" ", "comp_screen_blank")
			if ("!") src.setDisplayState("!", "comp_screen_exclamation_mark")
			else
				var/ascii = text2ascii(letter)
				if((ascii >= text2ascii("A") && ascii <= text2ascii("Z")) || (ascii >= text2ascii("0") && ascii <= text2ascii("9")))
					src.setDisplayState(letter, "comp_screen_[letter]")
				else
					src.setDisplayState("?", "comp_screen_question_mark") // Any unknown characters should display as ? instead.

	proc/setDisplayState(var/new_letter as text, var/new_icon_state as text)
		src.display_letter = new_letter
		src.icon_state = new_icon_state

/// allows cabinets to move around
/obj/item/mechanics/movement
	name = "Movement Component"
	desc = "Allows a cabinet to move around."
	icon_state = "comp_move"
	cooldown_time = 1 SECOND
	cabinet_only = TRUE
	one_per_tile = TRUE
	var/move_lag = BASE_SPEED

	New()
		..()
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "walk", .proc/do_walk)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_INPUT, "step", .proc/do_step)
		SEND_SIGNAL(src, COMSIG_MECHCOMP_ADD_CONFIG, "Set walk delay", .proc/set_speed)

	secure()
		src.loc.AddComponent(/datum/component/legs/six)

	loosen()
		var/datum/component/C = src.loc.GetComponent(/datum/component/legs/six)
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
		if (direction == null)
			direction = dirname_to_dir(input.signal)
		if (direction == null)
			return
		var/obj/item/storage/S = src.loc
		if (!istype(S))
			return
		if (S.anchored)
			return
		set_glide_size()
		walk(S, direction, move_lag, (32 / move_lag) * world.tick_lag)
		set_glide_size()
		if (direction == 0)
			UnregisterSignal(S, COMSIG_MOVABLE_MOVED)
		else
			RegisterSignal(S, COMSIG_MOVABLE_MOVED, .proc/set_glide_size, TRUE)

	proc/do_step(var/datum/mechanicsMessage/input)
		if (ON_COOLDOWN(src, "movement_delay", move_lag))
			return
		var/direction = text2num_safe(input.signal)
		if (!direction)
			direction = dirname_to_dir(input.signal)
		if (!direction)
			return
		var/obj/item/storage/S = src.loc
		if (!istype(S))
			return
		if (S.anchored)
			return
		set_glide_size()
		step(S, direction, (32 / move_lag) * world.tick_lag)
		set_glide_size()
		if (direction == 0)
			UnregisterSignal(S, COMSIG_MOVABLE_MOVED)
		else
			RegisterSignal(S, COMSIG_MOVABLE_MOVED, .proc/set_glide_size, TRUE)

	proc/set_glide_size()
		var/obj/item/storage/S = src.loc
		if (!istype(S))
			return
		S.glide_size = (32 / move_lag) * world.tick_lag

	proc/stop_moving()
		var/obj/item/storage/S = src.loc
		if (!istype(S))
			return
		walk(S, 0)
		UnregisterSignal(S, COMSIG_MOVABLE_MOVED)

	proc/set_speed(obj/item/W as obj, mob/user as mob)
		// as fast as humans, but they can't sprint
		var/inp = input(user,"Please enter movement delay, lower is faster ([BASE_SPEED] - 20)", "Movement delay", src.move_lag) as num
		if(!in_interact_range(src, user) || !isalive(user))
			return 0
		inp = clamp(inp, BASE_SPEED, 20)
		move_lag = inp
		boutput(user, "You set the movement delay set to [inp].")
		return 1

	update_icon()
		icon_state = "[under_floor ? "u":""]comp_move"

#undef IN_CABINET
#undef LIGHT_UP_HOUSING
