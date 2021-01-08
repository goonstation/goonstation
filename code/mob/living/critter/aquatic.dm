////////////////////////////////////////////////////////////////////////////////////////////////////
// aquatic mobcritters, found in sealab
//	-fish
//	-aquatic mobcritter limbs
//	-etc
////////////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/critter/aquatic
	name = "aquatic mobcritter"
	real_name = "aquatic mobcritter"
	desc = "No, you should not be seeing this!"
	icon = 'icons/misc/sea_critter.dmi'
	density = 0
	hand_count = 1
	can_disarm = 1
	can_help = 1
	butcherable = 1

	is_npc = 1

	var/health_brute = 10
	var/health_brute_vuln = 1
	var/health_burn = 10
	var/health_burn_vuln = 2

	var/water_need = 0 // 0, 1, or 2; 1 and 2 just differ in intensity
	var/in_water_to_out_of_water = 0 // did they enter an area with sufficient water from an area with insufficient water?
	var/out_of_water_debuff = 1 // debuff amount for being out of water
	var/out_of_water_to_in_water = 0 // did they enter an area with insufficient water from an area with sufficient water?
	var/in_water_buff = 1 // buff amount for being in water

	var/is_pet = null // null for automatic detection

/mob/living/critter/aquatic/New(loc)
	if(isnull(src.is_pet))
		src.is_pet = (copytext(src.name, 1, 2) in uppercase_letters)
	if(in_centcom(loc) || current_state >= GAME_STATE_PLAYING)
		src.is_pet = 0
	if(src.is_pet)
		START_TRACKING_CAT(TR_CAT_PETS)
	src.update_water_status(loc)
	..()
	remove_lifeprocess(/datum/lifeprocess/blood) // caused lag, not sure why exactly

/mob/living/critter/aquatic/disposing()
	ai?.dispose()
	ai = null
	if(src.is_pet)
		STOP_TRACKING_CAT(TR_CAT_PETS)
	..()

/mob/living/critter/aquatic/setup_healths()
	add_hh_flesh(-(src.health_brute), src.health_brute, src.health_brute_vuln)
	add_hh_flesh_burn(-(src.health_burn), src.health_burn, src.health_burn_vuln)

/mob/living/critter/aquatic/Login()
	..()
	if(is_npc)
		is_npc = 0

/mob/living/critter/aquatic/Life(datum/controller/process/mobs/parent)
	if (isdead(src))
		return
	if (..())
		return 1
	if(src.water_need)
		if(prob(10 * src.water_need) && !src.nodamage) // question: this gets rid of like one proc call; worth it?
			var/datum/healthHolder/Br = get_health_holder("brute")
			Br?.TakeDamage(water_need * out_of_water_debuff)
			var/datum/healthHolder/Bu = get_health_holder("burn")
			if(Bu && !is_heat_resistant())
				Bu.TakeDamage(water_need * out_of_water_debuff)
			hit_twitch(src)
	else if(src.max_health > src.health && prob(10 * src.in_water_buff))
		var/datum/healthHolder/Br = get_health_holder("brute")
		if (Br && Br.maximum_value > Br.value)
			Br.TakeDamage(-in_water_buff)
		var/datum/healthHolder/Bu = get_health_holder("burn")
		if (Bu && Bu.maximum_value > Bu.value && !is_heat_resistant())
			Bu.TakeDamage(-in_water_buff)

/mob/living/critter/aquatic/set_loc(newloc)
	. = ..()
	src.update_water_status()

/mob/living/critter/aquatic/EnteredFluid(obj/fluid/F, atom/oldloc)
	. = ..()
	src.update_water_status()

/mob/living/critter/aquatic/Move(NewLoc, direct)
	. = ..()
	src.update_water_status()

/mob/living/critter/aquatic/proc/update_water_status(loc = null)
	if(isnull(loc))
		loc = src.loc
	if(istype(loc, /turf/space/fluid)) // question: is this logic viable? too messy?
		if(src.water_need)
			src.water_need = 0
			src.out_of_water_to_in_water = 1
	else if(isturf(loc))
		var/turf/T = loc
		if (T.active_liquid)
			if(T.active_liquid.last_depth_level > 3)
				if(src.water_need)
					src.water_need = 0
					src.out_of_water_to_in_water = 1
			else
				if(src.water_need != 1)
					if(!src.water_need)
						src.in_water_to_out_of_water = 1
					src.water_need = 1
		else
			if(src.water_need != 2)
				if(!src.water_need)
					src.in_water_to_out_of_water = 1
				src.water_need = 2
	else // so, like, in a vehicle or something; this does not work for being inside large storages
		if(src.water_need != 2)
			if(!src.water_need)
				src.in_water_to_out_of_water = 1
			src.water_need = 2

/mob/living/critter/aquatic/TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
	..()
	if(prob(10 * src.in_water_buff) && !src.water_need)
		src.HealDamage("All", in_water_buff, in_water_buff)

/mob/living/critter/aquatic/proc/harmed_by(var/mob/M) // copying cirr for this stuff
	if(isdead(src))
		return

/mob/living/critter/aquatic/attack_hand(var/mob/living/M)
	..()
	if(M.a_intent == INTENT_HARM)
		src.harmed_by(M)

/mob/living/critter/aquatic/attackby(var/obj/item/I, var/mob/M)
	..()
	if(I.force)
		harmed_by(M)

/mob/living/critter/aquatic/bullet_act(var/obj/projectile/P)
	..()
	if(P.mob_shooter)
		src.harmed_by(P.mob_shooter)

////////////////////////////////////////////////////////////////////////////////////////////////////
//fish
////////////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/critter/aquatic/fish
	name = "fish"
	real_name = "fish"
	desc = "Goes well with chips."
	icon_state = "clownfish"
	base_move_delay = 3
	speechverb_say = "blubs"
	speechverb_exclaim = "glubs"
	death_text = "%src% flops belly up!"
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish/small
	// todo: skinresult of scales, custom_brain_type of fish egg item (caviar?)

	throws_can_hit_me = 0
	ai = null

	var/swimming_away = 0


/mob/living/critter/aquatic/fish/setup_hands()
	..()
	var/datum/handHolder/HH = hands[1]
	HH.limb = new /datum/limb/mouth/fish
	HH.icon = 'icons/mob/critter_ui.dmi'
	HH.icon_state = "mouth"
	HH.name = "mouth"
	HH.limb_name = "mouth"
	HH.can_hold_items = 0

/mob/living/critter/aquatic/fish/New()
	..()
	src.ai = new /datum/aiHolder/aquatic/fish(src)
	animate_bumble(src)

	/*SPAWN_DBG(0)
		if(src.client)
			src.is_npc = 0
		else // i mean, i can't imagine many scenarios where a player controlled fish also needs AI that doesn't even run
			src.ai = new /datum/aiHolder/aquatic/fish(src)
			mobs.Remove(src)*/

/mob/living/critter/aquatic/fish/Move(NewLoc, direct)
	. = ..()
	if(src.out_of_water_to_in_water)
		animate_bumble(src)
		out_of_water_to_in_water = 0
	else if(src.in_water_to_out_of_water)
		animate(src)
		in_water_to_out_of_water = 0
	else if(src.water_need && prob(2 * src.water_need))
		hit_twitch(src)
		src.visible_message("<b>[src]</b> [pick("flops around desperately","gasps","shudders")].")

/mob/living/critter/aquatic/TakeDamage(zone, brute, burn, tox, damage_type, disallow_limb_loss)
	..()
	if(!isdead(src))
		animate_bumble(src)

/mob/living/critter/aquatic/fish/throw_impact(atom/hit_atom, datum/thrown_thing/thr)
	..()
	if(!water_need && !isdead(src))
		animate_bumble(src)

/mob/living/critter/aquatic/fish/harmed_by(var/mob/M)
	..()
	if(src.is_npc && !isdead(src) && !water_need && !swimming_away) // todo: add this to AI to make things cleaner?
		walk_away(src,M,6,4)
		swimming_away = 1
		if(src)
			walk(src,0)
			swimming_away = 0
			if(!isdead(src))
				animate_bumble(src)
	else if (isdead(src))
		walk(src,0)
		swimming_away = 0
		if (src.ai)
			src.ai.enabled = 0

/mob/living/critter/aquatic/fish/specific_emotes(var/act, var/param = null, var/voluntary = 0)
	switch (act)
		if ("flip")
			if (src.emote_check(voluntary, 50) && !src.water_need)
				SPAWN_DBG(1 SECOND)
					animate_bumble(src)
				return null
		if ("dance")
			if (src.emote_check(voluntary, 100))
				SPAWN_DBG(0)
					for (var/i = 0, i < 4, i++)
						src.pixel_x+= 2
						src.set_dir(turn(src.dir, 90))
						sleep(0.2 SECONDS)
					for (var/i = 0, i < 4, i++)
						src.pixel_x-= 2
						src.set_dir(turn(src.dir, 90))
						sleep(0.2 SECONDS)
					if(!src.water_need)
						animate_bumble(src)
				return "<b>[src]</b> dances!"
	return null

/mob/living/critter/aquatic/fish/butterfly
	name = "butterfly fish"
	desc = "An ocean-dwelling white butterfly fish from the <i>Chaetodontidae</i> family."
	icon_state = "butterflyfish"

/mob/living/critter/aquatic/fish/butterfly/copperbanded
	name = "copper-banded butterfly fish"
	desc = "An ocean-dwelling copper-banded butterfly fish from the <i>Chaetodontidae</i> family."
	icon_state = "butterflyfish_copperbanded"

/mob/living/critter/aquatic/fish/butterfly/addis
	name = "addis butterfly fish"
	desc = "An ocean-dwelling addis (or bluecheek) butterfly fish from the <i>Chaetodontidae</i> family."
	icon_state = "butterflyfish_addis"

/mob/living/critter/aquatic/fish/butterfly/spotted
	name = "spotted butterfly fish"
	desc = "An ocean-dwelling spotfin butterfly fish from the <i>Chaetodontidae</i> family."
	icon_state = "butterflyfish_spotted"

/mob/living/critter/aquatic/fish/butterfly/forceps
	name = "forceps butterfly fish"
	desc = "An ocean-dwelling forceps (or longnose) butterfly fish from the <i>Chaetodontidae</i> family."
	icon_state = "butterflyfish_forceps"

/mob/living/critter/aquatic/fish/tang
	name = "achilles tang"
	desc = "An ocean-dwelling achilles tang (or surgeonfish) from the <i>Acanthuridae</i> family."
	icon_state = "tang"

/mob/living/critter/aquatic/fish/tang/powderblue
	name = "powder blue tang"
	desc = "An ocean-dwelling powder blue tang (or surgeonfish) from the <i>Acanthuridae</i> family."
	icon_state = "tang_powderblue"

/mob/living/critter/aquatic/fish/tang/bluesailfin
	name = "blue sail-fin tang"
	desc = "An ocean-dwelling blue sail-fin tang from the <i>Acanthuridae</i> family."
	icon_state = "tang_bluesailfin"

/mob/living/critter/aquatic/fish/tang/purplesailfin
	name = "purple sail-fin tang"
	desc = "An ocean-dwelling purple sail-fin tang from the <i>Acanthuridae</i> family."
	icon_state = "tang_purplesailfin"

/mob/living/critter/aquatic/fish/tang/regal
	name = "regal tang"
	desc = "An ocean-dwelling regal (or hippo) tang from the <i>Acanthuridae</i> family."
	icon_state = "tang_regal"

	New()
		..()
		if (prob(5))
			desc += " This one looks quite wide-eyed and out of it."

/mob/living/critter/aquatic/fish/angel
	name = "koi angelfish"
	desc = "An ocean-dwelling koi angelfish from the <i>Cichlidae</i> family."
	icon_state = "angelfish"

/mob/living/critter/aquatic/fish/angel/french
	name = "juvenile french angelfish"
	desc = "An ocean-dwelling juvenile french angelfish from the <i>Cichlidae</i> family."
	icon_state = "angelfish_french"

/mob/living/critter/aquatic/fish/damsel
	name = "dusky damselfish"
	desc = "An ocean-dwelling dusky damselfish from the <i>Pomacentridae</i> family."
	icon_state = "damselfish"

/mob/living/critter/aquatic/fish/damsel/blue
	name = "blue damselfish"
	desc = "An ocean-dwelling blue (or blue devil) damselfish from the <i>Pomacentridae</i> family."
	icon_state = "damselfish_blue"

/mob/living/critter/aquatic/fish/gamma
	name = "royal gamma"
	desc = "An ocean-dwelling royal (or fairy basslet) gamma from the <i>Grammatidae</i> family."
	icon_state = "gamma"

/mob/living/critter/aquatic/fish/clown
	name = "ocellaris clownfish"
	desc = "An ocean-dwelling ocellaris (or false percula) clownfish from the <i>Pomacentridae</i> family."
	icon_state = "clownfish"

	New()
		..()
		if (prob(5))
			desc += " This one looks quite alarmed."

////////////////////////////////////////////////////////////////////////////////////////////////////
//cephalopod
////////////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/critter/aquatic/fish/nautilus //not a fish, but can act like one for now.
	name = "nautilus"
	desc = "An ocean-dwelling nautilus from the <i>Nautilidae</i> family."
	icon_state = "nautilus"

////////////////////////////////////////////////////////////////////////////////////////////////////
//king crab
////////////////////////////////////////////////////////////////////////////////////////////////////

/mob/living/critter/aquatic/king_crab
	name = "king crab"
	real_name = "king crab"
	desc = "This doesn't look tasty at all. It probably has spectacular levels of mercury and lead and who knows what else."
	icon = 'icons/obj/64x96.dmi'
	icon_state = "king_crab"
	base_move_delay = 1
	density = 1
	hand_count = 2
	can_disarm = 1
	can_help = 1
	can_grab = 1
	can_throw = 1
	can_choke = 1
	pet_text = "pokes"
	speechverb_say = "demands"
	speechverb_exclaim = "bellows"
	death_text = "%src% collapses in on itself!"
	meat_type = /obj/item/reagent_containers/food/snacks/ingredient/meat/fish
	// todo: meat_type of something cool, skinresult of especially hard crustacean plates?

	ai = null

	var/mob/living/kill_them = null

	health_brute = 500
	health_brute_vuln = 0.5
	health_burn = 500
	health_burn_vuln = 3
	out_of_water_debuff = 5
	in_water_buff = 10

	bound_width = 96
	bound_height = 64

/mob/living/critter/aquatic/king_crab/setup_hands()
	..()
	var/datum/handHolder/HH = hands[1]
	HH.icon = 'icons/mob/hud_human.dmi'
	HH.limb = new /datum/limb/king_crab
	HH.icon_state = "handl"
	HH.name = "pincer"
	HH.limb_name = "pincer"

	HH = hands[2]
	HH.icon = 'icons/mob/hud_human.dmi'
	HH.limb = new /datum/limb/king_crab
	HH.icon_state = "handr"
	HH.name = "pincer"
	HH.limb_name = "pincer"

/mob/living/critter/aquatic/king_crab/New()
	..()
	SPAWN_DBG(0)
		if(src.client)
			src.is_npc = 0
		else
			src.ai = new /datum/aiHolder/aquatic/king_crab(src)

/mob/living/critter/aquatic/king_crab/Move(NewLoc, direct)
	. = ..()
	if(src.out_of_water_to_in_water)
		base_move_delay = 1
		out_of_water_to_in_water = 0
	else if(src.in_water_to_out_of_water)
		animate_shake(src)
		src.emote("scream")
		base_move_delay = 2
		in_water_to_out_of_water = 0
	else if(src.water_need && prob(src.water_need))
		hit_twitch(src)
		src.visible_message("<b>[src]</b> [pick("shudders","clinks heavily","gasps","looks dazed")].")

/mob/living/critter/aquatic/king_crab/Bump(atom/movable/AM)
	..()
	if(isobj(AM))
		if(istype(AM, /obj/window))
			var/obj/window/W = AM
			W.health = 0
			W.smash()
		else if(istype(AM, /obj/grille))
			var/obj/grille/G = AM
			G.damage_blunt(30)
		else if(istype(AM, /obj/machinery/vehicle/tank) || istype(AM, /obj/table))
			AM.meteorhit()
		else if(istype(AM, /obj/foamedmetal))
			AM.dispose()
		playsound(src.loc, 'sound/effects/exlow.ogg', 70,1)
		src.visible_message("<span class='alert'><B>[src]</B> smashes into \the [AM]!</span>")

/mob/living/critter/aquatic/king_crab/harmed_by(var/mob/living/M)
	..()
	if(src.is_npc)
		src.kill_them = M

/mob/living/critter/aquatic/king_crab/specific_emotes(var/act, var/param = null, var/voluntary = 0)
	switch (act)
		if ("scream")
			if (src.emote_check(voluntary, 300))
				playsound(src.loc, 'sound/voice/animal/crab_chirp.ogg', 80, 0, 7, channel=VOLUME_CHANNEL_EMOTE)
				for (var/mob/living/M in oview(src, 7))
					M.apply_sonic_stun(0, 5, 3, 12, 40, rand(0,3))
				return "<span class='alert'><b>[src]</b> lets out an eerie wail.</span>"
		if ("dance")
			if (src.emote_check(voluntary, 300))
				for (var/i = 0, i < 4, i++)
					src.pixel_x+= 2
					src.set_dir(turn(src.dir, 90))
					sleep(0.2 SECONDS)
				for (var/i = 0, i < 4, i++)
					src.pixel_x-= 2
					src.set_dir(turn(src.dir, 90))
					sleep(0.2 SECONDS)
				SPAWN_DBG(5 SECONDS)
				for (var/mob/living/M in oview(src, 7))
					M.reagents.add_reagent(pick("cyanide","neurotoxin","venom","histamine","jenkem","lsd"), 5)
				return "<span class='alert'><b>[src]</b> does a sinister dance.</span>"
		if ("snap")
			if (src.emote_check(voluntary, 300))
				src.changeStatus("paralysis", -300)
				src.changeStatus("stunned", -300)
				src.changeStatus("weakened", -300)
				return "<span class='alert'><b>[src]</b> clacks menacingly.</span>"
		if ("flex")
			if (src.emote_check(voluntary, 300))
				src.health_brute_vuln = 0.1
				src.health_burn_vuln = 0.5
				SPAWN_DBG(10 SECONDS)
					if (src)
						src.health_brute_vuln = 0.5
						src.health_burn_vuln = 3
				return "<span class='alert'><b>[src]'s</b> chitin gleams.</span>"
	return null

////////////////////////////////////////////////////////////////////////////////////////////////////
// aquatic mobcritter limbs
////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/limb/mouth/fish
	sound_attack = "sound/impact_sounds/Glub_2.ogg"
	dam_low = 0
	dam_high = 1
	miss_prob = 100 // you ever meet those fish that eat the dead skin off of the backs of your feet?
	stam_damage_mult = 0.2

/datum/limb/king_crab // modified claw limb

/datum/limb/king_crab/attack_hand(atom/target, var/mob/living/user, var/reach, params, location, control)
	if (!holder)
		return

	if (!istype(user))
		target.attack_hand(user, params, location, control)
		return

	if (isobj(target))
		switch (user.smash_through(target, list("window", "grille", "table")))
			if (0)
				if (isitem(target))
					if (prob(33))
						boutput(user, "<span class='alert'>[target] slips through your pincers!</span>")
						return
					return ..()
				if (istype(target,/obj/sea_plant))
					user.visible_message("<span class='alert'><b>[user] smashes [target] into sea foam!</b></span>", "<span class='alert'><b>You smash [target] into sea foam!</b></span>")
					animate_melt_pixel(target)
					qdel(target)
				if (istype(target,/obj/machinery/power/apc))
					var/obj/machinery/power/apc/APC = target
					for (var/i=1,i<=4,i++)
						APC.cut(i)
					user.visible_message("<span class='alert'><b>[user]'s pincers slither inside [target] and slash the wires!</b></span>", "<span class='alert'><b>Your pincers slither inside [target] and slash the wires!</b></span>")
					return
				if (istype(target,/obj/cable))
					var/obj/cable/C = target
					C.cut(user,user.loc)
					return
			if (1)
				return

	..()
	return

/datum/limb/king_crab/proc/accident(mob/target, mob/living/user)
	if(check_target_immunity( target ))
		return 0
	if (prob(15))
		logTheThing("combat", user, target, "accidentally slashes [constructTarget(target,"combat")] with pincers at [log_loc(user)].")
		user.visible_message("<span class='alert'><b>[user] accidentally slashes [target] while trying to [user.a_intent] them!</b></span>", "<span class='alert'><b>You accidentally slash [target] while trying to [user.a_intent] them!</b></span>")
		harm(target, user, 1)
		return 1
	return 0

/datum/limb/king_crab/help(mob/target, var/mob/living/user)
	if (accident(target, user))
		return
	..()

/datum/limb/king_crab/disarm(mob/target, var/mob/living/user)
	if (accident(target, user))
		return
	..()

/datum/limb/king_crab/grab(mob/target, var/mob/living/user)
	if (accident(target, user))
		return
	..()

/datum/limb/king_crab/harm(mob/target, var/mob/living/user, var/no_logs = 0)
	if (no_logs != 1)
		logTheThing("combat", user, target, "slashes [constructTarget(target,"combat")] with pincers at [log_loc(user)].")
	var/obj/item/affecting = target.get_affecting(user)
	var/datum/attackResults/msgs = user.calculate_melee_attack(target, affecting, 10, 20, 0, 2)
	user.attack_effects(target, affecting)
	var/action = pick("slashes", "tears into", "gouges", "rips into", "lacerates", "mutilates")
	msgs.base_attack_message = "<b><span class='alert'>[user] [action] [target] with their [src.holder]!</span></b>"
	msgs.played_sound = "sound/impact_sounds/Glub_1.ogg"
	msgs.damage_type = DAMAGE_CUT
	msgs.flush(SUPPRESS_LOGS)

////////////////////////////////////////////////////////////////////////////////////////////////////
