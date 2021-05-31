/datum/targetable/spell/magicmissile
	name = "Magic Missile"
	desc = "Attacks nearby foes with stunning projectiles."
	icon_state = "missile"
	targeted = 0
	cooldown = 200
	requires_robes = 1
	offensive = 1
	voice_grim = "sound/voice/wizard/MagicMissileGrim.ogg"
	voice_fem = "sound/voice/wizard/MagicMissileFem.ogg"
	voice_other = "sound/voice/wizard/MagicMissileLoud.ogg"
	var/base_shots = 6
	var/datum/projectile/big_missile = new/datum/projectile/special/homing/magicmissile
	var/datum/projectile/lil_missile = new/datum/projectile/special/homing/magicmissile/weak
	var/datum/projectile/the_missile

	cast()
		if(!holder)
			return

		var/list/missile_targets = list()

		for(var/mob/living/M in oview(7, holder.owner))
			if(isdead(M)) continue
			if (ishuman(M))
				if (M.traitHolder.hasTrait("training_chaplain"))
					boutput(holder.owner, "<span class='alert'>You feel your spell wince at [M]'s divinity! It outright refuses to target \him!</span>")
					JOB_XP(M, "Chaplain", 2)
					continue
			if (iswizard(M))
				boutput(holder.owner, "<span class='alert'>You feel your spell ignore [M], a fellow magical practitioner!</span>")
				continue
			missile_targets += M

		if(!istype(get_area(holder.owner), /area/sim/gunsim))
			holder.owner.say("ICEE BEEYEM") // EHM-EYEARRVEE
		..()

		var/num_shots = src.base_shots
		if(!holder.owner.wizard_spellpower(src))
			boutput(holder.owner, "<span class='alert'>Without a staff, your spell has trouble manifesting its full potential, leaving its effect withered and weak!</span>")
			num_shots *= 0.5
			src.the_missile = src.lil_missile
		else
			src.the_missile = src.big_missile

		for (var/i in 1 to num_shots)
			if(length(missile_targets))
				var/mob/living/L = pick(missile_targets)
				var/turf/target = get_turf(L)
				var/obj/projectile/P = shoot_projectile_ST(holder.owner, src.the_missile, target)
				if (P)
					P.targets = list(L)
					P.mob_shooter = holder.owner
					P.shooter = holder.owner
				missile_targets -= L
			else // we got ammo left, lets just shoot them somewhere or something
				var/obj/projectile/P = shoot_projectile_XY(holder.owner, src.the_missile, cos(rand(0,360)), sin(rand(0,360)))
				if (P)
					P.mob_shooter = holder.owner
					P.shooter = holder.owner

		playsound(holder.owner.loc, "sound/effects/mag_magmislaunch.ogg", 25, 1, -1)
