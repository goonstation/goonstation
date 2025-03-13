// By @skull132/<@84559773487353856> on GitHub/Discord from paradise/aurora (tgstation/tgstation/pull/49374). Licensed to us under MIT(https://opensource.org/licenses/MIT).

/**
  * # HTTP Request
  *
  * Holder datum for ingame HTTP requests
  *
  * Holds information regarding to methods used, URL, and response,
  * as well as job IDs and progress tracking for async requests
  */
/datum/http_request
	/// The ID of the request (Only set if it is an async request)
	var/id
	/// Is the request in progress? (Only set if it is an async request)
	var/in_progress = FALSE
	/// HTTP method used
	var/method
	/// Body of the request being sent
	var/body
	/// Request headers being sent
	var/headers
	/// URL that the request is being sent to
	var/url
	/// If present response body will be saved to this file.
	var/output_file
	/// The raw response, which will be decoeded into a [/datum/http_response]
	var/_raw_response

/**
  * Preparation handler
  *
  * Call this with relevant parameters to form the request you want to make
  *
  * Arguments:
  * * _method - HTTP Method to use, see code/rust_g.dm for a full list
  * * _url - The URL to send the request to
  * * _body - The body of the request, if applicable
  * * _headers - Associative list of HTTP headers to send, if applicable
  * * _output_file - If present response body will be saved to this file.
  */
/datum/http_request/proc/prepare(_method, _url, _body = "", list/_headers, _output_file)
	if(!length(_headers))
		_headers = ""
	else
		_headers = json_encode(_headers)

	method = _method
	url = _url
	body = _body
	headers = _headers
	output_file = _output_file

/**
  * Blocking executor
  *
  * Remains as a proof of concept to show it works, but should NEVER be used to do FFI halting the entire DD process up
  * Async rqeuests are much preferred.
  */
/datum/http_request/proc/execute_blocking()
	CRASH("Attempted to execute a blocking HTTP request")
	// _raw_response = rustg_http_request_blocking(method, url, body, headers, build_options()))

/**
  * Async execution starter
  *
  * Tells the request to start executing inside its own thread inside RUSTG
  * Preferred over blocking.
  */
/datum/http_request/proc/begin_async()
	if(in_progress)
		CRASH("Attempted to re-use a request object.")

	id = rustg_http_request_async(method, url, body, headers, build_options())

	if(isnull(text2num(id)))
		_raw_response = "Proc error: [id]"
		CRASH("Proc error: [id]")
	else
		in_progress = TRUE

/**
  * Options builder
  *
  * Builds a set of request options
  * Apparently this is only currently used for output_file purposes
  */
/datum/http_request/proc/build_options()
	if(output_file)
		return json_encode(list("output_filename"=output_file,"body_filename"=null))
	return "{}"

/**
  * Async completion checker
  *
  * Checks if an async request has been complete
  * Has safety checks built in to compensate if you call this on blocking requests,
  * or async requests which have already finished
  */
/datum/http_request/proc/is_complete()
	// If we dont have an ID, were blocking, so assume complete
	if(isnull(id))
		return TRUE

	// If we arent in progress, assume complete
	if(!in_progress)
		return TRUE

	// We got here, so check the status
	var/result = rustg_http_check_request(id)

	// If we have no result, were not finished
	if(result == RUSTG_JOB_NO_RESULTS_YET)
		return FALSE
	else
		// If we got here, we have a result to parse
		_raw_response = result
		in_progress = FALSE
		return TRUE

/**
  * Response deserializer
  *
  * Takes a HTTP request object, and converts it into a [/datum/http_response]
  * The entire thing is wrapped in try/catch to ensure it doesnt break on invalid requests
  * Can be called on async and blocking requests
  */
/datum/http_request/proc/into_response()
	var/datum/http_response/R = new()

	try
		var/list/L = json_decode(_raw_response)
		R.status_code = L["status_code"]
		R.headers = L["headers"]
		R.body = L["body"]
	catch
		R.errored = TRUE
		R.error = _raw_response

		// Temp patch for rustg returning limited data on non-200 status responses
		var/static/regex/status_regex = regex(@"status code (\d+)$", "i")
		if (status_regex.Find(_raw_response))
			R.status_code = text2num(status_regex.group[1])

	return R

/**
  * # HTTP Response
  *
  * Holder datum for HTTP responses
  *
  * Created from calling [/datum/http_request/proc/into_response()]
  * Contains vars about the result of the response
  */
/datum/http_response
	/// The HTTP status code of the response
	var/status_code
	/// The body of the response from the server
	var/body
	/// Associative list of headers sent from the server
	var/list/headers
	/// Has the request errored
	var/errored = FALSE
	/// Raw response if we errored
	var/error


// Code lovingly made by ZephyrTFA of /tg/station
// And adapted for Goonstation use by ZeWaka

#define REQUEST_FAIL_BAD_URL "!!URL!!"
#define REQUEST_FAIL_NOT_POSSIBLE "!!NP!!"

/**
 * Datum used to manage the functionality and cache for the cobalt.tools API.
 */
/datum/cobalt_tools
	/// The base API url to use.
	var/base_url = "https://cobalt-api.kwiatekmiki.com" // api.cobalt.tools

/**
 * Sends a request to the cobalt.tools API to fetch a tunnel for the audio file we want.
 *
 * Returns list(filename, url) if successful, otherwise crashes.
 */
/datum/cobalt_tools/proc/request_tunnel(normalized_url, request_type = "audio")
	var/static/headers = json_encode(list(
		"Accept" = "application/json",
		"Content-Type" = "application/json",
	))

	var/body = json_encode(list(
		"url" = normalized_url,
		"downloadMode" = request_type,
		"filenameStyle" = "basic",
	))

	var/response_raw = rustg_http_request_blocking(RUSTG_HTTP_METHOD_POST, base_url, body, headers, null)
	var/list/response
	try
		response = json_decode(response_raw)
		if(!("body" in response))
			. = REQUEST_FAIL_BAD_URL
			CRASH("Failed to perform cobalt.tools API request: Response lacks body.")
		response = json_decode(response["body"])
	catch
		. = REQUEST_FAIL_BAD_URL
		CRASH("Failed to perform cobalt.tools API request: Failed to decode response.")

	var/static/list/valid_status = list("redirect", "tunnel")
	var/status = response["status"]
	if(!(status in valid_status))
		. = REQUEST_FAIL_NOT_POSSIBLE
		CRASH("Failed to perform cobalt.tools API request: [json_encode(response)]")
	return list(response["filename"], response["url"])

#undef REQUEST_FAIL_BAD_URL
#undef REQUEST_FAIL_NOT_POSSIBLE
