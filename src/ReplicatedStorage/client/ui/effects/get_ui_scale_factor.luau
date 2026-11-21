-- multiplies every UIScale between the instance and its LayerCollector, so absolute sizes can be turned back into offsets
const function get_ui_scale_factor(instance: Instance): number
	local factor = 1
	local current: Instance? = instance
	while current and not current:IsA("LayerCollector") do
		const scale = current:FindFirstChildOfClass("UIScale")
		if scale then
			factor *= scale.Scale
		end
		current = current.Parent
	end
	return factor
end

return get_ui_scale_factor
