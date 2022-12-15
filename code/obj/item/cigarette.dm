
/* ==================================================== */
/* -------------------- Cigarettes -------------------- */
/* ==================================================== */

/obj/item/clothing/mask/cigarette
	name = "cigarette"
	icon = 'icons/obj/items/cigarettes.dmi'
	wear_image_icon = 'icons/mob/clothing/mask.dmi'
	icon_state = "cig"
	uses_multiple_icon_states = 1
	item_state = "cig"
	force = 0
	hit_type = DAMAGE_BLUNT
	throw_speed = 0.5
	c_flags = EQUIPPED_WHILE_HELD
	w_class = W_CLASS_TINY
	var/on = 0
	var/exploding = 0 //Does it blow up when it goes out?
	var/flavor = null
	var/nic_free = 0
	var/puff_ready = 0
	var/litstate = "ciglit"
	var/buttstate = "cigbutt"
	var/buttdesc = "cigarette butt"
	var/buttname = "cigarette butt"
	var/puffrate = 1
	var/cycle = 4
	var/numpuffs = 20 //number of times the cig can dispense reagents
	rand_pos = 1
	use_bloodoverlay = 0

	setupProperties()
		..()
		setProperty("coldprot", 0)
		setProperty("heatprot", 0)
		setProperty("meleeprot", 0)

	New()
		..()
		src.create_reagents(60)
		AddComponent(/datum/component/loctargeting/simple_light, 255, 110, 135, 90, src.on)

		if (src.on) //if we spawned lit, do something about it!
			src.on = 0
			src.firesource = FALSE
			src.light()

		if (src.exploding)
			if (src.flavor)
				reagents.add_reagent(src.flavor, 5)
			reagents.add_reagent("nicotine", 5)
			numpuffs = 5 //trickcigs burn out faster
			return
		else if (!src.nic_free)
			reagents.add_reagent("nicotine", 40)
			if (src.flavor)
				reagents.add_reagent(src.flavor, 20)
				return
		else if (src.flavor)
			reagents.add_reagent(src.flavor, 40)
			return
		START_TRACKING_CAT(TR_CAT_CANNABIS_OBJ_ITEMS)

	disposing()
		STOP_TRACKING_CAT(TR_CAT_CANNABIS_OBJ_ITEMS)
		. = ..()

	afterattack(atom/target , mob/user, flag) // copied from the propuffs
		if (istype(target, /obj/item/reagent_containers/food/snacks/)) // you dont crush cigs INTO food, you crush them ONTO food!
			var/obj/item/reagent_containers/food/snacks/T = target // typecasting because atom/target was causing some STINKY problems
			user.visible_message("<span class='notice'><b>[user]</b> crushes up [src] and sprinkles it onto [target], gross.</span>",\
			"<span class='notice'>You crush up [src] and sprinkle it onto [target].</span>")
			if (!(T.has_cigs))
				T.desc = "[T.desc]<br>Are those crushed cigarettes on top? That's disgusting!"
				T.has_cigs = 1
			if (src.reagents) // copied wirefix
				src.reagents.trans_to(T, 5)
			qdel (src)
			return
		else if (istype(target, /obj/item/reagent_containers/)) // crushing cigs into actual containers remains the same
			user.visible_message("<span class='notice'><b>[user]</b> crushes up [src] into [target].</span>",\
			"<span class='notice'>You crush up [src] into [target].</span>")
			if (src.reagents) // copied wirefix
				src.reagents.trans_to(target, 5)
			qdel (src)
			return
		else if (istype(target, /obj/item/match) && src.on)
			target:light(user, "<span class='alert'><b>[user]</b> lights [target] with [src].</span>")
		else if (src.on == 0 && isitem(target) && target:burning)
			src.light(user, "<span class='alert'><b>[user]</b> lights [src] with [target]. Goddamn.</span>")
			return
		else
			return ..()

	attack_self(mob/user)
		if (user.find_in_hand(src) && src.on > 0)
			src.put_out(user, "<b>[user]</b> calmly drops and treads on the lit [src.name], putting it out instantly.")
			user.u_equip(src)
			src.set_loc(user.loc)
			return
		else
			return ..()

	proc/light(var/mob/user as mob, var/message as text)
		if (src.on == 0)
			src.on = 1
			src.firesource = FIRESOURCE_OPEN_FLAME
			src.hit_type = DAMAGE_BURN
			src.force = 3
			src.icon_state = litstate
			src.item_state = litstate
			if (user && message)
				user.visible_message(message, group = "cig_light") //user check to fix a shitton of runtime errors with the temp expose ignition method. welp. -cogwerks
			if (ismob(src.loc))
				var/mob/M = src.loc
				M.set_clothing_icon_dirty()
			if(src?.reagents)
				puffrate = src.reagents.total_volume / numpuffs //default 20 active cycles (100 total, about 5 minutes)
			processing_items |= src

			hit_type = DAMAGE_BURN

			SEND_SIGNAL(src, COMSIG_LIGHT_ENABLE)

	proc/put_out(var/mob/user as mob, var/message as text)
		if (src.on == 1)
			src.on = -1
			src.firesource = FALSE
			src.hit_type = DAMAGE_BLUNT
			src.force = 0
			src.icon_state = buttstate
			src.item_state = buttstate
			src.name = buttname
			src.desc = buttdesc
			if (user && message)
				user.visible_message(message, group = "cig_drop")
			if (ismob(src.loc))
				var/mob/M = src.loc
				M.set_clothing_icon_dirty()
			processing_items.Remove(src)

			hit_type = DAMAGE_BLUNT

			SEND_SIGNAL(src, COMSIG_LIGHT_DISABLE)

			playsound(src, 'sound/impact_sounds/burn_sizzle.ogg', 50, 1)

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if (src.on == 0)
			if (temperature > T0C+200)
				src.visible_message("<span class='alert'>The [src] ignites!</span>", group = "cig_ignite")
				src.light()

	ex_act(severity)
		. = ..()
		if (src.on == 0)
			src.visible_message("<span class='alert'>The [src] ignites!</span>", group = "cig_ignite")
			src.light()

	attackby(obj/item/W, mob/user)
		if (src.on == 0)
			if (isweldingtool(W) && W:try_weld(user,0,-1,0,0))
				src.light(user, "<span class='alert'><b>[user]</b> casually lights [src] with [W], what a badass.</span>")
				return
			else if (istype(W, /obj/item/sword) && W:active)
				src.light(user, "<span class='alert'><b>[user]</b> swishes [W] alarmingly close to [his_or_her(user)] face and lights [src] ablaze.</span>")
				return
			else if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
				src.light(user, "<span class='alert'>Did [user] just light [his_or_her(user)] [src.name] with [W]? Holy Shit.</span>")
				return
			else if (istype(W, /obj/item/device/igniter))
				src.light(user, "<span class='alert'><b>[user]</b> fumbles around with [W]; a small flame erupts from [src].</span>")
				return
			else if (istype(W, /obj/item/device/light/zippo) && W:on)
				src.light(user, "<span class='alert'>With a single flick of their wrist, [user] smoothly lights [src] with [W]. Damn they're cool.</span>")
				return
			else if ((istype(W, /obj/item/match) || istype(W, /obj/item/clothing/mask/cigarette) || istype(W, /obj/item/device/light/candle)) && W:on)
				src.light(user, "<span class='alert'><b>[user]</b> lights [src] with [W].</span>")
				return
			else if (W.burning)
				src.light(user, "<span class='alert'><b>[user]</b> lights [src] with [W]. Goddamn.</span>")
				return
			else if (W.firesource)
				src.light(user, "<span class='alert'><b>[user]</b> lights [src] with [W].</span>")
				W.firesource_interact()
				return
			else
				return ..()
		else
			return ..() // CALL your GODDAMN PARENTS

	attack(atom/target, mob/user)
		if (isliving(target))
			var/mob/living/M = target

			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if (H.bleeding || (H.butt_op_stage == 4 && user.zone_sel.selecting == "chest"))
					if (src.cautery_surgery(H, user, 5, src.on))
						return
			if (M.getStatusDuration("burning") && src.on == 0)
				if (M == user)
					src.light(user, "<span class='alert'><b>[user]</b> lights [his_or_her(user)] [src.name] with [his_or_her(user)] OWN flaming body. That's dedication! Or crippling addiction.</span>")
				else
					src.light(user, "<span class='alert'><b>[user]</b> lights [his_or_her(user)] [src.name] with [M]'s flaming body. That's cold, man. That's real cold.</span>")
				return
			else if (istype(M, /mob/living/critter/fire_elemental))
				if (M == user)
					src.light(user, "<span class='alert'><b>[user]</b> lights [his_or_her(user)] [src.name] with [his_or_her(user)] OWN flaming body.")
				else
					src.light(user, "<span class='alert'><b>[user]</b> lights [src] with [M]. Good thinking!</span>")
			else if (src.on == 1)
				src.put_out(user, "<span class='alert'><b>[user]</b> puts [src] out on [target].</span>")
				if (ishuman(target))
					var/mob/living/carbon/human/chump = target
					if (!chump.stat)
						chump.emote("scream")
				if (src.exploding)
					trick_explode()
				return
			else
				return ..(target, user)

	attack_hand(mob/user)
		if (!user) return
		var/can_blow_smoke = (user.wear_mask == src && src.on && src.reagents.total_volume > 0 && src.puff_ready)
		var/success = ( ..() )
		if (!(can_blow_smoke && success) || ON_COOLDOWN(src, "wtf_cig_sanity_check", 0.5 SECONDS)) return
		particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(user.loc, user.dir))

		//var/datum/reagents/smokeContents = new/datum/reagents/(src.reagents.maximum_volume)
		//src.reagents.copy_to(smokeContents)
		//src.reagents.remove_any(smokeContents.total_volume - (smokeContents.maximum_volume / 50))
		//smokeContents.remove_any(smokeContents.total_volume - (smokeContents.maximum_volume / 50))
		//smoke_reaction(smokeContents, 1, get_step(user,user.dir), do_sfx = 0)

		var/mob/living/target
		var/check_loc = get_step(user, user.dir)
		for (var/mob/living/M in check_loc)
			target = M
			break

		if (target)
			var/message_append = ""
			if (prob(60))
				switch(rand(1, 9))
					if (1) message_append = " Ouch!"
					if (2) message_append = " Are they just going to take that?"
					if (3) message_append = " Whoa!"
					if (4) message_append = " What a jerk!"
					if (5) message_append = " That's bad-ass."
					if (6) message_append = " That looks pretty cool!"
					if (7) message_append = " That's cold."
					if (8) message_append = " How rude."
					if (9) message_append = " Wow!"
			user.visible_message("<span class='alert'><B>[user]</B> blows smoke right into <B>[target]</B>'s face![message_append]</span>", group = "[user]_blow_smoke_at_[target]")

			var/mob/living/carbon/human/human_target = target
			if (human_target && rand(1,5) == 1)
				SPAWN(0) target.emote("cough")
		else
			var/message
			switch(rand(1, 10))
				if (1) message = "<B>[user]</B> takes a drag and blows a cloud of smoke!"
				if (2) message = "<B>[user]</B> puffs out a smoke cloud!"
				if (3) message = "<B>[user]</B> exhales a huge cloud of smoke!"
				if (4) message = "<B>[user]</B> puffs on [his_or_her(user)] [src.name]."
				if (5) message = "<B>[user]</B> blows out a smoke cloud!"
				if (6) message = "<B>[user]</B> exhales some smoke from [his_or_her(user)] nose!"
				if (7) message = "<B>[user]</B> blows some smoke rings!"
				if (8) message = "<B>[user]</B> takes a drag of [his_or_her(user)] [src.name]."
				if (9) message = "<B>[user]</B> pulls on [his_or_her(user)] [src.name]."
				if (10) message = "<B>[user]</B> blows out some smoke in the shape of a [pick("butt","bee","shelterfrog","heart","burger","gun","cube","face","dog","star")]!"
			user.visible_message("<span class='alert'>[message]</span>", group = "blow_smoke")
		src.cycle = 0 //do the transfer on the next cycle. Also means we get the lung damage etc rolls

		src.puff_ready = 0

	process()
		var/turf/location = src.loc
		var/mob/M = null

		puff_ready = 1
		if(cycle-- <= 0 || src.exploding)
			cycle = 4  //every fifth cycle.
			if (ismob(location))
				M = location
				if(ishuman(M))
					var/mob/living/carbon/human/H = M //below//don't smoke unless it's worn or in hand.
					if(H.traitHolder && H.traitHolder.hasTrait("smoker") || !((src in H.get_equipped_items()) || ((H.l_store==src||H.r_store==src) && !(H.wear_mask && (H.wear_mask.c_flags & BLOCKSMOKE || (H.wear_mask.c_flags & MASKINTERNALS && H.internal))))))
						src.reagents.remove_any(puffrate)
					else
						if(H.bodytemperature < H.base_body_temp)
							H.bodytemperature += 1
						if (prob(1))
							H.contract_disease(/datum/ailment/malady/heartdisease,null,null,1)
						src.reagents.trans_to(M, puffrate)
						src.reagents.reaction(M, INGEST, puffrate)
						//lung damage
						if (prob(40))
							if (prob(70))
								if (!H.organHolder.left_lung.robotic)
									H.organHolder.damage_organ(0, 0, 1, "left_lung")
							else
								if (!H.organHolder.right_lung.robotic)
									H.organHolder.damage_organ(0, 0, 1, "right_lung")
				else
					src.reagents.trans_to(M, puffrate)
					src.reagents.reaction(M, INGEST, puffrate)
			else if (src?.reagents) //ZeWaka: Copied Wire's fix for null.remove_any() below
				src.reagents.remove_any(puffrate)

		if (!src.reagents || src.reagents.total_volume <= 0) //ZeWaka: fix for null.total_volume (syndie cigs)
			if (src.exploding)
				src.on = 0 //Let's not keep looping while we're busy blowing up, ok?
				processing_items.Remove(src)
				SPAWN((20)+(rand(1,10)))
					trick_explode()
				return
			else
				src.put_out(M, "<span class='alert'><b>[M]</b>'s [src.name] goes out.</span>")
				return

		//if (istype(location, /turf)) //start a fire if possible
		//	location.hotspot_expose(700, 5) // this doesn't seem to ever actually happen, gonna try a different setup - cogwerks
		var/turf/T = get_turf(src.loc)
		if (T)
			T.hotspot_expose(650,5)


	dropped(mob/user as mob)
		if (!isturf(src.loc))
			return
		if (src.on == 1 && !src.exploding && src.reagents.total_volume <= 20)
			src.put_out(user, "<span class='alert'><b>[user]</b> calmly drops and treads on the lit [src.name], putting it out instantly.</span>")
			return ..()
		else
			user.visible_message("<span class='alert'><b>[user]</b> drops [src]. Guess they've had enough for the day.</span>", group = "cig_drop")
			return ..()


	proc/trick_explode()
		var/turf/tlocation = get_turf(src.loc)
		if (tlocation)
			explosion(src, tlocation, 0, 1, 1, 2)
		else
			elecflash(src,power = 2)
			playsound(src.loc, 'sound/effects/Explosion1.ogg', 75, 1)
		src.visible_message("<span class='alert'>The [src] explodes!</span>")

		// Added (Convair880).
		if (ismob(src.loc))
			logTheThing(LOG_BOMBING, null, "A trick cigarette (held/equipped by [constructTarget(src.loc,"bombing")]) explodes at [log_loc(src)].")
		else
			logTheThing(LOG_BOMBING, src.fingerprintslast, "A trick cigarette explodes at [log_loc(src)]. Last touched by [src.fingerprintslast ? "[src.fingerprintslast]" : "*null*"].")

		if (istype(src.loc,/obj/item/device/pda2))
			var/obj/item/device/pda2/pda = src.loc
			if (pda.ID_card) //let's not destroy IDs
				pda.ID_card.set_loc(tlocation)
			qdel(pda)//Destroy PDA if in one
		qdel(src)


/obj/item/clothing/mask/cigarette/nicofree
	name = "nicotine-free cigarette"
	desc = "Smoking without the crippling addiction and lung cancer! Warning: side effects may include loss of breath and inability to relax."
	nic_free = 1
	flavor = "capsaicin"

/obj/item/clothing/mask/cigarette/menthol
	name = "menthol cigarette"
	desc = "Blow everyone away with your minty fresh breath!"
	flavor = "menthol"

/obj/item/clothing/mask/cigarette/dryjoint
	name = "dried up joint"
	desc = "An ancient joint, it's paper now resembles the burial shroud of an egyptian king. There's no telling what the roller could have twisted up in here."
	nic_free = 1
	flavor = "THC"

/obj/item/clothing/mask/cigarette/random
	name = "laced cigarette"
	desc = "A cigarette which seems to have been laced with something."

	New()
		if (all_functional_reagent_ids.len > 0)
			var/list/chem_choices = all_functional_reagent_ids
			src.flavor = pick(chem_choices)
		else
			src.flavor = "nicotine"
		..()

/obj/item/clothing/mask/cigarette/cigar
	name = "cigar"
	icon_state = "cigar"
	item_state = "cigar"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	litstate = "cigarlit"
	buttstate = "cigarbutt"
	buttdesc = "cigar butt"
	buttname = "cigar butt"

/obj/item/clothing/mask/cigarette/cigar/gold
	name = "golden cigar"
	icon_state = "goldcigar"
	item_state = "goldcigar"
	litstate = "goldcigarlit"
	buttstate = "goldcigarbutt"
	buttdesc = "golden cigar butt"
	buttname = "golden cigar butt"

//not a cigarette as it is not smokable on its own. comes pre-flavoured though.
/obj/item/bluntwrap
	name = "blunt wrap"
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "bluntwrap"
	force = 0
	hit_type = DAMAGE_BLUNT
	throw_speed = 0.5
	w_class = W_CLASS_TINY
	rand_pos = 1
	var/flavor = null

	New()
		..()
		src.create_reagents(30)

		if(!flavor)
			src.flavor = pick("rum","menthol","chocolate","coffee","juice_lemon","juice_orange","juice_lime","juice_peach","bourbon","vermouth","yuck","mucus")
		src.name = "[reagent_id_to_name(src.flavor)]-flavoured blunt wrap"
		reagents.add_reagent(src.flavor, 20)


/obj/item/clothing/mask/cigarette/cigarillo
	name = "cigarillo"
	icon_state = "cigarillo"
	item_state = "cigarillo"  //TODO: no inhands
	litstate = "cigarillolit"
	buttstate = "cigarillobutt"
	buttdesc = "Tarry, smelly."
	buttname = "cigarillo roach"

	attackby(obj/item/W, mob/user)
		if((W.tool_flags & TOOL_CUTTING) || (W.hit_type & DAMAGE_CUT) || (W.hit_type & DAMAGE_STAB))
			var/obj/item/bluntwrap/B = new(user.loc)
			if(src.flavor)
				B.reagents.remove_any(20)
				B.flavor = src.flavor
				B.name = "[reagent_id_to_name(src.flavor)]-flavoured blunt wrap"
			src.reagents.trans_to(B, 20)
			boutput(user, "<span class='alert'>You cut [src] open to make a blunt wrapper.</span>")
			qdel(src)
			user.put_in_hand_or_drop(B)

		else
			..()



/obj/item/clothing/mask/cigarette/cigarillo/flavoured

	New()
		src.flavor = pick("rum","menthol","chocolate","coffee","juice_lemon","juice_orange","juice_lime","juice_peach","bourbon","vermouth")
		src.name = "[reagent_id_to_name(src.flavor)]-flavoured cigarillo"
		..()

/obj/item/clothing/mask/cigarette/cigarillo/juicer // like a propuff, but laced again.
	name = "Juicer Schweet's Rowdy 'Rillo"
	desc = "A cigarillo which seems to have been laced with everything."
	buttdesc = "Ain't half the 'Rillo it used to be."

	New()
		src.flavor = pick("CBD","CBD","CBD","CBD","THC","THC","THC","THC","silicate","antihol","mutadone","rum","mutagen","toxin","water_holy","fuel","salbutamol","haloperidol",
		"cryoxadone","cryostylane","omnizine","jenkem","vomit","carpet","charcoal","blood","cheese","bilk","atropine",
		"lexorin","teporone","mannitol","spaceacillin","saltpetre","anti_rad","insulin","gvomit","milk","colors","diluted_fliptonium",
		"something","honey_tea","tea","coffee","chocolate","guacamole","juice_pickle","vanilla","enriched_msg","egg","aranesp",
		"paper","bread","green_goop","black_goop", "mint_tea", "juice_peach", "ageinium")
		..()
		if (src?.reagents) //Warc: copied ZeWaka's copy of Wire's fix for null.remove_any() way above
			src.reagents.remove_any(15)
			src.reagents.add_reagent(pick("CBD","mucus","ethanol","glitter","methamphetamine","uranium","pepperoni","poo","quebon","jenkem","cryoxadone","kerosene","cryostylane","ectoplasm","gravy","cheese","paper","carpet","ants","enriched_msg","THC","THC","THC","bee","coffee","fuel","salbutamol","milk","grog"),5)
			src.reagents.add_reagent(pick("CBD","mucus","ethanol","glitter","methamphetamine","uranium","pepperoni","poo","quebon","jenkem","cryoxadone","kerosene","cryostylane","ectoplasm","gravy","cheese","paper","carpet","ants","enriched_msg","THC","THC","THC","bee","coffee","fuel","salbutamol","milk","grog"),5)
			if(prob(5))
				src.reagents.add_reagent("triplemeth",5)


/obj/item/clothing/mask/cigarette/cigarillo/juicer/exploding // Wow! What an example!
	buttdesc = "Ain't twice the 'Rillo it used to be."
	exploding = 1


/obj/item/clothing/mask/cigarette/propuffs
	desc = "Pro Puffs - a new taste thrill in every cigarette."

	New()
		src.flavor = pick("silicate","antihol","mutadone","rum","mutagen","toxin","water_holy","fuel","salbutamol","haloperidol",
		"cryoxadone","cryostylane","omnizine","jenkem","vomit","carpet","charcoal","blood","cheese","bilk","atropine",
		"lexorin","teporone","mannitol","spaceacillin","saltpetre","anti_rad","insulin","gvomit","milk","colors","diluted_fliptonium",
		"something","honey_tea","tea","coffee","chocolate","guacamole","juice_pickle","vanilla","enriched_msg","egg","aranesp",
		"paper","bread","green_goop","black_goop", "mint_tea", "juice_peach", "ageinium", "synaptizine", "plasma", "morphine","oculine","CBD")
		src.name = "[reagent_id_to_name(src.flavor)]-laced cigarette"
		..()

/obj/item/clothing/mask/cigarette/syndicate
	//desc = "It looks a little funny." //fucka you
	exploding = 1

// this was in the middle of plants_food_etc.dm
// WHY
/obj/item/clothing/mask/cigarette/custom
	desc = "There could be anything in this."
	flags = FPRINT|TABLEPASS|OPENCONTAINER

	New()
		..()
		src.reagents.maximum_volume = 600
		src.reagents.clear_reagents()

	is_open_container()
		return 1

/* ================================================= */
/* -------------------- Packets -------------------- */
/* ================================================= */

/obj/item/cigpacket
	name = "cigarette packet"
	desc = "The most popular brand of Space Cigarettes, sponsors of the Space Olympics."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "cigpacket"
	uses_multiple_icon_states = 1
	item_state = "cigpacket"
	w_class = W_CLASS_TINY
	throwforce = 2
	var/max_cigs = 6
	var/cigtype = /obj/item/clothing/mask/cigarette
	var/package_style = "cigpacket"
	flags = TABLEPASS | FPRINT
	c_flags = ONBELT
	stamina_damage = 3
	stamina_cost = 3
	rand_pos = 1

	New()
		..()
		for(var/i in 1 to src.max_cigs)
			new src.cigtype(src)


/obj/item/cigpacket/nicofree
	name = "nicotine-free cigarette packet"
	desc = "All the perks of smoking without the addiction! Warning: Cigarettes use chemical compounds which may cause severe throat irritation."
	cigtype = /obj/item/clothing/mask/cigarette/nicofree
	icon_state = "cigpacket-b"
	package_style = "cigpacket-b"

/obj/item/cigpacket/menthol
	name = "menthol cigarette packet"
	desc = "Bad breath begone! Warning: Cigarettes use chemical compounds which may increase nicotine dependency."
	cigtype = /obj/item/clothing/mask/cigarette/menthol
	icon_state = "cigpacket-l"
	package_style = "cigpacket-l"

/obj/item/cigpacket/propuffs
	name = "packet of Pro Puffs"
	desc = "A flavor surprise in each cigarette, lovingly wrapped in the finest papers."
	cigtype = /obj/item/clothing/mask/cigarette/propuffs
	icon_state = "cigpacket-r"
	package_style = "cigpacket-r"

/obj/item/cigpacket/random
	name = "odd cigarette packet"
	desc = "These don't seem to have a brand name on them."
	cigtype = /obj/item/clothing/mask/cigarette/random
	icon_state = "cigpacket-p"
	package_style = "cigpacket-p"

/obj/item/cigpacket/syndicate // cogwerks: made them more sneaky, removed the glaringly obvious name
// haine: these can just inherit the parent name and description vOv
	cigtype = /obj/item/clothing/mask/cigarette/syndicate

/obj/item/cigpacket/update_icon()
	src.overlays = null
	if (length(src.contents) == 0)
		src.icon_state = "[src.package_style]0"
		src.desc = "There aren't any cigs left, shit!"
	else
		src.icon_state = "[src.package_style]o"
		src.overlays += "cig[length(src.contents)]"
	return

/obj/item/cigpacket/attack_hand(mob/user)
	if (user.find_in_hand(src))//r_hand == src || user.l_hand == src)
		if (length(src.contents) == 0)
			user.show_text("You're out of cigs, shit! How you gonna get through the rest of the day?", "red")
			return
		else
			var/obj/item/clothing/mask/cigarette/W = src.contents[1]
			user.put_in_hand_or_drop(W)
		src.UpdateIcon()
	else
		return ..()
	return

//Basically the same as above. This is useful so you can get cigs from packs when you only have one arm
/obj/item/cigpacket/attack_self(var/mob/user as mob)
	if (length(src.contents) == 0)
		user.show_text("You're out of cigs, dang! How are you gonna get through the rest of the day?", "red")
		return
	else
		var/obj/item/clothing/mask/cigarette/W = src.contents[1]

		if (user.put_in_hand(W))
			user.show_text("You stylishly knock a cig out of [src] into your other hand.", "blue")
		else
			W.set_loc(get_turf(user))
			user.show_text("You knock a cig out of [src], flopping it to the ground.", "red")

	src.UpdateIcon()

/obj/item/cigpacket/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/clothing/mask/cigarette))
		var/obj/item/clothing/mask/cigarette/cig = W
		if (cig.on)
			user.show_text("You can't put a lit cig back in the packet, are you crazy?", "red")
			return
		if (length(src.contents) < src.max_cigs)
			src.contents += cig
			user.u_equip(cig)
			cig.set_loc(src)
			src.UpdateIcon()
			return
		else
			user.show_text("The packet is just too full to fit any more cigs.", "red")
			return
	else
		return ..()

/obj/item/cigbutt
	name = "cigarette butt"
	desc = "A manky old cigarette butt."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "cigbutt"
	w_class = W_CLASS_TINY
	throwforce = 1
	stamina_damage = 0
	stamina_cost = 0
	rand_pos = 1

/obj/item/cigarbox
	name = "cigar box"
	desc = "The not-so-prestigeous brand of Space Cigars."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "cigarbox"
	uses_multiple_icon_states = 1
	item_state = "cigarbox"
	w_class = W_CLASS_TINY
	throwforce = 2
	var/cigcount = 5
	var/cigtype = /obj/item/clothing/mask/cigarette/cigar
	var/package_style = "cigarbox"
	flags = TABLEPASS | FPRINT
	c_flags = ONBELT
	stamina_damage = 3
	stamina_cost = 3
	rand_pos = 1

/obj/item/cigarbox/New()
	..()
	src.UpdateIcon()

/obj/item/cigarbox/update_icon()
	src.overlays = null
	if (src.cigcount <= 0)
		src.icon_state = "[src.package_style]"
		src.desc = "There aren't any cigars left, shit!"
	else
		src.icon_state = "[src.package_style]o"
		src.overlays += "cigar[src.cigcount]"
	return

/obj/item/cigarbox/attack_hand(mob/user)
	if (user.find_in_hand(src))//r_hand == src || user.l_hand == src)
		if (src.cigcount == 0)
			user.show_text("You're out of cigars! How you gonna get through the rest of the day?", "red")
			return
		else
			var/obj/item/clothing/mask/cigarette/cigar/W = new src.cigtype(user)
			user.put_in_hand_or_drop(W)
			if (src.cigcount != -1)
				src.cigcount--
		src.UpdateIcon()
	else
		return ..()
	return

/obj/item/cigarbox/attack_self(var/mob/user as mob)
	if (src.cigcount == 0)
		user.show_text("You're out of cigars, dang! How are you gonna get through the rest of the day?", "red")
		return
	else
		var/obj/item/clothing/mask/cigarette/cigar/W = new src.cigtype(user)

		if (src.cigcount != -1)
			src.cigcount--

		if (user.put_in_hand(W))
			user.show_text("You stylishly take a cigar out of [src] into your other hand.", "blue")
		else
			W.set_loc(get_turf(user))
			user.show_text("You knock a cigar out of [src], flopping it to the ground.", "red")

	src.UpdateIcon()

/obj/item/cigarbox/gold
	name = "deluxe golden cigar box"
	desc = "The most prestigeous brand of Space Cigars, made in Space Cuba."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "cigarbox"
	uses_multiple_icon_states = 1
	item_state = "cigarbox"
	w_class = W_CLASS_TINY
	throwforce = 2
	cigcount = 5
	cigtype = /obj/item/clothing/mask/cigarette/cigar/gold
	package_style = "cigarbox"
	flags = TABLEPASS | FPRINT
	c_flags = ONBELT
	stamina_damage = 3
	stamina_cost = 3
	rand_pos = 1

/obj/item/cigarbox/gold/update_icon()

	src.overlays = null
	if (src.cigcount <= 0)
		src.icon_state = "[src.package_style]"
		src.desc = "There aren't any cigars left, shit!"
	else
		src.icon_state = "[src.package_style]o"
		src.overlays += "goldcigar[src.cigcount]"
	return

/obj/item/cigarbox/gold/attack_hand(mob/user)
	if (user.find_in_hand(src))//r_hand == src || user.l_hand == src)
		if (src.cigcount == 0)
			user.show_text("You're out of cigars! How you gonna get through the rest of the day?", "red")
			return
		else
			var/obj/item/clothing/mask/cigarette/cigar/gold/W = new src.cigtype(user)
			user.put_in_hand_or_drop(W)
			if (src.cigcount != -1)
				src.cigcount--
		src.UpdateIcon()
	else
		return ..()
	return


/obj/item/cigarbox/gold/attack_self(var/mob/user as mob)
	if (src.cigcount == 0)
		user.show_text("You're out of cigars, dang! How are you gonna get through the rest of the day?", "red")
		return
	else
		var/obj/item/clothing/mask/cigarette/cigar/gold/W = new src.cigtype(user)

		if (src.cigcount != -1)
			src.cigcount--

		if (user.put_in_hand(W))
			user.show_text("You stylishly take a cigar out of [src] into your other hand.", "blue")
		else
			W.set_loc(get_turf(user))
			user.show_text("You knock a cigar out of [src], flopping it to the ground.", "red")

	src.UpdateIcon()

// breh

/obj/item/cigpacket/cigarillo
	max_cigs = 2
	name = "Discount Dan's Last-Ditch Doinks"
	desc = "These claim to be '100% all natoural* tobacco**'."
	cigtype = /obj/item/clothing/mask/cigarette/cigarillo/flavoured
	icon_state = "cigarillopacket"
	package_style = "cigarillopacket"

/obj/item/cigpacket/cigarillo/juicer
	name = "Juicer Schweet's Rowdy 'Rillos"
	desc = "These have clearly been opened and repackaged."
	cigtype = /obj/item/clothing/mask/cigarette/cigarillo/juicer
	icon_state = "juicer_sweets"
	package_style = "juicer_sweets"


// heh

/* ================================================== */
/* -------------------- Lighters -------------------- */
/* ================================================== */

/obj/item/matchbook
	name = "matchbook"
	desc = "A little bit of heavy paper with some matches in it, and a little strip to light them on."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "matchbook"
	uses_multiple_icon_states = 1
	w_class = W_CLASS_TINY
	throwforce = 1
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	burn_point = 220
	burn_output = 900
	burn_possible = 1
	health = 4
	var/match_amt = 6 // -1 for infinite
	rand_pos = 1

	get_desc()
		if (src.match_amt == -1)
			. += "There's a whole lot of matches left."
		else if (src.match_amt >= 1)
			. += "There's [src.match_amt] match[s_es(src.match_amt, 1)] left."
		else
			. += "It's empty."

	attack_hand(mob/user)
		if (user.find_in_hand(src))
			if (src.match_amt == 0)
				user.show_text("Looks like there's no matches left.", "red")
				return
			else
				var/obj/item/match/W = new /obj/item/match(user)
				user.put_in_hand_or_drop(W)
				if (src.match_amt != -1)
					src.match_amt --
					tooltip_rebuild = 1
			src.UpdateIcon()
		else
			return ..()
		return

	afterattack(atom/target, mob/user as mob)
		if (istype(target, /obj/item/match))
			if (target:on > 0)
				return
			if (target:on == -1)
				user.show_text("You [pick("fumble", "fuss", "mess", "faff")] around with [target] and try to get it to light, but it's no use.", "red")
				return
			else if (prob(25))
				user.visible_message("<b>[user]</b> awkwardly strikes [src] on [target]. [target] breaks!",\
				"You awkwardly strike [src] on [target]. [target] breaks![prob(50) ? " [pick("Damn!", "Fuck!", "Shit!", "Crap!")]" : null]")
				playsound(user.loc, 'sound/items/matchstick_hit.ogg', 50, 1)
				target:put_out(user, 1)
				return
			else if (prob(10))
				user.visible_message("<b>[user]</b> awkwardly strikes [src] on [target]. A small flame sparks into life from the tip.",\
				"You awkwardly strike [src] on [target]. A small flame sparks into life from the tip.")
				target:light(user)
				return
			else
				user.visible_message("<b>[user]</b> awkwardly strikes [src] on [target]. Nothing happens.",\
				"You awkwardly strike [src] on [target]. Nothing happens.")
				playsound(user.loc, 'sound/items/matchstick_hit.ogg', 50, 1)
				return
		else
			return ..()

	attack()
		return

	update_icon()
		if (src.match_amt == -1)
			src.icon_state = "matchbook6"
			return
		else
			src.icon_state = "matchbook[src.match_amt]"

/obj/item/match
	name = "match"
	desc = "A little stick of wood with phosphorus on the tip, for lighting fires, or making you very frustrated and not lighting fires. Either or."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "match"
	uses_multiple_icon_states = 1
	w_class = W_CLASS_TINY
	throwforce = 1
	flags = FPRINT | TABLEPASS | SUPPRESSATTACK
	stamina_damage = 0
	stamina_cost = 0
	stamina_crit_chance = 1
	burn_point = 220
	burn_output = 600
	burn_possible = 1

	/// 0 = unlit, 1 = lit, -1 is burnt out/broken or otherwise unable to be lit
	var/on = 0

	var/light_mob = 0
	var/life_timer = 0
	rand_pos = 1
	var/datum/light/light

	New()
		..()
		src.create_reagents(1)
		reagents.add_reagent("phosphorus", 1)
		light = new /datum/light/point
		light.set_brightness(0.4)
		light.set_color(0.94, 0.69, 0.27)
		light.attach(src)
		src.life_timer = rand(15,25)

	pickup(mob/user)
		..()
		light.attach(user)

	dropped(mob/user)
		..()
		if (isturf(src.loc) && src.on > 0)
			user.visible_message("<span class='alert'><b>[user]</b> calmly drops and treads on the lit [src.name], putting it out instantly.</span>")
			src.put_out(user)
			return
		SPAWN(0)
			if (src.loc != user)
				light.attach(src)

	process()
		if (src.on > 0)
			if (src.life_timer >= 0)
				life_timer--
			var/location = src.loc
			if (ismob(location))
				var/mob/M = location
				if (src.life_timer <= 0)
					src.put_out(M)
					if (M.find_in_hand(src))
						M.show_text("[src] burns your hand as the flame reaches the end of [src]!", "red")
						M.TakeDamage("All", 0, rand(1,5))
					return
			var/turf/T = get_turf(src.loc)
			if (T)
				T.hotspot_expose(600,5)
			if (src.life_timer <= 0)
				src.put_out()
				return
			//sleep(1 SECOND)

	proc/light(var/mob/user as mob)
		src.on = 1
		src.firesource = FIRESOURCE_OPEN_FLAME
		src.icon_state = "match-lit"

		playsound(user, 'sound/items/matchstick_light.ogg', 50, 1)
		light.enable()

		processing_items |= src

	proc/put_out(var/mob/user as mob, var/break_it = 0)
		src.on = -1
		src.firesource = FALSE
		src.life_timer = 0
		if (break_it)
			src.icon_state = "match-broken"
			src.name = "broken match"
			if (user)
				playsound(user, 'sound/impact_sounds/Flesh_Crush_1.ogg', 60, 1, 0, 2)
		else
			src.icon_state = "match-burnt"
			src.name = "burnt-out match"
			playsound(src, 'sound/impact_sounds/burn_sizzle.ogg', 50, 1)

		light.disable()

		processing_items.Remove(src)

	temperature_expose(datum/gas_mixture/air, temperature, volume)
		if (src.on == 0)
			if (temperature > T0C+200)
				src.visible_message("<span class='alert'>The [src] ignites!</span>")
				src.light()

	ex_act(severity)
		if (src.on == 0)
			src.visible_message("<span class='alert'>The [src] ignites!</span>")
			src.light()

	afterattack(atom/target, mob/user as mob)
		if (src.on > 0)
			if (!ismob(target) && target.reagents)
				user.show_text("You heat [target].", "blue")
				target.reagents.temperature_reagents(4000,10)
				return
		else if (src.on == -1)
			user.show_text("You [pick("fumble", "fuss", "mess", "faff")] around with [src] and try to get it to light, but it's no use.", "red")
			return
		else if (src.on == 0)
			if (istype(target, /obj/item/match) && target:on > 0)
				user.visible_message("<b>[user]</b> lights [src] with the flame from [target].",\
				"You light [src] with the flame from [target].")
				src.light(user)
				return
			else if (istype(target, /obj/item/clothing/mask/cigarette) && target:on > 0)
				user.visible_message("<b>[user]</b> lights [src] with [target].",\
				"You light [src] with [target].")
				src.light(user)
				return
			else if (istype(target, /obj/item/matchbook))
				if (prob(10))
					user.visible_message("<b>[user]</b> strikes [src] on [target]. [src] breaks!",\
					"You strike [src] on [target]. [src] breaks![prob(50) ? " [pick("Damn!", "Fuck!", "Shit!", "Crap!")]" : null]")
					playsound(user.loc, 'sound/items/matchstick_hit.ogg', 50, 1)
					src.put_out(user, 1)
					return
				else if (prob(50))
					user.visible_message("<b>[user]</b> strikes [src] on [target]. A small flame sparks into life from the tip.",\
					"You strike [src] on [target]. A small flame sparks into life from the tip.")
					src.light(user)
					return
				else
					user.visible_message("<b>[user]</b> strikes [src] on [target]. Nothing happens.",\
					"You strike [src] on [target]. Nothing happens.")
					playsound(user.loc, 'sound/items/matchstick_hit.ogg', 50, 1)
					return
			else if (istype (target, /obj/item) && target:burning)
				user.visible_message("<b>[user]</b> lights [src] with the flame from [target].",\
				"You light [src] with the flame from [target].")
				src.light(user)
				return
			else if (istype(target, /obj/item/reagent_containers/food/snacks/)) // RE-copied from cigarettes
				user.visible_message("<span class='notice'><b>[user]</b> crushes up [src] and sprinkles it onto [target], what the fuck?.</span>",\
				"<span class='notice'>You crush up [src] and sprinkle it onto [target].</span>")
				if (src.reagents) // copied wirefix
					src.reagents.trans_to(target, 5)
				qdel (src)
				return
			else if (istype(target, /obj/item/reagent_containers/)) // crushing cigs into actual containers remains the same
				user.visible_message("<span class='notice'><b>[user]</b> crushes up [src] into [target].</span>",\
				"<span class='notice'>You crush up [src] into [target].</span>")
				if (src.reagents) // copied wirefix
					src.reagents.trans_to(target, 5)
				qdel (src)
				return
			else
				if (prob(10))
					user.visible_message("<b>[user]</b> strikes [src] on [target]. A small flame sparks into life from the tip.[prob(50) ? " [pick("Damn", "Fuck", "Shit", "Wow")][pick("!", " that was cool!", " that was smooth!")]" : null]",\
					"You strike [src] on [target]. A small flame sparks into life from the tip.")
					src.light(user)
					return
				else if (prob(25))
					user.visible_message("<b>[user]</b> strikes [src] on [target]. [src] breaks!",\
					"You strike [src] on [target]. [src] breaks![prob(50) ? " [pick("Damn!", "Fuck!", "Shit!", "Crap!")]" : null]")
					playsound(user.loc, 'sound/items/matchstick_hit.ogg', 50, 1)
					src.put_out(user, 1)
					return
				else
					user.visible_message("<b>[user]</b> strikes [src] on [target]. Nothing happens.",\
					"You strike [src] on [target]. Nothing happens.[prob(50) ? " You feel awkward, though." : null]")
					playsound(user.loc, 'sound/items/matchstick_hit.ogg', 50, 1)
					return

	attack(mob/M, mob/user)
		if (ishuman(M))
			if (src.on > 0)
				var/mob/living/carbon/human/fella = M
				if (fella.wear_mask && istype(fella.wear_mask, /obj/item/clothing/mask/cigarette))
					var/obj/item/clothing/mask/cigarette/smoke = fella.wear_mask // aaaaaaa
					smoke.light(user, "<span class='alert'><b>[user]</b> lights [fella]'s [smoke] with [src].</span>")
					fella.set_clothing_icon_dirty()
					return
				else if (fella.bleeding || (fella.butt_op_stage == 4 && user.zone_sel.selecting == "chest"))
					src.cautery_surgery(fella, user, 5, src.on)
					return ..()
				else
					user.visible_message("<span class='alert'><b>[user]</b> puts out [src] on [fella]!</span>",\
					"<span class='alert'>You put out [src] on [fella]!</span>")
					fella.TakeDamage("All", 0, rand(1,5))
					if (!fella.stat)
						fella.emote("scream")
					src.put_out(user)
					return
		else
			return ..()

	attack_self(mob/user)
		if (user.find_in_hand(src))
			if (src.on > 0)
				user.visible_message("<b>[user]</b> [pick("licks [his_or_her(user)] finger and snuffs out [src].", "waves [src] around until it goes out.")]")
				src.put_out(user)
		else
			return ..()
		return

/obj/item/device/light/zippo
	name = "\improper Zippo lighter"
	desc = "A pretty nice lighter."
	icon = 'icons/obj/items/cigarettes.dmi'
	icon_state = "zippo"
	item_state = "zippo"
	var/item_state_base = "zippo"
	inhand_image_icon = 'icons/mob/inhand/hand_general.dmi'
	w_class = W_CLASS_TINY
	throwforce = 4
	flags = FPRINT | TABLEPASS | CONDUCT | ATTACK_SELF_DELAY
	c_flags = ONBELT
	object_flags = NO_GHOSTCRITTER
	click_delay = 0.7 SECONDS
	stamina_damage = 5
	stamina_cost = 5
	stamina_crit_chance = 5
	icon_off = "zippo"
	icon_on = "zippoon"
	brightness = 0.4
	col_r = 0.94
	col_g = 0.69
	col_b = 0.27
	var/infinite_fuel = 0 //1 is infinite fuel. Borgs use this apparently.
	/// exposure temp when heating reagents
	var/reagent_expose_temp = 4000
	/// exposure temp of passive enviromental heating
	var/enviromental_expose_temp = 700

	New()
		..()
		if (!infinite_fuel)
			src.create_reagents(20)
			reagents.add_reagent("fuel", 20)

		src.setItemSpecial(/datum/item_special/flame)
		return

	attack_self(mob/user)
		if (user.find_in_hand(src))
			if (!src.on)
				if (infinite_fuel)
					src.activate(user)
				if (!reagents)
					return
				if (!reagents.get_reagent_amount("fuel"))
					user.show_text("Out of fuel.", "red")
					return
				src.activate(user)
			else
				src.deactivate(user)
			user.update_inhands()
		else
			return ..()
		return

	proc/activate(mob/user as mob)
		src.on = 1
		src.firesource = FIRESOURCE_OPEN_FLAME
		set_icon_state(src.icon_on)
		src.item_state = "[item_state_base]on"
		flick("[icon_state]_open", src)
		light.enable()
		processing_items |= src
		if (user != null)
			user.visible_message("<span class='alert'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>")
			playsound(user, 'sound/items/zippo_open.ogg', 30, 1)
			user.update_inhands()

	proc/deactivate(mob/user as mob)
		src.on = 0
		src.firesource = FALSE
		set_icon_state(src.icon_off)
		src.item_state = "[item_state_base]"
		flick("[icon_state]_close", src)
		light.disable()
		processing_items.Remove(src)
		if (user != null)
			user.visible_message("<span class='alert'>You hear a quiet click, as [user] shuts off [src] without even looking what they're doing. Wow.</span>")
			playsound(user, 'sound/items/zippo_close.ogg', 30, 1)
			user.update_inhands()

	attack(mob/target, mob/user)
		if (ishuman(target))
			var/mob/living/carbon/human/fella = target

			if (src.on)
				if (user.zone_sel.selecting == "l_arm")
					if (fella.limbs.l_arm_bleed > 1)
						fella.TakeDamage("chest",0,10)
						fella.limbs.l_arm_bleed = max(0,fella.limbs.l_arm_bleed-5)
						if (fella.limbs.l_arm_bleed == 0)
							user.visible_message("<span class='alert'>[user] completely cauterises [fella]'s left stump with [src]!</span>")
						else
							user.visible_message("<span class='alert'>[user] partially cauterises [fella]'s left stump with [src]!</span>")
						return

				if (user.zone_sel.selecting == "r_arm")
					if (fella.limbs.r_arm_bleed > 1)
						fella.TakeDamage("chest",0,10)
						fella.limbs.r_arm_bleed = max(0,fella.limbs.r_arm_bleed-5)
						if (fella.limbs.r_arm_bleed == 0)
							user.visible_message("<span class='alert'>[user] completely cauterises [fella]'s right stump with [src]!</span>")
						else
							user.visible_message("<span class='alert'>[user] partially cauterises [fella]'s right stump with [src]!</span>")
						return

				if (fella.wear_mask && istype(fella.wear_mask, /obj/item/clothing/mask/cigarette))
					var/obj/item/clothing/mask/cigarette/smoke = fella.wear_mask // aaaaaaa
					smoke.light(user, "<span class='alert'><b>[user]</b> lights [fella]'s [smoke] with [src].</span>")
					fella.set_clothing_icon_dirty()
					return

			if (fella.bleeding || (fella.butt_op_stage == 4 && user.zone_sel.selecting == "chest"))
				if (src.cautery_surgery(target, user, 10, src.on))
					return

		user.visible_message("<span class='alert'><b>[user]</b> waves [src] around in front of [target]'s face! OoOo, are ya scared?![src.on ? "" : " No, probably not, since [src] is closed."]</span>")
		return

	afterattack(atom/O, mob/user as mob)
		if (!on && (istype(O, /obj/reagent_dispensers/fueltank) || istype(O, /obj/item/reagent_containers/food/drinks/fueltank)))
			if (!reagents)
				return

			if (infinite_fuel)
				user.show_text("You can't seem to find any way to add more fuel to [src]. It's probably fine.", "blue")
				return

			if (reagents.get_reagent_amount("fuel") >= src.reagents.maximum_volume) //this could be == but just in case...
				boutput(user, "<span class='alert'>[src] is full!</span>")
				return

			if (O.reagents.total_volume)
				if (O.reagents.has_reagent("fuel"))
					O.reagents.trans_to(src, src.reagents.maximum_volume - src.reagents.get_reagent_amount("fuel"), 1, 1, O.reagents.reagent_list.Find("fuel"))
					boutput(user, "<span class='notice'>[src] has been refueled.</span>")
					playsound(src.loc, 'sound/effects/zzzt.ogg', 50, 1, -6)
				else
					user.show_text("[src] can only be refilled with fuel.", "red")
			else
				user.show_text("[O] is empty.", "red")
			return

		else if (!ismob(O) && src.on && O.reagents)
			user.show_text("You heat [O].", "blue")
			O.reagents.temperature_reagents(reagent_expose_temp,10)
		else
			return ..()

	process()
		if (src.on)
			var/turf/location = src.loc
			if (ismob(location))
				var/mob/M = location
				if (M.find_in_hand(src))
					location = M.loc
			var/turf/T = get_turf(src.loc)
			if (T)
				T.hotspot_expose(enviromental_expose_temp,5)

			if (infinite_fuel) //skip all fuel checks
				return
			if (!reagents)
				if (ismob(src.loc))
					src.deactivate(src.loc)
				else
					src.deactivate(null)
				return
			if (reagents.get_reagent_amount("fuel"))
				reagents.remove_reagent("fuel", 0.2)
			if (!reagents.get_reagent_amount("fuel"))
				if (ismob(src.loc))
					src.deactivate(src.loc)
				else
					src.deactivate(null)
			//sleep(1 SECOND)

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		if (exposed_temperature > enviromental_expose_temp)
			return ..()
		return

	firesource_interact()
		if (!infinite_fuel && reagents.get_reagent_amount("fuel"))
			reagents.remove_reagent("fuel", 0.2)

	custom_suicide = 1
	suicide(var/mob/user as mob)
		if (!src.user_can_suicide(user))
			user.suiciding = 0
			return 0
		if (!src.on) // don't need to do more than just show the message since the lighter is deleted in a moment anyway
			user.visible_message("<span class='alert'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>")
		user.visible_message("<span class='alert'><b>[user] swallows the on [src.name]!</b></span>")
		user.take_oxygen_deprivation(75)
		user.TakeDamage("chest", 0, 100)
		user.emote("scream")
		SPAWN(50 SECONDS)
			if (user && !isdead(user))
				user.suiciding = 0
		qdel(src)
		return 1

/obj/item/device/light/zippo/gold
	name = "golden Zippo lighter"
	icon_state = "gold_zippo"
	icon_off = "gold_zippo"
	icon_on = "gold_zippoon"

/obj/item/device/light/zippo/brighter
	name = "\improper Zippo brighter"
	desc = "Are you feeling blinded by the light?"
	brightness = 4
	col_r = 0.69
	col_g = 0.27
	col_b = 1

/obj/item/device/light/zippo/dan
	name = "odd Zippo lighter"
	desc = "A sleek grey lighter. Something about it seems a bit strange."
	icon_state = "dan_zippo"
	icon_off = "dan_zippo"
	icon_on = "dan_zippoon"
	col_r = 0.45
	col_g = 0.22
	col_b = 1

/obj/item/device/light/zippo/borg
	infinite_fuel = 1

/obj/item/device/light/zippo/syndicate
	desc = "A sleek black lighter with a red stripe and an incredibly hot flame."
	icon_state = "syndie_zippo"
	icon_off = "syndie_zippo"
	icon_on = "syndie_zippoon"
	item_state = "syndi-zippo"
	item_state_base = "syndi-zippo"
	infinite_fuel = 1
	col_r = 0.298
	col_g = 0.658
	col_b = 0
	is_syndicate = 1
	reagent_expose_temp = 20000
	enviromental_expose_temp = 3500

	New()
		. = ..()
		RegisterSignals(src, list(COMSIG_MOVABLE_SET_LOC, COMSIG_MOVABLE_MOVED), .proc/update_hotbox_flag)

	proc/update_hotbox_flag(thing, previous_loc, direction)
		if (!firesource) return
		if (isturf(src.loc))
			var/turf/T = src.loc
			T.allow_unrestricted_hotbox++
		if (isturf(previous_loc))
			var/turf/T = previous_loc
			T.allow_unrestricted_hotbox = max(0, T.allow_unrestricted_hotbox - 1)
