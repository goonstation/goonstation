
/datum/lifeprocess/arrest_icon
	process(var/datum/gas_mixture/environment)
		if (!human_owner) //humans only, fix this later to work on critters!!!
			return ..()

		var/mob/living/carbon/human/H = owner
		if (H.arrestIcon) // Update security hud icon

			//TODO : move this code somewhere else that updates from an event trigger instead of constantly
			var/arrestState = ""
			var/visibleName = H.face_visible() ? H.real_name : H.name

			var/datum/db_record/record = data_core.security.find_record("name", visibleName)
			if(record)
				var/criminal = record["criminal"]
				if(criminal == "*Arrest*" || criminal == "Parolled" || criminal == "Incarcerated" || criminal == "Released" || criminal == "Clown")
					arrestState = criminal
			else if(H.traitHolder.hasTrait("stowaway") && H.traitHolder.hasTrait("jailbird"))
				arrestState = "*Arrest*"

			if (arrestState != "*Arrest*") // Contraband overrides non-arrest statuses, now check for contraband
				if (locate(/obj/item/implant/counterrev) in H.implant)
					if (H.mind?.get_antagonist(ROLE_HEAD_REVOLUTIONARY))
						arrestState = "RevHead"
					else if (H.mind?.get_antagonist(ROLE_REVOLUTIONARY))
						arrestState = "Loyal_Progress"
					else
						arrestState = "Loyal"
				else
					var/obj/item/card/id/myID = 0
					//mbc : its faster to check if the item in either hand has a registered owner than doing istype on equipped()
					//this does mean that if an ID has no registered owner + carry permit enabled it will blink off as contraband. however i dont care!
					if (H.l_hand && H.l_hand.registered_owner())
						myID = H.l_hand
					else if (H.r_hand && H.r_hand.registered_owner())
						myID = H.r_hand

					if (!myID)
						myID = H.wear_id

					var/has_contraband_permit = 0
					var/has_carry_permit = 0
					if (myID)
						has_contraband_permit = (access_contrabandpermit in myID.access)
						has_carry_permit = (access_carrypermit in myID.access)
					if ((!has_contraband_permit && GET_ATOM_PROPERTY(H,PROP_MOVABLE_VISIBLE_CONTRABAND) > 0) || (!has_carry_permit && GET_ATOM_PROPERTY(H,PROP_MOVABLE_VISIBLE_GUNS) > 0))
						arrestState = "Contraband"
			if (H.arrestIcon.icon_state != arrestState)
				H.arrestIcon.icon_state = arrestState

		..()
