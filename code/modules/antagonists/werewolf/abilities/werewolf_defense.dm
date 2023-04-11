/datum/targetable/werewolf/werewolf_defense
	name = "Defensive Howl"
	desc = "Start howling and switch to a defensive stance for 15 seconds."
	icon_state = "howl"
	cooldown = 50 SECONDS
	incapacitation_restriction = ABILITY_CAN_USE_WHEN_STUNNED
	can_cast_while_cuffed = TRUE
	werewolf_only = TRUE

	cast(mob/target)
		. = ..()
		target.changeStatus("werewolf_defense_howl", 15 SECONDS)

/datum/statusEffect/defensive_howl
	id = "werewolf_defense_howl"
	name = "Defensive Howl"
	desc = "You are using a defensive stance to block and dodge incoming melee attacks."
	icon_state = "person"
	maxDuration = 15 SECONDS
	unique = TRUE

	onAdd(var/optional)
		. = ..()
		var/mob/living/L = src.owner

		L.visible_message("<span class='alert'><B>[L] shifts to a defensive stance and starts to howl!</B></span>")

		//Do some howling
		playsound(L.loc, 'sound/voice/animal/werewolf_howl.ogg', 65, 1, 0, 0.5) //one really long howl

		if (L.getStatusDuration("burning"))
			L.delStatus("burning")
			L.visible_message("<span class='alert'><B>[L]'s deafening howl completely extinguishes the fire on it!</B></span>")

		L.stance = "defensive"

	onRemove()
		. = ..()
		var/mob/living/L = owner
		L.stance = "normal"
		L.visible_message("<span class='alert'><B>[L] shifts back to a normal werewolf stance! You can totally tell the difference!</B></span>")
		playsound(L, 'sound/voice/animal/werewolf_attack2.ogg', 70, 1, 0, 1.4)
