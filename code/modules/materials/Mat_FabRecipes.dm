//See bottom of file for valid materials in /simple recipes.

/datum/matfab_recipe/simple/nuclear
	name = "Nuclear Component - base"
	desc = "You shouldn't see this"
	category = "Nuclear"
	result = /obj/item/reactor_component

	postProcess(obj/item/reactor_component/I)
		. = ..()
		//default properties for all materials - everything is a sponge unless otherwise specified
		if(!I.material.hasProperty("density"))
			I.material.setProperty("density", 1)
		if(!I.material.hasProperty("hard"))
			I.material.setProperty("hard", 1)
		if(I.material.getID()=="ice") //ice is cold
			I.temperature = T0C-10

/datum/matfab_recipe/simple/nuclear/fuel_rod
	name = "Nuclear Fuel Rod"
	desc = "A fuel rod for a nuclear reactor"
	category = "Nuclear"
	materials = list("!any"=2)
	result = /obj/item/reactor_component/fuel_rod

/datum/matfab_recipe/makeshift_fuel_rod
	name = "Makeshift Nuclear Fuel Rod"
	desc = "A fuel rod for a nuclear reactor, made out of glowsticks"
	category = "Nuclear"

	New()
		..()
		required_parts.Add(new/datum/matfab_part/glowstick {part_name = "Glowstick"; required_amount = 1} ())

	build(amount, obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/device/light/glowstick/stick = getObjectByPartName("Glowstick")
			var/datum/material/glowstick_mat = getMaterial("glowstick")
			glowstick_mat = glowstick_mat.getMutable()
			glowstick_mat.setColor(rgb(stick.col_r*255, stick.col_g*255, stick.col_b*255))
			var/obj/item/reactor_component/fuel_rod/glowsticks/result_rod = new /obj/item/reactor_component/fuel_rod/glowsticks(glowstick_mat)
			result_rod.set_loc(getOutputLocation(owner))

/datum/matfab_recipe/simple/nuclear/control_rod
	name = "Control Rod"
	desc = "A control rod for a nuclear reactor"
	category = "Nuclear"
	materials = list("!any"=2)
	result = /obj/item/reactor_component/control_rod

/datum/matfab_recipe/simple/nuclear/heat_exchanger
	name = "Heat Exchanger"
	desc = "A heat exchanger component for a nuclear reactor"
	category = "Nuclear"
	materials = list("!any"=2)
	result = /obj/item/reactor_component/heat_exchanger

/datum/matfab_recipe/simple/nuclear/gas_channel
	name = "Coolant Channel"
	desc = "A coolant channel component for a nuclear reactor"
	category = "Nuclear"
	materials = list("!any"=2)
	result = /obj/item/reactor_component/gas_channel

/datum/matfab_recipe/simple/turbine
	name = "Turbine Component - base"
	desc = "You shouldn't see this"
	category = "Nuclear"
	result = /obj/item/turbine_component

	postProcess(obj/item/I)
		. = ..()
		//default properties for all materials - everything is a sponge unless otherwise specified
		if(!I.material.hasProperty("density"))
			I.material.setProperty("density", 1)

/datum/matfab_recipe/simple/turbine/blade
	name = "Turbine Blade"
	desc = "A replacement blade for the reactor turbine"
	category = "Nuclear"
	materials = list("!any"=2)
	result = /obj/item/turbine_component/blade

/datum/matfab_recipe/simple/turbine/stator
	name = "Turbine Stator"
	desc = "A replacement stator coil for the reactor turbine"
	category = "Nuclear"
	materials = list("!any"=2)
	result = /obj/item/turbine_component/stator

/datum/matfab_recipe/spacesuit
	name = "Space Suit Set"
	desc = "A complete space suit."
	category = "Clothing"

	New()
		..()
		required_parts.Add(new/datum/matfab_part/clothororganicorrubber {part_name = "Fabric"; required_amount = 3} ())
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Reinforcement"; required_amount = 3} ())
		required_parts.Add(new/datum/matfab_part/crystal {part_name = "Visor"; required_amount = 2} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/clothing/suit/space/custom/suit = new()
			var/obj/item/clothing/head/helmet/space/custom/helm = new()
			var/obj/item/fabr = getObjectByPartName("Fabric")
			var/obj/item/visr = getObjectByPartName("Visor")
			var/obj/item/renf = getObjectByPartName("Reinforcement")

			suit.set_custom_mats(fabr.material, renf.material)
			helm.set_custom_mats(fabr.material, visr.material)

			suit.set_loc(getOutputLocation(owner))
			helm.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/mining_mod_conc
	name = "Tool mod (Concussive)"
	desc = "A mod for mining tools. Increases area of effect."
	category = "Mining Tools"

	New()
		..()
		required_parts.Add(new/datum/matfab_part/radiocative_material {part_name = "Internal"; required_amount = 45} ())
		required_parts.Add(new/datum/matfab_part/charge {part_name = "Charge"; required_amount = 1} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/mining_mod/conc/newObj = new()
			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/mining_head_pick
	name = "Tool head (Pick)"
	desc = "A Pick head. Picks have high power but no area of effect."
	category = "Mining Tools"

	New()
		..()
		required_parts.Add(new/datum/matfab_part/anymat {part_name = "Base"; required_amount = 5} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/mining_head/pick/newObj = new()
			var/obj/item/source = getObjectByPartName("Base")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return


/datum/matfab_recipe/mining_head_blaster
	name = "Tool head (Blaster)"
	desc = "A Blaster head. Blasters have lower power but very high area of effect."
	category = "Mining Tools"

	New()
		..()
		required_parts.Add(new/datum/matfab_part/anymat {part_name = "Base"; required_amount = 5} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/mining_head/blaster/newObj = new()
			var/obj/item/source = getObjectByPartName("Base")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/mining_head_hammer
	name = "Tool head (Hammer)"
	desc = "A Hammer head. Hammers have a wide area of effect and normal power."
	category = "Mining Tools"

	New()
		..()
		required_parts.Add(new/datum/matfab_part/anymat {part_name = "Base"; required_amount = 5} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/mining_head/hammer/newObj = new()
			var/obj/item/source = getObjectByPartName("Base")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/mining_head_drill
	name = "Tool head (Drill)"
	desc = "A Drill head. Drills have a long area of effect and normal power."
	category = "Mining Tools"

	New()
		..()
		required_parts.Add(new/datum/matfab_part/anymat {part_name = "Base"; required_amount = 5} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/mining_head/drill/newObj = new()
			var/obj/item/source = getObjectByPartName("Base")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/mining_tool
	name = "Mining Tool"
	desc = "A tool for mining asteroids. Type of tool depends on components used. Optional modifier slot."
	category = "Mining Tools"

	New()
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Body"; required_amount = 10} ())
		required_parts.Add(new/datum/matfab_part/any_mtool_head {part_name = "Tool Head"; required_amount = 1} ())
		required_parts.Add(new/datum/matfab_part/optionalmat_mining {part_name = "Tool Mod"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/newtype = null
			var/obj/item/mining_tools/newObj
			var/obj/item/body = getObjectByPartName("Body")
			var/obj/item/head = getObjectByPartName("Tool Head")
			var/obj/item/opt = getObjectByPartName("Tool Mod")

			if(istype(head, /obj/item/mining_head/drill))
				newtype = /obj/item/mining_tools/drill
			else if(istype(head, /obj/item/mining_head/hammer))
				newtype = /obj/item/mining_tools/hammer
			else if(istype(head, /obj/item/mining_head/blaster))
				newtype = /obj/item/mining_tools/blaster
			else if(istype(head, /obj/item/mining_head/pick))
				newtype = /obj/item/mining_tools/pick

			if(newtype && body?.material && head?.material)
				newObj = new newtype(src)
				if(istype(opt, /obj/item/mining_mod/conc))
					newObj.blasting = 1

				newObj.setMaterial(mat1 = head.material, appearance = 1, setname = 1, use_descriptors = 0)

				if(newObj.blasting)
					newObj.remove_prefixes(99)
					newObj.name_prefix("Blasting")
					newObj.name_prefix(head.material.getName() ? head.material.getName() : "")
					newObj.UpdateName()
				else if(newObj.powered)
					newObj.remove_prefixes(99)
					newObj.name_prefix("Powered")
					newObj.name_prefix(head.material.getName() ? head.material.getName() : "")
					newObj.UpdateName()

				newObj.desc = "[initial(newObj.desc)] It has \a [head.name]."

			newObj.set_loc(getOutputLocation(owner))
			if(newObj.power > SPIKES_MEDAL_POWER_THRESHOLD)
				var/mob/living/player = usr
				if(istype(player))
					player.unlock_medal("This object menaces with spikes of...", 1)
		return

/datum/matfab_recipe/coilsmall
	name = "Small coil"
	desc = "A small coil used in various objects."
	category = "Components"

	New()
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Coil"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/coil/small/newObj = new()
			var/obj/item/source = getObjectByPartName("Coil")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/spear
	name = "Spear"
	desc = "A simple spear with long reach."
	category = "Weapons"

	New()
		required_parts.Add(new/datum/matfab_part/metalororganic {part_name = "Shaft"; required_amount = 3} ())
		required_parts.Add(new/datum/matfab_part/metalorcrystalororganic {part_name = "Head"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/experimental/melee/spear/newObj = new()
			var/obj/item/shaft = getObjectByPartName("Shaft")
			var/obj/item/head = getObjectByPartName("Head")
			if(shaft?.material && head?.material)
				newObj.setShaftMaterial(shaft.material)
				newObj.setHeadMaterial(head.material)
				newObj.buildOverlays()

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/arrow
	name = "Arrow"
	desc = "A simple arrow used as ammunition for bows."
	category = "Weapons"

	New()
		required_parts.Add(new/datum/matfab_part/metalorcrystalororganic {part_name = "Arrowhead"; required_amount = 1} ())
		required_parts.Add(new/datum/matfab_part/metalororganic {part_name = "Shaft"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		var/obj/item/arrow/newObj = new()
		var/obj/item/arrowhead = getObjectByPartName("Arrowhead")
		var/obj/item/shaft = getObjectByPartName("Shaft")

		if(arrowhead?.material && shaft?.material)
			newObj.setHeadMaterial(arrowhead.material)
			newObj.setShaftMaterial(shaft.material)

		newObj.change_stack_amount(amount - newObj.amount)
		newObj.set_loc(getOutputLocation(owner))

		return

/datum/matfab_recipe/bow
	name = "Bow"
	desc = "A simple bow."
	category = "Weapons"

	New()
		required_parts.Add(new/datum/matfab_part/metalororganic {part_name = "Bow"; required_amount = 3} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/gun/bow/newObj = new()
			var/obj/item/source = getObjectByPartName("Bow")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/quiver
	name = "Quiver"
	desc = "A quiver for arrows."
	category = "Weapons"

	New()
		required_parts.Add(new/datum/matfab_part/clothorrubber {part_name = "Quiver"; required_amount = 2} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/quiver/newObj = new()
			var/obj/item/source = getObjectByPartName("Quiver")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/lens
	name = "Lens"
	desc = "A lens used as a component in various objects."
	category = "Components"

	New()
		required_parts.Add(new/datum/matfab_part/crystal {part_name = "Lens"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/lens/newObj = new()
			var/obj/item/source = getObjectByPartName("Lens")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/tripod
	name = "Tripod"
	desc = "A tripod for attaching a light to."
	category = "Components"

	New()
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Tripod"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/tripod/newObj = new()
			var/obj/item/source = getObjectByPartName("Tripod")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/glasses
	name = "Glasses"
	desc = "A pair of non-corrective glasses."
	category = "Clothing"

	New()
		required_parts.Add(new/datum/matfab_part/crystal {part_name = "Glasses"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/clothing/glasses/crafted/newObj = new()
			var/obj/item/source = getObjectByPartName("Glasses")
			if(source?.material)
				newObj.setMaterial(source.material)
				newObj.color_r = GetRedPart(source.material.getColor()) / 255
				newObj.color_g = GetGreenPart(source.material.getColor()) / 255
				newObj.color_b = GetBluePart(source.material.getColor()) / 255

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/jumpsuit
	name = "Jumpsuit"
	desc = "A custom made jumpsuit. Has no special properties."
	category = "Clothing"

	New()
		required_parts.Add(new/datum/matfab_part/clothororganicorrubber {part_name = "Jumpsuit"; required_amount = 3} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/clothing/under/crafted/newObj = new()
			var/obj/item/source = getObjectByPartName("Jumpsuit")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/glovesins
	name = "Insulating gloves"
	desc = "Custom insulating gloves. Inherits thermally and electrically insulating properties."
	category = "Clothing"

	New()
		required_parts.Add(new/datum/matfab_part/clothororganicorrubber {part_name = "Gloves"; required_amount = 2} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/clothing/gloves/crafted/insulating/newObj = new()
			var/obj/item/source = getObjectByPartName("Gloves")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/glovearmor
	name = "Armored gloves"
	desc = "Custom armored gloves. Inherits physical properties like toughness and hardness."
	category = "Clothing"

	New()
		required_parts.Add(new/datum/matfab_part/clothororganicorrubber {part_name = "Gloves"; required_amount = 2} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/clothing/gloves/crafted/armored/newObj = new()
			var/obj/item/source = getObjectByPartName("Gloves")
			if(source?.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/shoes
	name = "Shoes"
	desc = "A custom pair of shoes."
	category = "Clothing"

	New()
		required_parts.Add(new/datum/matfab_part/clothororganicorrubber {part_name = "Upper"; required_amount = 2} ())
		required_parts.Add(new/datum/matfab_part/anymat {part_name = "Sole"; required_amount = 2} ())
		required_parts.Add(new/datum/matfab_part/optionalanymat {part_name = "Optional Toe Tip"; required_amount = 2} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/clothing/shoes/crafted/newObj = new()
			var/obj/item/upper = getObjectByPartName("Upper")
			var/obj/item/sole = getObjectByPartName("Sole")
			var/obj/item/toe = getObjectByPartName("Optional Toe Tip")
			if(toe && toe.material)
				newObj.setMaterial(toe.material)
				newObj.desc = "[toe.material.getName()]-toed [upper.material.getName()] shoes. The soles are made of [sole.material.getName()]."
			else if(upper && upper.material)
				newObj.setMaterial(upper.material)
				newObj.desc = newObj.desc + " The soles are made of [sole.material.getName()]."

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/flashlight
	name = "Flashlight"
	desc = "A simple flashlight. Light color is affected by lens color."
	category = "Lights"

	New()
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Casing"; required_amount = 1} ())
		required_parts.Add(new/datum/matfab_part/lens {part_name = "Lens"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/lensObj = getObjectByPartName("Lens")
			var/obj/item/casingObj = getObjectByPartName("Casing")
			var/obj/item/device/light/flashlight/newObj
			if(lensObj?.material)
				var/R = GetRedPart(lensObj.material.getColor()) / 255
				var/G = GetGreenPart(lensObj.material.getColor()) / 255
				var/B = GetBluePart(lensObj.material.getColor()) / 255
				newObj = new(null, R, G, B)
			else
				newObj = new
			if(casingObj?.material)
				newObj.setMaterial(casingObj.material)
				newObj.desc = newObj.desc + " It has a [lensObj.material.getName()] lens."

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/lighttube
	name = "Light tube"
	desc = "A replacement light tube. Lens color affects light color."
	category = "Lights"

	New()
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Casing"; required_amount = 1} ())
		required_parts.Add(new/datum/matfab_part/lens {part_name = "Lens"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount*1, i++)
			var/obj/item/light/tube/newObj = new()
			var/obj/item/lensObj = getObjectByPartName("Lens")
			var/obj/item/casingObj = getObjectByPartName("Casing")
			if(casingObj?.material && lensObj?.material)
				newObj.setMaterial(lensObj.material)
				newObj.desc = newObj.desc + " Its made from [lensObj.material.getName()]."
				newObj.color_r = GetRedPart(lensObj.material.getColor()) / 255
				newObj.color_g = GetGreenPart(lensObj.material.getColor()) / 255
				newObj.color_b = GetBluePart(lensObj.material.getColor()) / 255


			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/lightbulb
	name = "Light bulb"
	desc = "A replacement light bulb. Lens color affects light color."
	category = "Lights"

	New()
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Casing"; required_amount = 1} ())
		required_parts.Add(new/datum/matfab_part/lens {part_name = "Lens"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount*1, i++)
			var/obj/item/light/bulb/newObj = new()
			var/obj/item/lensObj = getObjectByPartName("Lens")
			var/obj/item/casingObj = getObjectByPartName("Casing")
			if(casingObj?.material && lensObj?.material)
				newObj.setMaterial(lensObj.material)
				newObj.desc = newObj.desc + " Its made from [lensObj.material.getName()]."
				newObj.color_r = GetRedPart(lensObj.material.getColor()) / 255
				newObj.color_g = GetGreenPart(lensObj.material.getColor()) / 255
				newObj.color_b = GetBluePart(lensObj.material.getColor()) / 255


			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/tripodbulb
	name = "Tripod bulb"
	desc = "A replacement tripod light bulb. Lens color affects light color."
	category = "Lights"

	New()
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Casing"; required_amount = 1} ())
		required_parts.Add(new/datum/matfab_part/lens {part_name = "Lens"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount*1, i++)
			var/obj/item/tripod_bulb/light/newObj = new()
			var/obj/item/lensObj = getObjectByPartName("Lens")
			var/obj/item/casingObj = getObjectByPartName("Casing")
			if(casingObj?.material && lensObj?.material)
				newObj.setMaterial(lensObj.material)
				newObj.desc = newObj.desc + " Its made from [lensObj.material.getName()]."
				newObj.light.set_color(GetRedPart(lensObj.material.getColor()) / 255, GetGreenPart(lensObj.material.getColor()) / 255, GetBluePart(lensObj.material.getColor()) / 255)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/sheet
	name = "Material sheet"
	desc = "Sheets for construction purposes."
	category = "Tools"

	New()
		required_parts.Add(new/datum/matfab_part/metalorcrystal {part_name = "Sheet"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		var/num = round(amount/5)
		amount = amount%5
		var/obj/item/source = getObjectByPartName("Sheet")
		for(var/i in 1 to num)
			var/obj/item/sheet/newObj = new()
			if(source?.material)
				newObj.setMaterial(source.material)
			newObj.change_stack_amount(50 - newObj.amount)
			newObj.set_loc(getOutputLocation(owner))
		if(amount > 0)
			var/obj/item/sheet/newObj = new()
			if(source?.material)
				newObj.setMaterial(source.material)
			newObj.change_stack_amount((amount*10) - newObj.amount)
			newObj.set_loc(getOutputLocation(owner))

/datum/matfab_recipe/thermocouple
	name = "Thermocouple"
	desc = "For use in a Thermo Electric Generator."
	category = "Tools"

	New()
		required_parts.Add(new/datum/matfab_part/metalorcrystal {part_name = "Sheet"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		var/obj/item/source = getObjectByPartName("Sheet")
		var/obj/item/teg_semiconductor/newObj = new()
		if(source?.material)
			newObj.setMaterial(source.material)
		newObj.set_loc(getOutputLocation(owner))

/datum/matfab_recipe/cell_small
	name = "Small energy cell"
	desc = "A small energy cell used in guns and small portable devices."
	category = "Tools"

	New()
		required_parts.Add(new/datum/matfab_part/conductive {part_name = "Core"; required_amount = 2} ())
		required_parts.Add(new/datum/matfab_part/radiocative_material {part_name = "Glowy Stuff"; required_amount = 2; optional = TRUE} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/ammo/power_cell/self_charging/custom/newObj = new()
			var/obj/item/source = getObjectByPartName("Core")
			var/obj/item/rads = getObjectByPartName("Glowy Stuff")
			if(source?.material)
				newObj.set_custom_mats(source?.material, rads?.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/cell_large
	name = "Large energy cell"
	desc = "A large energy cell, often used in APCs or cyborgs."
	category = "Tools"

	New()
		required_parts.Add(new/datum/matfab_part/conductive {part_name = "Core"; required_amount = 4} ())
		required_parts.Add(new/datum/matfab_part/radiocative_material {part_name = "Glowy Stuff"; required_amount = 4; optional = TRUE} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/cell/custom/newObj = new()
			var/obj/item/source = getObjectByPartName("Core")
			var/obj/item/rads = getObjectByPartName("Glowy Stuff")
			if(source?.material)
				newObj.set_custom_mats(source?.material, rads?.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/infusion
	name = "Infusion"
	desc = "Infuse a stack of provided material with a supplied chemical. Requires a Starstone as catalyst."
	category = "Refining"

	New()
		required_parts.Add(new/datum/matfab_part/chemical {part_name = "Chemical"; required_amount = 1} ())
		required_parts.Add(new/datum/matfab_part/anymat_canmix {part_name = "Unprocessed Material"; required_amount = 10} ())
		required_parts.Add(new/datum/matfab_part/starstone {part_name = "Starstone"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/refined = getObjectByPartName("Unprocessed Material")
			var/obj/item/chemical = getObjectByPartName("Chemical")

			var/master_chem = chemical.reagents.get_master_reagent()
			var/master_chem_name = chemical.reagents.get_master_reagent_name()

			var/datum/material/mat = refined.material.getMutable()

			var/datum/materialProc/generic_reagent_onlife/O = new/datum/materialProc/generic_reagent_onlife(master_chem,1)
			mat.removeAllTriggers(TRIGGERS_ON_LIFE)
			mat.addTrigger(TRIGGERS_ON_LIFE, O)

			var/datum/materialProc/generic_reagent_onattack_depleting/A = new/datum/materialProc/generic_reagent_onattack_depleting(master_chem,1,10,25)
			mat.removeAllTriggers(TRIGGERS_ON_ATTACK)
			mat.addTrigger(TRIGGERS_ON_ATTACK, A)

			var/obj/item/material_piece/wad/W = new /obj/item/material_piece/wad

			if(refined?.material)
				mat.setCanMix(0)
				mat.setName("[master_chem_name]-infused [mat.getName()]")
				mat.setID("[master_chem_name][mat.getID()]")
				W.setMaterial(mat)
				W.change_stack_amount(9)

			W.set_loc(getOutputLocation(owner))
		return

//////////////////////////////////////////////BASE CLASS BELOW

/// Base material fabricator recipie
/datum/matfab_recipe
	/// Name of the recipe.
	var/name = ""
	/// Short description of the item.
	var/desc = ""
	/// List of [/datum/matfab_part] that are required for this.
	var/list/required_parts = list()
	/// Which group this recipe belongs to.
	var/category = "Misc"

	/// Gets the maximum amount of this recipe we can make with the currently assigned objects.
	proc/getMaxAmount()
		var/maxAmt = INFINITY
		for(var/datum/matfab_part/P in required_parts)
			if(!P.assigned)
				if(!P.optional)
					maxAmt = 0
					break
				else
					continue

			maxAmt = min(maxAmt, round(P.assigned.amount / P.required_amount))

		return maxAmt

	/// Can we currently build this?
	proc/canBuild(var/amount = 1, var/atom/owner)
		for(var/datum/matfab_part/P in required_parts)
			if(P.optional)
				if(P.assigned)
					if(P.assigned && P.checkMatch(P.assigned) && (P.assigned in owner) && (amount * P.required_amount <= P.assigned.amount))
						continue
					else
						return 0
				else
					continue
			else
				if(P.assigned && P.checkMatch(P.assigned) && (P.assigned in owner) && (amount * P.required_amount <= P.assigned.amount))
					continue
				else
					return 0
		return 1

	/// Actually create and place the object.
	proc/build(var/amount = 1, var/obj/machinery/nanofab/owner)
		return

	/// Clear everything. used to reset the recipe
	proc/clear()
		for(var/datum/matfab_part/P in required_parts)
			P.clear()
		return

	/// Gets the assigned object that matches the given part name i.e. "Lens" or such. Whatever you named it in the recipe New.
	proc/getObjectByPartName(var/findName)
		for(var/datum/matfab_part/P in required_parts)
			if(P.part_name == findName)
				return P.assigned
		return null

	/// Figures out if we should place the result on the ground or inside the fab.
	proc/getOutputLocation(var/obj/machinery/nanofab/owner)
		var/atom/output = owner.loc
		if(owner.outputInternal)
			output = owner
		else
			output = owner.get_output_location()
		return output

/// Simple matfab recipie definition
/datum/matfab_recipe/simple
	/// Usage: list("!metal"=5, "crystal"=3, "rubber"=1) , putting a ! in front of a material name will make that material the main material that is applied at the end.
	var/list/materials = list()
	/// Typepath of the resulting item.
	var/result = null
	/// If 1, we change the stack amount instead of creating multiple objects.
	var/stack = 0
	/// Multiply output numbers by this.
	var/createMultiplier = 1

	var/datum/matfab_part/finishMaterial = null //Internal use.

	/**
		* Called after the object is created and the material is assigned to it. Do any additional processing in here.
		*
		* getObjectByPartName(var/findName) works in here. Check the new proc below to see what the expected names are. This might not work if you have multiple parts of the same type.
		*
		* A normal metal part would be getObjectByPartName("Metal"), a metal part set to main(!) would be getObjectByPartName("(Main) Metal")
		*/
	proc/postProcess(var/obj/item/I)
		return

	New()
		..()
		for(var/A in materials)
			var/numReq = materials[A]
			if(numReq && isnum(numReq) && numReq >= 1)
				var/isFinish = 0
				isFinish = copytext(A,1,2) == "!"
				if(isFinish) A = copytext(A,2,length(A)+1)
				var/datum/matfab_part/P = null
				switch(lowertext(A))
					if("metal")
						P = new/datum/matfab_part/metal()
						P.part_name = "[isFinish?"(Main) ":""]Metal"
						P.required_amount = numReq
					if("crystal")
						P = new/datum/matfab_part/crystal()
						P.part_name = "[isFinish?"(Main) ":""]Crystal"
						P.required_amount = numReq
					if("energy")
						P = new/datum/matfab_part/energy()
						P.part_name = "[isFinish?"(Main) ":""]Energy"
						P.required_amount = numReq
					if("rubber")
						P = new/datum/matfab_part/rubber()
						P.part_name = "[isFinish?"(Main) ":""]Rubber"
						P.required_amount = numReq
					if("cloth")
						P = new/datum/matfab_part/cloth()
						P.part_name = "[isFinish?"(Main) ":""]Cloth"
						P.required_amount = numReq
					if("organic")
						P = new/datum/matfab_part/organic()
						P.part_name = "[isFinish?"(Main) ":""]Organic"
						P.required_amount = numReq
					if("metalcrystal")
						P = new/datum/matfab_part/metalorcrystal()
						P.part_name = "[isFinish?"(Main) ":""]Metal/Crystal"
						P.required_amount = numReq
					if("metalorganic")
						P = new/datum/matfab_part/metalororganic()
						P.part_name = "[isFinish?"(Main) ":""]Metal/Organic"
						P.required_amount = numReq
					if("clothorganic")
						P = new/datum/matfab_part/clothororganic()
						P.part_name = "[isFinish?"(Main) ":""]Cloth/Organic"
						P.required_amount = numReq
					if("clothrubber")
						P = new/datum/matfab_part/clothorrubber()
						P.part_name = "[isFinish?"(Main) ":""]Cloth/Rubber"
						P.required_amount = numReq
					if("clothorganicrubber")
						P = new/datum/matfab_part/clothororganicorrubber()
						P.part_name = "[isFinish?"(Main) ":""]Cloth/Organic/Rubber"
						P.required_amount = numReq
					if("any")
						P = new/datum/matfab_part/anymat()
						P.part_name = "[isFinish?"(Main) ":""]Any Material"
						P.required_amount = numReq
					else
						logTheThing(LOG_DEBUG, null, "Invalid material parameter in [type] : [A]")
				if(P)
					if(isFinish)
						finishMaterial = P
					required_parts.Add(P)

	build(amount, var/obj/machinery/nanofab/owner)
		if(!ispath(result)) return //You beefed it.

		if(stack)
			var/obj/item/newObj = new result()
			if(finishMaterial?.assigned?.material)
				newObj.setMaterial(finishMaterial.assigned.material)
			postProcess(newObj)
			newObj.change_stack_amount(round(amount*createMultiplier,1) - newObj.amount)
			newObj.set_loc(getOutputLocation(owner))
		else
			for(var/i=0, i<round(amount*createMultiplier,1), i++)
				var/obj/item/newObj = new result()
				if(finishMaterial?.assigned?.material)
					newObj.setMaterial(finishMaterial.assigned.material)
				postProcess(newObj)
				newObj.set_loc(getOutputLocation(owner))
		return
