-- id of the latest request sent, responses to older requests get ignored
local remote_id = {
	current = 0,
}

function remote_id.next_id(): number
	remote_id.current += 1
	return remote_id.current
end

return remote_id
