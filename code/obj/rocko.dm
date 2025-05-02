
// CE's pet rock! A true hellburn companion
/obj/item/rocko
	name = "Rocko"
	icon = 'icons/obj/materials.dmi'
	icon_state = "rock1"
	w_class = W_CLASS_TINY
	force = 10
	throwforce = 15
	throw_range = 3

	var/static/list/rocko_is
	var/smile = TRUE
	var/painted
	var/bright = FALSE
	var/mob/living/holder
	var/obj/item/clothing/head/hat

	New()
		. = ..()
		if(prob(20))
			src.bright = TRUE

		src.icon_state = "rock[pick(1,3)]"
		src.transform = matrix(1.3,0,0,0,1.3,-3) // Scale 1.3 and Shift Down 3
		src.color = "#CCC" // Darken slightly to allow lighter colors to be more visibile

		src.rocko_is = list("a great listener", "a good friend", "trustworthy", "wise", "sweet", "great at parties")
		src.hat = new /obj/item/clothing/head/helmet/hardhat(src)

		if (prob(10))
			var/new_material = pick(childrentypesof(/datum/material/metal))
			var/datum/material/dummy = new new_material
			src.setMaterial(getMaterial(dummy.getID()), setname = FALSE)
		else
			src.setMaterial(getMaterial("rock"), appearance = FALSE, setname = FALSE)

		UpdateIcon()

		START_TRACKING_CAT(TR_CAT_PETS)
		processing_items |= src

	disposing()
		processing_items -= src
		STOP_TRACKING_CAT(TR_CAT_PETS)
		..()

	proc/can_mob_observe(mob/M)
		// ignore things we don't care about
		if(isnull(M.client))
			return FALSE

		var/view_chance = 0
		if(M.job == "Chief Engineer")
			view_chance += 2
			if(src.holder == M)
				view_chance += 5
		else if(M.job in list("Engineer"))
			view_chance += 1
			if(src.holder == M)
				view_chance += 1

		// whoa dude!
		if(M.reagents?.total_volume && (M.reagents.has_reagent("LSD") || M.reagents.has_reagent("lsd_bee") || M.reagents.has_reagent("psilocybin") || M.reagents?.has_reagent("bathsalts") || M.reagents?.has_reagent("THC")) )
			view_chance += 20
		if(M.hasStatus("drunk"))
			view_chance += 5

		return prob(view_chance)

	process()
		if(prob(95))
			return

		switch(pick( 200;1, 200;2, 50;3, 10;4, 100;5))
			if(1)
				emote("<B>[src]</B> winks.", "<I>winks</I>")
			if(2)
				if(holder) boutput(src.holder,"<B>[src]</B> feels warm.")
			if(3)
				emote("<B>[src]</B> whispers something about a hellburn.", "<I>whispers something about a hellburn</I>")
			if(4)
				emote("<B>[src]</B> rants about job site safety.", "<I>Goes on about job safety</I>")
			if(5)
				if (!src.holder)
					return
				src.say("We really need to do something about the [pick("captain", "head of personnel", "clown", "research director", "head of security", "medical director", "AI")].", atom_listeners_override = list(src.holder))

	emote(message, maptext_out)
		. = ..()

		var/list/mob/targets
		if(!src.holder)
			targets = viewers(src, null)
		else
			targets = list(src.holder)

		var/list/mob/recipients = list()
		for (var/mob/M as anything in targets)
			if(!src.can_mob_observe(M))
				continue

			recipients += M
			M.show_message(SPAN_EMOTE("[message]"))

		DISPLAY_MAPTEXT(src, recipients, MAPTEXT_MOB_RECIPIENTS_WITH_OBSERVERS, /image/maptext/emote, maptext_out)

	update_icon()
		var/image/smiley = image('icons/misc/rocko.dmi', src.smile ? "smile" : "frown")
		if(bright)
			painted = pick(list("#EE2","#2EE", "#E2E","#EEE"))
		else
			painted = pick(list("#000","#151","#514","#511","#218"))

		smiley.color = painted
		smiley.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE

		src.UpdateOverlays(smiley, "face")
		update_hat()

	proc/update_hat()
		if(istype(src.hat))
			var/icon/working_icon = icon(src.hat.wear_image_icon, src.hat.icon_state, SOUTH )
			working_icon.Shift(SOUTH, 10)
			var/image/working_hat = image(working_icon)
			working_hat.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | PIXEL_SCALE
			src.UpdateOverlays(working_hat, "hat")
		else
			src.UpdateOverlays(null, "hat")

	get_desc(dist, mob/user)
		if(ismob(user) &&	user.job == "Chief Engineer")
			. = "A rock but also [pick(rocko_is)]."
		else if(ismob(user) && (user.job in list("Engineer", "Quartermaster", "Captain")))
			. = "The Chief Engineer loves this rock.  Maybe it's to make up for their lack of a pet."
		else
			. = "A rock with a [src.smile ? "smiley" : "frowny"] face painted on it."

		if (src.material?.getID() != "rock")
			. += "<br>Wait, that isn't a rock. It's a [pick("hunk", "chunk")] of [src.material.getName()]!"

	attackby(obj/item/W, mob/living/user)
		if(istype(W,/obj/item/clothing/head))
			if(src.hat)
				src.hat.set_loc(get_turf(src))

			src.hat = W
			user.drop_item(W)
			W.set_loc(src)
			user.visible_message("[user] manages to fit [W] snugly on top of [src].")
			update_hat()
		if(istype(W, /obj/item/pet_carrier))
			var/obj/item/pet_carrier/carrier = W
			carrier.trap_mob(src, user)
			user.visible_message(SPAN_ALERT("[user] places [src] into [carrier]."))
			return
		. = ..()

	attack_self(mob/user as mob)
		. = "[user] shakes [src]"
		if(src.hat && prob(40))
			. += " and knocks [src.hat] off"
			src.hat.set_loc(get_turf(src))
			src.hat = null
			update_hat()
		user.visible_message("[.].")

	afterattack(atom/target, mob/user, reach, params)
		if(src.smile && ismob(target) && prob(10))
			src.smile = FALSE
			UpdateIcon()


