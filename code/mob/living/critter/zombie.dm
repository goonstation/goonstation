// Maybe replace with NPC humans later? kill obj for now though

#define NO_EAT 0 // Does not eat brains
#define EATS_BRAINS 1 // Eats brains and creates new CRITTER zombies
#define HUMAN_INFECTION 2 // Eats brains and creates new HUMAN zombies

/mob/living/critter/zombie
	name = "zombie"
	real_name = "zombie"
	desc = "BraaAAAinnsSSs..."
	icon_state = "zombie"
	can_throw = TRUE
	can_grab = TRUE
	can_disarm = TRUE
	hand_count = 2
	health_brute = 15
	health_brute_vuln = 1
	health_burn = 15
	health_burn_vuln = 0.1
	is_npc = TRUE
	ai_type = /datum/aiHolder/aggressive
	ai_retaliates = TRUE
	ai_retaliate_patience = 0
	ai_retaliate_persistence = RETALIATE_UNTIL_INCAP
	ai_attacks_per_ability = 5

	var/infection_type = EATS_BRAINS

	New()
		..()
		src.add_stam_mod_max("zombie", 100)
		APPLY_MOVEMENT_MODIFIER(src, /datum/movement_modifier/zombie, src)
		APPLY_ATOM_PROPERTY(src, PROP_MOB_STAMINA_REGEN_BONUS, "zombie", -5)
		switch (src.infection_type)
			if (NO_EAT)
				return
			if (EATS_BRAINS)
				src.abilityHolder.addAbility(/datum/targetable/critter/zombify)
				return
			if (HUMAN_INFECTION)
				src.abilityHolder.addAbility(/datum/targetable/zombie/infect)
				return

	setup_hands()
		..()
		var/datum/handHolder/HH = hands[1]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/zombie
		HH.icon_state = "handl"
		HH.limb_name = "left zombie arm"

		HH = hands[2]
		HH.icon = 'icons/mob/hud_human.dmi'
		HH.limb = new /datum/limb/zombie
		HH.name = "right hand"
		HH.suffix = "-R"
		HH.icon_state = "handr"
		HH.limb_name = "right zombie arm"

	setup_healths()
		add_hh_flesh(src.health_brute, src.health_brute_vuln)
		add_hh_flesh_burn(src.health_burn, src.health_brute_vuln)

	valid_target(mob/living/C)
		if (istype(C, /mob/living/critter/zombie)) return FALSE
		if (iszombie(C)) return FALSE
		if (ishuman(C))
			var/mob/living/carbon/human/H = C
			if (istype(H.head, /obj/item/clothing/head/void_crown)) return FALSE
		return ..()

	critter_ability_attack(mob/target)
		switch (src.infection_type)
			if (NO_EAT)
				return FALSE
			if (EATS_BRAINS)
				var/datum/targetable/critter/zombify/infect = src.abilityHolder.getAbility(/datum/targetable/critter/zombify)
			if (HUMAN_INFECTION)
				var/datum/targetable/zombie/infect/infect = src.abilityHolder.getAbility(/datum/targetable/zombie/infect)
		if (!infect.disabled && infect.cooldowncheck())
			infect.handleCast(target)
			return TRUE

	death(var/gibbed)
		if (istype(src, /mob/living/critter/zombie/biosuit)) return //special death
		if (!gibbed)
			src.unequip_all()
			src.gib()
		..()

	can_critter_attack()
		var/datum/targetable/infect
		switch (src.infection_type)
			if (NO_EAT)
				return ..()
			if (EATS_BRAINS)
				var/datum/targetable/critter/zombify/infect = src.abilityHolder.getAbility(/datum/targetable/critter/zombify)
			if (HUMAN_INFECTION)
				var/datum/targetable/zombie/infect/infect = src.abilityHolder.getAbility(/datum/targetable/zombie/infect)
		return ..() && !infect?.disabled

/mob/living/critter/zombie/scientist
	name = "Shambling Scientist"
	desc = "Physician, heal thyself! Welp, so much for that."
	icon_state = "scizombie"
	health_brute = 15
	health_brute_vuln = 1
	health_burn = 15
	health_brute_vuln = 0.4

/mob/living/critter/zombie/security
	name = "Undead Guard"
	desc = "Eh, couldn't be any worse than regular security."
	icon_state = "seczombie"
	health_brute = 15
	health_brute_vuln = 1
	health_burn = 15
	health_burn_vuln = 1

/mob/living/critter/zombie/biosuit
	name = "Biosuit Shambler"
	desc = "This does not reassure one about biosuit reliability."
	icon_state = "suitzombie"
	health_brute = 8
	health_brute_vuln = 1
	health_burn = 8
	health_burn_vuln = 1
	infection_type = NO_EAT

	death(var/gibbed)
		..()
		src.visible_message("<span class='alert'>Black mist flows from the broken suit!</span>")
		playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
		harmless_smoke_puff(src.loc)
		new /mob/living/critter/aberration(src.loc)
		new /obj/item/clothing/suit/bio_suit(src.loc)
		new /obj/item/clothing/gloves/latex(src.loc)
		new /obj/item/clothing/head/bio_hood(src.loc)
		qdel(src)

//It's like the jam mansion is back!
/mob/living/critter/zombie/wrestler
	name = "Zombie Wrestler"
	desc = "This zombie is hulked out! Watch out for the piledriver!"
	icon_state = "wrestlerzombie"
	health_brute = 20
	health_brute_vuln = 1
	health_burn = 20
	health_burn_vuln = 0.2
	add_abilities = list(/datum/targetable/wrestler/slam) // YEAH YEAH YEAH

	New()
		..()
		src.bioHolder.AddEffect("hulk", magical = TRUE)

	critter_attack(var/mob/target)
		var/obj/item/grab/G = src.equipped()
		if (istype(G))
			if (G.affecting == null || G.assailant == null || G.disposed)
				src.drop_item()
				return
			if (src.critter_ability_attack(target))
				return
		src.drop_item()
		if (src.ai_attack_count >= src.ai_attacks_per_ability)
			if (src.critter_ability_attack(target))
				src.ai_attack_count = 0
				return
		if (src.critter_basic_attack(target))
			src.ai_attack_count += 1

	critter_basic_attack(var/mob/target)
		if (prob(40) && !issilicon(target) && !is_incapacitated(target))
			src.set_a_intent(INTENT_GRAB)
			src.hand_attack(target)
			var/obj/item/grab/G = src.equipped()
			if (istype(G))
				if (G.affecting == null || G.assailant == null || G.disposed)
					src.drop_item()
				G.AttackSelf(src)
		if (src.equipped())
			src.drop_item()
		src.set_a_intent(INTENT_HARM)
		src.hand_attack(target)
		return TRUE

	critter_ability_attack(mob/target)
		var/datum/targetable/wrestler/slam/slam = src.abilityHolder.getAbility(/datum/targetable/wrestler/slam)
		if (!slam.disabled && slam.cooldowncheck())
			slam.handleCast(target)
			return TRUE
		else
			..()

//For Jones City Ruins
/mob/living/critter/zombie/radiation
	name = "Shambling Technician"
	desc = "Looks like they got a large dose of the Zetas."
	icon_state = "radzombie"
	health_brute = 15
	health_brute_vuln = 0.4
	health_burn = 15
	health_burn_vuln = 0.4
	infection_type = NO_EAT
	ai_attacks_per_ability = 4

	New()
		..()
		src.add_simple_light("rad", list(0, 0.8 * 255, 0.3 * 255, 0.8 * 255))

	critter_ability_attack(mob/target)
		boutput(target, "<span class='alert'>You are enveloped by a soft green glow emanating from [src].</span>")
		target.take_radiation_dose(1 SIEVERTS)
		..()

	death()
		..()
		src.remove_simple_light("rad")
		make_cleanable( /obj/decal/cleanable/greenglow,src.loc)

/mob/living/critter/zombie/meatmonaut
	name = "Lost Cosmonaut"
	desc = "Soviet presence near NT stations is rarely overt. For good reasons, as this fellow probably learned too late.  Seriously, where is his face? Grody."
	icon = 'icons/misc/meatland.dmi'
	icon_state = "sovmeat"
	health_brute = 15
	health_brute_vuln = 0.6
	health_burn = 15
	health_burn_vuln = 1

	//playsound(src.loc, 'sound/misc/meatmonaut1.ogg', 50, 0)

#undef NO_EAT
#undef EATS_BRAINS
#undef HUMAN_INFECTION
