
/obj/storage/closet/coffin/vampire
	name = "vampiric coffin"
	desc = "A vampire's place of rest. They can regenerate while inside."
	icon_state = "vampcoffin"
	icon_closed = "vampcoffin"
	icon_opened = "vampcoffin-open"
	_max_health = 50
	_health = 50

	open(entangleLogic, mob/user)
		if (!isvampire(user))
			return
		. = ..()

	attack_hand(mob/user)
		if (!isvampire(user))
			if (user.a_intent == INTENT_HELP)
				user.show_text("It won't budge!", "red")
			else
				user.show_text("It's built tough! A weapon would be more effective.", "red")
			return

		..()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if (!isvampire(user))
			user.show_text("It won't budge!", "red")
		else
			..()

	attackby(obj/item/I, mob/user)
		user.lastattacked = src
		_health -= I.force
		attack_particle(user,src)
		playsound(src.loc, 'sound/impact_sounds/Wood_Hit_1.ogg', 50, 1, pitch = 1.1)

		if (_health <= 0)
			logTheThing(LOG_COMBAT, user, "destroyed [src] at [log_loc(src)]")
			bust_out()


/datum/targetable/vampire/mark_coffin
	name = "Hide Coffin"
	desc = "Pick an area for your coffin to be hidden. The coffin is intangible until you use the Coffin Escape ability."
	icon_state = "coffin"
	targeted = 1
	target_anything = 1
	target_nodamage_check = 1
	max_range = 999
	cooldown = 600
	pointCost = 0
	when_stunned = 1
	not_when_handcuffed = 0
	sticky = 1
	unlock_message = "You have gained Hide Coffin. It allows you to hide a coffin somewhere on the station."



	cast(turf/target)
		if (!holder)
			return 1

		if (!isturf(target))
			target = get_turf(target)

		if (!target)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/V = holder

		if (istype(target,/turf/space) || isrestrictedz(target.z))
			boutput(M, "<span class='alert'>You cannot place your coffin there.</span>")
			return 1

		V.coffin_turf = target
		boutput(M, "<span class='notice'>You plant your coffin on [target].</span>")

		logTheThing(LOG_COMBAT, M, "marks coffin on tile on [constructTarget(target,"combat")] at [log_loc(M)].")
		return 0

/datum/targetable/vampire/coffin_escape
	name = "Coffin Escape"
	desc = "Become temporarily intangible and escape to a coffin where you can regenerate. If you have previously used Hide Coffin, the coffin will appear in that location."
	icon_state = "mist"
	targeted = 0
	target_nodamage_check = 1
	max_range = 999
	cooldown = 600
	pointCost = 400
	when_stunned = 1
	not_when_handcuffed = 0
	sticky = 1
	unlock_message = "You have gained Coffin Escape. It allows you to heal within a coffin."

	cast(mob/target)
		if (!holder)
			return 1

		var/mob/living/M = holder.owner
		var/datum/abilityHolder/vampire/V = holder

		if (!V.coffin_turf)
			V.coffin_turf = get_turf(M)

		var/turf/spawnturf = V.coffin_turf
		if (istype(spawnturf,/turf/space))
			spawnturf = get_turf(M)
		var/turf/owner_turf = get_turf(M)
		if (spawnturf.z != owner_turf?.z)
			boutput(M, "<span class='alert'>You cannot escape to a different Z-level.</span>")
			return 1


		var/obj/storage/closet/coffin/vampire/coffin = new(spawnturf)
		animate_buff_in(coffin)

		V.the_coffin = coffin

		var/obj/projectile/proj = initialize_projectile_ST(M, new/datum/projectile/special/homing/travel, spawnturf)
		var/tries = 5
		while (tries > 0 && (!proj || proj.disposed))
			proj = initialize_projectile_ST(M, new/datum/projectile/special/homing/travel, spawnturf)

		proj.special_data["owner"] = M
		proj.targets = list(coffin)

		proj.launch()

		logTheThing(LOG_COMBAT, M, "begins escaping to a coffin from [log_loc(M)] to [log_loc(V.coffin_turf)].")

		if (get_turf(coffin) == get_turf(M))
			M.set_loc(coffin)

		return 0
