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
	material_amt = 1 //cannot efficiently recycle these

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
	var/thermal_cross_section = 10
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
	/// Thermal mass. Basically how much energy it takes to heat this up 1Kelvin
	var/thermal_mass = 420*250//specific heat capacity of steel (420 J/KgK) * mass of component (Kg)


	New(material="steel")
		..()
		if(istype(material, /datum/material))
			src.setMaterial(material)
		else
			src.setMaterial(getMaterial(material))
		melt_health = _max_health
		var/img_check = ui_image_base64_cache[src.type]
		if (img_check)
			src.ui_image = img_check
		else
			var/icon/dummy_icon = icon(initial(src.icon), initial(src.icon_state_inserted))
			src.ui_image = icon2base64(dummy_icon)
			ui_image_base64_cache[src.type] = src.ui_image

	setMaterial(var/datum/material/mat1, var/appearance = TRUE, var/setname = TRUE, var/mutable = TRUE, var/use_descriptors = FALSE) //mutable is the default here, for obvious reasons
		. = ..()
		src.cap_icon = icon(src.icon, src.icon_state_cap)
		if(appearance) //some mildly cursed code to set material appearance on the end caps
			if (mat1.getID() in src.get_typeinfo().mat_appearances_to_ignore)
				return
			if (src.mat_changeappearance && mat1.shouldApplyColor())
				var/list/setcolor = mat1.getColor()
				if(istext(mat1.getColor()))
					setcolor = rgb2num(mat1.getColor())
				if(islist(mat1.getColor()))
					setcolor = mat1.getColor()

				if(length(setcolor) == 4)
					setcolor[4] = mat1.getAlpha()
				else if(length(setcolor) == 3)
					setcolor += mat1.getAlpha()

				if (mat1.getTexture())
					var/icon_mode = null
					switch(mat1.getTextureBlendMode()) //fucking byond...
						if(BLEND_DEFAULT) icon_mode = ICON_OVERLAY
						if(BLEND_OVERLAY) icon_mode = ICON_OVERLAY
						if(BLEND_ADD) icon_mode = ICON_ADD
						if(BLEND_SUBTRACT) icon_mode = ICON_SUBTRACT
						if(BLEND_MULTIPLY) icon_mode = ICON_MULTIPLY
						if(BLEND_INSET_OVERLAY) icon_mode = ICON_OVERLAY

					src.cap_icon.Blend(getTexturedIcon(src.cap_icon, mat1.getTexture()), icon_mode)

				if(length(setcolor) > 4) //ie, if it's a color matrix
					src.cap_icon.MapColors(arglist(setcolor))
				else
					src.cap_icon.Blend(rgb(setcolor[1],setcolor[2],setcolor[3],setcolor[4]), ICON_MULTIPLY)

	proc/melt()
		if(melted)
			return
		src.melted = TRUE
		src.name = "melted "+src.name
		src.icon_state_cap += "_melted_[rand(1,4)]"
		src.setMaterial(src.material, TRUE, FALSE, FALSE)
		var/obj/machinery/atmospherics/binary/nuclear_reactor/parent = src.loc
		if(istype(parent))
			parent.MarkGridForUpdate()
			parent.UpdateIcon()
		src.neutron_cross_section = 5.0
		src.thermal_cross_section = 20.0
		src.is_control_rod = FALSE

	proc/extra_info()
		. = ""

	proc/processGas(var/datum/gas_mixture/inGas)
		return null //most components won't touch gas

	proc/processHeat(var/list/obj/item/reactor_component/adjacentComponents)
		for(var/obj/item/reactor_component/RC as anything in adjacentComponents)
			if(isnull(RC))
				continue
			//first, define some helpful vars
			// temperature differential
			var/deltaT = src.temperature - RC.temperature
			//thermal conductivity
			var/k = calculateHeatTransferCoefficient(RC.material,src.material)
			//surface area in thermal contact (m^2)
			var/A = min(src.thermal_cross_section,RC.thermal_cross_section)
			src.temperature = src.temperature - (k * A * (MACHINE_PROC_INTERVAL*8)/src.thermal_mass)*deltaT //8 because machines are ticked when % 8 == 0
			RC.temperature = RC.temperature - (k * A * (MACHINE_PROC_INTERVAL*8)/RC.thermal_mass)*-deltaT

			if(RC.temperature < 0 || src.temperature < 0)
				CRASH("TEMP WENT NEGATIVE")
			RC.material_trigger_on_temp(RC.temperature)
			src.material_trigger_on_temp(src.temperature)
		//heat transfer with reactor vessel
		var/obj/machinery/atmospherics/binary/nuclear_reactor/holder = src.loc
		if(istype(holder))
			var/deltaT = src.temperature - holder.temperature
			var/k = calculateHeatTransferCoefficient(holder.material,src.material)
			var/A = src.thermal_cross_section
			src.temperature = src.temperature - (k * A * (MACHINE_PROC_INTERVAL*8)/src.thermal_mass)*deltaT
			holder.temperature = holder.temperature - (k * A * (MACHINE_PROC_INTERVAL*8)/holder.thermal_mass)*-deltaT
			if(holder.temperature < 0 || src.temperature < 0)
				CRASH("TEMP WENT NEGATIVE")

			holder.material_trigger_on_temp(holder.temperature)
			src.material_trigger_on_temp(src.temperature)
		if((src.temperature > src.melting_point) && (src.melt_health > 0))
			src.melt_health -= rand(10,50)
		if(src.melt_health <= 0)
			src.melt() //oh no


	proc/processNeutrons(var/list/datum/neutron/inNeutrons)
		for(var/datum/neutron/N as anything in inNeutrons)
			if(prob(src.material.getProperty("density")*10*src.neutron_cross_section)) //dense materials capture neutrons, configuration influences that
				//if a neutron is captured, we either do fission or we slow it down
				if(N.velocity <= 1 & prob(src.material.getProperty("n_radioactive")*10)) //neutron stimulated emission
					src.material.adjustProperty("n_radioactive", -0.01)
					src.material.setProperty("radioactive", src.material.getProperty("radioactive") + 0.005)
					for(var/i in 1 to 5)
						inNeutrons += new /datum/neutron(pick(alldirs), pick(2,3))
					inNeutrons -= N
					qdel(N)
					src.temperature += 50
				else if(N.velocity <= 1 & prob(src.material.getProperty("radioactive")*10)) //stimulated emission
					src.material.adjustProperty("radioactive", -0.01)
					src.material.setProperty("spent_fuel", src.material.getProperty("spent_fuel") + 0.005)
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
				boutput(user, SPAN_ALERT("\The [src] burns your hand!"))
				user.TakeDamageAccountArmor(user.hand ? "l_arm" : "r_arm", 0, min((src.temperature-T0C)/20, 50) * mult, 0, DAMAGE_BURN)

		if(src.temperature > T0C + 400)
			boutput(user, SPAN_ALERT("<b>\The [src] sets you on fire with its extreme heat!</b>"))
			user.changeStatus("burning", 30 SECONDS)
		return TRUE

	pickup(mob/user)
		. = ..()
		if(src.mob_holding_temp_react(user, 1))
			RegisterSignal(user, COMSIG_LIVING_LIFE_TICK, PROC_REF(mob_holding_temp_react))

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
	thermal_cross_section = 10
	thermal_mass = 420*1000//specific heat capacity of steel (420 J/KgK) * mass of component (Kg)

	extra_info()
		. = ..()
		. += "Radioactivity: [max(src.material.getProperty("n_radioactive")*10,src.material.getProperty("radioactive")*10)]%"

/obj/item/reactor_component/fuel_rod/glowsticks
	name = "makeshift fuel rod"
	desc = "A fuel rod fo- hey this is just a squashed glowstick!"
	melting_point = T0C+400 //plastic glowsticks melt easy

	New(material)
		if(isnull(material))
			.=..("glowstick") //force material
		else
			.=..()
////////////////////////////////////////////////////////////////
//Control rod
/obj/item/reactor_component/control_rod
	name = "control rod"
	desc = "A control rod assembly for a nuclear reactor."
	icon_state_inserted = "control"
	icon_state_cap = "control_cap"
	thermal_cross_section = 10
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
	thermal_cross_section = 25
	neutron_cross_section = 0.1

////////////////////////////////////////////////////////////////
//Gas channel
/obj/item/reactor_component/gas_channel
	name = "gas channel"
	desc = "A gas coolant channel component for a nuclear reactor. Rated for 100 liters of gas flow volume."
	icon_state_inserted = "gas"
	icon_state_cap = "gas_cap"
	thermal_cross_section = 15
	var/gas_thermal_cross_section = 15
	var/datum/gas_mixture/air_contents
	gas_volume = 100
	thermal_mass = 420*50//specific heat capacity of steel (420 J/KgK) * mass of component (Kg)

	return_air(direct = FALSE)
		return air_contents

	melt()
		..()
		gas_thermal_cross_section = 0.1 //oh no, all the fins and stuff are melted

	processNeutrons(list/datum/neutron/inNeutrons)
		. = ..()
		if(air_contents)
			for(var/datum/neutron/N in .)
				if(N.velocity > 0)
					var/neutron_count = src.air_contents.neutron_interact()
					if(neutron_count > 1)
						for(var/i in 1 to neutron_count)
							. += new /datum/neutron(pick(alldirs), rand(1,3))
					else if(neutron_count < 1)
						. -= N
						qdel(N)


	processGas(var/datum/gas_mixture/inGas)
		if(src.air_contents)
			//first, define some helpful vars
			// temperature differential
			var/deltaT = src.temperature - src.air_contents.temperature
			// temp differential for radiative heating
			//this is equivelant to (src.temperature ** 4) - (src.current_gas.temperature ** 4), but factored so its less likely to hit overflow
			var/deltaTr = (src.temperature + src.air_contents.temperature)*(src.temperature - src.air_contents.temperature)*((src.temperature**2) + (src.air_contents.temperature**2))

			//thermal conductivity
			var/k = calculateHeatTransferCoefficient(null,src.material)
			//surface area in thermal contact (m^2)
			var/A = src.gas_thermal_cross_section * (MACHINE_PROC_INTERVAL*8) //multipied by process time to approximate flow rate

			var/thermal_e = THERMAL_ENERGY(air_contents)
			//commented out for later debugging purposes
			//var/coe_check = thermal_e + src.temperature*src.thermal_mass

			//okay, we're slightly abusing some things here. Notably we're using the thermal conductivity as a stand-in
			//for the convective heat transfer coefficient(h). It's wrong, since h generally depends on flow rate, but we
			//can assume a constant flow rate and then a dependence on the thermal conductivity of the material it's flowing over
			//which in this case is given by k
			//also radiative heating given by Steffan-Boltzman constant * area * (T1^4 - T2^4) ( + (5.67037442e-8 * A * deltaTr))
			//since this is a discrete approximation, it breaks down when the temperature diffs are low. As such, we linearise the equation
			//by clamping between hottest and coldest. It's not pretty, but it works.
			var/hottest = max(src.air_contents.temperature, src.temperature)
			var/coldest = min(src.air_contents.temperature, src.temperature)
			//max limit on the energy transfered is bounded between the coldest and hottest temperature of the thermal mass, to ensure that the
			//gas can't suck out more heat from the component than exists
			var/max_delta_e = clamp(((k * A * deltaT) + (5.67037442e-8 * A * deltaTr)), src.temperature*src.thermal_mass - hottest*src.thermal_mass, src.temperature*src.thermal_mass - coldest*src.thermal_mass)
			src.air_contents.temperature = clamp(src.air_contents.temperature + max_delta_e/HEAT_CAPACITY(src.air_contents), coldest, hottest)
			//after we've transferred heat to the gas, we remove that energy from the gas channel to preserve CoE
			src.temperature = clamp(src.temperature - (THERMAL_ENERGY(air_contents) - thermal_e)/src.thermal_mass, coldest, hottest)

			//commented out for later debugging purposes
			//var/coe2 = (THERMAL_ENERGY(air_contents) + src.temperature*src.thermal_mass)
			//if(abs(coe2 - coe_check) > 64)
			//	CRASH("COE VIOLATION COMPONENT")
			if(src.air_contents.temperature < 0 || src.temperature < 0)
				CRASH("TEMP WENT NEGATIVE")


			if(src.melted)
				var/turf/T = get_turf(src.loc)
				if(T)
					T.assume_air(air_contents)
			else
				. = src.air_contents
		if(inGas && (THERMAL_ENERGY(inGas) > 0))
			src.air_contents = inGas.remove((src.gas_volume*MIXTURE_PRESSURE(inGas))/(R_IDEAL_GAS_EQUATION*inGas.temperature))
			src.air_contents?.volume = gas_volume
			if(src.air_contents && TOTAL_MOLES(src.air_contents) < 1)
				if(istype(., /datum/gas_mixture))
					var/datum/gas_mixture/result = .
					result.merge(src.air_contents)
					src.air_contents = null
					return result
				else
					. = src.air_contents
					src.air_contents = null
					return .

#define SANE_COMPONENT_MATERIALS \
		100;"gold",\
		100;"syreline",\
		100;"silver",\
		100;"cobryl",\
		50;"miracle",\
		20;"soulsteel",\
		20;"hauntium",\
		20;"ectoplasm",\
		10;"ectofibre",\
		10;"wiz_quartz",\
		10;"wiz_topaz",\
		10;"wiz_ruby",\
		10;"wiz_amethyst",\
		10;"wiz_emerald",\
		10;"wiz_sapphire",\
		10;"gnesis",\
		10;"gnesisglass",\
		10;"starstone",\
		100;"koshmarite",\
		100;"plasmastone",\
		50;"telecrystal",\
		30;"erebite",\
		100;"flesh",\
		100;"viscerite",\
		100;"leather",\
		100;"cotton",\
		100;"coral",\
		50;"spidersilk",\
		50;"beewool",\
		50;"beeswax",\
		50;"chitin",\
		50;"bamboo",\
		50;"wood",\
		50;"bone",\
		20;"blob",\
		60;"pizza",\
		20;"butt",\
		100;"electrum",\
		100;"steel",\
		100;"mauxite",\
		100;"copper",\
		100;"pharosium",\
		100;"glass",\
		100;"char",\
		100;"molitz",\
		50;"molitz_b",\
		50;"bohrum",\
		70;"cerenkite",\
		50;"plasmasteel",\
		50;"claretine",\
		50;"plasmaglass",\
		50;"uqill",\
		50;"latex",\
		50;"synthrubber",\
		50;"synthblubber",\
		50;"synthleather",\
		50;"fibrilith",\
		30;"carbonfibre",\
		30;"diamond",\
		30;"dyneema",\
		20;"iridiumalloy",\
		5;"neutronium",\
		100;"rock",\
		100;"slag",\
		100;"ice",\
		5;"spacelag",\
		15;"cardboard",\
		15;"frozenfart",\
		5;"negativematter",\
		5;"plutonium",\
		100; "glowstick"

/obj/item/reactor_component/fuel_rod/random_material
	New()
		..(pick(SANE_COMPONENT_MATERIALS))
/obj/item/reactor_component/control_rod/random_material
	New()
		..(pick(SANE_COMPONENT_MATERIALS))
/obj/item/reactor_component/gas_channel/random_material
	New()
		..(pick(SANE_COMPONENT_MATERIALS))
/obj/item/reactor_component/heat_exchanger/random_material
	New()
		..(pick(SANE_COMPONENT_MATERIALS))

#undef SANE_COMPONENT_MATERIALS
