export type location = {
	status: "loading",
} | {
	status: "fail",
} | {
	status: "success",
	result: string,
}

local location_default: location = {
	status = "loading",
}

return location_default
