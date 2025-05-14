#define WELDER_TYPE_INFINITE 1 // Unlimted fuel!
#define WELDER_TYPE_FUEL 2 // Fuel comes from fuel reagents
#define WELDER_TYPE_POWER 3 // Fuel comes from power cell

#define EYE_DAMAGE_IMMUNE 2
#define EYE_DAMAGE_MINOR 1
#define EYE_DAMAGE_NORMAL 0
#define EYE_DAMAGE_EXTRA -1

TYPEINFO(/datum/component/welding)
	initialization_args = list(
		ARG_INFO("welder", DATA_INPUT_REF, "The item to get fuel from.", null),
		ARG_INFO("fuelType", DATA_INPUT_NUM, "Type of fuel being used.", WELDER_TYPE_INFINITE),
		ARG_INFO("fuelConversion", DATA_INPUT_NUM, "Fuel efficiency and/or unit conversion.", 1),
		ARG_INFO("isWelding", DATA_INPUT_BOOL, "Is the welder on.", FALSE),
	)

/datum/component/welding
	var/is_welding = FALSE //! Has the welder been lit?
	var/obj/item/welder = null //! Where the fuel is getting used from, if anywhere
	var/fuel_type = WELDER_TYPE_INFINITE //! What is the welder being fueled with?
	var/fuel_conversion = 1 //! How efficient the welder is and/or convert to the proper units

	var/sound_ignite = 'sound/effects/welder_ignite.ogg'
	var/list/sound_noisey = list('sound/items/Welder.ogg', 'sound/items/Welder2.ogg')

	Initialize(welder=null, fuelType=WELDER_TYPE_INFINITE, fuelConversion=1, isWelding=FALSE)
		..()
		src.welder = welder
		src.fuel_type = fuelType
		src.fuel_conversion = fuelConversion
		src.is_welding = isWelding

	/// Returns TRUE if state is sucessfully set. Should only be called by the welder item.
	proc/set_state(var/welding_state, mob/user)
		if(src.is_welding == welding_state)
			return FALSE
		src.is_welding = welding_state
		if(!src.is_welding)
			if(!src.welder)
				return TRUE
			if (get_fuel() <= 0)
				if(user)
					boutput(user, SPAN_NOTICE("Need more fuel!"))
				src.is_welding = FALSE
				return FALSE
			SEND_SIGNAL(src.welder, COMSIG_LIGHT_ENABLE)
		else
			if(user)
				boutput(user, SPAN_NOTICE("Not welding anymore."))
			SEND_SIGNAL(src.welder, COMSIG_LIGHT_DISABLE)
		return TRUE

	/// fuel_amount is how much fuel is needed to weld.
	/// use_amount is how much fuel is used per action.
	proc/try_weld(mob/user, var/fuel_amount = 2, var/use_amount = -1, var/noisy=1, var/burn_eyes=TRUE)
		if(!src.is_welding)
			return FALSE // not welding
		if(use_amount < 0)
			use_amount = fuel_amount
		if (src.get_fuel() < fuel_amount)
			boutput(user, SPAN_NOTICE("Need more fuel!"))
			return FALSE //welding, doesnt have fuel
		src.use_fuel(use_amount)
		if(noisy)
			playsound(user.loc, sound_noisey[noisy], 40, 1)
		if(burn_eyes)
			src.eyecheck(user)
		return TRUE //welding, has fuel

	/// Returns the amount of fuel in the welder
	proc/get_fuel()
		switch(src.fuel_type)
			if(WELDER_TYPE_INFINITE)
				return INFINITY
			if(WELDER_TYPE_FUEL)
				return src.welder?.reagents?.get_reagent_amount("fuel")
			if(WELDER_TYPE_POWER)
				if(!src.welder)
					return 0
				var/list/ret = list()
				if(SEND_SIGNAL(src.welder, COMSIG_CELL_CHECK_CHARGE, ret) & CELL_RETURNED_LIST)
					. = ret["charge"] / src.fuel_conversion
			else
				return 0

	proc/use_fuel(var/use_amount)
		if(!src.welder || src.fuel_conversion == 0)
			return
		switch(src.fuel_type)
			if(WELDER_TYPE_FUEL)
				use_amount = min(get_fuel(), use_amount * src.fuel_conversion)
				if(src.welder.reagents)
					src.welder.reagents.remove_reagent("fuel", use_amount)
				src.welder.inventory_counter.update_number(get_fuel())
			if(WELDER_TYPE_POWER)
				use_amount = min(get_fuel(), use_amount)
				use_amount *= src.fuel_conversion
				SEND_SIGNAL(src.welder, COMSIG_CELL_USE, use_amount)


	proc/eyecheck(mob/user as mob)
		if(user.isBlindImmune())
			return
		/// Checks eye protection; positive value for protecting eyes, negative for increasing damage (thermals)
		var/safety = EYE_DAMAGE_NORMAL
		if (ishuman(user))
			var/mob/living/carbon/human/H = user
			if (!H.sight_check()) //don't blind if we're already blind
				safety = EYE_DAMAGE_IMMUNE
			// we want to check for the thermals first so having a polarized eye doesn't protect you if you also have a thermal eye
			else if (istype(H.glasses, /obj/item/clothing/glasses/thermal) || H.eye_istype(/obj/item/organ/eye/cyber/thermal) || istype(H.glasses, /obj/item/clothing/glasses/nightvision) || H.eye_istype(/obj/item/organ/eye/cyber/nightvision))
				safety = EYE_DAMAGE_EXTRA
			else if (istype(H.head, /obj/item/clothing/head/helmet/welding))
				var/obj/item/clothing/head/helmet/welding/WH = H.head
				if(!WH.up)
					safety = EYE_DAMAGE_IMMUNE
				else
					safety = EYE_DAMAGE_NORMAL
			else if (istype(H.head, /obj/item/clothing/head/helmet/space/industrial))
				var/obj/item/clothing/head/helmet/space/industrial/helmet = H.head
				if (helmet.has_visor && helmet.visor_enabled)
					safety = EYE_DAMAGE_EXTRA
				else
					safety = EYE_DAMAGE_IMMUNE
			else if (istype(H.head, /obj/item/clothing/head/helmet/space))
				safety = EYE_DAMAGE_IMMUNE
			else if (istype(H.glasses, /obj/item/clothing/glasses/sunglasses) || H.eye_istype(/obj/item/organ/eye/cyber/sunglass))
				safety = EYE_DAMAGE_MINOR
		switch (safety)
			// IMMUNE means nothing happens

			if (EYE_DAMAGE_MINOR)
				boutput(user, SPAN_ALERT("Your eyes sting a little."))
				user.take_eye_damage(rand(1, 2))
			if (EYE_DAMAGE_NORMAL)
				boutput(user, SPAN_ALERT("Your eyes burn."))
				user.take_eye_damage(rand(2, 4))
			if (EYE_DAMAGE_EXTRA)
				boutput(user, SPAN_ALERT("<b>Your goggles intensify the welder's glow. Your eyes itch and burn severely.</b>"))
				user.change_eye_blurry(rand(12, 20))
				user.take_eye_damage(rand(12, 16))

	proc/attach_robopart(mob/living/carbon/human/H as mob, mob/living/carbon/user as mob, var/part)
		if (!istype(H) || !part || !H.bioHolder.HasEffect("loose_robot_[part]"))
			return

		if(!src.try_weld(user, 5))
			return
		H.TakeDamage("chest",0,20)
		if (prob(50))
			H.emote("scream")
		if(user)
			user.visible_message(SPAN_ALERT("[user.name] welds [H.name]'s robotic part to their stump with [src]."), SPAN_ALERT("You weld [H.name]'s robotic part to their stump with [src]."))
		H.bioHolder.RemoveEffect("loose_robot_[part]")
		return

#undef EYE_DAMAGE_IMMUNE
#undef EYE_DAMAGE_MINOR
#undef EYE_DAMAGE_NORMAL
#undef EYE_DAMAGE_EXTRA
