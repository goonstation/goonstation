/obj/item/cell
	name = "power cell"
	desc = "A rechargeable electrochemical power cell. It's too large to fit into most handheld devices, but can be used to power cyborgs and APCs."
	icon = 'icons/obj/power.dmi'
	inhand_image_icon = 'icons/mob/inhand/hand_tools.dmi'
	icon_state = "cell"
	item_state = "cell"
	force = 5
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	health = 8
	w_class = W_CLASS_NORMAL
	pressure_resistance = 80
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 7500
	m_amt = 700
	var/rigged = 0		// true if rigged to explode
	var/mob/rigger = null // mob responsible for the explosion
	var/genrate = 0		// how much power the cell generates by itself per process tick
	var/specialicon = 0	// used for autoprocess shit
	var/unusualCell = 0
	stamina_damage = 10
	stamina_cost = 10
	stamina_crit_chance = 10

	disposing()
		if (istype(src.loc,/obj/machinery/power/apc))
			var/obj/machinery/power/apc/APC = src.loc
			APC.cell = null
		..()

/obj/item/cell/supercell
	maxcharge = 15000

/obj/item/cell/erebite
	name = "erebite power cell"
	desc = "A small battery/generator unit powered by the unstable mineral Erebite. Do not expose to high temperatures or fire."
	icon_state = "erebcell"
	maxcharge = 60000
	genrate = 30
	specialicon = 1

/obj/item/cell/cerenkite
	name = "cerenkite power cell"
	desc = "A small battery/generator unit powered by the radioactive mineral Cerenkite."
	icon_state = "cerecell"
	maxcharge = 15000
	genrate = 2
	specialicon = 1

/obj/item/cell/shell_cell
	name = "AI shell power cell"
	desc = "A rechargeable electrochemical power cell. It's made for AI shells."
	maxcharge = 4000

/obj/item/cell/hypercell
	name = "hyper capacity power cell"
	desc = "A hyper capacity power cell utilizing the latest in high density energy storage. Warning: Do no- *the rest is scratched out*"
	icon_state = "hypercell"
	maxcharge = 25000
	specialicon = 1

/obj/item/cell/custom
	name = "Large power cell"
	desc = "A custom large power cell."
	maxcharge = 3000

	New()
		..()
		processing_items |= src

	onMaterialChanged()
		..()
		if (istype(src.material))
			genrate = 0
			if(src.material.hasProperty("radioactive"))
				genrate += round(material.getProperty("radioactive"))
			if(src.material.hasProperty("n_radioactive"))
				genrate += round(material.getProperty("n_radioactive") * 2)
			if(src.material.hasProperty("electrical"))
				maxcharge = round((src.material.getProperty("electrical") ** 2) * 300, 500)
			else
				maxcharge = 2500

			charge = maxcharge
		return

	proc/set_custom_mats(datum/material/coreMat, datum/material/genMat = null)
		src.setMaterial(coreMat)
		if(genMat)
			src.name = "[genMat.getName()]-doped [src.name]"
			var/conductivity = (2 * coreMat.getProperty("electrical") + genMat.getProperty("electrical")) / 3 //if self-charging, use a weighted average of the conductivities
			maxcharge = round((conductivity ** 2) * 300, 500)
			genrate = (coreMat.getProperty("radioactive") + coreMat.getProperty("n_radioactive") * 2 + genMat.getProperty("radioactive") * 2 + genMat.getProperty("n_radioactive") * 4) / 3 //weight this too

/obj/item/cell/charged
	charge = 7500

/obj/item/cell/supercell/charged
	charge = 15000

/obj/item/cell/erebite/charged
	charge = 60000

/obj/item/cell/cerenkite/charged
	charge = 15000

/obj/item/cell/shell_cell/charged
	charge = 4000

/obj/item/cell/hypercell/charged
	charge = 25000

/obj/item/cell/New()
	..()

// I think this relic of a by-gone age is only used by APCs (in New()). Did result in absurd numbers for these
// pre-charged power cells, though. How did this go unnoticed for many years?
// 1) Power cell descs aren't dynamic. 2) Self-charging cells are in the item loop and capped.
// 3) The majority of charged power cells placed in the map editor were var-editied to use this formula (Convair880).

//	charge = charge * maxcharge/100.0		// map obj has charge as percentage, convert to real value here

	SPAWN(0.5 SECONDS)
		UpdateIcon()

	if (genrate)
		processing_items |= src

/obj/item/cell/disposing()
	processing_items -= src
	..()

/obj/item/cell/update_icon()
	if(src.specialicon) return

	if(maxcharge <= 2500) icon_state = "cell"
	else icon_state = "hpcell"

	var/image/I = GetOverlayImage("charge_indicator")
	if(!I) I = image('icons/obj/power.dmi', "cell-o2")

	if(charge < 0.01)
		ClearSpecificOverlays(TRUE, "charge_indicator")
	else if(charge/maxcharge >=0.995)
		I.icon_state = "cell-o2"
		AddOverlays(I, "charge_indicator")
	else
		I.icon_state = "cell-o1"
		AddOverlays(I, "charge_indicator")

/obj/item/cell/proc/percent()		// return % charge of cell
	return 100.0*charge/maxcharge

// use power from a cell
/obj/item/cell/proc/use(var/amount)
	charge = max(0, charge-amount)
	if(rigged && amount > 0)
		if (rigger)
			message_admins("[key_name(rigger)]'s rigged cell exploded at [log_loc(src)].")
			logTheThing(LOG_COMBAT, rigger, "'s rigged cell exploded at [log_loc(src)].")
		explode()

// recharge the cell
/obj/item/cell/proc/give(var/amount)
	. = min(maxcharge-charge, amount)
	charge = min(maxcharge, charge+amount)
	if(rigged && amount > 0)
		if (rigger)
			message_admins("[key_name(rigger)]'s rigged cell exploded at [log_loc(src)].")
			logTheThing(LOG_COMBAT, rigger, "'s rigged cell exploded at [log_loc(src)].")
		explode()

/obj/item/cell/process()
	// Negative charge isn't an uncommon occurrence, but it appeared too expensive to keep an additional
	// ~270 power cells in the item loop just for this check (simple as it may be) (Convair880).
	src.charge = max(0, src.charge)
	if (genrate > 0) give(genrate)
	if (!genrate) ..()

/obj/item/cell/examine(mob/user)
	. = ..()

	if (src.artifact || src.unusualCell)
		return

	if(user && !user.stat)
		if(maxcharge <= 2500)
			. += "The manufacturer's label states this cell has a power rating of [maxcharge], and that you should not swallow it.<br>The charge meter reads [round(src.percent() )]%."
		else
			. += "This power cell has an exciting chrome finish, as it is an uber-capacity cell type! It has a power rating of [maxcharge]!!!<br>The charge meter reads [round(src.percent() )]%."

/obj/item/cell/attackby(obj/item/W, mob/user) // Moved the stungloves stuff to gloves.dm (Convair880).
	if (istype(W, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = W
		boutput(user, "You inject the solution into the power cell.")

		if (S.reagents.has_reagent("plasma", 1))
			if (istype(src,/obj/item/cell/erebite))
				message_admins("[key_name(user)] injected [src] with plasma, causing an explosion at [log_loc(user)].")
				logTheThing(LOG_COMBAT, user, "injected [src] with plasma, causing an explosion at [log_loc(user)].")
				boutput(user, SPAN_ALERT("The plasma reacts with the erebite and explodes violently!"))
				src.explode()
			else
				logTheThing(LOG_COMBAT, user, "rigged [src] to explode at [log_loc(user)].")
				rigged = 1
				rigger = user
		S.reagents.clear_reagents()

/*	else if (istype(W, /obj/item/cable_coil))
		var/obj/item/cable_coil/C = W
		if (C.amount < 4)
			user.show_text("You need at least 4 pieces of cable to attach it to [src].", "red")
		else if (src.zap(user))
			return
		else
			C.use(4)
			user.show_text("You attach some of the cable to [src].[prob(20) ? " That seems safe." : null]", "blue")
			new /obj/item/robodefibrillator/makeshift(get_turf(src), src)
			user.u_equip(src)
*/
	else
		return ..()

/obj/item/cell/proc/explode()
	if(src in bible_contents)
		for_by_tcl(B, /obj/item/bible)
			var/turf/T = get_turf(B.loc)
			if(T)
				T.hotspot_expose(700,125)
				explosion(src, T, -1, -1, 2, 3)
		qdel(src)
		return
	var/turf/T = get_turf(src.loc)

	explosion(src, T, 0, 1, 2, 2)

	SPAWN(1 DECI SECOND)
		qdel(src)


/obj/item/cell/proc/zap(mob/user as mob, var/ignores_gloves = 0)
	if (user.shock(src, src.charge, user.hand == LEFT_HAND ? "l_arm" : "r_arm", 1, ignores_gloves))
		boutput(user, SPAN_ALERT("[src] shocks you!"))

		for(var/mob/M in AIviewers(src))
			if(M == user)	continue
			M.show_message(SPAN_ALERT("[user:name] was shocked by the [src:name]!"), 3, SPAN_ALERT("You hear an electrical crack"), 2)
		return 1

/obj/item/cell/ex_act(severity)
	if (istype(src,/obj/item/cell/erebite)) src.explode()
	else ..()

/obj/item/cell/temperature_expose(null, temp, volume)
	if (istype(src,/obj/item/cell/erebite))
		src.visible_message(SPAN_ALERT("[src] violently detonates!"))
		src.explode()
	else ..()

/obj/item/cell/detonator_act(event, var/obj/item/canbomb_detonator/det)
	switch (event)
		if ("attach")
			det.initial_wire_functions += src
		if ("pulse")
			var/obj/item/device/timer/checked_timer = det.part_assembly.trigger
			if (checked_timer.time > 10)
				checked_timer.time = 10 //Oh no!
				det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>The timer flashes ominously and decreases to [checked_timer.time] seconds.</span>")
			else
				det.attachedTo.visible_message("<span class='bold' style='color: #B7410E;'>The timer flashes ominously.</span>")
		if ("cut")
			src.visible_message("<span class='bold' style='color: #B7410E;'>The failsafe timer buzzes refusingly before going quiet forever.</span>")
			SPAWN(0)
				det.detonate()

//kubius potato battery: main def

/obj/item/cell/potato
	name = "potato cell"
	desc = "An improvised organic power cell. It looks a bit limp."
	icon = 'icons/obj/potatocell.dmi'
	icon_state = "king_tater"
	maxcharge = 600
	genrate = 0
	specialicon = 1
	unusualCell = 1

/obj/item/cell/potato/New(var/loc, var/potency, var/endurance)
	src.maxcharge += rand(1,100) //slight deviation by specimen
	src.maxcharge += round(potency*(6+rand(1,4))) //more deviation
	src.genrate = round(endurance/rand(12,16))
	if(genrate) desc = "An improvised organic power cell. It seems to be holding up well."
	src.charge = src.maxcharge
	..()

/obj/item/cell/potato/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/plantanalyzer/)) //Since it's a plant after all
		if(genrate)
			boutput(user, "The potato cell has [src.charge]/[src.maxcharge] charge remaining, and a regeneration rate of [genrate].")
		else
			boutput(user, "The potato cell has [src.charge]/[src.maxcharge] charge remaining, and no capacity for regeneration.")
	else
		..()


/obj/item/ammo/power_cell/self_charging/potato
	name = "potato battery"
	desc = "An improvised organic power cell, cut down to a compact size. It seems somewhat impractical."
	icon = 'icons/obj/potatocell.dmi'
	icon_state = "baby_tater"
	unusualCell = 1
	m_amt = 20000
	g_amt = 20000
	max_charge = 10
	recharge_rate = 0

/obj/item/ammo/power_cell/self_charging/potato/New(var/loc, var/potency, var/endurance) //capped, approches double stats of disruptor cell
	var/rngfactor = 2 + rand()
//	src.max_charge += round(potency/rngfactor)
	src.max_charge += round(190 * potency / (potency + 100 * rngfactor)) //asymptote at 200pu
	src.recharge_rate = 0.25 * round(0.01 + 20 * endurance / (endurance + rand(400,500))) //asymptote at 5 recharge rate
	src.charge = src.max_charge
	..()

/obj/item/ammo/power_cell/self_charging/potato/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/plantanalyzer/))
		if(recharge_rate)
			boutput(user, "The potato battery has [src.charge] of [src.max_charge] PUs charge remaining, and a regeneration rate of [recharge_rate].")
		else
			boutput(user, "The potato battery has [src.charge] of [src.max_charge] PUs charge remaining, and no capacity for regeneration.")
	else
		..()
