/// Pick(1 tile), hammer(line across), drill(line in front), blaster(cone),
/obj/item/mining_head
	name = "mining tool head"
	desc = "A mining tool head."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "powerpick"

	drill
		name = "drill head"
		desc = "A drill head."
		icon_state = "drillhead"

	hammer
		name = "hammer head"
		desc = "A hammer head."
		icon_state = "hammerhead"

	pick
		name = "pick head"
		desc = "A pick head."
		icon_state = "pickhead"

	blaster
		name = "blaster head"
		desc = "A blaster head."
		icon_state = "blasterhead"

/obj/item/mining_mod
	name = "mining mod"
	desc = "A mod for mining tools."
	icon = 'icons/obj/items/mining.dmi'
	icon_state = "mod_none"

	conc
		name = "Concussive Mining Mod"
		desc = "A mod for mining tools. Increases AOE."
		icon_state = "mod_conc"

/obj/item/mining_tools
	name = "mining tool"
	desc = "A simple mining tool."
	icon = 'icons/obj/items/mining.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "powerpick"
	item_state = "ppick"

	var/blasting = 0 //Small Aoe damage around normal hit tiles.
	var/powered = 0 //Undecided.

	var/power = 5 //Damage to asteroid tiles.
	var/hit_sound = 'sound/items/mining_drill.ogg'

	flags = EXTRADELAY | TABLEPASS | CONDUCT
	c_flags = ONBELT

	New()
		..()
		BLOCK_SETUP(BLOCK_ROD)

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, var/reach)
		if(user == target || (!isturf(target.loc) && !isturf(target)))
			return
		playsound(src.loc, hit_sound, 20, 1)
		if(blasting)
			playsound(src.loc, 'sound/items/mining_conc.ogg', 20, 1)
		return use(user, target)

	onMaterialChanged()
		..()
		if(istype(src.material))
			src.power = max(20, (src.material.getProperty("hard") - 3) * 66)
		if(blasting)
			src.power *= 0.9
		return

	proc/use(var/mob/user, var/atom/target)
		return

	buildTooltipContent()
		. = ..()
		. += "<br>"
		. += "<div><img src='[resource("images/tooltips/mining.png")]' alt='' class='icon' /><span>Mining Power: [power]</span></div>"
		lastTooltipContent = .

/obj/item/mining_tools/pick
	name = "Mining Pick"
	desc = "A mining pick. Affects only a single tile but has very high power."
	icon_state = "pickaxe"
	item_state = "pick"
	hit_sound = 'sound/items/mining_pick.ogg'

	onMaterialChanged()
		..()
		if(istype(src.material))
			src.power = 0
			src.power += max(10, (src.material.getProperty("density") - 3) * 33)
			src.power += max(10, (src.material.getProperty("hard") - 3) * 33)
			src.power *= 2.5
			if(blasting)
				src.power *= 0.9
			src.power = round(src.power)
		return

	use(var/mob/user, var/atom/target)
		var/attackDir = get_dir(user, target)
		if(attackDir == NORTHEAST || attackDir == NORTHWEST || attackDir == SOUTHEAST || attackDir == SOUTHWEST)
			attackDir = (prob(50) ? turn(attackDir, 45) : turn(attackDir, -45))

		var/turf/start = get_step(user,attackDir)

		var/obj/effect/melee/pick/DA = new/obj/effect/melee/pick(start)

		SPAWN(2 SECONDS)
			qdel(DA)

		var/list/extra_dmg = list()
		if(blasting)
			extra_dmg |= range(1,start)
			for(var/turf/T in extra_dmg)
				if(istype(T,/turf/simulated/wall/auto/asteroid))
					var/obj/effect/melee/conc/conc = new/obj/effect/melee/conc(T)
					SPAWN(1 SECOND) qdel(conc)
					T:change_health(-(round(power/7)))

		if(istype(start,/turf/simulated/wall/auto/asteroid))
			var/turf/simulated/wall/auto/asteroid/A = start
			A.change_health(-power)
		return

/obj/item/mining_tools/blaster
	name = "Mining Blaster"
	desc = "A mining blaster. Affects a wide area but has a little bit less power."
	icon_state = "blaster"
	item_state = "drill"
	hit_sound = 'sound/items/mining_blaster.ogg'

	onMaterialChanged()
		..()
		if(istype(src.material))
			src.power = max(20, (src.material.getProperty("electrical") - 4) * 80)
			src.power *= 0.8
			if(blasting)
				src.power *= 0.9
			src.power = round(src.power)
		return

	use(var/mob/user, var/atom/target)
		var/attackDir = get_dir(user, target)
		if(attackDir == NORTHEAST || attackDir == NORTHWEST || attackDir == SOUTHEAST || attackDir == SOUTHWEST)
			attackDir = (prob(50) ? turn(attackDir, 45) : turn(attackDir, -45))

		var/turf/start = get_step(user,attackDir)
		var/turf/TC = get_step(start,attackDir)
		var/turf/TA = get_step(TC,turn(attackDir, 90))
		var/turf/TB = get_step(TC,turn(attackDir, -90))

		animate(start,color="#FFFF00", time=1)
		animate(color="#AA0000", time=2)
		animate(color="#FFFFFF", time=4)

		animate(TC,color="#FFFF00", time=1)
		animate(color="#AA0000", time=2)
		animate(color="#FFFFFF", time=4)

		animate(TA,color="#FFFF00", time=1)
		animate(color="#AA0000", time=2)
		animate(color="#FFFFFF", time=4)

		animate(TB,color="#FFFF00", time=1)
		animate(color="#AA0000", time=2)
		animate(color="#FFFFFF", time=4)

		var/obj/effect/melee/blasterline/EA = new/obj/effect/melee/blasterline(user.loc)
		var/obj/effect/melee/blasterline/EB = new/obj/effect/melee/blasterline(start)

		EA.set_dir(attackDir)
		EB.set_dir(turn(attackDir, 180))

		animate(EA,alpha=0, time=5)
		animate(EB,alpha=0, time=5)

		SPAWN(0.6 SECONDS)
			qdel(EA)
			qdel(EB)

		var/list/extra_dmg = list()
		if(blasting)
			extra_dmg |= range(1,start)
			extra_dmg |= range(1,TA)
			extra_dmg |= range(1,TB)
			extra_dmg |= range(1,TC)
			for(var/turf/T in extra_dmg)
				if(istype(T,/turf/simulated/wall/auto/asteroid))
					var/obj/effect/melee/conc/conc = new/obj/effect/melee/conc(T)
					SPAWN(1 SECOND) qdel(conc)
					T:change_health(-(round(power/7)))

		if(istype(start,/turf/simulated/wall/auto/asteroid))
			var/turf/simulated/wall/auto/asteroid/A = start
			A.change_health(-power)
		if(istype(TC,/turf/simulated/wall/auto/asteroid))
			var/turf/simulated/wall/auto/asteroid/B = TC
			B.change_health(-power)
		if(istype(TA,/turf/simulated/wall/auto/asteroid))
			var/turf/simulated/wall/auto/asteroid/C = TA
			C.change_health(-power)
		if(istype(TB,/turf/simulated/wall/auto/asteroid))
			var/turf/simulated/wall/auto/asteroid/D = TB
			D.change_health(-power)
		return

/obj/item/mining_tools/hammer
	name = "Mining Hammer"
	desc = "A mining hammer. Affects a wide area."
	icon_state = "powerhammer"
	item_state = "hammer"
	hit_sound = 'sound/items/mining_hammer.ogg'
	force = 5

	onMaterialChanged()
		..()
		if(istype(src.material))
			src.power = max(20, (src.material.getProperty("density") - 3) * 66)
			if(blasting)
				src.power *= 0.9
			src.power = round(src.power)
		return

	use(var/mob/user, var/atom/target)
		var/attackDir = get_dir(user, target)
		if(attackDir == NORTHEAST || attackDir == NORTHWEST || attackDir == SOUTHEAST || attackDir == SOUTHWEST)
			attackDir = (prob(50) ? turn(attackDir, 45) : turn(attackDir, -45))

		var/turf/start = get_step(user,attackDir)
		var/turf/middle = get_step(start,turn(attackDir, 90))
		var/turf/end = get_step(start,turn(attackDir, -90))

		var/obj/effect/melee/hammer/DA = new/obj/effect/melee/hammer(start)
		var/obj/effect/melee/hammer/DB = new/obj/effect/melee/hammer(middle)
		var/obj/effect/melee/hammer/DC = new/obj/effect/melee/hammer(end)

		SPAWN(2 SECONDS)
			qdel(DA)
			qdel(DB)
			qdel(DC)

		var/list/extra_dmg = list()
		if(blasting)
			extra_dmg |= range(1,start)
			extra_dmg |= range(1,middle)
			extra_dmg |= range(1,end)
			for(var/turf/T in extra_dmg)
				if(istype(T,/turf/simulated/wall/auto/asteroid))
					var/obj/effect/melee/conc/conc = new/obj/effect/melee/conc(T)
					SPAWN(1 SECOND) qdel(conc)
					T:change_health(-(round(power/7)))

		if(istype(start,/turf/simulated/wall/auto/asteroid))
			var/turf/simulated/wall/auto/asteroid/A = start
			A.change_health(-power)
		if(istype(middle,/turf/simulated/wall/auto/asteroid))
			var/turf/simulated/wall/auto/asteroid/B = middle
			B.change_health(-power)
		if(istype(end,/turf/simulated/wall/auto/asteroid))
			var/turf/simulated/wall/auto/asteroid/C = end
			C.change_health(-power)
		return

/obj/item/mining_tools/drill
	name = "Mining Drill"
	desc = "A mining drill. Has a long range."
	icon_state = "lasdrill-old"
	item_state = "drill"
	hit_sound = 'sound/items/mining_drill.ogg'

	onMaterialChanged()
		..()
		if(istype(src.material))
			src.power = max(20, (src.material.getProperty("hard") - 3) * 66)
			if(blasting)
				src.power *= 0.9
			src.power = round(src.power)
		return

	use(var/mob/user, var/atom/target)
		var/attackDir = get_dir(user, target)
		if(attackDir == NORTHEAST || attackDir == NORTHWEST || attackDir == SOUTHEAST || attackDir == SOUTHWEST)
			attackDir = (prob(50) ? turn(attackDir, 45) : turn(attackDir, -45))

		var/turf/start = get_step(user,attackDir)
		var/turf/middle = get_step(start,attackDir)
		var/turf/end = get_step(middle,attackDir)

		var/anim_x = 0
		var/anim_y = 0

		switch(attackDir)
			if(NORTH)
				anim_x = 0
				anim_y = 64
			if(EAST)
				anim_x = 64
				anim_y = 0
			if(SOUTH)
				anim_x = 0
				anim_y = -64
			if(WEST)
				anim_x = -64
				anim_y = 0

		var/obj/effect/melee/drill/D = new/obj/effect/melee/drill(start)
		D.set_dir(attackDir)

		animate(D, pixel_x = anim_x, pixel_y = anim_y, time = 5, easing = QUAD_EASING)
		SPAWN(2 SECONDS) qdel(D)

		var/list/extra_dmg = list()
		if(blasting)
			extra_dmg |= range(1,start)
			extra_dmg |= range(1,middle)
			extra_dmg |= range(1,end)
			for(var/turf/T in extra_dmg)
				if(istype(T,/turf/simulated/wall/auto/asteroid))
					var/obj/effect/melee/conc/conc = new/obj/effect/melee/conc(T)
					SPAWN(1 SECOND) qdel(conc)
					T:change_health(-(round(power/7)))

		if(istype(start,/turf/simulated/wall/auto/asteroid))
			var/turf/simulated/wall/auto/asteroid/A = start
			A.change_health(-power)
		if(istype(middle,/turf/simulated/wall/auto/asteroid))
			var/turf/simulated/wall/auto/asteroid/B = middle
			B.change_health(-power)
		if(istype(end,/turf/simulated/wall/auto/asteroid))
			var/turf/simulated/wall/auto/asteroid/C = end
			C.change_health(-power)

		return
