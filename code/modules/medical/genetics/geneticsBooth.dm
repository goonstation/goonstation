
/datum/geneboothproduct
	var/datum/bioEffect/BE = null
	var/name = null
	var/desc = null
	var/cost = 1
	var/id = null
	var/uses = 5
	var/registered_sale_id = null

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



/obj/machinery/genetics_booth
	name = "gene booth"
	desc = "A luxury booth that will exchange genetic upgrades for cash. It automatically bills your account using advanced magnet technology. It's safe!"
	icon = 'icons/obj/64x64.dmi'
	icon_state = "genebooth"
	pixel_x = -3
	anchored = 1
	density = 1
	event_handler_flags = USE_FLUID_ENTER | USE_CANPASS
	appearance_flags = TILE_BOUND

	var/letgo_hp = 50
	var/mob/living/carbon/human/occupant = null
	var/process_time = 20 SECONDS
	var/damage_per_tick = 1

	var/image/screenoverlay = null
	var/image/abilityoverlay = null
	var/image/workingoverlay = null
	var/eject_dir = 0
	var/entry_time = 0

	var/datum/geneboothproduct/selected_product = null
	var/list/offered_genes = list()

	var/spam_time = 0
	var/started = 0
	mats = 40
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_CROWBAR | DECON_WELDER | DECON_WIRECUTTERS | DECON_MULTITOOL

	var/datum/light/light
	var/lr = 0.88
	var/lg = 0.88
	var/lb = 1

	New()
		..()
		light = new /datum/light/point
		light.attach(src)
		light.set_brightness(0.6)
		light.set_height(1.5)
		light.set_color(lr,lg,lb)

		contextLayout = new /datum/contextLayout/flexdefault(4, 32, 32)

		START_TRACKING
		screenoverlay = SafeGetOverlayImage("screen", 'icons/obj/64x64.dmi', "genebooth_screen")
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

	disposing()
		STOP_TRACKING
		..()


	process()
		if (occupant)
			if (!powered())
				eject_occupant(0)
			if (occupant.loc != src)
				eject_occupant(0)

			started++
			if (started == 2)
				if (!try_billing(occupant))
					for (var/mob/O in hearers(src, null))
						O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"<b>[occupant.name]<b>! You can't afford [selected_product.name] with a bank account like that.\"</span></span>", 2)
					occupant.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"<b>[occupant.name]<b>! You can't afford [selected_product.name] with a bank account like that.\"</span></span>", 2)

					eject_occupant(0)
		else if (started)
			eject_occupant(0)

		updateicon()
		..()


	attack_hand(var/mob/user)
		if (occupant)
			user.show_text("[src] is currently occupied. Wait until it's done.", "blue")
			return

		if (offered_genes && offered_genes.len)
			user.show_text("Something went wrong, showing backup menu...", "blue")
			var/list/names = list()

			for (var/datum/geneboothproduct/P in offered_genes)
				names += P.name

			var/name_sel = input(user, "Offered Products", "Selection") as null|anything in names
			if (!name_sel)
				return
			if(occupant && occupant != user)
				user.show_text("There's someone else inside!")
				return

			for (var/datum/geneboothproduct/P in offered_genes)
				if (name_sel == P.name)
					select_product(P)
					break
		else
			user.show_text("[src] has no products available for purchase right now.", "blue")

	proc/reload_contexts()//IM ASORRY
		for(var/datum/contextAction/C in src.contextActions)
			C.dispose()
		src.contextActions = list()

		for (var/datum/geneboothproduct/P in offered_genes)
			var/datum/contextAction/genebooth_product/newcontext = new /datum/contextAction/genebooth_product
			newcontext.GBP = P
			newcontext.GB = src
			contextActions += newcontext

	proc/select_product(var/datum/geneboothproduct/P)
		selected_product = P
		abilityoverlay = SafeGetOverlayImage("abil", P.BE.icon, P.BE.icon_state,src.layer + 0.1)
		updateicon()

		usr.show_text("You have selected [P.name]. Walk into an opening on the side of this machine to purchase this item.", "blue")
		playsound(src.loc, "sound/machines/keypress.ogg", 50, 1, extrarange = -15, pitch = 0.60)

	proc/just_pick_anything()
		for (var/datum/geneboothproduct/P in offered_genes)
			selected_product = P
			abilityoverlay = SafeGetOverlayImage("abil", P.BE.icon, P.BE.icon_state,src.layer + 0.1)
			updateicon()
			break

	proc/updateicon()
		if (powered())
			light.enable()
			if (occupant && started>1)
				UpdateOverlays(workingoverlay, "abil", 0, 1)
				UpdateOverlays(screenoverlay, "screen", 0, 1)
				animate_shake(src,5,3,2, return_x = -3)
				playsound(src.loc, "sound/impact_sounds/Metal_Clang_1.ogg", 30, 1, pitch = 1.4)
				if (entry_time + process_time < world.timeofday)
					eject_occupant()
			else
				UpdateOverlays(abilityoverlay, "abil", 0, 1)
				UpdateOverlays(screenoverlay, "screen", 0, 1)

		else
			light.disable()
			ClearSpecificOverlays("abil")
			ClearSpecificOverlays("screen")


	proc/eject_occupant(var/add_power = 1,var/do_throwing = 1)
		if (occupant)

			if (add_power)
				if(selected_product && selected_product.BE)

					var/datum/bioEffect/NEW = new selected_product.BE.type()
					copy_datum_vars(selected_product.BE,NEW)
					occupant.bioHolder.AddEffectInstance(NEW,1)

					selected_product.uses -= 1
					if (selected_product.uses <= 0 || !selected_product.BE)
						notify_empty(selected_product)
						selected_product.dispose()
						offered_genes -= selected_product
						reload_contexts()

					playsound(src, 'sound/machines/ding.ogg', 50, 1, 0, 1.4)
			else
				playsound(src, 'sound/machines/airlock_deny.ogg', 35, 1, 0, 0.5)

			//occupant.set_loc(src.loc)

			if (eject_dir && do_throwing)
				occupant.throw_at(get_edge_target_turf(src, eject_dir), 2, 1)
			occupant = null

			updateicon()

		started = 0
		var/turf/dispense = get_step(src.loc,eject_dir)
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
				var/obj/item/card/id/perp_id = M.equipped()
				if (!istype(perp_id))
					if (istype(M.wear_id,/obj/item/device/pda2))
						var/obj/item/device/pda2/PDA = M.wear_id
						perp_id = PDA.ID_card
					else
						perp_id = M.wear_id
				if (istype(perp_id))

					//subtract from perp bank account
					var/datum/data/record/account = null
					account = FindBankAccountByName(perp_id.registered)
					if (account)
						if (account.fields["current_money"] >= selected_product.cost)
							account.fields["current_money"] -= selected_product.cost

							//add to genetecists budget etc
							if (selected_product.registered_sale_id)
								account = FindBankAccountByName(selected_product.registered_sale_id)
								if (account)
									account.fields["current_money"] += selected_product.cost/2
									wagesystem.research_budget += selected_product.cost/2
								else
									wagesystem.research_budget += selected_product.cost
							else
								wagesystem.research_budget += selected_product.cost

							for (var/mob/O in hearers(src, null))
								//if (src.glitchy_slogans)
								//	O.show_message("<span class='game say'><span class='name'>[src]</span> beeps,</span> \"[voidSpeak(message)]\"", 2)
								//else
								O.show_message("<span class='subtle'><span class='game say'><span class='name'>[src]</span> beeps, \"Thank you for your patronage, <b>[M.name]<b>.\"</span></span>", 2)


							.= 1
							notify_sale(selected_product.cost)
					else
						M.show_text("No bank account found for [perp_id.registered]!", "blue")

	proc/notify_sale(var/budget_inc, var/split_with = 0)
		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()

		var/string = "Notification: [budget_inc] credits earned from last booth sale."
		if (split_with)
			string += "Splitting half of profits with [split_with]."

		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="GENEBOOTH-MAILBOT",  "group"=MGD_MEDRESEACH, "sender"="00000000", "message"=string)
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		if(transmit_connection != null)
			transmit_connection.post_signal(src, pdaSignal)

		//playsound BEEP BEEEEEEEEEEP

	proc/notify_empty(var/datum/geneboothproduct/GBP)
		var/datum/radio_frequency/transmit_connection = radio_controller.return_frequency("1149")
		var/datum/signal/pdaSignal = get_free_signal()

		var/string = "Notification: [GBP.name] has sold out!"

		pdaSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="GENEBOOTH-MAILBOT",  "group"=MGD_MEDRESEACH, "sender"="00000000", "message"=string)
		pdaSignal.transmission_method = TRANSMISSION_RADIO
		if(transmit_connection != null)
			transmit_connection.post_signal(src, pdaSignal)

	CanPass(var/mob/M, var/atom/oldloc)
		.= ..()
		if (oldloc && oldloc.y == src.y)
			if (!occupant && selected_product && ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.bioHolder && !H.bioHolder.HasEffect(selected_product.id))
					eject_dir = get_dir(oldloc,src)
					M.set_loc(src)
					occupant = M
					letgo_hp = initial(letgo_hp)
					entry_time = world.timeofday
					started = 0

					if (world.time > spam_time + 3 SECONDS)
						playsound(src.loc, "sound/machines/heater_on.ogg", 90, 1, pitch = 0.78)
						M.show_text("[src] is warming up. Please hold still.", "blue")
						spam_time = world.time

					updateicon()
					.= 1
				else
					if (world.time > spam_time + 3 SECONDS)
						M.show_text("You already have the offered mutation!", "blue")
						spam_time = world.time


	mob_flip_inside(var/mob/user)
		..(user)
		user.show_text("<span class='alert'>[src] [pick("bends","shakes","groans")].</span>")
		if (prob(8))
			src.eject_occupant(add_power = 0)

	relaymove(mob/user, direction)
		if (direction != eject_dir)
			if (direction & WEST || direction & EAST)
				if (occupant == user && !(started>1))
					src.eject_occupant(0,0)
					step(user,direction)

	attackby(obj/item/W as obj, mob/user as mob)
		user.lastattacked = src
		letgo_hp -= W.force
		attack_particle(user,src)
		playsound(src.loc, "sound/impact_sounds/Metal_Clang_3.ogg", 50, 1, pitch = 0.8)

		if (letgo_hp <= 0)
			src.eject_occupant(add_power = 0)

//next :
	//sound effects
	//do slight damage to occupant on jumble?

