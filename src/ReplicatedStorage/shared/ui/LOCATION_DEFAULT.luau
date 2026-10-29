export type location = {
	status: "loading",
} | {
	status: "fail",
} | {
	status: "success",
	result: string,
}

const LOCATION_DEFAULT: location = {
	status = "loading",
}

return LOCATION_DEFAULT
