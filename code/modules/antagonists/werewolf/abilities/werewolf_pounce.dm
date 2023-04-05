/datum/targetable/werewolf/werewolf_pounce
	name = "Pounce"
	desc = "Pounce on a target location."
	icon_state = "pounce"
	targeted = 0
	target_nodamage_check = 1
	target_anything = 1
	max_range = 10
	cooldown = 100
	pointCost = 0
	when_stunned = 0
	not_when_handcuffed = 1
	werewolf_only = 1
	restricted_area_check = ABILITY_AREA_CHECK_VR_ONLY

	cast(turf/target)
		if (!holder)
			return 1
		var/mob/living/M = holder.owner

		if (istype(M.loc,/mob/))
			boutput(usr, "<span class='alert'>You can't jump right now!</span>")
			return 1

		var/jump_tiles = max_range
		var/pixel_move = round((8/7)*max_range)
		var/sleep_time = 1

		if (istype(M.loc,/turf))
			playsound(M.loc, 'sound/voice/animal/werewolf_attack2.ogg', 50, 1, 0, 1.4)
			playsound(M.loc, 'sound/effects/swoosh.ogg', 50, 1)

			var/prevLayer = M.layer
			M.layer = EFFECTS_LAYER_BASE
			usr.visible_message("<span class='alert'><b>[M]</b> pounces into the air!</span>")

			for(var/i=0, i < jump_tiles, i++)

				//get the mobs on the next step in the pounce, throw em to the side if they are standing.
				var/turf/next_step = get_step(M, M.dir)
				for (var/mob/A in next_step)
					M.werewolf_attack(A, "pounce")
				step(M, M.dir)
				if(i < jump_tiles / 2)
					M.pixel_y += pixel_move
				else
					M.pixel_y -= pixel_move
				sleep(sleep_time)

			usr.pixel_y = 0

			M.layer = prevLayer

		if (istype(M.loc,/obj/))
			var/obj/container = M.loc
			boutput(M, "<span class='alert'>You leap and slam your head against the inside of [container]! Ouch!</span>")
			M.setStatus("paralysis", 3 SECONDS)
			M.setStatus("weakened", 5 SECONDS)
			container.visible_message("<span class='alert'><b>[M.loc]</b> emits a loud thump and rattles a bit.</span>")
			playsound(container, 'sound/impact_sounds/Metal_Hit_Heavy_1.ogg', 50, 1)
			var/wiggle = 6
			while(wiggle > 0)
				wiggle--
				container.pixel_x = rand(-3,3)
				container.pixel_y = rand(-3,3)
				sleep(0.1 SECONDS)
			container.pixel_x = 0
			container.pixel_y = 0
