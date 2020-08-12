/datum/abilityHolder/wraith
	topBarRendered = 1
	pointName = "Wraith Points"
	cast_while_dead = 1
	var/corpsecount = 0

/obj/screen/ability/topBar/wraith
	tens_offset_x = 19
	tens_offset_y = 7
	secs_offset_x = 23
	secs_offset_y = 7

	MouseEntered(location, control, params)
		if (usr.client.tooltipHolder && control == "mapwindow.map")
			if (!istype(owner, /datum/targetable/wraithAbility/spook))
				var/theme = src.owner.theme

				usr.client.tooltipHolder.showHover(src, list(
					"params" = params,
					"title" = src.name,
					"content" = (src.desc ? src.desc : null),
					"theme" = theme
				))

/datum/targetable/wraithAbility
	icon = 'icons/mob/wraith_ui.dmi'
	icon_state = "template"
	cooldown = 0
	last_cast = 0
	targeted = 1
	target_anything = 1
	preferred_holder_type = /datum/abilityHolder/wraith
	theme = "wraith"

	New()
		var/obj/screen/ability/topBar/wraith/B = new /obj/screen/ability/topBar/wraith(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.owner = src
		B.name = src.name
		B.desc = src.desc
		src.object = B

	cast(atom/target)
		if (!holder || !holder.owner)
			return 1
		//if (!iswraith(holder.owner))
		//	boutput(holder.owner, "<span class='alert'>Yo, you're not a wraith, stop that. (like how the hell did you get this. report this to a coder asap)</span>")
		//	return 1
		return 0

	doCooldown()
		if (!holder)
			return
		last_cast = world.time + cooldown
		holder.updateButtons()
		SPAWN_DBG(cooldown + 5)
			holder.updateButtons()


/datum/targetable/wraithAbility/help
	name = "Toggle Help Mode"
	desc = "Enter or exit help mode."
	icon_state = "help0"
	targeted = 0
	cooldown = 0
	helpable = 0
	special_screen_loc = "SOUTH,EAST"

	cast(atom/target)
		if (..())
			return 1
		if (holder.help_mode)
			holder.help_mode = 0
		else
			holder.help_mode = 1
			boutput(holder.owner, "<span class='notice'><strong>Help Mode has been activated  To disable it, click on this button again.</strong></span>")
			boutput(holder.owner, "<span class='notice'>Hold down Shift, Ctrl or Alt while clicking the button to set it to that key.</span>")
			boutput(holder.owner, "<span class='notice'>You will then be able to use it freely by holding that button and left-clicking a tile.</span>")
			boutput(holder.owner, "<span class='notice'>Alternatively, you can click with your middle mouse button to use the ability on your current tile.</span>")
		src.object.icon_state = "help[holder.help_mode]"
		holder.updateButtons()


/datum/targetable/wraithAbility/absorbCorpse
	name = "Absorb Corpse"
	icon_state = "absorbcorpse"
	desc = "Steal life essence from a corpse. You cannot use this on a skeleton!"
	targeted = 1
	target_anything = 1
	pointCost = 20
	cooldown = 450 //Starts at 45 seconds and scales upward exponentially

	cast(atom/T)
		if (..())
			return 1
		if (!T)
			T = get_turf(holder.owner)

		//Find a suitable corpse
		var/error = 0
		var/mob/living/carbon/human/M
		if (isturf(T))
			for (var/mob/living/carbon/human/target in T.contents)
				if (isdead(target))
					error = 1
					if (target:decomp_stage != 4)
						M = target
						break
		else if (ishuman(T))
			M = T
			if (!isdead(M))
				boutput(holder.owner, "<span class='alert'>The living consciousness controlling this body shields it from being absorbed.</span>")
				return 1
			else if (M.decomp_stage == 4)
				M = null
				error = 1
			else
				M = T
		else
			boutput(holder.owner, "<span class='alert'>Absorbing [src] does not satisfy your ethereal taste.</span>")
			return 1

		if (!M && !error)
			boutput(holder.owner, "<span class='alert'>There are no usable corpses here!</span>")
			return 1
		if (!M && error)
			boutput(holder.owner, "<span class='alert'>[pick("This body is too decrepit to be of any use.", "This corpse has already been run through the wringer.", "There's nothing useful left.", "This corpse is worthless now.")]</span>")
			return 1

		logTheThing("combat", usr, null, "absorbs the corpse of [key_name(M)] as a wraith.")

		//Make the corpse all grody and skeleton-y
		M.decomp_stage = 4
		if (M.organHolder && M.organHolder.brain)
			qdel(M.organHolder.brain)
		M.set_face_icon_dirty()
		M.set_body_icon_dirty()
		particleMaster.SpawnSystem(new /datum/particleSystem/localSmoke("#000000", 5, locate(M.x, M.y, M.z)))

		holder.regenRate *= 2.0
		holder.owner:onAbsorb(M)
		//Messages for everyone!
		boutput(holder.owner, "<span class='alert'><strong>[pick("You draw the essence of death out of [M]'s corpse!", "You drain the last scraps of life out of [M]'s corpse!")]</strong></span>")
		for (var/mob/living/V in viewers(7, holder.owner))
			boutput(V, "<span class='alert'><strong>[pick("Black smoke rises from [M]'s corpse! Freaky!", "[M]'s corpse suddenly rots to nothing but bone in moments!")]</strong></span>")

		return 0


	doCooldown()         //This makes it so wraith early game is much faster but hits a wall of high absorb cooldowns after ~5 corpses
		if (!holder)	 //so wraiths don't hit scientific notation rates of regen without playing perfectly for a million years
			return
		var/datum/abilityHolder/wraith/W = holder
		if (istype(W))
			if (W.corpsecount == 0)
				cooldown = 450
				W.corpsecount += 1
			else
				cooldown += W.corpsecount * 150
				W.corpsecount += 1
		last_cast = world.time + cooldown
		holder.updateButtons()
		SPAWN_DBG(cooldown + 5)
			holder.updateButtons()


/datum/targetable/wraithAbility/possessObject
	name = "Possess Object"
	icon_state = "possessobject"
	desc = "Possess and control an everyday object. Freakout level: high."
	targeted = 1
	target_anything = 1
	pointCost = 300
	cooldown = 1500 //Tweaked this down from 3 minutes to 2 1/2, let's see if that ruins anything

	cast(atom/T)
		if (..())
			return 1

		if (src.holder.owner.density)
			boutput(usr, "<span class='alert'>You cannot force your consciousness into a body while corporeal.</span>")
			return 1

		if (!isitem(T) || istype(T, /obj/item/storage/bible))
			boutput(holder.owner, "<span class='alert'>You cannot possess this!</span>")
			return 1

		boutput(holder.owner, "<span class='alert'><strong>[pick("You extend your will into [T].", "You force [T] to do your bidding.")]</strong></span>")
		var/mob/living/object/O = new/mob/living/object(T, holder.owner)

		SPAWN_DBG (450)
			if (O)
				boutput(O, "<span class='alert'>You feel your control of this vessel slipping away!</span>")
		SPAWN_DBG (600) //time limit on possession: 1 minute
			if (O)
				boutput(O, "<span class='alert'><strong>Your control is wrested away! The item is no longer yours.</strong></span>")
				O.death(0)

		return 0


/datum/targetable/wraithAbility/makeRevenant
	name = "Raise Revenant"
	icon_state = "revenant"
	desc = "Take control of an intact corpse as a powerful Revenant! You will not be able to absorb this corpse later. As a revenant, you gain increased point generation, but your revenant abilities cost much more points than normal."
	targeted = 1
	target_anything = 1
	pointCost = 1000
	cooldown = 5000 //5 minutes

	cast(atom/T)
		if (..())
			return 1

		if (src.holder.owner.density)
			boutput(usr, "<span class='alert'>You cannot force your consciousness into a body while corporeal.</span>")
			return 1

		//If you targeted a turf for some reason, find a corpse on it
		if (istype(T, /turf))
			for (var/mob/living/carbon/human/target in T.contents)
				if (isdead(target) && target:decomp_stage != 4)
					T = target
					break

		if (ishuman(T))
			var/mob/wraith/W = holder.owner
			return W.makeRevenant(T)
			//return 0
		else
			boutput(usr, "<span class='alert'>There are no corpses here to possess!</span>")
			return 1

/datum/targetable/wraithAbility/decay
	name = "Decay"
	icon_state = "decay"
	desc = "Cause a human to lose stamina, or an object to malfunction."
	targeted = 1
	target_anything = 1
	pointCost = 30
	cooldown = 600 //1 minute

	cast(atom/T)
		if (..())
			return 1

		//If you targeted a turf for some reason, find a valid target on it
		var/atom/target = null
		if (istype(T, /turf))
			for (var/mob/living/carbon/human/M in T.contents)
				if (!isdead(M))
					target = M
					break
			if (!target)
				for (var/obj/O in T.contents)
					target = O //todo: emaggable check
					break
		else
			target = T

		if (ishuman(T))
			var/mob/living/carbon/H = T
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(usr, "<span class='alert'>Some mysterious force protects [T] from your influence.</span>")
				return 1
			else
				boutput(usr, "<span class='notice'>[pick("You sap [T]'s energy.", "You suck the breath out of [T].")]</span>")
				boutput(T, "<span class='alert'>You feel really tired all of a sudden!</span>")
				H.emote("pale")
				H.remove_stamina( rand(100, 120) )//might be nice if decay was useful.
				H.changeStatus("stunned", 4 SECONDS)
				return 0
		else if (isobj(T))
			var/obj/O = T
			if(istype(O, /obj/machinery/computer/shuttle/embedded))
				boutput(usr, "<span class='alert'>You cannot seem to alter the energy off [O].</span>" )
				return 0
			// go to jail, do not pass src, do not collect pushed messages
			if (O.emag_act(null, null))
				boutput(usr, "<span class='notice'>You alter the energy of [O].</span>")
				return 0
			else
				boutput(usr, "<span class='alert'>You fail to alter the energy of the [O].</span>")
				return 1
		else
			boutput(usr, "<span class='alert'>There is nothing to decay here!</span>")
			return 1

/datum/targetable/wraithAbility/command
	name = "Command"
	icon_state = "command"
	desc = "Command a few objects to hurl themselves at the target location."
	targeted = 1
	target_anything = 1
	pointCost = 50
	cooldown = 200 // 20 seconds

	cast(atom/T)
		var/list/thrown = list()
		var/current_prob = 100
		if (ishuman(T))
			var/mob/living/carbon/H = T
			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(usr, "<span class='alert'>Some mysterious force protects [T] from your influence.</span>")
				return 1
			else
				H.setStatus("stunned", max(H.getStatusDuration("weakened"), max(H.getStatusDuration("stunned"), 3))) // change status "stunned" to max(stunned,weakened,3)
				// T:stunned = max(max(T:weakened, T:stunned), 3)
				H.delStatus("weakened")
				H.lying = 0
				H.show_message("<span class='alert'>A ghostly force compels you to be still on your feet.</span>")
		for (var/obj/O in view(7, holder.owner))
			if (!O.anchored && isturf(O.loc))
				if (prob(current_prob))
					current_prob *= 0.35 // very steep. probably grabs 3 or 4 objects per cast -- much less effective than revenant command
					thrown += O
					animate_float(O)
		SPAWN_DBG(1 SECOND)
			for (var/obj/O in thrown)
				O.throw_at(T, 32, 2)

		return 0

/datum/targetable/wraithAbility/raiseSkeleton
	name = "Raise Skeleton"
	icon_state = "skeleton"
	desc = "Raise a skeletonized dead body as an indurable skeletal servant."
	targeted = 1
	target_anything = 1
	pointCost = 150
	cooldown = 600 // 1 minute

	cast(atom/T)
		if (..())
			return 1

		//If you targeted a turf for some reason, find a corpse on it
		if (istype(T, /turf))
			for (var/mob/living/carbon/human/target in T.contents)
				if (isdead(target) && target:decomp_stage == 4)
					T = target
					break

		if (ishuman(T))
			var/mob/living/carbon/human/H = T
			if (!isdead(H) || H.decomp_stage != 4)
				boutput(usr, "<span class='alert'>That body refuses to submit its skeleton to your will.</span>")
				return 1
			var/personname = H.real_name
			var/obj/critter/wraithskeleton/S = new /obj/critter/wraithskeleton(get_turf(T))
			S.name = "[personname]'s skeleton"
			S.health = 1
			H.gib()
			return 0
		else
			boutput(usr, "<span class='alert'>There are no skeletonized corpses here to raise!</span>")
			return 1

/datum/targetable/wraithAbility/animateObject
	name = "Animate Object"
	icon_state = "animobject"
	desc = "Animate an inanimate object to attack nearby humans."
	targeted = 1
	target_anything = 1
	pointCost = 100
	cooldown = 300 //30 seconds

	cast(atom/T)
		if (..())
			return 1

		var/obj/O = T
		//If you targeted a turf for some reason, find an object on it
		if (istype(T, /turf))
			for (var/obj/target in T.contents)
				if (istype(target, /obj/critter) || istype(target, /obj/machinery/bot) || istype(target, /obj/decal) || target.anchored || target.invisibility)
					continue
				O = target
				break

		if (istype(O))
			if(istype(O, /obj/critter) || istype(O, /obj/machinery/bot) || istype(O, /obj/decal) || O.anchored || O.invisibility)
				boutput(usr, "<span class='alert'>That is not a valid target for animation!</span>")
				return 1
			O.visible_message("<span class='alert'>The [O] comes to life!</span>")
			var/obj/critter/livingobj/L = new/obj/critter/livingobj(O.loc)
			O.loc = L
			L.name = "Living [O.name]"
			L.desc = "[O.desc]. It appears to be alive!"
			L.overlays += O
			L.health = rand(10, 50)
			L.atk_brute_amt = rand(5, 20)
			L.defensive = 1
			L.aggressive = 1
			L.atkcarbon = 1
			L.atksilicon = 1
			L.opensdoors = OBJ_CRITTER_OPENS_DOORS_ANY
			L.stunprob = 15
			L.original_object = O
			animate_levitate(L, -1, 30)
			return 0
		else
			boutput(usr, "<span class='alert'>There is no object here to animate!</span>")
			return 1

/datum/targetable/wraithAbility/haunt
	name = "Haunt"
	icon_state = "haunt"
	desc = "Become corporeal for 30 seconds. During this time, you gain additional biopoints, depending on the amount of humans in your vicinity. You cannot use this ability while already corporeal."
	targeted = 0
	pointCost = 0
	cooldown = 600 //1 minute

	cast()
		if (..())
			return 1

		var/mob/wraith/W = src.holder.owner
		return W.haunt()

/datum/targetable/wraithAbility/spook
	name = "Spook"
	icon_state = "spook"
	desc = "Cause freaky, weird, creepy or spooky stuff to happen in an area around you. Use this ability to mark your current tile as the origin of these events, then activate it by using this ability again."
	targeted = 0
	pointCost = 0
	cooldown = 200
	special_screen_loc="NORTH,EAST-1"

	var/datum/radio_frequency/pda_connection
	var/obj/spookMarker/marker = new /obj/spookMarker()		//removed for now
	var/status = 0
	var/static/list/effects = list("Flip light switches" = 1, "Burn out lights" = 2, "Create smoke" = 3, "Create ectoplasm" = 4, "Sap APC" = 5, "Haunt PDAs" = 6, "Open doors, lockers, crates" = 7, "Random" = 8)
	var/list/effects_buttons = list()


	New()
		..()
		pda_connection = radio_controller.return_frequency("1149")
		object.contextLayout = new /datum/contextLayout/screen_HUD_default(2, 16, 16)//, -32, -32)
		if (!object.contextActions)
			object.contextActions = list()

		for(var/i=1, i<=8, i++)
			var/datum/contextAction/wraith_spook_button/newcontext = new /datum/contextAction/wraith_spook_button(i)
			object.contextActions += newcontext

	disposing()
		radio_controller.remove_object(src,"1149")
		..()

	proc/haunt_pda(var/obj/item/device/pda2/pda)
		if (!pda_connection)
			return
		var/message = pick("boo", "git spooked", "BOOM", "there's a skeleton inside of you", "DEHUMANIZE YOURSELF AND FACE TO BLOODSHED", "ICARUS HAS FOUND YOU!!!!! RUN WHILE YOU CAN!!!!!!!!!!!")

		var/datum/signal/signal = get_free_signal()
		signal.source = src.holder.owner
		signal.transmission_method = TRANSMISSION_RADIO
		signal.data["command"] = "text_message"
		signal.data["sender_name"] = holder.owner.name
		signal.data["message"] = "[message]" // (?)
		signal.data["sender"] = "00000000" // surely this isn't going to be a problem
		signal.data["address_1"] = pda.net_id

		pda_connection.post_signal(src, signal)

	cast()
		if (..())
			return 1

	proc/do_spook_ability(var/effect as text)
		if (effect == 8)
			effect = rand(1, 7)
		switch (effect)
			if (1)
				boutput(holder.owner, "<span class='notice'>You flip some light switches near the designated location!!</span>")
				for (var/obj/machinery/light_switch/L in range(10, holder.owner))
					L.attack_hand(holder.owner)
				return 0
			if (2)
				boutput(holder.owner, "<span class='notice'>You cause a few lights to burn out near the designated location!.</span>")
				var/c_prob = 100
				for (var/obj/machinery/light/L in range(10, holder.owner))
					if (L.status == 2 || L.status == 1)
						continue
					if (prob(c_prob))
						L.broken()
						c_prob *= 0.5
				return 0
			if (3)
				boutput(holder.owner, "<span class='notice'>Smoke rises in the designated location.</span>")
				var/turf/trgloc = get_turf(holder.owner)
				var/list/affected = block(locate(trgloc.x - 3,trgloc.y - 3,trgloc.z), locate(trgloc.x + 3,trgloc.y + 3,trgloc.z))
				if(!affected.len) return
				var/list/centerview = view(4, trgloc)
				for(var/atom/A in affected)
					if(!(A in centerview)) continue
					//if (A == holder.owner) continue
					var/obj/smokeDummy/D = new(A)
					SPAWN_DBG(15 SECONDS)
						qdel(D)
				particleMaster.SpawnSystem(new/datum/particleSystem/areaSmoke("#ffffff", 30, trgloc))
				return 0
			if (4)
				boutput(holder.owner, "<span class='notice'>Matter from your realm appears near the designated location!</span>")
				var/count = rand(5,9)
				var/turf/trgloc = get_turf(holder.owner)
				var/list/affected = block(locate(trgloc.x - 8,trgloc.y - 8,trgloc.z), locate(trgloc.x + 8,trgloc.y + 8,trgloc.z))
				for (var/i = 0, i < count, i++)
					new/obj/item/reagent_containers/food/snacks/ectoplasm(pick(affected))
				return 0
			if (5)
				var/sapped_amt = src.holder.regenRate * 100
				var/obj/machinery/power/apc/apc = locate() in get_area(holder.owner)
				if (!apc)
					boutput(holder.owner, "<span class='alert'>Power sap failed: local APC not found.</span>")
					return 0
				boutput(holder.owner, "<span class='notice'>You sap the power of the chamber's power source.</span>")
				var/obj/item/cell/cell = apc.cell
				if (cell)
					cell.use(sapped_amt)
				return 0
			if (6)
				boutput(holder.owner, "<span class='notice'>Mysterious messages haunt PDAs near the designated location!</span>")
				for (var/mob/living/L in range(10, holder.owner))
					var/obj/item/device/pda2/pda = locate() in L
					if (pda)
						src.haunt_pda(pda)
				for (var/obj/item/device/pda2/pda in range(10, holder.owner))
					src.haunt_pda(pda)
			if (7)
				boutput(holder.owner, "<span class='notice'>Crates, lockers and doors mysteriously open and close in the designated area!</span>")
				var/c_prob = 100
				for(var/obj/machinery/door/G in range(10, holder.owner))
					if (prob(c_prob))
						c_prob *= 0.4
						SPAWN_DBG(1 DECI SECOND)
							if (G.density)
								G.open()
							else
								G.close()
				c_prob = 100
				for(var/obj/storage/F in range(10, holder.owner))
					if (prob(c_prob))
						c_prob *= 0.4
						SPAWN_DBG(1 DECI SECOND)
							if (F.open)
								F.close()
							else
								F.open()

		return 0

/datum/targetable/wraithAbility/whisper
	name = "Whisper"
	icon_state = "whisper"
	desc = "Send an ethereal message to a living being."
	targeted = 1
	target_anything = 1
	pointCost = 1
	cooldown = 2 SECONDS

	proc/ghostify_message(var/message)
		return message

	cast(atom/target)
		if (..())
			return 1

		if (ishuman(target))
			var/mob/living/carbon/human/H = target
			if (isdead(H))
				boutput(usr, "<span class='alert'>They can hear you just fine without the use of your abilities.</span>")
				return 1
			else
				var/message = html_encode(input("What would you like to whisper to [target]?", "Whisper", "") as text)
				logTheThing("say", usr, target, "WRAITH WHISPER TO [constructTarget(target,"say")]: [message]")
				message = ghostify_message(trim(copytext(sanitize(message), 1, 255)))
				boutput(usr, "<b>You whisper to [target]:</b> [message]")
				boutput(target, "<b>A netherworldly voice whispers into your ears... </b> [message]")
		else
			boutput(usr, "<span class='alert'>It would be futile to attempt to force your voice to the consciousness of that.</span>")
			return 1

//this is the spooky_writing ability from spooktober ghosts
/datum/targetable/wraithAbility/blood_writing
	name = "Blood Writing"
	desc = "Write a spooky character on the ground."
	icon_state = "bloodwriting"
	targeted = 1
	target_anything = 1
	pointCost = 10
	cooldown = 5 SECONDS
	var/in_use = 0

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1

		var/turf/T = get_turf(target)
		if (isturf(T))
			write_on_turf(T, holder.owner, params)


	proc/write_on_turf(var/turf/T as turf, var/mob/user as mob, params)
		if (!T || !user || src.in_use)
			return
		src.in_use = 1
		var/list/c_default = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "Exclamation Point", "Question Mark", "Period", "Comma", "Colon", "Semicolon", "Ampersand", "Left Parenthesis", "Right Parenthesis",
		"Left Bracket", "Right Bracket", "Percent", "Plus", "Minus", "Times", "Divided", "Equals", "Less Than", "Greater Than")
		var/list/c_symbol = list("Dollar", "Euro", "Arrow North", "Arrow East", "Arrow South", "Arrow West",
		"Square", "Circle", "Triangle", "Heart", "Star", "Smile", "Frown", "Neutral Face", "Bee", "Pentagram")

		var/t = input(user, "What do you want to write?", null, null) as null|anything in (c_default + c_symbol)

		if (!t)
			src.in_use = 0
			return 1
		var/obj/decal/cleanable/writing/spooky/G = make_cleanable(/obj/decal/cleanable/writing/spooky,T)
		G.artist = user.key

		logTheThing("station", user, null, "writes on [T] with [src] [log_loc(T)]: [t]")
		G.icon_state = t
		G.words = t
		if (islist(params) && params["icon-y"] && params["icon-x"])
			// playsound(src.loc, "sound/impact_sounds/Slimy_Splat_1.ogg", 50, 1)

			G.pixel_x = text2num(params["icon-x"]) - 16
			G.pixel_y = text2num(params["icon-y"]) - 16
		else
			G.pixel_x = rand(-4,4)
			G.pixel_y = rand(-4,4)
		src.in_use = 0

//this is the spooky_writing ability from spooktober ghosts
/datum/targetable/wraithAbility/make_poltergeist
	name = "Make Poltergeist"
	desc = "Attempt to breach the veil between worlds to allow a lesser spirit to enter this realm."
	icon_state = "make_poltergeist"
	targeted = 0
	pointCost = 600
	cooldown = 5 MINUTES
	var/in_use = 0
	var/ghost_confirmation_delay  = 30 SECONDS

	// cast(turf/target, params)
	cast(atom/target, params)
		if (..())
			return 1

		var/turf/T = get_turf(holder.owner)
		if (isturf(T) && !istype(T, /turf/space))
			boutput(holder.owner, "You begin to channel power to call a spirit to this realm, you won't be able to cast any other spells for the next 30 seconds!")
			make_poltergeist(holder.owner, T)
		else
			boutput(holder.owner, "<span class='alert'>You can't cast this spell on your current tile!</span>")
			return 1

	proc/make_poltergeist(var/mob/wraith/W, var/turf/T, var/tries = 0)
		if (!istype(W))
			boutput(W, "something went terribly wrong, call 1-800-CODER")
			return
		var/obj/spookMarker/marker = new /obj/spookMarker(T)
		var/list/text_messages = list()
		text_messages.Add("Would you like to respawn as a poltergeist? Your name will be added to the list of eligible candidates and set to DNR if selected.")
		text_messages.Add("You are eligible to be respawned as a poltergeist. You have [src.ghost_confirmation_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. The game will pick a player soon. Good luck!")

		// The proc takes care of all the necessary work (job-banned etc checks, confirmation delay).
		message_admins("Sending poltergeist offer to eligible ghosts. They have [src.ghost_confirmation_delay / 10] seconds to respond.")
		var/list/datum/mind/candidates = dead_player_list(1, src.ghost_confirmation_delay, text_messages)
		if (!islist(candidates) || candidates.len <= 0)
			message_admins("Couldn't set up poltergeist ; no ghosts responded. Source: [src.holder]")
			logTheThing("admin", null, null, "Couldn't set up poltergeist ; no ghosts responded. Source: [src.holder]")
			if (tries >= 1)
				boutput(W, "No spirits responded. The portal closes.")
				qdel(marker)
				return
			else
				boutput(W, "Couldn't set up poltergeist ; no spirits responded. Trying again in 3 minutes.")
				qdel(marker)
				SPAWN_DBG(3 MINUTES)
					make_poltergeist(W, T, tries++)
			return
		var/datum/mind/lucky_dude = pick(candidates)

		var/mob/wraith/poltergeist/P = new /mob/wraith/poltergeist(T, W, marker)
		lucky_dude.special_role = "poltergeist"
		lucky_dude.dnr = 1
		lucky_dude.transfer_to(P)
		//P.ckey = lucky_dude.ckey
		P.antagonist_overlay_refresh(1, 0)
		message_admins("[lucky_dude.key] respawned as a poltergeist for [src.holder.owner].")
		logTheThing("admin", lucky_dude.current, null, "respawned as a poltergeist for [src.holder.owner].")

		boutput(P, "<span class='notice'><b>You have been respawned as a poltergeist!</b></span>")
		boutput(P, "[W] is your master! Spread mischeif and do their bidding!")
		boutput(P, "Don't venture too far from your portal or your master!")


/obj/spookMarker
	name = "Spooky Marker"
	desc = "What is this? You feel like you shouldn't be able to see it, but it has an ominous and slightly mischevious aura."
	icon = 'icons/effects/wraitheffects.dmi'
	icon_state = "acursed"
	// invisibility = 101
	invisibility = 10
	anchored = 1
	density = 0
	opacity = 0
	mouse_opacity = 0
	alpha = 100

	New()
		..()
		var/matrix/M = matrix()
		M.Scale(0.75,0.75)
		animate(src, transform = M, time = 3 SECONDS, loop = -1,easing = ELASTIC_EASING)

