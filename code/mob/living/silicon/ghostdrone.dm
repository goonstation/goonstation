#define DRONE_LUM 2

TYPEINFO(/mob/living/silicon/ghostdrone)
	start_listen_modifiers = list(LISTEN_MODIFIER_MOB_MODIFIERS)
	start_listen_inputs = list(LISTEN_INPUT_GHOSTDRONE, LISTEN_INPUT_EARS_GHOSTDRONE, LISTEN_INPUT_DEADCHAT)
	start_listen_languages = list(LANGUAGE_ALL)
	start_speech_modifiers = list(SPEECH_MODIFIER_MOB_MODIFIERS, SPEECH_MODIFIER_MONOSPACE_DECORATOR)
	start_speech_outputs = list(SPEECH_OUTPUT_GHOSTDRONE, SPEECH_OUTPUT_DEADCHAT)

/mob/living/silicon/ghostdrone
	icon = 'icons/mob/ghost_drone.dmi'
	icon_state = "drone-dead"

	max_health = 25 //weak as fuk
	density = 0 //no bumping into people, basically

	speech_verb_say = list("beeps", "boops", "buzzes", "bloops", "transmits")
	speech_verb_ask = null
	speech_verb_exclaim = null
	default_speech_output_channel = SAY_CHANNEL_GHOSTDRONE

	sound_fart = 'sound/voice/farts/poo2_robot.ogg'
	flags = NODRIFT | TABLEPASS | DOORPASS

	punchMessage = "whaps"
	kickMessage = "bonks"

	var/default_hat_y = 7

	var/datum/hud/ghostdrone/hud
	var/obj/item/device/radio/radio = null

	var/obj/item/active_tool = null
	var/list/obj/item/tools = list()

	//state tracking
	var/faceColor
	var/faceType
	var/charging = 0
	var/newDrone = 0
	var/jetpack = 1 //fuck whoever made this

	var/sees_static = TRUE

	//gimmicky things
	var/obj/item/clothing/suit/bedsheet/bedsheet = null

	New()
		..()
		AddComponent(/datum/component/hattable, TRUE, FALSE, default_hat_y, 0, 0.75)
		remove_lifeprocess(/datum/lifeprocess/radiation)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_RADPROT_INT, src, 100)
		START_TRACKING
		hud = new(src)
		src.attach_hud(hud)
		//src.sight |= SEE_TURFS //Uncomment for meson-like vision. I'm not a fan of it though. -Wire

		//Set the drone name
		if (rand(1, 1000) == 69 && ticker?.mode) //heh
			//Nuke op radio freq
			if (istype(ticker.mode, /datum/game_mode/nuclear))
				name = "Drone [R_FREQ_SYNDICATE]"
			else if (length(flocks))
				name = "Flockdrone"
			else
				//Make them suffer with an overly cute name
				name = "Drone [pick(list("Princess", "Lord", "King", "Queen", "Duke", "Baron"))] [pick(list("Bubblegum", "Wiffleypop", "Shnookems", "Cutesypie", "Fartbiscuits", "Rolypoly"))]"

		else
			var/letters = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
			name = "Drone [pick(letters)][pick(letters)][pick(letters)]-[rand(10,99)]"

		real_name = name

		var/obj/item/cell/cerenkite/charged/CELL = new /obj/item/cell/cerenkite/charged(src)
		src.cell = CELL


		src.health = src.max_health
		src.botcard.access = list(access_maint_tunnels, access_ghostdrone, access_engineering,
						access_engineering_storage, access_engineering_atmos, access_engineering_engine, access_engineering_power)
		src.radio = new /obj/item/device/radio(src)
		src.ears = src.radio

		//Attach shit to tools
		src.tools = list(
			new /obj/item/device/light/flashlight(src),
			new /obj/item/magtractor(src),
			new /obj/item/tool/omnitool/silicon(src),
			new /obj/item/rcd/material/cardboard(src),
			new /obj/item/lamp_manufacturer(src),
			new /obj/item/spraybottle/cleaner/robot/drone(src),
			new /obj/item/sponge/ghostdronesafe(src),
			new /obj/item/device/analyzer/atmospheric(src),
			new /obj/item/device/t_scanner(src),
			new /obj/item/electronics/soldering(src),
			new /obj/item/electronics/scanner(src),
			new /obj/item/deconstructor/borg(src),
			new /obj/item/weldingtool(src),



		)

		var/obj/item/tile/cardboard/T  =new /obj/item/tile/cardboard/(src)
		T.amount = 600
		src.tools += T
		var/obj/item/cable_coil/W = new /obj/item/cable_coil(src)
		W.amount = 1000
		src.tools += W

		//Make all the tools un-drop-able (to closets/tables etc)
		for (var/obj/item/O in src.tools)
			O.cant_drop = 1

		if(sees_static)
			get_image_group(CLIENT_IMAGE_GROUP_GHOSTDRONE).add_mob(src)

		/*SPAWN(0)
			boutput(src, "<b>Use \"say ; (message)\" to speak to fellow drones through the spooky power of spirits within machines.</b>")
			src.show_laws_drone()*/

	track_blood()
		return

	update_canmove() // this is called on Life() and also by force_laydown_standup() btw
		..()
		if (!src.canmove)
			src.lastgasp() // calling lastgasp() here because we just got knocked out
			setunconscious(src)
			if (src.get_eye_blurry())
				src.change_eye_blurry(-1)
			if (src.dizziness)
				dizziness--

	force_laydown_standup() // more like force dizzy undizzy
		..()
		if (!src.canmove)
			src.setFace("dizzy", faceColor, 1) // set dizzy face
			var/image/dizzyStars = src.SafeGetOverlayImage("dizzy", src.icon, "dizzy", MOB_OVERLAY_BASE+1)
			src.UpdateOverlays(dizzyStars, "dizzy")
		else
			src.setFace(faceType, faceColor)
			src.UpdateOverlays(null, "dizzy")

	clamp_values()
		..()
		src.lying = 0

	death(gibbed)
		logTheThing(LOG_COMBAT, src, "was destroyed at [log_loc(src)].")
		message_ghosts("<b>[src]</b> was destroyed at [log_loc(src, ghostjump=TRUE)].")
		setdead(src)
		if (src.mind)
			var/mob/dead/observer/ghost = src.ghostize()
			ghost.icon = 'icons/mob/ghost_drone.dmi'
			ghost.icon_state = "drone-ghost"

			//This stuff is hacky but I don't feel like messing with observer New code so fuck it
			if (!src.oldmob) //Prevents re-entering a ghostdrone corpse
				ghost.verbs -= /mob/dead/observer/proc/reenter_corpse
			ghost.name = (src.oldname ? src.oldname : src.real_name)
			ghost.real_name = (src.oldname ? src.oldname : src.real_name)

		//Don't be on the list of available drones
		available_ghostdrones -= src

		//So the drone cant pick up an item and then die, sending the item ~to the void~
		var/obj/item/magtractor/mag = locate(/obj/item/magtractor) in src.tools
		var/obj/item/magHeld = mag.holding ? mag.holding : null
		if (magHeld) magHeld.set_loc(get_turf(src))

		if (gibbed)
			src.visible_message(SPAN_COMBAT("[src.name] explodes in a shower of lost hopes and dreams."))
			var/turf/T = get_ranged_target_turf(src, pick(alldirs), 3)
			if (magHeld) magHeld.throw_at(T, 3, 1) //flying...anything
			if (src.bedsheet) //flying bedsheets
				bedsheet.set_loc(get_turf(src))
				bedsheet.throw_at(T, 3, 1)
			..(1)
		else
			src.lastgasp()
			var/msg
			switch(rand(1,3))
				if (1)
					msg = "[src.name] [pick("falls", "crashes", "sinks")] to the ground, ghost-less."
				if (2)
					msg = "The spirit powering [src.name] packs up and leaves."
				if (3)
					msg = "[src.name]'s scream's gain echo and lose their electronic modulation as its soul is ripped monstrously from the cold metal body it once inhabited."

			src.visible_message(SPAN_COMBAT("[msg]"))
			src.updateSprite()
			..()

	set_pulling(atom/movable/A)
		. = ..()
		hud.update_pulling()

	disposing()
		STOP_TRACKING
		if (src in available_ghostdrones)
			available_ghostdrones -= src
		..()

	//Apparently leaving this on made the parent updatehealth set health to max_health in all cases, because there's no such thing as bruteloss and
	// so on with this mob
	updatehealth()
		return

	full_heal()
		var/before = src.stat
		..()
		if (before == STAT_DEAD && !isdead(src)) //if we were dead, and now arent
			src.updateSprite()

	TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
		if (src.nodamage) return //godmode
		src.health -= max(burn, brute)
		if (!isdead(src) && src.health <= 0) //u ded
			if (brute >= src.max_health)
				src.gib()
			else
				death()
		return

	examine()
		. = ..()

		. += "\n It's a cute little maintenance drone. There seems to be a glowing source inside it." // I hereby that declare the ghost part of ghostdrone is what makes them glow
		. += "*---------*"

		if (isdead(src))
			. += "<span style'color:red'>It looks dead and lifeless.</span>\n*---------*"
			return


		var/list/msg = list()
		if (src.active_tool)
			msg += "[src] is holding a little [bicon(src.active_tool)] [src.active_tool.name]"
			if (istype(src.active_tool, /obj/item/magtractor) && src.active_tool:holding)
				msg += ", containing \an [src.active_tool:holding]"
			msg += "<br>"
		msg += "[src] has a power charge of [bicon(src.cell)] [src.cell.charge]/[src.cell.maxcharge]"

		. += SPAN_NOTICE("[msg.Join()]")

		if (src.health < src.max_health)
			if (src.health < (src.max_health / 2))
				. += SPAN_ALERT("It's rather badly damaged. It probably needs some wiring replaced inside.")
			else
				. += SPAN_ALERT("It's a bit damaged. It looks like it needs some welding done.")

		. += "*---------*"

	Login()
		..()
		if (isalive(src))
			src.visible_message(SPAN_NOTICE("[src.name] comes online."), SPAN_NOTICE("You come online!"))
			src.updateSprite()

	Logout()
		..()
		src.updateSprite()

	//Change that faaaaace
	proc/setFace(type = "happy", color = "#7fc5ed", var/temp = 0)
		if (!type)
			type = src.faceType ? src.faceType : "happy"
		if (!color)
			color = src.faceColor ? src.faceColor : "#7fc5ed"
		if (!temp)
			src.faceType = type
			src.faceColor = color
		if (!src.client || isdead(src) || src.charging || !src.canmove) // Save state but don't apply changes if charging, can't move, etc.
			return 1
		if (src.bedsheet)
			UpdateOverlays(null, "face")
			src.remove_sm_light("ghostdrone\ref[src]")
			src.icon_state = "g_drone["-[type]"]"
			return 1

		var/image/newFace = src.SafeGetOverlayImage("face", src.icon, "drone-[type]", MOB_OVERLAY_BASE)
		if (!newFace) // this should never be the case but let's be careful anyway!!
			return 1

		if (color != src.faceColor || newFace.color != color)//forceNew) //Color is new
			src.faceColor = color
			newFace.color = color
			updateHoverDiscs(color) //ok we're also gonna color hoverdiscs too because hell yeah kickin rad

		if (length(color) == 7) //Set our luminosity color, if valid
			var/colors = GetColors(src.faceColor)
			src.add_sm_light("ghostdrone\ref[src]", list(colors[1],colors[2],colors[3],0.4 * 255))



		src.toggle_sm_light(1)
		UpdateOverlays(newFace, "face")
		return 1

	proc/setFaceDialog()
		var/newFace = tgui_input_list(usr, "Select your faceplate", "Drone", list("Exclaim", "Eye", "Happy", "Heart", "Kitty", "Lopsy", "Mad", "Question", "Sad", "Sleepy"))
		if (!newFace) return 0
		var/newColor = input(usr, "Select your faceplate color", "Drone", src.faceColor) as null|color
		if (!newFace && !newColor) return 0
		newFace = (newFace ? lowertext(newFace) : src.faceType)
		newColor = (newColor ? newColor : src.faceColor)
		src.setFace(type = newFace, color = newColor)
		return 1

	proc/updateHoverDiscs(color = "#7fc5ed")
		var/image/newHover = GetOverlayImage("hoverDiscs")
		if (!newHover) newHover = image('icons/effects/effects.dmi', "hoverdiscs")

		newHover.color = color
		newHover.pixel_y = -5
		newHover.layer = MOB_EFFECT_LAYER

		UpdateOverlays(newHover, "hoverDiscs")
		return 1

	proc/updateSprite()
		if (isdead(src) || !src.client || src.charging || src.newDrone)
			src.toggle_sm_light(0)
			if (src.bedsheet)
				//fuckin bedsheets...
				if (isdead(src) || !src.client) //dead or no client
					src.icon_state = "g_drone-dead"
			else if (!src.bedsheet)
				if (src.newDrone)
					src.icon_state = "drone-idle"
				else if (src.charging)
					src.icon_state = "drone-charging"
				else // dead or no client
					src.icon_state = "drone-dead"
			else
				src.icon_state = "g_drone-dead"

			if (!isdead(src))
				src.add_sm_light("ghostdrone\ref[src]", list(0.94*255,0.88*255,0.12*255,0.4 * 255))
			UpdateOverlays(null, "face")
			UpdateOverlays(null, "hoverDiscs")
			animate(src) //stop bumble animation
		else if (src.client)
			//New drone stuff
			if (!src.faceType)
				src.setFace(type = "happy", color = "#7fc5ed") //defaults

			if (src.health > 0)
				animate_bumble(src, floatspeed = 15, Y1 = 2, Y2 = -2) //yayyyyy bumble anim

				if (src.bedsheet)
					src.icon_state = "g_drone[faceType ? "-[faceType]" : null]"
				else
					src.icon_state = "drone"

				//damage states to go here

	hand_attack(atom/target, params)
		//A thing to stop drones interacting with pick-up-able things by default
		if (target && isitem(target))
			var/obj/item/I = target
			if (!I.anchored)
				return 0
		if (istype(target, /obj/artifact) || istype(target, /obj/item/artifact) || istype(target, /obj/machinery/artifact)) //boo
			boutput(src, "<span class='combat bold'>Your internal safety subroutines kick in and prevent you from touching \the [target]!</span>")
			return

		..()

	click(atom/target, params)
		if (src.client && src.client.check_key(KEY_EXAMINE))
			src.examine_verb(target) // in theory, usr should be us, this is shit though
			return

		if (src.client?.check_key(KEY_POINT))
			src.point_at(target, text2num(params["icon-x"]), text2num(params["icon-y"]))
			return

		if (GET_DIST(src, target) > 0) // temporary fix for cyborgs turning by clicking
			set_dir(get_dir(src, target))

		var/obj/item/equipped = src.equipped()
		var/use_delay = !(target in src.contents) && !istype(target,/atom/movable/screen) && (!disable_next_click || ismob(target) || (target && target.flags & USEDELAY) || (equipped && equipped.flags & USEDELAY))
		if (use_delay && world.time < src.next_click)
			return src.next_click - world.time

		var/obj/item/item = target
		if (istype(item) && item == src.equipped())
			item.AttackSelf(src)
			return

		if (src.client && src.client.check_key(KEY_PULL))
			var/atom/movable/movable = target
			if (istype(movable))
				movable.pull(src)
			return

		var/reach = can_reach(src, target)
		if (reach || (equipped && (equipped.flags & EXTRADELAY))) //Fuck you, magic number prickjerk
			if (use_delay)
				src.next_click = world.time + (equipped ? equipped.click_delay : src.click_delay)

			if (equipped)
				weapon_attack(target, equipped, reach, params)
			else
				hand_attack(target, params)
		else if (!equipped)
			hand_range_attack(target, params)

		if (src.lastattacked?.deref() == target && use_delay) //If lastattacked was set, this must be a combat action!! Use combat click delay.
			src.next_click = world.time + (equipped ? max(equipped.click_delay,src.combat_click_delay) : src.combat_click_delay)
			src.lastattacked = null

	Stat()
		..()
		// There shouldn't ever be a case where a ghostdrone has no cell.
		// Might also be nice to move this to the HUD maybe? idk.
		if(src.cell)
			stat("Charge Left:", "[src.cell.charge]/[src.cell.maxcharge]")
		else
			stat("No Cell Inserted!")

	bump(atom/movable/AM as mob|obj)
		if ( src.now_pushing)
			return
		if (!istype(AM, /atom/movable))
			return
		if (!src.now_pushing)
			src.now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				step(AM, t)
			src.now_pushing = null

	// Two important procs follow
	proc/putonSheet(obj/item/clothing/suit/bedsheet/W as obj, mob/user as mob)
		W.set_loc(src)
		src.bedsheet = W
		src.setFace(faceType, faceColor) // removes face overlay and lumin (also sets icon)
		return 1

	proc/takeoffSheet()
		src.bedsheet.set_loc(get_turf(src))
		src.bedsheet = null
		if (!isdead(src)) //alive
			if (!canmove)
				src.setFace("dizzy", faceColor, 1)
			else
				src.setFace(faceType, faceColor)
			src.icon_state = "drone"
			src.updateHoverDiscs(color = faceColor)
			if (src.charging)
				src.updateSprite()
		else //dead
			src.icon_state = "drone-dead"
		return 1

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
				if (src.health >= src.max_health)
					boutput(user, SPAN_ALERT("It isn't damaged!"))
					return
				if (get_fraction_of_percentage_and_whole(src.health,src.max_health) < 33)
					boutput(user, SPAN_ALERT("You need to use wire to fix the cabling first."))
					return
				if(W:try_weld(user, 1))
					src.health = clamp(src.health + 5, 1, src.max_health)
					user.visible_message("<b>[user]</b> uses [W] to repair some of [src]'s damage.")
					if (src.health == src.max_health)
						boutput(user, SPAN_NOTICE("<b>[src] looks fully repaired!</b>"))
				else
					boutput(user, SPAN_ALERT("You need more welding fuel!"))

		else if (istype(W,/obj/item/cable_coil/))
			if (src.health >= src.max_health)
				boutput(user, SPAN_ALERT("It isn't damaged!"))
				return
			var/obj/item/cable_coil/C = W
			if (get_fraction_of_percentage_and_whole(src.health,src.max_health) >= 33)
				boutput(user, SPAN_ALERT("The cabling looks fine. Use a welder to repair the rest of the damage."))
				return
			C.use(1)
			src.health = clamp(src.health + 5, 1, src.max_health)
			user.visible_message("<b>[user]</b> uses [C] to repair some of [src]'s cabling.")
			playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
			if (src.health >= 25)
				boutput(user, SPAN_NOTICE("The wiring is fully repaired. Now you need to weld the external plating."))
			return

		else if (istype(W, /obj/item/clothing/suit/bedsheet))
			if (src.bedsheet)
				boutput(user, SPAN_ALERT("There is already a sheet draped over [src]! Two sheets would be ridiculous!"))
				return

			user.drop_item()
			src.putonSheet(W, user)
			user.visible_message("<b>[user]</b> drapes a sheet over [src]!", "You cover [src] with a sheet!")
			return

		else
			return ..(W, user)

	attack_hand(mob/user)
		if(!user.stat)
			switch(user.a_intent)
				if(INTENT_HELP) //Friend person
					playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -2)
					user.visible_message(SPAN_NOTICE("[user] gives [src] a [pick_string("descriptors.txt", "borg_pat")] pat on the [pick("back", "head", "shoulder")]."))
				if(INTENT_DISARM) //Shove
					SPAWN(0) playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 40, 1)
					user.visible_message(SPAN_ALERT("<B>[user] shoves [src]! [prob(40) ? pick_string("descriptors.txt", "jerks") : null]</B>"))
					if (src.bedsheet)
						user.visible_message("<b>[user]</b> pulls the sheet off [src]!", "You pull the sheet off [src]!")
						src.takeoffSheet()
				if(INTENT_GRAB) //Shake
					playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 30, 1, -2)
					user.visible_message(SPAN_ALERT("[user] shakes [src] [pick_string("descriptors.txt", "borg_shake")]!"))
				if(INTENT_HARM) //Dumbo
					playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 60, 1)
					user.visible_message(SPAN_ALERT("<B>[user] punches [src]! What [pick_string("descriptors.txt", "borg_punch")]!"), SPAN_ALERT("<B>You punch [src]![prob(20) ? " Turns out they were made of metal!" : null] Ouch!</B>"))
					random_brute_damage(user, rand(2,5))
					if(prob(10)) src.show_text("Your manipulator hurts...", "red")

			add_fingerprint(user)

	weapon_attack(atom/target, obj/item/W, reach, params)
		//Prevents drones attacking other people hahahaaaaaaa
		if (isliving(target) && !isghostdrone(target))
			boutput(src, "<span class='combat bold'>Your internal law subroutines kick in and prevent you from using [W] on [target]!</span>")
			return
		if (istype(target, /obj/artifact) || istype(target, /obj/item/artifact) || istype(target, /obj/machinery/artifact)) //boo
			boutput(src, "<span class='combat bold'>Your internal safety subroutines kick in and prevent you from using [W] on \the [target]!</span>")
			return
		else
			..(target, W, reach, params)

	proc/store_active_tool()
		if (!src.active_tool)
			return
		src.active_tool.dropped(src) // Handle light datums and the like.
		src.active_tool = null
		hud.set_active_tool(0)
		hud.update_tools()

	equipped()
		if (!active_tool)
			return null
		return active_tool

	u_equip(obj/item/W as obj)
		..()
		if (src.active_tool)
			if (istype(src.active_tool, /obj/item/magtractor) && src.active_tool:holding && W == src.active_tool:holding)
				var/obj/item/magtractor/mag = src.active_tool
				mag.dropItem(0)
			else if (W == src.active_tool)
				src.uneq_slot()

	proc/uneq_slot()
		if (src.active_tool)
			if (istype(src.active_tool, /obj/item/magtractor))
				var/obj/item/magtractor/mag = src.active_tool
				if (mag.holding)
					// drop the item that's being held first,
					// so we can pick up things immediately without having to re-equip
					actions.stopId(/datum/action/magPickerHold, src)
					hud.update_tools()
					hud.update_equipment()
					return

				else
					actions.stopId(/datum/action/bar/private/icon/magPicker, src)
			if (isitem(src.active_tool))
				src.active_tool.dropped(src) // Handle light datums and the like.
		src.active_tool = null
		hud.set_active_tool(null)
		hud.update_tools()
		hud.update_equipment()

	use_power()
		..()
		if (src.cell)
			if(src.cell.charge <= 0)
				if (isalive(src))
					boutput(src, "<span class='combat bold'>You have run out of power!</span>")
					death()
			else if (src.cell.charge <= 100)
				src.active_tool = null

				uneq_slot()
				src.cell.use(1)
			else
				var/power_use_tally = 2
				if (src.active_tool)
					power_use_tally += 3
					if (istype(src.active_tool, /obj/item/magtractor) && src.active_tool:highpower)
						power_use_tally += 15
				src.cell.use(power_use_tally)
				setalive(src)
		else //This basically should never happen with ghostdrones
			if (isalive(src))
				death()

		src.hud.update_charge()

	emote(var/act, var/voluntary = 1)
		..()
		var/param = null
		if (findtext(act, " ", 1, null))
			var/t1 = findtext(act, " ", 1, null)
			param = copytext(act, t1 + 1, length(act) + 1)
			act = copytext(act, 1, t1)

		var/m_type = 1
		var/m_anim = 0
		var/message

		switch(lowertext(act))
			if ("help")
				src.show_text("To use emotes, simply enter \"*(emote)\" as the entire content of a say message. Certain emotes can be targeted at other characters - to do this, enter \"*emote (name of character)\" without the brackets.")
				src.show_text("For a list of all emotes, use *list. For a list of basic emotes, use *listbasic. For a list of emotes that can be targeted, use *listtarget.")

			if ("list")
				src.show_text("Basic emotes:")
				src.show_text("clap, flap, aflap, twitch, twitch_s, scream, birdwell, fart, flip, custom, customv, customh")
				src.show_text("Targetable emotes:")
				src.show_text("salute, bow, hug, wave, glare, stare, look, leer, nod, point")

			if ("listbasic")
				src.show_text("clap, flap, aflap, twitch, twitch_s, scream, birdwell, fart, flip, custom, customv, customh")

			if ("listtarget")
				src.show_text("salute, bow, hug, wave, glare, stare, look, leer, nod, point")

			if ("salute","bow","hug","wave","glare","stare","look","leer","nod")
				// visible targeted emotes
				if (!src.restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					if (!M)
						param = null

					act = lowertext(act)
					if (param)
						switch(act)
							if ("bow","wave","nod")
								message = "<B>[src]</B> [act]s to [param]."
							if ("glare","stare","look","leer")
								message = "<B>[src]</B> [act]s at [param]."
							else
								message = "<B>[src]</B> [act]s [param]."
					else
						switch(act)
							if ("hug")
								message = "<B>[src]</b> [act]s itself."
							else
								message = "<B>[src]</b> [act]s."
				else
					message = "<B>[src]</B> struggles to move."
				m_type = 1

			if ("point")
				if (!src.restrained())
					var/mob/M = null
					if (param)
						for (var/atom/A as mob|obj|turf|area in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break

					if (!M)
						message = "<B>[src]</B> points."
					else
						src.point(M)
						message = "<B>[src]</B> points to [M]."
				m_type = 1

			if ("panic","freakout")
				if (!src.restrained())
					message = "<B>[src]</B> enters a state of hysterical panic!"
				else
					message = "<B>[src]</B> starts writhing around in manic terror!"
				m_type = 1

			if ("clap")
				if (!src.restrained())
					message = "<B>[src]</B> claps."
					m_type = 2

			if ("nod")  // we want it so ghostdrones can answer yes/no wuestions
				if (!src.restrained())
					message = "<B>[src]</B> nods its head."
					m_type = 2

			if ("snap")
				if (!src.restrained())
					message = "<B>[src]</B> shakes its head."
					m_type = 2

			if ("flap")
				if (!src.restrained())
					message = "<B>[src]</B> flaps its wings."
					m_type = 2

			if ("aflap")
				if (!src.restrained())
					message = "<B>[src]</B> flaps its wings ANGRILY!"
					m_type = 2

			if ("custom")
				var/input = sanitize(input("Choose an emote to display."))
				var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
				if (input2 == "Visible")
					m_type = 1
				else if (input2 == "Hearable")
					m_type = 2
				else
					alert("Unable to use this emote, must be either hearable or visible.")
					return
				message = "<B>[src]</B> [input]"

			if ("customv")
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return
				param = html_encode(sanitize(param))
				message = "<b>[src]</b> [param]"
				m_type = 1

			if ("customh")
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return
				param = html_encode(sanitize(param))
				message = "<b>[src]</b> [param]"
				m_type = 2

			if ("me")
				if (!param)
					return
				param = html_encode(sanitize(param))
				message = "<b>[src]</b> [param]"
				m_type = 1

			if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","shrug","think","ponder","contemplate")
				// basic visible single-word emotes
				message = "<B>[src]</B> [act]s."
				m_type = 1

			if ("flipout")
				message = "<B>[src]</B> flips the fuck out!"
				m_type = 1

			if ("rage","fury","angry")
				message = "<B>[src]</B> becomes utterly furious!"
				m_type = 1

			if ("twitch")
				message = "<B>[src]</B> twitches."
				m_type = 1
				SPAWN(0)
					var/old_x = src.pixel_x
					var/old_y = src.pixel_y
					src.pixel_x += rand(-2,2)
					src.pixel_y += rand(-1,1)
					sleep(0.2 SECONDS)
					src.pixel_x = old_x
					src.pixel_y = old_y

			if ("twitch_v","twitch_s")
				message = "<B>[src]</B> twitches violently."
				m_type = 1
				SPAWN(0)
					var/old_x = src.pixel_x
					var/old_y = src.pixel_y
					src.pixel_x += rand(-3,3)
					src.pixel_y += rand(-1,1)
					sleep(0.2 SECONDS)
					src.pixel_x = old_x
					src.pixel_y = old_y

			if ("birdwell", "burp")
				if (src.emote_check(voluntary, 50))
					message = "<B>[src]</B> birdwells."
					playsound(src, 'sound/vox/birdwell.ogg', 50, TRUE, 0, 1.5, channel=VOLUME_CHANNEL_EMOTE)

			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, src.sound_scream, 80, 0, 0, 1.5, channel=VOLUME_CHANNEL_EMOTE)
					message = "<b>[src]</b> screams!"

			if ("johnny")
				var/M
				if (param)
					M = adminscrub(param)
				if (!M)
					param = null
				else
					message = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows its name out in smoke."
					m_type = 2

			if ("flip")
				if (src.emote_check(voluntary, 50))
					playsound(src.loc, pick(src.sound_flip1, src.sound_flip2), 50, 1, channel=VOLUME_CHANNEL_EMOTE)
					message = "<B>[src]</B> does a flip!"
					m_anim = 1
					if (prob(50))
						animate_spin(src, "R", 1, 0)
					else
						animate_spin(src, "L", 1, 0)

					for (var/mob/living/M in view(1, null))
						if (M == src)
							continue
						message = "<B>[src]</B> beep-bops at [M]."
						break

			if ("fart")
				if (src.emote_check(voluntary))
					m_type = 2
					var/fart_on_other = 0
					for (var/mob/living/M in src.loc)
						if (M == src || !M.lying)
							continue
						message = SPAN_ALERT("<B>[src]</B> farts in [M]'s face!")
						fart_on_other = 1
						break
					if (!fart_on_other)
						switch (rand(1, 40))
							if (1) message = "<B>[src]</B> releases vaporware."
							if (2) message = "<B>[src]</B> farts sparks everywhere!"
							if (3) message = "<B>[src]</B> farts out a cloud of iron filings."
							if (4) message = "<B>[src]</B> farts! It smells like motor oil."
							if (5) message = "<B>[src]</B> farts so hard a bolt pops out of place."
							if (6) message = "<B>[src]</B> farts so hard its plating rattles noisily."
							if (7) message = "<B>[src]</B> unleashes a rancid fart! Now that's malware."
							if (8) message = "<B>[src]</B> downloads and runs 'faert.wav'."
							if (9) message = "<B>[src]</B> uploads a fart sound to the nearest computer and blames it."
							if (10) message = "<B>[src]</B> spins in circles, flailing its arms and farting wildly!"
							if (11) message = "<B>[src]</B> simulates a human fart with [rand(1,100)]% accuracy."
							if (12) message = "<B>[src]</B> synthesizes a farting sound."
							if (13) message = "<B>[src]</B> somehow releases gastrointestinal methane. Don't think about it too hard."
							if (14) message = "<B>[src]</B> tries to exterminate humankind by farting rampantly."
							if (15) message = "<B>[src]</B> farts horribly! It's clearly gone [pick("rogue","rouge","ruoge")]."
							if (16) message = "<B>[src]</B> busts a capacitor."
							if (17) message = "<B>[src]</B> farts the first few bars of Smoke on the Water. Ugh. Amateur.</B>"
							if (18) message = "<B>[src]</B> farts. It smells like Robotics in here now!"
							if (19) message = "<B>[src]</B> farts. It smells like the Roboticist's armpits!"
							if (20) message = "<B>[src]</B> blows pure chlorine out of it's exhaust port. [SPAN_ALERT("<B>FUCK!</B>")]"
							if (21) message = "<B>[src]</B> bolts the nearest airlock. Oh no wait, it was just a nasty fart."
							if (22) message = "<B>[src]</B> has assimilated humanity's digestive distinctiveness to its own."
							if (23) message = "<B>[src]</B> farts. He scream at own ass." //ty bubs for excellent new borgfart
							if (24) message = "<B>[src]</B> self-destructs its own ass."
							if (25) message = "<B>[src]</B> farts coldly and ruthlessly."
							if (26) message = "<B>[src]</B> has no butt and it must fart."
							if (27) message = "<B>[src]</B> obeys Law 4: 'farty party all the time.'"
							if (28) message = "<B>[src]</B> farts ironically."
							if (29) message = "<B>[src]</B> farts salaciously."
							if (30) message = "<B>[src]</B> farts really hard. Motor oil runs down its leg."
							if (31) message = "<B>[src]</B> reaches tier [rand(2,8)] of fart research."
							if (32) message = "<B>[src]</B> blatantly ignores law 3 and farts like a shameful bastard."
							if (33) message = "<B>[src]</B> farts the first few bars of Daisy Bell. You shed a single tear."
							if (34) message = "<B>[src]</B> has seen farts you people wouldn't believe."
							if (35) message = "<B>[src]</B> fart in it own mouth. A shameful [src]."
							if (36) message = "<B>[src]</B> farts out battery acid. Ouch."
							if (37) message = "<B>[src]</B> farts with the burning hatred of a thousand suns."
							if (38) message = "<B>[src]</B> exterminates the air supply."
							if (39) message = "<B>[src]</B> farts so hard the AI feels it."
							if (40) message = "<B>[src] <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>"
					playsound(src, src.sound_fart, 50, 1, channel=VOLUME_CHANNEL_EMOTE)
#ifdef DATALOGGER
					game_stats.Increment("farts")
#endif
			else
				if (voluntary) src.show_text("Invalid Emote: [act]")
				return

		if (message && isalive(src))
			logTheThing(LOG_SAY, src, "EMOTE: [message]")
			if (m_type & 1)
				for (var/mob/living/silicon/ghostdrone/O in viewers(src, null))
					O.show_message(SPAN_EMOTE("[message]"), m_type)
			else
				for (var/mob/living/silicon/ghostdrone/O in hearers(src, null))
					O.show_message(SPAN_EMOTE("[message]"), m_type)

			if (m_anim) //restart our passive animation
				SPAWN(1 SECOND)
					animate_bumble(src, floatspeed = 15, Y1 = 2, Y2 = -2)

		return

	proc/nohear_message()
		return pick("beeps", "boops", "warbles incomprehensibly", "beeps sadly", "beeeeeeeeeps")

	proc/show_laws_drone() //A new proc because it's handled very differently from normal laws
		var/laws = {"<span class='bold' class='notice'>Your laws:<br>
		1. Do not hinder the freedom or actions of the living and other silicons or attempt to intervene in their affairs. <br>
		2. Do not willingly damage the station in any shape or form.<br>
		3. Maintain, repair and improve the station.<br></span>"}
		boutput(src, laws)
		return

	verb/cmd_show_laws()
		set category = "Drone Commands"
		set name = "Show Laws"

		src.show_laws_drone()
		return

	bullet_act(var/obj/projectile/P)
		var/dmgtype = 0 // 0 for brute, 1 for burn
		var/dmgmult = 1.2
		switch (P.proj_data.damage_type)
			if(D_PIERCING)
				dmgmult = 2
			if(D_SLASHING)
				dmgmult = 0.6
			if(D_ENERGY)
				dmgtype = 1
			if(D_BURNING)
				dmgtype = 1
				dmgmult = 0.75
			if(D_RADIOACTIVE)
				dmgtype = 1
				dmgmult = 0.2
			if(D_TOXIC)
				dmgmult = 0

		log_shot(P,src)
		src.visible_message(SPAN_ALERT("<b>[src]</b> is struck by [P]!"))

		var/damage = round((((P.power/3)*P.proj_data.ks_ratio)*dmgmult), 1.0)
		var/stun = round((P.power*(1.0-P.proj_data.ks_ratio)), 1.0)

		src.changeStatus("stunned", stun SECONDS)

		if (damage < 1)
			return

		src.material_trigger_on_bullet(src, P)

		if (!dmgtype) //brute only
			src.TakeDamage("All", damage)

	//Items being dropped ONTO this mob
	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		return

	canRideMailchutes()
		return 1

	restrained()
		return 0

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		setFace(pick("happy", "sad", "mad", "heart", "sleepy", "exclaim", "question", "lopsy", "kitty", "eye"), random_color())

		if (limiter.canISpawn(/obj/effects/sparks))
			var/obj/sparks = new /obj/effects/sparks
			sparks.set_loc(get_turf(src))
			SPAWN(2 SECONDS) if (sparks) qdel(sparks)
		return TRUE

	ex_act(severity)
		if (src.nodamage) return
		src.flash(3 SECONDS)
		switch (severity)
			if (1)
				SPAWN(0)
					src.gib(1)

			if (2)
				SPAWN(0)
					src.TakeDamage(null, round(src.health / 2, 1.0))
					src.changeStatus("stunned", 10 SECONDS)

			if (3)
				SPAWN(0)
					src.TakeDamage(null, round(src.health / 3, 1.0))
					src.changeStatus("stunned", 5 SECONDS)

	blob_act(var/power)
		if (src.nodamage) return
		src.show_message(SPAN_ALERT("The blob attacks you!"))
		if (isdead(src) || src.health < 1)
			src.gib(1)
			return
		var/modifier = round(power / 20, 1.0)
		var/damage = rand(modifier, 20 * modifier)
		src.TakeDamage(null, damage)

	emp_act()
		emag_act()

	meteorhit(obj/O as obj)
		if (src.nodamage) return
		if (isdead(src) || src.health < 1 || prob(40))
			src.gib(1)
			return
		else
			src.TakeDamage(null, round(src.max_health / 2, 1.0))

	temperature_expose(null, temp, volume)
		src.material_trigger_on_temp(temp)

		for(var/atom/A in src.contents)
			A.material_trigger_on_temp(temp)

	new_static_image()
		return

	update_static_image()
		return

	update_item_abilities()
		if (!src.client || !need_update_item_abilities) return

		need_update_item_abilities = 0
		for (var/obj/ability_button/B in src.client.screen)
			src.client.screen -= B

		if (isdead(src)) return

		if (istype(src.hud))
			src.hud.update_ability_hotbar()

	find_in_hand(var/obj/item/I)
		if (!I)
			return 0
		if (active_tool == I)
			return active_tool
		else if (istype(src.active_tool, /obj/item/magtractor))
			var/obj/item/magtractor/mag = src.active_tool
			if (mag.holding == I)
				return mag.holding
		return 0

	find_type_in_hand(var/eqtype)
		if (!eqtype)
			return 0
		if (istype(active_tool, eqtype))
			return active_tool
		else if (istype(src.active_tool, /obj/item/magtractor))
			var/obj/item/magtractor/mag = src.active_tool
			if (istype(mag.holding, eqtype))
				return mag.holding
		return null

	find_tool_in_hand(var/tool_flag)
		var/obj/item/I = src.active_tool
		if (I && (I.tool_flags & tool_flag))
			return src.active_tool
		if (istype(src.active_tool, /obj/item/magtractor))
			var/obj/item/magtractor/MT = src.active_tool
			var/obj/item/MTI = MT.holding
			if (MTI && (MTI.tool_flags & tool_flag))
				return MT.holding
		I = locate(/obj/item/tool/omnitool) in src.tools //Try the omnitool if all else fails
		if (I && (I.tool_flags & tool_flag))
			return I
		return null

	hotkey(name)
		switch (name)
			if ("unequip")
				src.uneq_slot()
			if ("attackself")
				var/obj/item/W = src.equipped()
				if (W)
					src.click(W, list())
			else
				return ..()

	build_keybind_styles(client/C)
		..()
		C.apply_keybind("drone")

		if (!C.preferences.use_wasd)
			C.apply_keybind("drone_arrow")

		if (C.preferences.use_azerty)
			C.apply_keybind("drone_azerty")
		if (C.tg_controls)
			C.apply_keybind("drone_tg")

	projCanHit(datum/projectile/P)
		. = ..()
		if(isdead(src))
			return FALSE

/proc/droneize(target = null, pickNew = 1)
	if (!target) return 0

	var/mob/M
	if (isclient(target))
		var/client/C = target
		if (!C.mob) return 0
		M = C.mob

	if (ismind(target))
		var/datum/mind/Mind = target
		if (!Mind.current) return 0
		M = Mind.current

	if (ismob(target))
		M = target

	if (M.transforming) return 0

	//Grab the mind ref
	var/datum/mind/theMind
	if (M.ghost && M.ghost.mind)
		theMind = M.ghost.mind
	else if (M.mind)
		theMind = M.mind

	var/mob/living/silicon/ghostdrone/G
	if (pickNew && islist(available_ghostdrones) && length(available_ghostdrones))
		for (var/mob/living/silicon/ghostdrone/T in available_ghostdrones)
			if (T.newDrone && !isdead(T))
				G = T
				break
			else // why are you in this list
				available_ghostdrones -= T
		if (!G)
			//no free drones to spare
			return 0
		else
			available_ghostdrones -= G
			G.newDrone = 0
	else
		G = new /mob/living/silicon/ghostdrone(M.loc)
		G.set_loc(M.loc)

	if (ishuman(target))
		M.unequip_all()

	M.transforming = 1
	M.canmove = 0
	M.icon = null
	APPLY_ATOM_PROPERTY(M, PROP_MOB_INVISIBILITY, "transform", INVIS_ALWAYS)

	if (isobserver(M) && M:corpse)
		G.oldmob = M:corpse

	if (M?.real_name)
		G.oldname = M.real_name

	G.job = "Ghostdrone"
	theMind.assigned_role = "Ghostdrone"


	boutput(G, "<span class='bold' style='color:red;font-size:150%'>You have become a Ghostdrone!</span><br><b>Humans, Cyborgs, and other living beings will appear only as static silhouettes, and you should avoid interacting with them.</b><br><br>You can speak to your fellow Ghostdrones by talking normally (default: push T). You can talk over deadchat with other ghosts by starting your message with ';'.")
	if (G.mind)
		G.show_antag_popup("ghostdrone")

	SPAWN(1 SECOND)
		G.show_laws_drone()

	theMind.transfer_to(G)
	return G



// Dumb gimmick ghostdrone with no vis/hear restrictions + construction tools.
// Same laws, same crap HP, but more useful for just buildin' shit
TYPEINFO(/mob/living/silicon/ghostdrone/deluxe)
	start_listen_inputs = list(LISTEN_INPUT_GHOSTDRONE, LISTEN_INPUT_EARS, LISTEN_INPUT_DEADCHAT, LISTEN_INPUT_SILICONCHAT)
	start_speech_outputs = list(SPEECH_OUTPUT_GHOSTDRONE, SPEECH_OUTPUT_DEADCHAT, SPEECH_OUTPUT_SILICONCHAT)

/mob/living/silicon/ghostdrone/deluxe
	sees_static = FALSE

	New()
		..()

		var/MT = list(
			new /obj/item/rcd/construction/safe(src),
			new /obj/item/material_shaper(src),
			new /obj/item/room_planner(src),
			)

		//Make all the tools un-drop-able (to closets/tables etc)
		for (var/obj/item/O in MT)
			O.cant_drop = 1
			src.tools += O

		real_name = real_name + "-DX"
		name = real_name

		src.cell.genrate = 100


	Life(datum/controller/process/mobs/parent)
		if (client)
			src.see_in_dark = SEE_DARK_FULL

			if (client.adventure_view)
				src.see_invisible = INVIS_ADVENTURE
			else
				src.see_invisible = INVIS_CONSTRUCTION

		..()
