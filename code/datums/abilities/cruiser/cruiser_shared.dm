/datum/targetable/cruiser/cancel_camera
	name = "Cancel camera view"
	desc = "Cancels your current camera view."
	icon_state = "cancelcam"
	cooldown = 0
	targeted = 0
	target_anything = 0
	lock_holder = FALSE
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return 1

		var/mob/M = holder.owner
		M.set_eye(null)
		M.client.view = world.view
		holder.removeAbility(/datum/targetable/cruiser/cancel_camera)

/datum/targetable/cruiser/toggle_interior
	name = "Toggle Interior"
	desc = "Enables/disables the interior"
	icon_state = "cancelcam"
	cooldown = 0
	targeted = 0
	target_anything = 0
	lock_holder = FALSE
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return 1

		var/mob/M = holder.owner
		if(istype(M.loc, /obj/machinery/cruiser_destroyable/cruiser_pod))
			var/obj/machinery/cruiser_destroyable/cruiser_pod/C = M.loc
			C.interior.ship.toggle_interior(M)


/datum/targetable/cruiser/exit_pod
	name = "Exit Pod"
	desc = "Exit the pod you are currently in."
	icon_state = "cruiser_exit"
	cooldown = 0
	targeted = 0
	target_anything = 0
	lock_holder = FALSE // Dunno about your WIP stuff. Adjust as needed.
	ignore_holder_lock = 1


	cast(atom/target)
		if (..())
			return 1

		if(istype(holder.owner.loc, /obj/machinery/cruiser_destroyable/cruiser_pod))
			var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
			C.exitPod(holder.owner)



/datum/targetable/cruiser/warp
	name = "Warp"
	desc = "Warp to a beacon."
	icon_state = "warp"
	cooldown = 10
	targeted = 0
	target_anything = 0
	lock_holder = FALSE
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return 1

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/cruiser/I = C.loc.loc
		if (I) //ZeWaka: Fix for null.ship
			var/obj/machinery/cruiser/P = I.ship
			if (P.engine)
				P.warp()

/datum/targetable/cruiser/fire_weapons
	name = "Fire Weapons"
	desc = "Fire the cruisers main weapons at the specified target."
	icon_state = "cruiser_shoot"
	cooldown = 10
	targeted = 1
	target_anything = 1
	sticky = 1
	lock_holder = FALSE
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return 1

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/cruiser/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		cooldown = P.fireAt(target)

/datum/targetable/cruiser/shield_overload
	name = "Overload shield (90 Power/5)"
	desc = "Overloads the cruiser's shields, providing increased shield regeneration even during sustained damage, for 15 seconds."
	icon_state = "shieldboost"
	cooldown = 200
	targeted = 0
	target_anything = 0
	lock_holder = FALSE
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return 1

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/cruiser/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		P.overload_shields()

/datum/targetable/cruiser/weapon_overload
	name = "Overload weapons (90 Power/5)"
	desc = "Overloads the cruiser's weapons, reducing cooldown times for 10 seconds."
	icon_state = "weaponboost"
	cooldown = 250
	targeted = 0
	target_anything = 0
	lock_holder = FALSE
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return 1

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/cruiser/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		P.overload_weapons()

/datum/targetable/cruiser/shield_modulation
	name = "Modulate shields (90 Power, Toggle)"
	desc = "Continually modulates the frequency of the cruiser's shields while active, eliminating the weakness to energy weapons."
	icon_state = "shieldmod"
	cooldown = 10
	targeted = 0
	target_anything = 0
	lock_holder = FALSE
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return 1

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/cruiser/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		P.toggleShieldModulation()

/datum/targetable/cruiser/firemode
	name = "Switch fire mode"
	desc = "Changes which weapons fire."
	icon_state = "firemode"
	cooldown = 0
	targeted = 0
	target_anything = 0
	lock_holder = FALSE
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return 1

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/cruiser/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		P.switchFireMode()

/datum/targetable/cruiser/ram
	name = "Ramming mode"
	desc = "Enabled ramming mode."
	icon_state = "ram"
	cooldown = 100
	targeted = 0
	target_anything = 0
	lock_holder = FALSE
	ignore_holder_lock = 1

	cast(atom/target)
		if (..())
			return 1

		var/obj/machinery/cruiser_destroyable/cruiser_pod/C = holder.owner.loc
		var/area/cruiser/I = C.loc.loc
		var/obj/machinery/cruiser/P = I.ship
		P.enableRamming()
