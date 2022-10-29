
/obj/item/machinery/phone/cellphone
	icon_state = "cellphone"
	mats = 25
	_health = 20
	var/phone_id = null
	var/ringmode = 0 // 0 for silent, 1 for vibrate, 2 for ring (For future use)
	var/ringing = 0
	var/answered = 0
	var/last_ring = 0
	var/dialing = 0
	var/chui/window/phonecall/phonebook
	var/phoneicon = "cellphone"
	var/ringingicon = "cellphone_ringing"
	var/answeredicon = "cellphone_answered"
	var/obj/item/cell/cell = new
	var/activated = 0
	var/ringsound = 'sound/machines/phones/ring_incoming.ogg'


	New()
		src.cell.give(7500) // Charge it up
		return

	attackby(obj/item/P, mob/living/user)
		if(istype(P,/obj/item/card/id))
			if(src.activated)
				if(tgui_alert(user, "Do you want to un-register this phone?", list("Yes", "No")) == "Yes")
					activated = 0
					phone_id = ""
					phonelist.Remove(src)
			else
				var/obj/item/card/id/new_id = P
				user.show_text("Activating the phone. Please wait!","blue")
				actions.start(new/datum/action/bar/icon/activate_cell_phone(src.icon_state,src,new_id), user)

		if(isscrewingtool(P) && src.cell)
			user.put_in_hand_or_drop(src.cell)
			src.cell = null

		if(istype(P,/obj/item/cell) && !src.cell)
			user.drop_item() //  Might need some cleaning up? I forget! Check here during debugging
			src.cell = P

		..()
		src._health -= P.force
		if(src._health <= 0)
			if(src.linked)
				hang_up()
			src.gib(src.loc)
			qdel(src)

	attack_hand(mob/living/user,var/cellmode)
		..(user,1)
		if(src.answered == 1)
			return

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
			if(!istype(src.linked,/obj/item/machinery/phone/cellphone) && src.linked.handset.holder)
				src.linked.handset.holder.playsound_local(src.linked.handset.holder,'sound/machines/phones/remote_answer.ogg',50,0)
		return


	process()
		src.cell.use(4) // Lasts around 30 minutes
		if(src.cell.charge <= 0)
			icon_state = phoneicon
			dialing = 0
			answered = 0
			ringing = 0
			if(src.linked)
				hang_up()
			return

		if(src.emagged == 1)
			playsound(src.loc,'sound/machines/phones/ring_incoming.ogg' ,100,1)
			if(src.answered == 0)
				src.icon_state = "[ringingicon]"
			return

		last_ring++
		if(src.ringing) // Are we calling someone
			if(src.linked && src.linked.answered == 0)
				if(src.last_ring >= 2)
					src.last_ring = 0
					src.playsound_local(src.handset.holder,'sound/machines/phones/ring_outgoing.ogg' ,40,0)
			else
				if(src.last_ring >= 2)
					if(ringmode > 0)
						playsound(src.loc,ringsound ,40,0)
					src.icon_state = "[ringingicon]"
					src.last_ring = 0


	hang_up()
		if(src.linked) // Other phone needs updating
			src.linked.linked = null
			src.linked = null
			src.linked.hang_up()
		ringing = 0
		icon_state = phoneicon
		playsound(src.loc,'sound/machines/phones/hang_up.ogg' ,50,0)


	proc/find_nearest_radio_tower()
		var/min_distance = inf
		var/nearest_tower = null
		for(var/machinery/radio_tower/tower in radio_antennas)
			if(!tower.active || tower.z != src.z)
				continue
			if(max(abs(tower.x - src.x),abs(tower.y - src.y)) < nearest_tower)
				nearest_tower = tower
		return nearest_tower

	Exited(Obj, newloc)
		. = ..()
		if(Obj == src.cell)
			src.cell = null


/obj/item/machinery/phone/cellphone/bananaphone
	name = "Banana Phone"
	icon = 'icons/obj/machines/phones.dmi'
	desc = "A cellular, bananular phone."
	icon_state = "bananaphone"
	phoneicon = "bananaphone"
	ringingicon = "bananaphone_ringing"
	answeredicon = "bananaphone_answered"

	//ring()

/datum/action/bar/icon/activate_cell_phone
	duration = 50
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "activate_cell_phone"
	icon = 'icons/obj/machines/phones.dmi'
	icon_state = "cellphone"
	var/obj/item/machinery/phone/cellphone/phone = null
	var/registering_name = "Anonymous"

	New(var/icon,var/obj/item/machinery/phone/cellphone/newphone,var/newid_name)
		icon_state = icon
		src.phone = newphone
		registering_name = newid_name
		..()


	onEnd()
		phone.registered = 1
		phone.phone_id = "[id.registered]'s Cell Phone"
		phonelist.Add(phone)
		..()
