
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
			else if(H.traitHolder.hasTrait("immigrant") && H.traitHolder.hasTrait("jailbird"))
				arrestState = "*Arrest*"

			if (arrestState != "*Arrest*") // Contraband overrides non-arrest statuses, now check for contraband
				if (locate(/obj/item/implant/counterrev) in H.implant)
					if (ticker.mode && ticker.mode.type == /datum/game_mode/revolution)
						var/datum/game_mode/revolution/R = ticker.mode
						if (H.mind && H.mind.special_role == ROLE_HEAD_REV)
							arrestState = "RevHead"
						else if (H.mind in R.revolutionaries)
							arrestState = "Loyal_Progress"
						else
							arrestState = "Loyal"
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
					if (myID && (access_carrypermit in myID.access) && (access_contrabandpermit in myID.access)) // has all permissions for contraband, don't check
						myID = null
					else
						var/contrabandLevel = 0
						if (myID)
							var/has_carry_permit = (access_carrypermit in myID.access)
							var/has_contraband_permit = (access_contrabandpermit in myID.access)
							if (H.l_hand)
								if (istype(H.l_hand, /obj/item/gun/))
									if(!has_carry_permit)
										contrabandLevel += H.l_hand.contraband
								else
									if(!has_contraband_permit)
										contrabandLevel += H.l_hand.contraband

							if (!contrabandLevel && H.r_hand)
								if (istype(H.r_hand, /obj/item/gun/))
									if(!has_carry_permit)
										contrabandLevel += H.r_hand.contraband
								else
									if(!has_contraband_permit)
										contrabandLevel += H.r_hand.contraband

							if (!contrabandLevel && H.belt)
								if (istype(H.belt, /obj/item/gun/))
									if(!has_carry_permit)
										contrabandLevel += H.belt.contraband
								else
									if(!has_contraband_permit)
										contrabandLevel += H.belt.contraband

							if (!contrabandLevel && H.wear_suit)
								if(!has_contraband_permit)
									contrabandLevel += H.wear_suit.contraband

							if (!contrabandLevel && H.back)
								if (istype(H.back, /obj/item/gun/))
									if (!has_carry_permit)
										contrabandLevel += H.back.contraband
								else
									if (!has_contraband_permit)
										contrabandLevel += H.back.contraband

						else
							if (H.l_hand)
								contrabandLevel += H.l_hand.contraband
							if (!contrabandLevel && H.r_hand)
								contrabandLevel += H.r_hand.contraband
							if (!contrabandLevel && H.belt)
								contrabandLevel += H.belt.contraband
							if (!contrabandLevel && H.wear_suit)
								contrabandLevel += H.wear_suit.contraband
							if (!contrabandLevel && H.back)
								contrabandLevel += H.back.contraband

						if (contrabandLevel > 0)
							arrestState = "Contraband"

			if (H.arrestIcon.icon_state != arrestState)
				H.arrestIcon.icon_state = arrestState

		..()
