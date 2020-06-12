
/datum/lifeprocess/arrest_icon
	process(var/datum/gas_mixture/environment)
		if (!human_owner) //humans only, fix this later to work on critters!!!
			return ..()

		var/mob/living/carbon/human/H = owner
		if (H.arrestIcon) // Update security hud icon

			//TODO : move this code somewhere else that updates from an event trigger instead of constantly
			var/arrestState = ""
			var/visibleName = H.name
			if (H.wear_id)
				visibleName = H.wear_id.registered_owner()

			for (var/security_record in data_core.security)
				var/datum/data/record/R = security_record
				if ((R.fields["name"] == visibleName) && ((R.fields["criminal"] == "*Arrest*") || R.fields["criminal"] == "Parolled" || R.fields["criminal"] == "Incarcerated" || R.fields["criminal"] == "Released"))
					arrestState = R.fields["criminal"] // Found a record of some kind
					break

			if (arrestState != "*Arrest*") // Contraband overrides non-arrest statuses, now check for contraband

				if (locate(/obj/item/implant/antirev) in H.implant)
					if (ticker.mode && ticker.mode.type == /datum/game_mode/revolution)
						var/datum/game_mode/revolution/R = ticker.mode
						if (H.mind && H.mind.special_role == "head_rev")
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
					if (myID && (access_carrypermit in myID.access))
						myID = null
					else
						var/contrabandLevel = 0
						if (H.l_hand)
							contrabandLevel += H.l_hand.contraband
						if (!contrabandLevel && H.r_hand)
							contrabandLevel += H.r_hand.contraband
						if (!contrabandLevel && H.belt)
							contrabandLevel += H.belt.contraband
						if (!contrabandLevel && H.wear_suit)
							contrabandLevel += H.wear_suit.contraband

						if (contrabandLevel > 0)
							arrestState = "Contraband"

			if (H.arrestIcon.icon_state != arrestState)
				H.arrestIcon.icon_state = arrestState

		..()
