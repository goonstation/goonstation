// NO GLOVES NO LOVES

var/list/glove_IDs = new/list() //Global list of all gloves. Identical to Cogwerk's forensic ID system (Convair880).
ABSTRACT_TYPE(/obj/item/clothing/gloves)
/obj/item/clothing/gloves
	name = "gloves"
	w_class = 2.0
	icon = 'icons/obj/clothing/item_gloves.dmi'
	wear_image_icon = 'icons/mob/hands.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_feethand.dmi'
	protective_temperature = 400
	var/uses = 0
	var/max_uses = 0 // If can_be_charged == 1, how many charges can these gloves store?
	var/stunready = 0
	var/weighted = 0
	var/atom/movable/overlay/overl = null
	var/activeweapon = 0 // Used for gloves that can be toggled to turn into a weapon (example, bladed gloves)

	var/hide_prints = 1 // Seems more efficient to do this with one global proc and a couple of vars (Convair880).
	var/scramble_prints = 0
	var/material_prints = null

	var/can_be_charged = 0 // Currently, there are provisions for icon state "yellow" only. You have to update this file and mob_procs.dm if you're wanna use other glove sprites (Convair880).
	var/glove_ID = null

	var/crit_override = 0 //overrides user's stamina crit chance, unless the user has some special limb attached
	var/bonus_crit_chance = 0 //bonus stamina crit chance; used additively in melee_attack_procs if crit_override is 0, otherwise replaces existing crit chance
	var/stamina_dmg_mult = 0 //used additively in melee_attack_procs

	var/overridespecial = 0
	var/datum/item_special/specialoverride = null

	setupProperties()
		..()
		setProperty("coldprot", 3)
		setProperty("heatprot", 3)
		setProperty("viralprot", 10)
		setProperty("conductivity", 0.5)

	New()
		..() // your parents miss you
		flags |= HAS_EQUIP_CLICK
		SPAWN_DBG(2 SECONDS)
			src.glove_ID = src.CreateID()
			if (glove_IDs) // fix for Cannot execute null.Add(), maybe??
				glove_IDs.Add(src.glove_ID)

	examine()
		. = ..()
		if (src.stunready)
			. += "It seems to have some wires attached to it.[src.max_uses > 0 ? " There are [src.uses]/[src.max_uses] charges left!" : ""]"

	// reworked this proc a bit so it can't run more than 5 times, just in case
	proc/CreateID()
		var/newID = null
		for (var/i=5, i>0, i--)
			newID = GenID()
			if (glove_IDs && newID && !glove_IDs.Find(newID))
				return newID

	proc/GenID()
		var/newID = ""
		for (var/i=10, i>0, i--)
			newID += "[pick(numbersAndLetters)]"
		if (length(newID))
			return newID

	attack(var/atom/target as mob, var/atom/challenger as mob)
		// you, sir, have offended my honour!
		if (!isliving(target))
			return ..()
		// check intents and targets
		if (ismob(challenger))
			var/mob/C = challenger
			if (C.a_intent != INTENT_HELP || !(C.zone_sel && C.zone_sel.selecting == "head"))
				return ..()
		else
			return ..()
		// I demand satisfaction!
		if (ismob(target))
			target.visible_message(
				"<span><b>[challenger]</b> slaps [target] in the face with the the [src]!</span>",
				"<span class='alert'><b>[challenger] slaps you in the face with the [src]! [capitalize(he_or_she(challenger))] has offended your honour!</span>"
			)
			logTheThing("combat", challenger, target, "glove-slapped [constructTarget(target,"combat")]")
		else
			target.visible_message(
				"<span class='alert'><b>[challenger]</b> slaps [target] in the face with the [src]!</span>"
			)
		playsound(target, 'sound/impact_sounds/Generic_Snap_1.ogg', 100, 1)

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/cable_coil))
			if (!src.can_be_charged)
				user.show_text("The [src.name] cannot be electrically charged.", "red")
				return
			if (src.stunready)
				user.show_text("You don't need to add more wiring to the [src.name].", "red")
				return

			var/obj/item/cable_coil/coil = W
			if(!coil.use(1))
				return
			boutput(user, "<span class='notice'>You attach the wires to the [src.name].</span>")
			src.stunready = 1
			src.setSpecialOverride(/datum/item_special/spark, 0)
			src.material_prints += ", electrically charged"
			return

		if (istype(W, /obj/item/cell)) // Moved from cell.dm (Convair880).
			var/obj/item/cell/C = W

			if (C.charge < 1500)
				user.show_text("[C] needs more charge before you can do that.", "red")
				return
			if (!src.stunready)
				user.visible_message("<span class='alert'><b>[user]</b> shocks themselves while fumbling around with [C]!</span>", "<span class='alert'>You shock yourself while fumbling around with [C]!</span>")
				C.zap(user)
				return

			if (src.can_be_charged)
				if (src.uses == src.max_uses)
					user.show_text("The gloves are already fully charged.", "red")
					return
				if (src.uses < 0)
					src.uses = 0
				src.uses = min(src.uses + 1, src.max_uses)
				C.use(1500)
				src.icon_state = "stun"
				src.item_state = "stun"
				src.overridespecial = 1
				C.updateicon()
				user.update_clothing() // Required to update the worn sprite (Convair880).
				user.visible_message("<span class='alert'><b>[user]</b> charges [his_or_her(user)] stun gloves.</span>", "<span class='notice'>The stun gloves now hold [src.uses]/[src.max_uses] charges!</span>")
			else
				user.visible_message("<span class='alert'><b>[user]</b> shocks themselves while fumbling around with [C]!</span>", "<span class='alert'>You shock yourself while fumbling around with [C]!</span>")
				C.zap(user)
			return

		..()

	proc/damage_bonus()
		if (weighted)
			return 3
		return 0

	proc/distort_prints(var/prints as text, var/get_glove_ID = 1) // Ditto (Convair880).

		var/data = null

		if (!src.hide_prints)
			data += prints

		else

			if (src.scramble_prints)
				data += corruptText(prints, 20)

			else // Seems a bit redundant to return both (Convair880).

				if (src.material_prints)
					data += src.material_prints
				else
					data += "unknown fiber material"

		if (get_glove_ID)
			data += " (Glove ID: [src.glove_ID])" // Space is required for formatting (Convair880).

		return data

	proc/special_attack(var/mob/target)
		boutput(usr, "Your gloves do nothing special")
		return

	proc/setSpecialOverride(var/type = null, active = 1)
		if(!ispath(type))
			if(isnull(type))
				src.specialoverride?.onRemove()
				src.specialoverride = null
			return null

		src.specialoverride?.onRemove()

		var/datum/item_special/S = new type
		S.master = src
		src.overridespecial = active
		S.onAdd()
		src.specialoverride = S
		return S


	equipment_click(atom/user, atom/target, params, location, control, origParams, slot)
		if(target == user || user:a_intent == INTENT_HELP || user:a_intent == INTENT_GRAB) return 0
		if(slot != SLOT_GLOVES || !overridespecial) return 0
		if(ismob(user))
			var/mob/M = user
			specialoverride.pixelaction(target,params,M)
			M.next_click = world.time+M.combat_click_delay
			return 1


/obj/item/clothing/gloves/long // adhara stuff
	desc = "These long gloves protect your sleeves and skin from whatever dirty job you may be doing."
	name = "cleaning gloves"
	icon = 'icons/obj/clothing/item_gloves.dmi'
	wear_image_icon = 'icons/mob/hands.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_feethand.dmi'
	icon_state = "long_gloves"
	item_state = "long_gloves"
	protective_temperature = 550
	material_prints = "synthetic silicone rubber fibers"
	setupProperties()
		..()
		setProperty("conductivity", 0.1)
		setProperty("heatprot", 5)

/obj/item/clothing/gloves/fingerless
	desc = "These gloves lack fingers."
	name = "Fingerless Gloves"
	icon_state = "fgloves"
	item_state = "finger-"
	hide_prints = 0

/obj/item/clothing/gloves/black
	desc = "These gloves are fire-resistant."
	name = "Black Gloves"
	icon_state = "black"
	item_state = "bgloves"
	protective_temperature = 1500
	material_prints = "black leather fibers"

	setupProperties()
		..()
		setProperty("heatprot", 7)

/obj/item/clothing/gloves/cyborg
	desc = "beep boop borp"
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "r_hands"
	setupProperties()
		..()
		setProperty("conductivity", 1)

/obj/item/clothing/gloves/latex
	name = "Latex Gloves"
	icon_state = "latex"
	item_state = "lgloves"
	permeability_coefficient = 0.02
	desc = "Thin gloves that offer minimal protection."
	protective_temperature = 310
	scramble_prints = 1
	setupProperties()
		..()
		setProperty("conductivity", 0.3)

/obj/item/clothing/gloves/latex/blue
	color = "#91d5e9"
/obj/item/clothing/gloves/latex/purple
	color = "#d888d8"
/obj/item/clothing/gloves/latex/teal
	color = "#73e8b6"
/obj/item/clothing/gloves/latex/pink
	color = "#ff9bc6"

/obj/item/clothing/gloves/latex/random
	New()
		..()
		if (prob(66))
			src.color = pick("#91d5e9","#d888d8","#73e8b6","#ff9bc6")

/obj/item/clothing/gloves/crafted
	name = "gloves"
	icon_state = "latex"
	item_state = "lgloves"
	desc = "Custom made gloves."
	scramble_prints = 1

	insulating
		onMaterialChanged()
			..()
			if(istype(src.material))
				if(src.material.hasProperty("electrical"))
					src.setProperty("conductivity", src.material.getProperty("electrical") / 100)
				else
					src.setProperty("conductivity", 1)

				if(src.material.hasProperty("thermal"))
					protective_temperature = (100 - src.material.getProperty("thermal")) ** 1.65
					setProperty("coldprot", round((100 - src.material.getProperty("thermal")) * 0.1))
					setProperty("heatprot", round((100 - src.material.getProperty("thermal")) * 0.1))
				else
					protective_temperature = 0
					setProperty("coldprot", 0)
					setProperty("heatprot", 0)
			return

	armored
		icon_state = "black"
		item_state = "swat_gl"
		onMaterialChanged()
			..()
			if(istype(src.material))
				if(src.material.hasProperty("density"))//linear function, 10 points of disarm-block for every 25 density, starting from density==10
					src.setProperty("deflection", round(max(src.material.getProperty("density")**0.5+0.2*(src.material.getProperty("density")-20),0)))
				else
					src.setProperty("deflection", 0)
				if(src.material.hasProperty("hard"))//Curve hits 0.5 at 30 (fibrilith), 1 at 60 (carbon fibre), 1.2 at 85 (starstone, aka maximum)
					src.setProperty("rangedprot", round(max(0,-0.5034652-(-0.04859378/0.02534389)*(1-eulers**(-0.02534398*src.material.getProperty("hard")))),0.1)) //holy best-fit curve batman!
				else
					src.setProperty("rangedprot", 0)
			return

/obj/item/clothing/gloves/swat
	desc = "A pair of syndicate tactical gloves that are quite fire and electrically-resistant. They also help you block attacks. They do not specifically help you block against blocking though. Just regular attacks."
	name = "SWAT Gloves"
	icon_state = "swat_syndie"
	item_state = "swat_syndie"
	protective_temperature = 1100
	material_prints = "high-quality synthetic fibers"
	setupProperties()
		..()
		setProperty("heatprot", 10)
		setProperty("conductivity", 0.3)
		setProperty("deflection", 20)

/obj/item/clothing/gloves/swat/NT
	desc = "A pair of Nanotrasen tactical gloves that are quite fire and electrically-resistant. They also help you block attacks. They do not specifically help you block against blocking though. Just regular attacks."
	icon_state = "swat_NT"
	item_state = "swat_NT"

/obj/item/clothing/gloves/stungloves/
	name = "Stungloves"
	desc = "These gloves are electrically charged."
	icon_state = "stun"
	item_state = "stun"
	material_prints = "insulative fibers, electrically charged"
	stunready = 1
	can_be_charged = 1
	uses = 10
	max_uses = 10
	setupProperties()
		..()
		setProperty("conductivity", 0)
	New()
		..()
		setSpecialOverride(/datum/item_special/spark)


/obj/item/clothing/gloves/yellow
	desc = "These gloves are electrically insulated."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	material_prints = "insulative fibers"
	can_be_charged = 1
	max_uses = 4
	permeability_coefficient = 0.5

	setupProperties()
		..()
		setProperty("conductivity", 0)

	proc/unsulate()
		src.desc = "These gloves are not electrically insulated."
		src.name = "unsulated gloves"
		setProperty("conductivity", 1)
		src.can_be_charged = 0
		src.max_uses = 0

/obj/item/clothing/gloves/yellow/unsulated
	desc = "These gloves are not electrically insulated."
	name = "unsulated gloves"
	can_be_charged = 0
	max_uses = 0
	setupProperties()
		..()
		setProperty("conductivity", 1)

/obj/item/clothing/gloves/boxing
	name = "Boxing Gloves"
	desc = "These gloves are for competitive boxing."
	icon_state = "boxinggloves"
	item_state = "bogloves"
	material_prints = "red leather fibers"
	crit_override = 1
	bonus_crit_chance = 0
	stamina_dmg_mult = 0.35

	setupProperties()
		..()
		setProperty("coldprot", 7)
		setProperty("conductivity", 0.3)

	afterattack(atom/target, mob/user, reach, params)
		..()
		boutput(user, "<span class='notice'><b>You have to put the gloves on your hands first, silly!</b></span>")

	get_desc()
		if (src.weighted)
			. += "These things are pretty heavy!"

/obj/item/clothing/gloves/boxing/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/horseshoe))
		if (src.weighted)
			boutput(user, "<span class='alert'>You try to put [W] into [src], but there's already something in there!</span>")
			return
		boutput(user, "You slip the horseshoe inside one of the gloves.")
		src.weighted = 1
		tooltip_rebuild = 1
		qdel(W)
	else
		return ..()

/obj/item/horseshoe //Heavy horseshoe for traitor boxers to put in their gloves
	name = "Heavy Horseshoe"
	desc = "An old horseshoe."
	icon = 'icons/obj/junk.dmi'
	icon_state = "horseshoe"
	force = 6.5
	throwforce = 25
	throw_speed = 3
	throw_range = 6
	w_class = 1.0
	flags = FPRINT | TABLEPASS | NOSHIELD

	New()
		..()
		BLOCK_SETUP(BLOCK_ROPE)

/obj/item/clothing/gloves/powergloves
	desc = "Now I'm playin' with power!"
	name = "power gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	material_prints = "insulative fibers and nanomachines"
	can_be_charged = 1 // Quite pointless, but could be useful as a last resort away from powered wires? Hell, it's a traitor item and can get the buff (Convair880).
	max_uses = 4
	flags = HAS_EQUIP_CLICK

	var/spam_flag = 0

	setupProperties()
		..()
		setProperty("conductivity", 0)

	proc/use_power(var/amount)
		var/turf/T = get_turf(src)
		var/area/A = T.loc
		if(!A || !isarea(A))
			return
		A.use_power(amount, ENVIRON)

	equipment_click(atom/user, atom/target, params, location, control, origParams, slot)
		if(target == user || spam_flag || user:a_intent == INTENT_HELP || user:a_intent == INTENT_GRAB) return 0
		if(slot != SLOT_GLOVES) return 0

		var/netnum = 0
		if(src.overridespecial)
			..()
		for(var/turf/T in range(1, user))
			for(var/obj/cable/C in T.contents) //Needed because cables have invisibility 101. Making them disappear from most LISTS.
				netnum = C.netnum
				break

		if(get_dist(user, target) > 1 && !user:equipped())

			if(!netnum)
				boutput(user, "<span class='alert'>The gloves find no cable to draw power from.</span>")
				return

			spam_flag = 1
			SPAWN_DBG(4 SECONDS) spam_flag = 0

			use_power(50000)

			var/atom/last = user
			var/atom/target_r = target

			var/list/dummies = new/list()

			playsound(user, "sound/effects/elec_bigzap.ogg", 40, 1)

			for (var/obj/item/cloaking_device/I in user)
				if (I.active)
					I.deactivate(user)
					user.visible_message("<span class='notice'><b>[user]'s cloak is disrupted!</b></span>")

			if(isturf(target))
				target_r = new/obj/elec_trg_dummy(target)

			var/turf/currTurf = get_turf(target_r)
			currTurf.hotspot_expose(2000, 400)

			for(var/count=0, count<4, count++)

				var/list/affected = DrawLine(last, target_r, /obj/line_obj/elec ,'icons/obj/projectiles.dmi',"WholeLghtn",1,1,"HalfStartLghtn","HalfEndLghtn",OBJ_LAYER,1,PreloadedIcon='icons/effects/LghtLine.dmi')

				for(var/obj/O in affected)
					SPAWN_DBG(0.6 SECONDS) pool(O)

				if(istype(target_r, /obj/machinery/power/generatorTemp))
					var/obj/machinery/power/generatorTemp/gen = target_r
					gen.efficiency_controller += 5
					gen.grump += 5
					SPAWN_DBG(45 SECONDS)
						gen.efficiency_controller -= 5

				else if(isliving(target_r)) //Probably unsafe.
					logTheThing("combat", user, target_r, "zaps [constructTarget(target_r,"combat")] with power gloves")
					switch(user:a_intent)
						if("harm")
							src.electrocute(target_r, 100, netnum)
							break
						if("disarm")
							target_r:weakened += 3
							break

				var/list/next = new/list()
				for(var/atom/movable/M in orange(3, target_r))
					if(M == user || istype(M, /obj/line_obj/elec) || istype(M, /obj/elec_trg_dummy) || istype(M, /obj/overlay/tile_effect) || M.invisibility) continue
					next.Add(M)

				if(istype(target_r, /obj/elec_trg_dummy)) dummies.Add(target_r)

				last = target_r
				target_r = pick(next)
				target = target_r

			for(var/d in dummies)
				qdel(d)

		return 1

/obj/item/clothing/gloves/water_wings
	name = "water wings"
	desc = "Inflatable armbands that don't help you keep afloat at all! At least they look fun."
	icon_state = "water_wings"
	item_state = "water_wings"
	hide_prints = 0


//Fun isn't something one considers when coding in ss13, but this did put a smile on my face
/obj/item/clothing/gloves/brass_gauntlet
	name = "Brass Gauntlet"
	desc = "A strange gauntlet made of cogs and brass machinery. It has seven slots along the side."
	icon_state = "brassgauntlet"
	item_state = "brassgauntlet"
	weighted = 1
	burn_possible = 0
	cant_self_remove = 1
	cant_other_remove = 1
	abilities = list()
	ability_buttons = list()

	attackby(obj/item/power_stones/W, mob/user)
		if (istype(W, /obj/item/power_stones))
			if(!istype(user, /mob/living/carbon/human)) return //This ain't a critter gauntlet
			if(user:gloves != src)
				boutput(user, "<span class='alert'><B>You need to be wearing it dingus!</B></span>")
				return
			for(var/obj/item/power_stones/S in src)
				if(S.stonetype == W.stonetype)
					boutput(user, "<span class='alert'><B>That's already in there you doofus!</B></span>") //Some nerd is going to figure out how to duplicate stones I know it
					return
			user.visible_message("<span class='alert'><B>[user] slots the [W] into the [src]!</B></span>")
			user.drop_item()
			W.set_loc(src)
			abilities.Add(W.ability)

			var/obj/ability_button/NB = new W.ability(src)
			ability_buttons += NB
			NB.the_item = src
			NB.the_mob = user
			NB.name = NB.name + " ([W.name])"

			if(!user.item_abilities.Find(NB))
				user.item_abilities.Add(NB)

			user.need_update_item_abilities = 1
			user.update_item_abilities()

		//Nerd trap for using the philosophers stone
		if (istype(W, /obj/item/alchemy/stone))
			if(!istype(user, /mob/living/carbon/human)) return
			if(user:gloves != src) return

			badstone(user, W, src)
			goldsnap(user)

		//Wow this is super dumb and dangerous why would you do this
		if(istype(W, /obj/item/raw_material))
			if(!istype(user, /mob/living/carbon/human)) return
			if(user:gloves != src) return

			badmaterial(user, W, src)

		//whytho
		if(istype(W, /obj/item/brick))
			if(!istype(user, /mob/living/carbon/human)) return
			if(user:gloves != src) return

			boutput(user, "<span class='alert'><B>You smack the [src] with the [W]. It makes a grumpy whirr. I don't think it liked that!</B></span>")
			sleep(5 SECONDS)
			boutput(user, "<span class='alert'><B>The [src] suddenly sucks you inside and devours you. Next time don't go smacking dangerous artifacts with bricks!</B></span>")
			user.implode()

		if(istype(W, /obj/item/plutonium_core/hootonium_core))
			boutput(user, "<span class='alert'><B>The [src] reacts but the core is too big for the slots.</B></span>")
