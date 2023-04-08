// -----------------
// Simple bite skill
// -----------------
/datum/targetable/critter/bite
	name = "Chomp"
	desc = "Chomp down on a mob, causing damage and a short stun."
	icon_state = "critter_bite"
	cooldown = 150
	targeted = 1
	target_anything = 1
	var/sound_bite = 'sound/voice/animal/werewolf_attack1.ogg'
	var/sound_volume = 50
	var/brute_damage = 16
	var/stun_duration = 2 SECONDS
	var/verb_other = "bites"
	var/verb_self = "bite"
	var/hit_type = DAMAGE_CRUSH
	var/bleed = 0

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, "<span class='alert'>Nothing to bite there.</span>")
				return 1
		if (target == holder.owner)
			return 1
		if (BOUNDS_DIST(holder.owner, target) > 0)
			boutput(holder.owner, "<span class='alert'>That is too far away to bite.</span>")
			return 1
		playsound(target, src.sound_bite, sound_volume, 1, -1)
		var/mob/MT = target
		MT.TakeDamageAccountArmor("All", src.brute_damage, 0, 0, DAMAGE_CRUSH)
		MT.changeStatus("stunned", stun_duration)
		if(bleed)
			take_bleeding_damage(MT, null, bleed, DAMAGE_CUT, bleed-5, get_turf(MT))

		holder.owner.visible_message("<span class='combat'><b>[holder.owner] [verb_other] [MT]!</b></span>", "<span class='combat'>You [verb_self] [MT]!</span>")
		return 0

/datum/targetable/critter/bite/big
	name = "Bite"
	desc = "Bite down on a mob, causing some damage."
	cooldown = 30 SECONDS
	sound_bite = 'sound/impact_sounds/Flesh_Crush_1.ogg'
	brute_damage = 30
	bleed = 15
	sound_volume = 100
	verb_other = "savagely bites"
	verb_self = "savagely bite"

/datum/targetable/critter/bite/maneater_bite
	name = "Munch"
	desc = "Munch down on a mob, dealing brute damage and a short stun."
	icon_state = "maneater_munch"
	cooldown = 25 SECONDS
	sound_bite = 'sound/impact_sounds/Flesh_Crush_1.ogg'
	sound_volume = 100
	brute_damage = 20
	bleed = 25
	hit_type = DAMAGE_CUT
	verb_other = "munches on"
	verb_self = "munch on"


/datum/targetable/critter/bite/fermid_bite
	name = "Chomp"
	desc = "Chomp down on a target, causing brute damage and bleed."
	icon_state = "fermid_bite"
	cooldown = 15 SECONDS
	sound_bite = 'sound/impact_sounds/Flesh_Crush_1.ogg'
	sound_volume = 60
	brute_damage = 10
	hit_type = DAMAGE_CUT
	verb_other = "chomps down on"
	verb_self = "bite"
	bleed = 15
	stun_duration = 0


/datum/targetable/critter/bite/tomato_bite
	name = "Chomp"
	desc = "Chomp down on a target, causing some serious pain."
	icon_state = "tomato_bite"
	cooldown = 10 SECONDS
	sound_bite = 'sound/impact_sounds/Flesh_Crush_1.ogg'
	bleed = 15
	brute_damage = 8
