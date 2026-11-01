local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])

export type portal = { render: (unknown) -> (), disconnect: () -> () }

local function mount_portal(parent: Instance): portal
	local container = Instance.new("Folder")
	local tree = ReactRoblox.createRoot(container)
	local function render(element: unknown): ()
		tree:render(ReactRoblox.createPortal(element, parent))
	end
	local function disconnect(): ()
		tree:unmount()
		container:Destroy()
	end
	return { render = render, disconnect = disconnect }
end

return mount_portal
