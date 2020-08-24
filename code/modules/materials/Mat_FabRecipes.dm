//See bottom of file for valid materials in /simple recipes.

/datum/matfab_recipe/simple/insbody
	name = "Instrument body"
	desc = "The body of an instrument."
	category = "Miscellaneous"
	materials = list("!any"=4)
	result = /obj/item/musicpart/body

/datum/matfab_recipe/simple/insneck
	name = "Instrument neck"
	desc = "The neck of an instrument."
	category = "Miscellaneous"
	materials = list("!any"=3)
	result = /obj/item/musicpart/neck

/datum/matfab_recipe/simple/insmouth
	name = "Instrument mouthpiece"
	desc = "The mouthpiece of an instrument."
	category = "Miscellaneous"
	materials = list("!any"=2)
	result = /obj/item/musicpart/mouth

/datum/matfab_recipe/simple/insbell
	name = "Instrument bell"
	desc = "The bell of an instrument. Not an actual bell."
	category = "Miscellaneous"
	materials = list("!metalcrystal"=4)
	result = /obj/item/musicpart/bell

/datum/matfab_recipe/simple/insbag
	name = "Instrument bag"
	desc = "The bag of an instrument."
	category = "Miscellaneous"
	materials = list("!clothorganic"=4)
	result = /obj/item/musicpart/bag

/datum/matfab_recipe/simple/insrod
	name = "Instrument rod"
	desc = "A plain old hollowed out rod."
	category = "Miscellaneous"
	materials = list("!metalcrystal"=3)
	result = /obj/item/musicpart/h_rod

/datum/matfab_recipe/blueprint/blastarmor
	name = "Blueprint: EOD Armor"
	desc = "Blueprints for EOD Armor"
	category = "Blueprints"

	New()
		required_parts.Add(new/datum/matfab_part/variable {part_name = "Hard material"; required_amount = 5; required_value = 70; greater_than = 1; required_property = "hard"; proper_name = "hardness"} ())
		required_parts.Add(new/datum/matfab_part/variable {part_name = "Dense material"; required_amount = 2; required_value = 60; greater_than = 1; required_property = "density"; proper_name = "density"} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/clothing/suit/space/suit = new()
			suit.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/spacesuit
	name = "Space Suit Set"
	desc = "A complete space suit."
	category = "Clothing"

	New()
		required_parts.Add(new/datum/matfab_part/clothororganicorrubber {part_name = "Fabric"; required_amount = 3} ())
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Reinforcement"; required_amount = 3} ())
		required_parts.Add(new/datum/matfab_part/crystal {part_name = "Visor"; required_amount = 2} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/clothing/suit/space/suit = new()
			var/obj/item/clothing/head/helmet/space/helmet = new()
			suit.set_loc(getOutputLocation(owner))
			helmet.set_loc(getOutputLocation(owner))
			var/obj/item/fab = getObjectByPartName("Fabric")
			var/obj/item/vis = getObjectByPartName("Visor")
			suit.setMaterial(fab.material)
			helmet.setMaterial(vis.material)
		return

/datum/matfab_recipe/mining_mod_conc
	name = "Tool mod (Concussive)"
	desc = "A mod for mining tools. Increases AOE."
	category = "Mining Tools"

	New()
		required_parts.Add(new/datum/matfab_part/radiocative_material {part_name = "Internal"; required_amount = 45} ())
		required_parts.Add(new/datum/matfab_part/charge {part_name = "Charge"; required_amount = 1} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/mining_mod/conc/newObj = new()
			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/mining_head_pick
	name = "Tool head (Pick)"
	desc = "A Pick head. Picks have high power but no AOE."
	category = "Mining Tools"

	New()
		required_parts.Add(new/datum/matfab_part/anymat {part_name = "Base"; required_amount = 5} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/mining_head/pick/newObj = new()
			var/obj/item/source = getObjectByPartName("Base")
			if(source && source.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return


/datum/matfab_recipe/mining_head_blaster
	name = "Tool head (Blaster)"
	desc = "A Blaster head. Blasters have lower power but very high AOE."
	category = "Mining Tools"

	New()
		required_parts.Add(new/datum/matfab_part/anymat {part_name = "Base"; required_amount = 5} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/mining_head/blaster/newObj = new()
			var/obj/item/source = getObjectByPartName("Base")
			if(source && source.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/mining_head_hammer
	name = "Tool head (Hammer)"
	desc = "A Hammer head. Hammers have a wide AOE and normal power."
	category = "Mining Tools"

	New()
		required_parts.Add(new/datum/matfab_part/anymat {part_name = "Base"; required_amount = 5} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/mining_head/hammer/newObj = new()
			var/obj/item/source = getObjectByPartName("Base")
			if(source && source.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/mining_head_drill
	name = "Tool head (Drill)"
	desc = "A Drill head. Hammers have a long AOE and normal power."
	category = "Mining Tools"

	New()
		required_parts.Add(new/datum/matfab_part/anymat {part_name = "Base"; required_amount = 5} ())

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/mining_head/drill/newObj = new()
			var/obj/item/source = getObjectByPartName("Base")
			if(source && source.material)
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

			if(newtype && body && body.material && head && head.material)
				newObj = new newtype(src)
				if(istype(opt, /obj/item/mining_mod/conc))
					newObj.blasting = 1

				newObj.setMaterial(mat1 = head.material, appearance = 1, setname = 1, copy = 1, use_descriptors = 0)

				if(newObj.blasting)
					newObj.remove_prefixes(99)
					newObj.name_prefix("Blasting")
					newObj.name_prefix(head.material.name ? head.material.name : "")
					newObj.UpdateName()
				else if(newObj.powered)
					newObj.remove_prefixes(99)
					newObj.name_prefix("Powered")
					newObj.name_prefix(head.material.name ? head.material.name : "")
					newObj.UpdateName()

				newObj.desc = "[initial(newObj.desc)] It has \a [head.name]."

			newObj.set_loc(getOutputLocation(owner))
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
			if(source && source.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/coillarge
	name = "Large coil"
	desc = "A large coil used in various objects."
	category = "Components"

	New()
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Coil"; required_amount = 2} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/coil/large/newObj = new()
			var/obj/item/source = getObjectByPartName("Coil")
			if(source && source.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/arrowhead
	name = "Arrowhead"
	desc = "An Arrowhead that can be used for arrows or in other objects."
	category = "Components"

	New()
		required_parts.Add(new/datum/matfab_part/metalorcrystal {part_name = "Arrowhead"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		var/obj/item/arrowhead/newObj = new()
		var/obj/item/source = getObjectByPartName("Arrowhead")
		if(source && source.material)
			newObj.setMaterial(source.material)
		newObj.change_stack_amount((amount) - newObj.amount)
		newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/spear
	name = "Spear"
	desc = "A simple spear with long reach. (This is very experimental and likely buggy)"
	category = "Weapons"

	New()
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Shaft"; required_amount = 3} ())
		required_parts.Add(new/datum/matfab_part/arrowhead {part_name = "Head"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/experimental/melee/spear/newObj = new()
			var/obj/item/shaft = getObjectByPartName("Shaft")
			var/obj/item/head = getObjectByPartName("Head")
			if(shaft && shaft.material && head && head.material)
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
		required_parts.Add(new/datum/matfab_part/arrowhead {part_name = "Arrowhead"; required_amount = 1} ())
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Shaft"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		var/obj/item/arrow/newObj = new()
		var/obj/item/arrowhead = getObjectByPartName("Arrowhead")
		var/obj/item/shaft = getObjectByPartName("Shaft")

		if(arrowhead && arrowhead.material && shaft && shaft.material)
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
			if(source && source.material)
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
			if(source && source.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/lens
	name = "Lens"
	desc = "A Lens used as a component in various objects."
	category = "Components"

	New()
		required_parts.Add(new/datum/matfab_part/crystal {part_name = "Lens"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/lens/newObj = new()
			var/obj/item/source = getObjectByPartName("Lens")
			if(source && source.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/gears
	name = "Gears"
	desc = "Some gears used as parts in various objects."
	category = "Components"

	New()
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Gears"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/gears/newObj = new()
			var/obj/item/source = getObjectByPartName("Gears")
			if(source && source.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/tripod
	name = "Tripod"
	desc = "A tripod."
	category = "Components"

	New()
		required_parts.Add(new/datum/matfab_part/metal {part_name = "Tripod"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/tripod/newObj = new()
			var/obj/item/source = getObjectByPartName("Tripod")
			if(source && source.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/aplates
	name = "Armor plates"
	desc = "Armor plates used in various objects."
	category = "Components"

	New()
		required_parts.Add(new/datum/matfab_part/metalorcrystal {part_name = "Armor"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/aplate/newObj = new()
			var/obj/item/source = getObjectByPartName("Armor")
			if(source && source.material)
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
			if(source && source.material)
				newObj.setMaterial(source.material)
				newObj.color_r = GetRedPart(source.material.color) / 255
				newObj.color_g = GetGreenPart(source.material.color) / 255
				newObj.color_b = GetBluePart(source.material.color) / 255

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
			if(source && source.material)
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
			if(source && source.material)
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
			if(source && source.material)
				newObj.setMaterial(source.material)

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
				var/R = GetRedPart(lensObj.material.color) / 255
				var/G = GetGreenPart(lensObj.material.color) / 255
				var/B = GetBluePart(lensObj.material.color) / 255
				newObj = new(null, R, G, B)
			else
				newObj = new
			if(casingObj && casingObj.material)
				newObj.setMaterial(casingObj.material)
				newObj.desc = newObj.desc + " It has a [lensObj.material.name] lens."

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
			if(casingObj && casingObj.material && lensObj && lensObj.material)
				newObj.setMaterial(lensObj.material)
				newObj.desc = newObj.desc + " Its made from [lensObj.material.name]."
				newObj.color_r = GetRedPart(lensObj.material.color) / 255
				newObj.color_g = GetGreenPart(lensObj.material.color) / 255
				newObj.color_b = GetBluePart(lensObj.material.color) / 255


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
			if(casingObj && casingObj.material && lensObj && lensObj.material)
				newObj.setMaterial(lensObj.material)
				newObj.desc = newObj.desc + " Its made from [lensObj.material.name]."
				newObj.color_r = GetRedPart(lensObj.material.color) / 255
				newObj.color_g = GetGreenPart(lensObj.material.color) / 255
				newObj.color_b = GetBluePart(lensObj.material.color) / 255


			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/tripodbulb
	name = "Tripod bulb"
	desc = "a replacement tripod light bulb. Lens color affects light color."
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
			if(casingObj && casingObj.material && lensObj && lensObj.material)
				newObj.setMaterial(lensObj.material)
				newObj.desc = newObj.desc + " Its made from [lensObj.material.name]."
				newObj.light.set_color(GetRedPart(lensObj.material.color) / 255, GetGreenPart(lensObj.material.color) / 255, GetBluePart(lensObj.material.color) / 255)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/sheet
	name = "Material Sheet"
	desc = "Sheets for construction purposes."
	category = "Tools"

	New()
		required_parts.Add(new/datum/matfab_part/metalorcrystal {part_name = "Sheet"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		var/obj/item/sheet/newObj = new()
		var/obj/item/source = getObjectByPartName("Sheet")
		if(source && source.material)
			newObj.setMaterial(source.material)
		newObj.change_stack_amount((amount * 10) - newObj.amount)
		newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/cell_small
	name = "Small energy cell"
	desc = "A small energy cell used in guns and small portable devices."
	category = "Tools"

	New()
		required_parts.Add(new/datum/matfab_part/energy {part_name = "Core"; required_amount = 2} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/ammo/power_cell/self_charging/custom/newObj = new()
			var/obj/item/source = getObjectByPartName("Core")
			if(source && source.material)
				newObj.setMaterial(source.material)

			newObj.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/cell_large
	name = "Large energy cell"
	desc = "A large enery cell, often used in APCs or cyborgs."
	category = "Tools"

	New()
		required_parts.Add(new/datum/matfab_part/energy {part_name = "Core"; required_amount = 4} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/cell/custom/newObj = new()
			var/obj/item/source = getObjectByPartName("Core")
			if(source && source.material)
				newObj.setMaterial(source.material)

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

			var/datum/materialProc/generic_reagent_onlife/O = new/datum/materialProc/generic_reagent_onlife(master_chem,1)
			refined.material.triggersOnLife.Cut()
			refined.material.addTrigger(refined.material.triggersOnLife, O)

			var/datum/materialProc/generic_reagent_onattack_depleting/A = new/datum/materialProc/generic_reagent_onattack_depleting(master_chem,1,10,25)
			refined.material.triggersOnAttack.Cut()
			refined.material.addTrigger(refined.material.triggersOnAttack, A)

			var/obj/item/material_piece/wad/W = unpool(/obj/item/material_piece/wad)

			if(refined && refined.material)
				refined.material.canMix = 0
				refined.material.name = "[master_chem_name]-infused [refined.material.name]"
				refined.material.mat_id = "[master_chem_name][refined.material.mat_id]"
				W.setMaterial(refined.material)
				W.change_stack_amount(9)

			W.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/fuel_rod
	name = "Nuclear Fuel Rod"
	desc = "Fuel suitable for use in a fission reactor"
	category = "Tools"

	New()
		required_parts.Add(new/datum/matfab_part/fissile {part_name = "Fissile Fuel 1"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		for(var/i=0, i<amount, i++)
			var/obj/item/fuel_1 = getObjectByPartName("Fissile Fuel 1")
			var/obj/item/nuke/rod/new_rod = new()

			new_rod.setMaterial(fuel_1.material)
			new_rod.sv_ratio = 1.22
			new_rod.set_loc(getOutputLocation(owner))
		return

/datum/matfab_recipe/fuel_rod_4
	name = "Advanced Nuclear Fuel Rod"
	desc = "Composite fuel suitable for use in a fission reactor"
	category = "Tools"

	New()
		required_parts.Add(new/datum/matfab_part/fissile {part_name = "Fissile Fuel"; required_amount = 3} ())
		required_parts.Add(new/datum/matfab_part/radiocative_material {part_name = "Flux Catalyst"; required_amount = 1} ())
		..()

	build(amount, var/obj/machinery/nanofab/owner)
		//TODO
		return

//////////////////////////////////////////////BASE CLASS BELOW

/datum/matfab_recipe
	var/name = ""			//Name of the recipe.
	var/desc = ""			//Short description of the item.
	var/list/required_parts = list() //List of /datum/matfab_part that are required for this.
	var/category = "Misc"	//Which group this recipe belongs to.

	proc/getMaxAmount()	//Gets the maximum amount of this recipe we can make with the currently assigned objects.
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

	proc/canBuild(var/amount = 1, var/atom/owner) //Can we currently build this?
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

	proc/build(var/amount = 1, var/obj/machinery/nanofab/owner) //Actually create and place the object.
		return

	proc/clear()	//Clear everything. used to reset the recipe
		for(var/datum/matfab_part/P in required_parts)
			P.clear()
		return

	proc/getObjectByPartName(var/findName) //Gets the assigned object that matches the given part name i.e. "Lens" or such. Whatever you named it in the recipe New.
		for(var/datum/matfab_part/P in required_parts)
			if(P.part_name == findName)
				return P.assigned
		return null

	proc/getOutputLocation(var/obj/machinery/nanofab/owner) //Figures out if we should place the result on the ground or inside the fab.
		var/atom/output = owner.loc
		if(owner.outputInternal)
			output = owner
		else
			output = owner.get_output_location()
		return output

/datum/matfab_recipe/simple
	var/list/materials = list() //Usage: list("!metal"=5, "crystal"=3, "rubber"=1) , putting a ! in front of a material name will make that material the main material that is applied at the end.
	var/result = null			//Typepath of the resulting item.
	var/stack = 0				//If 1, we change the stack amount instead of creating multiple objects.
	var/createMultiplier = 1	//Multiply output numbers by this.

	var/datum/matfab_part/finishMaterial = null //Internal use.

	proc/postProcess(var/obj/item/I) //Called after the object is created and the material is assigned to it. Do any additional processing in here.
		//getObjectByPartName(var/findName) works in here. Check the new proc below to see what the expected names are. This might not work if you have multiple parts of the same type.
		//A normal metal part would be getObjectByPartName("Metal"), a metal part set to main(!) would be getObjectByPartName("(Main) Metal")
		return

	New()
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
						logTheThing("debug", null, null, "Invalid material parameter in [type] : [A]")
				if(P)
					if(isFinish)
						finishMaterial = P
					required_parts.Add(P)

	build(amount, var/obj/machinery/nanofab/owner)
		if(!ispath(result)) return //You beefed it.

		if(stack)
			var/obj/item/newObj = new result()
			if(finishMaterial && finishMaterial.assigned && finishMaterial.assigned.material)
				newObj.setMaterial(finishMaterial.assigned.material)
			postProcess(newObj)
			newObj.change_stack_amount(round(amount*createMultiplier,1) - newObj.amount)
			newObj.set_loc(getOutputLocation(owner))
		else
			for(var/i=0, i<round(amount*createMultiplier,1), i++)
				var/obj/item/newObj = new result()
				if(finishMaterial && finishMaterial.assigned && finishMaterial.assigned.material)
					newObj.setMaterial(finishMaterial.assigned.material)
				postProcess(newObj)
				newObj.set_loc(getOutputLocation(owner))
		return


/////EXPERIMENTAL ARTIFACT ENGINE RELATED STUFF//
