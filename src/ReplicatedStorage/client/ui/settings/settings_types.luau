export type category = { id: string, text: string, icon: string, bottom: boolean? }
export type colour_value = { colour: Color3, alpha: number }
export type value = boolean | number | string | colour_value
export type option = { text: string, colour: Color3? }

type message = {
	id: string,
	category: string,
	text: string,
	kind: "information" | "warning" | "danger",
}

type action = {
	id: string,
	category: string,
	text: string,
	kind: "button" | "big_button" | "dangerous_button",
	on_activated: (() -> ())?,
}

type toggle = {
	id: string,
	category: string,
	text: string,
	kind: "switch" | "checkbox",
	default: boolean,
	on_changed: ((boolean) -> ())?,
	round: boolean?,
}

type text = {
	id: string,
	category: string,
	text: string,
	kind: "text" | "dropdown",
	default: string,
	on_changed: ((string) -> ())?,
	icon: string?,
	options: { option }?,
}

type slider = {
	id: string,
	category: string,
	text: string,
	kind: "slider",
	default: number,
	on_changed: ((number) -> ())?,
	minimum: number?,
	maximum: number?,
	step: number?,
	suffix: string?,
}

type colour = {
	id: string,
	category: string,
	text: string,
	kind: "colour",
	default: colour_value,
	on_changed: ((colour_value) -> ())?,
}

export type entry = message | action | toggle | text | slider | colour

return {}
