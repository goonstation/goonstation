/*
 * A file for human mob critters
 *
 * It might seem odd, but when you just want a humanoid mob it makes sense to keep it simple
 * with normal humans you have more processing and more things to worry about like oxygen, disarms and inventory
 * and using real weapons you need to worry about ammo and such as well. The critter AI is also currently
 * better for the most part compared to human AI and only has full compatibility with mob critters.
 *
 * The idea is to use a temporary mob equip them and copy the appearance for the critter
 * while keeping inhands for their limbs where possible.
 *
 */
ABSTRACT_TYPE(/mob/living/critter/human)
/mob/living/critter/human
	name = "Human critter parent"
	desc = "You shouldn't see me!"
	icon = 'icons/mob/mob.dmi'
	icon_state = "m-none"
	hand_count = 2
	health_brute = 50
	health_brute_vuln = 1
	health_burn = 50
	health_burn_vuln = 1
	/// What do we spawn when we die should be a human corpse spawner leave null for gibs
	var/corpse_spawner = null
	/// Path of a human to copy appearance from
	var/human_to_copy = null

	New()
		..()
		steal_appearance(src.human_to_copy)

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "left hand"
		HH.suffix = "-L"
		HH.icon_state = "handl"
		HH.limb_name = "left arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right arm"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_brute_vuln)

	death(var/gibbed)
		if (gibbed)
			return ..()
		..()
		if (src.corpse_spawner)
			new src.corpse_spawner(src.loc)
			src.ghostize()
			qdel(src)
		else
			src.gib()

	proc/steal_appearance(var/mob/living/carbon/human/H)
		if (isnull(H))
			return
		var/mob/living/carbon/human/target = new H
		SPAWN(1) // Let it equip / do traces
			if (target.l_hand) // don't want artifacts of papers / etc.
				qdel(target.l_hand)
			if (target.r_hand)
				qdel(target.r_hand)
			src.appearance = target
			src.overlay_refs = target.overlay_refs?.Copy()
			src.name = initial(src.name)
			src.real_name = initial(src.real_name)
			src.desc = initial(src.desc)
			qdel(target)

/mob/living/critter/human/syndicate
	name = "Syndicate Operative"
	real_name = "Syndicate Operative"
	desc = "A Syndicate Operative, oh dear."
	corpse_spawner = /obj/mapping_helper/mob_spawn/corpse/human/skeleton
	human_to_copy = /mob/living/carbon/human/normal/syndicate
