/*
/mob/proc/jack_in()
	set category = "Local"
	set name="Enter V-space"

	if (!ismob(usr)) return
	if (!usr.client) return
	if (!usr.network_device) return

	if (!isalive(usr) || usr.getStatusDuration("stunned") !=0)
		return

	var/mob/living/user = usr
	if (user.network_device)
		var/datum/v_space/V
		V.Enter_Vspace(user, user.network_device)
	return

/mob/proc/jack_out()
	set category = "Local"
	set name="Exit V-space"

	if (!ismob(usr)) return
	if (!usr.client) return
	if (!istype(usr, /mob/living/carbon/human/virtual/)) return

	var/datum/v_space/V
	V.Leave_Vspace(usr)
	return*/

// Logout buttons were discontinued because...?? Well, here they are again (Convair880).
/obj/death_button/VR_logout_button
	name = "Leave VR"
	desc = "Press this button to log out of virtual reality."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "party"

	attack_hand(mob/user)
		if (!ismob(user) || !user.client || !istype(user, /mob/living/carbon/human/virtual/))
			return
		src.add_fingerprint(user)

		// Won't delete the VR character otherwise, which can be confusing (detective's goggles sending you to the existing body in the bomb VR etc).
		setdead(user)
		user.death(FALSE)

		Station_VNet.Leave_Vspace(user)
		return

var/global/datum/v_space/v_space_network/Station_VNet

datum/v_space
	var
		active = 0
		list/users = list()			  //Who is in V-space
		list/inactive_bodies = list() //Spare virtual bodies. waste not want not
		vr_key_dispensed = 0


	v_space_network
		active = 1


	proc/Enter_Vspace(var/mob/user as mob, var/network_device, var/network)
	//Who is entering, What they are using to enter, Which network are they entering
		if(!user)
			return
		if(!active)
			boutput(user, "<span class='alert'>Unable to connect to the Net!</span>")
			return
		if(!network_device)
			boutput(user, "<span class='alert'>You lack a device able to connect to the net!</span>")
			return
		if(!user:client)
			return
		if(!user.mind)
			boutput(user, "<span class='alert'>You don't have a mind!</span>")
			return

//		var/range_check = In_Network(user, network_device, network)
//		if(!range_check)
//			boutput(user, "<span class='alert'>Out of network range!</span>")
//			return

		var/turf/B = pick_landmark(network)

		if(!B) //no entry landmark
			boutput(user, "<span class='alert'>Invalid network!</span>")
			return


		if (user.mind && user.mind.virtual && user.mind.virtual.qdeled)
			user.mind.virtual = null

		var/mob/living/carbon/human/character
		if (user.mind && user.mind.virtual && !isobserver(user))
			var/mob/living/carbon/human/virtual/V = user.mind.virtual
			V.body = user
			user.mind.transfer_to(V)
			character = V
			character.visible_message("<span class='notice'><b>[user.name] logs in!</b></span>")
		else
			character = create_Vcharacter(user, network_device, network, B)
			character.set_loc(B)
			character.visible_message("<span class='notice'><b>[character.name] logs in!</b></span>")
		users.Add(character)
		// Made much more prominent due to frequent a- and mhelps (Convair880).
		character.show_text("<h2><font color=red><B>Death in virtual reality will result in a log-out. You can also press one of the logout buttons to leave.</B></font></h2>", "red")
		return


	proc/Leave_Vspace(var/mob/living/carbon/human/virtual/user)
		if (!user) return 0
		//We have a body - give them a VR key if none have been dispensed
		if(user.mind && user.body && !vr_key_dispensed && user.check_contents_for(/obj/item/device/key/virtual))
			new /obj/item/device/key/virtual(user.body.loc)
			vr_key_dispensed = 1

		if (user.client)
			user.client.reset_view()

		if (user.mind)
			for (var/datum/antagonist/antag_role in user.mind.antagonists)
				if (antag_role.vr)
					antag_role.on_death()

		for(var/mob/O in oviewers())
			boutput(O, "<span class='alert'><b>[user] logs out!</b></span>")
		if (istype(user.loc,/obj/racing_clowncar/kart))
			var/obj/racing_clowncar/kart/car = user.loc
			car.reset()
		if (isdead(user))
			for (var/obj/item/I in user)
				// Stop littering the place with VR skulls and organs, aaahh (Convair880).
				if (istype(I,/obj/item/clothing/glasses/vr_fake) || istype(I, /obj/item/parts) || istype(I, /obj/item/organ) || istype(I, /obj/item/skull) || istype(I, /obj/item/clothing/head/butt))
					continue
				if (I != user.w_uniform && I != user.shoes)
					user.u_equip(I)
					if (I) //I don't know of any items that delete themselves on drop BUT HEY
						I.set_loc(user.loc)
						I.layer = initial(I.layer)
		users.Remove(user)
		if (user.mind && user.body)
			user.mind.transfer_to(user.body)
			user.mind.virtual = null
			user.body = null
		else
			if(user.network_device)
				var/mob/dead/observer/O = user.ghostize()
				if (O)
					O.real_name = user.isghost
					O.name = O.real_name
					O.set_loc(user.network_device)
			else
				var/mob/dead/observer/O = user.ghostize()
				if (O)
					var/arrival_loc = pick_landmark(LANDMARK_LATEJOIN)
					O.real_name = user.isghost
					O.name = O.real_name
					O.set_loc(arrival_loc)

/*
		if(!user.client)
			inactive_bodies += user
			user.body = null
			user.set_loc(null)
			return 0
*/
		return 1


	proc/In_Network(var/mob/user, var/networkdevice)
		for(var/obj/machinery/sim/transmitter/T in orange(10,networkdevice))
			if(T.active == 1)
				return 1
		return 0


	proc/create_Vcharacter(var/mob/user, var/network_device, var/network, turf/B)
		var/mob/living/carbon/human/virtual/virtual_character

		if (inactive_bodies.len)
			virtual_character = inactive_bodies[1]
			inactive_bodies -= virtual_character
			while (inactive_bodies.len && virtual_character.qdeled)
				virtual_character = inactive_bodies[1]
				inactive_bodies -= virtual_character
			virtual_character.full_heal()
		else
			virtual_character = new(B)

		virtual_character.network_device = network_device
		virtual_character.body = user
		virtual_character.Vnetwork = network

		if(ishuman(user))
			copy_to(virtual_character, user)

		var/clothing_color = pick("#FF0000","#FFFF00","#00FF00","#00FFFF","#0000FF","#FF00FF")
		var/obj/item/clothing/under/virtual/C = new
		var/obj/item/clothing/shoes/virtual/S = new
		C.set_loc(virtual_character)
		S.set_loc(virtual_character)
		C.color = clothing_color
		S.color = clothing_color
		virtual_character.equip_if_possible( C, virtual_character.slot_w_uniform )
		virtual_character.equip_if_possible( S, virtual_character.slot_shoes)
		if(isobserver(user) && !isAIeye(user))
			virtual_character.isghost = user.real_name
			virtual_character.real_name = "Virtual Spectre #[rand(1, 999)]"
		else
			virtual_character.real_name = "Virtual [user.real_name]"
		user.mind.virtual = virtual_character
		user.mind.transfer_to(virtual_character)
		SPAWN(0.8 SECONDS)
			if (virtual_character)
				virtual_character.update_face()
				virtual_character.update_body()
				virtual_character.update_clothing()
		return virtual_character


	proc/copy_to(var/mob/living/carbon/human/virtual/character, var/mob/living/carbon/human/user )
//		character.real_name = "Virtual [user.real_name]"
		character.bioHolder.mobAppearance.gender = user.gender
		character.gender = user.gender
		character.bioHolder.age = user.bioHolder.age
		character.pin = user.pin
		character.bioHolder.bloodType = user.bioHolder.bloodType
		character.bioHolder.mobAppearance.e_color = user.bioHolder.mobAppearance.e_color
		character.bioHolder.mobAppearance.customization_first_color = user.bioHolder.mobAppearance.customization_first_color
		character.bioHolder.mobAppearance.customization_second_color = user.bioHolder.mobAppearance.customization_second_color
		character.bioHolder.mobAppearance.customization_third_color = user.bioHolder.mobAppearance.customization_third_color
		character.bioHolder.mobAppearance.s_tone = user.bioHolder.mobAppearance.s_tone
		character.bioHolder.mobAppearance.customization_first = user.bioHolder.mobAppearance.customization_first
		character.bioHolder.mobAppearance.customization_second = user.bioHolder.mobAppearance.customization_second
		character.bioHolder.mobAppearance.customization_third = user.bioHolder.mobAppearance.customization_third

		character.bioHolder.mobAppearance.underwear = user.bioHolder.mobAppearance.underwear
		character.bioHolder.mobAppearance.u_color = user.bioHolder.mobAppearance.u_color

		sanitize_null_values(character)

		character.bioHolder.mobAppearance.UpdateMob()
		return

	proc/sanitize_null_values(var/mob/living/carbon/human/virtual/character)
		if (!character.bioHolder.mobAppearance) return
		var/datum/appearanceHolder/AH = character.bioHolder.mobAppearance
		if (!AH)
			AH = new
		if (AH.customization_first_color == null)
			AH.customization_first_color = "#101010"
		if (AH.customization_first == null)
			AH.customization_first = new /datum/customization_style/none
		if (AH.customization_second_color == null)
			AH.customization_second_color = "#101010"
		if (AH.customization_second == null)
			AH.customization_second = new /datum/customization_style/none
		if (AH.customization_third_color == null)
			AH.customization_third_color = "#101010"
		if (AH.customization_third == null)
			AH.customization_third = new /datum/customization_style/none
		if (AH.e_color == null)
			AH.e_color = "#101010"
		if (AH.u_color == null)
			AH.u_color = "#FEFEFE"
		if (AH.s_tone == null  || AH.s_tone == "#ffffff")
			AH.s_tone = "#FEFEFE"
		return
