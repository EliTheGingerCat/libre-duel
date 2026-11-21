const ReplicatedStorage = game:GetService("ReplicatedStorage")

const POPUP_LAYOUT = require(script.Parent.POPUP_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const popup_card = require(script.Parent.popup_card)
const popup_management = require(script.Parent.popup_management)

const create_element = React.createElement

type popup = popup_management.popup

const function use_popups(): { popup }
	const popups, set_popups = React.useState(popup_management.get_all)

	const function effect_popups()
		const function on_change(): ()
			set_popups(popup_management.get_all())
		end

		const connection = popup_management.on_change:Connect(on_change)

		const function disconnect(): ()
			connection:Disconnect()
		end

		return disconnect
	end
	React.useEffect(effect_popups, {})

	return popups
end

-- popups are modal, so only the oldest one shows and the rest wait their turn
const function popup_container()
	const popups = use_popups()
	const current_popup = popups[1]

	const children = {}
	if current_popup then
		-- keyed by id so text input state never leaks into the next popup
		children[`popup_{current_popup.id}`] = create_element(popup_card, { popup = current_popup })
	end

	return create_element("ScreenGui", {
		Name = "Popups",
		DisplayOrder = POPUP_LAYOUT.DISPLAY_ORDER,
		ResetOnSpawn = false,
	}, children)
end

return popup_container
