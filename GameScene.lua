---------------------------------------------------------------------------------
--
-- GameScene.lua
--REMOVED the ready thing ... could reimpletment with turns going back and forth
---------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()


--------------------
-- Setup
--------------------

local json = require "json"
local physics = require( "physics" ); physics.setDrawMode( "normal" )
local ads = require "ads"
local tapfortap = require "plugin.tapfortap"
local loadsave = require("loadsave")
local gameNetwork = require "gameNetwork"
local isTall = ( "iPhone" == system.getInfo( "model" ) ) and ( display.pixelHeight > 960 )
local bubbleSound = audio.loadSound( "bubble.wav" )
local jumpSound = audio.loadSound( "jumpSwoosh.aif" )
--local jumpSound = audio.loadSound( "newScore.mp3" )
local newScoreSound = audio.loadSound( "newScore.mp3" )

physics.start( )




--GAME VARIABLES

local _W =  display.contentWidth
local _H =  display.contentHeight
local myFont = native.systemFontBold
local mySize = 70
local gravity = 70
display.setStatusBar(display.HiddenStatusBar)
local nextset = 1
local wallGroup = display.newGroup( )
local CENTER = 2
local BOTTOM = 3

local wallWidth = 100
local wallHeight = 500 + 100
local scoreAlpha = 0

if isTall then
	buff = 176
else
	buff = 0
end
-----------------------------------
local side_Width = 15
local side_Height = (wallHeight + buff)/2
local top_Width = wallWidth/2 - side_Width
local top_Height = 20

local gap = 346.7

local gameSpeed = 250
local gameJumpHeight = 700

local max_V = -200
local bump_V = 300
local slow_V = 0

local crash_V_Max = 250
local crash_V_Min = 150

local jumpCount = false--75
local jumpAllow = true
--MAP_LENGTH = 10

local topCap = {top_Width+side_Width,side_Height,		-top_Width,side_Height,
		-top_Width,side_Height-top_Height,		top_Width+side_Width,side_Height-top_Height, 
		}
		
--[[
local topCapWall = {-top_Width-side_Width,-100-top_Height/2,
			top_Width+side_Width,-100-top_Height/2,
		}
		]]
		
local topCapWall = {top_Width+side_Width,-100-top_Height/2,
	-top_Width-side_Width,-100-top_Height/2,

	-top_Width-side_Width,-100-top_Height/2+5,
	top_Width+side_Width,-100-top_Height/2+5,
	
	}
		
local bottomCap = {top_Width+side_Width,-side_Height+top_Height,
			-top_Width,-side_Height+top_Height,
			-top_Width,-side_Height,
			top_Width+side_Width,-side_Height,			 
		}
		
--[[	
local bottomCapWall = {top_Width+side_Width,100+top_Height/2,
			-top_Width-side_Width,100+top_Height/2,
		}
		]]
		
local bottomCapWall = {-top_Width-side_Width,100+top_Height/2,
		top_Width+side_Width,100+top_Height/2,

		top_Width+side_Width,100+top_Height/2+5,
		-top_Width-side_Width,100+top_Height/2+5,
		}
		
local sideBox = {-wallWidth/2+side_Width,side_Height,		-wallWidth/2,side_Height,
		-wallWidth/2,-side_Height,		-wallWidth/2+side_Width,-side_Height, 
		}

local player1CollisionFilter = { categoryBits = 1, maskBits = 12 }
local player2CollisionFilter = { categoryBits = 2, maskBits = 36 }
local wallCollisionFilter = { categoryBits = 4, maskBits = 3 }
local guildCollisionFilter = { categoryBits = 8, maskBits = 1 }
local miscCollisionFilter = { categoryBits = 16, maskBits = 0 }
local player2GroundCollisionFilter = { categoryBits = 32, maskBits = 2 }
local sensorCollisionFilter = { categoryBits = 64, maskBits = 64 }
	
--local wallTable = {}
--local gameTable = {}
--gameTable.start = nil
--local timerTable = {}	
--local seaweedTable = {}
--local shadowTable = {}
--map = {}
--fishbtn = {}
	

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

local function gameLoop(event)
  appWarpClient.Loop()
end
Runtime:addEventListener("enterFrame", gameLoop)

function startTheGame()
	if gameState == nil then
		gameState = true
		appWarpClient.startGame()
		--print("START GAME")
	end
end



function onUpdatePeersReceived(dataEncoded)

--print("UPDATE INFO-------------")

dataDecoded = json.decode( dataEncoded )



userName = dataDecoded["userName"]
action = dataDecoded["action"]
mapString = dataDecoded["map"]
p2_y = tonumber(dataDecoded["p2_y"])
p2_vy = tonumber(dataDecoded["p2_vy"])
wall = tonumber(dataDecoded["wall"])
wall_Dist = tonumber(dataDecoded["wall_Dist"])
state = dataDecoded["p2_state"]
p2_vx = tonumber(dataDecoded["p2_vx"])
v = tonumber(dataDecoded["v"])
p2_vy = tonumber(dataDecoded["p2_vy"])
color = dataDecoded["color"]



	--other player enterscene complete
	if action == "entered" and userName ~= USER_NAME then--and READY == nil then
		READY = "entered"
		
		--print("OTHER PLAYER ENTERED")
	
		local infoTable = {
			userName = USER_NAME,
			color = FISH_PICKED,
			action = "players",
			}
			
		local dataEncoded = json.encode(infoTable)
			
		appWarpClient.sendUpdatePeers( dataEncoded )
	
	end
	


	--Other Player
	if action == "players" then --and READY == "entered" then
		
		--print("players recieved")
	
		if userName ~= USER_NAME then
		
		READY = "players"
			
			USER_NAME_P2 = userName
			
			FISH_PICKED_P2 = color
			--print(color)
			showGame()
			Runtime:addEventListener("enterFrame", onEveryFrame)
			
			
			--print("Me "..USER_NAME)
			--print("Player 2 "..USER_NAME_P2)
			
			
			
			if USER_NAME == ROOM_ADMIN then
				--print("IM HOST")
			
				map = {}
				function createMap()
					for i=1,MAP_LENGTH do
					map[i] = math.random(1,5)
					end
				mapString = table.concat(map)
				end
				
				createMap()
				
				
				
				myTable = {
				userName = USER_NAME,
				action = "MAP",
				map = mapString,
				}
				
				dataEncoded = json.encode(myTable)
				
				
				
				function sendMap()
					appWarpClient.sendUpdatePeers( dataEncoded )
				end
				timerTable[#timerTable+1] = timer.performWithDelay(1000,sendMap,1)
				
			else
				--print("Not HOST")
				
				
			end
		end
	
	end
	
	
	
	
	
	
	--Generate Map
	if action == "MAP" then--and READY == "players" then
		READY = "MAP"
		
		--print("map")
		mapEnd = string.len(mapString)
		
		map = {}
		for i = 1,mapEnd do
			map[i] = {}
			map[i].level = tonumber( string.sub(mapString, i, i) )
			map[i].sent = false
		end
			
		for i = 1,mapEnd do
			--print(i.." "..map[i].level)
		end
		gameTable.start = "ready"
		game_MAP_LENGTH = #map
		scoreTxt.text = game_MAP_LENGTH
		
		if game_MAP_LENGTH == 10 then
			jumpCount = 75
		elseif game_MAP_LENGTH == 20 then
			jumpCount = 125
		end
		
		beginGame()
		gameTable.start = true 
		
		
		
		
		if disconnectButton == nil then
			createDisconnect()
			
			if disconnectTimer ~= nil then timer.cancel(disconnectTimer); disconnectTimer = nil end
		end
					
	end
	
	
	
	
	--Jump Player 2
	if userName ~= USER_NAME then--and READY == "MAP" then
		if action == "jump" then
			
			
			for i = 1,#map do
				if map[i].past == nil then
				flappyNext = i
				break
					
				end
			end
			

			
			if wall_Dist ~= nil and wall ~= nil then
			if flappyNext-2 <= wall or flappyNext+2 >= wall then
				
				
				loc_x = gap*(wall-flappyNext) - wall_Dist
				
					for i = 1,#wallTable do
						if wallTable[i].score.mapWallNum == flappyNext then
						wall_loc_x = wallTable[i].score.x
						end
					end
				
				if wall_loc_x ~= nil then 
				player2.x = wall_loc_x + loc_x
				player2.state = state
				end
			end
			end
			
			player2.y = p2_y + buff
			
			if p2_vx ~= nil then
				player2.state = state
				player2.vAct = p2_vx
				player2.vTrue = player2.vAct + player2.vRel
				player2:setLinearVelocity(player2.vTrue,-gameJumpHeight)
			end
			
			

			
			
			
			if wallTable[1].score.x ~= nil then
				for i = 1,#wallTable do
					if wallTable[i].score.past == nil then
						player2_D = wallTable[i].score.x - player2.x
						break
					end
				end
			end

			
		end
	end
	
	if action == "victory" then
		if resultTimer == nil then
			resultTimer = timer.performWithDelay(1500,decideResult,1)
		end
		
		if userName == USER_NAME and LASTGAME_RESULT == nil then
			LASTGAME_RESULT = "win"
		elseif userName ~= USER_NAME and LASTGAME_RESULT == nil then
			LASTGAME_RESULT = "lose"
		elseif userName == USER_NAME and LASTGAME_RESULT == "lose" then
			LASTGAME_RESULT = "tie"
		elseif userName ~= USER_NAME and LASTGAME_RESULT == "win" then
			LASTGAME_RESULT = "tie"
		end
	
	end
	
end



--[Game Methods]--




local function createSeaweed()
local id = #seaweedTable + 1


local log_SheetData = {
	width=288,
	height=162,
	numFrames=34,
	sheetContentWidth=9792,
	sheetContentHeight=162
}

local log_Sheet = graphics.newImageSheet( "seaweed_Sprite.png", log_SheetData)

local log_sequenceData = {
	{name = "normal", start = 1,count = 34, time =1200}--,
	}
	
seaweedTable[id] = display.newSprite( log_Sheet, log_sequenceData)

local x_rand = math.random(1,100)
--[[
	if id == 1 then seaweedTable[id].x = 850 
	else seaweedTable[id].x = seaweedTable[id-1].x + gap - 50 + x_rand
	end
	]]
	seaweedTable[id].x = wallTable[#wallTable].x + 0.5*gap -50 + x_rand
	
local y_rand = math.random(1,3)
	if y_rand == 1 then y_rand = 0.875
	elseif y_rand == 2 then y_rand = 0.9
	elseif y_rand == 3 then y_rand = 0.95
	end
seaweedTable[id].y = _H*y_rand

seaweedTable[id].timeScale = 1
seaweedTable[id].xScale = .4; seaweedTable[id].yScale = .4
seaweedTable[id]:play()

physics.addBody(seaweedTable[id], "kinematic", 
	{filter=miscCollisionFilter})
seaweedTable[id]:setLinearVelocity(player2.vRel,0)

seaweedTable[id]:toFront()

end

local function createShadow()
if player2 ~= nil then

	local id = #shadowTable + 1


	local log_SheetData = {
		width=288,
		height=162,
		numFrames=19,
		sheetContentWidth=5472,
		sheetContentHeight=162
	}

	local log_Sheet = graphics.newImageSheet( "shadowFish_Sprite.png", log_SheetData)

	local log_sequenceData = {
		{name = "normal", start = 1,count = 19, time =1200}--,
		}
		
	shadowTable[id] = display.newSprite( log_Sheet, log_sequenceData)
	shadowTable[id].timeScale = 1
	shadowTable[id]:play()

	shadowTable[id]:toBack()
	background:toBack()

	physics.addBody(shadowTable[id], "kinematic",
		{filter=miscCollisionFilter})


	local direct_rand = math.random(1,2)
	if direct_rand == 1 then

		shadowTable[id].x = -_W/4
		local y_rand = math.random(_H/4,_H*3/4)
		shadowTable[id].y = y_rand
		
		local speed_rand = math.random(1,3)
		if speed_rand == 1 then speed_rand = 0
			elseif speed_rand == 2 then speed_rand = 50
			elseif speed_rand == 3 then speed_rand = 100
		end
		shadowTable[id].speed = 350+speed_rand
		shadowTable[id]:setLinearVelocity( player2.vRel+shadowTable[id].speed,0)
		
		
		local size_rand = math.random(1,3)
		
		if size_rand == 1 then size_rand = 0.3
			elseif size_rand == 2 then size_rand = 0.4
			elseif size_rand == 3 then size_rand = 0.5
		end
		shadowTable[id].xScale = size_rand
		shadowTable[id].yScale = size_rand
		
	elseif direct_rand == 2 then

		shadowTable[id].x = _W*5/4
		local y_rand = math.random(_H/4,_H*3/4)
		shadowTable[id].y = y_rand
		
		local speed_rand = math.random(1,3)
		if speed_rand == 1 then speed_rand = 1
			elseif speed_rand == 2 then speed_rand = 3
			elseif speed_rand == 3 then speed_rand = 6
		end
		shadowTable[id].speed = -75*speed_rand
		shadowTable[id]:setLinearVelocity( player2.vRel+shadowTable[id].speed,0)
		
		
		local size_rand = math.random(1,3)
		
		if size_rand == 1 then size_rand = 0.3
			elseif size_rand == 2 then size_rand = 0.4
			elseif size_rand == 3 then size_rand = 0.5
		end
		
		shadowTable[id].xScale = -size_rand
		shadowTable[id].yScale = size_rand
		
	end


end
end

function createScene()
	local box = {-_W,96,--_H*.1
	-_W,-43.2,--_H*.045
	_W,-43.2,--_H*.045
	_W,96}--_H*.1
	
	lightRays = display.newImageRect("LightRays.png",_W, _H)
	lightRays.x = _W/2
	lightRays.y = _H/2
	lightRays:toBack()
	
	background = display.newImageRect("background.png",_W, _H)
	background.x = _W/2
	background.y = _H/2
	background:toBack()
	
	energy = display.newText( "Energy: "..jumpCount, _W/2, 150, "Helvetica", 24 )
	energy.anchorX = 1
	energy.anchorY = 0
	energy.x = _W - 10
	energy.y = 150
	
	
	ground = display.newImageRect("ground.png", _W *2, 192)--_H*.2
	ground.x = _W/2
	ground.y = _H - 96
	ground.type = "wall"
	physics.addBody(ground, "kinematic",
		{shape=box, bounce=0, filter=wallCollisionFilter})
	ground:setLinearVelocity(-gameSpeed,0)
	
	ground2 = display.newImageRect("ground2.png", _W *2, 192)--_H*.2
	ground2.x = _W/2+_W*2-10
	ground2.y = _H - 96 
	ground2.type = "wall"
	physics.addBody(ground2, "kinematic",
		{shape=box, bounce=0, filter=wallCollisionFilter})
	ground2:setLinearVelocity(-gameSpeed,0)
	
	ground3 = display.newImageRect("ground.png", _W *2, 192)--_H*.2
	ground3.x = _W/2+_W*4-20
	ground3.y = _H - 96
	ground3.type = "wall"
	physics.addBody(ground3, "kinematic",
		{shape=box, bounce=0, filter=wallCollisionFilter})
	ground3:setLinearVelocity(-gameSpeed,0)
	
	player2Ground = display.newRect(_W,_H - 96,800,86.4)
	player2Ground.y = ground.y
	physics.addBody(player2Ground, "static",
			{bounce=0, filter=player2GroundCollisionFilter})
	player2Ground.isVisible = false
	
	scoreTxt = display.newText( "",_W - 10, 200, myFont,60)
	scoreTxt.anchorX = 1
	scoreTxt.anchorY = 0
	
end


function initiateSensor()
createShadow()
fishQueWall.x = _W
fishQueWall:setLinearVelocity(-gameSpeed,0)
end
function fishSensor(self,event)
if event.phase == "began" then
	timerTable[#timerTable+1] = timer.performWithDelay(1,initiateSensor,1)
end
end
function fishQue(self, event)
	if fishQueWall == nil then
	
	fishQueWall = display.newRect (_W,_H/2,50,50)
	physics.addBody(fishQueWall, "dynamic", {filter=sensorCollisionFilter})
	fishQueWall.gravityScale = 0
	fishQueWall:setLinearVelocity(-gameSpeed,0)
	fishQueWall.isVisible = false
	
	fishSensorWall = display.newRect (0,_H/2,50,50)
	physics.addBody(fishSensorWall, "kinematic", {filter=sensorCollisionFilter})
	fishSensorWall.collision = fishSensor
	fishSensorWall:addEventListener("collision", fishSensorWall)
	fishSensorWall.isVisible = false
	end
end





function sendWalls()

	wallsets()
	--createSeaweed()
	timer.performWithDelay(10,wallsets,1)
	--createSeaweed()

end

function wallsets()
	local id = #wallTable+1
	--nextset = 5
	
	
	for i = 1,#map do
		if map[i].sent == false then
			nextset = map[i].level
			map[i].sent = true
			mapWallNum = i
			break
		elseif i == #map and map[i].sent == true then
			--print("COMPLETED")
		end
		
	end

	
	
	local WALLTABLE_Y = -285 + 100*nextset
	local SCORE_Y = 100 + 100*nextset
	local BOTTOM_Y = 480 + 100*nextset
	local BLOCK_Y = 100 + 100*nextset
	
	
	---
	---
	---
	---
	if queWall ~= nil then ADD_X = queWall.x+gap else --print("FIRST WALL")
	ADD_X = 740 end
	
	wallTable[id] = display.newImageRect( "wall.png", wallWidth, wallHeight+buff)
		wallTable[id].x = ADD_X - top_Width - side_Width*2
		wallTable[id].y = WALLTABLE_Y + buff/2
		wallTable[id].yScale = -1
		wallTable[id].type = "wall"
		
		
		wallTable[id].score = display.newRect(740,600 + (buff),20,200)
		wallTable[id].score.x = ADD_X --+ top_Width + side_Width*2
		wallTable[id].score.y = SCORE_Y + buff
		wallTable[id].score.alpha = scoreAlpha
		wallTable[id].score.isHitTestable = true
		wallTable[id].score.type = "score"
		
		wallTable[id].bottom = display.newImageRect( "wall.png", wallWidth, wallHeight+buff)
		wallTable[id].bottom.x = ADD_X - top_Width - side_Width*2
		wallTable[id].bottom.y = BOTTOM_Y  + buff*1.5
		wallTable[id].bottom.type = "wall"
		
		wallTable[id].block = display.newRect(999,999,50,50)
		wallTable[id].block.x = ADD_X - top_Width - side_Width*2
		wallTable[id].block.y = BLOCK_Y + buff
		wallTable[id].block.type = "wallBlock"
		wallTable[id].block.isVisible = false
		
		
		wallTable[id].forward = display.newRect(999,999,20,_H)
		wallTable[id].forward.x = ADD_X - gap*7/10
		wallTable[id].forward.y = _H/2
		wallTable[id].forward.type = "forward"
		wallTable[id].forward.isVisible = false
		wallTable[id].forward.isHitTestable = true
		
		physics.addBody(wallTable[id], "kinematic", 
			{shape=sideBox, filter=wallCollisionFilter},{shape=topCap, filter=wallCollisionFilter})
			wallTable[id].isSensor=true
			
		physics.addBody(wallTable[id].score, "kinematic",
		{isSensor=true, filter=wallCollisionFilter})
		
		physics.addBody(wallTable[id].bottom, "kinematic",
			{shape=sideBox, filter=wallCollisionFilter},{shape=bottomCap, filter=wallCollisionFilter})
			wallTable[id].bottom.isSensor=true
			
		physics.addBody(wallTable[id].block, "kinematic",
			{shape=bottomCapWall, bounce=0, filter=wallCollisionFilter},
			{shape=topCapWall, bounce=0, filter=wallCollisionFilter})
			
		physics.addBody(wallTable[id].forward, "kinematic",
			{filter=wallCollisionFilter})
			wallTable[id].forward.isSensor=true
			
		wallTable[id]:setLinearVelocity(player2.vRel,0)
		wallTable[id].score:setLinearVelocity(player2.vRel,0)
		wallTable[id].bottom:setLinearVelocity(player2.vRel,0)
		wallTable[id].block:setLinearVelocity(player2.vRel,0)
		wallTable[id].forward:setLinearVelocity(player2.vRel,0)
		
		wallTable[id].collision = crash
		wallTable[id]:addEventListener("collision", wallTable[id])
		wallTable[id].bottom.collision = crash
		wallTable[id].bottom:addEventListener("collision", wallTable[id].bottom)
		wallTable[id].score.collision = pastWall
		wallTable[id].score:addEventListener("collision", wallTable[id].score)
		wallTable[id].block.collision = crash
		wallTable[id].block:addEventListener("collision", wallTable[id].block)
		wallTable[id].forward.collision = crashForward
		wallTable[id].forward:addEventListener("collision", wallTable[id].forward)
		
		---
		---
		---
		---
	
	wallTable[id].score.mapWallNum = mapWallNum
	wallTable[id].score.sentNext = false
	queWall = wallTable[id].score
	
	wallTable[id]:toBack()
	wallTable[id].bottom:toBack()
	lightRays:toBack()
	for i = 1,#shadowTable do
		shadowTable[i]:toBack()
	end
	background:toBack()
	
	timerTable[#timerTable+1] = timer.performWithDelay(1,createSeaweed,1)
	
end




function releaseSound(obj)

	audio.dispose(obj)
	obj = nil

end

function stopSound(obj)
audio.stop(obj)
audio.dispose(obj)
obj = nil
end

function fixWallPos()

		function rePosWall()
			for i = 1, #wallTable do
			wallTable[i].block.x = wallTable[i].score.x - top_Width - side_Width*2
			--print("OFF_CORRECTED")
			end
		end
	
		for i = 1, #wallTable do
		if 	wallTable[i].block.x -1 > wallTable[i].score.x - top_Width - side_Width*2 or 
			wallTable[i].block.x +1 <  wallTable[i].score.x - top_Width - side_Width*2 then

		timerTable[#timerTable+1] = timer.performWithDelay(15,rePosWall,1)
		end
		end		
		
end

function fixFlappyPos()

	function rePoseFish()
		flappy.x = _W/3
	end

	if _W/3 < flappy.x-2 or flappy.x + 2 < _W/3 then	
		timerTable[#timerTable+1] = timer.performWithDelay(15,rePoseFish,1)
	end
		
end





function pastWall(self, event)

	if event.phase == "ended" 
	and event.other.type == "ball" then
		flappy.state = nil
	
		event.target.past = true
	
		for i = 1,#map do
			if map[i].past == nil then
			map[i].past = true
			break
			
			end
		end
		
		game_MAP_LENGTH = game_MAP_LENGTH -1
		scoreTxt.text = game_MAP_LENGTH
		
		if flappy.x > player2.x and map[#map].sent ~= true then
			timerTable[#timerTable+1] = timer.performWithDelay(1,wallsets,1)
			--timerTable[#timerTable+1] = timer.performWithDelay(2,createSeaweed,1)
		end
		
		if flappy.x > wallTable[#wallTable].score.x and flappy.x > player2.x then
			victory()
			if jumpTimer ~= nil then timer.cancel(jumpTimer); jumpTimer = nil end
			jumpAllow = nil
		end
		
	elseif event.phase == "ended"
	and event.other.type == "player2" then
		player2.state = nil
		if player2.x > flappy.x and map[#map].sent ~= true then
			timerTable[#timerTable+1] = timer.performWithDelay(1,wallsets,1)
			--timerTable[#timerTable+1] = timer.performWithDelay(2,createSeaweed,1)
			
		end
	end
end

function crashForward(self, event)

if event.phase == "ended" and 
event.target.type == "forward" and
event.other.type == "ball" and
event.other.state == "back" then
	

	
	for i = 1,#wallTable do
		wallTable[i]:setLinearVelocity(-gameSpeed,0)
		wallTable[i].score:setLinearVelocity(-gameSpeed,0)
		wallTable[i].bottom:setLinearVelocity(-gameSpeed,0)
		wallTable[i].block:setLinearVelocity(-gameSpeed,0)
		wallTable[i].forward:setLinearVelocity(-gameSpeed,0)
		end
		for i = 1,#seaweedTable do
			seaweedTable[i]:setLinearVelocity(-gameSpeed,0)
		end
		for i = 1,#shadowTable do
			shadowTable[i]:setLinearVelocity( shadowTable[i].speed-gameSpeed,0)
			--shadowTable[i].speed = shadowTable[i].speed - bump_V
		end

		ground:setLinearVelocity(-gameSpeed,0)
		ground2:setLinearVelocity(-gameSpeed,0)
		ground3:setLinearVelocity(-gameSpeed,0)
		
		
		vx, vy = player2:getLinearVelocity()
		player2.vRel = -gameSpeed
		player2.vTrue = player2.vRel + player2.vAct
		player2:setLinearVelocity(player2.vTrue,vy)
		
		flappy.state = nil
		
elseif event.phase == "ended" and 
event.target.type == "forward" and
event.other.type == "player2" and
event.other.state == "back" then
	

	
		
		vx, vy = player2:getLinearVelocity()
		player2.vAct = gameSpeed
		player2.vTrue = player2.vRel + player2.vAct
		player2:setLinearVelocity(player2.vTrue,vy)
		
		player2.state = nil
end

end

function crash(self, event)




if event.other.type == "ball" then


	
	
	
	
	
	if --event.phase == "began" and
	event.selfElement == 1
	and event.target.type == "wall"
	and flappy.state~= "stop" and flappy.state~= "past" then

		if event.phase == "began" then
		
			for i = 1,#wallTable do
			wallTable[i]:setLinearVelocity(bump_V,0)
			wallTable[i].score:setLinearVelocity(bump_V,0)
			wallTable[i].bottom:setLinearVelocity(bump_V,0)
			wallTable[i].block:setLinearVelocity(bump_V,0)
			wallTable[i].forward:setLinearVelocity(bump_V,0)
			end
			for i = 1,#seaweedTable do
				seaweedTable[i]:setLinearVelocity(bump_V,0)
			end
			if event.phase == "began" then
				for i = 1,#shadowTable do
					shadowTable[i]:setLinearVelocity( shadowTable[i].speed+bump_V,0)
					--shadowTable[i].speed = shadowTable[i].speed + bump_V
				end

			end
			ground:setLinearVelocity(bump_V,0)
			ground2:setLinearVelocity(bump_V,0)
			ground3:setLinearVelocity(bump_V,0)
			
			vx, vy = player2:getLinearVelocity()
			player2.vRel = bump_V
			player2.vTrue = player2.vRel + player2.vAct
			player2:setLinearVelocity(player2.vTrue,vy)
			
			flappy.state = "back"

		elseif event.phase == "ended" then
			--flappy.state = nil
		end
		

		
	elseif
	event.selfElement == 2 and
	event.target.type == "wall" and
	flappy.state ~= "back" then

		
		if event.phase == "began" then
			flappy.state = "stop"
		
			for i = 1,#wallTable do
			wallTable[i]:setLinearVelocity(slow_V,0)
			wallTable[i].score:setLinearVelocity(slow_V,0)
			wallTable[i].bottom:setLinearVelocity(slow_V,0)
			wallTable[i].block:setLinearVelocity(slow_V,0)
			wallTable[i].forward:setLinearVelocity(slow_V,0)
			end
			for i = 1,#seaweedTable do
				seaweedTable[i]:setLinearVelocity(slow_V,0)
			end
			for i = 1,#shadowTable do
				shadowTable[i]:setLinearVelocity( shadowTable[i].speed,0)
				--shadowTable[i].speed = shadowTable[i].speed
			end

			ground:setLinearVelocity(slow_V,0)
			ground2:setLinearVelocity(slow_V,0)
			ground3:setLinearVelocity(slow_V,0)

			vx, vy = player2:getLinearVelocity()
			player2.vRel = slow_V
			player2.vTrue = player2.vRel + player2.vAct
			player2:setLinearVelocity(player2.vTrue,vy)
			
			
			
		
		elseif event.phase == "ended" then
			flappy.state = "past"
			
			for i = 1,#wallTable do
			wallTable[i]:setLinearVelocity(-gameSpeed,0)
			wallTable[i].score:setLinearVelocity(-gameSpeed,0)
			wallTable[i].bottom:setLinearVelocity(-gameSpeed,0)
			wallTable[i].block:setLinearVelocity(-gameSpeed,0)
			wallTable[i].forward:setLinearVelocity(-gameSpeed,0)
			end
			for i = 1,#seaweedTable do
				seaweedTable[i]:setLinearVelocity(-gameSpeed,0)
			end
			for i = 1,#shadowTable do
				shadowTable[i]:setLinearVelocity( shadowTable[i].speed-gameSpeed,0)
				--shadowTable[i].speed = shadowTable[i].speed
			end

			ground:setLinearVelocity(-gameSpeed,0)
			ground2:setLinearVelocity(-gameSpeed,0)
			ground3:setLinearVelocity(-gameSpeed,0)
			
			vx, vy = player2:getLinearVelocity()
			player2.vRel = -gameSpeed
			player2.vTrue = player2.vRel + player2.vAct
			player2:setLinearVelocity(player2.vTrue,vy)
		end
		
		
	end
	


	

	


	
	
	
	
	
	
	
	
	
	
elseif event.other.type == "player2" then
	
	if event.target.type == "score" and event.phase == "ended" then
	
		player2.state = nil

	end
	
	if --event.phase == "began" and
	event.selfElement == 1
	and event.target.type == "wall"
	and player2.state~= "stop" and player2.state~= "past" then
		
		if event.phase == "began" then
			player2.state = "back"
			
			vx, vy = player2:getLinearVelocity()
			player2.vAct = -bump_V
			player2.vTrue = player2.vRel + player2.vAct
			player2:setLinearVelocity(player2.vTrue,vy)
			
			elseif event.phase == "ended" then
			--player2.state = nil
		end


		
	elseif --event.phase == "began" and
	event.selfElement == 2 
	and event.target.type == "wall"
	and player2.state ~= "back" then

		
		if event.phase == "began" then
			player2.state = "stop"
			
			vx, vy = player2:getLinearVelocity()
			player2.vAct = -slow_V
			player2.vTrue = player2.vRel + player2.vAct
			player2:setLinearVelocity(player2.vTrue,vy)
		
		
		
		elseif event.phase == "ended" then
			player2.state = "past"
			
			vx, vy = player2:getLinearVelocity()
			player2.vAct = gameSpeed
			player2.vTrue = player2.vRel + player2.vAct
			player2:setLinearVelocity(player2.vTrue,vy)
		end
		
	end
	

	
	

	
	

end

	if event.phase == "ended" then
		fixWallPos()
		fixFlappyPos()
	end
end

function jump(event)

if gameTable.start == true and 
event.phase == "began" and flappy.y > 100+buff and
jumpAllow == true and
jumpCount > 0 then
		
		function allowJump()
			jumpAllow = true
		end
		jumpTimer = timer.performWithDelay(1,allowJump,1)
		
		jumpAllow = false
		
		jumpCount = jumpCount - 1
		energy.text = "Energy: "..jumpCount
		
		if jumpSoundChannel ~= nil then 
		--stopSound(jumpSoundChannel) 
		end
		
		--jumpSoundChannel = audio.play( jumpSound,
		--			{ channel=1, onComplete=releaseSound } )
		--audio.play(jumpSound)
		
		flappy:setLinearVelocity(0,-gameJumpHeight)
		
				for i = 1,#map do
					if map[i].past == nil then
						wall = i
						break
					end
				end
		
		
				if wallTable[1].score.x ~= nil then
					for i = 1,#wallTable do
						if wallTable[i].score.past == nil then
							flappy_D = wallTable[i].score.x - flappy.x
							break
						end
					end
				end
		
				
				local myTable = {
					userName = USER_NAME,
					action = "jump",
					p2_y = flappy.y - buff,
					p2_vy = vy,
					wall = wall,
					wall_Dist = flappy_D,
					p2_state = flappy.state,
					p2_vx = -player2.vRel,
					p2_vy = -gameJumpHeight,
						}
						
				local dataEncoded = json.encode(myTable)
				
		appWarpClient.sendUpdatePeers( dataEncoded )
		--print(USER_NAME_P2)
		--appWarpClient.sendPrivateChat (USER_NAME_P2 , dataEncoded ) 
		
		wall = nil
		
end
end

function cleanUp()

	if wallTable[1] ~=nil then
		if wallTable[1].x < -_W/2 then
		
				display.remove(wallTable[1].block)
				table.remove(wallTable[1].block,1)
			
				display.remove(wallTable[1].score)
				table.remove(wallTable[1].score,1)
				
				display.remove(wallTable[1].bottom)
				table.remove(wallTable[1].bottom,1)
				
				display.remove(wallTable[1].forward)
				table.remove(wallTable[1].forward,1)
				
				display.remove(wallTable[1])
				table.remove(wallTable,1)

		end
	end
	
	for i = #shadowTable,1,-1 do
		if shadowTable[i].x < -_W*3/4 or shadowTable[i].x > _W*7/4 then
		display.remove(shadowTable[i])
		table.remove(shadowTable, i)
		end
	end
	
	for i = #seaweedTable,1,-1 do
		if seaweedTable[i].x < -_W/2 then
			display.remove(seaweedTable[i])
			table.remove(seaweedTable, i)
		end
	end
	
end

--------------------------------------





--[On EveryFrame]--
local function animationRotation(player)
	if player.state ~= "stop" then


	local vx, vy = player:getLinearVelocity()
	
	--BOBS HEAD UP
	if vy < 0 and player.angle > -30 then
	
		--FAST ROTATION FOR
		if player.angle > 10 then
	
			if player == player2 then player2Image:rotate(-20)
			elseif player == flappy then flappyImage:rotate(-20)
			end
			player.angle = player.angle - 20
		
		--FAST BUT NOT TO FAST		
		elseif player.angle > 0 and player.angle <= 10 then
	
			--player:rotate(-player.angle - 10)
			if player == player2 then player2Image:rotate(-player.angle - 10)
			elseif player == flappy then flappyImage:rotate(-player.angle - 10)
			end
			player.angle = player.angle - player.angle -10
			
		--NORMAL ROTATION FOR
		else
			--player:rotate(-5)
			if player == player2 then player2Image:rotate(-5)
			elseif player == flappy then flappyImage:rotate(-5)
			end
			player.angle = player.angle - 5
	
		end
	
	--BOBS HEAD DOWN
	elseif vy > 0 and player.angle < 55 then
		--player:rotate(5)
		if player == player2 then player2Image:rotate(5)
		elseif player == flappy then flappyImage:rotate(5)
		end
		player.angle = player.angle + 5
	end
	
	end
end

function onEveryFrame(event)

	flappyImage.x = flappy.x
	flappyImage.y = flappy.y
	player2Image.x = player2.x
	player2Image.y = player2.y
	

	animationRotation(player2)
	animationRotation(flappy)
	
	player2Ground.x = player2.x
	

	
	
	

	if ground.x + ground.width <=0 and ground.x < _W/2 then
		ground.x = ground3.x + ground3.width-10 
		ground.xScale = -ground.xScale
	end
	if ground2.x + ground2.width <=0 and ground2.x < _W/2 then 
		ground2.x = ground.x + ground.width-10 
		ground2.xScale = -ground2.xScale
	end
	if ground3.x + ground3.width <=0 and ground3.x < _W/2 then 
		ground3.x = ground2.x + ground2.width-10 
		ground3.xScale = -ground3.xScale
	end
	
	
end






---[Game State Controller]---
function timesUp()

	LASTGAME_RESULT = "expired"
	
	appWarpClient.unsubscribeRoom(ROOM_ID);
	appWarpClient.leaveRoom(ROOM_ID);
	--appWarpClient.deleteRoom(ROOM_ID)  -- NOT SURE
	appWarpClient.disconnect()
	storyboard.gotoScene( "roomType", "slideLeft", 800 )
	
end

function decideResult()
	--print(LASTGAME_RESULT)
	
	 
	
	appWarpClient.unsubscribeRoom(ROOM_ID);
                    appWarpClient.leaveRoom(ROOM_ID);
					--appWarpClient.deleteRoom(ROOM_ID)  -- NOT SURE
                    appWarpClient.disconnect()
                    storyboard.gotoScene( "roomType", "slideLeft", 800 )
end

function victory()

	if endGameTimer ~= nil then timer.cancel(endGameTimer); endGameTimer = nil end

	local myTable = {
	userName = USER_NAME,
	action = "victory",
	}
						
	local dataEncoded = json.encode(myTable)
				
	appWarpClient.sendUpdatePeers( dataEncoded )

end

function showGame()
	
		if newBtn ~= nil then
			display.remove( newBtn )
			newBtn = nil
		end
		
		if flappy ~= nil then
			display.remove( flappy )
			flappy = nil
		end
		
		local tempTime = 0
		local tempY = -1 * _H
		



		
		-------------------------------------------
		local log_SheetData = {
			width=288,
			height=162,
			numFrames=18,
			sheetContentWidth=5184,
			sheetContentHeight=162
		}
		
		
		fishbtn = {}
		fishbtn.frame =1
		
		--[[
		if fishbtn.frame == 1 then FISH_SELECT = "sprite_Fish_Blue.png"
			elseif fishbtn.frame == 2 then FISH_SELECT = "sprite_Fish_Green.png"
			elseif fishbtn.frame == 3 then FISH_SELECT = "sprite_Fish_Black.png"
			elseif fishbtn.frame == 4 then FISH_SELECT = "sprite_Fish_Purple.png"
			elseif fishbtn.frame == 5 then fishRand = math.random(1,4)
			if fishRand == 1 then FISH_SELECT = "sprite_Fish_Blue.png"
				elseif fishRand == 2 then FISH_SELECT = "sprite_Fish_Green.png"
				elseif fishRand == 3 then FISH_SELECT = "sprite_Fish_Black.png"
				elseif fishRand == 4 then FISH_SELECT = "sprite_Fish_Purple.png"
			end
		end
		]]
		
		
		flappy = display.newRect(999,999,47.8,48)

		
		-------------------------------------------
		local fishShape = {
		-23.9,24,
		-23.9,-24,
		23.9,-24,
		23.9,24,
		}
		
		
		
		flappy.x = _W/3
		flappy.y = 300+buff
		flappy.angle = 0
		flappy.type = "ball"
		physics.addBody(flappy, "static",
			{shape=fishShape, bounce=0, --[[radius=(24),]] filter=player1CollisionFilter})
		flappy.isFixedRotation = true
		flappy.isBullet = true
		flappy.isVisible = false
		
		
		local log_Sheet = graphics.newImageSheet( FISH_PICKED, log_SheetData)

		local log_sequenceData = {
			{name = "normal", start = 1,count = 18, time =1200}--,
			}
		flappyImage = display.newSprite( log_Sheet, log_sequenceData)
			
		flappyImage.timeScale = 1
		flappyImage.xScale = .35; flappyImage.yScale = .35
		flappyImage.x = flappy.x
		flappyImage.y = flappy.y
		flappyImage:play()
		
		

		
		--local player2_INFO_FISH = 4
		--FISH_PICKED_P2
		if player2_INFO_FISH == 1 then FISH_SELECT2 = "sprite_Fish_Blue.png"
			elseif player2_INFO_FISH == 2 then FISH_SELECT2 = "sprite_Fish_Green.png"
			elseif player2_INFO_FISH == 3 then FISH_SELECT2 = "sprite_Fish_Black.png"
			elseif player2_INFO_FISH == 4 then FISH_SELECT2 = "sprite_Fish_Purple.png"
		end
		
		
		player2 = display.newRect(999,999,48,48)
		
		

		player2.x = _W/3
		player2.y = 300+buff
		player2.angle = 0
		player2.type = "player2"
		player2.vAct = gameSpeed
		player2.vRel = -gameSpeed
		physics.addBody(player2, "static",
			{shape=fishShape, bounce=0, --[[radius=(24),]] filter=player2CollisionFilter})
		player2.isFixedRotation = true
		player2.isBullet = true
		player2.isVisible = false
		
		local log_Sheet2 = graphics.newImageSheet( FISH_PICKED_P2, log_SheetData)
		player2Image = display.newSprite( log_Sheet2, log_sequenceData)
		
		player2Image.timeScale = 1
		player2Image.xScale = .35; player2Image.yScale = .35
		player2Image.alpha = 0.75
		player2Image.x = player2.x
		player2Image.y = player2.y
		player2Image:setFrame(4)
		player2Image:play()
		
		player2Image:toFront()
		flappyImage:toFront()
		
		
	guild_Left = display.newRect(_W/3-24-10,_H/2,20,_H*2)
	physics.addBody(guild_Left, "static",
		{bounce=0, fiction=0, filter=guildCollisionFilter})
	guild_Left.isVisible = false

	guild_Right = display.newRect(_W/3+24+10,_H/2,20,_H*2)
	physics.addBody(guild_Right, "static",
		{bounce=0, fiction=0, filter=guildCollisionFilter})
	guild_Right.isVisible = false
	
	screen = display.newRect(_W/2,_H/2,_W,_H)
	screen.alpha = 0
	screen.isHitTestable = true
	screen.touch = jump("yes")
	screen:addEventListener("touch",jump)

end


function  stopGame()


	gameTable.start = false

	flappy.gravityScale = 0
	flappy:setLinearVelocity(0,0)

	
end

function beginGame()

	local gameTimeLength = 36000
	
	if game_MAP_LENGTH == 20 then
		gameTimeLength = gameTimeLength*2
	end
	
	if endGameTimer == nil then endGameTimer = timer.performWithDelay(gameTimeLength, timesUp,1) end

	flappy.bodyType = "dynamic"
		player2.bodyType = "dynamic"
	physics.setGravity(0,gravity)
	cleanTimer = timer.performWithDelay(100,cleanUp,0)
	sendWalls()
	
end

function createDisconnect()

	if disconnectButton == nil then
		disconnectButton =  require("widget").newButton
			{
				left = 20,--(display.contentWidth-200)/2,
				top = 150,--display.contentHeight/5 ,
				defaultFile = "buttonLight.png",
				font = "Helvetica",
				fontSize = 24,
				label = "Disconnect",
				width = 150, height = 45,
				cornerRadius = 4,
				onEvent = function(event) 
					if "ended" == event.phase then
						appWarpClient.unsubscribeRoom(ROOM_ID);
						appWarpClient.leaveRoom(ROOM_ID);
						--appWarpClient.deleteRoom(ROOM_ID)  -- NOT SURE
						appWarpClient.disconnect()
						storyboard.gotoScene( "roomType", "slideLeft", 800 )		
					end
				end
			}  
	end
end















function scene:createScene( event )
	
	--statusText.text = "WELCOME"
	--[[
	if statusText == nil then 
		statusText = display.newText( "Welcome", _W/2, _H/4, "Helvetica", 24 )
	end
	]]
	--print( "\n2: createScene Game event")
	

	startTheGame()
	--[[
	  disconnectButton =  require("widget").newButton
        {
            left = (display.contentWidth-200)/2,
            top = display.contentHeight/3 ,
			font = "Helvetica",
            label = "Disconnect",
            width = 200, height = 40,
            cornerRadius = 4,
            onEvent = function(event) 
                if "ended" == event.phase then
                    appWarpClient.unsubscribeRoom(ROOM_ID);
                    appWarpClient.leaveRoom(ROOM_ID);
					--appWarpClient.deleteRoom(ROOM_ID)  -- NOT SURE
                    --appWarpClient.disconnect()
                    storyboard.gotoScene( "ConnectScene", "slideLeft", 800 )		
                end
            end
        }  
		]]
end

function scene:enterScene( event )
	
	--print( "2: enterScene Game event "..USER_NAME.." "..ROOM_ID )
	
	storyboard.removeAll()
	
	LASTGAME_RESULT = nil
	
	wallTable = {}
	gameTable = {}
	gameTable.start = nil
	timerTable = {}	
	seaweedTable = {}
	shadowTable = {}
	
	if MAP_LENGTH == 10 then
		jumpCount = 75
	elseif MAP_LENGTH == 20 then
		jumpCount = 125
	end
	
	jumpAllow = true
	
	
	createScene()
	fishQue()
	
	
	function delayabit()
		local infoTable = {
				userName = USER_NAME,
				action = "entered",
				}
				
		local dataEncoded = json.encode(infoTable)
				
		appWarpClient.sendUpdatePeers( dataEncoded )
	end
	
	
	delayStartTimer = timer.performWithDelay(1000,delayabit,1)

	
	
	
	disconnectTimer = timer.performWithDelay(4000,createDisconnect,1)
	
	
	
	----------
	----------
	----------
	
	
	
	
	
	
	
  
	appWarpClient.addRequestListener("onConnectDone", scene.onConnectDone)        
	appWarpClient.addRequestListener("onDisconnectDone", scene.onDisconnectDone)
	appWarpClient.addNotificationListener("onUserLeftRoom", scene.onUserLeftRoom)
	appWarpClient.addNotificationListener("onGameStarted", scene.onGameStarted)
	appWarpClient.addNotificationListener("onGameStopped", scene.onGameStopped)
	appWarpClient.addNotificationListener("onMoveCompleted", scene.onMoveCompleted)
	appWarpClient.addNotificationListener("onUpdatePeersReceived", onUpdatePeersReceived)
end

function scene:exitScene( event )
	
	--print( "2: exitScene Game event" )

	--disconnectButton.isVisible = false
	--statusText.isVisible = false
	--statusText.text = LASTGAME_RESULT
	display.remove(disconnectButton); disconnectButton = nil
	
	
	display.remove(flappy); flappy = nil
	display.remove(flappyImage); flappyImage = nil
	display.remove(player2); player2 = nil
	display.remove(player2Image); player2Image = nil
	
	display.remove(lightRays); lightRays = nil
	display.remove(background); background = nil
	display.remove(energy); dnergy = nil; jumpCount = nil
	display.remove(ground); ground = nil
	display.remove(ground2); ground2 = nil
	display.remove(ground3); ground3 = nil
	display.remove(scoreTxt); scoreTxt = nil
	
	display.remove( player2Ground ); player2Ground = nil
	display.remove( fishQueWall ); fishQueWall = nil
	display.remove( fishSensorWall ); fishSensorWall = nil
	display.remove( guild_Left ); guild_Left = nil
	display.remove( guild_Right ); guild_Right = nil
	display.remove( screen ); screen = nil
	
	for i = 1,#wallTable do
		display.remove(wallTable[i])
		display.remove(wallTable[i].bottom)
		display.remove(wallTable[i].score)
		display.remove(wallTable[i].block)
		display.remove(wallTable[i].forward)
	end
	
	for i = 1,#shadowTable do
		display.remove(shadowTable[i])
	end
	
	for i = 1,#seaweedTable do
		display.remove(seaweedTable[i])
	end
	
	for i = 1,#timerTable do
		timer.cancel( timerTable[i] )
	end
	
	if delayStartTimer ~= nil then timer.cancel(delayStartTimer); delayStartTimer = nil end
	if jumpTimer ~= nil then timer.cancel(jumpTimer); jumpTimer = nil end
	if resultTimer ~= nil then timer.cancel( resultTimer ); resultTimer = nil end
	if disconnectTimer ~= nil then timer.cancel( disconnectTimer ); disconnectTimer = nil end
	if cleanTimer ~= nil then timer.cancel( cleanTimer ); cleanTimer = nil end
	if endGameTimer ~= nil then timer.cancel(endGameTimer); endGameTimer = nil end
	
	map = nil
	queWall = nil
	
wallTable = nil
gameTable = nil
timerTable = nil
seaweedTable = nil
shadowTable = nil

fishbtn = nil
jumpAllow = nil
READY = nil

Runtime:removeEventListener("enterFrame", gameLoop)
Runtime:removeEventListener("enterFrame", onEveryFrame)
	
end

function scene:destroyScene( event )
	--print( "((destroying scene 2's view_____________))" )

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