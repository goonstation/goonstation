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

	var/datum/phone/phoneDatum = null

// some of this code is copied from the old phone code, so there might be oversights/bugs remaining that I failed to catch - nex

	New()
		..() // Set up power usage, subscribe to loop, yada yada yada
		icon_state = "[phoneIcon]"
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
		else
			color = "#663300"
		overlays += image('icons/obj/machines/phones.dmi',"[dialIcon]")
		// Generate a name for the phone.

		phoneDatum = new /datum/phone/landline(src)

		if(isnull(phoneDatum.phoneName) && !nameOverride)
			var/temp_name = name
			if(temp_name == initial(name) && location)
				temp_name = location.name
			/*var/name_counter = 1
			for_by_tcl(M, /datum/phone)
				if(M.phoneName && M.phoneName == temp_name)
					name_counter++
			if(name_counter > 1)
				temp_name = "[temp_name] [name_counter]"*/// This doesn't work and findtext() won't be foolproof and i dont wanna regex so fuck it
			setName(temp_name)
		else if(!nameOverride)
			setName(phoneDatum.phoneName)
		else
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

	/// callStart is only TRUE when we an incoming call is first received, forcing it to immediately ring
	proc/doRing(callStart = FALSE)
		var/pendingCallMembers = phoneDatum.currentPhoneCall?.pendingMembers
		lastRing++
		if(phoneDatum.incomingCall && ((src.lastRing >= 2) || callStart))
			playsound(src.loc,"sound/machines/phones/ring_incoming.ogg" ,40,0)
			src.icon_state = "[ringingIcon]"
			src.lastRing = 0

		else if((length(pendingCallMembers) > 0) && ((src.lastRing >= 2) || callStart))
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
		RegisterSignal(src, COMSIG_ITEM_DROPPED, .proc/onDrop)
		RegisterSignal(src, COMSIG_ITEM_PICKUP, .proc/onPickup)


	disposing()
		parent.handset = null
		parent = null
		processing_items.Remove(src)
		UnregisterSignal(src, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_PICKUP))
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
		parent.phoneDatum.sendSpeech(M, processed, secure, real_name, lang_id)

	/// Handles taking incoming speech from a phonecall and outputting it to the mob holding the phone
	proc/outputSpeech(var/datum/phone/source, mob/M as mob, text, secure, real_name, lang_id)
		var/mob/user
		if(!istype(src.loc, /mob/living))
			return
		user = src.loc
		if(!(src in user.equipped_list()))
			return // handsets shouldn't be able to go anywhere except hands so this is fine; replace with an in_hands proc or w/e if one is made please!!
		user.show_message(text, 2)
		for(var/obj/item/device/radio/intercom/I in range(3, user))
			I.talk_into(M, text, null, M.real_name, lang_id)

	/// Handles all the logic for if we should even be trying to output sound in the first place
	proc/outputSound(soundin, vol as num, vary, extrarange as num, pitch, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME, flags = 0)
		if(!istype(src.loc, /mob/living))
			return
		var/mob/living/user = src.loc
		if(!(src in user.equipped_list()))
			return
		user.playsound_local(user, soundin, vol, vary, extrarange, pitch, ignore_flag, channel, flags)

	proc/onDrop(var/mob/user)
		UnregisterSignal(user, COMSIG_VAPE_INTO)
		//UnregisterSignal(user, COMSIG_VOLTRON_INTO)

	proc/onPickup(var/mob/user)
		RegisterSignal(user, COMSIG_VAPE_INTO, .proc/vapeInto)
		//RegisterSignal(user, COMSIG_VOLTRON_INTO, .proc/voltronInto)

	proc/vapeInto(var/mob/user, var/obj/item/reagent_containers/vape/vape)
		var/datum/phone/phoneDatum = parent.phoneDatum
		var/datum/phonecall/phonecall = phoneDatum?.currentPhoneCall
		if(!phonecall)
			return PHONE_RELAY_NO_PHONECALL
		var/victimCount = phonecall.relayVape(vape, user, phoneDatum)
		if(victimCount)
			return PHONE_RELAY_SUCCESS
		else
			return PHONE_RELAY_NO_TARGETS

/datum/phone/landline
	var/obj/machinery/phone/ourHolder = null // we can't override holder, so we make our own for when we need to refer to a handset or something
	var/dialing = FALSE // for temporarily disabling the ability to dial, so you can't just spam-click the UI

	canVape = TRUE
	canVoltron = TRUE

	New(var/atom/creator)
		..()
		ourHolder = creator

	startPhoneCall(var/toCall, var/forceStart, var/doGroupCall = FALSE)
		if(!ourHolder.connected)
			return FALSE
		if(currentPhoneCall)
			if(forceStart)
				disconnectFromCall()
			else if(!currentPhoneCall.isGroupCall && (currentPhoneCall.host != src))
				return FALSE

		if(!toCall && !forceStart)
			return FALSE  // we have duplicate checks here with the base proc because we don't wanna make the dial noise if they fail

		if(!ourHolder.handset)
			return // just in case??
		. = ..()
		if(.)
			ourHolder.doRing(callStart = TRUE)
		else
			if(!ourHolder.handset)
				return // did we hang up in these 4 seconds?
			. = ..()
			if(.)
				ourHolder.doRing(callStart = TRUE)

	receiveInvite()
		if(ourHolder.handset)
			return FALSE // we can't receive an invite if we're holding the handset!!
		if(!ourHolder.connected)
			return FALSE
		. = ..()
		if(.)
			ourHolder.doRing(callStart = TRUE)

	hangUp()
		cancelInvite(src)
		..()

	canSee()
		if(!ourHolder.connected)
			return FALSE
		if(ourHolder.unlisted)
			return FALSE
		. = ..()

	getContacts()
		if(!ourHolder.connected)
			return
		. = ..()

	speechReceived(var/datum/phone/source, mob/M as mob, text, secure, real_name, lang_id)
		ourHolder.handset?.outputSpeech(source, M, text, secure, real_name, lang_id)

	onDisconnect(datum/phonecall/leftPhoneCall)
		..()
		if(ourHolder.handset)
			return
		ourHolder.icon_state = ourHolder.phoneIcon
		ourHolder.lastRing = 0

	onRemoteDisconnect()
		handleSound("sound/machines/phones/remote_hangup.ogg",50,0)

	onRemoteJoin()
		handleSound("sound/machines/phones/remote_answer.ogg",50,0)

	uiMakeCall(target)
		handleSound("sound/machines/phones/dial.ogg",50,0)
		dialing = TRUE
		SPAWN_DBG(4 SECONDS)
			dialing = FALSE
			..()

	handleSound(soundin, vol as num, vary, extrarange as num, pitch, ignore_flag = 0, channel = VOLUME_CHANNEL_GAME, flags = 0)
		ourHolder.handset?.outputSound(soundin, vol, vary, extrarange, pitch, ignore_flag, channel, flags)

	onVape(var/datum/reagents/_buffer, var/obj/item/reagent_containers/vape/vape, var/mob/living/sourceMob, var/datum/phone/sourcePhone)
		if(ourHolder.handset)
			_buffer.my_atom = ourHolder.handset // we do this so the actual smoke reaction occurs on the handset and not the person who vaped
			if(ismob(ourHolder.handset.loc))
				var/mob/user = ourHolder.handset.loc
				boutput(user,"<span class='alert'><B>[sourceMob] blows a cloud of smoke right through the phone! What a total [pick("dork","loser","dweeb","nerd","useless piece of shit","dumbass")]!</B></span>")
		..()

	onVoltron(var/mob/living/sourceMob, var/obj/item/device/voltron/voltron, var/datum/phone/sourcePhone, var/isOrgan = FALSE, var/override)
		override = ourHolder?.handset
		. = ..(sourceMob, voltron, sourcePhone, isOrgan, override)

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

	startPhoneCall(var/toCall, var/forceStart, var/doGroupCall = doGroupCalls)
		..(toCall, forceStart, doGroupCall)

/* ======= DEPRECATED ======= */
/*/obj/machinery/phone
	name = "phone"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "A landline phone. In space. Where there is no land. Hmm."
	icon_state = "phone"
	anchored = 1
	density = 0
	mats = 25
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WIRECUTTERS | DECON_MULTITOOL
	_health = 50
	var/can_talk_across_z_levels = 0
	var/phone_id = null
	var/obj/machinery/phone/linked = null
	var/ringing = 0
	var/answered = 0
	var/last_ring = 0
	var/connected = 1
	var/emagged = 0
	var/dialing = 0
	var/labelling = 0
	var/unlisted = FALSE
	var/obj/item/phone_handset/handset = null
	var/chui/window/phonecall/phonebook
	var/phoneicon = "phone"
	var/ringingicon = "phone_ringing"
	var/answeredicon = "phone_answered"
	var/dialicon = "phone_dial"




	New()
		..() // Set up power usage, subscribe to loop, yada yada yada
		src.icon_state = "[phoneicon]"
		var/area/location = get_area(src)

		// Give the phone an appropriate departmental color. Jesus christ thats fancy.
		if(istype(location,/area/station/security))
			src.color = "#ff0000"
		else if(istype(location,/area/station/bridge))
			src.color = "#00aa00"
		else if(istype(location, /area/station/engine) || istype(location, /area/station/quartermaster) || istype(location, /area/station/mining))
			src.color = "#aaaa00"
		else if(istype(location, /area/station/science))
			src.color = "#9933ff"
		else if(istype(location, /area/station/medical))
			src.color = "#0000ff"
		else
			src.color = "#663300"
		src.overlays += image('icons/obj/machines/phones.dmi',"[dialicon]")
		// Generate a name for the phone.

		if(isnull(src.phone_id))
			var/temp_name = src.name
			if(temp_name == initial(src.name) && location)
				temp_name = location.name
			var/name_counter = 1
			for_by_tcl(M, /obj/machinery/phone)
				if(M.phone_id && M.phone_id == temp_name)
					name_counter++
			if(name_counter > 1)
				temp_name = "[temp_name] [name_counter]"
			src.phone_id = temp_name

		src.desc += " There is a small label on the phone that reads \"[src.phone_id]\""

		START_TRACKING

		return

	disposing()

		if (linked)
			linked.linked = null
		linked = null

		if (handset)
			handset.parent = null
		handset = null

		STOP_TRACKING
		..()

	// Attempt to pick up the handset
	attack_hand(mob/living/user as mob)
		..(user)
		if(src.answered == 1)
			return

		src.handset = new /obj/item/phone_handset(src,user)
		user.put_in_hand_or_drop(src.handset)
		src.answered = 1

		src.icon_state = "[answeredicon]"
		playsound(user, "sound/machines/phones/pick_up.ogg", 50, 0)

		if(src.ringing == 0) // we are making an outgoing call
			if(src.connected == 1)
				if(user)
					if(!src.phonebook)
						src.phonebook = new /chui/window/phonecall(src)
					phonebook.Subscribe(user.client)
			else
				if(user)
					boutput(user,"<span class='alert'>As you pick up the phone you notice that the cord has been cut!</span>")
		else
			src.ringing = 0
			src.linked.ringing = 0
			if(src.linked.handset.holder)
				src.linked.handset.holder.playsound_local(src.linked.handset.holder,"sound/machines/phones/remote_answer.ogg",50,0)
		return

	attack_ai(mob/user as mob)
		return

	attackby(obj/item/P as obj, mob/living/user as mob)
		if(istype(P, /obj/item/phone_handset))
			var/obj/item/phone_handset/PH = P
			if(PH.parent == src)
				user.drop_item(PH)
				hang_up()
			return
		if(istype(P,/obj/item/wirecutters))
			if(src.connected == 1)
				if(user)
					boutput(user,"You cut the phone line leading to the phone.")
				src.connected = 0
			else
				if(user)
					boutput(user,"You repair the line leading to the phone.")
				src.connected = 1
			return
		if(istype(P,/obj/item/device/multitool))
			if(src.labelling == 1)
				return
			src.labelling = 1
			var/t = input(user, "What do you want to name this phone?", null, null) as null|text
			t = sanitize(html_encode(t))
			if(t && length(t) > 50)
				return
			if(t)
				src.phone_id = t
			src.labelling = 0
			return
		..()
		src._health -= P.force
		attack_particle(user,src)
		if(src._health <= 0)
			if(src.linked)
				hang_up()
			src.gib(src.loc)
			qdel(src)

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		src.icon_state = "[ringingicon]"
		if (!src.emagged)
			if(user)
				boutput(user, "<span class='alert'>You short out the ringer circuit on the [src].</span>")
			src.emagged = 1
			return 1
		return 0

	process()
		if(src.emagged == 1)
			playsound(src.loc,"sound/machines/phones/ring_incoming.ogg" ,100,1)
			if(src.answered == 0)
				src.icon_state = "[ringingicon]"
			return

		if(src.connected == 0)
			return

		src.last_ring++
		if(..())
			return

		if(src.ringing) // Are we calling someone
			if(src.linked && src.linked.answered == 0)
				if(src.last_ring >= 2)
					src.last_ring = 0
					if(src.handset && src.handset.holder)
						src.handset.holder.playsound_local(src.handset.holder,"sound/machines/phones/ring_outgoing.ogg" ,40,0)
			else
				if(src.last_ring >= 2)
					playsound(src.loc,"sound/machines/phones/ring_incoming.ogg" ,40,0)
					src.icon_state = "[ringingicon]"
					src.last_ring = 0


	proc/hang_up()
		src.answered = 0
		if(src.linked) // Other phone needs updating
			if(!src.linked.answered) // nobody picked up. Go back to not-ringing state
				src.linked.icon_state = "[phoneicon]"
			else if(src.linked.handset && src.linked.handset.holder)
				src.linked.handset.holder.playsound_local(src.linked.handset.holder,"sound/machines/phones/remote_hangup.ogg",50,0)
			src.linked.ringing = 0
			src.linked.linked = null
			src.linked = null
		src.ringing = 0
		src.handset = null
		src.icon_state = "[phoneicon]"
		playsound(src.loc,"sound/machines/phones/hang_up.ogg" ,50,0)

	// This makes phones do that thing that phones do
	proc/call_other(var/obj/machinery/phone/target)
		// Dial the number
		if(!src.handset)
			return
		src.dialing = 1
		src.handset.holder?.playsound_local(src.handset.holder,"sound/machines/phones/dial.ogg" ,50,0)
		SPAWN_DBG(4 SECONDS)
			// Is it busy?
			if(target.answered || target.linked || target.connected == 0)
				playsound(src.loc,"sound/machines/phones/phone_busy.ogg" ,50,0)
				src.dialing = 0
				return

			// Start ringing the other phone (handled by process)
			src.linked = target
			target.linked = src
			src.ringing = 1
			src.linked.ringing = 1
			src.dialing = 0
			return


/obj/machinery/phone/custom_suicide = 1
/obj/machinery/phone/suicide(var/mob/user as mob)
	if (!src.user_can_suicide(user))
		return 0
	if (ishuman(user))
		user.visible_message("<span class='alert'><b>[user] bashes the [src] into their head repeatedly!</b></span>")
		user.TakeDamage("head", 150, 0)
		return 1



// Interface for placing a call
/chui/window/phonecall
	name = "phonebook"
	windowSize = "250x500"
	var/obj/machinery/phone/owner = null

	New(var/obj/machinery/phone/creator)
		..()
		src.owner = creator

	GetBody()
		var/html = ""
		for_by_tcl(P, /obj/machinery/phone)
			if (P.unlisted) continue
			html += "[theme.generateButton(P.phone_id, "[P.phone_id]")] <br/>"
		return html

	OnClick(var/client/who, var/id, var/data)
		if(src.owner.dialing == 1 || src.owner.linked)
			return
		if(owner)
			for_by_tcl(P, /obj/machinery/phone)
				if(P.phone_id == id)
					owner.call_other(P)
					return
		Unsubscribe(who)


// Item generated when someone picks up a phone
/obj/item/phone_handset

	name = "phone handset"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "I wonder if the last crewmember to use this washed their hands before touching it."
	var/obj/machinery/phone/parent = null
	var/mob/holder = null //GC WOES (just dont use this var, get holder using loc)
	flags = TALK_INTO_HAND
	w_class = 1

	New(var/obj/machinery/phone/parent_phone, var/mob/living/picker_upper)
		if(!parent_phone)
			return
		..()
		icon_state = "handset"
		src.parent = parent_phone
		src.color = parent_phone.color
		if(picker_upper)
			src.holder = picker_upper
		processing_items.Add(src)

	disposing()
		parent = null
		holder = null
		processing_items.Remove(src)
		..()

	process()
		if(!src.parent)
			qdel(src)
			return
		if(src.parent.answered == 1 && get_dist(src,src.parent) > 1)
			boutput(src.holder,"<span class='alert'>The phone cord reaches it limit and the handset is yanked back to its base!</span>")
			src.holder.drop_item(src)
			src.parent.hang_up()
			processing_items.Remove(src)
			qdel(src)

	talk_into(mob/M as mob, text, secure, real_name, lang_id)
		..()
		if(get_dist(src,holder) > 0 || !src.parent.linked || !src.parent.linked.handset) // Guess they dropped it? *shrug
			return
		var/processed = "<span class='game say'><span class='bold'>[M.name] \[<span style=\"color:[src.color]\"> [bicon(src)] [src.parent.phone_id]</span>\] says, </span> <span class='message'>\"[text[1]]\"</span></span>"
		var/mob/T = src.parent.linked.handset.holder
		if(T?.client)
			T.show_message(processed, 2)
			M.show_message(processed, 2)

			for (var/obj/item/device/radio/intercom/I in range(3, T))
				I.talk_into(M, text, null, M.real_name, lang_id)

	// Attempt to pick up the handset
	attack_hand(mob/living/user as mob)
		..(user)
		holder = user
*/
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
