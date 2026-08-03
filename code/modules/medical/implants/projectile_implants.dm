/obj/item/implant/projectile
	name = "bullet"
	icon = 'icons/obj/scrap.dmi'
	icon_state = "bullet"
	desc = "A spent bullet."
	scan_category = IMPLANT_SCAN_CATEGORY_NOT_SHOWN
	var/bleed_time = 60
	var/bleed_timer = 0
	var/leaves_wound = TRUE

	New()
		..()
		implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "bullet_wound-[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

	bullet_357
		name = ".357 round"
		desc = "A powerful revolver bullet, likely of criminal origin."

	bullet_357AP
		name = ".357 AP round"
		desc = "A highly illegal armor-piercing variant of the common .357 round."

	bullet_38
		name = ".38 round"
		desc = "An outdated police-issue bullet. Some anachronistic detectives still like to use these, for style."

	bullet_45
		name = ".45 round"
		icon_state = "bulletround"
		desc = "An outdated army-issue bullet. Mainly used by war reenactors and space cowboys."

	bullet_38AP
		name = ".38 AP round"
		desc = "A more powerful armor-piercing .38 round. Huh. Aren't these illegal?"

	bullet_38ricochet
		name = ".38 ricochet round"
		desc = "A bouncy variant of the .38 round. Huh. Aren't these illegal?"

	bullet_9mm
		name = "9mm round"
		desc = "An extremely common bullet fired by a myriad of different cartridges."
	bullet_455
		name = ".455 round"
		desc = "A powerful, old-timey revolver bullet, likely of criminal origin."
	ninemmplastic
		name = "9mm Plastic round"
		icon_state = "bulletplastic"
		desc = "A small, sublethal plastic projectile."
		leaves_wound = FALSE

		New()
			..()
			implant_overlay = null

	bullet_308
		name = "Rifle Round" // this is used by basically every rifle in the game, ignore the "308" path
		icon_state = "bulletbig"
		desc = "A large bullet from a rifle cartridge."

	bullet_22
		name = ".22 round"
		desc = "A cheap, small bullet, often used for recreational shooting and small-game hunting."

	bullet_22HP
		name = ".22 hollow point round"
		icon_state = "bulletexpanded"
		desc = "A small calibre hollow point bullet for use against unarmored targets. Hang on, aren't these a war crime?"

	bullet_41
		name = ".41 round"
		icon_state = "bulletexpanded"
		desc = ".41? What the heck? Who even uses these anymore?"

	bullet_12ga
		name = "buckshot"
		icon_state = "buckshot"
		desc = "A collection of buckshot rounds, a very commonly used load for shotguns."

		New()
			..()
			implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "buckshot_wound-[rand(0, 1)]", layer = MOB_EFFECT_LAYER)
		bird
			name = "birdshot"
			desc = "A large collection of birdshot rounds, a less-lethal load for shotguns."

	staple
		name = "staple"
		icon_state = "staple"
		desc = "Well that's not very nice."
		leaves_wound = FALSE

		New()
			..()
			implant_overlay = null

	stinger_ball
		name = "rubber ball"
		icon_state = "rubberball"
		desc = "A rubber ball from a stinger grenade. Ouch."

	grenade_fragment
		name = "grenade fragment"
		icon_state = "grenadefragment"
		desc = "A sharp and twisted grenade fragment. Comes from your typical frag grenade."

	shrapnel
		name = "shrapnel"
		icon = 'icons/obj/scrap.dmi'
		desc = "A bunch of jagged shards of metal."
		icon_state = "2metal2"
		leaves_wound = FALSE

		New()
			..()
			implant_overlay = null

		radioactive
			name = "radioactive shrapnel"

			New()
				..()
				src.AddComponent(/datum/component/radioactive, 50, FALSE, FALSE, 0)

	glass_shard
		name = "shrapnel"
		icon = 'icons/obj/scrap.dmi'
		desc = "A shattered piece of glass shrapnel. Ow."
		icon_state = "glass_shrapnel"
		leaves_wound = FALSE

		New()
			..()
			implant_overlay = null

	ice_feather
		name = "ice feather"
		desc = "A feather made of ice, sharp on all edges."
		icon = 'icons/obj/items/items.dmi'
		icon_state = "ice_feather"
		burn_possible = FALSE
		default_material = "ice"
		mat_changename = FALSE
		mat_changedesc = FALSE
		mat_changeappearance = FALSE

	body_visible
		bleed_time = 0
		leaves_wound = FALSE
		var/barbed = FALSE
		var/pull_out_name = ""

		proc/on_pull_out(mob/living/puller)
			return

		on_life(mob/M, mult)
			. = ..()
			if (src.reagents?.total_volume)
				src.reagents.trans_to(owner, 1 * mult)

		blowdart
			name = "blowdart"
			desc = "a sharp little dart with a little poison reservoir."
			icon_state = "blowdart"
			leaves_wound = FALSE
			barbed = TRUE

			New()
				..()
				implant_overlay = null

		dart
			name = "dart"
			pull_out_name = "dart"
			icon = 'icons/obj/chemical.dmi'
			desc = "A small hollow dart."
			icon_state = "syringeproj"

			tranq_dart_sleepy
				name = "spent tranquilizer dart"
				desc = "A small tranquilizer dart, emptied of its contents. Useful for putting animals (or people!) to sleep."
				icon_state = "tranqdart_red"

				New()
					..()
					implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "tranqdart_red_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

			tranq_dart_sleepy_barbed
				name = "barbed tranquilizer dart"
				desc = "An empty tranquilizer dart, with a barbed tip. It was likely loaded with some bad stuff..."
				icon_state = "tranqdart_red_barbed"
				barbed = TRUE

				New()
					..()
					implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "tranqdart_red_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

			tranq_dart_mutadone
				name = "spent tranquilizer dart"
				desc = "A small tranquilizer dart, emptied of its contents. This one is specialized for removing genetic mutations."
				icon_state = "tranqdart_green"

				New()
					..()
					implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "tranqdart_green_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

		syringe
			name = "spent syringe round"
			pull_out_name = "syringe"
			desc = "A syringe round, of the type that is fired from a syringe gun. Whatever was inside is completely gone."
			icon = 'icons/obj/chemical.dmi'
			icon_state = "syringeproj"

			New()
				..()
				implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "syringe_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

			implanted(var/mob/receiving_mob, var/mob/implanting_mob)
				..()
				RegisterSignal(receiving_mob, COMSIG_MOB_EX_ACT, PROC_REF(on_explosion_reaction))

			on_remove(var/mob/losing_mob)
				..()
				UnregisterSignal(losing_mob, COMSIG_MOB_EX_ACT)

			proc/on_explosion_reaction(var/mob/exploding_mob, var/severity)
				if (ishuman(exploding_mob))
					var/mob/living/carbon/human/human_owner = exploding_mob
					SPAWN(0.1 SECONDS)
						src.on_remove(human_owner)
						human_owner.implant.Remove(src)
						qdel(src)

			syringe_barbed
				name = "barbed syringe round"
				desc = "An empty syringe round, of the type that is fired from a syringe gun. It has a barbed tip. Nasty!"
				icon_state = "syringeproj_barbed"
				barbed = TRUE

		janktanktwo
			name = "spent JankTank II"
			pull_out_name = "syringe"
			desc = "A large syringe ripped straight out of some poor, presumably dead gang member!"
			icon = 'icons/obj/syringe.dmi'
			icon_state = "dna_scrambler_2"
			var/obj/item/tool/janktanktwo/syringe
			var/full = TRUE

			New()
				..()
				implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "syringe_stick_1", layer = MOB_EFFECT_LAYER)
			implanted(mob/M, mob/I)
				..()
				if (!full)
					return
				SPAWN(JANKTANK2_PAUSE_TIME - 0.5 SECONDS)
					playsound(M.loc, 'sound/items/hypo.ogg', 50, 0)

				SPAWN(JANKTANK2_PAUSE_TIME)
					if (!ishuman(M))
						return
					full = FALSE
					icon_state = "dna_scrambler_3"
					desc = "A large, empty syringe. Whatever awfulness it contained is probably in somebody's heart. Eugh."
					if (!src.owner)
						src.visible_message("<span class='alert'>[src] sprays its' volatile contents everywhere, [prob(10) ? "it smells like bacon? <b><i>WHY?!?</i></b>" : "gross!"]</span>")
						return

					syringe.do_heal(src.owner)
			proc/set_owner(obj/item/tool/janktanktwo/injector)
				src.syringe = injector

	flintlock
		name= "flintlock round"
		desc = "A rather imperfect round ball. It looks very old indeed."
		icon_state = "flintlockbullet"

	bullet_50
		name = ".50AE round"
		icon_state = "bulletbig"
		desc = "Ouch."

	rakshasa
		name = "\improper Rakshasa round"
		desc = "A weird flechette-like projectile."
		icon_state = "blowdart"

/obj/item/implant/projectile/implanted(mob/living/carbon/C, mob/I, bleed_time)
	if (!istype(C) || !isnull(I)) //Don't make non-organics bleed and don't act like a launched bullet if some doofus is just injecting it somehow.
		return

	if (implant_overlay)
		if (ishuman(C) && leaves_wound)
			var/datum/reagent/contained_blood = reagents_cache[C.blood_id]
			implant_overlay.color = rgb(contained_blood.fluid_r, contained_blood.fluid_g, contained_blood.fluid_b, contained_blood.transparency)

	..()

	if (!bleed_time)
		return
	src.bleed_time = bleed_time
	src.blood_DNA = src.owner.bioHolder.Uid

	for (var/obj/item/implant/projectile/P in C)
		if (P.bleed_timer)
			P.bleed_timer = max(src.bleed_time, P.bleed_timer)
			return

	src.bleed_timer = src.bleed_time
	SPAWN(0.5 SECONDS)
//		boutput(C, SPAN_ALERT("You start bleeding!")) // the blood system takes care of this bit now
		src.bleed_loop()

/obj/item/implant/projectile/proc/bleed_loop() // okay it doesn't actually cause bleeding now but um w/e
	if (src.bleed_timer-- < 0)
		return

	if (!iscarbon(src.owner) || (src.loc != src.owner))
		src.owner = null
		return

	var/mob/living/carbon/C = src.owner

	if (isdead(C))
		src.owner = null
		return

	if (istype(C.loc, /turf/simulated))
		if(prob(35))
			random_brute_damage(C, 1)
		if(prob(1))
			C.emote("faint")
		if(prob(4))
			C.emote(pick("pale", "shiver"))
		if(prob(4))
			boutput(C, SPAN_ALERT("You feel a [pick("sharp", "stabbing", "startling", "worrying")] pain in your chest![pick("", " It feels like there's something lodged in there!", " There's gotta be something stuck in there!", " You feel something shift around painfully!")]"))
		//werewolf silver implants handling
		if (prob(60) && iswerewolf(C) && istype(src:material, /datum/material/metal/silver))
			random_burn_damage(C, rand(5,10))
			C.take_toxin_damage(rand(1,3))
			C.stamina -= 30
			boutput(C, SPAN_ALERT("You feel a [pick("searing", "hot", "burning")] pain in your chest![pick("", "There's gotta be silver in there!", )]"))
	SPAWN(rand(40,70))
		src.bleed_loop()
	return
/* =============================================================== */
/* ------------------------- Throwing Darts ---------------------- */
/* =============================================================== */

/obj/item/implant/projectile/body_visible/dart/bardart
	name = "dart"
	desc = "An object of d'art."
	w_class = W_CLASS_TINY
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dart"
	throw_spin = 0

	New()
		..()
		implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "dart_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

	throw_impact(atom/hit_thing, datum/thrown_thing/thr)
		..()
		if (istype(hit_thing, /obj/item/reagent_containers/balloon))
			var/obj/item/reagent_containers/balloon/balloon = hit_thing
			balloon.smash()

		else if (ishuman(hit_thing) && prob(5))
			var/mob/living/carbon/human/H = hit_thing
			H.implant.Add(src)
			src.visible_message(SPAN_ALERT("[src] gets embedded in [H]!"))
			playsound(src.loc, 'sound/impact_sounds/Flesh_Cut_1.ogg', 100, 1)
			random_brute_damage(H, 1)
			src.implanted(H)

	attack_hand(mob/user)
		src.pixel_x = 0
		src.pixel_y = 0
		..()

/obj/item/implant/projectile/body_visible/dart/lawndart
	name = "lawn dart"
	desc = "An oversized plastic dart with a metal spike at the tip. Fun for the whole family!"
	w_class = W_CLASS_TINY
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "lawndart"
	throw_spin = 0
	throw_speed = 3

	New()
		..()
		implant_overlay = image(icon = 'icons/mob/human.dmi', icon_state = "dart_stick_[rand(0, 4)]", layer = MOB_EFFECT_LAYER)

	throw_impact(atom/hit_thing, datum/thrown_thing/thr)
		..()
		if (ishuman(hit_thing))
			var/mob/living/carbon/human/H = hit_thing
			H.implant.Add(src)
			src.visible_message(SPAN_ALERT("[src] gets embedded in [H]!"))
			playsound(src.loc, 'sound/impact_sounds/Flesh_Cut_1.ogg', 100, 1)
			H.changeStatus("knockdown", 2 SECONDS)
			random_brute_damage(H, 20)//if it can get in you, it probably doesn't give a damn about your armor
			take_bleeding_damage(H, null, 10, DAMAGE_CUT)
			src.implanted(H)
