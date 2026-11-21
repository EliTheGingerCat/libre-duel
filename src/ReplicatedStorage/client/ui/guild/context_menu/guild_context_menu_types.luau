export type option = {
	id: string,
	text: string,
	colour: Color3,
	-- the first press only arms it, for actions that are annoying to undo
	needs_confirmation: boolean?,
}

return {}
