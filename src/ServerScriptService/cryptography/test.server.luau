local send_message = require(script.Parent.send_encrypted_message)
local receive_message = require(script.Parent.recieve_encrypted_message)

receive_message.on_message_received(function(player, msg)
    print(`{player.Name} said: {msg}`)

    send_message(player, "Hi, client!")
end)
