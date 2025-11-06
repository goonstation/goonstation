
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
			hivebot_owner.hud.update_health()
			hivebot_owner.hud.update_charge()
			hivebot_owner.hud.update_pulling()
			if (ticker?.mode && istype(ticker.mode, /datum/game_mode/construction))
				hivebot_owner.see_invisible = INVIS_CONSTRUCTION

		if (critter_owner)
			critter_owner.hud.update_health()
			critter_owner.hud.update_temp_indicator()
			critter_owner.hud.update_blood_indicator()
			critter_owner.hud.update_pulling()
			critter_owner.hud.update_rad_indicator()

		if (human_owner)
			human_owner.hud.update_health_indicator()
			human_owner.hud.update_temp_indicator()
			human_owner.hud.update_blood_indicator()
			human_owner.hud.update_pulling()
			human_owner.hud.update_rad_indicator()

			var/color_mod_r = 255
			var/color_mod_g = 255
			var/color_mod_b = 255
			if ( human_owner.client.view_tint )
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
		else
			if (owner.druggy)
				owner.vision.animate_color_mod(rgb(rand(0, 255), rand(0, 255), rand(0, 255)), 15)
			else
				owner.vision.set_color_mod("#FFFFFF")
		..()
