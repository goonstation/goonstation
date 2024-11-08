var/list/genescanner_addresses = list()
var/list/genetek_hair_styles = list()

TYPEINFO(/obj/machinery/genetics_scanner)
	mats = 15

/obj/machinery/genetics_scanner
	name = "GeneTek scanner"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner_0"
	density = 1
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL
	var/mob/occupant = null
	var/datum/movable_preview/character/multiclient/occupant_preview = null
	var/locked = 0
	anchored = ANCHORED
	soundproofing = 10

	var/net_id = null
	var/frequency = FREQ_PDA

	New()
		..()
		if(!src.net_id)
			src.net_id = generate_net_id(src)
			genescanner_addresses += src.net_id
		MAKE_SENDER_RADIO_PACKET_COMPONENT(src.net_id, null, frequency)

	disposing()
		if (src.net_id)
			genescanner_addresses -= src.net_id
		if(occupant)
			occupant.set_loc(get_turf(src.loc))
			occupant = null
		..()

	allow_drop()
		return 0

	examine()
		. = ..()
		if (src.occupant)
			. += "[src.occupant.name] is inside the scanner."
		else
			. += "There is nobody currently inside the scanner."
		if (src.locked)
			. += "The scanner is currently locked."
		else
			. += "The scanner is not currently locked."

	mob_flip_inside(mob/user)
		..(user)
		if (prob(33))
			user.show_text(SPAN_ALERT("[src] [pick("cracks","bends","shakes","groans")]."))
			src.togglelock(1)

	relaymove(mob/user as mob, dir)
		if(!ismobcritter(user) || user.client)
			eject_occupant(user)

	Click(location, control, params)
		if(!src.ghost_observe_occupant(usr, src.occupant))
			. = ..()

	MouseDrop_T(mob/living/target, mob/user)
		if (!istype(target) || isAI(user))
			return

		if (BOUNDS_DIST(src, user) > 0 || BOUNDS_DIST(user, target) > 0)
			return

		if (target == user)
			move_mob_inside(target)
		else if (can_operate(user,target))
			var/previous_user_intent = user.a_intent
			user.set_a_intent(INTENT_GRAB)
			user.drop_item()
			target.Attackhand(user)
			user.set_a_intent(previous_user_intent)
			SPAWN(user.combat_click_delay + 2)
				if (can_operate(user,target))
					if (istype(user.equipped(), /obj/item/grab))
						src.Attackby(user.equipped(), user)
		return

	proc/can_operate(var/mob/M, var/mob/living/target)
		if (!isalive(M))
			return 0
		if (BOUNDS_DIST(src, M) > 0)
			return 0
		if (M.getStatusDuration("unconscious") || M.getStatusDuration("stunned") || M.getStatusDuration("knockdown"))
			return 0
		if (src.occupant)
			boutput(M, SPAN_NOTICE("<B>The scanner is already occupied!</B>"))
			return 0
		if(ismobcritter(target))
			if(!genResearch.isResearched(/datum/geneticsResearchEntry/critter_scanner))
				boutput(M, SPAN_ALERT("<B>The scanner doesn't support this body type.</B>"))
				return 0
			if(!target.has_genetics())
				boutput(M, SPAN_ALERT("<B>The scanner doesn't support this genetic structure.</B>"))
				return 0
		else if(!iscarbon(target) )
			boutput(M, SPAN_ALERT("<B>The scanner supports only carbon based lifeforms.</B>"))
			return 0
		if (src.occupant)
			boutput(M, SPAN_NOTICE("<B>The scanner is already occupied!</B>"))
			return 0
		if (src.locked)
			boutput(M, SPAN_ALERT("<B>You need to unlock the scanner first.</B>"))
			return 0

		.= 1

	proc/move_mob_inside(var/mob/M)
		if (!can_operate(M,M)) return

		M.remove_pulling()
		src.go_in(M)

		for(var/obj/O in src)
			O.set_loc(src.loc)

		src.add_fingerprint(usr)

	verb/move_inside()
		set name = "Enter"
		set src in oview(1)
		set category = "Local"

		move_mob_inside(usr)

	attack_hand(mob/user)
		..()
		eject_occupant(user)

	mouse_drop(mob/user as mob)
		if (can_operate(user))
			eject_occupant(user)
		else
			..()

	verb/eject()
		set name = "Eject Occupant"
		set src in oview(1)
		set category = "Local"

		eject_occupant(usr)


	verb/eject_occupant(var/mob/user)
		if (!src.can_eject_occupant(user))
			return
		if (src.locked)
			boutput(user, SPAN_ALERT("<b>The scanner door is locked!</b>"))
			return

		src.go_out()
		add_fingerprint(user)

	attackby(var/obj/item/grab/G, user)
		if (!istype(G))
			return

		if(!can_operate(user, G.affecting))
			return

		var/mob/living/L = user

		var/mob/M = G.affecting
		if (L.pulling == M)
			L.remove_pulling()
		src.go_in(M)

		for(var/obj/O in src)
			O.set_loc(src.loc)

		src.add_fingerprint(user)
		qdel(G)

	verb/lock()
		set name = "Scanner Lock"
		set src in oview(1)
		set category = "Local"

		if (!isalive(usr))
			return
		if (usr == src.occupant)
			boutput(usr, SPAN_ALERT("<b>You can't reach the scanner lock from the inside.</b>"))
			return
		src.togglelock()
		return

	proc/togglelock(var/forceunlock = 0)
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		if (src.locked || forceunlock)
			src.locked = 0
			usr.visible_message("<b>[usr]</b> unlocks the scanner.")
			if (src.occupant)
				boutput(src.occupant, SPAN_ALERT("You hear the scanner's lock slide out of place."))
		else
			src.locked = 1
			usr.visible_message("<b>[usr]</b> locks the scanner.")
			if (src.occupant)
				boutput(src.occupant, SPAN_ALERT("You hear the scanner's lock click into place."))

		// Added (Convair880).
		if (src.occupant)
			logTheThing(LOG_STATION, usr, "[src.locked ? "locks" : "unlocks"] the [src.name] with [constructTarget(src.occupant,"station")] inside at [log_loc(src)].")

		return

	proc/go_in(var/mob/M)
		if (src.occupant || !M)
			return

		if (src.locked)
			return

		M.set_loc(src)
		src.occupant = M
		src.icon_state = "scanner_1"
		src.update_occupant()

		// open the computer UI so the person in the scanner can watch.
		var/obj/machinery/computer/genetics/C = locate(/obj/machinery/computer/genetics, orange(1, src))
		if (istype(C))
			C.ui_interact(M, null)

		playsound(src.loc, 'sound/machines/sleeper_close.ogg', 50, 1)
		return

	proc/go_out()
		if (!src.occupant)
			return

		if (src.locked)
			return

		if(!src.occupant.disposed)
			src.occupant.set_loc(get_turf(src))

		src.occupant = null

		for(var/atom/movable/A in src)
			A.set_loc(src.loc)

		src.icon_state = "scanner_0"

		playsound(src.loc, 'sound/machines/sleeper_open.ogg', 50, 1)
		return


	proc/update_occupant()
		var/mob/living/carbon/human/H = src.occupant
		if (istype(H))
			if (src.occupant_preview)
				src.occupant_preview.update_appearance(H.bioHolder.mobAppearance, H.mutantrace, name=H.real_name)
		else
			qdel(src.occupant_preview)
			src.occupant_preview = null

	was_deconstructed_to_frame(mob/user)
		src.go_out()

///////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/genetics_appearancemenu
	var/mob/living/carbon/human/target_mob = null
	var/direction = SOUTH

	var/list/datum/customization_style/customizations = list(
		"hair_bottom" = new /datum/customizationHolder/hair/first,
		"hair_middle" = new /datum/customizationHolder/hair/second,
		"hair_top" = new /datum/customizationHolder/hair/third,
	)
	var/list/colors = list(
		"hair_bottom" = "#FFFFFF",
		"hair_middle" = "#FFFFFF",
		"hair_top" = "#FFFFFF",
	)

	var/e_color = "#FFFFFF"

	var/s_tone = "#FAD7D0"

	var/datum/movable_preview/character/multiclient/preview = null

	New(mob/target)
		..()
		if(!ishuman(target))
			qdel(src)
			return

		src.target_mob = target
		src.preview = new()
		src.preview.add_background("#092426", height_mult = 2)
		src.load_mob_data(src.target_mob)
		return

	disposing()
		. = ..()
		qdel(src.preview)

	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if (.)
			return
		switch (action)
			if("editappearance")
				. = TRUE
				var/fixColors = !!(src.target_mob.mutantrace?.mutant_appearance_flags & FIX_COLORS)
				if (params["skin"])
					src.s_tone = sanitize_color(params["skin"], FALSE)
				if (params["eyes"])
					src.e_color = sanitize_color(params["eyes"], FALSE)
				if (params["color1"])
					src.colors["hair_bottom"] = sanitize_color(params["color1"], fixColors)
				if (params["color2"])
					src.colors["hair_middle"] = sanitize_color(params["color2"], fixColors)
				if (params["color3"])
					src.colors["hair_top"] = sanitize_color(params["color3"], fixColors)
				if (params["style1"])
					src.customizations["hair_bottom"] = find_style_by_name(params["style1"], usr.client)
				if (params["style2"])
					src.customizations["hair_middle"] = find_style_by_name(params["style2"], usr.client)
				if (params["style3"])
					src.customizations["hair_top"] = find_style_by_name(params["style3"], usr.client)
				if (params["apply"] || params["cancel"])
					if (params["apply"])
						src.copy_to_target()
					qdel(src)
					return
				src.update_preview_icon()

	ui_data(mob/user)
		src.preview?.add_client(user?.client)

		if (!genetek_hair_styles.len)
			for (var/datum/customization_style/styletype as anything in get_available_custom_style_types(user.client))
				var/datum/customization_style/CS = new styletype
				genetek_hair_styles += CS.name

		var/fixColors = !!(src.target_mob.mutantrace?.mutant_appearance_flags & FIX_COLORS)
		var/hasHumanEyes = !src.target_mob.mutantrace || (src.target_mob.mutantrace.mutant_appearance_flags & HAS_HUMAN_EYES)
		var/hasHumanSkintone = !src.target_mob.mutantrace || (src.target_mob.mutantrace.mutant_appearance_flags & HAS_HUMAN_SKINTONE)
		var/hasHumanHair = !src.target_mob.mutantrace || (src.target_mob.mutantrace.mutant_appearance_flags & HAS_HUMAN_HAIR)
		var/colorChannels = list("Bottom Detail", "Mid Detail", "Top Detail")
		if (!hasHumanHair)
			colorChannels = src.target_mob.mutantrace.color_channel_names

		return list(
			"preview" = src.preview.preview_id,
			"hairStyles" = genetek_hair_styles,
			"direction" = src.direction,
			"skin" = src.s_tone,
			"eyes" = src.e_color,
			"color1" = src.colors["hair_bottom"],
			"color2" = src.colors["hair_middle"],
			"color3" = src.colors["hair_top"],
			"style1" = src.customizations["hair_bottom"].name,
			"style2" = src.customizations["hair_middle"].name,
			"style3" = src.customizations["hair_top"].name,
			"fixColors" = fixColors,
			"hasEyes" = hasHumanEyes,
			"hasSkin" = hasHumanSkintone,
			"hasHair" = hasHumanHair,
			"channels" = colorChannels,
		)

	ui_close(mob/user)
		. = ..()
		src.preview?.remove_client(user?.client)

	proc
		load_mob_data(var/mob/living/carbon/human/H)
			if(!ishuman(H))
				qdel(src)
				return

			var/datum/appearanceHolder/AH = H.bioHolder.mobAppearance
			src.s_tone = AH.s_tone

			var/hair_slots = list("hair_bottom", "hair_middle", "hair_top")
			for (var/slot in hair_slots)
				var/datum/customizationHolder/holder = AH.getCustomizationByID(slot)
				var/datum/customizationHolder/geneHolder = src.customizations[slot]
				if (!istype(holder))
					continue
				geneHolder.set_style(holder.style)
				geneHolder.color = holder.color

			src.e_color = AH.e_color

			return

		copy_to_target()
			if(!target_mob)
				return

			sanitize_null_values()

			var/hair_slots = list("hair_bottom", "hair_middle", "hair_top")

			var/datum/appearanceHolder/AH = target_mob.bioHolder.mobAppearance
			for (var/slot in hair_slots)
				var/datum/customizationHolder/holder = AH.getCustomizationByID(slot)
				if (!istype(holder))
					continue
				holder.color = src.colors[slot]
				holder.color_original = src.colors[slot]
				holder.set_style(src.customizations[slot])
				holder.set_style(src.customizations[slot], TRUE)

			AH.e_color = e_color
			AH.e_color_original = e_color

			AH.s_tone = s_tone
			AH.s_tone_original = s_tone
			if (target_mob.limbs)
				target_mob.limbs.reset_stone()

			target_mob.update_colorful_parts()
			target_mob.set_face_icon_dirty()
			target_mob.set_body_icon_dirty()

		sanitize_color(color, fix)
			if (fix)
				. = fix_colors(color)
			else
				var/list/L = hex_to_rgb_list(color)
				. = rgb(L[1], L[2], L[3])

		sanitize_null_values()
			if (src.colors["hair_bottom"] == null)
				src.colors["hair_bottom"] = "#101010"
			if (src.colors["hair_middle"] == null)
				src.colors["hair_middle"] = "#101010"
			if (src.colors["hair_top"] == null)
				src.colors["hair_top"] = "#101010"
			if (e_color == null)
				e_color = "#101010"
			if (s_tone == null || s_tone == "#ffffff")
				s_tone = "#FEFEFE"

		update_preview_icon()
			var/datum/appearanceHolder/AH = new()
			AH.CopyOther(src.target_mob.bioHolder.mobAppearance)

			src.preview.update_appearance(AH, src.target_mob.mutantrace, src.direction)
