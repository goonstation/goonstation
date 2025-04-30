/atom/movable/screen/parallax_render_source/foreground
	plane = PLANE_FOREGROUND_PARALLAX

// Space Layers
/atom/movable/screen/parallax_render_source/space_1
	parallax_icon_state = "space_1"
	parallax_value = 0

/atom/movable/screen/parallax_render_source/space_1/south
	parallax_value = 0.005
	scroll_speed = 240
	scroll_angle = 180

/atom/movable/screen/parallax_render_source/space_1/west
	parallax_value = 0.005
	scroll_speed = 240
	scroll_angle = 270


/atom/movable/screen/parallax_render_source/space_2
	parallax_icon_state = "space_2"
	parallax_value = 0.009
	blend_mode = BLEND_ADD

/atom/movable/screen/parallax_render_source/space_2/south
	scroll_speed = 240
	scroll_angle = 180

/atom/movable/screen/parallax_render_source/space_2/west
	scroll_speed = 240
	scroll_angle = 270


// Ocean Caustics
/atom/movable/screen/parallax_render_source/foreground/caustics
	parallax_icon = 'icons/misc/parallax_caustics.dmi'
	parallax_icon_state = "caustics"
	static_colour = TRUE
	blend_mode = BLEND_ADD
	alpha = 75
	parallax_value = 1


// Typhon
/atom/movable/screen/parallax_render_source/typhon
	parallax_icon = 'icons/misc/1024x1024.dmi'
	parallax_icon_state = "plasma_giant"
	static_colour = TRUE
	parallax_value = 0.015
	tessellate = FALSE
	visible_to_gps = TRUE
	name = "Typhon"
	desc = "Y-CLASS BROWN DWARF<br>\
		Somewhere between a star and a planet, also known as a \"Plasma Giant\" due to the ferocious FAAE storms that ravage its surface."

/atom/movable/screen/parallax_render_source/typhon/cogmap
	initial_x_coordinate = 0
	initial_y_coordinate = 167

/atom/movable/screen/parallax_render_source/typhon/cogmap2
	initial_x_coordinate = 300
	initial_y_coordinate = 140

/atom/movable/screen/parallax_render_source/typhon/kondaru
	initial_x_coordinate = 150
	initial_y_coordinate = 500

/atom/movable/screen/parallax_render_source/typhon/donut2
	initial_x_coordinate = 300
	initial_y_coordinate = 350

/atom/movable/screen/parallax_render_source/typhon/donut3
	initial_x_coordinate = -50
	initial_y_coordinate = 350


// Planets
/atom/movable/screen/parallax_render_source/planet
	parallax_icon = 'icons/misc/512x512.dmi'
	static_colour = TRUE
	parallax_value = 0.03
	tessellate = FALSE

/atom/movable/screen/parallax_render_source/planet/gimmick1
/atom/movable/screen/parallax_render_source/planet/gimmick2
/atom/movable/screen/parallax_render_source/planet/gimmick3
/atom/movable/screen/parallax_render_source/planet/gimmick4
/atom/movable/screen/parallax_render_source/planet/gimmick5


/// inner system - Diner debris belt

/atom/movable/screen/parallax_render_source/planet/quadriga // the channel node is near here, an Io-like volcanic, a nasty place
	parallax_icon_state = "quadriga"
	initial_x_coordinate = 35
	initial_y_coordinate = 0
	parallax_value = 0.03
	visible_to_gps = TRUE
	name = "Quadriga"
	desc = "ABLATED PLANET CORE<br>\
		Surface Outposts: PIEDRA DE ORO, NT-Δ<br>\
		The crust has been shattered off of a silicate planet, leaving a partially exposed inner core and a thin volcanic mantle. The Frontier's access point to the Channel is found above this wrecked world. Crustal ejecta fills the surrounding region."

/atom/movable/screen/parallax_render_source/planet/channel
	parallax_icon_state = "channel"
	initial_x_coordinate = 35
	initial_y_coordinate = 1
	parallax_value = 0.031
	visible_to_gps = TRUE
	name = "The Channel"
	desc = "Quadriga Flux Channel<br>\
		A corroded region of spacetime where electromagnetic fields from Typhon interact with Quadriga's ion plumes and aurora. PTL convergence pulses help stabilize this transient phenomenon."


/atom/movable/screen/parallax_render_source/planet/amantes // the space butt, haven of gangs, clown town, shanty colonies
	parallax_icon_state = "amantes"
	initial_x_coordinate = 300
	initial_y_coordinate = 300
	parallax_value = 0.04
	visible_to_gps = TRUE
	name = "Amantes"
	desc = "CONTACT BINARY<br>\
		Surface Outposts: BUTTES JUNCTION, NT-Κ, CLOWN TOWN<br>\
		A pair of inhabited rubble-pile asteroids merged together in a slow collision, likely coalesced from the rubble of Quadriga.<br>\
		Travel advisories are in effect due to high crime within the countless warrens and unlisted settlements of this infamous Frontier landmark. "

// donut 2 neighborhood

/atom/movable/screen/parallax_render_source/planet/fatuus // the scary bog planet, home of Biodome and New Memphis
	parallax_icon_state = "fatuus"
	initial_x_coordinate = 0
	initial_y_coordinate = 50
	parallax_value = 0.034
	visible_to_gps = TRUE
	name = "Fatuus"
	desc = "STEAM PLANET<br>\
		L5 Stations: NT-Ι<br>\
		Surface Outposts: NEW MEMPHIS, NT-Γ, NT-Σ, NT-Χ<br>\
		A carboniferous world with shallow boiling seas and fog-shrouded bogs. The colony of New Memphis and the lights of the Bonktek Shopping Pyramid can be seen from orbit."

/*
/atom/movable/screen/parallax_render_source/planet/domusdei // need to resprite this
	parallax_icon_state = "domusDei"
	initial_x_coordinate = 450
	initial_y_coordinate = 450
	parallax_value = 0.025
*/

// the Mundus Gap, a safer economic and administrative hub

/atom/movable/screen/parallax_render_source/planet/mundus  //  tundra and glacier planet, home of Space Canada
	parallax_icon_state = "mundus"
	initial_x_coordinate = 500
	initial_y_coordinate = 100
	parallax_value = 0.025
	visible_to_gps = TRUE
	name = "Mundus"
	desc = "MINI-TERRAN PLANET<br>\
		L1 Stations: NT-Ν<br>\
		A chilly earthlike dwarf planet. Home to Space Quebec, the oldest surviving ground settlement in the frontier."

/atom/movable/screen/parallax_render_source/planet/iustitia // a moon with a major spaceport, diplomatic and cultural hub
	parallax_icon_state = "iustitia"
	initial_x_coordinate = 100
	initial_y_coordinate = 100
	parallax_value = 0.035
	visible_to_gps = TRUE
	name = "Iustitia"
	desc = "SILICATE MOON<br>\
		SECURE AREA<br>\
		Surface Outposts: PORT ROERICH, IUSTITIA COSMOTHEQUE, NT-Α<br>\
		The diplomatic, cultural, and financial center of the Frontier is found here at Port Roerich and its adjacent citydomes."

/atom/movable/screen/parallax_render_source/planet/iudicium // a desolate moon with old military sites, bunkers, Ainley hospital
	parallax_icon_state = "iudicium"
	initial_x_coordinate = -150
	initial_y_coordinate = 100
	parallax_value = 0.040
	visible_to_gps = TRUE
	desc = "SILICATE MOON<br>\
		SECURE AREA<br>\
		Surface Outposts: NT-Λ, NT-Ξ<br>\
		A desolate moon dotted with old retired military sites and a few corporate holdings.<br>\
		NT Security's Instructional Outpost Xi, aka 'Fight School' is one of the few remaining sites in operation here."

/// fortuna area

/atom/movable/screen/parallax_render_source/planet/fortuna // a strategic layover point between the inner and outer rings
	parallax_icon_state = "fortuna"
	initial_x_coordinate = 0
	initial_y_coordinate = 100
	parallax_value = 0.04
	visible_to_gps = TRUE
	name = "Rota Fortuna"
	desc = "VESTOID DWARF<br>\
		HIGH TRAFFIC AREA<br>\
		L2 Stations: NT-13, NT-14<br>\
		L3 Stations: NT-15<br>\
		The namesake of Waypoint Fortuna, a fiercely contested landmark during the Pod Wars. This major asteroid remains an important stopover and refueling point between the inner and outer rings."

// outer rings

/atom/movable/screen/parallax_render_source/planet/mors // worse than Mars. bad
	parallax_icon_state = "mors"
	initial_x_coordinate = -50
	initial_y_coordinate = 100
	parallax_value = 0.030
	visible_to_gps = TRUE
	name = "Mors"
	desc = "CORELESS PLANET<br>\
		L? Stations: NT-Ρ<br>\
		A rusty, porous Mars-like, once covered in deep oceans, now a deadly world of toxic brine pools, claretine salt-flats and fractured mudstone terrain. Heavily bombarded and irradiated when the Martian War continued into a Mortian War."

/atom/movable/screen/parallax_render_source/planet/regis // possibly blob infested
	parallax_icon_state = "regis"
	initial_x_coordinate = 250
	initial_y_coordinate = -50
	parallax_value = 0.04
	visible_to_gps = TRUE
	name = "Regis"
	desc = "SILICATE MOONLET<br>\
		L2 Stations: NT-Ρ<br>\
		Mostly quiet now, this highly restricted moon was used as a staging ground for Joint Fleet operations in the early Frontier.<br>\
		Though the missile silos are long silent, the old howitzer platforms here still occasionally conduct routine suppressive fire-missions towards Mors. Just in case."

///////

/atom/movable/screen/parallax_render_source/planet/magus // acidic frigid horrible death-ocean planet, Nadir's home
	parallax_icon_state = "magus"
	initial_x_coordinate = 50
	initial_y_coordinate = 100
	parallax_value = 0.03
	visible_to_gps = TRUE
	name = "Magus"
	desc = "SULFUR PLANET<br>\
		Surface Outposts: NADIR EXTRACTION SITE<br>\
		A viciously corrosive planet which provides many industrially valuable resources and reagents. The super-acid seas are rich in both dissolved and crystallized exotic compounds. NADIR Station lays on the seafloor below."

/atom/movable/screen/parallax_render_source/planet/regina // a captive comet, hosts a flea market, ice-water mining
	parallax_icon = 'icons/obj/large/320x320.dmi'
	parallax_icon_state = "regina"
	initial_x_coordinate = 120
	initial_y_coordinate = 120
	parallax_value = 0.04
	visible_to_gps = TRUE
	name = "Regina"
	desc = "CAPTIVE COMET<br>\
		Surface Outposts: NT-Μ<br>\
		This comet core is caught in the gravity well of MAGUS.<br>\
		The old Regina Anchorage here is still a popular flea market and space bazaar today. Agricultural Outpost Mu's hydroponic produce fills many Frontier kitchens. Mining Outpost Iota magnet-harvests material from the comet's tail."

// Asteroid Layers
/atom/movable/screen/parallax_render_source/asteroids_far
	parallax_icon_state = "asteroids_far"
	static_colour = TRUE
	parallax_value = 0.06

/atom/movable/screen/parallax_render_source/asteroids_far/kondaru
	scroll_speed = 100
	scroll_angle = 98


/atom/movable/screen/parallax_render_source/asteroids_near
	parallax_icon_state = "asteroids_near"
	static_colour = TRUE
	parallax_value = 0.1

/atom/movable/screen/parallax_render_source/asteroids_near/sparse
	parallax_icon_state = "asteroids_sparse"
	parallax_value = 0.15

/atom/movable/screen/parallax_render_source/asteroids_near/sparse/south
	scroll_speed = 240
	scroll_angle = 180


// Miscellaneous Layers
/atom/movable/screen/parallax_render_source/blowout_clouds
	parallax_icon_state = "blowout_clouds"
	static_colour = TRUE
	parallax_value = 0.5
	blend_mode = BLEND_ADD
	scroll_speed = 500
	scroll_angle = 240

/atom/movable/screen/parallax_render_source/meteor_shower
	parallax_icon_state = "meteors"
	static_colour = TRUE
	parallax_value = 0.5
	scroll_speed = 500
	scroll_angle = 0

// scrolling doesnt work if scroll_angle is changed after initialisation i think. So I made these.
/atom/movable/screen/parallax_render_source/meteor_shower/north
	scroll_angle = 180

/atom/movable/screen/parallax_render_source/meteor_shower/south
	scroll_angle = 0

/atom/movable/screen/parallax_render_source/meteor_shower/east
	scroll_angle = 270

/atom/movable/screen/parallax_render_source/meteor_shower/west
	scroll_angle = 90

// Effects

// Clouds
/atom/movable/screen/parallax_render_source/foreground/clouds
	parallax_icon_state = "clouds_3"
	color = list(
		0, 0, 0, -0.4,
		0, 0, 0, -0.4,
		0, 0, 0, -0.4,
		0, 0, 0, 1,
		0, 0, 0, 0)
	static_colour = TRUE
	parallax_value = 0.9
	scroll_speed = 5
	scroll_angle = 150

/atom/movable/screen/parallax_render_source/foreground/clouds/dense
	color = list(
		0, 0, 0, -0.4,
		0, 0, 0, -0.4,
		0, 0, 0, -0.4,
		0, 0, 0, 1,
		0, 0, 0, -0.5)
	parallax_icon_state = "clouds_1"
	parallax_value = 0.8
	scroll_speed = 1

/atom/movable/screen/parallax_render_source/foreground/clouds/sparse
	color = list(
		0, 0, 0, -0.4,
		0, 0, 0, -0.4,
		0, 0, 0, -0.4,
		0, 0, 0, 0,
		0, 0, 0, -0.4)
	parallax_icon_state = "clouds_2"
	parallax_value = 0.7
	scroll_speed = 10


// Adventure Zones

// Snow Storm Layers
/atom/movable/screen/parallax_render_source/foreground/snow
	parallax_icon_state = "snow_dense"
	color = list(
		1, 0, 0, 0.4,
		0, 1, 0, 0.4,
		0, 0, 1, 0.4,
		0, 0, 0, 1,
		0, 0, 0, -1)
	static_colour = TRUE
	parallax_value = 0.8
	scroll_speed = 100
	scroll_angle = 240

/atom/movable/screen/parallax_render_source/foreground/snow/sparse
	parallax_icon_state = "snow_sparse"
	color = null
	blend_mode = BLEND_ADD
	parallax_value = 0.9
	scroll_speed = 150

/atom/movable/screen/parallax_render_source/foreground/fog
	parallax_icon_state = "snow_dense"
	color = list(
		1, 0, 0, 0.4,
		0, 1, 0, 0.4,
		0, 0, 1, 0.4,
		0, 0, 0, 1,
		0, 0, 0, -1)
	static_colour = TRUE
	parallax_value = 0.8
	scroll_speed = 5
	scroll_angle = 180


// Dust Storm Layers
/atom/movable/screen/parallax_render_source/foreground/dust
	parallax_icon_state = "dust_dense"
	color = list(
		1, 0, 0, 0.8,
		0, 1, 0, 0.8,
		0, 0, 1, 0.8,
		0, 0, 0, 1,
		0, 0, 0, -1)
	static_colour = TRUE
	parallax_value = 0.8
	scroll_speed = 150
	scroll_angle = 240

/atom/movable/screen/parallax_render_source/foreground/dust/sparse
	parallax_icon_state = "dust_sparse"
	color = null
	blend_mode = BLEND_ADD
	parallax_value = 0.9
	scroll_speed = 225


// Embers Layers
/atom/movable/screen/parallax_render_source/foreground/embers
	parallax_icon_state = "embers_dense"
	color = list(
		1, 0, 0, -0.8,
		0, 1, 0, -0.8,
		0, 0, 1, -0.8,
		0, 0, 0, 1,
		0, 0, 0, -0.7)
	static_colour = TRUE
	parallax_value = 0.8
	scroll_speed = 25
	scroll_angle = 135

/atom/movable/screen/parallax_render_source/foreground/embers/sparse
	parallax_icon_state = "embers_sparse"
	color = null
	parallax_value = 0.9
	scroll_speed = 35


// Void Layers
/atom/movable/screen/parallax_render_source/void
	parallax_icon_state = "void"
	parallax_value = 0.1
	scroll_speed = 20
	scroll_angle = 150

/atom/movable/screen/parallax_render_source/void/clouds_1
	parallax_icon_state = "void_clouds_1"
	parallax_value = 0.4
	blend_mode = BLEND_ADD

/atom/movable/screen/parallax_render_source/void/clouds_2
	parallax_icon_state = "void_clouds_2"
	parallax_value = 0.7
	blend_mode = BLEND_ADD
