/// Max amount of items allowed in mixer bowl
#define MIXER_MAX_CONTENTS 4
/// Power used during mixing
#define MIXER_MIXING_POWER_USAGE 1 KILO WATTS
/// Mixing time in seconds
#define MIX_TIME 2 SECONDS

var/list/mixer_recipes = list()

TYPEINFO(/obj/machinery/mixer)
	mats = 15

/obj/machinery/mixer
	name = "KitchenHelper"
	desc = "A food mixer."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "blender_empty"
	density = 1
	anchored = ANCHORED
	flags = TGUI_INTERACTIVE
	deconstruct_flags = DECON_WRENCH | DECON_CROWBAR | DECON_WELDER

	var/image/blender_off
	var/image/blender_powered
	var/image/blender_working
	var/list/recipes = null
	var/list/to_remove = list()
	var/allowed = list(/obj/item/reagent_containers/food/, /obj/item/parts/robot_parts/head, /obj/item/clothing/head/butt, /obj/item/organ/brain)
	var/working = 0
	var/timeMixEnd = 0

	New()
		..()
		src.recipes = mixer_recipes
		if (!src.recipes)
			src.recipes = list()

		if (!src.recipes.len)
/*			src.recipes += new /datum/cookingrecipe/mixer/mix_cake_custom(src)
			src.recipes += new /datum/cookingrecipe/mixer/pancake_batter(src)
			src.recipes += new /datum/cookingrecipe/mixer/brownie_batter(src)
			src.recipes += new /datum/cookingrecipe/mixer/cake_batter(src)
			src.recipes += new /datum/cookingrecipe/mixer/custard(src)
			src.recipes += new /datum/cookingrecipe/mixer/mashedpotatoes(src)
			src.recipes += new /datum/cookingrecipe/mixer/mashedbrains(src)
			src.recipes += new /datum/cookingrecipe/mixer/gruel(src)
			src.recipes += new /datum/cookingrecipe/mixer/fishpaste(src)
			src.recipes += new /datum/cookingrecipe/mixer/meatpaste(src)
			src.recipes += new /datum/cookingrecipe/mixer/wonton_wrapper(src)
			src.recipes += new /datum/cookingrecipe/mixer/butters(src)
			src.recipes += new /datum/cookingrecipe/mixer/soysauce(src)
			src.recipes += new /datum/cookingrecipe/mixer/gravy(src)
*/
		src.blender_off = image(src.icon, "blender_off")
		src.blender_powered = image(src.icon, "blender_powered")
		src.blender_working = image(src.icon, "blender_working")
		src.UpdateIcon()
		UnsubscribeProcess()

	attackby(obj/item/W, mob/user)
		var/amount = length(src.contents)
		if (amount >= MIXER_MAX_CONTENTS)
			boutput(user, SPAN_ALERT("The mixer is full."))
			return
		var/proceed = 0
		for(var/check_path in src.allowed)
			if(istype(W, check_path))
				proceed = 1
				break
		if (!proceed)
			boutput(user, SPAN_ALERT("You can't put that in the mixer!"))
			return
		user.visible_message(SPAN_NOTICE("[user] puts [W] into the [src]."))
		user.u_equip(W)
		W.set_loc(src)
		W.dropped(user)
		tgui_process.update_uis(src)
		src.UpdateIcon()

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "MixerMachine")
			ui.open()

	ui_static_data(mob/user)
		. = list("maxItems" = MIXER_MAX_CONTENTS)

	ui_data(mob/user)
		var/mixerContents = list()
		var/index = 1
		for(var/obj/item/I in src.contents)
			var/itemData = list()
			itemData["name"] = I.name
			itemData["index"] = index
			itemData["iconData"] = get_item_icon(I)
			mixerContents += list(itemData)
			index += 1
		. = list("working" = src.working, "mixerContents" = mixerContents)

	proc/get_item_icon(var/obj/item/target)
		var/static/base64_preview_cache = list()
		var/original_name = initial(target.name)
		. = base64_preview_cache[original_name]

		if(isnull(.))
			var/icon/result = getFlatIcon(target, no_anim=TRUE)
			if(result)
				. = icon2base64(result)
			else
				. = ""
			base64_preview_cache[original_name] = .

	proc/ejectItemFromMixer(obj/item/target)
		if (target)
			if (BOUNDS_DIST(usr, src) == 0)
				usr.put_in_hand_or_drop(target)
			else
				target.set_loc(src.loc)

	ui_act(action, params)
		. = ..()
		if (.)
			return

		switch (action)
			if ("eject")
				var/index = params["index"]
				var/obj/item/target = src.contents[index]
				src.ejectItemFromMixer(target)

				usr.show_text(SPAN_NOTICE("You eject the [target.name] from the [src]."))
				. = TRUE

			if ("mix")
				src.mix()
				. = TRUE

			if ("ejectAll")
				for (var/obj/item/target in src.contents)
					src.ejectItemFromMixer(target)

				usr.show_text(SPAN_NOTICE("You eject all contents from the [src]."))
				. = TRUE

	attack_ai(var/mob/user as mob)
		return ui_interact(user)

	MouseDrop_T(obj/item/W as obj, mob/user as mob)
		if (istype(W) && in_interact_range(W, user) && in_interact_range(src, user) && isalive(user) && !isintangible(user))
			return src.Attackby(W, user)
		return ..()

	proc/bowl_checkitem(var/recipeitem, var/recipecount)
		if (!locate(recipeitem) in src.contents) return 0
		var/count = 0
		for(var/obj/item/I in src.contents)
			if(istype(I, recipeitem))
				count++
				to_remove += I

		if (count < recipecount)
			return 0
		return 1

	proc/mix()

		var/amount = length(src.contents)
		if (!amount)
			boutput(usr, SPAN_ALERT("There's nothing in the mixer."))
			return
		src.working = 1
		src.timeMixEnd = TIME + MIX_TIME
		src.power_usage = MIXER_MIXING_POWER_USAGE

		tgui_process.update_uis(src)
		src.UpdateIcon()
		playsound(src.loc, 'sound/machines/mixer.ogg', 50, 1)
		SubscribeToProcess()

	process()
		. = ..()
		if (status & (NOPOWER|BROKEN))
			UnsubscribeProcess()
			return

		var/amount = length(src.contents)
		if (!amount)
			UnsubscribeProcess()
			return

		if (TIME < src.timeMixEnd)
			return

		var/output = null // /obj/item/reagent_containers/food/snacks/yuck
		var/derivename = 0
		check_recipe:
			for (var/datum/cookingrecipe/R in src.recipes)
				to_remove.len = 0
				for(var/I in R.ingredients)
					if (!bowl_checkitem(I, R.ingredients[I])) continue check_recipe
				output = R.specialOutput(src)
				if (!output)
					output = R.output
				if (R.useshumanmeat)
					derivename = 1
				break

		if (!isnull(output))
			var/obj/item/reagent_containers/food/snacks/F
			if (ispath(output))
				F = new output(get_turf(src))
			else
				F = output
				F.set_loc(get_turf(src))

			if (derivename)
				var/foodname = F.name
				for (var/obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/M in src.contents)
					F.name = "[M.subjectname] [foodname]"
					F.desc += " It sort of smells like [M.subjectjob ? M.subjectjob : "pig"]s."
					if(!isnull(F.unlock_medal_when_eaten))
						continue
					else if (M.subjectjob && M.subjectjob == "Clown")
						F.unlock_medal_when_eaten = "That tasted funny"
					else
						F.unlock_medal_when_eaten = "Space Ham" //replace the old fat person method
		for (var/obj/item/I in to_remove)
			qdel(I)
		to_remove.len = 0

		for (var/obj/I in src.contents)
			I.set_loc(src.loc)
			src.visible_message(SPAN_ALERT("[I] is tossed out of [src]!"))
			var/edge = get_edge_target_turf(src, pick(alldirs))
			I.throw_at(edge, 25, 4)

		src.working = 0
		src.UpdateIcon()
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
		tgui_process.update_uis(src)

		src.power_usage = 0
		UnsubscribeProcess()
		return

	power_change()
		. = ..()
		src.UpdateIcon()

	disposing()
		. = ..()
		src.ClearSpecificOverlays(0)

	update_icon()
		if (!src || !istype(src))
			return

		if (length(src.contents) > 0)
			src.icon_state = "blender_filled"
		else
			src.icon_state = "blender_empty"

		var/notPowered = src.status & NOPOWER
		if (notPowered)
			src.UpdateOverlays(src.blender_off, "blender_light")
		else if (!notPowered && !src.working)
			src.UpdateOverlays(src.blender_powered, "blender_light")
		else
			src.UpdateOverlays(src.blender_working, "blender_light")

		return
