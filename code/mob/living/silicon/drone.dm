/obj/item/device/drone_control
	name = "drone control handset"
	desc = "Allows the user to remotely operate a drone."
	icon_state = "matanalyzer"
	var/signal_tag = "mining"
	flags = TABLEPASS | CONDUCT
	var/list/drone_list = list()

	attack_self(var/mob/user as mob)
		drone_list = list()
		for (var/mob/living/silicon/drone/D in mobs)
			if (D.signal_tag == src.signal_tag)
				drone_list += D

		if (length(drone_list) < 1)
			boutput(user, SPAN_ALERT("No usable drones detected."))
			return

		var/mob/living/silicon/drone/which = input("Which drone do you want to control?","Drone Controls") as mob in drone_list
		if (istype(which))
			var/attempt = which.connect_to_drone(user)
			switch(attempt)
				if(1)
					boutput(user, SPAN_ALERT("Connection error: Drone not found."))
				if(2)
					boutput(user, SPAN_ALERT("Connection error: Drone already in use."))

/mob/living/silicon/drone
	name = "drone"
	var/base_name = "drone"
	desc = "A small remote-controlled robot for doing risky work from afar."
	icon = 'icons/mob/drone.dmi'
	icon_state = "base"
	var/health_max = 100
	var/signal_tag = "mining"
	var/datum/hud/drone/hud
	var/mob/controller = null
	var/obj/item/device/radio/radio = null
	var/obj/item/parts/robot_parts/drone/propulsion/propulsion = null
	var/obj/item/parts/robot_parts/drone/plating/plating = null
	var/list/equipment_slots = list(null, null, null, null, null)
	var/obj/item/active_tool = null
	var/datum/material/mat_chassis = null
	var/datum/material/mat_plating = null
	var/disabled = 0
	var/panelopen = 0
	var/sound_damaged = 'sound/impact_sounds/Metal_Hit_Light_1.ogg'
	var/sound_destroyed = 'sound/impact_sounds/Machinery_Break_1.ogg'
	var/list/beeps_n_boops = list('sound/machines/twobeep.ogg','sound/machines/ping.ogg','sound/machines/chime.ogg','sound/machines/buzz-two.ogg','sound/machines/buzz-sigh.ogg')
	var/list/glitchy_noise = list('sound/effects/glitchy1.ogg','sound/effects/glitchy2.ogg','sound/effects/glitchy3.ogg')
	var/list/glitch_con = list("kind of","a little bit","somewhat","a bit","slightly","quite","rather")
	var/list/glitch_adj = list("scary","weird","freaky","crazy","demented","horrible","ghastly","egregious","unnerving")

	New()
		..()
		name = "drone [rand(1,9)]*[rand(10,99)]"
		base_name = name
		hud = new(src)
		src.attach_hud(hud)

		var/obj/item/cell/CELL = new /obj/item/cell(src)
		CELL.charge = CELL.maxcharge
		src.cell = CELL

		src.radio = new /obj/item/device/radio(src)
		src.ears = src.radio

		var/obj/item/mining_tool/powered/drill/D = new /obj/item/mining_tool/powered/drill(src)
		equipment_slots[1] = D
		var/obj/item/ore_scoop/borg/S = new /obj/item/ore_scoop/borg(src)
		equipment_slots[2] = S
		var/obj/item/oreprospector/O = new /obj/item/oreprospector(src)
		equipment_slots[3] = O

		src.health = src.health_max
		src.botcard.access = get_all_accesses()

	examine()
		. = ..()
		if (src.controller)
			. += "It is currently active and being controlled by someone."
		else
			. += "It is currently shut down and not being used."
		if (src.health < 100)
			if (src.health < 50)
				. += SPAN_ALERT("It's rather badly damaged. It probably needs some wiring replaced inside.")
			else
				. += SPAN_ALERT("It's a bit damaged. It looks like it needs some welding done.")

	movement_delay()
		var/tally = 0
		tally += movement_delay_modifier
		for (var/obj/item/parts/robot_parts/drone/DP in src.contents)
			tally += DP.weight
		if (src.propulsion && istype(src.propulsion))
			tally -= src.propulsion.speed
		return tally

	attackby(obj/item/W, mob/user)
		if(isweldingtool(W))
			if (user.a_intent == INTENT_HARM)
				if (W:try_weld(user,0,-1,0,0))
					user.visible_message(SPAN_ALERT("<b>[user] burns [src] with [W]!</b>"))
					damage_heat(W.force)
				else
					user.visible_message(SPAN_ALERT("<b>[user] beats [src] with [W]!</b>"))
					damage_blunt(W.force)
			else
				if (src.health >= src.health_max)
					boutput(user, SPAN_ALERT("It isn't damaged!"))
					return
				if (get_fraction_of_percentage_and_whole(src.health,src.health_max) < 33)
					boutput(user, SPAN_ALERT("You need to use wire to fix the cabling first."))
					return
				if(W:try_weld(user, 1))
					src.health = clamp(src.health + 10, 1, src.health_max)
					user.visible_message("<b>[user]</b> uses [W] to repair some of [src]'s damage.")
					if (src.health == src.health_max)
						boutput(user, SPAN_NOTICE("<b>[src] looks fully repaired!</b>"))

		else if (istype(W,/obj/item/cable_coil/))
			if (src.health >= src.health_max)
				boutput(user, SPAN_ALERT("It isn't damaged!"))
				return
			var/obj/item/cable_coil/C = W
			if (get_fraction_of_percentage_and_whole(src.health,src.health_max) >= 33)
				boutput(user, SPAN_ALERT("The cabling looks fine. Use a welder to repair the rest of the damage."))
				return
			C.use(1)
			src.health = clamp(src.health + 10, 1, src.health_max)
			user.visible_message("<b>[user]</b> uses [C] to repair some of [src]'s cabling.")
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			if (src.health >= 50)
				boutput(user, SPAN_NOTICE("The wiring is fully repaired. Now you need to weld the external plating."))

		else
			user.visible_message(SPAN_ALERT("<b>[user] attacks [src] with [W]!</b>"))
			damage_blunt(W.force)

	proc/take_damage(var/amount)
		if (!isnum(amount))
			return

		src.health = clamp(src.health - amount, 0, 100)

		if (amount > 0)
			playsound(src.loc, src.sound_damaged, 50, 2)
			if (src.health == 0)
				src.visible_message(SPAN_ALERT("<b>[src.name] is destroyed!</b>"))
				disconnect_user()
				robogibs(src.loc)
				playsound(src.loc, src.sound_destroyed, 50, 2)
				qdel(src)
				return

	damage_blunt(var/amount)
		if (!isnum(amount) || amount <= 0)
			return
		take_damage(amount)

	damage_heat(var/amount)
		if (!isnum(amount) || amount <= 0)
			return
		take_damage(amount)

	swap_hand(var/switchto = 0)
		if (!isnum(switchto))
			active_tool = null
		else
			if (src.active_tool && isitem(src.active_tool))
				var/obj/item/I = src.active_tool
				I.dropped(src) // Handle light datums and the like.
			switchto = clamp(switchto, 1, 5)
			active_tool = equipment_slots[switchto]
			if (isitem(src.active_tool))
				var/obj/item/I2 = src.active_tool
				I2.pickup(src) // Handle light datums and the like.

		hud.set_active_tool(switchto)

	click(atom/target, params)
		var/obj/item/equipped = src.active_tool
		var/use_delay = !(target in src.contents) && !istype(target,/atom/movable/screen) && (!disable_next_click || ismob(target) || (target && target.flags & USEDELAY) || (equipped && equipped.flags & USEDELAY))
		if (use_delay && world.time < src.next_click)
			return src.next_click - world.time

		if (GET_DIST(src, target) > 0)
			set_dir(get_dir(src, target))

		var/reach = can_reach(target, src)
		if (equipped && (reach || (equipped.flags & EXTRADELAY)))
			if (use_delay)
				src.next_click = world.time + (equipped ? equipped.click_delay : src.click_delay)

			target.Attackby(equipped, src)
			if (equipped)
				equipped.AfterAttack(target, src, reach)

			if (src.lastattacked == target && use_delay) //If lastattacked was set, this must be a combat action!! Use combat click delay.
				src.next_click = world.time + (equipped ? max(equipped.click_delay,src.combat_click_delay) : src.combat_click_delay)
				src.lastattacked = null

	bump(atom/movable/AM as mob|obj)
		SPAWN( 0 )
			if (src.now_pushing)
				return
			..()
			if (!istype(AM, /atom/movable))
				return
			if (!src.now_pushing)
				src.now_pushing = 1
				if (!AM.anchored)
					var/t = get_dir(src, AM)
					step(AM, t)
				src.now_pushing = null
			return
		return

	say(var/message)
		if (!message)
			return

		if (src.client && src.client.ismuted())
			boutput(src, "You are currently muted.")
			return

		if (isdead(src))
			message = trimtext(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			return src.say_dead(message)

		// wtf?
		if (src.stat)
			return

		if (copytext(message, 1, 2) == "*")
			..()
		else
			src.visible_message("<b>[src]</b> beeps.")
			playsound(src.loc, beeps_n_boops[1], 30, 1)

	emote(var/act)
		..()
		//var/param = null
		if (findtext(act, " ", 1, null))
			var/t1 = findtext(act, " ", 1, null)
			//param = copytext(act, t1 + 1, length(act) + 1)
			act = copytext(act, 1, t1)

		var/message
		var/sound/emote_sound = null

		switch(act)
			if ("help")
				boutput(src, "To use emotes, simply enter \"*(emote)\" as the entire content of a say message. Certain emotes can be targeted at other characters - to do this, enter \"*emote (name of character)\" without the brackets.")
				boutput(src, "For a list of basic emotes, use *listbasic. For a list of emotes that can be targeted, use *listtarget.")
			if ("listbasic")
				boutput(src, "ping, chime, madbuzz, sadbuzz")
			if ("listtarget")
				boutput(src, "Drones do not currently have any targeted emotes.")
			if ("ping")
				emote_sound = beeps_n_boops[2]
				message = "<B>[src]</B> pings!"
			if ("chime")
				emote_sound = beeps_n_boops[3]
				message = "<B>[src]</B> emits a pleased chime."
			if ("madbuzz")
				emote_sound = beeps_n_boops[4]
				message = "<B>[src]</B> buzzes angrily!"
			if ("sadbuzz")
				emote_sound = beeps_n_boops[5]
				message = "<B>[src]</B> buzzes dejectedly."
			if ("glitch","malfunction")
				playsound(src.loc, pick(glitchy_noise), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
				src.visible_message(SPAN_ALERT("<B>[src]</B> freaks the fuck out! That's [pick(glitch_con)] [pick(glitch_adj)]!"))
				animate_glitchy_freakout(src)
				return

		if (emote_sound)
			playsound(src.loc, emote_sound, 50, 1, channel=VOLUME_CHANNEL_EMOTE)
		if (message)
			src.visible_message(message)
		return

	get_equipped_ore_scoop()
		if(src.equipment_slots[1] && istype(src.equipment_slots[1],/obj/item/ore_scoop))
			return equipment_slots[1]
		else if(src.equipment_slots[2] && istype(src.equipment_slots[2],/obj/item/ore_scoop))
			return equipment_slots[2]
		else if(src.equipment_slots[3] && istype(src.equipment_slots[3],/obj/item/ore_scoop))
			return equipment_slots[3]
		else if(src.equipment_slots[4] && istype(src.equipment_slots[4],/obj/item/ore_scoop))
			return equipment_slots[4]
		else if(src.equipment_slots[5] && istype(src.equipment_slots[5],/obj/item/ore_scoop))
			return equipment_slots[5]
		else
			return null

	proc/connect_to_drone(var/mob/living/L)
		if (!L || !src)
			return 1
		if (controller)
			return 2

		boutput(L, "You connect to [src.name].")
		controller = L
		L.mind.transfer_to(src)
		return 0

	proc/disconnect_user()
		if (!controller)
			return

		boutput(controller, "You were disconnected from [src.name].")
		src.mind.transfer_to(controller)
		controller = null

// DRONE ITEM/OBJ STUFF, TRANSFER IT ELSEWHERE LATER

/obj/drone_frame
	name = "drone frame"
	desc = "It's a remote-controlled drone in the middle of being constructed."
	icon = 'icons/mob/drone.dmi'
	icon_state = "frame-0"
	opacity = 0
	density = 0
	anchored = UNANCHORED
	var/construct_stage = 0
	var/obj/item/device/radio/part_radio = null
	var/obj/item/cell/part_cell = null
	var/obj/item/parts/robot_parts/drone/propulsion/part_propulsion = null
	var/obj/item/parts/robot_parts/drone/plating/part_plating = null
	var/obj/item/cable_coil/cable_type = null

	proc/change_stage(var/change_to,var/mob/user,var/obj/item/item_used)
		if (!isnum(change_to))
			return
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		if (user && item_used)
			user.drop_item()
			item_used.set_loc(src)

		icon_state = "frame-" + clamp(change_to, 0, 6)
		overlays = list()
		if (part_propulsion?.drone_overlay)
			overlays += part_propulsion.drone_overlay

	examine()
		. = ..()
		switch(construct_stage)
			if(0)
				. += "It's nothing but a pile of scrap right now. Wrench the parts together to build it up or weld it back down to metal sheets."
			if(1)
				. += "It's still a bit rickety. Weld it to make it more secure or wrench it to take it apart."
			if(2)
				. += "It needs cabling. Add some to build it up or take the circuit board out to deconstruct it."
			if(3)
				. += "A radio needs to be added, or you could take the cabling out to deconstruct it."
			if(4)
				. += "A power cell needs to be added, or you could remove the radio to deconstruct it."
			if(5)
				. += "It needs a propulsion system, or you could remove the power cell to deconstruct it."
			if(6)
				. += "It looks almost finished, all that's left to add is extra optional components.\nWrench it together to activate it, or remove all parts and the power cell to deconstruct it."

	attack_hand(var/mob/user)
		switch(construct_stage)
			if(3)
				user.put_in_hand_or_drop(cable_type)
				cable_type = null
				change_stage(2)
			if(4)
				user.put_in_hand_or_drop(part_radio)
				part_radio = null
				change_stage(3)
			if(5)
				user.put_in_hand_or_drop(part_cell)
				part_cell = null
				change_stage(4)
			if(6)
				user.put_in_hand_or_drop(part_propulsion)
				part_propulsion = null
				change_stage(5)
			else
				boutput(user, "You can't figure out what to do with it. Maybe a closer examination is in order.")

	attackby(obj/item/W, mob/user)
		if(isweldingtool(W))
			if(W:try_weld(user, 1))
				switch(construct_stage)
					if(0)
						src.visible_message("<b>[user]</b> welds [src] back down to metal.")
						var/obj/item/sheet/S = new /obj/item/sheet(src.loc)
						S.amount = 5

						if(src.material)
							S.setMaterial(src.material)
						else
							var/datum/material/M = getMaterial("steel")
							S.setMaterial(M)

						qdel(src)
					if(1)
						src.visible_message("<b>[user]</b> welds [src]'s joints together.")
						src.construct_stage = 2
					if(2)
						src.visible_message("<b>[user]</b> disconnects [src]'s welded joints.")
						src.construct_stage = 1
					else
						boutput(user, SPAN_ALERT("[user.real_name], there's a time and a place for everything! But not now."))

		else if (iswrenchingtool(W))
			switch(construct_stage)
				if(0)
					change_stage(1)
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					src.visible_message("<b>[user]</b> wrenches together [src]'s parts.")
				if(1)
					change_stage(0)
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					src.visible_message("<b>[user]</b> wrenches [src] apart.")
				if(6)
					var/confirm = alert("Finish and activate the drone?","Drone Assembly","Yes","No")
					if (confirm != "Yes")
						return
					src.visible_message("<b>[user]</b> finishes up and activates [src].")
					playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
					var/mob/living/silicon/drone/D = new /mob/living/silicon/drone(src.loc)
					if (part_cell)
						D.cell = part_cell
						part_cell.set_loc(D)
					if (part_radio)
						D.radio = part_radio
						part_radio.set_loc(D)
					if (part_propulsion)
						D.propulsion = part_propulsion
						part_propulsion.set_loc(D)
					if (part_plating)
						D.plating = part_plating
						part_plating.set_loc(D)
					qdel(src)
				else
					boutput(user, SPAN_ALERT("There's lots of good times to use a wrench, but this isn't one of them."))

		else if(istype(W, /obj/item/cable_coil) && construct_stage == 2)
			var/obj/item/cable_coil/C = W
			src.visible_message("<b>[user]</b> adds [C] to [src].")
			cable_type = C.split_stack(1)
			cable_type.set_loc(src)
			change_stage(3)

		else if(istype(W, /obj/item/device/radio) && construct_stage == 3)
			src.visible_message("<b>[user]</b> adds [W] to [src].")
			src.part_radio = W
			change_stage(4,user,W)

		else if(istype(W, /obj/item/cell) && construct_stage == 4)
			src.visible_message("<b>[user]</b> adds [W] to [src].")
			src.part_cell = W
			change_stage(5,user,W)

		else if(istype(W, /obj/item/parts/robot_parts/drone/propulsion) && construct_stage == 5)
			src.visible_message("<b>[user]</b> adds [W] to [src].")
			src.part_propulsion = W
			change_stage(6,user,W)

		else
			..()

// DRONE PARTS

/obj/item/parts/robot_parts/drone
	name = "drone part"
	icon = 'icons/mob/drone.dmi'
	desc = "It's a component intended for remote controlled drones. This one happens to be invisible and unusable. Some things are like that."
	var/image/drone_overlay = null

/obj/item/parts/robot_parts/drone/propulsion
	name = "drone wheels"
	desc = "The most cost-effective movement available for drones. Won't do very good in space, though!"
	var/speed = 0

	New()
		..()
		drone_overlay = image('icons/mob/drone.dmi',"wheels")

/obj/item/parts/robot_parts/drone/plating
	name = "drone plating"
	desc = "Armor for a remote controlled drone."

	New()
		..()
		drone_overlay = image('icons/mob/drone.dmi',"plating-0")
