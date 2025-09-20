/datum/client_auth_provider/goonhub/dummy

/datum/client_auth_provider/goonhub/dummy/begin_auth()
	SPAWN(rand(1,5))
		var/returned_key = src.owner.key + "-AUTHTEST"
		var/returned_ckey = ckey(returned_key)
		src.on_auth(json_encode(list(
			"ckey" =  returned_ckey,
			"key" = returned_key,
			"player_id" = rand(1, 300),
			"is_admin" = TRUE,
			"admin_rank" = "Host",
			"is_mentor" = TRUE,
			"is_hos" = TRUE,
			"is_whitelisted" = TRUE,
			"can_bypass_cap" = TRUE
		)))
	return TRUE
