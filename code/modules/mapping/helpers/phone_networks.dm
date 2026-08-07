// These aren't really used yet, so feel free to start using them and making new ones
ABSTRACT_TYPE(/obj/mapping_helper/phone_networks)
/obj/mapping_helper/phone_networks
	name = "phone network"
	desc = "Place this over a phone to add a network to it"
	var/network = null

/obj/mapping_helper/phone_networks/setup()
	for (var/obj/D in src.loc)
		var/phone_networks = PHONE.get_var(D, PHONE_NETWORKS)
		if(isnull(phone_networks))
			continue
		phone_networks |= src.network
		PHONE.set_var(D, PHONE_NETWORKS, phone_networks)

// this one is... probably redundant
/obj/mapping_helper/phone_networks/station
	name = "phone network - station"
	network = PHONE_NET_STATION

// currently unused
/obj/mapping_helper/phone_networks/security
	name = "phone network - security"
	network = PHONE_NET_SECURITY

/obj/mapping_helper/phone_networks/station_remover
	name = "Station network remover"
	desc = "Removes the station network from any phone objects' network"
/obj/mapping_helper/phone_networks/station_remover/setup()
	for (var/obj/D in src.loc)
		var/phone_networks = PHONE.get_var(D, PHONE_NETWORKS)
		if(isnull(phone_networks))
			continue
		phone_networks &= ~PHONE_NET_STATION
		PHONE.set_var(D, PHONE_NETWORKS, phone_networks)
