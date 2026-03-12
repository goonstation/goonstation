ABSTRACT_TYPE(/obj/item/parts/robot_parts/arm)
/obj/item/parts/robot_parts/arm
	name = "placeholder item (don't use this!)"
	desc = "A metal arm for a cyborg. It won't be able to use as many tools without it!"
	material_amt = ROBOT_LIMB_COST
	tool_flags = TOOL_ASSEMBLY_APPLIER
	max_health = 60
	can_hold_items = 1
	accepts_normal_human_overlays = TRUE
	var/emagged = FALSE //contains: technical debt
	var/add_to_tools = FALSE

	New()
		..()
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY, PROC_REF(assembly_application))
		RegisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP, PROC_REF(assembly_setup))

	disposing()
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_APPLY)
		UnregisterSignal(src, COMSIG_ITEM_ASSEMBLY_ITEM_SETUP)
		. = ..()

	attack(mob/target, mob/user, def_zone, is_special = FALSE, params = null)
		if(!ismob(target))
			return

		src.add_fingerprint(user)

		if(!(user.zone_sel.selecting in list("l_arm","r_arm")) || !ishuman(target))
			return ..()

		if (!surgeryCheck(target,user))
			return ..()

		var/mob/living/carbon/human/H = target

		if(H.limbs.get_limb(user.zone_sel.selecting))
			boutput(user, SPAN_ALERT("[H.name] already has one of those!"))
			return

		if(src.appearanceString == "sturdy" || src.appearanceString == "heavy")
			boutput(user, SPAN_ALERT("That arm is too big to fit on [H]'s body!"))
			return

		attach(H,user)

		return

	can_arm_attach()
		return ..() && !(src.appearanceString == "sturdy" || src.appearanceString == "heavy")

	on_holder_examine()
		if (!isrobot(src.holder)) // probably a human, probably  :p
			return "has [bicon(src)] \an [initial(src.name)] attached as a"
		return

	emag_act(mob/user, obj/item/card/emag/E)
		boutput(user, SPAN_ALERT("You short out the control servos on [src]")) //sneaky emag act
		src.emagged = TRUE

	on_life()
		if (!src.emagged || src.holder.restrained() || prob(60)) //chance to do nothing
			return

		if (prob(50))
			boutput(src.holder, SPAN_ALERT(pick("You hear the servos in your arm make a distressing whining sound!", "Your arm twitches oddly!", "You lose control of your arm for a moment!")))

		if (ishuman(src.holder))
			src.human_emag_effect()
		else if (isrobot(src.holder))
			src.robot_emag_effect()

	get_limb_print()
		return build_id_fingerprint(FORENSIC_CHARS_HEX)

	proc/human_emag_effect()
		var/mob/living/carbon/human/H = src.holder
		var/mob/living/target = H //default to hitting ourselves
		if (prob(80)) //usually look for something else
			var/list/mob/living/targets = list()
			for (var/mob/living/M in view(1, H))
				if (isintangible(M) || M == H)
					continue
				targets |= M
			if (length(targets))
				target = pick(targets)
		//make sure we're using the correct hand
		if ((H.hand == LEFT_HAND && src.slot != "l_arm") || (H.hand == RIGHT_HAND && src.slot != "r_arm"))
			H.swap_hand()

		if (target == H)
			H.set_a_intent(pick(INTENT_HELP, INTENT_DISARM, INTENT_HARM)) //no blocking
		else
			H.set_a_intent(pick(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)) //only grabbing

		logTheThing(LOG_COMBAT, key_name(H), "emagged cyberarm attempts to attack [constructTarget(target)]")
		var/obj/item/equipped = H.equipped()
		if (isgrab(equipped) || equipped?.chokehold)
			if (prob(50))
				equipped.AttackSelf(H)
			else
				H.drop_item(equipped, TRUE)
		else if (equipped)
			H.weapon_attack(target, H.equipped(), can_reach(H, target), list())
		else
			H.hand_attack(target)

	proc/robot_emag_effect()
		var/mob/living/silicon/robot/robot = src.holder
		var/robo_slot = src.slot == "l_arm" ? 1 : 3
		var/last_active = robot.module_states.Find(robot.module_active)
		robot.uneq_slot(robo_slot)
		var/obj/item/chosen_tool = pick(robot.module?.tools)
		if (!chosen_tool)
			return
		robot.equip_slot(robo_slot, chosen_tool)
		if (last_active)
			robot.swap_hand(last_active)

/// ----------- Trigger/Applier/Target-Assembly-Related Procs -----------

	assembly_get_part_help_message(var/dist, var/mob/shown_user, var/obj/item/assembly/parent_assembly)
		if(!parent_assembly.target)
			return " You can add a pie onto this assembly in order to modify it further."

	proc/assembly_setup(var/manipulated_arm, var/obj/item/assembly/parent_assembly, var/mob/user, var/is_build_in)
		//since we have different robot arms (including left and right versions)
		parent_assembly.applier_icon_prefix = "robot_arm"
		if (!parent_assembly.target)
			// trigger-robotarm-Assembly + pie -> trigger-robotarm-pie-assembly
			parent_assembly.AddComponent(/datum/component/assembly, list(/obj/item/reagent_containers/food/snacks/pie), TYPE_PROC_REF(/obj/item/assembly, add_target_item), TRUE)

	proc/assembly_application(var/manipulated_arm, var/obj/item/assembly/parent_assembly, var/obj/assembly_target)
		var/mob/mob_target = null
		var/turf/current_turf = get_turf(src)
		for(var/mob/iterated_mob in viewers(6, current_turf))
			//the first mob within the return of view() should also be the nearest
			if (!isintangible(iterated_mob))
				mob_target = iterated_mob
				break
		if(!assembly_target)
			//if there is no target, we don't do anything. Else, we give them the finger.
			if(mob_target)
				mob_target.visible_message(SPAN_ALERT("<b>[parent_assembly.name]'s [src] flips [mob_target] off! How rude...</b>"),\
				SPAN_ALERT("<b>[parent_assembly.name]'s [src] flips you off! How rude...</b>"))
		else
			var/atom/throw_target = mob_target
			var/obj/item/pie_to_throw = parent_assembly.target
			//if no target is found, we throw at a random turf which is 6 tiles away instead
			if(!throw_target)
				throw_target = get_ranged_target_turf(current_turf, pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST), 6 * 32)
			else
				throw_target.visible_message(SPAN_ALERT("<b>[parent_assembly.name]'s [src] launches [pie_to_throw] at [throw_target]!</b>"),\
				SPAN_ALERT("<b>[parent_assembly.name]'s [src] launches [pie_to_throw] at you!</b>"))
			parent_assembly.remove_until_minimum_components()
			//after the pie is removed from the assembly and positioned at the ground, lets launch it!
			if(mob_target && get_turf(mob_target) == current_turf)
				//if the pie and the person is on the same tile, we gotta make them meet directly
				var/datum/thrown_thing/simulated_throw = new
				simulated_throw.user = parent_assembly.last_armer
				simulated_throw.thing = pie_to_throw
				pie_to_throw.throw_impact(throw_target, simulated_throw)
			else
				pie_to_throw.throw_at(throw_target, 6, 2, thrown_by = parent_assembly.last_armer)

/// ----------- ---------------------------------------------- -----------

ABSTRACT_TYPE(/obj/item/parts/robot_parts/arm/left)
/obj/item/parts/robot_parts/arm/left
	name = "cyborg left arm"
	slot = "l_arm"
	icon_state_base = "l_arm"
	icon_state = "l_arm-generic"
	handlistPart = "armL-generic"

/obj/item/parts/robot_parts/arm/left/standard
	name = "standard cyborg left arm"

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/sheet))
			var/obj/item/sheet/M = W
			src.reinforce(M, user, /obj/item/parts/robot_parts/arm/left/sturdy, FALSE)
		else ..()

/obj/item/parts/robot_parts/arm/left/sturdy
	name = "sturdy cyborg left arm"
	appearanceString = "sturdy"
	icon_state = "l_arm-sturdy"
	material_amt = ROBOT_LIMB_COST + ROBOT_STURDY_COST
	max_health = 115
	weight = 0.2
	robot_movement_modifier = /datum/movement_modifier/robot_part/sturdy_arm_left
	kind_of_limb = (LIMB_ROBOT | LIMB_HEAVY)

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/sheet))
			var/obj/item/sheet/M = W
			src.reinforce(M, user, /obj/item/parts/robot_parts/arm/left/heavy, TRUE)
		else ..()

/obj/item/parts/robot_parts/arm/left/heavy
	name = "heavy cyborg left arm"
	appearanceString = "heavy"
	icon_state = "l_arm-heavy"
	material_amt = ROBOT_LIMB_COST + ROBOT_HEAVY_COST
	max_health = 175
	weight = 0.4
	robot_movement_modifier = /datum/movement_modifier/robot_part/heavy_arm_left
	kind_of_limb = (LIMB_ROBOT | LIMB_HEAVIER)

/obj/item/parts/robot_parts/arm/left/light
	name = "light cyborg left arm"
	appearanceString = "light"
	icon_state = "l_arm-light"
	material_amt = ROBOT_LIMB_COST * ROBOT_LIGHT_COST_MOD
	max_health = 25
	handlistPart = "armL-light"
	robot_movement_modifier = /datum/movement_modifier/robot_part/light_arm_left
	kind_of_limb = (LIMB_ROBOT | LIMB_LIGHT)
	breaks_cuffs = FALSE

ABSTRACT_TYPE(/obj/item/parts/robot_parts/arm/right)
/obj/item/parts/robot_parts/arm/right
	name = "cyborg right arm"
	icon_state = "r_arm"
	slot = "r_arm"
	icon_state_base = "r_arm"
	icon_state = "r_arm-generic"
	handlistPart = "armR-generic"


/obj/item/parts/robot_parts/arm/right/standard
	name = "standard cyborg right arm"
	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/sheet))
			var/obj/item/sheet/M = W
			src.reinforce(M, user, /obj/item/parts/robot_parts/arm/right/sturdy, FALSE)
		else ..()

/obj/item/parts/robot_parts/arm/right/sturdy
	name = "sturdy cyborg right arm"
	appearanceString = "sturdy"
	icon_state = "r_arm-sturdy"
	material_amt = ROBOT_LIMB_COST + ROBOT_STURDY_COST
	max_health = 115
	weight = 0.2
	robot_movement_modifier = /datum/movement_modifier/robot_part/sturdy_arm_right
	kind_of_limb = (LIMB_ROBOT | LIMB_HEAVY)

	attackby(obj/item/W, mob/user)
		if(istype(W,/obj/item/sheet))
			var/obj/item/sheet/M = W
			src.reinforce(M, user, /obj/item/parts/robot_parts/arm/right/heavy, TRUE)
		else ..()

/obj/item/parts/robot_parts/arm/right/heavy
	name = "heavy cyborg right arm"
	appearanceString = "heavy"
	icon_state = "r_arm-heavy"
	material_amt = ROBOT_LIMB_COST + ROBOT_HEAVY_COST
	max_health = 175
	weight = 0.4
	robot_movement_modifier = /datum/movement_modifier/robot_part/heavy_arm_right
	kind_of_limb = (LIMB_ROBOT | LIMB_HEAVIER)

/obj/item/parts/robot_parts/arm/right/light
	name = "light cyborg right arm"
	appearanceString = "light"
	icon_state = "r_arm-light"
	material_amt = ROBOT_LIMB_COST * ROBOT_LIGHT_COST_MOD
	max_health = 25
	handlistPart = "armR-light"
	robot_movement_modifier = /datum/movement_modifier/robot_part/light_arm_right
	kind_of_limb = (LIMB_ROBOT | LIMB_LIGHT)
	breaks_cuffs = FALSE


// ancient robot stuff

///Returns TRUE on successful clamping
/atom/movable/proc/clamp_act(mob/clamper, obj/item/clamp)
	return FALSE

proc/do_clamp(atom/movable/clamped, mob/clamper, obj/item/clamp)
	if (ON_COOLDOWN(clamper, "clamp", 1 SECOND))
		return
	if (isturf(clamped))
		return
	APPLY_ATOM_PROPERTY(clamper, PROP_MOB_CANTMOVE, ref(clamp))
	APPLY_ATOM_PROPERTY(clamped, PROP_MOB_CANTMOVE, ref(clamp))
	playsound(clamper.loc, 'sound/machines/hydraulic.ogg', 40, 1)
	clamper.visible_message(SPAN_ALERT("[clamper] CLAMPS [clamped] with [his_or_her(clamper)] [clamp.name]!"))
	sleep(1 SECOND)
	if (!can_reach(clamper, clamped))
		REMOVE_ATOM_PROPERTY(clamper, PROP_MOB_CANTMOVE, ref(clamp))
		REMOVE_ATOM_PROPERTY(clamped, PROP_MOB_CANTMOVE, ref(clamp))
		return

	if (!clamped.clamp_act(clamper, clamp))
		clamper.visible_message(SPAN_ALERT("...but [clamped] remains unclamped."))

	REMOVE_ATOM_PROPERTY(clamper, PROP_MOB_CANTMOVE, ref(clamp))
	REMOVE_ATOM_PROPERTY(clamped, PROP_MOB_CANTMOVE, ref(clamp))

/obj/item/parts/robot_parts/arm/right/ancient
	name = "ancient right arm"
	desc = "The right arm of an ancient utility construct."
	icon_state = "r_arm-ancient"
	appearanceString = "ancient"
	max_health = 200
	weight = 0.4
	handlistPart = "armR-sturdy"
	robot_movement_modifier = /datum/movement_modifier/robot_part/sturdy_arm_right

	stonecutter
		name = "ancient stonecutter arm"
		desc = "The cutting arm of an ancient stonemason construct."
		icon_state = "r_arm-ancient2"
		appearanceString = "ancient2"
		max_health = 150
		weight = 0.2
		handlistPart = "armR-light"
		robot_movement_modifier = /datum/movement_modifier/robot_part/light_arm_right

	actuator
		name = "ancient actuator arm"
		desc = "A massive clamping arm from an ancient lifter construct."
		icon_state = "r_arm-ancient3"
		appearanceString = "ancient3"
		max_health = 350
		weight = 0.5
		handlistPart = "armR-heavy"
		add_to_tools = TRUE
		robot_movement_modifier = /datum/movement_modifier/robot_part/heavy_arm_right

		New()
			. = ..()
			RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(clamp_proxy))

		proc/clamp_proxy(_, target, user)
			if (issilicon(user) && !(target in user))
				do_clamp(target, user, src)
				return TRUE

/obj/item/parts/robot_parts/arm/left/ancient
	name = "ancient left arm"
	desc = "The left arm of an ancient silicon construct."
	icon_state = "l_arm-ancient"
	appearanceString = "ancient"
	max_health = 200
	weight = 0.4
	handlistPart = "armL-sturdy"
	robot_movement_modifier = /datum/movement_modifier/robot_part/sturdy_arm_left

	stonecutter
		name = "ancient stonecutter arm"
		desc = "The cutting arm of an ancient stonemason construct."
		icon_state = "l_arm-ancient2"
		appearanceString = "ancient2"
		max_health = 150
		weight = 0.2
		handlistPart = "armL-light"
		robot_movement_modifier = /datum/movement_modifier/robot_part/light_arm_left

	actuator
		name = "ancient actuator arm"
		desc = "A massive clamping arm from an ancient lifter construct."
		icon_state = "l_arm-ancient3"
		appearanceString = "ancient3"
		max_health = 350
		weight = 0.5
		handlistPart = "armL-heavy"
		add_to_tools = TRUE
		robot_movement_modifier = /datum/movement_modifier/robot_part/heavy_arm_left

		New()
			. = ..()
			RegisterSignal(src, COMSIG_ITEM_ATTACKBY_PRE, PROC_REF(clamp_proxy))

		proc/clamp_proxy(_, target, user)
			if (issilicon(user) && !(target in user))
				do_clamp(target, user, src)
				return TRUE
