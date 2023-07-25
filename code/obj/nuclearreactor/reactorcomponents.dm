// ----------------------------------------------------- //
// Defintion for the nuclear reactor engine internal components
// ----------------------------------------------------- //

ABSTRACT_TYPE(/obj/item/reactor_component)
/obj/item/reactor_component //base component
	name = "base reactor component"
	desc = "You really shouldn't be seeing this - call a coder"
	icon = 'icons/misc/reactorcomponents.dmi'
	icon_state = "fuel_rod"
	w_class = W_CLASS_BULKY

	/// Icon that appears in the UI
	var/icon_state_inserted = "base"
	/// Icon state that appears on the component grid overlay on the reactor
	var/icon_state_cap = "rod_cap"
	/// INTERNAL: Actual UI icon, base64 encoded
	var/ui_image = null
	/// INTERNAL: Actual component grid icon, coloured and textured by material
	var/icon/cap_icon = null
	/// Temperature of this component, starts at room temp Kelvin by default
	var/temperature = T20C
	/// How much does this component share heat with surrounding components? Basically surface area in contact (m2)
	var/thermal_cross_section = 0.01
	/// How adept is this component at interacting with neutrons - fuel rods are set up to capture them, heat exchangers are set up not to
	var/neutron_cross_section = 0.5
	/// Control rods don't moderate neutrons, they absorb them.
	var/is_control_rod = FALSE
	/// Max health to set melth_health to on init
	_max_health = 100
	/// Essentially indicates how long this component can be at a dangerous temperature before it melts
	var/melt_health = 100
	///If this component is melted, you can't take it out of the reactor and it might do some weird stuff
	var/melted = FALSE
	/// The dangerous temperature above which this component starts to melt. 1700K is the melting point of steel
	var/melting_point = 1700
	/// INTERNAL: cache of base64 encoded UI icons, so we don't have to store one copy for every component, just the types
	var/static/list/ui_image_base64_cache = list()
	/// How much gas this component can hold, and will be processed per tick
	var/gas_volume = 0

	New(material_name="steel")
		..()
		src.setMaterial(getMaterial(material_name))
		melt_health = _max_health
		var/img_check = ui_image_base64_cache[src.type]
		if (img_check)
			src.ui_image = img_check
		else
			var/icon/dummy_icon = icon(initial(src.icon), initial(src.icon_state_inserted))
			src.ui_image = icon2base64(dummy_icon)
			ui_image_base64_cache[src.type] = src.ui_image

	setMaterial(var/datum/material/mat1, var/appearance = TRUE, var/setname = TRUE, var/copy = TRUE, var/use_descriptors = FALSE)
		. = ..()
		src.cap_icon = icon(src.icon, src.icon_state_cap)
		if(appearance) //some mildly cursed code to set material appearance on the end caps
			if (islist(src.mat_appearances_to_ignore) && length(src.mat_appearances_to_ignore))
				if (mat1.name in src.mat_appearances_to_ignore)
					return
			if (src.mat_changeappearance && mat1.applyColor)
				var/list/setcolor = mat1.color
				if(istext(mat1.color))
					setcolor = rgb2num(mat1.color)
				if(islist(mat1.color))
					setcolor = mat1.color

				if(length(setcolor) == 4)
					setcolor[4] = mat1.alpha
				else if(length(setcolor) == 3)
					setcolor += mat1.alpha

				if (mat1.texture)
					var/icon_mode = null
					switch(mat1.texture_blend) //fucking byond...
						if(BLEND_DEFAULT) icon_mode = ICON_OVERLAY
						if(BLEND_OVERLAY) icon_mode = ICON_OVERLAY
						if(BLEND_ADD) icon_mode = ICON_ADD
						if(BLEND_SUBTRACT) icon_mode = ICON_SUBTRACT
						if(BLEND_MULTIPLY) icon_mode = ICON_MULTIPLY
						if(BLEND_INSET_OVERLAY) icon_mode = ICON_OVERLAY

					src.cap_icon.Blend(getTexturedIcon(src.cap_icon, mat1.texture), icon_mode)

				if(length(setcolor) > 4) //ie, if it's a color matrix
					src.cap_icon.MapColors(arglist(setcolor))
				else
					src.cap_icon.Blend(rgb(setcolor[1],setcolor[2],setcolor[3],setcolor[4]), ICON_MULTIPLY)




	proc/melt()
		if(melted)
			return
		src.melted = TRUE
		src.name = "melted "+src.name
		src.neutron_cross_section = 5.0
		src.thermal_cross_section = 1.0
		src.is_control_rod = FALSE

	proc/extra_info()
		. = ""

	proc/processGas(var/datum/gas_mixture/inGas)
		return null //most components won't touch gas

	proc/processHeat(var/list/obj/item/reactor_component/adjacentComponents)
		for(var/obj/item/reactor_component/RC as anything in adjacentComponents)
			if(isnull(RC))
				continue
			//heat transfer equation = hA(T2-T1)
			//assume A = 1m^2
			var/deltaT = RC.temperature - src.temperature
			//heat transfer coefficient
			var/hTC = calculateHeatTransferCoefficient(RC.material,src.material)
			RC.temperature += thermal_cross_section*-deltaT*hTC
			src.temperature += thermal_cross_section*deltaT*hTC
			if(RC.temperature < 0 || src.temperature < 0)
				CRASH("TEMP WENT NEGATIVE")
			RC.material.triggerTemp(RC,RC.temperature)
			src.material.triggerTemp(src,src.temperature)
		//heat transfer with reactor vessel
		var/obj/machinery/atmospherics/binary/nuclear_reactor/holder = src.loc
		if(istype(holder))
			var/deltaT = holder.temperature - src.temperature
			var/hTC = calculateHeatTransferCoefficient(holder.material,src.material)

			holder.temperature += thermal_cross_section*-deltaT*hTC
			src.temperature += thermal_cross_section*deltaT*hTC
			if(holder.temperature < 0 || src.temperature < 0)
				CRASH("TEMP WENT NEGATIVE")

			holder.material.triggerTemp(holder,holder.temperature)
			src.material.triggerTemp(src,src.temperature)
		if((src.temperature > src.melting_point) && (src.melt_health > 0))
			src.melt_health -= 10
		if(src.melt_health <= 0)
			src.melt() //oh no


	proc/processNeutrons(var/list/datum/neutron/inNeutrons)
		for(var/datum/neutron/N as anything in inNeutrons)
			if(prob(src.material.getProperty("density")*10*src.neutron_cross_section)) //dense materials capture neutrons, configuration influences that
				//if a neutron is captured, we either do fission or we slow it down
				if(N.velocity <= 1 & prob(src.material.getProperty("n_radioactive")*10)) //neutron stimulated emission
					for(var/i in 1 to 5)
						inNeutrons += new /datum/neutron(pick(alldirs), pick(2,3))
					inNeutrons -= N
					qdel(N)
					src.temperature += 50
				else if(N.velocity <= 1 & prob(src.material.getProperty("radioactive")*10)) //stimulated emission
					for(var/i in 1 to 5)
						inNeutrons += new /datum/neutron(pick(alldirs), pick(1,2,3))
					inNeutrons -= N
					qdel(N)
					src.temperature += 25
				else
					if(prob(src.material.getProperty("hard")*10)) //reflection is based on hardness
						N.dir = turn(N.dir,pick(180,225,135)) //either complete 180 or  180+/-45
					else if(is_control_rod) //control rods absorb neutrons
						N.velocity = 0
					else //everything else moderates them
						N.velocity--
					if(N.velocity <= 0)
						inNeutrons -= N
						qdel(N)
					src.temperature += 1

		if(prob(src.material.getProperty("n_radioactive")*10*src.neutron_cross_section)) //fast spontaneous emission
			for(var/i in 1 to 3)
				inNeutrons += new /datum/neutron(pick(alldirs), 3) //neutron radiation gets you fast neutrons
			src.material.adjustProperty("n_radioactive", -0.01)
			src.material.setProperty("radioactive", src.material.getProperty("radioactive") + 0.005)
			src.temperature += 20
		if(prob(src.material.getProperty("radioactive")*10*src.neutron_cross_section)) //spontaneous emission
			for(var/i in 1 to 3)
				inNeutrons += new /datum/neutron(pick(alldirs), pick(1,2,3))
			src.material.adjustProperty("radioactive", -0.01)
			src.material.setProperty("spent_fuel", src.material.getProperty("spent_fuel") + 0.005)
			src.temperature += 10
		return inNeutrons

	proc/mob_holding_temp_react(mob/user, mult)
		if(src.temperature < T0C + 80)
			return FALSE
		if(ON_COOLDOWN(user, "reactor_comp_burn", 2 SECONDS))
			return

		if(user.equipped(src))
			var/obj/item/clothing/gloves/gloves
			if (ishuman(user))
				var/mob/living/carbon/human/H = user
				gloves = H.gloves
			else
				gloves = null
			if(!gloves || gloves.material?.getProperty("thermal") > 2)
				boutput(user, "<span class='alert'>\The [src] burns your hand!</span>")
				user.TakeDamageAccountArmor(user.hand ? "l_arm" : "r_arm", 0, min((src.temperature-T0C)/20, 50) * mult, 0, DAMAGE_BURN)

		if(src.temperature > T0C + 400)
			boutput(user, "<span class='alert'><b>\The [src] sets you on fire with its extreme heat!</b></span>")
			user.changeStatus("burning", 30 SECONDS)
		return TRUE

	pickup(mob/user)
		. = ..()
		if(src.mob_holding_temp_react(user, 1))
			RegisterSignal(user, COMSIG_LIVING_LIFE_TICK, .proc/mob_holding_temp_react)

	dropped(mob/user)
		. = ..()
		UnregisterSignal(user, COMSIG_LIVING_LIFE_TICK)


////////////////////////////////////////////////////////////////
//Fuel rod
/obj/item/reactor_component/fuel_rod
	name = "fuel rod"
	desc = "A fuel rod for a nuclear reactor."
	icon_state_inserted = "fuel"
	icon_state_cap = "fuel_cap"
	neutron_cross_section = 1.0
	thermal_cross_section = 0.02

	extra_info()
		. = ..()
		. += "Radioactivity: [max(src.material.getProperty("n_radioactive")*10,src.material.getProperty("radioactive")*10)]%"
////////////////////////////////////////////////////////////////
//Control rod
/obj/item/reactor_component/control_rod
	name = "control rod"
	desc = "A control rod assembly for a nuclear reactor."
	icon_state_inserted = "control"
	icon_state_cap = "control_cap"
	/// Control rods have a variable neutron_cross_section, which is essentially *actual* insertion level
	neutron_cross_section = 1.0
	/// Target insertion level, will be approached by up to 0.1 per tick
	var/configured_insertion_level = 1.0
	is_control_rod = TRUE

	extra_info()
		. = ..()
		if(!melted)
			. += "Insertion: [neutron_cross_section*100]%"

	processNeutrons(list/datum/neutron/inNeutrons)
		. = ..()
		if((!src.melted) & (src.neutron_cross_section != src.configured_insertion_level))
			//step towards configured insertion level
			if(src.configured_insertion_level < src.neutron_cross_section)
				src.neutron_cross_section -= min(0.1, src.neutron_cross_section - src.configured_insertion_level)//TODO balance - this is 10% per tick, which is like every 3 seconds or something
			else
				src.neutron_cross_section += min(0.1, src.configured_insertion_level - src.neutron_cross_section)

////////////////////////////////////////////////////////////////
//Heat exchanger
/obj/item/reactor_component/heat_exchanger
	name = "heat exchanger"
	desc = "A heat exchanger component for a nuclear reactor."
	icon_state_inserted = "heat"
	icon_state_cap = "heat_cap"
	thermal_cross_section = 0.4
	neutron_cross_section = 0.1

////////////////////////////////////////////////////////////////
//Gas channel
/obj/item/reactor_component/gas_channel
	name = "gas channel"
	desc = "A gas coolant channel component for a nuclear reactor."
	icon_state_inserted = "gas"
	icon_state_cap = "gas_cap"
	thermal_cross_section = 0.05
	var/gas_thermal_cross_section = 0.95
	var/datum/gas_mixture/current_gas
	gas_volume = 100

	melt()
		..()
		gas_thermal_cross_section = 0.1 //oh no, all the fins and stuff are melted

	processNeutrons(list/datum/neutron/inNeutrons)
		. = ..()
		if(current_gas && current_gas.toxins > 0)
			for(var/datum/neutron/N in .)
				if(N.velocity > 0 && prob(current_gas.toxins/10))
					N.velocity++
					current_gas.toxins--
					current_gas.radgas+=10

	processGas(var/datum/gas_mixture/inGas)
		if(src.current_gas)
			//heat transfer equation = hA(T2-T1)
			//assume A = 1m^2
			var/deltaT = src.current_gas.temperature - src.temperature
			//heat transfer coefficient
			var/hTC = calculateHeatTransferCoefficient(null, src.material)
			if(hTC>0)
				//gas density << metal density, so energy to heat gas to T is much small than energy to heat metal to T
				//basically, we just need a specific heat capactiy factor in here
				//fortunately, atmos has macros for that - for everything else, let's just assume steel's heat capacity and density
				//shc * moles/(shc of steel * density of steel * volume / molar mass of steel)
				var/gas_thermal_e = THERMAL_ENERGY(current_gas)
				src.current_gas.temperature += gas_thermal_cross_section*-deltaT*hTC
				//Q = mcT
				//dQ = mc(dT)
				//dQ/mc = dT
				src.temperature += (gas_thermal_e - THERMAL_ENERGY(current_gas))/(420*7700*0.05) //specific heat capacity of steel (420 J/KgC) * density of steel (7700 Kg/m^3) * volume of material the gas channel is made of (m^3)
				if(src.current_gas.temperature < 0 || src.temperature < 0)
					CRASH("TEMP WENT NEGATIVE")
			. = src.current_gas
			if(src.melted)
				var/turf/T = get_turf(src.loc)
				if(T)
					T.assume_air(current_gas)
		if(inGas)
			src.current_gas = inGas.remove((src.gas_volume*MIXTURE_PRESSURE(inGas))/(R_IDEAL_GAS_EQUATION*inGas.temperature))


