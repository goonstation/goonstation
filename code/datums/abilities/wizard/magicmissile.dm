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

	cast()
		if(!holder)
			return
		var/mob_count = 0, mob_count2 = 0
		var/mob_limit = 6

		for(var/mob/living/M as mob in oview())
			if(isdead(M)) continue
			mob_count++
		if(!mob_count)
			boutput(holder.owner, "Noone is in range!")
			return 1 // cast failed

		holder.owner.say("ICEE BEEYEM")
		..()

		if(!holder.owner.wizard_spellpower(src))
			boutput(holder.owner, "<span class='alert'>Your spell is weak without a staff to focus it!</span>")

		for (var/mob/living/M as mob in oview())
			if (isdead(M)) continue
			if (ishuman(M))
				if (M.traitHolder.hasTrait("training_chaplain"))
					boutput(holder.owner, "<span class='alert'>[M] has divine protection! The spell refuses to target \him!</span>")
					JOB_XP(M, "Chaplain", 2)
					continue
			if (iswizard(M))
				boutput(holder.owner, "<span class='alert'>[M] has arcane protection! The spell refuses to target \him!</span>")
				continue

			playsound(holder.owner.loc, "sound/effects/mag_magmislaunch.ogg", 25, 1, -1)
			if ((!holder.owner.wizard_spellpower(src) && mob_count2 >= 1) || (mob_count2 >= mob_limit)) break
			mob_count2++
			SPAWN_DBG(0)
				var/obj/overlay/A = new /obj/overlay(holder.owner.loc)
				A.icon_state = "magicm"
				A.icon = 'icons/obj/wizard.dmi'
				A.name = "a magic missile"
				A.anchored = 0
				A.set_density(0)
				A.layer = EFFECTS_LAYER_1
				A.flags |= TABLEPASS
				//A.sd_SetLuminosity(3)
				//A.sd_SetColor(0.7, 0, 0.7)
				var/i
				for(i=0, i<20, i++)
					var/obj/overlay/B = new /obj/overlay(A.loc)
					B.icon_state = "magicmd"
					B.icon = 'icons/obj/wizard.dmi'
					B.name = "trail"
					B.anchored = 1
					B.set_density(0)
					B.layer = EFFECTS_LAYER_BASE
					SPAWN_DBG(0.5 SECONDS)
						qdel(B)
					step_to(A,M,0)
					if (get_dist(A,M) == 0)
						M.changeStatus("weakened", (5 - (min(mob_count2,4)))*10)
						M.force_laydown_standup()
						boutput(M, text("<span class='notice'>The magic missile SLAMS into you!</span>"))
						M.visible_message("<span class='alert'>[M] is struck by a magic missile!</span>")
						playsound(M.loc, "sound/effects/mag_magmisimpact.ogg", 25, 1, -1)
						M.TakeDamage("chest", 0, 10, 0, DAMAGE_BURN)
						random_brute_damage(M, 5)
						M.lastattacker = holder.owner
						M.lastattackertime = world.time
						qdel(A)
						return
					sleep(0.6 SECONDS)
				qdel(A)
