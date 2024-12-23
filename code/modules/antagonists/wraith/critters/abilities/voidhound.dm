/datum/targetable/critter/voidhound/cloak
	name = "Cloak"
	desc = "Slip into the void and make yourself hard to discern for a short time"
	icon_state = "cloak"
	cooldown = 40 SECONDS
	targeted = 0
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	cast()
		if (..())
			return 1

		if(istype(holder.owner, /mob/living/critter/wraith/voidhound))
			var/mob/living/critter/wraith/voidhound/V = holder.owner
			animate(V, alpha=30, time=3 SECONDS)
			boutput(V, SPAN_NOTICE("We slip into the shadows..."))
			V.cloaked = TRUE
			SPAWN(20 SECONDS)
				if(V?.cloaked)
					animate(V, alpha=255, time=3 SECONDS)
					boutput(V, SPAN_ALERT("We reappear..."))
					V.cloaked = FALSE

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")

/datum/targetable/critter/voidhount/rushdown
	name = "Rush down"
	desc = "Leap forward and knock down those in your way"
	icon_state = "pounce"
	cooldown = 40 SECONDS
	targeted = 0
	max_range = 5
	var/border_icon = 'icons/mob/wraith_ui.dmi'
	var/border_state = "harbinger_frame"

	cast()

		if (..())
			return 1

		var/mob/living/M = holder.owner

		if (istype(M.loc,/mob/))
			boutput(usr, SPAN_ALERT("You can't jump right now!"))
			return 1

		var/jump_tiles = max_range
		var/pixel_move = round((8/7)*max_range)
		var/sleep_time = 1

		if (istype(holder.owner, /mob/living/critter/wraith/voidhound))
			var/mob/living/critter/wraith/voidhound/V = holder.owner
			if(V.cloaked)
				animate(V, alpha=255, time=1 SECONDS)
				boutput(V, SPAN_NOTICE("We leap out of the shadows"))

		if (istype(M.loc,/turf))
			playsound(M.loc, 'sound/voice/animal/werewolf_attack2.ogg', 50, 1, 0, 1.4)
			playsound(M.loc, 'sound/effects/swoosh.ogg', 50, 1)

			var/prevLayer = M.layer
			M.layer = EFFECTS_LAYER_BASE
			usr.visible_message(SPAN_ALERT("<b>[M]</b> pounces into the air!"))

			for(var/i in 1 to jump_tiles)

				//get the mobs on the next step in the pounce, throw em to the side if they are standing.
				var/turf/next_step = get_step(M, M.dir)
				for (var/mob/A in next_step)
					playsound(M.loc, 'sound/impact_sounds/Generic_Hit_3.ogg', 50, 1)
					A.setStatus("knockdown", 3 SECONDS)
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
			boutput(M, SPAN_ALERT("You leap and slam your head against the inside of [container]! Ouch!"))
			M.setStatus("unconscious", 3 SECONDS)
			M.setStatus("knockdown", 5 SECONDS)
			container.visible_message(SPAN_ALERT("<b>[M.loc]</b> emits a loud thump and rattles a bit."))
			animate_storage_thump(container)
			if (prob(25))
				if (istype(container, /obj/storage))
					var/obj/storage/C = container
					if (C.can_flip_bust == 1)
						boutput(src, SPAN_ALERT("[C] [pick("busts","bends","cracks")] open."))
						C.bust_out()

	onAttach(datum/abilityHolder/holder)
		..()
		var/atom/movable/screen/ability/topBar/B = src.object
		B.UpdateOverlays(image(border_icon, border_state), "mob_type")
