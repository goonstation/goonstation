/mob/living/critter/flock/bit
	name = "floaty gewgaw"
	desc = "Well, that's a thing."
	icon_state = "flockbit"
	density = FALSE
	hand_count = 2
	pays_to_construct = FALSE
	health_brute = 5
	health_burn = 5
	repair_per_resource = 1
	fits_under_table = TRUE
	flags = TABLEPASS

/mob/living/critter/flock/bit/New(var/atom/location, var/datum/flock/F=null)
	..(src, F)

	src.ai = new /datum/aiHolder/flock/bit(src)

	SPAWN(1 SECOND)
		animate_bumble(src)
		src.zone_sel.change_hud_style('icons/mob/flock_ui.dmi')

	src.name = "[pick_string("flockmind.txt", "flockbit_name_adj")] [pick_string("flockmind.txt", "flockbit_name_noun")]"
	src.real_name = src.flock ? src.flock.pick_name("flockbit") : name
	src.update_name_tag()
	src.flock_name_tag = new
	src.flock_name_tag.set_name(src.real_name)
	src.vis_contents += src.flock_name_tag

	src.flock?.bits_made++

	APPLY_ATOM_PROPERTY(src, PROP_ATOM_FLOCK_THING, src)
	src.AddComponent(/datum/component/flock_protection)

/mob/living/critter/flock/bit/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"<span class='flocksay'><span class='bold'>###=-</span> Ident confirmed, data packet received.
		<br><span class='bold'>ID:</span> [src.real_name]
		<br><span class='bold'>Flock:</span> [src.flock ? src.flock.name : "none"]
		<br><span class='bold'>System Integrity:</span> [max(0, round(src.get_health_percentage() * 100))]%
		<br><span class='bold'>Cognition:</span> [src.dormant ? "ABSENT" : src.is_npc ? "PREDEFINED" : "AWARE"]
		<br><span class='bold'>###=-</span></span>"}

/mob/living/critter/flock/bit/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return TRUE
	if (!src.dormant && src.flock && !src.flock.z_level_check(src) && src.z != Z_LEVEL_NULL)
		src.dormantize()

/mob/living/critter/flock/bit/MouseDrop_T(mob/living/target, mob/user)
	if(!target || !user)
		return
	if(target == user)
		if(istype(user, /mob/living/intangible/flock))
			boutput(user, "<span class='flocksay'>Insufficient processing power for partition override.</span>")
		else
			..() // ghost observe
	else
		..()

/mob/living/critter/flock/bit/setup_hands()
	..()
	var/datum/handHolder/HH = hands[1]
	HH.limb = new /datum/limb/flock_grip
	HH.name = "grip tool"
	HH.icon = 'icons/mob/flock_ui.dmi'
	HH.icon_state = "griptool"
	HH.limb_name = HH.name
	HH.can_hold_items = TRUE
	HH.can_attack = TRUE
	HH.can_range_attack = FALSE

	HH = hands[2]
	HH.limb = new /datum/limb/flockbit_converter
	HH.name = "nanite spray"
	HH.icon = 'icons/mob/flock_ui.dmi'
	HH.icon_state = "converter"
	HH.limb_name = HH.name
	HH.can_hold_items = FALSE
	HH.can_attack = TRUE
	HH.can_range_attack = FALSE

/mob/living/critter/flock/bit/dormantize()
	src.icon_state = "bit-dormant"
	animate(src) // doesnt work right now
	..()

/mob/living/critter/flock/bit/death(var/gibbed)
	..()
	flockdronegibs(get_turf(src))
	if (src.mind || src.client)
		src.ghostize()
	qdel(src)

/mob/living/critter/flock/bit/disposing()
	if (src.mind || src.client)
		src.ghostize()
	..()

// for gimmicks
/mob/living/critter/flock/bit/Login()
	..()
	src.client?.set_color()
	src.ai?.stop_move()
	src.is_npc = FALSE

/mob/living/critter/flock/bit/specific_emotes(var/act, var/param = null, var/voluntary = 0)
	switch (act)
		if ("whistle", "beep", "burp", "scream", "growl", "abeep", "grump", "fart")
			if (src.emote_check(voluntary, 50))
				playsound(src, "sound/misc/flockmind/flockbit_wisp[pick("1","2","3","4","5","6")].ogg", 30, 1, extrarange = -10)
				return "<b>[src]</b> chimes."
		if ("flip")
			if (src.emote_check(voluntary, 50) && !src.shrunk)
				SPAWN(1 SECOND)
					animate_bumble(src)
				return null
	return null

/////////////////////////////////////

/datum/limb/flockbit_converter // can only convert turfs but can do it for free and faster

/datum/limb/flockbit_converter/attack_hand(atom/target, var/mob/living/critter/flock/bit/user, var/reach, params, location, control)
	if (!holder)
		return
	if(check_target_immunity( target ))
		return
	if (!istype(user))
		return

	if(!isturf(target))
		target = get_turf(target)

	if(!istype(target, /turf/simulated) && !istype(target, /turf/space))
		boutput(user, "<span class='alert'>Something about this structure prevents it from being assimilated.</span>")
	else
		playsound(src, "sound/misc/flockmind/flockbit_wisp[pick("1","2","3","4","5","6")].ogg", 30, extrarange = -10)
		actions.start(new/datum/action/bar/flock_convert(target, 25), user)
