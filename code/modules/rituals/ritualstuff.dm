
/datum/preMapLoad/New()
	..()
	Z_LOG_DEBUG("Preload", "  /datum/ritual")
	for(var/A in childrentypesof(/datum/ritual))
		var/datum/ritual/R = new A()
		globalRituals.Add(R)

	Z_LOG_DEBUG("Preload", "  /datum/ritualComponent")
	for(var/A in childrentypesof(/datum/ritualComponent))
		var/datum/ritualComponent/R = new A()
		globalRitualComponents.Add(R)
		globalRitualAnchors.Remove(R)

/datum/statusEffect
	simplehot
		ritual
			id = "ritual_hot"
			name = "Healing ritual"
			icon_state = "+"
			heal_burn = 0.5
			heal_tox = 0.5
			heal_brute = 0.5
			unique = 1

			onAdd()
				. = ..()
				ritualBuffEffect("buff-life", owner)
				return

			onRemove()
				. = ..()
				owner.UpdateOverlays(null, "buff-life")
				return

			getTooltip()
				return "Healing 0.5 damage of every type, every [tickSpacing/(1 SECOND)] sec."

	simpledot
		ritual
			id = "ritual_dot"
			name = "Cursed ritual"
			icon_state = "+"
			damage_burn = 0.5
			damage_tox = 0.5
			damage_brute = 0.5
			unique = 1

			onAdd()
				. = ..()
				ritualBuffEffect("buff-lifec", owner)
				return

			onRemove()
				. = ..()
				owner.UpdateOverlays(null, "buff-lifec")
				return

			getTooltip()
				return "Inflicting 0.5 damage of every type, every [tickSpacing/(1 SECOND)] sec."

	airrit
		id = "airrit"
		name = "Air infused"
		desc = "Infused with airy energy."
		icon_state = "airbuff"
		unique = 1
		var/buffer = 0
		movement_modifier = /datum/movement_modifier/airrit

		onAdd()
			. = ..()
			if(isobj(owner))
				ritualBuffEffect("buff-air-obj", owner)
			else
				ritualBuffEffect("buff-air", owner)
			return

		onRemove()
			. = ..()
			owner.UpdateOverlays(null, "buff-air")
			return

		onUpdate(timePassed)
			buffer += timePassed
			if (owner.hasStatus(list("stunned", "knockdown", "unconscious", "pinned", "disoriented")))
				owner.delStatus(id)	//delete this status

			if(buffer >= 1 SECOND)
				buffer = 0
				for(var/atom/movable/A in oview(1, owner))
					if(!A.anchored)
						var/turf/T = get_step_away(A, owner)
						step_to(A,T)
				ritualEffect(aloc = get_turf(owner), istate = "air-old2", duration = 50, aoe = 0)
			return

	stonerit
		id = "stonerit"
		name = "Earth infused"
		desc = "Infused with earthen energy.<br>Block chance increased by 20%."
		icon_state = "stone"
		unique = 1

		onAdd()
			. = ..()
			if(isobj(owner))
				ritualBuffEffect("buff-earth-obj", owner)
			else
				ritualBuffEffect("buff-earth", owner)
			return

		onRemove()
			. = ..()
			owner.UpdateOverlays(null, "buff-earth")
			return

	firerit
		id = "firerit"
		name = "Fire infused"
		desc = "Infused with fiery energy."
		icon_state = "match"
		unique = 1
		var/wait = 0

		onAdd()
			. = ..()
			owner.name_prefix("fiery")
			owner.UpdateName()
			if(isobj(owner))
				ritualBuffEffect("buff-fire-obj", owner)
			else
				ritualBuffEffect("buff-fire", owner)
			return

		onRemove()
			. = ..()
			owner.remove_prefixes()
			owner.UpdateName()
			owner.UpdateOverlays(null, "buff-fire")
			return

		onUpdate(timePassed)
			wait += timePassed
			if(wait > 10)
				if(prob(33)) shoot_projectile_ST_pixel_spread(owner, new/datum/projectile/bullet/flare(), pick(view(8,owner)))
				wait = 0
			return

/datum/particleType/ritual
	name = "ritual"
	icon = 'icons/effects/ritual_effects.dmi'
	icon_state = "ritualspark"

	MatrixInit()
		..()

	Apply(obj/particle/par)
		if(..())
			var/scale = (rand(33, 133) / 100)
			first = matrix()
			second = turn(first, rand(0, 180))
			first *= scale
			second *= scale

			par.blend_mode = BLEND_ADD
			par.pixel_x = rand(-14, 14)
			par.pixel_y = rand(-14, 14)
			//par.alpha = 220
			icon_state = pick("ritualspark1","ritualspark2","ritualspark3","ritualspark4","ritualspark5")

			par.transform = first

			if(!length(par.vis_locs))
				return
			var/turf/T = par.vis_locs[1]

			var/move_x = ((par.target.x - T.x) * 32) + rand(-5,5)
			var/move_y = ((par.target.y - T.y) * 32) + rand(-5,5)

			animate(par, transform = second, alpha = 100, time = 25, pixel_y = move_y,  pixel_x = move_x , easing = SINE_EASING)
			animate(alpha = 0, time = 5)

/datum/particleSystem/ritual
	New(var/atom/location, var/atom/target)
		..(location, "ritual", 30, "#ffffff", target)

	InitPar()
		sleepCounter = 5

	Run()
		if (..())
			if (sleepCounter > 0)
				sleepCounter--
				SPAWN(0)
					for(var/i=0, i<2, i++)
						if(src)
							SpawnParticle()
							sleep(0.5 SECONDS)
				Sleep(1)
			else
				Die()

/datum/bioEffect/hidden/sacrificed
	name = "Husk"
	desc = "Subject appears to have no life essence."
	id = "sacrificed"
	effectType = EFFECT_TYPE_DISABILITY
	isBad = 1
	can_copy = 0
	acceptable_in_mutini = 0

	OnMobDraw()
		if (..())
			return
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.body_standing:overlays += image('icons/mob/human.dmi', "husk")

	OnAdd()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.set_body_icon_dirty()
			if (!H.organHolder) return

			var/datum/organHolder/OH = H.organHolder
			//Qdel all organs. It's not super important that this happens instantly so qdel should be fine.
			//Except for some. head, chest, and most importantly: the brain, wanna let em clone
			qdel(OH.skull)
			qdel(OH.left_eye)
			qdel(OH.right_eye)
			qdel(OH.heart)
			qdel(OH.left_lung)
			qdel(OH.right_lung)
			qdel(OH.left_kidney)
			qdel(OH.right_kidney)
			qdel(OH.liver)
			qdel(OH.spleen)
			qdel(OH.pancreas)
			qdel(OH.stomach)
			qdel(OH.intestines)
			qdel(OH.appendix)
			qdel(OH.butt)
		. = ..()

	OnRemove()
		if (ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.set_body_icon_dirty()
		. = ..()

/datum/movement_modifier/airrit
	additive_slowdown = -0.5


// stuff from old ritualstuff_after.dm

/obj/hear_talk(mob/M as mob, text, real_name)
	..()
	if(src.ritualComponent)
		src.ritualComponent.hear_talk(M, text, real_name)

/atom/movable/set_loc(var/newloc as turf|mob|obj in world)
	if (..() && loc != newloc)
		if (src.ritualComponent)
			src.ritualComponent.breakLinks()
			if(isturf(newloc))
				if(istype(src, /datum/ritualComponent/anchor))
					var/datum/ritualComponent/anchor/A = src
					A.linkComponents()
				else
					src.ritualComponent.findAnchor()

/obj/item/storage/bible
	New()
		..()
		if (!src.ritualComponent)
			src.ritualComponent = new/datum/ritualComponent/sanctus(src)
			src.ritualComponent.autoActive = 1
