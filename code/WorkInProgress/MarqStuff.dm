// The day has come when this warps into existence.
// Dear god, imagine the horrors that will soon lurk in here.

/proc/chs(var/str, var/i)
	return ascii2text(text2ascii(str,i))

// TODO: Variable processing.

#define NONE 0
#define APOS 1
#define QUOT 2

#define ESCAPE "\\"

/**
 * BASH explode: Splits a string into string pieces the same way BASH handles this.
 *
 * - Process quoted strings LTR: Apostrophized strings are unparsed. Quoted strings are parsed.
 * - Insert parsed strings back into the string by using a placeholder for spaces.
 * - Split the string with the usual space separation method.
 * - Return list.
 */
/proc/bash_explode(var/str)
	var/fin = 0
	var/state = NONE
	var/pos = 1
	var/qpos = 1
	var/buf = ""
	while (!fin)
		switch(state)
			if (NONE)
				var/NA = findtext(str, "'", pos)
				var/NQ = findtext(str, "\"", pos)
				if (!NA && !NQ)
					buf += copytext(str, pos)
					fin = 1
				else if (NA && !NQ || (NA && NQ && NA < NQ))
					if (chs(str, NA - 1) == ESCAPE)
						buf += copytext(str, pos, NA - 1) + "'"
						pos = NA + 1
						continue
					else
						buf += copytext(str, pos, NA)
						pos = NA + 1
						state = APOS
				else if (NQ && !NA || (NA && NQ && NQ < NA))
					if (chs(str, NQ - 1) == ESCAPE)
						buf += copytext(str, pos, NQ - 1) + "\""
						pos = NQ + 1
						continue
					else
						buf += copytext(str, pos, NQ)
						pos = NQ + 1
						qpos = NQ + 1
						state = QUOT
				else if (NA == NQ)
					//??????
					return null

			if (APOS)
				var/NA = findtext(str, "'", pos)
				if (!NA)
					return null
				var/temp = copytext(str, pos, NA)
				buf += replacetext(temp, " ", "&nbsp;")
				pos = NA + 1
				state = NONE

			if (QUOT)
				var/NQ = findtext(str, "\"", pos)
				if (!NQ)
					return null
				if (copytext(str, NQ - 1, NQ) == ESCAPE)
					pos = NQ + 1
					continue
				var/temp = copytext(str, qpos, NQ)
				buf += replacetext(replacetext(temp, " ", "&nbsp;"), "\\\"", "\"")
				pos = NQ + 1
				state = NONE

	var/list/el = splittext(buf, " ")
	var/list/ret = list()
	for (var/s in el)
		ret += replacetext(s, "&nbsp;", " ")
	return ret

#undef ESCAPE
#undef QUOT
#undef APOS
#undef NONE

/proc/bash_sanitize(var/data)
	var/list/allowed_chars = list(" ")
	var/ret = ""
	var/lgp = 0
	for (var/i = 1, i <= length(data), i++)
		var/char = text2ascii(data, i)
		var/ord = ascii2text(char)
		if ((65 <= char && char <= 90) || (97 <= char && char <= 122) || (ord in allowed_chars))
			if (lgp == 0)
				lgp = i
			continue
		if (lgp == 0)
			continue
		ret += copytext(data, lgp, i)
		lgp = 0
	if (lgp)
		ret += copytext(data, lgp)
	return ret


/obj/nerd_trap_door
	name = "Heavily locked door"
	desc = "Man, whatever is in here must be pretty valuable. This door seems to be indestructible and features an unrealistic amount of keyholes."
	var/list/expected = list("silver key", "skeleton key", "cold steel key", "literal skeleton key", "hot iron key", "onyx key", "virtual key", "golden key", "iron key", "iridium key", "lunar key")
	var/list/unlocked = list()
	var/list/ol = list()
	icon = 'icons/misc/aprilfools.dmi'
	icon_state = "hld0"
	opacity = 1
	density = 1
	anchored = ANCHORED

	examine()
		. = ..()
		. += "Your keen skills of observation tell you that [expected.len - unlocked.len] out of the [expected.len] locks are locked."

	attackby(var/obj/item/I, var/mob/user)
		if (istype(I, /obj/item/device/key))
			var/kname = null
			if (I.name in expected)
				kname = I.name
			//for (var/N in expected)
			//	if (dd_hasprefix(I.name, N))
			//		break
			if (kname)
				boutput(user, SPAN_NOTICE("You insert the [I.name] into the [kname]hole and turn it. The door emits a loud click."))
				playsound(src.loc, 'sound/impact_sounds/Generic_Click_1.ogg', 60, 1)
				if (kname in unlocked)
					unlocked -= kname
					overlays -= ol[kname]
					ol -= kname
				else
					unlocked += kname
					var/image/IM = image('icons/misc/aprilfools.dmi', "[kname]hole")
					ol[kname] = IM
					overlays += IM
			else
				boutput(user, SPAN_ALERT("You cannot find a matching keyhole for that key!"))
		else if (istype(I, /obj/item/reagent_containers/food/snacks/pie/lime))
			if ("key lime pie" in expected)
				boutput(user, SPAN_NOTICE("You insert the [I.name] into the key lime piehole and turn it. The door emits a loud click."))
				playsound(src.loc, 'sound/impact_sounds/Generic_Click_1.ogg', 60, 1)
				if ("key lime pie" in unlocked)
					unlocked -= "key lime pie"
					overlays -= ol["key lime pie"]
					ol -= "key lime pie"
				else
					unlocked += "key lime pie"
					var/image/IM = image('icons/misc/aprilfools.dmi', "key lime piehole")
					ol["key lime pie"] = IM
					overlays += IM
			else
				boutput(user, SPAN_ALERT("You cannot find a matching keyhole for that key!"))

	Bumped(var/mob/M)
		if (!istype(M))
			return
		src.Attackhand(M)

	attack_hand(var/mob/user)
		if (!density)
			return
		if (length(unlocked) == expected.len)
			open()
		else
			boutput(user, SPAN_ALERT("The door won't budge!"))

	proc/open()
		if (unlocked.len != expected.len)
			return
		playsound(src.loc, 'sound/machines/door_open.ogg', 50, 1)
		icon_state = "hld1"
		set_density(0)
		set_opacity(0)
		overlays.len = 0

	meteorhit()
		return

	ex_act()
		return

	blob_act()
		return

	bullet_act()
		return

/obj/nerd_trap_door/voidoor
	name = "V O I D O O R"
	desc = "This door cannot be returned. You see, the warranty is void."
	expected = list("silver key", /*"skeleton key",*/ "literal skeleton key", "hot iron key", "cold steel key", "onyx key", /*"key lime pie",*/ /*"futuristic key",*/ /*"virtual key",*/ "golden key", /*"bee key",*/ "iron key", /*"iridium key",*/ "lunar key")
	icon_state = "hld2"

/obj/steel_beams
	name = "steel beams"
	desc = "A bunch of unfortunately placed, tightly packed steel beams. You cannot get a meaningful glimpse of what's on the other side."
	anchored = ANCHORED
	density = 1
	opacity = 1
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "beams"

	meteorhit()
		return

	ex_act()
		return

	blob_act()
		return

	bullet_act()
		return

/obj/faint_shimmer
	name = "faint shimmer"
	desc = "Huh."
	anchored = ANCHORED
	density = 0
	invisibility = INVIS_CLOAK
	blend_mode = 4
	icon = 'icons/misc/old_or_unused.dmi'
	icon_state = "noise5"
	var/decloaked_type = /obj/item/storage/toilet

	dense
		density = 1

// Aiming bow action.
/datum/action/bar/aim
	duration = -1
	var/obj/item/gun/bow/bow = null
	var/draw_target = 3
	var/progress = 0
	var/moved = 0

	New(var/mob/M, var/obj/item/gun/bow/B, max_draw)
		owner = M
		bow = B
		draw_target = max_draw
		..()

	onStart()
		..()
		playsound(owner, 'sound/effects/bow_pull.ogg', 80, TRUE)
		owner.visible_message(SPAN_ALERT("[owner] pulls the string on [bow]!"), SPAN_NOTICE("You pull the string on [bow]!"))
		src.bar.transform = matrix(0, 1, MATRIX_SCALE)
		src.bar.pixel_x = -15

	onDelete()
		if (bow)
			bow.aim = null
		..()

	onEnd()
		if (src.state != ACTIONSTATE_FINISH)
			boutput(owner, SPAN_ALERT("You let go of the string."))
		if (bow)
			bow.aim = null
		..()

	interrupt(var/flag)
		if(flag == INTERRUPT_MOVE)
			moved = 1
			return
		..()


	onUpdate()
		if (src.moved)
			src.progress += 0.5
		else
			src.progress += 1
		src.progress = min(src.draw_target, src.progress)
		src.moved = 0

		var/completion_fraction = src.progress/src.draw_target
		bow.UpdateIcon(completion_fraction)
		src.bar.color = "#0000FF"
		animate(src.bar, transform = matrix(completion_fraction, 1, MATRIX_SCALE), time = ACTION_CONTROLLER_INTERVAL)
		animate(pixel_x = -nround( ((30 - (30 * completion_fraction)) / 2) ), time = ACTION_CONTROLLER_INTERVAL, flags = ANIMATION_PARALLEL)

/obj/item/arrow
	name = "steel-headed arrow"
	icon = 'icons/obj/items/items.dmi'
	icon_state = null
	flags = TABLEPASS | SUPPRESSATTACK
	// placeholder
	var/datum/material/head_material
	var/datum/material/shaft_material
	var/image/shaft
	var/image/head
	amount = 1
	max_stack = 50
	appearance_flags = LONG_GLIDE | PIXEL_SCALE | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_TOGETHER
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	move_triggered = 1

	New()
		..()
		shaft = image(icon, "arrow_base")
		head = image(icon, "arrow_head")
		reagents = new /datum/reagents(3)
		reagents.my_atom = src
		overlays += shaft
		overlays += head

	check_valid_stack(atom/movable/O as obj)
		if(!istype(O, /obj/item/arrow)) return 0
		var/obj/item/arrow/A = O

		if(A.head_material && src.head_material)
			if(!A.head_material.isSameMaterial(src.head_material))
				return 0
		else if ((A.head_material && !src.head_material) || (!A.head_material && src.head_material))
			return 0

		if(A.shaft_material && src.shaft_material)
			if(!A.shaft_material.isSameMaterial(src.shaft_material))
				return 0
		else if ((A.shaft_material && !src.shaft_material) || (!A.shaft_material && src.shaft_material))
			return 0

		return 1

	examine()
		. = ..()
		if (amount > 1)
			. += SPAN_NOTICE("This is a stack of [amount] arrows.")
		if (reagents.total_volume)
			. += SPAN_NOTICE("The tip of the arrow is coated with reagents.")

	clone(var/newloc = null)
		var/obj/item/arrow/O = new(loc)
		if (newloc)
			O.set_loc(newloc)
		O.setHeadMaterial(head_material)
		O.setShaftMaterial(shaft_material)
		return O

	attackby(obj/item/W, mob/user, params)
		if(W.type == src.type && src.check_valid_stack(W))
			stack_item(W)
			return
		if(istype(W, /obj/item/quiver))
			var/obj/item/quiver/quiver = W
			quiver.loadArrow(src, user)
			return
		if(istype(W, /obj/item/gun/bow))
			var/obj/item/gun/bow/bow = W
			if(isnull(bow.loaded))
				bow.loadArrow(src, user)
			return
		. = ..()
/*
	attack_hand(var/mob/user)
		if (amount > 1)
			amount--
			var/obj/item/arrow/O = clone(loc)
			user.put_in_hand_or_drop(O, user.hand)
			boutput(user, "<span class='notice'>You take \a [src] from the stack of [src]s. [amount] remaining on the stack.")
		else
			..()
*/

	set_loc()
		..()
		if (isturf(loc))
			overlays.len = 0
			head.layer = initial(head.layer)
			shaft.layer = initial(shaft.layer)
			overlays += shaft
			overlays += head
		else
			overlays.len = 0
			head.layer = HUD_LAYER+3
			shaft.layer = HUD_LAYER+3
			overlays += shaft
			overlays += head

	_update_stack_appearance()
		setName()
		return

	move_trigger(var/mob/M, kindof)
		if (..() && reagents)
			reagents.move_trigger(M, kindof)

	proc/setName()
		if (head_material && shaft_material)
			name = "[amount] [head_material]-headed [shaft_material] arrow[amount > 1 ? "s":""]"
		else if (head_material)
			name = "[amount] [head_material]-headed arrow[amount > 1 ? "s":""]"
		else if (shaft_material)
			name = "[amount] steel-headed [shaft_material] arrow[amount > 1 ? "s":""]"
		else
			name = "[amount] steel-headed arrow[amount > 1 ? "s":""]"

	proc/setHeadMaterial(var/datum/material/M)
		head_material = M
		overlays -= head
		if (M)
			head.color = M.getColor()
			head.alpha = M.getAlpha()
		else
			head.color = null
			head.alpha = 255
		overlays += head
		setName()

	proc/setShaftMaterial(var/datum/material/M)
		shaft_material = M
		src.setMaterial(shaft_material, appearance = 0, setname = 0)
		overlays -= shaft
		if (M)
			shaft.color = M.getColor()
			shaft.alpha = M.getAlpha()
		else
			shaft.color = null
			shaft.alpha = 255
		overlays += shaft
		setName()

	afterattack(var/atom/target, var/mob/user, reach)
		if (!reach)
			return
		if (isliving(target))
			if (prob(50))
				user.visible_message(SPAN_ALERT("<b>[user] tries to stab [target] with [src] but misses!</b>"))
				playsound(user, 'sound/impact_sounds/Generic_Swing_1.ogg', 25, TRUE, 1)
				return
			user.visible_message(SPAN_ALERT("<b>[user] stabs [target] with [src]!</b>"))
			user.u_equip(src)
			playsound(user, 'sound/impact_sounds/Flesh_Stab_1.ogg', 75, TRUE)
			var/datum/material/fusedmaterial = getFusedMaterial(head_material,shaft_material)//uses a fused material to get the effects of both the shaft and head material as an implant as the lifeloop only accepts one material per implant
			if (ishuman(target))
				var/mob/living/carbon/human/H = target
				var/obj/item/implant/projectile/body_visible/arrow/A = new
				A.material = fusedmaterial
				A.setMaterial(fusedmaterial, appearance = 0, setname = 0)
				A.arrow = src
				A.name = name
				set_loc(A)
				A.implanted(H, null, 100)
			reagents.reaction(target, 2)
			reagents.trans_to(target, reagents.total_volume)
			take_bleeding_damage(target, null, 8, DAMAGE_STAB)
			if (fusedmaterial)
				fusedmaterial.triggerOnAttack(src, user, target)
			return 1
		else
			var/obj/item/I = target
			if (istype(I) && I.is_open_container() == 1 && I.reagents)
				if (reagents.total_volume == reagents.maximum_volume)
					boutput(user, SPAN_ALERT("[src] is already coated in the maximum amount of reagents it can hold."))
				else if (!I.reagents.total_volume)
					boutput(user, SPAN_ALERT("[I] is empty."))
				else
					var/amt = min(reagents.maximum_volume - reagents.total_volume, I.reagents.total_volume)
					logTheThing(LOG_COMBAT, user, "poisoned [src] [log_reagents(I)] at [log_loc(user)].") // Logs would be nice (Convair880).
					I.reagents.trans_to(src, amt)
					boutput(user, SPAN_NOTICE("You dip [src] into [I], coating it with [amt] units of reagents."))

/obj/item/implant/projectile/body_visible/arrow
	name = "arrow"
	pull_out_name = "arrow"
	icon = null
	icon_state = null
	desc = "An arrow."
	var/obj/item/arrow/arrow = null

	New()
		..()
		implant_overlay = image(icon='icons/mob/human.dmi', icon_state="arrow_stick_[rand(0,4)]", layer=MOB_EFFECT_LAYER)

	on_pull_out(mob/living/puller)
		puller.put_in_hand_or_drop(src.arrow)
		qdel(src)

	// Hack.
	set_loc()
		..()
		if (isturf(loc))
			if (arrow)
				arrow.set_loc(loc)
			qdel(src)

/obj/item/quiver
	name = "quiver"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "quiver-0"
	wear_image_icon = 'icons/mob/clothing/back.dmi'
	item_state = "quiver"
	flags = TABLEPASS
	c_flags = ONBACK | ONBELT
	move_triggered = 1

	New()
		. = ..()
		src.create_inventory_counter()

	attackby(obj/item/I, mob/user)
		if (istype(I, /obj/item/arrow))
			src.loadArrow(I, user)
			return
		if (istype(I, /obj/item/gun/bow))
			var/obj/item/gun/bow/bow = I
			if (isnull(bow.loaded))
				var/obj/item/arrow = src.getArrow(user)
				if (isnull(arrow))
					return // no arrows
				bow.loadArrow(arrow, user)
				src.updateAppearance()
			return
		boutput(user, SPAN_ALERT("That cannot be placed in [src]!"))

	proc/loadArrow(obj/item/arrow/arrow, mob/user)
		if(arrow.amount > 1)
			var/amountinitial = arrow.amount
			for(var/i=0, i<amountinitial, i++)
				arrow.clone(src)
				arrow.change_stack_amount(-1)
		else
			user.u_equip(arrow)
			arrow.set_loc(src)
		src.updateAppearance()

	proc/getArrow(var/mob/user)
		if (src in user)
			if (contents.len)
				boutput(user, SPAN_NOTICE("You take [contents[1]] from [src]."))
				return contents[1]
			else return null

	proc/updateAppearance()
		src.inventory_counter.update_number(length(contents))
		icon_state = "quiver-[min(contents.len, 4)]"
		return

	attack_hand(var/mob/user)
		if (src in user)
			var/obj/item/arrow/I = getArrow(user)
			if(I)
				user.put_in_hand(I, user.hand)
				updateAppearance()
			return
		..()

	mouse_drop(atom/over_object, src_location, over_location)
		..()
		var/atom/movable/screen/hud/S = over_object
		if (istype(S))
			playsound(src.loc, "rustle", 50, 1, -5)
			if (!usr.restrained() && !usr.stat && src.loc == usr)
				if (S.id == "rhand")
					if (!usr.r_hand)
						usr.u_equip(src)
						usr.put_in_hand(src, 0)
				else
					if (S.id == "lhand")
						if (!usr.l_hand)
							usr.u_equip(src)
							usr.put_in_hand(src, 1)
				return
		if (usr.is_in_hands(src))
			var/turf/T = over_object
			if (istype(T, /obj/table))
				T = get_turf(T)
			if (!(usr in range(1, T)))
				return
			if (istype(T))
				for (var/obj/O in T)
					if (O.density && !istype(O, /obj/table) && !istype(O, /obj/rack))
						return
				if (!T.density)
					usr.visible_message(SPAN_ALERT("[usr] dumps the contents of [src] onto [T]!"))
					for (var/obj/item/I in src)
						I.set_loc(T)
						I.layer = initial(I.layer)

	move_trigger(var/mob/M, kindof)
		if (..())
			for (var/obj/O in contents)
				if (O.move_triggered)
					O.move_trigger(M, kindof)

	equipped(mob/user, slot)
		. = ..()
		src.inventory_counter.show_count()

/datum/projectile/arrow
	name = "arrow"
	damage = 10
	dissipation_delay = 12
	dissipation_rate = 5
	projectile_speed = 36 //gets adjusted by bow draw stats
	shot_sound = 'sound/effects/bow_release.ogg'
	damage_type = D_KINETIC
	hit_type = DAMAGE_STAB
	implanted = null
	impact_image_state = "bullethole"
	icon_state = "arrow"

	on_hit(var/atom/A, angle, var/obj/projectile/P)
		if (ismob(A))
			playsound(A, 'sound/impact_sounds/Flesh_Stab_1.ogg', 75, TRUE)
			var/obj/item/implant/projectile/body_visible/arrow/B = P.implanted
			if (istype(B))
				B.material_on_attack_use(null, A)
				B.arrow.reagents?.reaction(A, 2)
				B.arrow.reagents?.trans_to(A, B.arrow.reagents.total_volume)
			take_bleeding_damage(A, null, round(src.power / 2), src.hit_type)


/obj/item/gun/bow
	name = "bow"
	icon = 'icons/obj/items/items.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_guns.dmi'
	icon_state = "bow0"
	item_state = "bow"
	var/obj/item/arrow/loaded = null
	var/datum/action/bar/aim/aim = null
	spread_angle = 40
	force = 5
	can_dual_wield = 0
	contraband = 0
	move_triggered = 1
	var/spread_base = 40
	var/max_draw = 3
	recoil_enabled = FALSE
	pickup_sfx = null
	var/const/draw_states = 3

	New()
		set_current_projectile(new/datum/projectile/arrow)
		. = ..()

	update_icon(draw_fraction)
		src.icon_state = "bow[round(draw_fraction * (src.draw_states - 1), 1)]"

	onMaterialChanged()
		. = ..()
		spread_base = initial(spread_base)
		if(src.material)
			if (src.material.getProperty("density") <= 2)
				spread_base *= 1.5
			if (src.material.getProperty("density") >= 5)
				spread_base *= 0.5
			if (src.material.getProperty("density") >= 7)
				spread_base *= 0.75

			if (src.material.getProperty("hard") <= 2)
				max_draw = 2
			if (src.material.getProperty("hard") >= 5)
				max_draw = 5
			if (src.material.getProperty("hard") >= 8)
				max_draw = 10

	proc/loadFromQuiver(var/mob/user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(istype(H.back, /obj/item/quiver))
				var/obj/item/quiver/Q = H.back
				var/obj/item/arrow/I = Q.getArrow(user)
				if(I)
					src.loadArrow(I, user)
					Q.updateAppearance()
			if(istype(H.belt, /obj/item/quiver))
				var/obj/item/quiver/Q = H.belt
				var/obj/item/arrow/I = Q.getArrow(user)
				if(I)
					src.loadArrow(I, user)
					Q.updateAppearance()
		return

	proc/loadArrow(obj/item/arrow/arrow, mob/user)
		if (arrow.amount > 1)
			arrow.change_stack_amount(-1)
			arrow = arrow.clone(src)
		else
			user.drop_item(arrow)
		arrow.plane = initial(arrow.plane)
		arrow.layer = initial(arrow.layer)
		arrow.pixel_x = 0
		arrow.pixel_y = 0
		src.loaded = arrow
		arrow.set_loc(src)
		src.vis_contents += arrow
		playsound(get_turf(src), 'sound/effects/bow_nock.ogg', 60, FALSE)

	attack_hand(var/mob/user)
		if (!src.loaded && user.is_in_hands(src))
			src.loadFromQuiver(user)

		if (loaded && user.is_in_hands(src))
			user.put_in_hand_or_drop(src.loaded)
			boutput(user, SPAN_NOTICE("You unload the arrow from the bow."))
			src.vis_contents -= src.loaded
			src.loaded = null
		else
			..()

	move_trigger(var/mob/M, kindof)
		if (istype(loaded))
			loaded.move_trigger(M, kindof)

	dropped(mob/user)
		. = ..()
		src.aim = null
		src.UpdateIcon(0)

	attack(var/mob/target, var/mob/user)
		user.lastattacked = target
		target.lastattacker = user
		target.lastattackertime = world.time


	//absolutely useless as an attack but removing it causes bugs, replaced fire point blank which had issues with the way arrow damage is calculated.
		if(isliving(target))
			if(loaded)
				if(loaded.AfterAttack(target,user,1))
					src.vis_contents -= src.loaded
					loaded = null //arrow isnt consumed otherwise, for some inexplicable reason.
					src.UpdateIcon(0)
			else
				boutput(user, SPAN_ALERT("Nothing is loaded in the bow!"))
		else
			..()

	#ifdef DATALOGGER
			game_stats.Increment("violence")
	#endif
			return

	/*
	onMouseDown(atom/target,location,control,params)
		var/mob/user = usr
		var/list/parameters = params2list(params)
		if(ismob(target.loc) || istype(target, /atom/movable/screen)) return
		if(parameters["left"])
			if (!aim && !loaded)
				loadFromQuiver(user)

			if (!aim && loaded)
				aim = new(user, src)
				actions.start(aim, user)
		return
	*/

	attack_self(var/mob/user)
		return

	process_ammo(var/mob/user)
		if (!loaded)
			boutput(user, SPAN_ALERT("Nothing is loaded in the bow!"))
			return 0
		src.vis_contents -= src.loaded
		var/obj/item/implant/projectile/body_visible/arrow/A = new
		A.setMaterial(loaded.head_material, appearance = 0, setname = 0)
		A.arrow = loaded
		A.name = loaded.name
		current_projectile.name = loaded.name
		loaded.set_loc(A)
		current_projectile.implanted = A
		current_projectile.material = loaded.head_material
		var/default_damage = 7
		if(loaded.head_material)
			if(loaded.head_material.hasProperty("hard"))
				current_projectile.damage = round(6+loaded.head_material.getProperty("hard")) //pretty close to the 7-15 range, which will get multiplied by bow draw
			else
				current_projectile.damage = default_damage
		else
			current_projectile.damage = default_damage

		current_projectile.generate_stats()

		loaded = null
		return 1

	canshoot(mob/user)
		return loaded != null

	pixelaction(atom/target, params, mob/user, reach)
		/*
		if (!loaded)
			boutput(user, SPAN_ALERT("Nothing is loaded in the bow!"))
			return 1
		*/

		if (!aim)
			//var/list/parameters = params2list(params)
			if(ismob(target.loc) || istype(target, /atom/movable/screen)) return
			if (!loaded)//removed redundant check
				loadFromQuiver(user)
				if(loaded)
					boutput(user, SPAN_ALERT("You load an arrow from the quiver."))
					playsound(user, 'sound/effects/bow_nock.ogg', 60, FALSE)
				return
			if(reach)
				return
			if (loaded)
				aim = new(user, src, max_draw)
				actions.start(aim, user)
		else
			spread_angle = spread_base
			if (aim)
				spread_angle = (1 - aim.progress/max_draw) * spread_base
				aim.state = ACTIONSTATE_FINISH
			if (!aim.progress)
				return
			..()

	alter_projectile(obj/projectile/P)
		. = ..()
		if(aim)
			P.power *= aim.progress
			P.internal_speed = P.proj_data.projectile_speed * 1.5 * ((0.3/max_draw + 0.05) * aim.progress + 0.25)

	attackby(var/obj/item/arrow/I, var/mob/user)
		if (!istype(I))
			return ..()
		if (loaded)
			boutput(user, SPAN_ALERT("An arrow is already loaded onto the bow."))
			return

		src.loadArrow(I, user)

