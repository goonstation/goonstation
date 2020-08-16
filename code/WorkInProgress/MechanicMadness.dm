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
#define LIGHT_UP_HOUSING SPAWN_DBG(0) src.light_up_housing()
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
	var/datum/light/point/light
	var/open=true
	var/welded=false
	var/can_be_welded=false
	var/can_be_anchored=false
	custom_suicide=true
	New()
		..()
		src.light = new /datum/light/point
		src.light.attach(src)
		src.light.set_color(1,0,1)
		if (!(src in processing_items))
			processing_items.Add(src)

	hear_talk(mob/M as mob, msg, real_name, lang_id) // hack to make microphones work
		for(var/obj/item/mechanics/miccomp/mic in src.contents)
			mic.hear_talk(M,msg,real_name,lang_id)
		return
	process()
		if (src.light_time>0)
			src.light_time--
			src.updateIcon()
			return
		if(src.light.enabled) // bluh
			src.updateIcon()
			return
		return
	proc/light_up()
		var/orig_light_time
		src.light_time+=CONTAINER_LIGHT_TIME
		src.light_time%=MAX_CONTAINER_LIGHT_TIME
		if(!orig_light_time)
			src.updateIcon()
		return
	ex_act(severity)
		switch(severity)
			if (1.0)
				src.dispose() // disposing upon being blown up unlike all those decorative rocks on cog2
				return
			if (2.0)
				if(prob(25))
					src.dispose()
					return
				src.open=true
				src.welded=false
				src.updateIcon()
				return
			if (3.0)
				if(prob(50) && !src.welded)
					src.open=true
					src.updateIcon()
				return
		return
	suicide(var/mob/user as mob) // lel
		if (!src.user_can_suicide(user))
			return 0
		user.visible_message("<span class='alert'><b>[user] stares into the [src], trying to make sense of its function!</b></span>")
		SPAWN_DBG(3 SECONDS)
			user.visible_message("<span class='alert'><b>[user]'s brain melts!</b></span>")
			playsound(get_turf(user), "sound/weapons/phaseroverload.ogg", 100)
			user.take_brain_damage(69*420)
		SPAWN_DBG(20 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		return
	attack_self(mob/user as mob)
		if(!(usr in src.users) && istype(user))
			src.users+=usr
		return ..()
	attack_hand(mob/user as mob)
		if(!(usr in src.users) && istype(user))
			src.users+=usr
		return ..()

	attackby(obj/item/W as obj, mob/user as mob)
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
			src.updateIcon()
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
				src.updateIcon()
				return 1
		else if (src.open || !istype(W,/obj/item/mechanics))
			..()
			src.updateIcon()
		return 1
	proc
		updateIcon()
			if(src.welded)
				src.icon_state=initial(src.icon_state)+"_w"
			else if(src.open)
				// ugly warning, the istype() is 1 when there's a trigger in the container\
				//	it subtracts 1 from the list of contents when there's a trigger \
				//	doing arithmatic on bools is probably not good!
				var/has_trigger = istype(locate(/obj/item/mechanics/trigger/trigger) in src.contents,/obj/item/mechanics/trigger/trigger)
				var/len_contents = src.contents.len - has_trigger
				if(src.num_f_icons && len_contents)
					src.icon_state=initial(src.icon_state)+"_f[min(src.num_f_icons-1,round((len_contents*src.num_f_icons)/(src.slots-has_trigger)))]"
				else
					src.icon_state=initial(src.icon_state)
			else
				src.icon_state=initial(src.icon_state)+"_closed"
			if(src.light_time>0)
				src.icon_state+="_e"
				if(!src.light.enabled)
					src.light.enable()
			else if (src.light.enabled)
				src.light.disable()
			return
		close_storage_menus() // still ugly but probably quite better performing
			for(var/mob/chump in src.users)
				for(var/datum/hud/storage/hud in chump.huds)
					if(hud.master==src) hud.close.clicked()
			src.users = list() // gee golly i hope garbage collection does its job
			return 1
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
	MouseDrop(atom/target)
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
		name="Component Cabinet" // i tried to replace "23" below with "[CABINET_CAPACITY]", but byond \
									 // thinks it's not a constant and refuses to work with it.
		desc="A rather chunky cabinet for storing up to 23 active mechanic components\
		 at once.<br>It can only be connected to external components when bolted to the floor.<br>"
		w_class = 4.0 //all the weight
		num_f_icons=3
		density=1
		anchored=false
		icon_state="housing_cabinet"
		flags = FPRINT | EXTRADELAY | CONDUCT
		attack_hand(mob/user as mob)
			if(src.loc==user)
				src.set_loc(get_turf(src))
				user.drop_item()
				return
			return MouseDrop(user)
		New()
			..()
			src.light.set_color(0,0.7,1)
		attack_self(mob/user as mob)
			src.set_loc(get_turf(user))
			user.drop_item()
			return
		MouseDrop(atom/target)
		// thanks, whoever hardcoded that pick-up action into obj/item/MouseDrop()!
			if(istype(target,/obj/screen/hud))
				return
			if(target.loc!=get_turf(target) && !isturf(target)) //return if dragged onto an item in another object (i.e backpacks on players)
				return // you used to be able to pick up cabinets by dragging them to your backpack
			return ..()
	housing_handheld
		var/obj/item/mechanics/trigger/trigger/the_trigger
		slots=HANDHELD_CAPACITY + 1 // One slot used by the permanent button
		name="Device Frame"
		desc="A massively shrunken component cabinet fitted with a handle and an external\
		 button. Due to the average mechanic's low arm strength, it only holds 6 components." // same as above\
		 												if you change the capacity, remember to manually update this string
		w_class = 3.0 // fits in backpacks but not pockets. no quickdraw honk boxess
		density=0
		anchored=0
		num_f_icons=1
		icon_state="housing_handheld"
		flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT | ONBELT
		New()
			..()
			src.light.set_color(0.2,0,0)
		spawn_contents=list(/obj/item/mechanics/trigger/trigger)
		proc/find_trigger() // find the trigger comp, return 1 if found.
			if (!istype(src.the_trigger))
				src.the_trigger = (locate(/obj/item/mechanics/trigger/trigger) in src.contents)
				if (!istype(src.the_trigger)) //no trigger?
					for(var/obj/item in src.contents)
						item.loc=get_turf(src) // kick out any mechcomp
					qdel(src) // delet
					return false
			return true
		attack_self(mob/user as mob)
			if(src.open)
				if(!(usr in src.users))
					src.users+=usr
				return ..() // you can just use the trigger manually from the UI
			if(src.find_trigger() && !src.open && src.loc==user)
				return src.the_trigger.attack_hand(user)
			return
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
	w_class = 4
	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
	attackby(obj/item/W as obj, mob/user as mob)
		if(iswrenchingtool(W)) // prevent unanchoring
			return 0
		if(..()) return 1
		return 1 //attack_hand(user) // was causing issues

	attack_hand(mob/user as mob)
		..()
		if (!istype(src.loc,/obj/item/storage/mechanics/housing_handheld))
			qdel(src) //if outside the gun, delet
			return
		if(level == 1)
			src.icon_state=icon_down
			SPAWN_DBG(1 SECOND)
				src.updateIcon()
			LIGHT_UP_HOUSING
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG)
			playsound(get_turf(src),'sound/machines/keypress.ogg',30)
		else
			qdel(src) // it's somehow been unanchored or something, kill it
		return
	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		qdel(src)// never should be outside of the gun (in someone's hands), so kill it
		return
	updateIcon()
		icon_state = icon_up
		return

// Put these into Mechanic's locker
/obj/item/electronics/frame/mech_cabinet
	name = "Component Cabinet frame"
	store_type = /obj/item/storage/mechanics/housing_large
	viewstat = 2
	secured = 2
	icon_state = "dbox"


//Global list of telepads so we don't have to loop through the entire world aaaahhh.
var/list/mechanics_telepads = new/list()

/obj/item/mechanics
	name = "testhing"
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "comp_unk"
	item_state = "swat_suit"
	flags = FPRINT | EXTRADELAY | TABLEPASS | CONDUCT
	w_class = 1.0
	level = 2
	var/cabinet_banned = false // whether or not this component is prevented from being anchored in cabinets
	var/under_floor = 0
	var/can_rotate = 0
	var/cooldown_time = 3 SECONDS
	var/when_next_ready = 0
	var/list/particles

	New()
		particles = new/list()
		AddComponent(/datum/component/mechanics_holder)
		if (!(src in processing_items))
			processing_items.Add(src)
		return ..()


	disposing()
		processing_items.Remove(src)
		..()


	proc

		cutParticles()
			if(length(particles))
				for(var/datum/particleSystem/mechanic/M in particles)
					M.Die()
				particles.Cut()
			return
		light_up_housing( ) // are we in a housing? if so, tell it to light up
			var/obj/item/storage/mechanics/the_container = src.loc
			if(istype(the_container,/obj/item/storage/mechanics)) // wew lad i hope this compiles
				the_container.light_up()
			return

	process()
		if(level == 2 || under_floor)
			cutParticles()
			return
		var/pointer_container[1] //A list of size 1, to store the address of the list we want
		SEND_SIGNAL(src, _COMSIG_MECHCOMP_GET_OUTGOING, pointer_container)
		var/list/connected_outgoing = pointer_container[1]
		if(length(particles) != length(connected_outgoing))
			cutParticles()
			for(var/atom/X in connected_outgoing)
				particles.Add(particleMaster.SpawnSystem(new /datum/particleSystem/mechanic(src.loc, X.loc)))

		return

	attack_hand(mob/user as mob)
		if(level == 1) return
		if(issilicon(user) || isAI(user)) return
		else return ..(user)

	attack_ai(mob/user as mob)
		return src.attack_hand(user)
	proc/secure()
	proc/loosen()

	proc/rotate()
		src.dir = turn(src.dir, -90)

	attackby(obj/item/W as obj, mob/user as mob)
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
					logTheThing("station", usr, null, "detaches a <b>[src]</b> from the [istype(src.loc,/obj/item/storage/mechanics) ? "housing" : "underfloor"] and deactivates it at [log_loc(src)].")
					level = 2
					anchored = 0
					loosen()
				if(2) //Level 2 = loose
					if(!isturf(src.loc) && !(IN_CABINET)) // allow items to be deployed inside housings, but not in other stuff like toolboxes
						boutput(usr, "<span class='alert'>[src] needs to be on the ground  [src.cabinet_banned ? "" : "or in a component housing"] for that to work.</span>")
						return 0
					if(IN_CABINET && src.cabinet_banned)
						boutput(usr,"<span class='alert'>[src] is not allowed in component housings.</span>")
						return
					boutput(user, "You attach the [src] to the [istype(src.loc,/obj/item/storage/mechanics) ? "housing" : "underfloor"] and activate it.")
					logTheThing("station", usr, null, "attaches a <b>[src]</b> to the [istype(src.loc,/obj/item/storage/mechanics) ? "housing" : "underfloor"]  at [log_loc(src)].")
					level = 1
					anchored = 1
					secure()

			var/turf/T = src.loc
			if(isturf(T))
				hide(T.intact)
			else
				hide()

			SEND_SIGNAL(src,COMSIG_MECHCOMP_RM_ALL_CONNECTIONS)
			return 1
		return SEND_SIGNAL(src,COMSIG_ATTACKBY,W,user) & COMSIGBIT_ATTACKBY_COMPLETE ? 1 : 0

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

	MouseDrop(obj/O, null, var/src_location, var/control_orig, var/control_new, var/params)
		if(level == 2 || (istype(O, /obj/item/mechanics) && O.level == 2))
			boutput(usr, "<span class='alert'>Both components need to be secured into place before they can be connected.</span>")
			return ..()

		SEND_SIGNAL(src,_COMSIG_MECHCOMP_DROPCONNECT,O,usr)
		return

	proc/componentSay(var/string)
		string = trim(sanitize(html_encode(string)), 1)
		for(var/mob/O in all_hearers(7, src.loc))
			O.show_message("<span class='game radio'><span class='name'>[src]</span><b> [bicon(src)] [pick("squawks", "beeps", "boops", "says", "screeches")], </b> <span class='message'>\"[string]\"</span></span>",2)

	hide(var/intact)
		under_floor = (intact && level==1)
		updateIcon()
		return

	proc/isReady()
		return src.when_next_ready <= world.time

	proc/unReady(var/unReadyTime = null)
		if(isnull(unReadyTime))
			unReadyTime = src.cooldown_time
		src.when_next_ready = world.time + unReadyTime
		return

	proc/updateIcon()
		return

/obj/item/mechanics/cashmoney
	name = "Payment component"
	desc = ""
	icon_state = "comp_money"
	density = 0
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"eject money", "emoney")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Price","setPrice")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Code","setCode")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Thank-String","setThank")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Eject Money","checkEjectMoney")

	proc/emoney(var/datum/mechanicsMessage/input)
		if(level == 2 || !input) return
		if(input.signal == code)
			ejectmoney()
		return

	proc/setPrice(obj/item/W as obj, mob/user as mob)
		if (code)
			var/codecheck = strip_html(input(user,"Please enter current code:","Code check","") as text)
			if (codecheck != code)
				boutput(user, "<span class='alert'>[bicon(src)]: Incorrect code entered.</span>")
				return 0
		var/inp = input(user,"Enter new price:","Price setting", price) as num
		if(!in_range(src, user) || user.stat)
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
		if(!in_range(src, user) || user.stat)
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
			var/codecheck = strip_html(input(user,"Please enter current code:","Code check","") as text)
			if(!in_range(src, user) || user.stat)
				return 0
			if (codecheck != code)
				boutput(user, "<span class='alert'>[bicon(src)]: Incorrect code entered.</span>")
				return 0
		ejectmoney()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return 1
		if (istype(W, /obj/item/spacecash) && isReady())
			LIGHT_UP_HOUSING
			unReady()
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

				usr.drop_item()
				pool(W)

				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG, null)
				flick("comp_money1", src)

				unReady(0)//Make it ready now.
				return 1
		return 0


	proc/ejectmoney()
		if (collected)
			var/obj/item/spacecash/S = unpool(/obj/item/spacecash)
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

	New()
		. = ..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"flush", "flushp")

	disposing()
		if(air_contents)
			pool(air_contents)
			air_contents = null
		trunk = null
		..()

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user))
			if(src.level == 1) //wrenched down
				trunk = locate() in src.loc
				if(trunk)
					trunk.linked = src
					air_contents = unpool(/datum/gas_mixture)
			else if (src.level == 2) //loose
				if (trunk) //ZeWaka: Fix for null.linked
					trunk.linked = null
				if(air_contents)
					pool(air_contents)
				air_contents = null
				trunk = null
			return 1
		return 0

	proc/flushp(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(input && input.signal && isReady() && trunk)
			unReady()
			for(var/atom/movable/M in src.loc)
				if(M == src || M.anchored || isAI(M)) continue
				M.set_loc(src)
			flushit()
		return

	proc/flushit()
		if(!trunk) return
		LIGHT_UP_HOUSING
		var/obj/disposalholder/H = unpool(/obj/disposalholder)

		H.init(src)

		air_contents.zero()

		flick("comp_flush1", src)
		sleep(1 SECOND)
		playsound(src, "sound/machines/disposalflush.ogg", 50, 0, 0)

		H.start(src) // start the holder processing movement
		return

	proc/expel(var/obj/disposalholder/H)

		var/turf/target
		playsound(src, "sound/machines/hiss.ogg", 50, 0, 0)
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))

			AM.set_loc(src.loc)
			AM.pipe_eject(0)
			SPAWN_DBG(1 DECI SECOND)
				if(AM)
					AM.throw_at(target, 5, 1)

		H.vent_gas(loc)
		pool(H)

/obj/item/mechanics/thprint
	name = "Thermal printer"
	desc = ""
	icon_state = "comp_tprint"
	cooldown_time = 5 SECONDS
	var/paper_name = "thermal paper"
	cabinet_banned = true

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"print", "print")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Paper Name","setPaperName")

	proc/print(var/datum/mechanicsMessage/input)
		if(level == 2 || !isReady()) return
		if(input)
			unReady()
			LIGHT_UP_HOUSING
			flick("comp_tprint1",src)
			playsound(src.loc, "sound/machines/printer_thermal.ogg", 60, 0)
			var/obj/item/paper/thermal/P = new/obj/item/paper/thermal(src.loc)
			P.info = strip_html(html_decode(input.signal))
			P.name = paper_name
		return

	proc/setPrice(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter name:","name setting", paper_name) as text
		if(!in_range(src, user) || user.stat)
			return 0
		paper_name = adminscrub(inp)
		boutput(user, "String set to [paper_name]")
		return 1

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && get_dist(src, target) == 1)
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Paper Consumption","toggleConsume")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Thermal Paper Mode","toggleThermal")

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && get_dist(src, target) == 1)
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

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return 1
		else if (istype(W, /obj/item/paper) && isReady())
			if(thermal_only && !istype(W, /obj/item/paper/thermal))
				boutput(user, "<span class='alert'>This scanner only accepts thermal paper.</span>")
				return 0
			unReady()
			LIGHT_UP_HOUSING
			flick("comp_pscan1",src)
			playsound(src.loc, "sound/machines/twobeep2.ogg", 90, 0)
			var/obj/item/paper/P = W
			var/saniStr = strip_html(sanitize(html_encode(P.info)))
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
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	var/obj/item/mechanics/triplaser/holder

	New(var/loc, var/obj/item/mechanics/triplaser/t)
		holder = t
		..()

	proc/tripped()
		if (!holder)
			qdel(src)
		else
			holder.tripped()

	HasEntered(atom/movable/AM as mob|obj)
		if (isobserver(AM) || !AM.density) return
		if (!istype(AM, /obj/mechbeam))
			SPAWN_DBG(0) tripped()

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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", "toggle")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Range","setRange")

	proc/setRange(obj/item/W as obj, mob/user as mob)
		var/rng = input("Range is limited between 1-5.", "Enter a new range", range) as num
		if(!in_range(src, user) || user.stat)
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
		if(level == 2 && get_dist(src, target) == 1)
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
			if(lastturf.opacity || !lastturf.canpass())
				break
			var/obj/mechbeam/newbeam = new(lastturf, src)
			newbeam.dir = src.dir
			beamobjs[++beamobjs.len] = newbeam
			lastturf = get_step(lastturf, dir)

/obj/item/mechanics/hscan
	name = "Hand scanner"
	desc = ""
	icon_state = "comp_hscan"
	var/send_name = 0

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal Type","toggleSig")

	proc/toggleSig(obj/item/W as obj, mob/user as mob)
		send_name = !send_name
		boutput(user, "[send_name ? "Now sending user NAME":"Now sending user FINGERPRINT"]")
		return 1

	attack_hand(mob/user as mob)
		if(level != 2 && isReady())
			if(ishuman(user) && user.bioHolder)
				unReady()
				LIGHT_UP_HOUSING
				flick("comp_hscan1",src)
				playsound(src.loc, "sound/machines/twobeep2.ogg", 90, 0)
				var/sendstr = (send_name ? user.real_name : user.bioHolder.uid_hash)
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,sendstr)
			else
				boutput(user, "<span class='alert'>The hand scanner can only be used by humanoids.</span>")
				return
		else return ..(user)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && get_dist(src, target) == 1)
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
	event_handler_flags = USE_HASENTERED | USE_FLUID_ENTER

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", "activateproc")

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
			if(world.tick_usage > 100) return //fuck it, failsafe

	proc/activateproc(var/datum/mechanicsMessage/input)
		if(level == 2) return
		if(input)
			if(active) return
			particleMaster.SpawnSystem(new /datum/particleSystem/gravaccel(src.loc, src.dir))
			SPAWN_DBG(0)
				if(src)
					icon_state = "[under_floor ? "u":""]comp_accel1"
					active = 1
					SPAWN_DBG(0) drivecurrent()
					SPAWN_DBG(0.5 SECONDS) drivecurrent()
				sleep(3 SECONDS)
				if(src)
					icon_state = "[under_floor ? "u":""]comp_accel"
					active = 0
		return

	proc/throwstuff(atom/movable/AM as mob|obj)
		if(level == 2 || AM.anchored || AM == src) return
		if(AM.throwing) return
		var/atom/target = get_edge_target_turf(AM, src.dir)
		SPAWN_DBG(0) AM.throw_at(target, 50, 1)
		return

	HasEntered(atom/movable/AM as mob|obj)
		if(level == 2) return
		if(active)
			throwstuff(AM)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_accel"
		return

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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"delay", "delayproc")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Delay","setDelay")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal Changing","toggleDefault")

	proc/setDelay(obj/item/W as obj, mob/user as mob)
		var/inp = input(user, "Enter delay in 10ths of a second:", "Set delay", 10) as num
		if(!in_range(src, user) || user.stat)
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
			SPAWN_DBG(0)
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

	updateIcon()
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 1", "fire1")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 2", "fire2")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Time Frame","setTime")

	proc/setTime(obj/item/W as obj, mob/user as mob)
		var/inp = input(user, "Enter Time Frame in 10ths of a second:", "Set Time Frame", timeframe) as num
		if(!in_range(src, user) || user.stat)
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

		SPAWN_DBG(timeframe)
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

		SPAWN_DBG(timeframe)
			inp2 = 0

		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_and"
		return

/obj/item/mechanics/orcomp
	name = "OR Component"
	desc = ""
	icon_state = "comp_or"
	var/triggerSignal = "1"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 1", "fire")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 2", "fire")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 3", "fire")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 4", "fire")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 5", "fire")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 6", "fire")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 7", "fire")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 8", "fire")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 9", "fire")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input 10", "fire")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Trigger Field","setTrigger")

	proc/setTrigger(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Signal:","Signal setting","1") as text
		if(!in_range(src, user) || user.stat)
			return 0
		if(length(inp))
			inp = strip_html(html_decode(inp))
			triggerSignal = inp
			boutput(user, "Signal set to [inp]")
			return 1
		return 0

	proc/fire(var/datum/mechanicsMessage/input)
		if(level != 2 && input.signal == triggerSignal)
			LIGHT_UP_HOUSING
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG,input)
		return

	updateIcon()
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"split", "split")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Trigger Field","setTrigger")

	proc/setTrigger(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Signal:","Signal setting","1") as text
		if(!in_range(src, user) || user.stat)
			return 0
		if(length(inp))
			inp = strip_html(html_decode(inp))
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

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_split"
		return

/obj/item/mechanics/regreplace
	name = "RegEx Replace Component"
	desc = ""
	icon_state = "comp_regrep"
	var/expression = "original/replacement/g"
	var/expressionpatt = "original"
	var/expressionrepl = "replacement"
	var/expressionflag = "g"

	get_desc()
		. += {"<span class='notice'>Current Expression: [html_encode(expression)]</span><br/>
		<span class='notice'>Current Replacement: [html_encode(expressionrepl)]</span><br/>
		Your replacement string can contain $0-$9 to insert that matched group(things between parenthesis)<br/>
		$` will be replaced with the text that came before the match, and $' will be replaced by the text after the match.<br/>
		$0 or $& will be the entire matched string."}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"replace string", "checkstr")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set regex", "setregex")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set regex replacement", "setregexreplace")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Pattern","setPattern")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Replacement","setReplacement")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Flags","setFlags")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Regular Expression Replacement","setRegexReplacement")

	proc/setPattern(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Expression Pattern:","Expression setting", expressionpatt) as text
		if(!in_range(src, user) || user.stat)
			return 0
		if(length(inp))
			expressionpatt = inp
			inp = sanitize(html_encode(inp))
			expression =("[expressionpatt]/[expressionrepl]/[expressionflag]")
			boutput(user, "Expression Pattern set to [inp], Current Expression: [sanitize(html_encode(expression))]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/setReplacement(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Expression Replacement:","Expression setting", expressionrepl) as text
		if(!in_range(src, user) || user.stat)
			return 0
		if(length(inp))
			expressionrepl = inp
			inp = sanitize(html_encode(inp))
			expression =("[expressionpatt]/[expressionrepl]/[expressionflag]")
			boutput(user, "Expression Replacement set to [inp], Current Expression: [sanitize(html_encode(expression))]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/setFlags(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Expression Flags:","Expression setting", expressionflag) as text
		if(!in_range(src, user) || user.stat)
			return 0
		if(length(inp))
			expressionflag = inp
			inp = sanitize(html_encode(inp))
			expression =("[expressionpatt]/[expressionrepl]/[expressionflag]")
			boutput(user, "Expression Flags set to [inp], Current Expression: [sanitize(html_encode(expression))]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/setRegexReplacement(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Replacement:","Replacement setting", expressionrepl) as text
		if(!in_range(src, user) || user.stat)
			return 0
		if(length(inp))
			expressionrepl = inp
			boutput(user, "Replacement set to [html_encode(inp)]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/checkstr(var/datum/mechanicsMessage/input)
		if(level == 2 || !length(expressionpatt)) return
		LIGHT_UP_HOUSING
		var/regex/R = new(expressionpatt,expressionflag)

		if(!R) return

		var/mod = R.Replace(input.signal, expressionrepl)
		mod = strip_html(sanitize(html_encode(mod)))//U G H

		if(mod)
			input.signal = mod
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)

		return
	proc/setregex(var/datum/mechanicsMessage/input)
		if(level == 2) return
		expression = input.signal
		tooltip_rebuild = 1
	proc/setregexreplace(var/datum/mechanicsMessage/input)
		if(level == 2) return
		expressionrepl = input.signal
		tooltip_rebuild = 1
	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_regrep"
		return

/obj/item/mechanics/regfind
	name = "RegEx Find Component"
	desc = ""
	icon_state = "comp_regfind"
	var/replacesignal = 0
	var/expression = "/\[a-Z\]*/"
	var/expressionpatt
	var/expressionflag

	get_desc()
		. += {"<br><span class='notice'>Current Expression: [sanitize(html_encode(expression))]<br>
		Replace Signal is [replacesignal ? "on.":"off."]</span>"}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"check string", "checkstr")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set regex", "setregex")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Expression Pattern","setRegex")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Expression Flags","setFlags")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal replacing","toggleReplaceing")

	proc/setRegex(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Expression Pattern:","Expression setting", expressionpatt) as text
		if(!in_range(src, user) || user.stat)
			return 0
		if(length(inp))
			expressionpatt = inp
			expression =("[expressionpatt]/[expressionflag]")
			inp = sanitize(html_encode(inp))
			boutput(user, "Expression Pattern set to [inp], Current Expression: [sanitize(html_encode(expression))]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/setFlags(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Expression Flags:","Expression setting", expressionflag) as text
		if(!in_range(src, user) || user.stat)
			return 0
		if(length(inp))
			expressionflag = inp
			expression =("[expressionpatt]/[expressionflag]")
			inp = sanitize(html_encode(inp))
			boutput(user, "Expression Flags set to [inp], Current Expression: [sanitize(html_encode(expression))]")
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
		expression = input.signal
		tooltip_rebuild = 1
	proc/checkstr(var/datum/mechanicsMessage/input)
		if(level == 2 || !length(expression)) return
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

	updateIcon()
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"check string", "checkstr")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set trigger", "settrigger")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Trigger-String","setTrigger")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Invert Trigger","invertTrigger")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Replace Signal","toggleReplace")

	proc/setTrigger(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter String:","String setting","1") as text
		if(!in_range(src, user) || user.stat)
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
	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_check"
		return

/obj/item/mechanics/dispatchcomp
	name = "Dispatch Component"
	desc = ""
	icon_state = "comp_disp"
	var/exact_match = 0

	//This stores all the relevant filters per output
	//Notably, this list doesn't remove entries when an output is removed.
	//So it will bloat over time...
	var/list/outgoing_filters

	get_desc()
		. += "<br><span class='notice'>Exact match mode: [exact_match ? "on" : "off"]</span>"

	New()
		..()
		src.outgoing_filters = list()
		RegisterSignal(src, list(_COMSIG_MECHCOMP_DISPATCH_ADD_FILTER), .proc/addFilter)
		RegisterSignal(src, list(_COMSIG_MECHCOMP_DISPATCH_RM_OUTGOING), .proc/removeFilter)
		RegisterSignal(src, list(_COMSIG_MECHCOMP_DISPATCH_VALIDATE), .proc/runFilter)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"dispatch", "dispatch")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle exact matching","toggleExactMatching")

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

	proc/dispatch(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		var/sent = SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		if(sent) animate_flash_color_fill(src,"#00FF00",2, 2)
		return

	//This will get called from the component-datum when a device is being linked
	proc/addFilter(var/comsig_target, atom/receiver, mob/user)
		var/filter = input(user, "Add filters for this connection? (Comma-delimited list. Leave blank to pass all messages.)", "Intput Filters") as text
		if(!in_range(src, user) || user.stat)
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
			return 0 //Not filtering this output, let anything pass
		for (var/filter in src.outgoing_filters[receiver])
			var/text_found = findtext(signal, filter)
			if (exact_match)
				text_found = text_found && (length(signal) == length(filter))
			if (text_found)
				return 0 //Signal validated, let it pass
		return 1 //Signal invalid, halt it

	updateIcon()
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"add to string", "addstr")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"add to string + send", "addstrsend")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send", "sendstr")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"clear buffer", "clrbff")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set starting String","setStartingString")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set ending String","setEndingString")

	proc/setStartingString(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter String:","String setting", bstr) as text
		if(!in_range(src, user) || user.stat)
			return 0
		inp = strip_html(inp)
		bstr = inp
		boutput(user, "String set to [inp]")
		tooltip_rebuild = 1
		return 1

	proc/setEndingString(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter String:","String setting", astr) as text
		if(!in_range(src, user) || user.stat)
			return 0
		inp = strip_html(inp)
		astr = inp
		boutput(user, "String set to [inp]")
		tooltip_rebuild = 1
		return 1

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
		finished = strip_html(sanitize(finished))
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

	updateIcon()
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"relay", "relay")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Signal Changing","toggleDefault")

	proc/toggleDefault(obj/item/W as obj, mob/user as mob)
		changesig = !changesig
		boutput(user, "Signal changing now [changesig ? "on":"off"]")
		tooltip_rebuild = 1
		return 1

	proc/relay(var/datum/mechanicsMessage/input)
		if(level == 2 || !isReady()) return
		LIGHT_UP_HOUSING
		unReady()
		flick("[under_floor ? "u":""]comp_relay1", src)
		var/transmissionStyle = changesig ? COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG : COMSIG_MECHCOMP_TRANSMIT_MSG
		SPAWN_DBG(0) SEND_SIGNAL(src,transmissionStyle,input)
		return

	updateIcon()
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send file", "sendfile")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"add file to signal and send", "addandsendfile")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"save file", "storefile")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"delete file", "deletefile")
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

	updateIcon()
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
	var/range = 0

	var/noise_enabled = true
	var/frequency = 1419
	var/datum/radio_frequency/radio_connection

	get_desc()
		. += {"<br><span class='notice'>[forward_all ? "Sending full unprocessed Signals.":"Sending only processed sendmsg and pda Message Signals."]<br>
		[only_directed ? "Only reacting to Messages directed at this Component.":"Reacting to ALL Messages received."]<br>
		Current Frequency: [frequency]<br>
		Current NetID: [net_id]</span>"}

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send radio message", "send")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set frequency", "setfreq")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Frequency","setFreqManually")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle NetID Filtering","toggleAddressFiltering")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Forward All","toggleForwardAll")

		if(radio_controller)
			set_frequency(frequency)

		src.net_id = format_net_id("\ref[src]")

	proc/setFreqManually(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Frequency:","Frequency setting", frequency) as num
		if(!in_range(src, user) || user.stat)
			return 0
		if(!isnull(inp))
			set_frequency(inp)
			boutput(user, "Frequency set to [inp]")
			tooltip_rebuild = 1
			return 1
		return 0

	proc/toggleAddressFiltering(obj/item/W as obj, mob/user as mob)
		only_directed = !only_directed
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
		var/newfreq = text2num(input.signal)
		if(!newfreq) return
		set_frequency(newfreq)
		return

	proc/send(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		var/list/converted = params2list(input.signal)
		if(!length(converted) || !isReady()) return

		unReady()

		var/datum/signal/sendsig = get_free_signal()

		sendsig.source = src
		sendsig.data["sender"] = src.net_id
		sendsig.transmission_method = TRANSMISSION_RADIO

		for(var/X in converted)
			sendsig.data["[X]"] = "[converted[X]]"
			if(X == "command" && converted[X] == "text_message")
				logTheThing("pdamsg", usr, null, "sends a PDA message <b>[input.signal]</b> using a wifi component at [log_loc(src)].")
		if(input.data_file)
			sendsig.data_file = input.data_file.copy_file()
		SPAWN_DBG(0)
			if(src.noise_enabled)
				src.noise_enabled = false
				playsound(get_turf(src), "sound/machines/modem.ogg", WIFI_NOISE_VOLUME, 0, 0)
				SPAWN_DBG(WIFI_NOISE_COOLDOWN)
					src.noise_enabled = true
			src.radio_connection.post_signal(src, sendsig, src.range)

		animate_flash_color_fill(src,"#FF0000",2, 2)
		return

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption || level == 2)
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
				pingsignal.transmission_method = TRANSMISSION_RADIO

				SPAWN_DBG(0.5 SECONDS) //Send a reply for those curious jerks
					if(src.noise_enabled)
						src.noise_enabled = false
						playsound(get_turf(src), "sound/machines/modem.ogg", WIFI_NOISE_VOLUME, 0, 0)
						SPAWN_DBG(WIFI_NOISE_COOLDOWN)
							src.noise_enabled = true
					src.radio_connection.post_signal(src, pingsignal, src.range)

			if(forward_all)
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, html_decode(list2params_noencode(signal.data)), signal.data_file?.copy_file())
				animate_flash_color_fill(src,"#00FF00",2, 2)
				return

			else if(signal.data["command"] == "sendmsg" && signal.data["data"])
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, html_decode(signal.data["data"]), signal.data_file?.copy_file())
				animate_flash_color_fill(src,"#00FF00",2, 2)

			else if(signal.data["command"] == "text_message" && signal.data["message"])
				SEND_SIGNAL(src, COMSIG_MECHCOMP_TRANSMIT_SIGNAL, html_decode(signal.data["message"]), null)
				animate_flash_color_fill(src,"#00FF00",2, 2)

			else if(signal.data["command"] == "setfreq" && signal.data["data"])
				var/newfreq = text2num(signal.data["data"])
				if(!newfreq) return
				set_frequency(newfreq)
				animate_flash_color_fill(src,"#00FF00",2, 2)

		return

	proc/set_frequency(new_frequency)
		if(!radio_controller) return
		tooltip_rebuild = 1
		new_frequency = clamp(new_frequency, 1000, 1500)
		radio_controller.remove_object(src, "[frequency]")
		frequency = new_frequency
		radio_connection = radio_controller.add_object(src, "[frequency]")

	updateIcon()
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"add item", "additem")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"remove item", "remitem")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"remove all items", "remallitem")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"select item", "selitem")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"select item + send", "selitemplus")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"next", "next")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"previous", "previous")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"next + send", "nextplus")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"previous + send", "previousplus")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send selected", "sendCurrent")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send random", "sendRand")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Signal List","setSignalList")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Signal List(Delimeted)","setDelimetedList")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Announcements","toggleAnnouncements")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Random","toggleRandom")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Allow Duplicate Entries","toggleAllowDuplicates")


	proc/setSignalList(obj/item/W as obj, mob/user as mob)
		var/numsig = input(user,"How many Signals would you like to define?","# Signals:", 3) as num
		if(!in_range(src, user) || user.stat)
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
		if(!in_range(src, user) || user.stat)
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
				current_index = length(signals)
			tooltip_rebuild = 1
			if(announce)
				componentSay("Removed : [input.signal]")
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

		SPAWN_DBG(0)
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

	updateIcon()
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", "activate")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate and send", "activateplus")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"deactivate", "deactivate")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"deactivate and send", "deactivateplus")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", "toggle")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle and send", "toggleplus")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"send", "send")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set On-Signal","setOnSignal")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Off-Signal","setOffSignal")

	proc/setOnSignal(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter Signal:","Signal setting",signal_on) as text
		if(!in_range(src, user) || user.stat)
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
		if(!in_range(src, user) || user.stat)
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
		SPAWN_DBG(0)
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_toggle[on ? "1":""]"
		return

/obj/item/mechanics/telecomp
	name = "Teleport Component"
	desc = ""
	icon_state = "comp_tele"
	cabinet_banned = true // potentially abusable. b&
	var/teleID = "tele1"
	var/send_only = 0

	get_desc()
		. += {"<br><span class='notice'>Current ID: [teleID].<br>
		Send only Mode: [send_only ? "On":"Off"].</span>"}

	New()
		..()
		mechanics_telepads.Add(src)
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", "activate")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"setID", "setidmsg")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Teleporter ID","setID")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Send-only Mode","toggleSendOnly")

	disposing()
		mechanics_telepads.Remove(src)
		return ..()

	proc/setID(obj/item/W as obj, mob/user as mob)
		var/inp = input(user,"Please enter ID:","ID setting",teleID) as text
		if(!in_range(src, user) || user.stat)
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
			src.overlays += image('icons/misc/mechanicsExpansion.dmi', icon_state = "comp_teleoverlay")
		else
			src.overlays.Cut()
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
		if(level == 2 || !isReady()) return
		unReady()
		LIGHT_UP_HOUSING
		flick("[under_floor ? "u":""]comp_tele1", src)
		particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(get_turf(src.loc)))
		playsound(src.loc, "sound/mksounds/boost.ogg", 50, 1)
		var/list/destinations = new/list()

		for(var/obj/item/mechanics/telecomp/T in mechanics_telepads)
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
			particleMaster.SpawnSystem(new /datum/particleSystem/tpbeam(get_turf(picked.loc)))
			for(var/atom/movable/M in src.loc)
				if(M == src || M.invisibility || M.anchored) continue
				M.set_loc(get_turf(picked.loc))
				count_sent++
			input.signal = count_sent
			SPAWN_DBG(0)
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
				SEND_SIGNAL(picked,COMSIG_MECHCOMP_TRANSMIT_MSG,input)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_tele"
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"toggle", "toggle")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"activate", "turnon")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"deactivate", "turnoff")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set rgb", "setrgb")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Color","setColor")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Range","setRange")

		light = new /datum/light/point
		light.attach(src)

	proc/setColor(obj/item/W as obj, mob/user as mob)
		var/red = input(user,"Red Color(0.0 - 1.0):","Color setting", 1.0) as num
		var/green = input(user,"Green Color(0.0 - 1.0):","Color setting", 1.0) as num
		var/blue = input(user,"Blue Color(0.0 - 1.0):","Color setting", 1.0) as num
		if(!in_range(src, user) || user.stat)
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
		if(!in_range(src, user) || user.stat)
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
			SPAWN_DBG(0) light.set_color(GetRedPart(selcolor) / 255, GetGreenPart(selcolor) / 255, GetBluePart(selcolor) / 255)

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

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_led"
		return

/obj/item/mechanics/miccomp
	name = "Microphone Component"
	desc = ""
	icon_state = "comp_mic"
	var/add_sender = 0

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Toggle Show-Source","toggleSender")

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
		message = strip_html(html_decode(message))
		var/heardname = M.name
		if(real_name)
			heardname = real_name
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,add_sender ? "[heardname] : [message]":"[message]")
		animate_flash_color_fill(src,"#00FF00",2, 2)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_mic"
		return

/obj/item/mechanics/radioscanner
	name = "Radio Scanner Component"
	desc = ""
	icon_state = "comp_radioscanner"

	var/frequency = R_FREQ_DEFAULT
	var/datum/radio_frequency/radio_connection

	get_desc()
		. += "<br><span style=\"color:blue\">Current Frequency: [frequency]</span>"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"set frequency", "setfreq")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Frequency","setFreqMan")


		if(radio_controller)
			set_frequency(frequency)

	proc/setFreqMan(obj/item/W as obj, mob/user as mob)
		var/inp = input(user, "New frequency ([R_FREQ_MINIMUM] - [R_FREQ_MAXIMUM]):", "Enter new frequency", frequency) as num
		if(!in_range(src, user) || user.stat)
			return 0
		if(!isnull(inp))
			set_frequency(inp)
			boutput(user, "Frequency set to [frequency]")
			return 1
		return 0

	proc/setfreq(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		var/newfreq = text2num(input.signal)
		if (!newfreq) return
		set_frequency(newfreq)
		return

	proc/set_frequency(new_frequency)
		if (!radio_controller) return
		new_frequency = sanitize_frequency(new_frequency)
		componentSay("New frequency: [new_frequency]")
		radio_controller.remove_object(src, "[frequency]")
		frequency = new_frequency
		radio_connection = radio_controller.add_object(src, "[frequency]")
		tooltip_rebuild = 1
	proc/hear_radio(mob/M as mob, msg, lang_id)
		if (level == 2) return
		LIGHT_UP_HOUSING
		var/message = msg[2]
		if (lang_id in list("english", ""))
			message = msg[1]
		message = strip_html(html_decode(message))
		var/heardname = M.real_name
		if (M.wear_mask && M.wear_mask.vchange)
			heardname = M:wear_id ? M:wear_id:registered : "Unknown"
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL,"name=[heardname]&message=[message]")
		animate_flash_color_fill(src,"#00FF00",2, 2)
		return

	updateIcon()
		icon_state = "[under_floor ? "u" : ""]comp_radioscanner"
		return

/obj/item/mechanics/synthcomp
	name = "Sound Synthesizer"
	desc = ""
	icon_state = "comp_synth"
	cooldown_time = 2 SECONDS

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"input", "fire")

	proc/fire(var/datum/mechanicsMessage/input)
		if(level == 2 || !isReady() || !input) return
		unReady()
		LIGHT_UP_HOUSING
		componentSay("[input.signal]")
		return

	updateIcon()
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
		if (level == 2 || isobserver(AM))
			return
		if (limiter && (ticker.round_elapsed_ticks < limiter))
			return
		LIGHT_UP_HOUSING
		limiter = ticker.round_elapsed_ticks + 10
		SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG, null)
		return

	updateIcon()
		icon_state = "[under_floor ? "u":""]comp_pressure"
		return

/obj/item/mechanics/trigger/button
	name = "Button"
	desc = "A button. It's red hue enticing you to press it."
	icon_state = "comp_button"
	var/icon_up = "comp_button"
	var/icon_down = "comp_button1"
	density = 1

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ALLOW_MANUAL_SIGNAL)

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return 1
		if(ispulsingtool(W)) return // Don't press the button with a multitool, it brings up the config menu instead
		return attack_hand(user)

	attack_hand(mob/user as mob)
		if(level == 1)
			flick(icon_down, src)
			LIGHT_UP_HOUSING
			SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_DEFAULT_MSG, null)
			return 1
		return ..(user)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && get_dist(src, target) == 1)
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
	updateIcon()
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Add Button","addButton")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Remove Button","removeButton")

	proc/addButton(obj/item/W as obj, mob/user as mob)
		if(length(src.active_buttons) >= 10)
			boutput(user, "<span class='alert'>There's no room to add another button - the panel is full</span>")
			return 0

		var/new_label = input(user, "Button label", "Button Panel") as text
		var/new_signal = input(user, "Button signal", "Button Panel") as text
		if(!in_range(src, user) || user.stat)
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
			if(!in_range(src, user) || user.stat)
				return 0
			if(!to_remove || to_remove == "*CANCEL*")
				return 0
			src.active_buttons.Remove(to_remove)
			boutput(user, "Removed button labeled [to_remove]")
			tooltip_rebuild = 1
			return 1
		return 0

	attack_hand(mob/user as mob)
		if (level == 1)
			if (length(src.active_buttons))
				var/selected_button = input(usr, "Press a button", "Button Panel") in src.active_buttons + "*CANCEL*"
				if (!selected_button || selected_button == "*CANCEL*" || !in_range(src, usr)) return
				LIGHT_UP_HOUSING
				flick(icon_down, src)
				SEND_SIGNAL(src,COMSIG_MECHCOMP_TRANSMIT_SIGNAL, src.active_buttons[selected_button])
				return 1
			else
				boutput(usr, "<span class='alert'>[src] has no active buttons - there's nothing to press!</span>")
		else return ..(user)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		if(level == 2 && in_range(src, target))
			if(isturf(target))
				user.drop_item()
				src.set_loc(target)
		return

	updateIcon()
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
	var/compatible_guns = /obj/item/gun/kinetic
	cabinet_banned = true // non-functional thankfully
	get_desc()
		. += "<br><span class='notice'>Current Gun: [Gun ? "[Gun] [Gun.canshoot() ? "(ready to fire)" : "(out of [istype(Gun, /obj/item/gun/energy) ? "charge)" : "ammo)"]"]" : "None"]</span>"

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"fire", "fire")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Remove Gun","removeGun")

	proc/removeGun(obj/item/W as obj, mob/user as mob)
		if(Gun)
			logTheThing("station", user, null, "removes [Gun] from [src] at [log_loc(src)].")
			Gun.loc = get_turf(src)
			Gun = null
			tooltip_flags &= ~REBUILD_ALWAYS
			return 1
		boutput(user, "<span class='alert'>There is no gun inside this component.</span>")
		return 0

	attackby(obj/item/W as obj, mob/user as mob)
		if(..(W, user)) return 1
		else if(istype(W, src.compatible_guns))
			if(!Gun)
				boutput(usr, "You put the [W] inside the [src].")
				logTheThing("station", usr, null, "adds [W] to [src] at [log_loc(src)].")
				usr.drop_item()
				Gun = W
				Gun.loc = src
				tooltip_flags |= REBUILD_ALWAYS
				return 1
			else
				boutput(usr, "There is already a [Gun] inside the [src]")
		else
			user.show_text("The [W.name] isn't compatible with this component.", "red")
		return 0

	proc/getTarget()
		var/atom/trg = get_turf(src)
		for(var/mob/living/L in trg)
			return get_turf_loc(L)
		for(var/i=0, i<7, i++)
			trg = get_step(trg, src.dir)
			for(var/mob/living/L in trg)
				return get_turf_loc(L)
		return get_edge_target_turf(src, src.dir)

	proc/fire(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		if(input && Gun)
			if(Gun.canshoot())
				var/atom/target = getTarget()
				if(target)
					//DEBUG_MESSAGE("Target: [log_loc(target)]. Src: [src]")
					Gun.shoot(target, get_turf(src), src)
			else
				src.visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"The [Gun.name] has no [istype(Gun, /obj/item/gun/energy) ? "charge" : "ammo"] remaining.\"</span>")
				playsound(src.loc, "sound/machines/buzz-two.ogg", 50, 0)
		else
			src.visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"No gun installed.\"</span>")
			playsound(src.loc, "sound/machines/buzz-two.ogg", 50, 0)
		return

	updateIcon()
		icon_state = "comp_gun"
		return

/obj/item/mechanics/gunholder/recharging
	name = "E-Gun Component"
	desc = ""
	icon_state = "comp_gun2"
	density = 0
	compatible_guns = /obj/item/gun/energy
	var/charging = 0

	get_desc()
		. = ..() // Please don't remove this again, thanks.
		. += charging ? "<br><span class='notice'>Component is charging.</span>" : null

	New()
		..()
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"recharge", "recharge")

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
			updateIcon()

		if(!istype(Gun, /obj/item/gun/energy) || !charging)
			return

		var/obj/item/gun/energy/E = Gun

		// Can't recharge the crossbow. Same as the other recharger.
		if (!E.rechargeable)
			src.visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"This gun cannot be recharged manually.\"</span>")
			playsound(src.loc, "sound/machines/buzz-two.ogg", 50, 0)
			charging = 0
			tooltip_rebuild = 1
			updateIcon()
			return

		if (E.cell)
			if (E.cell.charge(15) != 1) // Same as other recharger.
				src.charging = 0
				tooltip_rebuild = 1
				src.updateIcon()
		E.update_icon()
		return

	proc/recharge(var/datum/mechanicsMessage/input)
		if(charging || !Gun || level == 2) return
		if(!istype(Gun, /obj/item/gun/energy)) return
		charging = 1
		tooltip_rebuild = 1
		updateIcon()
		return

	fire(var/datum/mechanicsMessage/input)
		if(charging || !isReady() || level == 2) return
		unReady()
		return ..()

	updateIcon()
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"play", "fire")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Remove Instrument","removeInstrument")

	proc/removeInstrument(obj/item/W as obj, mob/user as mob)
		if(instrument)
			logTheThing("station", user, null, "removes [instrument] from [src] at [log_loc(src)].")
			instrument.loc = get_turf(src)
			instrument = null
			tooltip_rebuild = 1
			return 1
		else
			boutput(user, "<span class='alert'>There is no instrument inside this component.</span>")
		return 0

	attackby(obj/item/W as obj, mob/user as mob)
		if (..(W, user)) return 1
		else if (instrument) // Already got one, chief!
			boutput(usr, "There is already \a [instrument] inside the [src].")
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
			boutput(usr, "You put [W] inside [src].")
			logTheThing("station", usr, null, "adds [W] to [src] at [log_loc(src)].")
			usr.drop_item()
			instrument.loc = src
			tooltip_rebuild = 1
			return 1
		return 0

	proc/fire(var/datum/mechanicsMessage/input)
		if (level == 2 || !isReady() || !instrument) return
		LIGHT_UP_HOUSING
		unReady(delay)
		var/signum = text2num(input.signal)
		if (signum &&((signum >= 0.4 && signum <= 2) ||(signum <= -0.4 && signum >= -2) || pitchUnlocked))
			flick("comp_instrument1", src)
			playsound(get_turf(src), sounds, volume, 0, 0, signum)
		else
			flick("comp_instrument1", src)
			playsound(get_turf(src), sounds, volume, 1)
			return

	updateIcon()
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
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set A", "setA")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Set B", "setB")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_INPUT,"Evaluate", "evaluate")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set A","setAManually")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set B","setBManually")
		SEND_SIGNAL(src,COMSIG_MECHCOMP_ADD_CONFIG,"Set Mode","setMode")

	proc/setAManually(obj/item/W as obj, mob/user as mob)
		var/input = input("Set A to what?", "A", A) as num
		if(!in_range(src, user) || user.stat || isnull(input))
			return 0
		A = input
		tooltip_rebuild = 1
		return 1

	proc/setBManually(obj/item/W as obj, mob/user as mob)
		var/input = input("Set B to what?", "B", B) as num
		if(!in_range(src, user) || user.stat || isnull(input))
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
		if (!isnull(text2num(input.signal)))
			A = text2num(input.signal)
			tooltip_rebuild = 1
	proc/setB(var/datum/mechanicsMessage/input)
		if(level == 2) return
		LIGHT_UP_HOUSING
		if (!isnull(text2num(input.signal)))
			B = text2num(input.signal)
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

/obj/mecharrow
	name = ""
	icon = 'icons/misc/mechanicsExpansion.dmi'
	icon_state = "connectionArrow"
#undef IN_CABINET
#undef LIGHT_UP_HOUSING
