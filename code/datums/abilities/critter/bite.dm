// -----------------
// Simple bite skill
// -----------------
/datum/targetable/critter/bite
	name = "Chomp"
	desc = "Chomp down on a mob, causing damage and a short stun."
	cooldown = 150
	targeted = 1
	target_anything = 1
	var/sound_bite = 'sound/voice/animal/werewolf_attack1.ogg'
	var/brute_damage = 16

	var/datum/projectile/slam/proj = new

	cast(atom/target)
		if (..())
			return 1
		if (isobj(target))
			target = get_turf(target)
		if (isturf(target))
			target = locate(/mob/living) in target
			if (!target)
				boutput(holder.owner, __red("Nothing to bite there."))
				return 1
		if (target == holder.owner)
			return 1
		if (get_dist(holder.owner, target) > 1)
			boutput(holder.owner, __red("That is too far away to bite."))
			return 1
		playsound(target, src.sound_bite, 50, 1, -1)
		var/mob/MT = target
		MT.TakeDamageAccountArmor("All", src.brute_damage, 0, 0, DAMAGE_CRUSH)
		MT.changeStatus("stunned", 2 SECONDS)
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] bites [MT]!</b></span>", "<span class='combat'>You bite [MT]!</span>")
		return 0

/datum/targetable/critter/bite/big
	name = "Bite"
	desc = "Bite down on a mob, causing some damage."
	cooldown = 100
	sound_bite = 'sound/impact_sounds/Flesh_Crush_1.ogg'
	brute_damage = 18

	cast(atom/target)
		if (..())
			return 1
		playsound(target, src.sound_bite, 100, 1, -1)
		var/mob/MT = target
		MT.TakeDamageAccountArmor("All", src.brute_damage, 0, 0, DAMAGE_CRUSH)
		holder.owner.visible_message("<span class='combat'><b>[holder.owner] savagely bites [MT]!</b></span>", "<span class='combat'>You savagely bite [MT]!</span>")
		return 0
