/obj/machinery/phone
	name = "phone"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "A landline phone. In space. Where there is no land. Hmm."
	icon_state = "phone"
	anchored = 1
	density = 0
	mats = 25
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WIRECUTTERS | DECON_MULTITOOL
	_health = 50
	var/emagged = FALSE
	var/labelling = FALSE
	var/obj/item/phoneHandset/handset = null
	var/lastRing = 0
	var/phoneIcon = "phone"
	var/ringingIcon = "phone_ringing"
	var/answeredIcon = "phone_answered"
	var/dialIcon = "phone_dial"
	var/connected = TRUE
	var/nameOverride = FALSE // for mappers who want to have custom phone names; set the actual name var of the phone, and this to TRUE
	var/phoneDatumType = /datum/phone/landline // so you can set the datum in a child obj if you wanna use a modified landline datum
	var/unlisted = FALSE
	var/showPhoneNumber = TRUE

	var/datum/phone/phoneDatum = null

// some of this code is copied from the old phone code, so there might be oversights/bugs remaining that I failed to catch - nex

	New()
		..() // Set up power usage, subscribe to loop, yada yada yada
		icon_state = "[phoneIcon]"
		phoneDatum = new /datum/phone/landline(src)
		var/area/location = get_area(src)

		// Give the phone an appropriate departmental color. Jesus christ thats fancy.
		if(istype(location,/area/station/security))
			color = "#ff0000"
		else if(istype(location,/area/station/bridge))
			color = "#00aa00"
		else if(istype(location, /area/station/engine) || istype(location, /area/station/quartermaster) || istype(location, /area/station/mining))
			color = "#aaaa00"
		else if(istype(location, /area/station/science))
			color = "#9933ff"
		else if(istype(location, /area/station/medical))
			color = "#0000ff"
		if(istype(location, /area/syndicate) || istype(location, /area/listeningpost))
			color = "#ff0000"
			phoneDatum.elementSettings["syndicate"] = TRUE
		else
			color = "#663300"
		overlays += image('icons/obj/machines/phones.dmi',"[dialIcon]")

		// generate a new name if we don't have a mapvar'd one
		if(name == initial(name))
			var/temp_name = name
			if(temp_name == initial(name) && location)
				temp_name = location.name
			setName(temp_name)
		phoneDatum.phoneName = name

		START_TRACKING


	proc/setName(var/newName = "")
		phoneDatum.phoneName = newName
		name = "phone ([newName])"


	disposing()

		qdel(phoneDatum)
		phoneDatum = null

		if (handset)
			handset.parent = null
		handset = null // we let it exist so people can beat others to death with it

		STOP_TRACKING
		..()


	attack_hand(mob/living/user as mob)
		..(user)
		if(handset)
			if(!connected)
				boutput(user,"<span class='alert'>As you reach for the dial you notice that the cord has been cut, you can't possibly try to make a call!</span>")
			if(handset?.loc == user)
				phoneDatum.ui_interact(user)
			return

		icon_state = "[answeredIcon]"
		playsound(user, "sound/machines/phones/pick_up.ogg", 50, 0) // we dont call handset.outputSound() since we're guaranteed to have a user here

		handset = new /obj/item/phoneHandset(src,user)
		user.put_in_hand_or_drop(handset)

		if(!connected)
			boutput(user,"<span class='alert'>As you pick up the phone you notice that the cord has been cut!</span>")
			return
		if(phoneDatum.incomingCall)
			phoneDatum.joinPhoneCall(phoneDatum.incomingCall)
			icon_state = "[answeredIcon]"
			playsound(user, "sound/machines/phones/pick_up.ogg", 50, 0)
			return
		phoneDatum.ui_interact(user)



	attackby(obj/item/P as obj, mob/living/user as mob)
		if(istype(P, /obj/item/phoneHandset))
			var/obj/item/phoneHandset/PH = P
			if(PH.parent == src)
				user.drop_item(PH)
				hangUp()
				icon_state = phoneIcon
			else if(user)
				boutput(user,"<span class='alert'>That handset doesn't belong to that phone, it won't fit back into it, clearly!</span>")
			return
		if(istype(P,/obj/item/wirecutters))
			handleCutWire(user)
			return
		if(istype(P,/obj/item/device/multitool))
			var/input = input(user, "What would you like to do?", null, null) in list("Change Name", "Toggle Visibility")
			if(input == "Toggle Visibility")
				if(!unlisted)
					unlisted = TRUE
					phoneDatum.unlisted = TRUE
					user.visible_message("<span class='alert'>[user] disables [src]'s visibility to other phones!", "<span class='notice'>You disable the phonebook connection, rendering [src] invisible to other phones.")
				else
					unlisted = FALSE
					phoneDatum.unlisted = FALSE
					user.visible_message("<span class='alert'>[user] enables [src]'s visibility to other phones!", "<span class='notice'>You enable the phonebook connection, rendering [src] visible to other phones.")
				return
			var/t = input(user, "What do you want to name this phone?", null, null) as null|text
			t = sanitize(html_encode(t))
			if(t && length(t) > 50)
				return
			if(t)
				src.setName(t)
			return
		..()
		src._health -= P.force
		attack_particle(user,src)
		if(src._health <= 0)
			src.hangUp()
			src.gib(src.loc)
			qdel(src)

	attack_ai(mob/user as mob)
		return

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		src.icon_state = "[ringingIcon]"
		if (!src.emagged)
			if(user)
				boutput(user, "<span class='alert'>You short out the ringer circuit on the [src].</span>")
			src.emagged = TRUE
			return TRUE
		return FALSE

	process()
		if(src.emagged)
			playsound(src.loc,"sound/machines/phones/ring_incoming.ogg" ,100,1)
			if(!handset)
				src.icon_state = "[ringingIcon]"
			return
		if(!src.connected)
			return
		if(..())
			return

		src.doRing()


	examine(var/mob/user)
		. = ..()
		if((get_dist(user, src)) < 2) // gotta be close to see that number!
			. += "<br>It has a label on the side reading \"#[phoneDatum.formattedPhoneNumber]\""


	/// callStart is only TRUE when we an incoming call is first received, forcing it to immediately ring the other end
	proc/doRing(callStart = FALSE)
		var/pendingCallMembers = phoneDatum.currentPhoneCall?.pendingMembers
		lastRing++
		if(phoneDatum.incomingCall && ((src.lastRing >= 2) || callStart))
			playsound(src.loc,"sound/machines/phones/ring_incoming.ogg" ,40,0)
			src.icon_state = "[ringingIcon]"
			src.lastRing = 0

		else if((length(pendingCallMembers) > 0) && ((src.lastRing >= 2)))
			src.lastRing = 0
			handset.outputSound("sound/machines/phones/ring_outgoing.ogg" ,40,0)


	/// Physically hang up the phone; distinct from /datum/phone/hangUp() which only disconnects from calls/incoming calls
	proc/hangUp()
		phoneDatum.hangUp()
		if(handset) // this should always be the case but just in case it's not for some absolutely bizarre reason
			playsound(loc,"sound/machines/phones/hang_up.ogg" ,50,0)
			qdel(handset)


	/// Called when we get a new incoming phonecall and need to start ringing
	proc/receiveCall()
		doRing(callStart = TRUE)


	proc/handleCutWire(var/mob/user)
		if(connected)
			if(user)
				boutput(user,"<span class='alert'>You cut the phone line leading to the phone.</span>")
			connected = FALSE
			phoneDatum.disconnectFromCall()
		else
			if(user)
				boutput(user,"<span class='alert'>You repair the line leading to the phone.</span>")
			connected = TRUE



/obj/item/phoneHandset
	name = "phone handset"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "I wonder if the last crewmember to use this washed their hands before touching it."
	var/obj/machinery/phone/parent = null
	flags = TALK_INTO_HAND
	w_class = 1

	New(var/obj/machinery/phone/parentPhone)
		if(!parentPhone)
			return
		..()
		icon_state = "handset"
		parent = parentPhone
		color = parentPhone.color
		processing_items.Add(src)
		RegisterSignal(src, COMSIG_VAPE_INTO, .proc/vapeInto)
		RegisterSignal(src, COMSIG_VOLTRON_INTO, .proc/voltronInto)


	disposing()
		parent.handset = null
		parent = null
		processing_items.Remove(src)
		UnregisterSignal(src, list(COMSIG_VAPE_INTO, COMSIG_VOLTRON_INTO))
		..()


	process()
		if(get_dist(src,src.parent) > 1)
			var/mob/living/holder = null
			if(istype(src.loc, /mob/living))
				holder = src.loc
				boutput(holder,"<span class='alert'>The phone cord reaches it limit and the handset is yanked back to its base!</span>")
				holder.drop_item(src)
			parent.icon_state = parent.phoneIcon
			src.parent.hangUp()

	talk_into(mob/M as mob, text, secure, real_name, lang_id)
		..()
		if(!src.parent)
			return // we're not usable as a phone anymore
		if(src.loc != M)
			return // not the person holding us talking, ignore em!
		var/processed = "<span class='game say'><span class='bold'>[M.name] \[<span style=\"color:[src.color]\"> [bicon(src)] [src.parent.phoneDatum.phoneName]</span>\] says, </span> <span class='message'>\"[text[1]]\"</span></span>"
		parent.phoneDatum.sendSpeech(M, processed, secure, real_name, lang_id, text)


	/// Handles taking incoming speech from a phonecall and outputting it to the mob holding the phone
	proc/outputSpeech(var/datum/phone/source, mob/M as mob, text, secure, real_name, lang_id, initialText)
		var/mob/user
		if(!istype(src.loc, /mob/living))
			return
		user = src.loc
		if(!(src in user.equipped_list()))
			return // handsets shouldn't be able to go anywhere except hands so this is fine; replace with an in_hands proc or w/e if one is made please!!
		user.show_message(text, 2)
		for(var/obj/item/device/radio/intercom/I in range(3, user))
			if(I.broadcasting) // we only wanna talk_into if the mic is on
				I.talk_into(M, initialText, null, M.real_name, lang_id) // we talk_into with the ORIGINAL, unprocessed speech from the person who talked


	/// Handles all the logic for if we should even be trying to output sound in the first place
	proc/outputSound(soundin, vol as num, vary, extrarange as num, pitch, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME, flags = 0)
		if(!istype(src.loc, /mob/living))
			return
		var/mob/living/user = src.loc
		if(!(src in user.equipped_list()))
			return
		user.playsound_local(user, soundin, vol, vary, extrarange, pitch, ignore_flag, channel, flags)



	proc/vapeInto(var/obj/item/equippedOffHand, var/mob/user, var/obj/item/reagent_containers/vape/vape)
		if(equippedOffHand != src)
			return
		var/datum/phone/phoneDatum = parent.phoneDatum
		var/datum/phonecall/phonecall = phoneDatum?.currentPhoneCall
		if(!phonecall)
			return PHONE_RELAY_NO_PHONECALL
		var/victimCount = phonecall.relayVape(vape, user, phoneDatum)
		if(victimCount)
			return PHONE_RELAY_SUCCESS
		else
			return PHONE_RELAY_NO_TARGETS


	proc/voltronInto(var/obj/item/equippedOffHand, var/mob/user, var/obj/item/device/voltron/voltron)
		if(equippedOffHand != src)
			return
		var/datum/phone/ourPhone = parent.phoneDatum
		var/returnList = ourPhone.currentPhoneCall?.getVoltronTarget(user, voltron, ourPhone)
		var/datum/phone/targetPhone = returnList[1] // returns as list, index 1 is target
		var/atom/targetDestination = targetPhone?.onVoltron(user, voltron, ourPhone)

		if(targetDestination) // time2ride the space lines
			. |= PHONE_RELAY_SUCCESS
			user.visible_message("<span class='alert'>[user] enters the phone line using their [voltron]!</span>", "<span class='alert'>You enter the phone line using your [voltron].</span>", "You hear a strange sucking noise.")
			playsound(user.loc, "sound/effects/singsuck.ogg", 40, 1)
			user.drop_item(src)
			user.set_loc(get_turf(targetDestination))
			playsound(user.loc, "sound/effects/singsuck.ogg", 40, 1)
			user.visible_message("<span class='alert'>[user] suddenly emerges from the [targetDestination]! [pick("","What the fuck?")]</span>", "<span class='alert'>You emerge from the [targetDestination].</span>", "You hear a strange sucking noise.")
			voltron.power -= 5

			// try not to do this in a group call, doofus
			if(returnList[2]) // did a mishap occur, and if so, which phone in this group call will we be shooting an organ out of?
				if(!ishuman(user))
					return
				targetPhone = returnList[2]
				targetDestination = targetPhone.onVoltron(user, voltron, ourPhone, isOrgan = TRUE)
				var/mob/living/carbon/human/M = user
				var/obj/item/organ/O
				var/list/organ_list = list("left_eye", "right_eye", "left_lung", "right_lung", "left_kidney", "right_kidney", "liver", "stomach", "intestines", "spleen", "panreas", "appendix")
				shuffle_list(organ_list)
				organ_list += "FUCK" // very end of the list so we know when we've gone through the whole list

				for(var/Org in organ_list)
					O = M.organHolder.drop_organ(Org, get_turf(targetDestination))
					if(O)
						break
					else if(Org == "FUCK")
						return // just in case somehow someone with no organs uses this (while guaranteeing we otherwise lose an organ)

				targetDestination.visible_message("<span class='alert'><B>[O] shoots out of [targetDestination], [pick("holy shit!", "holy fuck!", "what the hell!", "what the fuck!", "Jesus Christ!", "yikes!", "oof...")]</B></span>")
				ThrowRandom(O, 16, 4)
				boutput(user, "<span class='alert'>[O] fell out of your body while travelling, holy fuck!</span>")
			return

		else // space lines closed :(
			. |= PHONE_RELAY_NO_TARGETS // or no valid call members but eh
			boutput(user, "You can't seem to enter the phone for some reason!")
		return


/obj/machinery/phone/testing

	New()
		..()
		qdel(phoneDatum) // to-do: MAKE IT SO YOU DONT HAVE TO DO THIS YOU KNOB
		phoneDatum = new /datum/phone/landline/testing(src)

/datum/phone/landline/testing

	var/doGroupCalls = TRUE

	New()
		..()
		maxConnected = 10
		prioritizeOurMax = TRUE

	startPhoneCall(var/toCall, var/forceStart, var/doGroupCall = doGroupCalls, var/manuallyDialled = FALSE)
		..(toCall, forceStart, doGroupCall, manuallyDialled)


/obj/machinery/phone/wall
	name = "wall phone"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "A landline phone. In space. Where there is no land. Hmm."
	icon_state = "wallphone"
	anchored = 1
	density = 0
	mats = 25
	_health = 50
	phoneIcon = "wallphone"
	ringingIcon = "wallphone_ringing"
	answeredIcon = "wallphone_answered"
	dialIcon = "wallphone_dial"

/obj/machinery/phone/unlisted
	unlisted = TRUE

//
//		----------------- CELL PHONE STUFF STARTS HERE ---------------------
//


/*
		Radio Antennas. Cell phones require a signal to work!


/var/global/list/radio_antennas = list()

/obj/machinery/radio_antenna
	icon='icons/obj/large/32x64.dmi'
	icon_state = "commstower"
	var/range = 10
	var/active = 0

	process()
		..()

	proc/get_max_range()
		return range * 5

	proc/process_message()

/obj/machinery/radio_antenna/large
	range = 40

/obj/item/phone/cellphone
	icon_state = "cellphone"
	mats = 25
	_health = 20
	var/can_talk_across_z_levels = 0
	var/phone_id = null
	var/ringmode = 0 // 0 for silent, 1 for vibrate, 2 for ring
	var/ringing = 0
	var/answered = 0
	var/last_ring = 0
	var/dialing = 0
	var/labelling = 0
	var/chui/window/phonecall/phonebook
	var/phoneicon = "cellphone"
	var/ringingicon = "cellphone_ringing"
	var/answeredicon = "cellphone_answered"
	var/obj/item/ammo/power_cell/cell = new /obj/item/ammo/power_cell/med_power
	var/activated = 0


	New()
		..()

	attackby(obj/item/P as obj, mob/living/user as mob)
		if(istype(P,/obj/item/card/id))
			if(src.activated)
				if(alert("Do you want to un-register this phone?","yes","no") == "yes")
					registered = 0
					phone_id = ""
					phonelist.Remove(src)
			else
				var/obj/item/card/id/new_id = obj
				user.show_text("Activating the phone. Please wait!","blue")
				actions.start(new/datum/action/bar/icon/activate_cell_phone(src.icon_state,src,new_id), user)

		..()
		src._health -= P.force
		if(src._health <= 0)
			if(src.linked)
				hang_up()
			src.gib(src.loc)
			qdel(src)


	proc/ring()

	proc/talk_into()


	proc/find_nearest_radio_tower()
		var/min_distance = inf
		var/nearest_tower = null
		for(var/machinery/radio_tower/tower in radio_antennas)
			if(!tower.active || tower.z != src.z)
				continue
			if(max(abs(tower.x - src.x),abs(tower.y - src.y) < nearest_tower)
				nearest_tower = tower
		return nearest_tower


/obj/item/phone/cellphone/bananaphone
	name = "Banana Phone"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "A cellular, bananular phone."
	icon_state = "bananaphone"
	phoneicon = "bananaphone"
	ringingicon = "bananaphone_ringing"
	answeredicon = "bananaphone_answered"

	ring()

/datum/action/bar/icon/activate_cell_phone
	duration = 50
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "activate_cell_phone"
	icon = 'icons/obj/machines/phones.dmi'
	icon_state = "cellphone"
	var/obj/item/cellphone/phone
	var/registering_name

	New(icon,newphone,newid_name)
		icon_state = icon
		phone = newphone
		registering_name = newid_name
		..()


	onEnd()
		phone.registered = 1
		phone.phone_id = "[id.registered]'s Cell Phone"
		phonelist.Add(phone)
		..()

*/
