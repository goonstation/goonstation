
/datum/blob_ability/upgrade
	name = "Toggle Upgrade Bar"
	desc = "Expand or contract the upgrades bar."
	icon_state = "blob-viewupgrades"
	targeted = 0
	special_screen_loc = "SOUTH,WEST"
	helpable = 0
	tooltip_options = list("align" = TOOLTIP_TOP, "bounds" = list(16, 32))

	onUse(var/turf/T)
		if (..())
			return
		if (owner.viewing_upgrades)
			owner.viewing_upgrades = 0
		else
			owner.viewing_upgrades = 1
		owner.update_buttons()

//////////////
// UPGRADES //
//////////////

/datum/blob_upgrade
	var/name = null
	var/desc = null
	var/icon = 'icons/mob/blob_ui.dmi'
	var/icon_state = "blob-template"
	var/evo_point_cost = 0
	var/last_used = 0
	var/repeatable = 0
	var/initially_disabled = 0
	var/scaling_cost_mult = 1
	var/scaling_cost_add = 0
	var/mob/living/intangible/blob_overmind/owner
	var/atom/movable/screen/blob/button
	var/upgradename = "upgrade"
	var/purchased_times = 0 // For crew credits
	var/list/tooltip_options = list("align" = TOOLTIP_TOP)

	New()
		..()
		var/atom/movable/screen/blob/B = new /atom/movable/screen/blob(null)
		B.icon = src.icon
		B.icon_state = src.icon_state
		B.upgrade = src
		B.name = src.name
		B.desc = src.desc
		B.tooltip_options = src.tooltip_options
		src.button = B

	disposing()
		if(button)
			button.dispose()
			button = null
		owner = null
		..()

	proc/check_requirements()
		if (!istype(owner))
			return 0
		if (owner.evo_points < evo_point_cost)
			//boutput(owner, SPAN_ALERT("You need [bio_point_cost] bio-points to take this upgrade."))
			return 0
		return 1

	// Wholesale stolen from ability_parent
	proc/update_cooldown_cost()
		if (!button)
			return
		var/newcolor = null

		if (evo_point_cost)
			if (owner.evo_points < evo_point_cost)
				newcolor = rgb(64, 64, 64)
				button.point_overlay.maptext = "<span class='sh vb r ps2p' style='color: #cc2222;'>[evo_point_cost]</span>"
			else
				button.point_overlay.maptext = "<span class='sh vb r ps2p'>[evo_point_cost]</span>"
		else
			button.point_overlay.maptext = null

		if (newcolor != button.color)
			button.color = newcolor


	proc/deduct_evo_points()
		if (evo_point_cost == 0)
			return
		owner.evo_points = max(0,round(owner.evo_points - evo_point_cost))
		src.evo_point_cost = round(src.evo_point_cost * src.scaling_cost_mult)
		src.evo_point_cost += scaling_cost_add


	proc/take_upgrade()
		if (!istype(owner))
			return 1
		if (!tutorial_check())
			return 1
		if (!(src in owner.upgrades))
			owner.upgrades += src
		if (repeatable > 0)
			repeatable--
		if (repeatable == 0)
			owner.available_upgrades -= src
		if (prob(80))
			owner.playsound_local(owner.loc, 'sound/voice/blob/blobup1.ogg', 50, 1)
		else if (prob(50))
			owner.playsound_local(owner.loc, 'sound/voice/blob/blobup2.ogg', 50, 1)
		else
			owner.playsound_local(owner.loc, 'sound/voice/blob/blobup3.ogg', 50, 1)

		purchased_times++
		owner.update_buttons()

	proc/tutorial_check()
		if (owner)
			if (owner.tutorial)
				if (!owner.tutorial.PerformAction("upgrade-[upgradename]", null))
					return 0
		return 1

/datum/blob_upgrade/extra_genrate
	name = "Passive: Increase Generation Rate"
	icon_state = "blob-genrate"
	desc = "Increases your BP generation rate by 2. Can be repeated."
	evo_point_cost = 1
	scaling_cost_add = 1
	repeatable = -1
	upgradename = "genrate"

	take_upgrade()
		if (..())
			return 1
		owner.gen_rate_bonus += 2
		owner.update_buttons()

/datum/blob_upgrade/quick_spread
	name = "Passive: Quicker Spread"
	icon_state = "blob-quickspread"
	desc = "Reduces the cooldown of your Spread ability by 0.5 seconds. Can be repeated. The cooldown of Spread cannot go below 0.6 seconds."
	evo_point_cost = 3
	scaling_cost_add = 3
	repeatable = -1
	upgradename = "spread"

	take_upgrade()
		if (..())
			return 1
		owner.spread_upgrade++

/datum/blob_upgrade/spread
	name = "Passive: Spread Upgrade"
	icon_state = "blob-spread-upgrade"
	desc = "When spreading, adds a cumulative 20% chance to spread off another, random tile on your screen. Every time your chance hits a multiple of 100%, the spread for that amount of tiles is guaranteed and a new chance is added for an extra tile. For example, at 120%, you have a 100% chance to spread twice; with a 20% chance to spread three times instead."
	evo_point_cost = 1
	scaling_cost_add = 1
	repeatable = -1
	upgradename = "multispread"

	take_upgrade()
		if (..())
			return 1
		owner.multi_spread += 20

/datum/blob_upgrade/attack
	name = "Passive: Attack Upgrade"
	icon_state = "blob-attack-upgrade"
	desc = "Increases your attack damage and the chance of mob knockdown. Can be repeated."
	evo_point_cost = 1
	scaling_cost_add = 1
	repeatable = -1
	upgradename = "attack"

	take_upgrade()
		if (..())
			return 1
		owner.attack_power += 0.34

/datum/blob_upgrade/fire_resist
	name = "Passive: Fire Resistance"
	icon_state = "blob-fireresist"
	desc = "Makes your blob become more resistant to fire and heat based attacks."
	evo_point_cost = 2
	upgradename = "fireres"

/datum/blob_upgrade/poison_resist
	name = "Passive: Poison Resistance"
	icon_state = "blob-poisonresist"
	desc = "Makes your blob become more resistant to chemical attacks."
	evo_point_cost = 2
	upgradename = "poisonres"

/datum/blob_upgrade/devour_item
	name = "Ability: Devour Item"
	icon_state = "blob-digest-upgrade"
	desc = "Unlocks the Devour Item ability, which can be used to near-instantly break down any item adjacent to any blob tile. In addition, a reagent deposit is created in the blob if the item contained any reagents. Reagent deposits can be used with various blob elements. Material bearing objects will break down into material deposits, which can be used to reinforce your blob."
	evo_point_cost = 1
	upgradename = "digest"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/devour_item)

/datum/blob_upgrade/bridge
	name = "Structure: Bridge"
	icon_state = "blob-bridge-upgrade"
	desc = "Unlocks the Bridge blob bit, which can be placed on space tiles. Bridges are floor tiles, you still need to spread onto them, and cannot spread from them."
	evo_point_cost = 1
	initially_disabled = 0
	upgradename = "bridge"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/bridge)

/datum/blob_upgrade/launcher
	name = "Structure: Slime Launcher"
	icon_state = "blob-cannon-upgrade"
	desc = "Unlocks the Slime Launcher blob bit, which fires at nearby mobs at the cost of biopoints. Slime inflicts a short stun and minimal damage."
	upgradename = "launcher"

	evo_point_cost = 1

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/build/launcher)

/datum/blob_upgrade/plasmaphyll
	name = "Structural: Plasmaphyll"
	icon_state = "blob-plasmaphyll-upgrade"
	desc = "Unlocks the plasmaphyll blob bit, which passively protects an area from plasma by converting it to biopoints."
	evo_point_cost = 1
	upgradename = "plasmaphyll"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/build/plasmaphyll)

/datum/blob_upgrade/ectothermid
	name = "Structural: Ectothermid"
	icon_state = "blob-ectothermid-upgrade"
	desc = "Unlocks the ectothermid blob bit, which passively an protects area from temperature. This protection consumes biopoints."
	evo_point_cost = 2
	upgradename = "ectothermid"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/build/ectothermid)

/datum/blob_upgrade/reflective
	name = "Structural: Reflective Membrane"
	icon_state = "blob-reflective-upgrade"
	desc = "Unlocks the reflective membrane, which is immune to energy projectiles."
	evo_point_cost = 1
	upgradename = "reflective"

	take_upgrade()
		if (..())
			return 1
		owner.add_ability(/datum/blob_ability/build/reflective)

