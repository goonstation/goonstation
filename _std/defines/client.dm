//for view size stuff
#define WIDE_TILE_WIDTH 21
#define SQUARE_TILE_WIDTH 15
#define TILE_HEIGHT 15

// Client authentication

#define CLIENT_AUTH_PROVIDER_BYOND 1
#define CLIENT_AUTH_PROVIDER_GOONHUB 2

// Order of providers must match the order of the defines above
var/list/datum/client_auth_provider/client_auth_providers = list(
	/datum/client_auth_provider/byond,
	/datum/client_auth_provider/goonhub,
)

#define CLIENT_AUTH_SUCCESS "success"
#define CLIENT_AUTH_FAILED "failed"
#define CLIENT_AUTH_PENDING "pending"

#define CLIENT_AUTH_PROVIDER_CURRENT CLIENT_AUTH_PROVIDER_BYOND
