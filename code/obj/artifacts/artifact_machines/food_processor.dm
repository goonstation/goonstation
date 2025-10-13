#define STATUS_PROCESSING 0
#define STATUS_PROCESSING_BODY 1
#define STATUS_READY 2

/obj/machinery/artifact/food_processor
	name = "artifact food processor"
	associated_datum = /datum/artifact/food_processor

	ArtifactHitWith(obj/item/I, mob/user)
		var/datum/artifact/food_processor/artifact = src.artifact
		if(artifact.food_processor_state != STATUS_READY)
			boutput(user, SPAN_ALERT("The artifact is already processing!"))
			return
		if (istype(I, /obj/item/reagent_containers/food) || (istype(I, /obj/item/parts/human_parts)) || istype(I, /obj/item/clothing/head/butt) || istype(I, /obj/item/organ) || istype(I,/obj/item/raw_material/martian))
			user.u_equip(I)
			qdel(I)
			user.visible_message("<b>[user]</b> loads [I] into [src].","You load [I] into [src]")
			artifact.biomatter += 2
			artifact.spawn_food(src)
		return

/datum/artifact/food_processor
	associated_object = /obj/machinery/artifact/food_processor
	type_name = "Food Processor"
	type_size = ARTIFACT_SIZE_LARGE
	rarity_weight = 350
	validtypes = list("martian","precursor", "wizard", "ancient", "eldritch")
	validtriggers = list(/datum/artifact_trigger/carbon_touch)
	//validtriggers = list(/datum/artifact_trigger/force,/datum/artifact_trigger/electric,/datum/artifact_trigger/heat,/datum/artifact_trigger/radiation,/datum/artifact_trigger/carbon_touch, /datum/artifact_trigger/language)
	activated = 0
	activ_text = "begins to make a grinding noise!"
	deact_text = "shuts down, going quiet."
	react_xray = list(50,20,90,8,"MECHANICAL")
	var/biomatter = 0
	var/biomatter_per_food = 0
	var/processing_speed = 0
	var/food_processor_state = STATUS_READY
	var/escapable = TRUE
	var/loops_per_consumption_step
	var/list/work_sounds = list('sound/impact_sounds/Flesh_Stab_1.ogg','sound/impact_sounds/Metal_Clang_1.ogg','sound/effects/airbridge_dpl.ogg','sound/impact_sounds/Slimy_Splat_1.ogg','sound/impact_sounds/Flesh_Tear_2.ogg','sound/impact_sounds/Slimy_Hit_3.ogg')

	New()
		..()
		src.biomatter_per_food = rand(0, 10)
		src.loops_per_consumption_step = src.escapable ? rand(4, 7) : rand(2, 4)

	//Effect_touch copied from borgifier.
	effect_touch(var/obj/O, var/mob/living/user)
		if (..())
			return
		if (!user)
			return
		if (src.food_processor_state != STATUS_READY)
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
			src.food_processor_state = STATUS_PROCESSING_BODY
			// keep it truthy to avoid null values due to missing limbs
			var/list/obj/item/parts/convertable_limbs = keep_truthy(list(humanuser.limbs.l_arm, humanuser.limbs.r_arm, humanuser.limbs.l_leg, humanuser.limbs.r_leg))
			//figure out which limbs are already robotic and remove them from the list
			for (var/obj/item/parts/limb in convertable_limbs)
				if (!limb || (limb.kind_of_limb & LIMB_ROBOT))
					convertable_limbs -= limb
			//people with existing robolimbs get converted faster.
			//(loops_per_consumption_step - 1) bit adds some 'buffer time' before any limbs are converted.
			var/loops = (loops_per_consumption_step * (convertable_limbs.len + 1)) + (loops_per_consumption_step - 1)
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
				if (loops % loops_per_consumption_step == 0)
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
					src.biomatter += 2
					spawn_food(O)
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
			src.biomatter += rand(5, 8) * (humanOccupant ? 2 : 1) * ((4.5 - decomp) / 4.5)
			src.food_processor_state = STATUS_READY

			spawn_food(O)
		else
			return

	proc/spawn_food(var/obj/O)
		while(src.biomatter > src.biomatter_per_food)
			var/food = pick(concrete_typesof(/obj/item/reagent_containers/food/snacks))
			new food(O.loc)
			src.biomatter -= src.biomatter_per_food

#undef STATUS_PROCESSING
#undef STATUS_PROCESSING_BODY
#undef STATUS_READY
