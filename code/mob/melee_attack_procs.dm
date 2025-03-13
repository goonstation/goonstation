// Contains:
// - Help procs
// - Grab procs
// - Disarm procs
// - Harm procs
// - Helper procs:
// -- attackResult datum [This is where the magic happens.]
// -- Targeting checks
// -- Calculate damage
// -- Target damage modifiers
// -- After attack

///////////////////////////////////////////////// Help intent //////////////////////////////////////////////

/mob/proc/do_help(var/mob/living/M)
	if (!istype(M))
		return
	src.lastattacked = get_weakref(M)
	if (src != M && M.getStatusDuration("burning")) //help others put out fires!!
		src.help_put_out_fire(M)
	else if (src == M && src.getStatusDuration("burning"))
		M.resist()
	else if (src != M && M.hasStatus("paralysis")) // we "dead"
		src.visible_message(SPAN_ALERT("<B>[src] tries to perform CPR, but it's too late for [M]!</B>"))
		return
	//If we use an empty hand on a cut up person, we might wanna rip out their organs by hand
	else if (surgeryCheck(M, src) && M.organHolder?.chest?.op_stage >= 2 && ishuman(src))
		if (M.organHolder.build_region_buttons())
			src.showContextActions(M.organHolder.contexts, M, M.organHolder.contextLayout)
			return
	else if ((M.health <= 0 || M.find_ailment_by_type(/datum/ailment/malady/flatline)) && src.health >= -75.0)
		if (src == M && src.is_bleeding())
			src.staunch_bleeding(M) // if they've got SOMETHING to do let's not just harass them for trying to do CPR on themselves
		else if (ishuman(M))
			src.administer_CPR(M)
		else
			src.visible_message(SPAN_NOTICE("[src] shakes [M], trying to wake [him_or_her(M)] up!"))
			hit_twitch(M)
	else if (M.is_bleeding())
		src.staunch_bleeding(M)
	else if (src.health > 0)
		src.shake_awake(M)

/mob/proc/help_put_out_fire(var/mob/living/M)
	playsound(M.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, 0 , 0.7)
	src.visible_message(SPAN_NOTICE("[src] pats down [M] wildly, trying to put out the fire!"))

	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/clothing/gloves/G = H.gloves
		if ((G && G.hasProperty("heatprot") && (G.getProperty("heatprot") >= 7)) || src.is_heat_resistant())
			M.update_burning(-2.5)
			if (src.is_heat_resistant())
				boutput(H, SPAN_NOTICE("Being fire resistant protects you from the flames!"))
			else
				boutput(H, SPAN_NOTICE("Your [G] protect you from the flames!"))
		else
			M.update_burning(-1.2)
			H.TakeDamage(prob(50) ? "l_arm" : "r_arm", 0, rand(1,2))
			playsound(src, 'sound/impact_sounds/burn_sizzle.ogg', 30, TRUE)
			boutput(src, SPAN_ALERT("Your hands burn from patting the flames!"))
	else
		M.update_burning(-1.2)
		src.TakeDamage("All", 0, rand(1,2))
		playsound(src, 'sound/impact_sounds/burn_sizzle.ogg', 30, TRUE)
		boutput(src, SPAN_ALERT("Your hands burn from patting the flames!"))


/mob/proc/shake_awake(var/mob/living/target)
	if (!src || !target)
		return 0

	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		if (H)
			H.add_fingerprint(src) // Just put 'em on the mob itself, like pulling does. Simplifies forensic analysis a bit (Convair880).

	target.sleeping = 0
	target.delStatus("resting")

	target.changeStatus("stunned", -5 SECONDS)
	target.changeStatus("unconscious", -5 SECONDS)
	target.changeStatus("knockdown", -5 SECONDS)

	playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
	if (src == target)
		var/mob/living/M = src

		var/obj/item/implant/projectile/body_visible/P = locate(/obj/item/implant/projectile/body_visible) in M.implant

		if (P)
			if (P.barbed == FALSE)
				SETUP_GENERIC_ACTIONBAR(src, target, 1 SECOND, /mob/living/proc/pull_out_implant, list(target, P), P.icon, P.icon_state, \
					src.visible_message(SPAN_COMBAT("<b>[src] pulls a [P.pull_out_name] out of [himself_or_herself(src)]!</B>")), \
					INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)
			else
				src.visible_message(SPAN_COMBAT("<b>[src] tries to pull a [P.pull_out_name] out of [himself_or_herself(src)], but it's stuck in!</B>"))
			return

		var/obj/stool/S = (locate(/obj/stool) in src.loc)
		if (S)
			S.buckle_in(src,src)
		if(src.hasStatus("shivering"))
			src.visible_message(SPAN_ALERT("<B>[src] shakes [himself_or_herself(src)], trying to warm up!</B>"))
			src.changeStatus("shivering", -1 SECONDS)
		else if(istype(src.wear_mask,/obj/item/clothing/mask/moustache))
			src.visible_message(SPAN_ALERT("<B>[src] twirls [his_or_her(src)] moustache and laughs [pick("diabolically","madly","evilly","strangely","scarily","awkwardly","excitedly","hauntingly","ominously","nonchalantly","gloriously","hairily")]!</B>"))
		else if(istype(src.wear_mask,/obj/item/clothing/mask/clown_hat))
			var/obj/item/clothing/mask/clown_hat/mask = src.wear_mask
			mask.honk_nose(src)
		else
			var/item = src.get_random_equipped_thing_name()
			if (item)
				var/v = pick("tidies","adjusts","brushes off", "flicks a piece of lint off", "tousles", "fixes", "readjusts","fusses with", "sweeps off")
				src.visible_message(SPAN_NOTICE("[src] [v] [his_or_her(src)] [item]!"))
			else
				src.visible_message(SPAN_NOTICE("[src] pats [himself_or_herself(src)] on the back. Feel better, [src]."))

	else
		var/mob/living/M = target

		var/obj/item/implant/projectile/body_visible/P = locate(/obj/item/implant/projectile/body_visible) in M.implant

		if (P)
			if (P.barbed == FALSE)
				SETUP_GENERIC_ACTIONBAR(src, target, 1 SECOND, /mob/living/proc/pull_out_implant, list(src, P), P.icon, P.icon_state, \
					src.visible_message(SPAN_COMBAT("<b>[src] pulls a [P.pull_out_name] out of [target]!</B>")), \
					INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION | INTERRUPT_MOVE)
			else
				src.visible_message(SPAN_COMBAT("<b>[src] tries to pull a [P.pull_out_name] out of [target], but it's stuck in!</B>"))
			return

		if (target.lying)
			src.visible_message(SPAN_NOTICE("[src] shakes [target], trying to wake [him_or_her(target)] up!"))
		else if(target.hasStatus("shivering"))
			src.visible_message(SPAN_ALERT("<B>[src] shakes [target], trying to warm [him_or_her(target)] up!</B>"))
			target.changeStatus("shivering", -2 SECONDS)
		else
			if (ishuman(target) && ishuman(src))
				var/mob/living/carbon/human/Z = src
				var/mob/living/carbon/human/X = target

				if (Z.zone_sel && Z.zone_sel.selecting == "head")
					var/obj/item/clothing/head/sunhat/hat = X.head
					if(istype(hat) && hat.uses)
						src.visible_message(SPAN_ALERT("[src] tries to pat [target] on the head, but gets shocked by [target]'s hat!"))
						elecflash(target)

						hat.uses = max(0, hat.uses - 1)
						if (hat.uses < 1)
							X.head.icon_state = splittext(hat.icon_state,"-")[1]
							X.head.item_state = splittext(hat.item_state,"-")[1]
							X.update_clothing()

						if (hat.uses <= 0)
							X.show_text("The sunhat is no longer electrically charged.", "red")
						else
							X.show_text("The stunhat has [hat.uses] charges left!", "red")


						src.do_disorient(280, knockdown = 80, stunned = 40, disorient = 160)
						src.stuttering = max(target.stuttering,30)
					else
						src.visible_message(SPAN_NOTICE("[src] gently pats [target] on the head."))
					return

			if (ismobcritter(target))
				var/mob/living/critter/C = target
				C.on_pet(src)
			else
				src.visible_message(SPAN_NOTICE("[src] shakes [target], trying to grab [his_or_her(target)] attention!"))
	hit_twitch(target)

/mob/living/proc/pull_out_implant(var/mob/living/user, var/obj/item/implant/projectile/body_visible/dart)
	dart.on_remove(src)
	dart.on_pull_out(user)
	src.implant.Remove(dart)
	if(!QDELETED(dart)) //some implants will delete themselves on removal
		user.put_in_hand_or_drop(dart)

/mob/proc/administer_CPR(var/mob/living/carbon/human/target)
	boutput(src, SPAN_ALERT("You have no idea how to perform CPR."))
	return

/mob/living/administer_CPR(var/mob/living/target)
	if (!src || !target)
		return 0

	if (src == target) // :I
		boutput(src, SPAN_ALERT("You desperately try to think of a way to do CPR on yourself, but it's just not logically possible!"))
		return
	if(actions.hasAction(src, /datum/action/bar/icon/CPR))
		boutput(src, SPAN_ALERT("You're already doing CPR!"))
		return

	src.lastattacked = get_weakref(target)

	actions.start(new /datum/action/bar/icon/CPR(target), src)

///////////////////////////////////////////// Grab intent //////////////////////////////////////////////////////////

/mob/living/proc/grab_self()
	if (!src)
		return 0
	return 1

/mob/living/grab_self()
	if(!..())
		return
	var/block_it_up = TRUE
	if (!src.lying && !src.getStatusDuration("knockdown") && !src.getStatusDuration("unconscious"))
		for(var/obj/stool/stool_candidate in src.loc)
			if (stool_candidate.buckle_in(src, src, src.a_intent == INTENT_GRAB))
				block_it_up = FALSE
				break //found one, no need to continue

	if (block_it_up)
		var/obj/item/grab/block/G = new /obj/item/grab/block(src, src, src)
		if(src.put_in_hand(G, src.hand))
			playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
			src.visible_message(SPAN_ALERT("[src] starts blocking!"))
			SEND_SIGNAL(src, COMSIG_UNARMED_BLOCK_BEGIN, G)
			src.setStatus("blocking", duration = INFINITE_STATUS)
			block_begin(src)
		else
			qdel(G)

		src.next_click = world.time + src.combat_click_delay

/mob/living/proc/grab_block() //this is sorta an ugly but fuck it!!!!
	if (src.grabbed_by && length(src.grabbed_by) > 0)
		return 0

	.= 1

	var/obj/item/I = src.equipped()
	if (!I)
		src.grab_self()
	else
		var/obj/item/grab/block/G = new /obj/item/grab/block(I, src, src)
		G.loc = I

		I.chokehold = G
		I.chokehold.post_item_setup()

		playsound(src.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
		src.visible_message(SPAN_ALERT("[src] starts blocking with [I]!"))
		SEND_SIGNAL(I, COMSIG_ITEM_BLOCK_BEGIN, G)
		src.setStatus("blocking", duration = INFINITE_STATUS)
		block_begin(src)
		src.next_click = world.time + src.combat_click_delay


/mob/living/proc/grab_other(var/mob/living/target, var/suppress_final_message = 0, var/obj/item/grab_item = null)
	if(!src || !target)
		return 0

	var/mob/living/carbon/human/H = src

	logTheThing(LOG_COMBAT, src, "grabs [constructTarget(target,"combat")] at [log_loc(src)].")

	if (target)
		target.add_fingerprint(src) // Just put 'em on the mob itself, like pulling does. Simplifies forensic analysis a bit (Convair880).

	if (check_target_immunity(target) == 1)
		playsound(target.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
		target.visible_message(SPAN_COMBAT("<b>[src] tries to grab [target], but can't get a good grip!</B>"))
		return

	if (!target.canbegrabbed)
		if (target.grabresistmessage)
			target.visible_message(SPAN_COMBAT("<b>[src] tries to grab [target], [target.grabresistmessage]</B>"))
		return

	if (istype(H))
		if(H.traitHolder && !H.traitHolder.hasTrait("glasscannon"))
			H.process_stamina(STAMINA_GRAB_COST)

		if (prob(20) && isrobot(target))
			var/mob/living/silicon/robot/T = target
			src.visible_message(SPAN_COMBAT("<b>[T] blocks [src]'s attempt to grab [him_or_her(T)]!"))
			playsound(target.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, 1, 1)
			return
		else
			var/obj/item/grab/block/B = target.check_block()
			if (target.do_dodge(src, null, show_msg = 0))
				src.visible_message(SPAN_COMBAT("<b>[target] dodges [src]'s attempt to grab [him_or_her(target)]!"))
				playsound(target.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, 1, 1)
				return
			else if(B && !target.lying)
				src.visible_message(SPAN_COMBAT("<b>[target] blocks [src]'s attempt to grab [him_or_her(target)]!"))
				playsound(target.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, 1, 1)
				qdel(B)
				target.remove_stamina(STAMINA_DEFAULT_BLOCK_COST)
				return

	if (!grab_item)
		var/obj/item/grab/G = new /obj/item/grab(src, src, target)
		src.put_in_hand(G, src.hand)
	else// special. return it too
		if (!grab_item.special_grab)
			return
		var/obj/item/grab/G = new grab_item.special_grab(grab_item, src, target)
		G.loc = grab_item
		.= G

	for (var/obj/item/grab/block/G in target.equipped_list(check_for_magtractor = 0)) //being grabbed breaks a block
		qdel(G)

	playsound(target.loc, 'sound/impact_sounds/Generic_Shove_1.ogg', 50, 1, -1)
	if (!suppress_final_message) // Melee-focused roles (resp. their limb datums) grab the target aggressively (Convair880).
		if (grab_item)
			target.visible_message(SPAN_ALERT("[src] grabs hold of [target] with [grab_item]!"))
		else
			target.visible_message(SPAN_ALERT("[src] grabs hold of [target]!"))


///////////////////////////////////////////////////// Disarm intent ////////////////////////////////////////////////

/mob/proc/disarm(var/mob/living/target, var/extra_damage = 0, var/suppress_flags = 0, var/damtype = DAMAGE_BLUNT, var/is_special = 0)
	if (!src || !ismob(src) || !target || !ismob(target))
		return

	hit_twitch(target)

	if (!isnum(extra_damage))
		extra_damage = 0

	//if (target.melee_attack_test(src, null, null, 1) != 1)
	//	return
	for(var/obj/item/grab/grab in target.equipped_list()) //if we're disarming the person grabbing us then resist instead
		if (grab.affecting == src)
			grab.do_resist()
			return

	var/datum/attackResults/disarm/msgs = calculate_disarm_attack(target, 0, 0, extra_damage, is_special)
	msgs.damage_type = damtype
	msgs.flush(suppress_flags)
	return

#define DISARM_WITH_ITEM_TEXT (disarming_item ? " with [disarming_item]" : "")
// I needed a harm intent-like attack datum for some limbs (Convair880).
// is_shove flag removes the possibility of slapping the item out of someone's hand. instead there is a chance to shove them backwards. The 'shove to the ground' chance remains unchanged. (mbc)
// mbc also added disarming_item flag - for when a disarm is performed BY something. Doesn't do anything but change text currently.
/mob/proc/calculate_disarm_attack(var/mob/target, var/base_damage_low = 0, var/base_damage_high = 0, var/extra_damage = 0, var/is_shove = 0, var/obj/item/disarming_item = 0)
	var/datum/attackResults/disarm/msgs = new(src)
	msgs.clear(target)
	msgs.valid = 1
	msgs.disarm = 1
	msgs.disarm_RNG_result = list()
	var/list/obj/item/items = target.equipped_list()

	var/def_zone = target.get_def_zone(src, src.zone_sel?.selecting)
	msgs.def_zone = def_zone
	if(prob(target.get_deflection())) //chance to deflect disarm attempts entirely
		msgs.played_sound = 'sound/impact_sounds/Generic_Swing_1.ogg'
		msgs.base_attack_message = SPAN_COMBAT("<b>[src] shoves at [target][DISARM_WITH_ITEM_TEXT]!</B>")
		fuckup_attack_particle(src)
		return msgs

	if (target.lying == 1) //roll lying bodies
		msgs.played_sound = 'sound/impact_sounds/Generic_Shove_1.ogg'
		msgs.base_attack_message = SPAN_COMBAT("<b>[src] rolls [target] backwards[DISARM_WITH_ITEM_TEXT]!</B>")
		msgs.disarm_RNG_result |= "shoved"
		msgs.disarm_RNG_result |= "handle_item_arm"
		return msgs

	var/damage = rand(base_damage_low, base_damage_high) * extra_damage
	var/mult = 1
	var/target_stamina = STAMINA_MAX //uses stamina?
	if (isliving(target))
		var/mob/living/L = target
		target_stamina = L.stamina

	if (damage > 0)
		def_zone = target.check_target_zone(def_zone)

		var/armor_mod = 0
		armor_mod = target.get_melee_protection(def_zone)
		damage -= armor_mod
		msgs.stamina_target -= max((STAMINA_DISARM_COST * 2.5) - armor_mod, 0)

		var/attack_resistance = target.check_attack_resistance(null, src)
		if (attack_resistance)
			if (isnum(attack_resistance))
				damage *= attack_resistance
			else
				damage = 0
				if (istext(attack_resistance))
					msgs.show_message_target(attack_resistance)
		msgs.damage = max(damage, 0)
	else if ( !(HAS_ATOM_PROPERTY(target, PROP_MOB_CANTMOVE)) )
		var/armor_mod = 0
		armor_mod = target.get_melee_protection(def_zone)
		if(target_stamina >= 0)
			var/unarmed_mod = 1.5 // if target is unarmed, do 1.5x stamina damage
			if (length(items))
				unarmed_mod = 1
			msgs.stamina_target -= max(unarmed_mod * STAMINA_DISARM_DMG - (armor_mod*0.5), 0) //armor vs barehanded disarm gives flat reduction
			msgs.force_stamina_target = 1


	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		if (H.sims)
			mult *= H.sims.getMoodActionMultiplier()

	var/stampart = round( ((STAMINA_MAX - target_stamina) / 3) )
	if (is_shove)
		msgs.base_attack_message = SPAN_COMBAT("<b>[src] shoves [target][DISARM_WITH_ITEM_TEXT]!</B>")
		msgs.played_sound = 'sound/impact_sounds/Generic_Shove_1.ogg'
		if (prob((stampart + 70) * mult))
			msgs.base_attack_message = SPAN_COMBAT("<b>[src] shoves [target] backwards[DISARM_WITH_ITEM_TEXT]!</B>")
			msgs.disarm_RNG_result |= "shoved"

	if (prob((stampart + 5) * mult))
		msgs.base_attack_message = SPAN_COMBAT("<b>[src] shoves [target] to the ground[DISARM_WITH_ITEM_TEXT]!</B>")
		msgs.played_sound = 'sound/impact_sounds/Generic_Shove_1.ogg'
		msgs.disarm_RNG_result |= "shoved_down"
		msgs.disarm_RNG_result |= "drop_item"
		msgs.disarm_RNG_result |= "handle_item_arm"

		return msgs

	if (is_shove) return msgs
	var/disarm_success = prob(40 * lerp(clamp(200 - target_stamina, 0, 100)/100, 1, 0.5) * mult)
	if (disarm_success && target.check_block() && !(HAS_ATOM_PROPERTY(target, PROP_MOB_CANTMOVE)))
		disarm_success = 0
		msgs.stamina_target -= STAMINA_DEFAULT_BLOCK_COST * 2
	var/list/obj/item/limbs = list()
	var/list/obj/item/loose = list()
	var/list/obj/item/fixed_in_place = list()
	if(length(items))
		var/multi = length(items) > 1
		for(var/obj/item/I in items)
			if(I.two_handed)
				multi = 1


			if (I.temp_flags & IS_LIMB_ITEM)
				limbs |= I.loc
				if(disarm_success)
					msgs.disarm_RNG_result |= "handle_item_arm"
			else if (I.cant_other_remove)
				fixed_in_place |= I
			else
				loose |= I
				if(disarm_success)
					msgs.disarm_RNG_result |= "drop_item"

#define ONE_OR_SOME(_mylist, _what) (length(_mylist) > 1 ? "multiple [_what]" : "[_mylist[1]]")

		if(disarm_success)
			msgs.played_sound = 'sound/impact_sounds/Generic_Shove_1.ogg'
			if(length(limbs))
				msgs.base_attack_message = SPAN_COMBAT("<b>[src] shoves [ONE_OR_SOME(limbs, "item limbs")][DISARM_WITH_ITEM_TEXT] and forces [target] to hit [himself_or_herself(target)]!</B>")
			else if(length(loose))
				msgs.base_attack_message = SPAN_COMBAT("<b>[src] knocks [ONE_OR_SOME(loose, "items")] out of [target]'s hand[multi?"s":""][DISARM_WITH_ITEM_TEXT]!</B>")
		else
			msgs.played_sound = 'sound/impact_sounds/Generic_Swing_1.ogg'
			if(length(limbs))
				msgs.base_attack_message = SPAN_COMBAT("<b>[src] shoves at [ONE_OR_SOME(limbs, "item limbs")][DISARM_WITH_ITEM_TEXT]!</B>")
			else if(length(loose))
				msgs.base_attack_message = SPAN_COMBAT("<b>[src] tries to knock [ONE_OR_SOME(loose, "items")] out of [target]'s hand[multi?"s":""][DISARM_WITH_ITEM_TEXT]!</B>")

			else if(length(fixed_in_place))
				msgs.base_attack_message = SPAN_COMBAT("<b>[src] vainly tries to knock [ONE_OR_SOME(fixed_in_place, "items")] out of [target]'s hand[multi?"s":""][DISARM_WITH_ITEM_TEXT]!</B>")
				msgs.show_self.Add(SPAN_ALERT("Something is binding [ONE_OR_SOME(fixed_in_place, "items")] to [target]. You won't be able to disarm [him_or_her(target)]."))
				msgs.show_target.Add(SPAN_ALERT("Something is binding [ONE_OR_SOME(fixed_in_place, "items")] to you. It cannot be knocked out of your hands."))
	else
		msgs.base_attack_message = SPAN_COMBAT("<b>[src] shoves [target][DISARM_WITH_ITEM_TEXT]!</B>")
		msgs.played_sound = 'sound/impact_sounds/Generic_Shove_1.ogg'
#undef ONE_OR_SOME

	return msgs

#undef DISARM_WITH_ITEM_TEXT

/mob/proc/check_block(ignoreStuns = 0) //am i blocking?
	RETURN_TYPE(/obj/item/grab/block)
	if (ignoreStuns || (isalive(src) && !getStatusDuration("unconscious")))
		var/obj/item/I = src.equipped()
		if (I)
			if (istype(I,/obj/item/grab/block))
				return I
			else if (I.c_flags & HAS_GRAB_EQUIP)
				for (var/obj/item/grab/block/G in I)
					return G
	return null

/mob/proc/do_dodge(var/mob/attacker, var/obj/item/W, var/show_msg = 1)
	return 0

/mob/living/do_dodge(var/mob/attacker, var/obj/item/W, var/show_msg = 1)
	if (stance == "dodge")
		if (show_msg)
			visible_message(SPAN_COMBAT("<b>[src] narrowly dodges [attacker]'s attack!"))
		playsound(loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 50, TRUE, 1)
		if (!ON_COOLDOWN(src, "matrix_sound_effect", 1 SECOND))
			src.playsound_local(src, 'sound/effects/graffiti_hit.ogg', 40, pitch = 0.8)
		add_stamina(STAMINA_FLIP_COST * 0.25) //Refunds some stamina if you successfully dodge.
		stamina_stun()
		fuckup_attack_particle(attacker)
		return 1
	else if (prob(src.get_passive_block()))
		if (show_msg)
			visible_message(SPAN_COMBAT("<b>[src] blocks [attacker]'s attack!"))
		playsound(loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 50, TRUE, 1)
		fuckup_attack_particle(attacker)
		return 1
	return ..()

/mob/living/proc/get_passive_block(var/obj/item/W)
	var/ret = 0
	if(getStatusDuration("stonerit"))
		ret += 20

	for (var/obj/item/C as anything in src.get_equipped_items())
		ret += C.getProperty("block")

	return ret



/////////////////////////////////////////////////// Harm intent ////////////////////////////////////////////////////////

/mob/living/proc/stun_glove_attack(var/mob/living/target)

//Todo : this
///mob/living/critter/stun_glove_attack(var/mob/living/target)


/mob/living/carbon/human/stun_glove_attack(var/mob/living/target)
	if (!src || !target || !src.gloves)
		return 0

	if (src.gloves.uses > 0)
		src.lastattacked = get_weakref(target)
		target.lastattacker = get_weakref(src)
		target.lastattackertime = world.time
		logTheThing(LOG_COMBAT, src, "touches [constructTarget(target,"combat")] with stun gloves at [log_loc(src)].")
		target.add_fingerprint(src) // Some as the other 'empty hand' melee attacks (Convair880).
		src.unlock_medal("High Five!", 1)

		elecflash(target)

		src.gloves.uses = max(0, src.gloves.uses - 1)
		if (src.gloves.uses < 1)
			src.gloves.icon_state = "yellow"
			src.gloves.item_state = "ygloves"
			src.update_clothing() // Was missing (Convair880).

		if (src.gloves.uses <= 0)
			src.show_text("The gloves are no longer electrically charged.", "red")
			src.gloves.overridespecial = 0
		else
			src.show_text("The gloves have [src.gloves.uses]/[src.gloves.max_uses] charges left!", "red")

		target.visible_message(SPAN_COMBAT("<b>[src] touches [target] with the stun gloves!</B>"))
		if (check_target_immunity(target) == 1)
			target.visible_message(SPAN_COMBAT("<b>...but it has no effect whatsoever!</B>"))
			return

#ifdef USE_STAMINA_DISORIENT
		target.do_disorient(140, knockdown = 40, stunned = 20, disorient = 80)
#else
		target.changeStatus("knockdown", 3 SECONDS)
		target.changeStatus("stunned", 2 SECONDS)
#endif


		target.stuttering = max(target.stuttering,5)

	else
		boutput(src, SPAN_ALERT("The stun gloves don't have enough charge!"))
		return

/mob/living/proc/melee_attack(var/mob/living/target)
	var/datum/limb/L = equipped_limb()
	if (!L)
		return

	L.harm(target, src) // Calls melee_attack_normal if limb datum doesn't override anything.

/mob/proc/melee_attack_normal(var/mob/target, var/extra_damage = 0, var/suppress_flags = 0, var/damtype = DAMAGE_BLUNT)
	if(!src || !target)
		return 0

	if(!isnum(extra_damage))
		extra_damage = 0

	if (!target.melee_attack_test(src))
		return

	var/datum/attackResults/msgs = calculate_melee_attack(target, 2, 9, extra_damage)
	if(msgs)
		msgs.damage_type = damtype
		attack_effects(target, zone_sel?.selecting)
		msgs.flush(suppress_flags)

/mob/proc/calculate_melee_attack(var/mob/target, var/base_damage_low = 2, var/base_damage_high = 9, var/extra_damage = 0, var/stamina_damage_mult = 1, var/can_crit = 1, can_punch = 1, can_kick = 1, var/datum/limb/limb = null)
	var/datum/attackResults/msgs = new(src)
	var/crit_chance = STAMINA_CRIT_CHANCE
	var/do_armor = TRUE
	var/do_stam = TRUE


	msgs.clear(target)
	msgs.valid = 1
	SEND_SIGNAL(target, COMSIG_MOB_ATTACKED_PRE, src, null)

	//get defense zone and 'organ' to hit
	var/def_zone = target.get_def_zone(src, src.zone_sel?.selecting)
	msgs.def_zone = def_zone

	//get damage multiplers based on self and target.
	var/self_damage_multiplier = get_base_damage_multiplier(def_zone)
	var/target_damage_multiplier = target.get_taken_base_damage_multiplier(src, def_zone)

	//abort if either multiplier is 0
	if (!target_damage_multiplier)
		msgs.played_sound = pick(sounds_punch)
		msgs.visible_message_self(SPAN_COMBAT("<b>[src] [src.punchMessage] [target], but it does absolutely nothing!</B>"))
		return msgs
	if (!self_damage_multiplier)
		msgs.played_sound = 'sound/impact_sounds/Generic_Snap_1.ogg'
		msgs.visible_message_self(SPAN_COMBAT("<b>[src] hits [target] with a ridiculously feeble attack!</B>"))
		return msgs

	msgs.played_sound = "punch"
	var/do_punch = FALSE
	var/do_kick = FALSE
	if(target.lying && can_kick)
		do_armor = FALSE
		do_stam = FALSE
		do_kick = TRUE
	else if(can_punch)//do_punch
		do_punch = TRUE
		//adjust stamina crit chance and stamina damage based on gloves
		if (ishuman(src))
			var/mob/living/carbon/human/H = src
			if (H.gloves)
				if (H.gloves.crit_override)
					crit_chance = H.gloves.bonus_crit_chance
				else
					crit_chance += H.gloves.bonus_crit_chance
				if (H.gloves.stamina_dmg_mult)
					stamina_damage_mult += H.gloves.stamina_dmg_mult

	//calculate damage
	var/damage = rand(base_damage_low, base_damage_high) * target_damage_multiplier * self_damage_multiplier + extra_damage + calculate_bonus_damage(msgs, do_punch, do_kick)
	//get def_zone again?
	def_zone = target.check_target_zone(def_zone)


	var/pre_armor_damage = damage
	var/list/shield_amt = list()
	SEND_SIGNAL(target, COMSIG_MOB_SHIELD_ACTIVATE, damage, shield_amt)
	damage *= max(0, (1-shield_amt["shield_strength"]))
	if(do_armor)
		//get target armor
		var/armor_mod = 0

		armor_mod = target.get_melee_protection(def_zone, DAMAGE_BLUNT)

		//flat damage reduction by armor
		damage -= armor_mod
		//effects for armor reducing most/all of damage
		if(pre_armor_damage > 0 && damage/pre_armor_damage <= 0.66)
			block_spark(target,armor=1)
			playsound(target, 'sound/impact_sounds/block_blunt.ogg', 50, TRUE, -1,pitch=1.5)
			if(damage <= 0)
				fuckup_attack_particle(src)


	if(do_stam)
		//calculate stamina damage to deal
		var/stam_power = STAMINA_HTH_DMG + src.calculate_bonus_stam_damage(msgs)
		stam_power *= stamina_damage_mult
		//reduce stamina damage by the same proportion that base damage was reduced
		//min cap is stam_power/3 so we still cant ignore it entirely
		if (pre_armor_damage == 0) //mbc lazy runtime fix
			stam_power *= (1/3) //do the least
		else
			stam_power *= clamp(damage/pre_armor_damage, 1, 1/3)
		stam_power *= max(0, (1-shield_amt["shield_strength"]))

		//record the stamina damage to do
		msgs.stamina_target -= max(stam_power, 0)

		//if we can crit, roll for a crit. Crits are blocked by blocks.
		if (prob(crit_chance) && !target.check_block()?.can_block(DAMAGE_BLUNT, 0))
			msgs.stamina_crit = 1
			msgs.played_sound = pick(sounds_punch)

	target.revenge_stun_reduction(msgs.stamina_target, damage, 0, DAMAGE_BLUNT) // this is a solid 'uncertain this should be here'
	//do stamina cost
	if (!(src.traitHolder && src.traitHolder.hasTrait("glasscannon")))
		msgs.stamina_self -= STAMINA_HTH_COST

	if(!do_kick)
		//set attack message
		if(pre_armor_damage > 0 && damage <= 0 )
			msgs.base_attack_message = SPAN_COMBAT("<b>[src] [do_punch ? src.punchMessage : "attacks"] [target], but [target]'s armor blocks it!</B>")
		else
			msgs.base_attack_message = SPAN_COMBAT("<b>[src] [do_punch ? src.punchMessage : "attacks"] [target][msgs.stamina_crit ? " and lands a devastating hit!" : "!"]</B>")

	//check godmode/sanctuary/etc
	var/attack_resistance = msgs.target.check_attack_resistance(null, src)
	if (attack_resistance)
		if (isnum(attack_resistance))
			damage *= attack_resistance
		else
			damage = 0
			if (istext(attack_resistance))
				msgs.show_message_target(attack_resistance)

	//clamp damage to non-negative values
	msgs.damage = max(damage, 0)
	return msgs

// This is used by certain limb datums (werewolf, shambling abomination) (Convair880).
/proc/special_attack_silicon(var/mob/target, var/mob/living/user)
	if (!target || !issilicon(target) || !user || !isliving(user))
		return

	if (check_target_immunity(target) == 1)
		playsound(user.loc, "punch", 50, 1, 1)
		user.visible_message(SPAN_COMBAT("<b>[user]'s attack bounces off [target] uselessly!</B>"))
		return

	user.lastattacked = get_weakref(target)

	var/damage = 0
	var/send_flying = 0 // 1: a little bit | 2: across the room

	if (isrobot(target))
		var/mob/living/silicon/robot/BORG = target
		if (!BORG.part_head)
			user.visible_message(SPAN_COMBAT("<b>[user] smashes [BORG.name] to pieces!</B>"))
			playsound(user.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 70, 1)
			BORG.gib()
		else
			if (BORG.part_head.ropart_get_damage_percentage() >= 85)
				user.visible_message(SPAN_COMBAT("<b>[user] grabs [BORG.name]'s head and wrenches it right off!</B>"))
				playsound(user.loc, 'sound/impact_sounds/Metal_Hit_Lowfi_1.ogg', 70, 1)
				BORG.compborg_lose_limb(BORG.part_head)
			else
				user.visible_message(SPAN_COMBAT("<b>[user] pounds on [BORG.name]'s head furiously!</B>"))
				playsound(user.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1)
				if (BORG.part_head.ropart_take_damage(rand(20,40),0) == 1)
					BORG.compborg_lose_limb(BORG.part_head)
				if (!BORG.anchored && prob(30))
					user.visible_message(SPAN_COMBAT("<b>...and sends [him_or_her(BORG)] flying!</B>"))
					send_flying = 2

	else if (isAI(target))
		user.visible_message(SPAN_COMBAT("<b>[user] [pick("wails", "pounds", "slams")] on [target]'s terminal furiously!</B>"))
		playsound(user.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1)
		damage = 10

	else
		user.visible_message(SPAN_COMBAT("<b>[user] smashes [target] furiously!</B>"))
		playsound(user.loc, 'sound/impact_sounds/Metal_Clang_3.ogg', 50, 1)
		damage = 10
		if (!target.anchored && prob(30))
			user.visible_message(SPAN_COMBAT("<b>...and sends [him_or_her(target)] flying!</B>"))
			send_flying = 2

	if (send_flying == 2)
		wrestler_backfist(user, target)
	else if (send_flying == 1)
		wrestler_knockdown(user, target)

	if (damage > 0)
		random_brute_damage(target, damage)
		target.UpdateDamageIcon()

	logTheThing(LOG_COMBAT, user, "punches [constructTarget(target,"combat")] at [log_loc(user)].")
	return

/////////////////////////////////////////////////////// attackResult datum ////////////////////////////////////////

/datum/attackResults
	var/mob/owner
	var/mob/target
	var/list/visible_self = list()
	var/list/visible_target = list()
	var/list/show_self = list()
	var/list/show_target = list()
	var/list/logs = null
	var/list/after_effects = list()

	// the message to play to the target
	var/base_attack_message = null

	// a sound to play when this attack is flushed
	var/played_sound = null

	var/stamina_self = 0
	var/stamina_target = 0
	var/stamina_crit = 0
	var/damage = 0
	var/damage_type = DAMAGE_BLUNT
	var/def_zone = null
	var/valid = 0
	var/disarm = 0 // Is this a disarm as opposed to harm attack?
	var/disarm_RNG_result = null // Blocked, shoved down etc.
	var/bleed_always = 0 //Will cause bleeding regardless of damage type.
	var/bleed_bonus = 0 //bonus to bleed damage specifically.

	//grouping of combat message
	var/msg_group = 0

	var/force_stamina_target = null

	New(var/mob/M)
		..()
		owner = M

	proc/clear(var/mob/M)
		target = M
		visible_self.Cut()
		visible_target.Cut()
		show_self.Cut()
		show_target.Cut()
		logs = null
		played_sound = null
		base_attack_message = null
		stamina_self = 0
		stamina_target = 0
		stamina_crit = 0
		damage = 0
		damage_type = DAMAGE_BLUNT
		valid = 0
		disarm = 0
		disarm_RNG_result = null
		bleed_always = 0 //Will cause bleeding regardless of damage type.
		bleed_bonus = 0 //bonus to bleed damage specifically.
		def_zone = null

		after_effects.Cut()

	proc/show_message_self(var/message)
		show_self += message

	proc/show_message_target(var/message)
		show_target += message

	proc/visible_message_self(var/message)
		visible_self += message

	proc/visible_message_target(var/message)
		visible_target += message

	proc/logc(var/message)
		logs += message

	// I worked disarm into this because I needed a more detailed disarm proc and didn't want to reinvent the wheel or repeat a bunch of code (Convair880).
	proc/flush(var/suppress = 0)
		if (!target)
			clear(null)
			logTheThing(LOG_DEBUG, owner, "<b>Marquesas/Melee Attack Refactor:</b> NO TARGET FLUSH! EMERGENCY!")
			return

		if (!def_zone)
			clear(null)
			logTheThing(LOG_DEBUG, owner, "<b>tarmunora/Melee Attack Refactor2:</b> NO DEF_ZONE FLUSH! WARNING!")
			return

		var/list/disarm_log = list()

		if (!msg_group)
			msg_group = "[owner]_attacks_[target]_with_[disarm ? "disarm" : "harm"]"

		if (!(suppress & SUPPRESS_SOUND) && played_sound)
			var/obj/item/grab/block/G = target.check_block()
			if (G && G.can_block(damage_type) && damage > 0)
				G.play_block_sound(damage_type)
				playsound(owner.loc, played_sound, 15, 1, -1, 1.4)
			else
				playsound(owner.loc, played_sound, 50, 1, -1)

		if (!(suppress & SUPPRESS_BASE_MESSAGE) && base_attack_message)
			owner.visible_message(base_attack_message, group = msg_group)

		if (!(suppress & SUPPRESS_SHOWN_MESSAGES))
			for (var/message in show_self)
				owner.show_message(message, group = msg_group)

			for (var/message in visible_self)
				owner.visible_message(message, group = msg_group)

		if (!(suppress & SUPPRESS_SHOWN_MESSAGES))
			for (var/message in visible_target)
				target.visible_message(message, group = msg_group)

			for (var/message in show_target)
				target.show_message(message, group = msg_group)

		if (!(suppress & SUPPRESS_LOGS))
			if (!length(logs))
				if (!istype(src, /datum/attackResults/disarm))
					logs = list("punches [constructTarget(target,"combat")]")

//Pod wars friendly fire check
#if defined(MAP_OVERRIDE_POD_WARS)
			var/friendly_fire = 0
			if (owner != target && get_pod_wars_team_num(owner) == get_pod_wars_team_num(target))
				friendly_fire = 1
				if (istype(ticker.mode, /datum/game_mode/pod_wars))
					var/datum/game_mode/pod_wars/mode = ticker.mode
					mode.stats_manager?.inc_friendly_fire(owner)
				// message_admins("[owner] just committed friendly fire against [target]!")

			for (var/message in logs)
				logTheThing(LOG_COMBAT, owner, "[friendly_fire ? SPAN_ALERT("Friendly Fire!"):""][message] at [log_loc(owner)].")
#else
			for (var/message in logs)
				logTheThing(LOG_COMBAT, owner, "[message] at [log_loc(owner)].")
#endif

		if (stamina_self)
			if (stamina_self > 0)
				owner.add_stamina(stamina_self)
			else
				owner.process_stamina(-stamina_self)

		if (src.disarm == 1)
			target.add_fingerprint(owner)

			if (owner.traitHolder && !owner.traitHolder.hasTrait("glasscannon"))
				owner.process_stamina(STAMINA_DISARM_COST)

			if (length(src.disarm_RNG_result))
				if ("drop_item" in src.disarm_RNG_result)
					target.deliver_move_trigger("bump")
					var/list/dropped_items = list()
					for(var/obj/item/I in target.equipped_list())
						if(!(I.temp_flags & IS_LIMB_ITEM))
							dropped_items += "[I]"
							target.drop_item_throw(I)
					if(length(dropped_items))
						var/final_items_log = jointext(dropped_items, ", ")
						disarm_log += " making them drop item(s): ([final_items_log])"

				if ("handle_item_arm" in src.disarm_RNG_result)
					for(var/obj/item/I in target.equipped_list())
						if(!(I.temp_flags & IS_LIMB_ITEM))
							continue

						var/old_zone_sel = 0
						if (target.zone_sel) //attack the zone of the attacker
							old_zone_sel = target.zone_sel.selecting
							if (owner.zone_sel)
								target.zone_sel.selecting = owner.zone_sel.selecting
						var/prev_intent = target.a_intent
						target.set_a_intent(INTENT_HARM)

						disarm_log += " attempting to make them self-attack with the item arm: [I]"
						target.Attackby(I, target)

						target.set_a_intent(prev_intent)
						if (old_zone_sel)
							target.zone_sel.selecting = old_zone_sel

						if (prob(20))
							I.AttackSelf(target)


				if ("shoved_down" in src.disarm_RNG_result)
					target.deliver_move_trigger("pushdown")
					target.changeStatus("knockdown", 2 SECONDS)
					target.force_laydown_standup()
					disarm_log += " shoving them down"
				if ("shoved" in src.disarm_RNG_result)
					step_away(target, owner, 1)
					target.OnMove(owner)
					disarm_log += " shoving them away"
			else
				target.deliver_move_trigger("bump")
			logTheThing(LOG_COMBAT, owner, "disarms [constructTarget(target,"combat")][jointext(disarm_log, ", ")] at [log_loc(owner)].")
		else
#ifdef DATALOGGER
			game_stats.Increment("violence")
#endif
			owner.lastattacked = get_weakref(target)
			target.lastattacker = get_weakref(owner)
			target.lastattackertime = world.time
			target.add_fingerprint(owner)

		if (damage > 0 || (src.disarm == 1 || force_stamina_target))

			if ((src.disarm == 1 || force_stamina_target) && damage <= 0)
				goto process_stamina

			if (damage > 0 && target != owner)
				target.changeStatus("staggered", 5 SECONDS)
				owner.changeStatus("staggered", 5 SECONDS)
			// important

			if (damage_type == DAMAGE_BLUNT && prob(25 + (damage * 2)) && damage >= 8)
				damage_type = DAMAGE_CRUSH

			target.TakeDamage(def_zone, (damage_type != DAMAGE_BURN ? damage : 0), (damage_type == DAMAGE_BURN ? damage : 0), 0, damage_type)

			if ((damage_type & (DAMAGE_CUT | DAMAGE_STAB)) || bleed_always)
				take_bleeding_damage(target, owner, damage + bleed_bonus, damage_type, is_crit=stamina_crit)
				target.spread_blood_clothes(target)
				owner.spread_blood_hands(target)
				if (prob(15))
					owner.spread_blood_clothes(target)

			for (var/P in after_effects)
				call(P)(owner, target)

			process_stamina:

			if (stamina_target)
				if (stamina_target > 0)
					target.add_stamina(stamina_target)
				else
					var/prev_stam = target.get_stamina()
					target.remove_stamina(-stamina_target)
					target.revenge_stun_reduction(stamina_target, (damage_type != DAMAGE_BURN ? damage : 0), (damage_type == DAMAGE_BURN ? damage : 0), damage_type )
					target.stamina_stun()
					if(prev_stam > 0 && target.get_stamina() <= 0) //We were just knocked out.
						target.set_clothing_icon_dirty()
						target.lastgasp()

			if (stamina_crit)
				target.handle_stamina_crit()

			if (src.disarm != 1)
				owner.attack_finished(target)
				target.attackby_finished(owner)
			target.UpdateDamageIcon()

			if (damage > 1)
				if (isrevolutionary(owner))	//attacker is rev, all heads who see the attack get mutiny buff
					for (var/datum/mind/M in ticker?.mode?.get_living_heads())
						if (M.current)
							if (GET_DIST(owner,M.current) <= 7)
								if (owner in viewers(7,M.current))
									M.current.changeStatus("mutiny", 10 SECONDS)

			if(target.client && target.health < 0 && ishuman(target)) //Only do rev stuff if they have a client and are low health
				var/mob/living/carbon/human/H = target
				if (H.can_be_converted_to_the_revolution())
					if (isrevolutionary(owner))
						if (H.mind?.add_antagonist(ROLE_REVOLUTIONARY, source = ANTAGONIST_SOURCE_CONVERTED))
							H.changeStatus("newcause", 5 SECONDS)
							H.HealDamage("All", max(30 - H.health,0), 0)
							H.HealDamage("All", 0, max(30 - H.health,0))
					else
						if (H.mind?.remove_antagonist(ROLE_REVOLUTIONARY))
							H.delStatus("derevving") //Make sure they lose this status upon completion
							H.changeStatus("newcause", 5 SECONDS)
							H.HealDamage("All", max(30 - H.health,0), 0)
							H.HealDamage("All", 0, max(30 - H.health,0))
		clear(null)

/datum/attackResults/disarm
	logs = null //list("disarms [constructTarget(src,"diary")]") //handled above

////////////////////////////////////////////////////////// Targeting checks ////////////////////////////////////

/mob/proc/melee_attack_test(var/mob/attacker, var/obj/item/I, var/def_zone, var/disarm_check = 0)
	if (check_target_immunity(src) == 1)
		playsound(loc, "punch", 50, 1, 1)
		src.visible_message(SPAN_COMBAT("<b>[attacker]'s attack bounces off [src] uselessly!</B>"))
		return 0

	return 1

/mob/living/melee_attack_test(var/mob/attacker, var/obj/item/I, var/def_zone, var/disarm_check = 0)
	if (!..())
		return 0

	if (src.do_dodge(attacker, I))
		return 0

	return 1

/mob/proc/get_def_zone(mob/attacker, def_zone = null)
	if (def_zone)
		return def_zone
	var/t = pick("head", "chest")
	if(attacker.zone_sel)
		t = attacker.zone_sel.selecting
	return check_target_zone(t)

/mob/living/carbon/human/get_def_zone(mob/attacker, def_zone = null)
	var/t = pick("head", "chest")
	if(def_zone)
		t = def_zone
	else if(attacker.zone_sel)
		t = attacker.zone_sel.selecting
	t = ran_zone(t)

	return check_target_zone(t)

/mob/proc/check_target_zone(var/def_zone)
	return def_zone

/mob/living/carbon/human/check_target_zone(var/def_zone)
	if (limbs && !limbs.l_arm && def_zone == "l_arm")
		return "chest"
	if (limbs && !limbs.r_arm && def_zone == "r_arm")
		return "chest"
	return def_zone

////////////////////////////////////////////////////// Calculate damage //////////////////////////////////////////
///multipler to unarmed attack damage dealt
/mob/proc/get_base_damage_multiplier(def_zone)
	SHOULD_CALL_PARENT(TRUE)
	return 1

/mob/living/carbon/human/get_base_damage_multiplier(def_zone)
	. = ..()

	if (sims) //this is still a thing. huh.
		. *= sims.getMoodActionMultiplier() //also this is a 0-1.35 scale. HUH.

///multipler to unarmed damage received
/mob/proc/get_taken_base_damage_multiplier(mob/attacker, def_zone)
	SHOULD_CALL_PARENT(TRUE)
	return 1

///Returns flat bonus damage to unarmed attacks - can also modify the attackResults passed in, e.g. to add to `after_effects`
/mob/proc/calculate_bonus_damage(var/datum/attackResults/msgs, do_punch, do_kick)
	SHOULD_CALL_PARENT(TRUE)
	. = 0
	if(do_punch)
		. += calculate_punch_bonus(msgs)
	if(do_kick)
		. += calculate_kick_bonus(msgs)


/mob/living/carbon/human/calculate_bonus_damage(var/datum/attackResults/msgs, do_punch, do_kick)
	. = ..()
	if (src.is_hulk() && (do_punch || do_kick))
		//increase damage by, typically, 5-10, scaled from 0% health to 100% health - raw values don't matter
		//can exceed 10 damage in edge case of being under -300% health.
		//maybe should be a bigger bonus when hurt? hulk angry etc?
		. += max((abs(health+max_health)/max_health)*5, 5)
		msgs.after_effects += /proc/hulk_smash

/mob/proc/calculate_punch_bonus(datum/attackResults/msgs)
	SHOULD_CALL_PARENT(TRUE)
	. = 0
	//drunkards get a 2/5 chance of bonus damage
	if (src.reagents && (src.reagents.get_reagent_amount("ethanol") >= 100) && prob(40))
		. += rand(3,5)
		msgs.show_message_self(SPAN_ALERT("You drunkenly throw a brutal punch!"))
	//wrestlers have a 2/3 chance of a big hit
	if (src != msgs.target && iswrestler(src) && prob(66))
		msgs.base_attack_message = SPAN_COMBAT("<b>[src]</b> winds up and delivers a backfist to [msgs.target], sending [him_or_her(msgs.target)] flying!")
		. += 4
		msgs.after_effects += /proc/wrestler_backfist

/mob/living/carbon/human/calculate_punch_bonus(datum/attackResults/msgs)
	. = ..()
	//bonus damage from weighted/etc gloves
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if (H.gloves)
			. += H.gloves.punch_damage_modifier


/mob/proc/calculate_kick_bonus(datum/attackResults/msgs)
	SHOULD_CALL_PARENT(TRUE)
	. = 0
	//setup kick effects
	msgs.played_sound = 'sound/impact_sounds/Generic_Hit_1.ogg'
	msgs.base_attack_message = SPAN_COMBAT("<b>[src] [src.kickMessage] [msgs.target]!</B>")
	msgs.logs = list("[src.kickMessage] [constructTarget(msgs.target,"combat")]")

	//bonus damage from shoes or legs
	if (ishuman(src))
		var/mob/living/carbon/human/H = src
		if (H.shoes)
			. += H.shoes.kick_bonus
		else if (H.limbs.r_leg)
			. += H.limbs.r_leg.limb_hit_bonus
		else if (H.limbs.l_leg)
			. += H.limbs.l_leg.limb_hit_bonus

	//RELAXING
	#if STAMINA_LOW_COST_KICK == 1
	msgs.stamina_self += STAMINA_HTH_COST / 3
	#endif

///returns additive adjustment to stamina damage for unarmed attacks (applied before stamina damage multiplier)
/mob/proc/calculate_bonus_stam_damage(datum/attackResults/msgs)
	SHOULD_CALL_PARENT(TRUE)
	. = 0
	if (src.traitHolder.hasTrait("bigbruiser"))
		msgs.stamina_self -= STAMINA_HTH_COST //Double the cost since this is stacked on top of default
		. += STAMINA_HTH_DMG * 0.25

/////////////////////////////////////////////////////// Target damage modifiers //////////////////////////////////

/mob/proc/check_attack_resistance(var/obj/item/I, var/mob/attacker)
	return null

/mob/living/silicon/robot/check_attack_resistance(var/obj/item/I, var/mob/attacker)
	if (!I)
		if (attacker.equipped_limb()?.can_beat_up_robots)
			return 0.5 //let's say they do half damage because metal is stronk
		else
			return SPAN_ALERT("Sensors indicate no damage from external impact.")
	return null

/mob/living/check_attack_resistance(var/obj/item/I, var/mob/attacker)
	if (reagents?.get_reagent_amount("ethanol") >= 100 && prob(40) && !I)
		return SPAN_ALERT("You drunkenly shrug off the blow!")
	return null

/mob/proc/get_melee_protection(zone, damage_type = 0)
	return 0

/mob/proc/get_ranged_protection()
	return 1

/mob/proc/get_deflection()
	.= 0

///////////////////
/mob/proc/get_head_pierce_prot()
	return 0

/mob/living/carbon/human/get_head_pierce_prot()
	if ((head && head.body_parts_covered & HEAD) || (wear_mask && wear_mask.body_parts_covered & HEAD))
		if (head && !wear_mask)
			return max(0, head.getProperty("pierceprot"))
		else if (!head && wear_mask)
			return max(0, wear_mask.getProperty("pierceprot"))
		else if (head && wear_mask)
			return max(0, max(head.getProperty("pierceprot"), wear_mask.getProperty("pierceprot")))
	return 0

/mob/proc/get_chest_pierce_prot()
	return 0

/mob/living/carbon/human/get_chest_pierce_prot()
	if ((wear_suit && wear_suit.body_parts_covered & TORSO) || (w_uniform && w_uniform.body_parts_covered & TORSO))
		if (wear_suit && !w_uniform)
			return max(0, wear_suit.getProperty("pierceprot"))
		else if (!wear_suit && w_uniform)
			return max(0, w_uniform.getProperty("pierceprot"))
		else if (wear_suit && w_uniform)
			return max(0, max(w_uniform.getProperty("pierceprot"), wear_suit.getProperty("pierceprot")))
	return 0

/////////////////////////////////////////////////////////// After attack ////////////////////////////////////////////

/mob/proc/attack_effects(var/target, def_zone)
	return

/mob/living/carbon/human/attack_effects(var/mob/target, def_zone)
	if (src.bioHolder.HasEffect("revenant"))
		var/datum/bioEffect/hidden/revenant/R = src.bioHolder.GetEffect("revenant")
		if (R.ghoulTouchActive)
			R.ghoulTouch(target, def_zone)

//variant, using for werewolf pounce, to send mobs in a random direction and 50% chance to weaken them.
/proc/wrestler_knockdown(var/mob/H, var/mob/T, var/variant)
	if (!H || !ismob(H) || !T || !ismob(T))
		return

	if (variant)
		if(prob(50))
			T.changeStatus("knockdown", 2 SECONDS)
			T.force_laydown_standup()
		SPAWN(0)
			step_rand(T, 15)
	else
		T.changeStatus("knockdown", 2 SECONDS)
		T.force_laydown_standup()
		SPAWN(0)
			step_away(T, H, 15)

	return

/proc/wrestler_backfist(var/mob/H, var/mob/T)
	if (!H || !ismob(H) || !T || !ismob(T))
		return

	T.changeStatus("knockdown", 5 SECONDS)
	var/turf/throwpoint = get_edge_target_turf(H, get_dir(H, T))
	if (throwpoint && isturf(throwpoint))
		T.throw_at(throwpoint, 10, 2)

	return

/proc/hulk_smash(var/mob/H, var/mob/T)
	SPAWN(0)
		if (prob(20))
			T.changeStatus("stunned", 1 SECOND)
			step_away(T,H,15)
			sleep(0.3 SECONDS)
			step_away(T,H,15)
		else if (prob(20))				//what's this math, like 40% then with the if else? who cares

			var/turf/throw_to = get_edge_target_turf(H, H.dir)
			if (isturf(throw_to))
				H.visible_message(SPAN_COMBAT("<b>[H] savagely punches [T], sending [him_or_her(T)] flying!</B>"))
				T.throw_at(throw_to, 10, 2)

/mob/proc/attack_finished(var/mob/target)
	return

/mob/living/carbon/human/attack_finished(var/mob/target)
	if (sims)
		sims.affectMotive("fun", 5)

/mob/proc/attackby_finished(var/mob/attacker)
	return

/mob/living/carbon/human/attackby_finished(var/mob/attacker)
	if (sims)
		if (istype(gloves, /obj/item/clothing/gloves/boxing))
			sims.affectMotive("fun", 2.5)

/// return 1 on successful dodge or parry, 0 on fail
/mob/proc/parry_or_dodge(mob/M, obj/item/W)
	return 0

/mob/living/parry_or_dodge(mob/M, obj/item/W)
	if(!(M && src.stance == "defensive" && !src.stat))
		return ..()
	if(iswerewolf(src) && prob(60) || !iswerewolf(src) && prob(40))//dodge more likely, we're more agile than macho
		src.set_dir(get_dir(src, M))
		playsound(src.loc, 'sound/impact_sounds/Generic_Swing_1.ogg', 50, 1)
		if (prob(60))
			src.visible_message(SPAN_COMBAT("<b>[src] dodges the blow by [M]!</B>"))
		else
			if (prob(50))
				step_away(M, src, 15)
			else
				src.visible_message(SPAN_COMBAT("<b>[src] parries [M]'s attack, knocking [him_or_her(M)] to the ground!</B>"))
				M.changeStatus("knockdown", 4 SECONDS)
				M.force_laydown_standup()
		playsound(src.loc, 'sound/impact_sounds/kendo_parry_1.ogg', 65, 1)
		return 1

/mob/living/proc/werewolf_tainted_saliva_transfer(var/mob/target)
	if (iswerewolf(src))
		var/datum/abilityHolder/werewolf/W = src.get_ability_holder(/datum/abilityHolder/werewolf)
		if (target && W?.tainted_saliva_reservoir.total_volume > 0)
			W.tainted_saliva_reservoir.trans_to(target,5, 2)

