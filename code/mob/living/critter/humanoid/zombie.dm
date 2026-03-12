// Maybe replace with NPC humans later? kill obj for now though

#define NO_EAT 0 // Does not eat brains
#define EATS_BRAINS 1 // Eats brains and creates new CRITTER zombies
#define HUMAN_INFECTION 2 // Eats brains and creates new HUMAN zombies

/mob/living/critter/zombie
	name = "zombie"
	desc = "BraaAAAinnsSSs..."
	icon = 'icons/mob/critter/humanoid/zombie.dmi'
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
	var/moan_sounds = list("sound/voice/Zgroan1.ogg", "sound/voice/Zgroan2.ogg", "sound/voice/Zgroan3.ogg", "sound/voice/Zgroan4.ogg")

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

	specific_emotes(var/act, var/param = null, var/voluntary = 0)
		switch (act)
			if ("scream")
				if (src.emote_check(voluntary, 50))
					playsound(src, pick(src.moan_sounds) , 80, 1, channel=VOLUME_CHANNEL_EMOTE)
					return "<b>[src]</b> moans!"
		return null

	specific_emote_type(var/act)
		switch (act)
			if ("scream")
				return 2
		return ..()

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

	Life(datum/controller/process/mobs/parent)
		if (..(parent))
			return 1

		if (src.ai?.enabled)
			if (prob(5))
				playsound(src, pick(moan_sounds), 25, 5)

	valid_target(mob/living/C)
		if (iszombie(C)) return FALSE
		if (ishuman(C))
			var/mob/living/carbon/human/H = C
			if (istype(H.head, /obj/item/clothing/head/void_crown)) return FALSE
		return ..()

	critter_ability_attack(mob/target)
		var/datum/targetable/infect
		switch (src.infection_type)
			if (NO_EAT)
				return FALSE
			if (EATS_BRAINS)
				infect = src.abilityHolder.getAbility(/datum/targetable/critter/zombify)
			if (HUMAN_INFECTION)
				infect = src.abilityHolder.getAbility(/datum/targetable/zombie/infect)
		if (!infect?.disabled && infect.cooldowncheck())
			infect.handleCast(target)
			return TRUE

	death(var/gibbed)
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
				infect = src.abilityHolder.getAbility(/datum/targetable/critter/zombify)
			if (HUMAN_INFECTION)
				infect = src.abilityHolder.getAbility(/datum/targetable/zombie/infect)
		return ..() && !infect?.disabled

/mob/living/critter/zombie/scientist
	name = "shambling scientist"
	desc = "Physician, heal thyself! Welp, so much for that."
	icon_state = "scizombie"
	health_brute = 15
	health_brute_vuln = 1
	health_burn = 15
	health_brute_vuln = 0.4

/mob/living/critter/zombie/security
	name = "undead guard"
	desc = "Eh, couldn't be any worse than regular security."
	icon_state = "seczombie"
	health_brute = 15
	health_brute_vuln = 1
	health_burn = 15
	health_burn_vuln = 1

/mob/living/critter/zombie/biosuit
	name = "biosuit shambler"
	desc = "This does not reassure one about biosuit reliability."
	icon_state = "suitzombie"
	health_brute = 8
	health_brute_vuln = 1
	health_burn = 8
	health_burn_vuln = 1
	infection_type = NO_EAT

	gib()
		src.visible_message(SPAN_ALERT("Black mist flows from the broken suit!"))
		playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
		harmless_smoke_puff(src.loc)
		new /mob/living/critter/aberration(src.loc)
		new /obj/item/clothing/suit/hazard/bio_suit(src.loc)
		new /obj/item/clothing/gloves/latex(src.loc)
		new /obj/item/clothing/head/bio_hood(src.loc)
		qdel(src)

//It's like the jam mansion is back!
/mob/living/critter/zombie/wrestler
	name = "zombie wrestler"
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
		if (prob(20) && !issilicon(target) && !is_incapacitated(target))
			src.do_grab_slam_or_throw(target)
			return
		if (src.ai_attack_count >= src.ai_attacks_per_ability)
			if (src.critter_ability_attack(target))
				src.ai_attack_count = 0
				return
		if (src.critter_basic_attack(target))
			src.ai_attack_count += 1

	critter_basic_attack(var/mob/target)
		if (src.equipped())
			src.drop_item()
		src.set_a_intent(INTENT_HARM)
		src.hand_attack(target)
		return TRUE

	proc/do_grab_slam_or_throw(var/mob/target)
		var/datum/targetable/wrestler/slam/slam = src.abilityHolder.getAbility(/datum/targetable/wrestler/slam)
		src.set_a_intent(INTENT_GRAB)
		src.set_dir(get_dir(src, target))

		var/list/params = list()
		params["left"] = TRUE
		params["ai"] = TRUE

		src.hand_attack(target, params)
		var/obj/item/grab/G = src.equipped()

		if (isnull(G)) //if we somehow have something that isn't a grab in our hand
			src.drop_item()
		else
			if (G.affecting == null || G.assailant == null || G.disposed || isdead(G.affecting))
				src.drop_item()
				return
			G.AttackSelf(src)
			if (!slam.disabled && slam.cooldowncheck())
				slam.handleCast(target)
				src.ai.move_away(target,1)
				return
			else
				for(var/turf/T in view(3, src))
					if(!is_blocked_turf(T))
						src.throw_item(T)

//For Jones City Ruins
/mob/living/critter/zombie/radiation
	name = "shambling technician"
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
		boutput(target, SPAN_ALERT("You are enveloped by a soft green glow emanating from [src]."))
		target.take_radiation_dose(1 SIEVERTS)
		..()

	death()
		..()
		src.remove_simple_light("rad")
		make_cleanable(/obj/decal/cleanable/greenglow, src.loc)

/mob/living/critter/zombie/meatmonaut
	name = "lost cosmonaut"
	desc = "Soviet presence near NT stations is rarely overt. For good reasons, as this fellow probably learned too late.  Seriously, where is his face? Grody."
	icon = 'icons/misc/meatland.dmi'
	icon_state = "sovmeat"
	health_brute = 15
	health_brute_vuln = 0.6
	health_burn = 15
	health_burn_vuln = 1
	moan_sounds = 'sound/misc/meatmonaut1.ogg'

#undef NO_EAT
#undef EATS_BRAINS
#undef HUMAN_INFECTION
