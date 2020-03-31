---------------------------------------------------------------------------------
--
-- ConnectScene.lua
--
---------------------------------------------------------------------------------

--Problem Host is Joined but not subscribed so other player can join and start before Host
-- is ready



local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local image, statusText, connectButton
local _W = display.contentWidth
local _H = display.contentHeight
local isNewRoomCreated = false;

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view
	
	--display.setDefault( "background", 255, 255, 255 )
  
	statusText = display.newText( "Connecting To Server...", 0, 0, "Helvetica", 24 )
	statusText:setFillColor(1,0,1)
	--statusText:setReferencePoint( display.CenterReferencePoint )
	statusText.x, statusText.y = display.contentWidth * 0.5, 50+buff
	--screenGroup:insert( statusText )

	if JOIN_GAME_TYPE == "ranked" then
	
  --[[
  connectButton =  require("widget").newButton
        {
            left = (display.contentWidth-200)/2,
            top = display.contentHeight - 70,
			font = "Helvetica",
			fontSize = 24,
            label = "Join Ranked",
            width = 200, height = 40,
            cornerRadius = 4,
            onEvent = function(event) 
                if "began" == event.phase then
				
                    if(string.len(ROOM_ID)>0 and connectButton:getLabel() == "Back") then
                      statusText.text = "Disconnecting.."
                      appWarpClient.unsubscribeRoom(ROOM_ID)
                      appWarpClient.leaveRoom(ROOM_ID)
                      appWarpClient.deleteRoom(ROOM_ID)
                      --appWarpClient.disconnect()
					  isNewRoomCreated = false
                    else
						print("CONNECT "..USER_NAME.." "..ROOM_ID)
						--JOIN_GAME_TYPE = "random"
                      statusText.text = "Connecting.."
					  appWarpClient.joinRoomInRange (1, 1, false)
                      --USER_NAME = tostring(os.clock())
                    --  appWarpClient.connectWithUserName(USER_NAME) -- join with a random name
                   -- end
                end
            end
        }
		]]
		
	elseif JOIN_GAME_TYPE == "private" then
		--[[
		
	connectButton =  require("widget").newButton
        {
            left = (display.contentWidth-200)*3/4,
            top = display.contentHeight - 370,
			font = "Helvetica",
			fontSize = 24,
            label = "Host Private Game",
            width = 200, height = 40,
            cornerRadius = 4,
            onEvent = function(event) 
                if "began" == event.phase then
					
					ROOM_ADMIN = USER_NAME
                    statusText.text = "Hosting Private Room"
					hostNameText = display.newText( "Host Name: -"..USER_NAME.."-", _W/2, 100, "Helvetica", 24 )
					hostNameText:setFillColor(1,0,1)
					local roomPropertiesTable = {players=0, isRoomPrivate=true}
					appWarpClient.createRoom ( "FloppyFinRoom" ,ROOM_ADMIN ,2 ,roomPropertiesTable )

                end
            end
        }
		
		
	joinButton =  require("widget").newButton
        {
            left = (display.contentWidth-200)*3/4,
            top = display.contentHeight - 70,
			font = "Helvetica",
			fontSize = 24,
            label = "Join Private Game",
            width = 200, height = 40,
            cornerRadius = 4,
            onEvent = function(event) 
                if "began" == event.phase then
				
					if FRIEND_USER_NAME ~= nil then
						statusText.text = "Joining Friends Game"
						appWarpClient.getRoomsInRange ( 1 ,1 )
					elseif FRIEND_USER_NAME == nil then
						print("Please Enter Friends Name")
					end
					
                end
            end
        }
		]]
	end
	
	backButton =  require("widget").newButton
        {
            left = 20,
            top = display.contentHeight -200+buff/2,
			defaultFile = "buttonLight.png",
			font = "Helvetica",
			fontSize = 24,
            label = "Back",
            width = 150, height = 45,
            cornerRadius = 4,
            onEvent = function(event) 
                if "began" == event.phase then
				
					if statusText.text == "Ranked Room Lobby" then
						--print("disconnect from Ranked server")
						display.remove(connectButton); connectButton = nil
						display.remove(backButton); backButton = nil
						
						appWarpClient.disconnect()
						isNewRoomCreated = false
						storyboard.gotoScene( "roomType", "fade", 400)
						
					elseif statusText.text == "Private Room Lobby" then
						--print("disconnect from Private server")
						display.remove(connectButton); connectButton = nil
						display.remove(joinButton); joinButton = nil
						display.remove(backButton); backButton = nil
						display.remove(hostNameText); hostNameText = nil
						display.remove(friendText); friendText=nil
						display.remove(userNameField); userNameField=nil
						display.remove(taco); taco=nil
						
						appWarpClient.disconnect()
						isNewRoomCreated = false
						storyboard.gotoScene( "roomType", "fade", 400)
						
					elseif statusText.text == "Waiting for other user" then
						--print("stop waiting for other user")
						statusText.text = "Disconnecting.."
						appWarpClient.unsubscribeRoom(ROOM_ID)
						appWarpClient.leaveRoom(ROOM_ID)
						appWarpClient.deleteRoom(ROOM_ID)
						isNewRoomCreated = false
						
						connectButton.isVisible = true
					
					elseif statusText.text == "Waiting for friend" then
						--print("stop Waiting for friend")
						appWarpClient.unsubscribeRoom(ROOM_ID)
						appWarpClient.leaveRoom(ROOM_ID)
						appWarpClient.deleteRoom(ROOM_ID)
						isNewRoomCreated = false
						
						display.remove(hostNameText); hostNameText = nil
						
						connectButton.isVisible = true
						joinButton.isVisible = true
						friendText.isVisible = true
						--userNameField.isVisible = true
						createKeyboard()
						taco.isVisible = true
						backButton:setLabel( "Back" )
						statusText.text = "Private Room Lobby"
					--[[	
					elseif statusText.text == "Connecting To Server..." then
						print("stop connection")
						
						appWarpClient.disconnect()
						isNewRoomCreated = false
						storyboard.gotoScene( "roomType", "fade", 200)
						]]
						
					else
						--if statusText ~= nil then 
						--	display.remove(statusText); statusText = nil
						--end
						appWarpClient.unsubscribeRoom(ROOM_ID)
						appWarpClient.leaveRoom(ROOM_ID)
						appWarpClient.deleteRoom(ROOM_ID)
						appWarpClient.disconnect()
						
						if connectButton ~= nil then
							display.remove(connectButton); connectButton = nil
						end
						if joinButton ~= nil then
							display.remove(joinButton); joinButton = nil
						end
						if backButton ~= nil then
							display.remove(backButton); backButton = nil
						end
						
						--[[
						appWarpClient.removeRequestListener("onConnectDone", scene.onConnectDone)  
						appWarpClient.removeRequestListener("onDisconnectDone", scene.onDisconnectDone)  
						appWarpClient.removeRequestListener("onJoinRoomDone", scene.onJoinRoomDone)  
						appWarpClient.removeRequestListener("onCreateRoomDone", scene.onCreateRoomDone)  
						appWarpClient.removeRequestListener("onSubscribeRoomDone", scene.onSubscribeRoomDone)
						appWarpClient.removeRequestListener("onUnsubscribeRoomDone", scene.onUnsubscribeRoomDone)
						appWarpClient.removeRequestListener("onUserJoinedRoom", scene.onUserJoinedRoom)
						

						appWarpClient.removeRequestListener("onLeaveRoomDone", scene.onLeaveRoomDone)
						appWarpClient.removeRequestListener("onGetMatchedRoomsDone", scene.onGetMatchedRoomsDone) 
						]]
						
						storyboard.gotoScene( "roomType", "fade", 400)
					
					end
					

                end
            end
        }
        
	--print( "\n1: createScene ConnectScene")
end

----------------------------------------------------------------------
-- Common Scene Handline
----------------------------------------------------------------------
function scene.onGetMatchedRoomsDone(resultCode , roomsTable )
	if(resultCode == WarpResponseResultCode.SUCCESS) then
	
		ROOMS_TABLE = roomsTable
		--print("--ROOMS--")
		--[[
		for key,value in pairs(ROOMS_TABLE) do print(key,value) end
		if ROOMS_TABLE[1] ~= nil then
		for key,value in pairs(ROOMS_TABLE[1]) do print(key,value) end
		end
		]]
		for i = 1,#ROOMS_TABLE do
			if ROOMS_TABLE[i].owner == FRIEND_USER_NAME then
				--print(ROOMS_TABLE[i].id)
				appWarpClient.joinRoom ( ROOMS_TABLE[i].id )
				--print(ROOMS_TABLE[1].owner)
				display.remove(userNameField); userNameField=nil
				display.remove(taco); taco=nil
				break
			end
		end
		
	
	else
    statusText.text = "onGetMatchedRoomsDone: Failed"..resultCode;
  end
end


function scene.onConnectDone(resultCode)
  if(resultCode == WarpResponseResultCode.SUCCESS) then
  --print("DONE CONNECTING To Server")
    --statusText.text = "Joining room.."  
	--statusText.text = "Ranked Room Lobby.." 
		--
		 
		
		--[[
		if JOIN_GAME_TYPE == "random" then
			local roomPropertiesTable = {players=999, isRoomPrivate=false}
			appWarpClient.joinRoomWithProperties ( roomPropertiesTable )
		elseif JOIN_GAME_TYPE == "private" then
			local roomPropertiesTable = {players=999, isRoomPrivate=true}
			appWarpClient.joinRoomWithProperties ( roomPropertiesTable )
		else print("ERROR CONNECTING")
		end
		]]--
		
		if JOIN_GAME_TYPE == "ranked" then
			--appWarpClient.joinRoomInRange (1, 1, false)
			statusText.text = "Ranked Room Lobby"
			
--[[
			if gameScore.rankedLosses == 0 then losses = 1
			else losses = gameScore.rankedLosses
			end
			
			local ratio = gameScore.rankedWins / losses
			ratio = math.round(ratio*100)*0.01
			losses = nil
			print(gameScore.rankedWins)
			print(gameScore.rankedLosses)
			print(ratio)
			]]
			winLossRatio = display.newText( "Win/Loss:  "..gameScore.rankedRatio,
				_W/2, display.contentHeight -300+buff/2, "Helvetica" ,25)
			
			connectButton =  require("widget").newButton
				{
					left = _W/2-144,--(display.contentWidth-200)/2,
					top = display.contentHeight/3 +buff,
					defaultFile = "buttonLight.png",
					font = "Helvetica",
					fontSize = 35,
					label = "Join Ranked",
					width = 288, height = 76.8,
					cornerRadius = 4,
					onEvent = function(event) 
						if "began" == event.phase then
						--[[
							if(string.len(ROOM_ID)>0 and connectButton:getLabel() == "Back") then
							  statusText.text = "Disconnecting.."
							  appWarpClient.unsubscribeRoom(ROOM_ID)
							  appWarpClient.leaveRoom(ROOM_ID)
							  appWarpClient.deleteRoom(ROOM_ID)
							  --appWarpClient.disconnect()
							  isNewRoomCreated = false
							else]]
								--print("CONNECT "..USER_NAME.." "..ROOM_ID)
								--JOIN_GAME_TYPE = "random"
								connectButton.isVisible = false
								
							  statusText.text = "Connecting.."
							  appWarpClient.joinRoomInRange (1, 1, false)
							  --USER_NAME = tostring(os.clock())
							--  appWarpClient.connectWithUserName(USER_NAME) -- join with a random name
						   -- end
						end
					end
				}
		
		elseif JOIN_GAME_TYPE == "private" then
			statusText.text = "Private Room Lobby" 
			--appWarpClient.getRoomsInRange ( 1 ,1 )

		
		
			connectButton =  require("widget").newButton
				{
					left = _W/2-144,--(display.contentWidth-200)*3/4,
					top = display.contentHeight/3 +100 +buff,
					defaultFile = "buttonLight.png",
					font = "Helvetica",
					fontSize = 30,
					label = "Host Private Game",
					 width = 288, height = 76.8,
					cornerRadius = 4,
					onEvent = function(event) 
						if "began" == event.phase and
						statusText.text == "Private Room Lobby" then
							
							ROOM_ADMIN = USER_NAME
							statusText.text = "Hosting Private Room"
							backButton.isVisible = false
							connectButton.isVisible = false
							joinButton.isVisible = false
							friendText.isVisible = false
							display.remove(userNameField); userNameField = nil
							taco.isVisible = false
							
							hostNameText = display.newText( "Your Username:   "..USER_NAME, _W/2, 350, "Helvetica", 35 )
							hostNameText.anchorX = 0
							hostNameText.x = 10
							hostNameText:setFillColor(1,1,1)
							--backButton:setLabel( "Disconnect" )
							local roomPropertiesTable = {players=0, isRoomPrivate=true}
							appWarpClient.createRoom ( "FloppyFinRoom" ,ROOM_ADMIN ,2 ,roomPropertiesTable )

						end
					end
				}
				
				
			joinButton =  require("widget").newButton
				{
					left = _W/2-144,--(display.contentWidth-200)*3/4,
					top = display.contentHeight/3 + 125+100+buff,--display.contentHeight - 70,
					defaultFile = "buttonLight.png",
					font = "Helvetica",
					fontSize = 30,
					label = "Join Private Game",
					width = 288, height = 76.8,
					cornerRadius = 4,
					onEvent = function(event) 
						if "began" == event.phase then
						
							if FRIEND_USER_NAME ~= nil then
								display.remove(friendText); friendText=nil
								statusText.text = "Joining Friends Game"
								appWarpClient.getRoomsInRange ( 1 ,1 )
							elseif FRIEND_USER_NAME == nil then
								--print("Please Enter Friends Name")
							end
							
						end
					end
				}
				
		friendText = display.newText( "To Join Private - Enter Friends Username", _W/2, 150, "Helvetica", 30 )
		friendText.anchorX = 0.5
		friendText.anchorY = 0
		friendText.x = _W/2
		friendText.y = 100 + buff
		
		
		--
		function focusKeyboard(e)
			native.setKeyboardFocus( userNameField)
		end
		
		function recieveName(e)
			if (e.phase == "submitted") then
				opponentID = userNameField.text
				changeName(opponentID)
				native.setKeyboardFocus( nil )
			end
		end
		
		function createKeyboard()
			fieldLength = 450
			userNameField = native.newTextField( display.contentWidth/2, 175+buff,fieldLength, 50, recieveName)
			userNameField:setReturnKey("done")
			
			userNameField.size = 15
			userNameField.align = "center"
			
			userNameField:addEventListener("touch",focusKeyboard)
		end
		createKeyboard()
		--FRIEND_USER_NAME = "sfsdf"
		taco = display.newText(userNameField.text,  display.contentWidth/2,250+buff,nil,25)
		
		function changeName(text)
			taco.text = text
			FRIEND_USER_NAME = text
		end
		--
		

		
		end
  else
    statusText.text = "onConnectDone: Failed"..resultCode;
  end
  
end

function scene.onLeaveRoomDone(resultCode , roomid)
	if(resultCode == WarpResponseResultCode.SUCCESS) then
	--print("Left Room "..roomid.." "..USER_NAME)
	ROOM_ADMIN = nil
		if JOIN_GAME_TYPE == "ranked" then
			statusText.text = "Ranked Room Lobby"
		elseif JOIN_GAME_TYPE == "private" then
			statusText.text = "Private Room Lobby"
		end
		
	else
    statusText.text = "onLeaveRoomDone: Failed"..resultCode;
  end
	
end

function scene.onDisconnectDone(resultCode)
  if(resultCode == WarpResponseResultCode.SUCCESS) then
    if statusText ~=nil then statusText.text = "Click to Connect to Start" end
		--print("DISCONNECTED")
    --connectButton:setLabel("Connect")
  else
    statusText.text = "onDisconnectDone: Failed"..resultCode;
  end
end

function scene.onJoinRoomDone(resultCode, roomId)
  if(resultCode == WarpResponseResultCode.SUCCESS) then
    appWarpClient.subscribeRoom(roomId)
	--print("Joined Room")
  elseif(resultCode == WarpResponseResultCode.RESOURCE_NOT_FOUND) then
  --print("room not joined")
    -- no room found with one user creating new room
	ROOM_ADMIN = USER_NAME
		--[[
		if JOIN_GAME_TYPE == "random" then
			local roomPropertiesTable = {players=0, isRoomPrivate=false}
			appWarpClient.createRoom ( "TicTacToeRoom" ,ROOM_ADMIN ,2 ,roomPropertiesTable )
		elseif JOIN_GAME_TYPE == "private" then
			local roomPropertiesTable = {players=0, isRoomPrivate=true}
			--roomPropertiesTable["result"] = ""
			appWarpClient.createRoom ( "TicTacToeRoom" ,ROOM_ADMIN ,2 ,roomPropertiesTable )
		else print("ERROR CREATING ROOM")
		end
		]]--
		
		if JOIN_GAME_TYPE == "ranked" then
			local roomPropertiesTable = {isRoomPrivate=false}
			appWarpClient.createRoom ( "FloppyFinRoom" ,ROOM_ADMIN ,2 ,roomPropertiesTable )
		end
		
  else
    statusText.text = "onJoinRoomDone: failed"..resultCode
  end  
end

function scene.onCreateRoomDone(resultCode, roomId, roomName)
  if(resultCode == WarpResponseResultCode.SUCCESS) then
    --print("DONE CREATING ROOM NOW JOIN")
    isNewRoomCreated = true;
	appWarpClient.subscribeRoom(roomId)
    appWarpClient.joinRoom(roomId)
		--[[
		if JOIN_GAME_TYPE == "random" then
			local roomPropertiesTable = {players=2, isRoomPrivate=false}
			appWarpClient.updateRoomProperties ( roomId ,roomPropertiesTable, roomPropertiesTable ) 
		elseif JOIN_GAME_TYPE == "private" then
			local roomPropertiesTable = {players=2, isRoomPrivate=true}
			appWarpClient.updateRoomProperties ( roomId ,roomPropertiesTable, roomPropertiesTable ) 
		end
		]]--
  else
    statusText.text = "onCreateRoomDone failed"..resultCode
  end  
end

function scene.onSubscribeRoomDone(resultCode, roomId)
  if(resultCode == WarpResponseResultCode.SUCCESS) then
    ROOM_ID = roomId;
	--print("Subscribed Room "..roomId.." "..USER_NAME)
    if(isNewRoomCreated) then
      waitForOtherUser()
    else
      startGame()
    end
  else
    statusText.text = "subscribeRoom failed"
  end  
end

function scene.onUnsubscribeRoomDone(resultCode , roomid)
	if(resultCode == WarpResponseResultCode.SUCCESS) then
		--print("UNSUBED")
	end
end

function scene.onUserJoinedRoom(userName, roomId)
	if(roomId == ROOM_ID and userName ~= USER_NAME) then
	--print("A PLAYER JOINED")
    --connectButton:setLabel("Connect")
    startGame()
	
  end
end

function startGame()
	
	--[[
	if connectButton ~= nil then
		display.remove(connectButton); connectButton = nil
	end
	
	if joinButton ~= nil then
		display.remove(joinButton); joinButton = nil
	end
	
	if backButton ~= nil then
		display.remove(backButton); backButton = nil
	end
	]]
	if hostNameText ~= nil then
		display.remove(hostNameText); hostNameText = nil
	end
	
	if joinButton ~= nil then connectButton.isVisible = false end
	if joinButton ~= nil then joinButton.isVisible = false end
	if joinButton ~= nil then backButton.isVisible = false end
	--print(statusText)
	--print("ABOBE")
	--if statusText ~= nil then statusText.isVisible = false end
	
	if tipText ~= nil then display.remove(tipText); tipText = nil end
	
	storyboard.gotoScene( "GameScene", "fade", 400)
	display.remove(background_Menu)
	background_Menu = nil
end

function waitForOtherUser ()
  --connectButton:setLabel("Back")
  if JOIN_GAME_TYPE == "ranked" then
  statusText.text = "Waiting for other user"
  
  elseif JOIN_GAME_TYPE == "private" then
  statusText.text = "Waiting for friend"
  backButton.isVisible = true
  backButton:setLabel( "Disconnect" )
  end
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	
	--print( "1: enterScene ConnectScene" )
	--print(USER_NAME)
	appWarpClient.initialize(API_KEY, SECRET_KEY)
	appWarpClient.connectWithUserName(USER_NAME)
	
	--[[
	if connectButton ~= nil then connectButton.isVisible = true end
	if joinButton ~= nil then joinButton.isVisible = true end
	if backButton ~= nil then backButton.isVisible = true end
	]]
	--statusText.isVisible = true
	
	--connectButton.isVisible = true
	--connectButton:setLabel("Connect")
	
	
	--print("purge")
	--storyboard.purgeAll()
	--storyboard.removeScene("GameScene")
	storyboard.removeAll()
	
	if statusText == nil then
	--print("NEEDS CREATING")
	statusText = display.newText( "2 Connecting To Server...", 0, 0, "Helvetica", 24 )
	statusText:setFillColor(1,0,1)
	end
  --statusText.text = "Connecting To Server..."
  --connectButton.isVisible = true
  isNewRoomCreated = false

  appWarpClient.addRequestListener("onConnectDone", scene.onConnectDone)  
  appWarpClient.addRequestListener("onDisconnectDone", scene.onDisconnectDone)  
  appWarpClient.addRequestListener("onJoinRoomDone", scene.onJoinRoomDone)  
  appWarpClient.addRequestListener("onCreateRoomDone", scene.onCreateRoomDone)  
  appWarpClient.addRequestListener("onSubscribeRoomDone", scene.onSubscribeRoomDone)
  appWarpClient.addRequestListener("onUnsubscribeRoomDone", scene.onUnsubscribeRoomDone)
  appWarpClient.addNotificationListener("onUserJoinedRoom", scene.onUserJoinedRoom)
  
  appWarpClient.addRequestListener("onLeaveRoomDone", scene.onLeaveRoomDone)
  appWarpClient.addRequestListener("onGetMatchedRoomsDone", scene.onGetMatchedRoomsDone) 
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	
	--print( "1: exitScene ConnectScene" )
	display.remove(statusText); statusText = nil
	display.remove(backButton)
	backButton = nil
	
	
	
	if connectButton ~= nil then display.remove(connectButton); connectButton = nil end
	if joinButton ~= nil then display.remove(joinButton); joinButton = nil end
	if backButton ~= nil then display.remove(backButton); backButton = nil end
	if hostNameText ~= nil then display.remove(hostNameText); hostNameText = nil end
	if friendText ~= nil then display.remove(friendText); friendText=nil end
	if userNameField ~= nil then display.remove(userNameField); userNameField=nil end
	if taco ~= nil then display.remove(taco); taco=nil end
	if winLossRatio ~= nil then display.remove(winLossRatio); winLossRatio=nil end
	
  --connectButton.isVisible = false
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	
	--print( "((destroying ConnectScene))" )
  display.remove(connectButton)
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene