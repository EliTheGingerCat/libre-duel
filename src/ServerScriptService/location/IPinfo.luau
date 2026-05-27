local HttpService = game:GetService("HttpService")

local token_saved: string?
local function use_token(): string
	assert(token_saved, "Token is missing. Please use `set_token` before accessing the API. Alternatively, use the legacy API.")
	return token_saved
end

local function set_token(token: string): ()
	token_saved = token
end

type HttpResponseData = {
	Body: string?,
	Headers: {
		[string]: string
	},
	StatusCode: number,
	StatusMessage: string,
	Status: boolean,
}

local function request(URL: string): (boolean, HttpResponseData)
	return pcall(HttpService.RequestAsync, HttpService, {
		Url = URL,
		Method = "GET",
		Headers = {
			Accept = "application/json",
		},
	})
end

local function request_authorised(URL: string,  token: string): (boolean, HttpResponseData)
	return pcall(HttpService.RequestAsync, HttpService, {
		Url = URL,
		Method = "GET",
		Headers = {
			Accept = "application/json",
			Authorization = `Bearer {token}`,
		},
	})
end

local function extract_data(success: boolean, result: HttpResponseData): {}?
	if not success then
		print("[IPinfo] Failed to request. Result:", result)
		return nil
	end

	if result.Body == nil then
		print("[IPinfo] Result has no body.")
		return nil
	end

	local success_decode, data = pcall(HttpService.JSONDecode, HttpService, result.Body)
	if not success_decode then
		print("[IPinfo] Failed to decode JSON. Result:", data)
		return nil
	end

	if type(data) ~= "table" then
		print("[IPinfo] Data returned is not a table.")
		return nil
	end

	return data
end

type data_legacy = {
	ip: string,
	city: string,
	region: string,
	country: string,
	loc: string,
	org: string,
	postal: string,
	timezone: string,
	readme: string, -- https://ipinfo.io/missingauth
}

local function get_legacy(target: string?): data_legacy
	local target_string = target or ""
	local success, result = request(`https://ipinfo.io/{target_string}`)
	local data = extract_data(success, result)
	-- ~ Todo: Typecheck data at runtime
	return data :: data_legacy
end

type data_Lite = {
	ip: string,
	asn: string,
	as_name: string,
	as_domain: string,
	country_code: string,
	country: string,
	continent_code: string,
	continent: string,
}

local function get_Lite(target: string?): data_Lite
	local target_string = target or "me"
	local success, result = request_authorised(`https://api.ipinfo.io/lite/{target_string}`, use_token())
	local data = extract_data(success, result)
	-- ~ Todo: Typecheck data at runtime
	return data :: data_Lite
end

return {
	set_token = set_token,
	get_legacy = get_legacy,
	get_Lite = get_Lite,
}
