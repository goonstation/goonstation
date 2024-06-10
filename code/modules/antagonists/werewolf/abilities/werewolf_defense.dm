/datum/targetable/werewolf/werewolf_defense
	name = "Defensive Howl"
	desc = "Start howling and switch to a defensive stance for 15 seconds."
	icon_state = "howl"
	targeted = 0
	target_nodamage_check = 0
	max_range = 0
	cooldown = 500
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	werewolf_only = 1

	cast(mob/target)
		if (!holder)
			return 1
		var/mob/living/M = holder.owner
		if (!M)
			return 1
		var/mob/living/carbon/human/H = M
		if (!istype(H))
			return 1

		if (!iswerewolf(M))
			return 1

		. = ..()
		H.changeStatus("werewolf_defense_howl", 15 SECONDS)

/datum/statusEffect/defensive_howl
	id = "werewolf_defense_howl"
	name = "Defensive Howl"
	desc = "You are using a defensive stance to block and dodge incoming melee attacks."
	icon_state = "person"
	maxDuration = 150
	unique = 1

	onAdd(var/optional=null)
		. = ..()
		var/mob/living/carbon/human/H = owner
		if (!istype(H)) return

		H.visible_message(SPAN_ALERT("<B>[H] shifts to a defensive stance and starts to howl!</B>"))

		//Do some howling
		playsound(H.loc, 'sound/voice/animal/werewolf_howl.ogg', 65, 1, 0, 0.5) //one really long howl

		if (H.getStatusDuration("burning"))
			H.delStatus("burning")
			H.visible_message(SPAN_ALERT("<B>[H] deafening howl completely extinguishes the fire on it!</B>"))

		//SPAWN(8 SECONDS)
		//	playsound(H.loc, 'sound/voice/animal/werewolf_howl.ogg', 70, 1, 0, 0.7)

		H.stance = "defensive"
		return

	onRemove()
		. = ..()
		var/mob/living/carbon/human/H = owner
		if (!istype(H)) return
		H.stance = "normal"
		H.visible_message(SPAN_ALERT("<B>[H] shifts back to a normal werewolf stance! You can totally tell the difference!</B>"))
		playsound(H.loc, 'sound/voice/animal/werewolf_attack2.ogg', 70, 1, 0, 1.4)
		return
