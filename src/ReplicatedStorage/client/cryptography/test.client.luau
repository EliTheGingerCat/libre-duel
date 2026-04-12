local send_message = require(script.Parent.send_encrypted_message)
local receive_message = require(script.Parent.recieve_encrypted_message)

receive_message.on_message_received(function(msg)
    print("The server responded: ", msg)
end)

send_message("Hi, server!")
