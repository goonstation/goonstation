
#define RADIO_JAMMER_RANGE 6

proc/check_for_radio_jammers(atom/source)
	. = FALSE
	for (var/atom/A as anything in by_cat[TR_CAT_RADIO_JAMMERS])
		if (IN_RANGE(source, A, RADIO_JAMMER_RANGE))
			return TRUE

#define MAKE_DEFAULT_RADIO_PACKET_COMPONENT(conn_id, freq) src._AddComponent(list( \
		/datum/component/packet_connected/radio, \
		conn_id, \
		freq, \
		("net_id" in src.vars) ? src.vars["net_id"] : null, \
		hascall(src, "receive_signal") ? "receive_signal" : null, \
		null, /*("id_tag" in src.vars) ? "[src.vars["id_tag"]]" : null, */\
		FALSE \
	))

proc/get_packet_connection_by_id(atom/movable/AM, id)
	RETURN_TYPE(/datum/component/packet_connected)
	for(var/datum/component/packet_connected/comp as anything in AM.GetComponents(/datum/component/packet_connected))
		if(comp.connection_id == id)
			return comp
	return null

proc/get_radio_connection_by_id(atom/movable/AM, id)
	RETURN_TYPE(/datum/component/packet_connected/radio)
	for(var/datum/component/packet_connected/radio/comp as anything in AM.GetComponents(/datum/component/packet_connected/radio))
		if(comp.connection_id == id)
			return comp
	return null

/// packet transmission types
#define TRANSMISSION_INVALID -1
#define TRANSMISSION_WIRE	0
#define TRANSMISSION_RADIO	1

//Signal frequencies

#define FREQ_PDA "1149"
#define FREQ_AIRLOCK "1411"
#define FREQ_FREE "1419" /// frequency for "free packet communication", default for nerd stuff
#define FREQ_NAVBEACON "1445"
#define FREQ_SECURE_STORAGE "1431"
#define FREQ_SECBUDDY_NAVBEACON "1431"
#define FREQ_ALARM "1437"

/*
Special frequency list:
On the map:
1149 for PDA messaging
1433 for hydroponics alerts
1435 for status displays
FREQ_ALARM for atmospherics/fire alerts
FREQ_NAVBEACON for bot nav beacons
1447 for mulebot control
1449 for airlock controls
1453 for engineering access
1457 for door access request
1475 for Mail chute location
1359 for security headsets
1357 for engineering headsets
1354 for research headsets
1356 for medical headsets
1352 for syndicate headsets
*/
