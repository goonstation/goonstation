var/datum/spatial_hashmap/clients/client_hashmap = new(name = "Clients")
var/datum/spatial_hashmap/ranch_animals/ranch_animal_hashmap = new(name = "Ranch Animals")

/// Iterates over all clients within a specified range of a centre turf.
#define for_clients_in_range(_iterator, _centre, _range) for (var/client/##_iterator as anything in global.client_hashmap.exact_supremum(##_centre, ##_range))
