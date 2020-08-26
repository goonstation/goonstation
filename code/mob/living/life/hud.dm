
/datum/lifeprocess/hud
	process()
		if (!owner.client) return ..()

		//proc/handle_regular_hud_updates()
		if (owner.stamina_bar) owner.stamina_bar.update_value(owner)
		//hud.update_indicators()


		if (robot_owner)
			robot_owner.hud.update_health()
			robot_owner.hud.update_charge()
			robot_owner.hud.update_pulling()
			robot_owner.hud.update_environment()

		if (hivebot_owner)
			if (ticker?.mode && istype(ticker.mode, /datum/game_mode/construction))
				hivebot_owner.see_invisible = 9

		if (critter_owner)
			critter_owner.hud.update_health()
			critter_owner.hud.update_temp_indicator()
			critter_owner.hud.update_blood_indicator()
			critter_owner.hud.update_pulling()

		if (human_owner)
			human_owner.hud.update_health_indicator()
			human_owner.hud.update_temp_indicator()
			human_owner.hud.update_blood_indicator()
			human_owner.hud.update_pulling()

			var/color_mod_r = 255
			var/color_mod_g = 255
			var/color_mod_b = 255
			if (istype(human_owner.glasses))
				color_mod_r *= human_owner.glasses.color_r
				color_mod_g *= human_owner.glasses.color_g
				color_mod_b *= human_owner.glasses.color_b
			if (istype(human_owner.wear_mask))
				color_mod_r *= human_owner.wear_mask.color_r
				color_mod_g *= human_owner.wear_mask.color_g
				color_mod_b *= human_owner.wear_mask.color_b
			if (istype(human_owner.head))
				color_mod_r *= human_owner.head.color_r
				color_mod_g *= human_owner.head.color_g
				color_mod_b *= human_owner.head.color_b
			var/obj/item/organ/eye/L_E = human_owner.get_organ("left_eye")
			if (istype(L_E))
				color_mod_r *= L_E.color_r
				color_mod_g *= L_E.color_g
				color_mod_b *= L_E.color_b
			var/obj/item/organ/eye/R_E = human_owner.get_organ("right_eye")
			if (istype(R_E))
				color_mod_r *= R_E.color_r
				color_mod_g *= R_E.color_g
				color_mod_b *= R_E.color_b

			if (human_owner.druggy)
				human_owner.vision.animate_color_mod(rgb(rand(80, 255), rand(80, 255), rand(80, 255)), 15)
			else
				human_owner.vision.set_color_mod(rgb(color_mod_r, color_mod_g, color_mod_b))

			if (istype(human_owner.glasses, /obj/item/clothing/glasses/healthgoggles))
				var/obj/item/clothing/glasses/healthgoggles/G = human_owner.glasses
				if (human_owner.client && !(G.assigned || G.assigned == human_owner.client))
					G.assigned = human_owner.client
					if (!(G in processing_items))
						processing_items.Add(G)
					//G.updateIcons()

			if (istype(human_owner.head, /obj/item/clothing/head/helmet/space/syndicate/specialist/medic))
				var/obj/item/clothing/head/helmet/space/syndicate/specialist/medic/M = human_owner.head
				if (human_owner.client && !(M.assigned || M.assigned == human_owner.client))
					M.assigned = human_owner.client
					if (!(M in processing_items))
						processing_items.Add(M)
					//G.updateIcons()

			else if (human_owner.organHolder && istype(human_owner.organHolder.left_eye, /obj/item/organ/eye/cyber/prodoc))
				var/obj/item/organ/eye/cyber/prodoc/G = human_owner.organHolder.left_eye
				if (human_owner.client && !(G.assigned || G.assigned == human_owner.client))
					G.assigned = human_owner.client
					if (!(G in processing_items))
						processing_items.Add(G)
					//G.updateIcons()
			else if (human_owner.organHolder && istype(human_owner.organHolder.right_eye, /obj/item/organ/eye/cyber/prodoc))
				var/obj/item/organ/eye/cyber/prodoc/G = human_owner.organHolder.right_eye
				if (human_owner.client && !(G.assigned || G.assigned == human_owner.client))
					G.assigned = human_owner.client
					if (!(G in processing_items))
						processing_items.Add(G)
					//G.updateIcons()
		else
			if (owner.druggy)
				owner.vision.animate_color_mod(rgb(rand(0, 255), rand(0, 255), rand(0, 255)), 15)
			else
				owner.vision.set_color_mod("#FFFFFF")
		..()
