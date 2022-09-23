/obj/machinery/phone
	name = "phone"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "A landline phone. In space. Where there is no land. Hmm."
	icon_state = "phone"
	anchored = 1
	density = 0
	mats = 25
	_health = 50
	var/can_talk_across_z_levels = 0
	var/phone_id = null
	var/obj/machinery/phone/linked = null
	var/ringing = 0
	var/answered = 0
	var/location = null
	var/last_ring = 0
	var/connected = 1 // as in to a phone line. Not to another phone. So you can cut the phone wire and disable it!
	var/emagged = 0
	var/dialing = 0
	var/labelling = 0
	var/obj/item/phone_handset/handset = null
	var/chui/window/phonecall/phonebook
	var/phoneicon = "phone"
	var/ringingicon = "phone_ringing"
	var/answeredicon = "phone_answered"
	var/dialicon = "phone_dial"




	New()
		..() // Set up power usage, subscribe to loop, yada yada yada
		src.icon_state = "[phoneicon]"
		src.location = get_area(src)

		// Give the phone an appropriate departmental color. Jesus christ thats fancy.
		if(istype(src.location,/area/station/security))
			src.color = "#ff0000"
		else if(istype(src.location,/area/station/bridge))
			src.color = "#00aa00"
		else if(istype(src.location, /area/station/engine) || istype(src.location, /area/station/quartermaster) || istype(src.location, /area/station/mining))
			src.color = "#aaaa00"
		else if(istype(src.location, /area/station/science))
			src.color = "#9933ff"
		else if(istype(src.location, /area/station/medical))
			src.color = "#0000ff"
		else
			src.color = "#663300"
		src.overlays += image('icons/obj/machines/phones.dmi',"[dialicon]")
		// Generate a name for the phone.
		var/area/my_area = get_area(src)
		var/base_name = my_area.name // tentative name
		var/temp_name = base_name
		var/name_counter = 1
		for(var/obj/machinery/phone/M in phonelist)
			if(M.phone_id && M.phone_id == temp_name)
				name_counter++
				temp_name = "[base_name] [name_counter]"

		src.phone_id = temp_name

		src.desc += " There is a small label on the phone that reads \"[temp_name]\""

		phonelist.Add(src)

		return

	disposing()

		if (linked)
			linked.linked = null
		linked = null

		if (handset)
			handset.parent = null
		handset = null

		phonelist.Remove(src)
		..()

	// Attempt to pick up the handset
	attack_hand(mob/living/user,var/cellmode = 0)
		..(user)
		if(cellmode)
			return
		if(src.answered == 1)
			return

		src.handset = new /obj/item/phone_handset(src,user)
		user.put_in_hand_or_drop(src.handset)
		src.answered = 1

		src.icon_state = "[answeredicon]"
		playsound(user, 'sound/machines/phones/pick_up.ogg', 50, 0)

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
			answer_phone()
			if(src.linked)
				src.linked.play_pickup_sound()
		return

	proc/answer_phone()
		src.ringing = 0
		src.linked.ringing = 0

	proc/play_pickip_sound()
		if(!handset || !handset.holder) //fuck
			return
		handset.holder.playsound_local(src.linked.handset.holder,'sound/machines/phones/remote_answer.ogg',50,0)

	attack_ai(mob/user as mob)
		return

	attackby(obj/item/P, mob/living/user)
		if(istype(P, /obj/item/phone_handset))
			var/obj/item/phone_handset/PH = P
			if(PH.parent == src)
				if(src.linked && src.linked.handset && src.linked.handset.holder)
					src.linked.handset.holder.playsound_local(src.linked.handset.holder,'sound/machines/phones/remote_answer.ogg',50,0)
				user.drop_item(PH)
				qdel(PH)
				hang_up()
			return
		if(issnippingtool(P))
			if(src.connected == 1)
				if(user)
					boutput(user,"You cut the phone line leading to the phone.")
				src.connected = 0
			else
				if(user)
					boutput(user,"You repair the line leading to the phone.")
				src.connected = 1
			return
		if(ispulsingtool(P))
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
			playsound(src.loc,'sound/machines/phones/ring_incoming.ogg' ,100,1)
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
						src.handset.holder.playsound_local(src.handset.holder,'sound/machines/phones/ring_outgoing.ogg' ,40,0)
			else
				if(src.last_ring >= 2)
					playsound(src.loc,'sound/machines/phones/ring_incoming.ogg' ,40,0)
					src.icon_state = "[ringingicon]"
					src.last_ring = 0


	proc/hang_up()
		if(src.linked) // Other phone needs updating
			src.linked.linked = null
			src.linked = null
			src.linked.hang_up()
		src.ringing = 0
		src.handset = null
		src.icon_state = "[phoneicon]"
		playsound(src.loc,'sound/machines/phones/hang_up.ogg' ,50,0)

	// This makes phones do that thing that phones do
	proc/call_other(var/obj/machinery/phone/target)
		// Dial the number
		src.dialing = 1
		src.handset.holder?.playsound_local(src.handset.holder,'sound/machines/phones/dial.ogg' ,50,0)
		SPAWN(4 SECONDS)
			// Is it busy?
			if(!target.can_be_called())
				playsound(src.loc,'sound/machines/phones/phone_busy.ogg' ,50,0)
				src.dialing = 0
				return

			// Start ringing the other phone (handled by process)
			src.linked = target
			target.linked = src
			src.ringing = 1
			src.linked.ringing = 1
			src.dialing = 0
			return

	proc/can_be_called()
		return answered || linked || !connected

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
	windowSize = "350x700"
	var/obj/machinery/phone/owner = null

	New(var/obj/machinery/phone/creator)
		..()
		src.owner = creator

	GetBody()
		var/html = ""
		for(var/obj/machinery/phone/P in phonelist)
			html += "[theme.generateButton(P.phone_id, "[P.phone_id]")] <br/>"
		return html

	OnClick(var/client/who, var/id, var/data)
		if(src.owner.dialing == 1 || src.owner.linked)
			return
		if(owner)
			for(var/obj/machinery/phone/P in phonelist)
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
		if(src.parent.answered == 1 && BOUNDS_DIST(src, src.parent) > 0)
			boutput(src.holder,"<span class='alert'>The phone cord reaches it limit and the handset is yanked back to its base!</span>")
			src.holder.drop_item(src)
			src.parent.hang_up()
			processing_items.Remove(src)
			qdel(src)

	talk_into(mob/M as mob, text, secure, real_name, lang_id)
		..()
		if(GET_DIST(src,holder) > 0 || !src.parent.linked) // Guess they dropped it? *shrug
			return
		var/processed = "<span class='game say'><span class='bold'>[M.name] \[<span style=\"color:[src.color]\"> [bicon(src)] [src.parent.phone_id]</span>\] says, </span> <span class='message'>\"[text[1]]\"</span></span>"
		var/mob/T = src.parent.linked.handset.holder
		if(T?.client)
			T.show_message(processed, 2)
			M.show_message(processed, 2)

			for (var/obj/item/device/radio/intercom/I in range(3, T))
				I.talk_into(M, text, null, M.real_name, lang_id)

	call_other(var/obj/machinery/phone/target)
		// Dial the number
		src.dialing = 1
		src.handset.holder?.playsound_local(src.handset.holder,'sound/machines/phones/dial.ogg' ,50,0)
		SPAWN(4 SECONDS)
			// Is it busy?
			if(!target.can_be_called())
				playsound(src.loc,'sound/machines/phones/phone_busy.ogg' ,50,0)
				src.dialing = 0
				return

			// Start ringing the other phone (handled by process)
			src.linked = target
			target.linked = src
			src.ringing = 1
			src.linked.ringing = 1
			src.dialing = 0
			return



/obj/machinery/phone/wall
	name = "phone"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "A landline phone. In space. Where there is no land. Hmm."
	icon_state = "wallphone"
	anchored = 1
	density = 0
	mats = 25
	_health = 50
	phoneicon = "wallphone"
	ringingicon = "wallphone_ringing"
	answeredicon = "wallphone_answered"
	dialicon = "wallphone_dial"

