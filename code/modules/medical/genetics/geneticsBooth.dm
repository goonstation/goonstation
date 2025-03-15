
/datum/geneboothproduct
	var/datum/bioEffect/BE = null
	var/name = null
	var/desc = null
	var/cost = 1
	var/id = null
	var/uses = 5
	var/registered_sale_id = null
	var/locked = FALSE

	New(bioeffect, description, price, registered)
		BE = bioeffect
		name = BE.name
		id = BE.id

		desc = description
		cost=price

		registered_sale_id = registered
		..()

	disposing()
		BE=null
		name=null
		desc=null
		cost=null
		id=null
		uses=null
		registered_sale_id = null
		..()



TYPEINFO(/obj/machinery/genetics_booth)
	mats = 40
	start_speech_modifiers = null
	start_speech_outputs = list(SPEECH_OUTPUT_SPOKEN_SUBTLE)

/obj/machinery/genetics_booth
	name = "gene booth"
	desc = "A luxury booth that will exchange genetic upgrades for cash. It automatically bills your account using advanced magnet technology. It's safe!"
	icon = 'icons/obj/large/64x64.dmi'
	icon_state = "genebooth"
	pass_unstable = TRUE
	pixel_x = -3
	anchored = ANCHORED
	density = 1
	event_handler_flags = USE_FLUID_ENTER
	appearance_flags = TILE_BOUND | PIXEL_SCALE | LONG_GLIDE
	req_access = list(access_captain, access_head_of_personnel, access_maxsec, access_medical_director)
	speech_verb_say = "beeps"
	default_speech_output_channel = SAY_CHANNEL_OUTLOUD

	var/letgo_hp = 50
	var/mob/living/carbon/human/occupant = null
	var/process_time = 20 SECONDS
	var/static/process_speedup = 0 // static since the genetek upgrade is universal
	var/damage_per_tick = 1

	var/image/screenoverlay = null
	var/image/abilityoverlay = null
	var/image/workingoverlay = null
	var/eject_dir = 0
	var/entry_time = 0

	var/datum/geneboothproduct/selected_product = null
	var/list/offered_genes = list()

	var/started = 0
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL | DECON_NO_ACCESS

	var/datum/light/light
	var/light_r =0.88
	var/light_g = 0.88
	var/light_b = 1

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.6)
		light.set_height(1.5)
		light.set_color(light_r, light_g, light_b)

		contextLayout = new /datum/contextLayout/flexdefault(4, 32, 32)

		START_TRACKING
		screenoverlay = SafeGetOverlayImage("screen", 'icons/obj/large/64x64.dmi', "genebooth_screen")
		screenoverlay.blend_mode = BLEND_MULTIPLY
		screenoverlay.layer = src.layer + 0.2

		abilityoverlay = SafeGetOverlayImage("abil", 'icons/mob/genetics_powers.dmi', "none")
		abilityoverlay.transform *= 0.5
		abilityoverlay.pixel_x = 3
		abilityoverlay.pixel_y = 2
		abilityoverlay.layer = src.layer + 0.1


		workingoverlay = SafeGetOverlayImage("abil", 'icons/mob/genetics_powers.dmi', "working")
		workingoverlay.transform *= 0.5
		workingoverlay.pixel_x = 3
		workingoverlay.pixel_y = 2
		workingoverlay.layer = src.layer + 0.1

		MAKE_SENDER_RADIO_PACKET_COMPONENT(null, "pda", FREQ_PDA)

	disposing()
		STOP_TRACKING
		if(occupant)
			occupant.set_loc(get_turf(src.loc))
			occupant = null
		..()

	process()
		if (occupant)
			if (!powered())
				eject_occupant(0)
			if (occupant?.loc != src)
				eject_occupant(0)
			if(!occupant)
				return

			started++
			if ((started == 2) && !try_billing(occupant))
				src.say("<b>[occupant.name]<b>! You can't afford [selected_product.name] with a bank account like that.", flags = SAYFLAG_IGNORE_HTML)
				src.eject_occupant(0)

		else if (started)
			eject_occupant(0)

		UpdateIcon()
		..()


	attack_hand(var/mob/user)
		if (occupant)
			user.show_text("[src] is currently occupied. Wait until it's done.", "blue")
			return

		if (status & (NOPOWER | BROKEN))
			boutput(user, SPAN_ALERT("The gene booth is currently nonfunctional."))
			return


		if (length(offered_genes))
			var/list/names = list()
			show_admin_panel(user)
			for (var/datum/geneboothproduct/P as anything in offered_genes)
				if(!P.locked)
					names += P.name
			if(length(names))
				user.show_text("Something went wrong, showing backup menu...", "blue")
				var/name_sel = input(user, "Offered Products", "Selection") as null|anything in names
				if (!name_sel)
					return
				for (var/datum/geneboothproduct/P as anything in offered_genes)
					if (name_sel == P.name)
						select_product(P)
						break
		else
			user.show_text("[src] has no products available for purchase right now.", "blue")

	proc/reload_contexts()//IM ASORRY
		for(var/datum/contextAction/C as anything in src.contextActions)
			C.dispose()
		src.contextActions = list()

		for (var/datum/geneboothproduct/P as anything in offered_genes)
			if(!P.locked)
				var/datum/contextAction/genebooth_product/newcontext = new /datum/contextAction/genebooth_product
				newcontext.GBP = P
				newcontext.GB = src
				contextActions += newcontext

	proc/show_admin_panel(mob/user)
		if(user && src.allowed(user))
			if(length(offered_genes))
				. = ""
				for (var/datum/geneboothproduct/P as() in offered_genes)
					. += "<u>[P.name]</u><small> "
					. += " * Price: <A href='?src=\ref[src];op=\ref[P];action=price'>[P.cost]</A>"
					. += " * <A href='?src=\ref[src];op=\ref[P];action=lock'>[P.locked ? "Locked" : "Unlocked"]</A></small><BR/>"

			else
				. += "[src] has no products available for purchase right now."
			src.add_dialog(user)
			user.Browse("<HEAD><TITLE>Genebooth Administrative Control Panel</TITLE></HEAD><TT>[.]</TT>", "window=genebooth")
			onclose(user, "genebooth")

	Topic(href, href_list)
		if (usr.stat)
			return
		if ((in_interact_range(src, usr) && istype(src.loc, /turf)) || (issilicon(usr)))
			var/datum/geneboothproduct/P
			src.add_dialog(usr)

			switch(href_list["action"])

				if("price")
					if(href_list["op"])
						P = locate(href_list["op"])
						var/price = input(usr, "Please enter price for [P.name].", "Gene Price", 0) as null|num
						if(!isnum_safe(price))
							return
						price = ceil(clamp(price, 0, 999999))
						P.cost = price

				if("lock")
					if(href_list["op"])
						P = locate(href_list["op"])
						if(P)
							P.locked = !P.locked
							if(selected_product?.locked)
								select_product(null)
								eject_occupant(0)
							reload_contexts()

			show_admin_panel(usr)
		else
			usr.Browse(null, "window=genebooth")
			src.remove_dialog(usr)
		return

	proc/select_product(var/datum/geneboothproduct/P)
		selected_product = P
		if(P)
			abilityoverlay = SafeGetOverlayImage("abil", P.BE.icon, P.BE.icon_state,src.layer + 0.1)
			UpdateIcon()
			usr.show_text("You have selected [P.name]. Walk into an opening on the side of this machine to purchase this item.", "blue")
			playsound(src.loc, 'sound/machines/keypress.ogg', 50, 1, extrarange = -15, pitch = 0.6)
		else
			abilityoverlay = SafeGetOverlayImage("abil", 'icons/mob/genetics_powers.dmi', "none")
			UpdateIcon()

	update_icon()
		if (powered())
			light.enable()
			if (occupant && started>1)
				UpdateOverlays(workingoverlay, "abil", 0, 1)
				UpdateOverlays(screenoverlay, "screen", 0, 1)
				animate_shake(src,5,3,2, return_x = -3)
				playsound(src.loc, 'sound/impact_sounds/Metal_Clang_1.ogg', 30, 1, pitch = 1.4)
				var/adjusted_time = process_time - (process_time * process_speedup)
				if (entry_time + adjusted_time < TIME)
					eject_occupant()
			else
				UpdateOverlays(abilityoverlay, "abil", 0, 1)
				UpdateOverlays(screenoverlay, "screen", 0, 1)

		else
			light.disable()
			ClearSpecificOverlays("abil")
			ClearSpecificOverlays("screen")


	proc/eject_occupant(var/add_power = 1,var/do_throwing = 1, var/override_dir = null)
		if (occupant)

			if (add_power)
				if(selected_product?.BE)

					var/datum/bioEffect/NEW = new selected_product.BE.type()
					copy_datum_vars(selected_product.BE, NEW, blacklist=list("owner", "holder", "dnaBlocks"))
					occupant.bioHolder.AddEffectInstanceNoDelay(NEW)

					selected_product.uses -= 1
					if (selected_product.uses <= 0 || !selected_product.BE)
						notify_empty(selected_product)
						selected_product.dispose()
						offered_genes -= selected_product
						reload_contexts()

					playsound(src, 'sound/machines/ding.ogg', 50, TRUE, 0, 1.4)
			else
				playsound(src, 'sound/machines/airlock_deny.ogg', 35, TRUE, 0, 0.5)

			//occupant.set_loc(src.loc)

			if (eject_dir && do_throwing)
				occupant.throw_at(get_edge_target_turf(src, eject_dir), 2, 1)
			occupant = null

			UpdateIcon()

		started = 0
		var/turf/dispense = (override_dir ? get_step(src.loc, override_dir) : get_step(src.loc, eject_dir))
		for (var/atom in src)
			var/atom/movable/A = atom
			A.set_loc(dispense)


	proc/try_billing(var/mob/living/carbon/human/M)
		.= 0
		if (selected_product)

			//free, wow!
			if (selected_product.cost <= 0)
				.= 1
			else
				var/obj/item/card/id/perp_id = get_id_card(M.equipped())
				if (!istype(perp_id))
					perp_id = get_id_card(M.wear_id)
				if (istype(perp_id))

					//subtract from perp bank account
					var/datum/db_record/account = null
					account = FindBankAccountByName(perp_id.registered)
					if (account)
						if (account["current_money"] >= selected_product.cost)
							account["current_money"] -= selected_product.cost

							//add to genetecists budget etc
							if (selected_product.registered_sale_id)
								account = FindBankAccountByName(selected_product.registered_sale_id)
								if (account)
									account["current_money"] += selected_product.cost/2
									wagesystem.research_budget += selected_product.cost/2
								else
									wagesystem.research_budget += selected_product.cost
							else
								wagesystem.research_budget += selected_product.cost

							src.say("Thank you for your patronage, <b>[M.name]<b>")

							.= 1
							notify_sale(selected_product.cost)
					else
						M.show_text("No bank account found for [perp_id.registered]!", "blue")

	proc/notify_sale(var/budget_inc, var/split_with = 0)
		var/datum/signal/pdaSignal = get_free_signal()

		var/string = "Notification: [budget_inc] credits earned from last booth sale."
		if (split_with)
			string += "Splitting half of profits with [split_with]."

		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="GENEBOOTH-MAILBOT", "group"=list(MGD_MEDRESEACH, MGA_SALES), "sender"="00000000", "message"=string)
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal)

		//playsound BEEP BEEEEEEEEEEP

	proc/notify_empty(var/datum/geneboothproduct/GBP)
		var/datum/signal/pdaSignal = get_free_signal()

		var/string = "Notification: [GBP.name] has sold out!"

		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="GENEBOOTH-MAILBOT", "group"=list(MGD_MEDRESEACH, MGA_SALES), "sender"="00000000", "message"=string)
		SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, pdaSignal)

	Cross(var/mob/M)
		.= ..()
		if (!(src.status & (NOPOWER | BROKEN)) && ishuman(M) && M.y == src.y && !occupant && selected_product && !GET_COOLDOWN(M, "genebooth_debounce"))
			return TRUE

	Crossed(var/mob/M, atom/oldLoc)
		. = ..()
		if (!M || M.y != src.y || GET_COOLDOWN(M, "genebooth_debounce"))
			return
		if (occupant || !selected_product || !ishuman(M))
			return
		var/mob/living/carbon/human/H = M
		if (H.bioHolder)
			ON_COOLDOWN(M, "genebooth_debounce", 2 SECONDS)
			eject_dir = pick(EAST, WEST)
			M.set_loc(src)
			occupant = M
			letgo_hp = initial(letgo_hp)
			entry_time = TIME
			started = 0

			UpdateIcon()

			if (H.bioHolder.HasEffect(selected_product.id))
				SPAWN(1 SECOND)
					src.eject_occupant(add_power=0)
					if (!ON_COOLDOWN(M, "genebooth_message_antispam", 3 SECONDS))
						M.show_text("You already have the offered mutation!", "blue")
				return

			if (!ON_COOLDOWN(M, "genebooth_message_antispam", 3 SECONDS))
				playsound(src.loc, 'sound/machines/heater_on.ogg', 90, 1, pitch = 0.78)
				M.show_text("[src] is warming up. Please hold still.", "blue")

	mob_flip_inside(var/mob/user)
		..(user)
		user.show_text(SPAN_ALERT("[src] [pick("bends","shakes","groans")]."))
		if (prob(33))
			src.eject_occupant(add_power = 0)

	relaymove(mob/user, direction)
		if (direction != eject_dir)
			if (direction == WEST || direction == EAST)
				if (occupant == user && !(started>1))
					src.eject_occupant(0,0, direction)

	attackby(obj/item/W, mob/user)
		user.lastattacked = get_weakref(src)
		letgo_hp -= W.force
		attack_particle(user,src)
		playsound(src.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1, pitch = 0.8)

		if (letgo_hp <= 0)
			src.eject_occupant(add_power = 0)

	was_deconstructed_to_frame(mob/user)
		src.eject_occupant(do_throwing=FALSE)

//next :
	//sound effects
	//do slight damage to occupant on jumble?

