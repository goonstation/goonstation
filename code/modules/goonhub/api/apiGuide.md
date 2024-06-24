## About the DM side API
This is written from the understanding of Tyrant, who is not an API developer. Some things may be slightly wrong.

Useful links:
Goonhub API docs: https://goonhub.com/docs/api#/
Event tracking docs: https://goonhub.com/docs/events/1.0/overview

### Endpoints and apiRoutes
Endpoints are the ways that the API communicates, and they contain routes. The routes contain several vars:

A route can have one of four method types:
- `GET` Which checks information.
- `POST` Which adds new information.
- `PUT` Which updates/overwrites existing information.
- `DELETE` Which removes information.
These are specified in the `method` var using defines.

Each route has a path which it connects to as well, for instance https://goonhub.com/api
**/bans**. This is specified in the form of a string in the `path` var.

Path parameters are stored in the `routeParams` var. These are used when the path ends with a variable, for instance, `https://goonhub.com/api/bans/{ban}`, which has the path parameter `{ban}`.

Query parameters send extra information when connecting, stored in `queryParams`. This is usually a list of strings, for instance, `queryParams = list("filters", "sort_by", "descending", "per_page")`.

The request body (`body` var) is what is sent through the connection. These are usually in the form of a `/datum/apiBody`, which are in the requests folder in the repo. More information is in the following sections.

The response model (`correct_response` var) is what is sent back. These are in the form of a `/datum/apiModel`, which are in the models folder in the repo. More information is in the following sections.

A Template for API endpoint routes:
```dm
/// [method type e.g. POST] [path e.g. /players/notes]
/// [reference to the name of the file or what it does, e.g. Add]
//datum/apiRoute/[path of route]
	method = RUSTG_HTTP_METHOD_[method type]
	path = "[the path of the endpoint it connects to]"
	routeParams = list([list of parameter items, separated by commas]) // [the primitive type of each parameter]
	queryParams = list([list of parameter items, separated by commas]) // [the primitive type of each parameter]
	body = [the datum of the body, under /datum/apiBody]
	correct_response = [the datum of the model, under datum/apiModel]

	buildBody(	// check the apiBody section below to understand what this means
		field1,
		field2,
		field3
	)
		. = ..(args)

// A proper example:

/// PUT /bans/{ban}
/// Update
/datum/apiRoute/bans/update
	method = RUSTG_HTTP_METHOD_PUT
	path = "/bans"
	routeParams = list("ban")	// integer
	body = /datum/apiBody/bans/add
	correct_response = /datum/apiModel/Tracked/BanResource

	buildBody(
		game_admin_ckey,
		round_id,
		server_id,
		ckey,
		comp_id,
		ip,
		reason,
		duration
	)
		. = ..(args)
```

The reason why the API files are formatted this way is so that "it's optimized so you can just copypaste stuff and change it via column/vertical select" ~ZeWaka.

Other notes:
- the path should start with slash.
- not all methods require all the vars. In fact, some are mutually exclusive.
- If the apiBody or apiModel doesn't exist, make it. Don't try to just shove a list of strings in; it won't work.

#### Making your own apiRoute's
The list of what to make and how it works is at https://goonhub.com/docs/api, along with the request body and response model needed. They need to match the `apiRoute` in order for the API to work correctly.
- Under request, the parameters should match in the form of a list of strings matching the parameter names. If it says query parameters, use `queryParams`, if it says path parameters, use `routeParams`.
- If the path ends with something like `/{kind of routeParam}`, you don't include it in `src.path`. It gets appended automatically later on by the routeParams.
- The request body should match an `apiBody`.
- The response body should match an `apiModel`.
- If the above two don't have matching ones, you have to make them.
- If you're making new files, follow the format of existing names.

### Request bodies and apiBody
A `/datum/apiBody` is a type of request which gets sent through a route and provides information. These are typically used on `POST` and `PUT` method using routes.
The Goonhub api, while it lists what's needed in the body of the request for each route, doesn't actually give fixed names for each body. You can check what's required in the body under "request" -> "Body".

This body will need to then be "built" by calling `buildBody()` on the routes that use them, as shown in the example in the above `/datum/apiRoute` section. This way, autocomplete works better. It's a bit silly but will help overall.

The default format for making them is as follows:
```dm
/datum/apiBody/[path]
	fields = list(
		"field1", // [type]
		"field2", // [type]
		"field3" // [type]
	)

/datum/apiBody/[path]/VerifyIntegrity(
	. = ..()
	if (
		isnull(src.values["field1"]) \
		|| isnull(src.values["field2"]) \
	)	// note that this means field1 and field2 can't be null, but field3 can.
)

// a real example:
/datum/apiBody/bans/add
	fields = list(
		"game_admin_ckey", // string
		"round_id", // integer
		"server_id", // string
		"ckey", // string
		"comp_id", // string
		"ip", // string
		"reason", // string
		"duration" // integer
	)

/datum/apiBody/bans/add/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.values["game_admin_ckey"]) \
		|| isnull(src.values["round_id"]) \
		|| isnull(src.values["server_id"]) \
		|| isnull(src.values["reason"]) \
	)
		return FALSE
```

### Response models and apiModel
A `/datum/apiModel` is a response that is sent back after the task is complete. They are sometimes called resources. The Goonhub API guide lists what kind is required and what they contain. You can check what is required under "Responses" -> "Body". They're typically used in `GET` method routes.

Note that there are certain parents, which have built in fields. For instance, the abstract type `/datum/apiModel/Tracked` has three fields: `id`, `created_at` and `updated_at`. Anything that needs these three should usually be a subtype and won't have to redefine them.

Similarly, `/datum/apiModel/Tracked/PlayerRes` includes the tracked vars and one more: `player_id`. Meanwhile `/datum/apiModel/Paginated` is usually used in `RUSTG_HTTP_METHOD_GET` methods and includes three vars: `data` (which is another apiModel, nested inside), `links` and `meta`.

The usual format is below:
```dm
/// [Name]
/datum/apiModel/[path]
	var/field1	= null // [type]
	var/field2	= null // [type]
	var/field3	= null // [type]

/datum/apiModel/[path]/SetupFromResponse(response)
	. = ..()
	src.field1 = response["field1"]
	src.field2 = response["field2"]
	src.field3 = response["field3"]

/datum/apiModel/[path]/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.[field1]) \	// assuming that field1 and 2 cannot be null and field3 can
		|| isnull(src.[field2])
	)
		return FALSE

/datum/apiModel/[path]/ToString()
	. = list()
	.["field1"] = src.field1
	.["field2"] = src.field2
	.["field3"] = src.field3
	return json_encode(.)

//A real example:
/// Error
/datum/apiModel/Error
	var/message	= null // string
	var/errors	= null // null or list

/datum/apiModel/Error/SetupFromResponse(response)
	. = ..()
	src.message = response["message"]
	src.errors = response["errors"]

/datum/apiModel/Error/VerifyIntegrity()
	. = ..()
	if (
		isnull(src.message) \
	)
		return FALSE

/datum/apiModel/Error/ToString()
	. = list()
	.["message"] = src.message
	.["errors"] = src.errors
	return json_encode(.)
```
