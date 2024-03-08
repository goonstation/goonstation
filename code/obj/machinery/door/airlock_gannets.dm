// ------------ gannets airlocks ------------

/obj/machinery/door/airlock/gannets
	name = "airlock"
	icon = 'icons/obj/doors/destiny.dmi'
	icon_state = "gen_closed"
	icon_base = "gen"

	alt
		icon_state = "fgen_closed"
		icon_base = "fgen"
		welded_icon_state = "fgen_welded"

	command
		name = "command airlock"
		icon_state = "com_closed"
		icon_base = "com"
		req_access = list(access_heads)

	command/alt
		icon_state = "fcom_closed"
		icon_base = "fcom"
		welded_icon_state = "fcom_welded"

	security
		name = "security airlock"
		icon_state = "sec_closed"
		icon_base = "sec"
		req_access = list(access_security)

	security/alt
		icon_state = "fsec_closed"
		icon_base = "fsec"
		welded_icon_state = "fsec_welded"

	engineering
		name = "engineering airlock"
		icon_state = "eng_closed"
		icon_base = "eng"
		req_access = list(access_engineering)

	engineering/alt
		icon_state = "feng_closed"
		icon_base = "feng"
		welded_icon_state = "feng_welded"

	medical
		name = "medical airlock"
		icon_state = "med_closed"
		icon_base = "med"
		req_access = list(access_medical)

	medical/alt
		icon_state = "fmed_closed"
		icon_base = "fmed"
		welded_icon_state = "fmed_welded"

	morgue
		name = "morgue airlock"
		icon_state = "morg_closed"
		icon_base = "morg"
		req_access = list(access_morgue)

	morgue/alt
		icon_state = "fmorg_closed"
		icon_base = "fmorg"
		welded_icon_state = "fmorg_welded"

	chemistry
		name = "chemistry airlock"
		icon_state = "chem_closed"
		icon_base = "chem"
		req_access = list(access_research)

	chemistry/alt
		icon_state = "fchem_closed"
		icon_base = "fchem"
		welded_icon_state = "fchem_welded"

	toxins
		name = "toxins airlock"
		icon_state = "tox_closed"
		icon_base = "tox"
		req_access = list(access_research)

	toxins/alt
		icon_state = "ftox_closed"
		icon_base = "ftox"
		welded_icon_state = "ftox_welded"

	maintenance
		name = "maintenance airlock"
		icon_state = "maint_closed"
		icon_base = "maint"
		welded_icon_state = "maint_welded"
		req_access = list(access_maint_tunnels)

/obj/machinery/door/airlock/gannets/glass
	name = "glass airlock"
	icon = 'icons/obj/doors/destiny.dmi'
	icon_state = "tgen_closed"
	icon_base = "tgen"
	opacity = 0
	visible = 0

	alt
		icon_state = "tfgen_closed"
		icon_base = "tfgen"
		welded_icon_state = "fgen_welded"

	command
		name = "glass command airlock"
		icon_state = "tcom_closed"
		icon_base = "tcom"
		req_access = list(access_heads)

	command/alt
		icon_state = "tfcom_closed"
		icon_base = "tfcom"
		welded_icon_state = "fcom_welded"

	security
		name = "glass security airlock"
		icon_state = "tsec_closed"
		icon_base = "tsec"
		req_access = list(access_security)

	security/alt
		icon_state = "tfsec_closed"
		icon_base = "tfsec"
		welded_icon_state = "fsec_welded"

	engineering
		name = "glass engineering airlock"
		icon_state = "teng_closed"
		icon_base = "teng"
		req_access = list(access_engineering)

	engineering/alt
		icon_state = "tfeng_closed"
		icon_base = "tfeng"
		welded_icon_state = "feng_welded"

	medical
		name = "glass medical airlock"
		icon_state = "tmed_closed"
		icon_base = "tmed"
		req_access = list(access_medical)

	medical/alt
		icon_state = "tfmed_closed"
		icon_base = "tfmed"
		welded_icon_state = "fmed_welded"

	morgue
		name = "glass morgue airlock"
		icon_state = "tmorg_closed"
		icon_base = "tmorg"
		req_access = list(access_morgue)

	morgue/alt
		icon_state = "tfmorg_closed"
		icon_base = "tfmorg"
		welded_icon_state = "fmorg_welded"

	chemistry
		name = "glass chemistry airlock"
		icon_state = "tchem_closed"
		icon_base = "tchem"
		req_access = list(access_research)

	chemistry/alt
		icon_state = "tfchem_closed"
		icon_base = "tfchem"
		welded_icon_state = "fchem_welded"

	toxins
		name = "glass toxins airlock"
		icon_state = "ttox_closed"
		icon_base = "ttox"
		req_access = list(access_research)

	toxins/alt
		icon_state = "tftox_closed"
		icon_base = "tftox"
		welded_icon_state = "ftox_welded"

	maintenance
		name = "glass maintenance airlock"
		icon_state = "tmaint_closed"
		icon_base = "tmaint"
		welded_icon_state = "tmaint_welded"
		req_access = list(access_maint_tunnels)
