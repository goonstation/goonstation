#define STATUS_PROCESSING 0
#define STATUS_PROCESSING_BODY 1
#define STATUS_READY 2

/obj/machinery/artifact/food_processor
	name = "artifact food processor"
	associated_datum = /datum/artifact/food_processor

/datum/artifact/food_processor
	associated_object = /obj/machinery/artifact/food_processor
	type_name = "Food Processor"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 350
	validtypes = list("martian","precursor", "wizard", "ancient", "eldritch")
	validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/language)
	activated = 0
	activ_text = "begins to radiate a strange energy field!"
	deact_text = "shuts down, causing the energy field to vanish!"
	react_xray = list(50,20,90,8,"MECHANICAL")
	var/biofuel = 0
	var/biofuel_per_food = 0
	var/processing_speed = 0
	var/food_processor_state = READY

	New()
		..()
		var/biofuel_per_food = rand(0, 10)

	attackby(obj/item/grab/G, mob/user)
		if(src.food_processor_state != STATUS_READY)
			boutput(user, SPAN_ALERT("The artifact is already processing!"))
			return
		if (istype(G, /obj/item/reagent_containers/food) || (istype(G, /obj/item/parts/human_parts)) || istype(G, /obj/item/clothing/head/butt) || istype(G, /obj/item/organ) || istype(G,/obj/item/raw_material/martian))
			user.u_equip(G)
			qdel(G)
			user.visible_message("<b>[user]</b> loads [G] into [src].","You load [G] into [src]")
			src.biofuel += 2
		src.add_fingerprint(user)
		actions.start(new /datum/action/bar/icon/put_in_reclaimer(G.affecting, src, G, 50), user)
		return

	//Effect_touch copied from borgifier.
	effect_touch(var/obj/O, var/mob/living/user)
		if (..())
			return
		if (!user)
			return
		if (src.food_processor_state != STATE_READY)
			return
		if (ishuman(user))
			var/mob/living/carbon/human/humanuser = user
			if(!isalive(user) && user.ghost && user.ghost.mind && user.ghost.mind.get_player()?.dnr)
				O.visible_message(SPAN_ALERT("<b>[O]</b> refuses to process [user.name]!"))
				return
			O.visible_message(SPAN_ALERT("<b>[O]</b> suddenly pulls [user.name] inside[escapable ? "!" : " and slams shut!"]"))
			user.emote("scream")
			user.changeStatus("unconscious", 5 SECONDS)
			user.force_laydown_standup()
			if (!escapable)
				user.set_loc(O)
			else
				user.set_loc(get_turf(O.loc))
			src.food_processor_state = STATE_PROCESSING_BODY
			// keep it truthy to avoid null values due to missing limbs
			var/list/obj/item/parts/convertable_limbs = keep_truthy(list(humanuser.limbs.l_arm, humanuser.limbs.r_arm, humanuser.limbs.l_leg, humanuser.limbs.r_leg))
			//figure out which limbs are already robotic and remove them from the list
			for (var/obj/item/parts/limb in convertable_limbs)
				if (!limb || (limb.kind_of_limb & LIMB_ROBOT))
					convertable_limbs -= limb
			//people with existing robolimbs get converted faster.
			//(loops_per_conversion_step - 1) bit adds some 'buffer time' before any limbs are converted.
			var/loops = (loops_per_conversion_step * (convertable_limbs.len + 1)) + (loops_per_conversion_step - 1)
			while (loops > 0)
				if ((user.loc != O.loc && user.loc != O) || !activated)
					src.food_processor_state = STATUS_READY
					return
				loops--
				//inescapable version slices em up more
				random_brute_damage(humanuser, (escapable ? 10 : 15))
				take_bleeding_damage(humanuser, null, (escapable ? 3 : 4))
				user.changeStatus("stunned", 7 SECONDS)
				playsound(user.loc, pick(work_sounds), 50, 1, -1)
				if (loops % loops_per_conversion_step == 0)
					if (!convertable_limbs.len) //avoid runtiming once all limbs are converted
						continue
					var/obj/item/parts/limb_to_replace = pick(convertable_limbs)
					switch(limb_to_replace.slot)
						if ("l_arm")
							qdel(humanuser.limbs.get_limb("l_arm"))
						if ("r_arm")
							qdel(humanuser.limbs.get_limb("r_arm"))
						if ("l_leg")
							qdel(humanuser.limbs.get_limb("l_leg"))
						if ("r_leg")
							qdel(humanuser.limbs.get_limb("r_leg"))
					convertable_limbs -= limb_to_replace
					humanuser.update_body()
					src.biofuel += 2
				sleep(0.4 SECONDS)

			var/bdna = null // For forensics (Convair880).
			var/btype = null
			if (user.bioHolder.Uid && user.bioHolder.bloodType)
				bdna = user.bioHolder.Uid
				btype = user.bioHolder.bloodType
			var/turf/T = get_turf(user)
			gibs(T, null, bdna, btype)

			ArtifactLogs(user, null, O, "touched", "food processing user", 0) // Added (Convair880).

			user.set_loc(get_turf(O.loc))
			user.death()
			user.ghostize()
			qdel(user)

			//Biofuel per body copied from the enzymatic reclaimer
			var/humanOccupant = (ishuman(user) && !ismonkey(user))
			var/decomp = ishuman(user) ? user:decomp_stage : 0
			src.biofuel += rand(5, 8) * (humanOccupant ? 2 : 1) * ((4.5 - decomp) / 4.5)
			src.food_processor_state = STATE_READY
		else
			return
