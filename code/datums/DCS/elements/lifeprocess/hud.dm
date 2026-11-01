/datum/element/lifeprocess/hud/process(mob/living/target, datum/gas_mixture/environment)
	if (!target.client)
		return

	target.stamina_bar?.update_value(target)

	if (ishuman(target))
		var/mob/living/carbon/human/M = target
		var/datum/hud/human/hud = M.hud
		hud.update_health_indicator()
		hud.update_temp_indicator()
		hud.update_blood_indicator()
		hud.update_pulling()
		hud.update_rad_indicator()
		hud.update_gravity_indicator()

		var/color_mod_r = 255
		var/color_mod_g = 255
		var/color_mod_b = 255
		if (M.client.view_tint)
			if (istype(M.glasses))
				color_mod_r *= M.glasses.color_r
				color_mod_g *= M.glasses.color_g
				color_mod_b *= M.glasses.color_b

			if (istype(M.wear_mask))
				color_mod_r *= M.wear_mask.color_r
				color_mod_g *= M.wear_mask.color_g
				color_mod_b *= M.wear_mask.color_b

			if (istype(M.head))
				color_mod_r *= M.head.color_r
				color_mod_g *= M.head.color_g
				color_mod_b *= M.head.color_b

			var/obj/item/organ/eye/l_eye = M.get_organ("left_eye")
			if (istype(l_eye))
				color_mod_r *= l_eye.color_r
				color_mod_g *= l_eye.color_g
				color_mod_b *= l_eye.color_b

			var/obj/item/organ/eye/r_eye = M.get_organ("right_eye")
			if (istype(r_eye))
				color_mod_r *= r_eye.color_r
				color_mod_g *= r_eye.color_g
				color_mod_b *= r_eye.color_b

		if (M.druggy)
			M.vision.animate_color_mod(rgb(rand(80, 255), rand(80, 255), rand(80, 255)), 15)
		else
			M.vision.set_color_mod(rgb(color_mod_r, color_mod_g, color_mod_b))

		return

	if (isrobot(target))
		var/mob/living/silicon/robot/M = target
		var/datum/hud/silicon/robot/hud = M.hud
		hud.update_health()
		hud.update_charge()
		hud.update_pulling()
		hud.update_environment()
		hud.update_gravity_indicator()

	else if (ishivebot(target))
		var/mob/living/silicon/hivebot/M = target
		var/datum/hud/silicon/shell/hud = M.hud
		hud.update_health()
		hud.update_charge()
		hud.update_pulling()

	else if (iscritter(target))
		var/mob/living/critter/M = target
		var/datum/hud/critter/hud = M.hud
		hud.update_health()
		hud.update_temp_indicator()
		hud.update_blood_indicator()
		hud.update_pulling()
		hud.update_rad_indicator()
		hud.update_gravity_indicator()

	if (target.druggy)
		target.vision.animate_color_mod(rgb(rand(0, 255), rand(0, 255), rand(0, 255)), 15)
	else
		target.vision.set_color_mod("#FFFFFF")
