--
-- Abstract: Storyboard Chat Sample using AppWarp
--
--
-- Demonstrates use of the AppWarp API (connect, disconnect, joinRoom, subscribeRoom, chat )
--

display.setStatusBar( display.HiddenStatusBar )

--local storyboard = require "storyboard"
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require "widget"
appWarpClient = require "AppWarp.WarpClient"
local loadsave = require("loadsave")

-- load first scene
--storyboard.purgeAll()

--storyboard.gotoScene( "ConnectScene", "fade", 400 )

-- Replace these with the values from AppHQ dashboard of your AppWarp app
API_KEY_RANKED = "bb6a5a8e7e235d33308f034bc3ada99b237f6b35b91936a34595da4ade0043b5"
SECRET_KEY_RANKED = "2f29a9cd31be447fdde45d3a0262af8f3fa4a6cee7a7a7b2680d0ea3c7dd368d"

API_KEY_PRIVATE = "8f871d9e606dbfce1fd0b28089b9406287f82139b697150d75f50a131a402c3e"
SECRET_KEY_PRIVATE = "e6daf6dbf24c57834ee5be5fe4f2d5aa1f355085737d744a5d0a1b3dbf1115c7"

--API_KEY = API_KEY_RANDOM
--SECRET_KEY = SECRET_KEY_RANDOM

--ROOM_ID = "698454267"
ROOM_ID = ""
--USER_NAME = ""
REMOTE_USER = ""
ROOM_ADMIN = ""

local _W = display.contentWidth
local _H = display.contentHeight

-- create global warp client and initialize it
--appWarpClient = require "AppWarp.WarpClient"
--appWarpClient.initialize(API_KEY, SECRET_KEY)

--appWarpClient.enableTrace(true)

-- IMPORTANT! loop WarpClient. This is required for receiving responses and notifications
local function gameLoop(event)
  appWarpClient.Loop()
end

Runtime:addEventListener("enterFrame", gameLoop)


function createBackground()
	if background_Menu == nil then
	
		background_Menu = display.newImageRect("background_Menu.png",_W, _H)
		background_Menu.x = _W/2
		background_Menu.y = _H/2
		background_Menu. alpha = 0.3
		background_Menu:toBack()
		
	end
end





function scene:createScene( event )
	
	--print( "\n2: createScene RoomType")
	 
end

function scene:enterScene( event )
	
	--print( "\n2: enterScene RoomType")
	
	storyboard.removeAll()
	
	if FISH_SELECT == "RANDOM" then
	
		fishRand = math.random(1,4)
		if fishRand == 1 then FISH_PICKED = "sprite_Fish_Blue.png"
			elseif fishRand == 2 then FISH_PICKED = "sprite_Fish_Green.png"
			elseif fishRand == 3 then FISH_PICKED = "sprite_Fish_Black.png"
			elseif fishRand == 4 then FISH_PICKED = "sprite_Fish_Purple.png"
		end
		
	else
		FISH_PICKED = FISH_SELECT	
	end
	
	if gameScore.rate == nil then
		tip = "Tip: Rate To Unlock More Fish"
	elseif gameScore.rate ~=nil and gameScore.tweet == nil then
		tip = "Tip: Share To Unlock Longer Races"
	else
		tip = " "
	end
	
	if tipText == nil and tip ~= nil then
	tipText = display.newText( tip, 
	_W*2/3, display.contentHeight -200+buff/2, "Helvetica" ,25)
	tipText.anchorY = 0
	end
	
	createBackground()
	
	
	if LASTGAME_RESULT == "win" then 
		resultText = display.newText( "Victory", _W/2, _H-300+buff/2, "Helvetica", 50 )
		gameScore.rankedWins = gameScore.rankedWins + 1
		
		if gameScore.rankedLosses == 0 then losses = 1
		else losses = gameScore.rankedLosses
		end
			
		gameScore.rankedRatio = gameScore.rankedWins / losses
		gameScore.rankedRatio = math.round(gameScore.rankedRatio*100)*0.01
		losses = nil
		
		loadsave.saveTable(gameScore, "gameScore.json")
	elseif LASTGAME_RESULT == "lose" then
		resultText = display.newText( "Defeat", _W/2, _H-300+buff/2, "Helvetica", 50 )
		gameScore.rankedLosses = gameScore.rankedLosses + 1
		
		if gameScore.rankedLosses == 0 then losses = 1
		else losses = gameScore.rankedLosses
		end
			
		gameScore.rankedRatio = gameScore.rankedWins / losses
		gameScore.rankedRatio = math.round(gameScore.rankedRatio*100)*0.01
		losses = nil
		
		loadsave.saveTable(gameScore, "gameScore.json")
	elseif LASTGAME_RESULT == "tie" then
		resultText = display.newText( "Draw", _W/2, _H-300+buff/2, "Helvetica", 50 )
	elseif LASTGAME_RESULT == "expired" then
		resultText = display.newText( "No Contest -time expired-", _W/2, _H-300+buff/2, "Helvetica", 50 )
	end
	
	--storyboard.purgeAll()
	
	rankedGameButton =  require("widget").newButton
        {
            left = _W/2-144,--(display.contentWidth-200)/4,
            top = display.contentHeight/3 ,
			defaultFile = "buttonLight.png",
			font = "Helvetica",
			fontSize = 35,
            label = "Play Ranked",
            width = 288, height = 76.8,
            cornerRadius = 4,
            onEvent = function(event) 
                if "ended" == event.phase then
                    API_KEY = API_KEY_RANKED
					SECRET_KEY = SECRET_KEY_RANKED
					
					JOIN_GAME_TYPE = "ranked"
					
	--				appWarpClient.initialize(API_KEY, SECRET_KEY)
					storyboard.gotoScene( "ConnectScene", "fade", 400 )
					
					--USER_NAME = tostring(os.clock())
	--				  appWarpClient.connectWithUserName(USER_NAME)
                    --storyboard.gotoScene( "ConnectScene", "slideLeft", 800 )		
                end
            end
        }  
		
		homeButton =  require("widget").newButton
        {
            left = 20,
            top = display.contentHeight -200+buff/2,
			defaultFile = "buttonLight.png",
			font = "Helvetica",
			fontSize = 24,
            label = "Home",
            width = 150, height = 45,
            cornerRadius = 4,
            onEvent = function(event) 
                if "began" == event.phase then
				
					display.remove(background_Menu); background_Menu = nil
					if tipText ~= nil then display.remove(tipText); tipText = nil end
					storyboard.gotoScene( "singlePlayer", "fade", 400 )
					
				
					

                end
            end
        }
		
		
	privateGameButton =  require("widget").newButton
        {
            left = _W/2-144,--(display.contentWidth-200)*3/4,
            top = display.contentHeight/3 + 125,
			defaultFile = "buttonLight.png",
			font = "Helvetica",
			fontSize = 35,
            label = "Play Private",
            width = 288, height = 76.8,
            cornerRadius = 4,
            onEvent = function(event) 
                if "ended" == event.phase then
                    API_KEY = API_KEY_PRIVATE
					SECRET_KEY = SECRET_KEY_PRIVATE
					
					JOIN_GAME_TYPE = "private"
					
		--			appWarpClient.initialize(API_KEY, SECRET_KEY)
					storyboard.gotoScene( "ConnectScene", "fade", 400 )
					
					--USER_NAME = tostring(os.clock())
		--			appWarpClient.connectWithUserName(USER_NAME)
                    --storyboard.gotoScene( "ConnectScene", "slideLeft", 800 )		
                end
            end
        }  
	
end

function scene:exitScene( event )
	
	--print( "\n2: exitScene RoomType")
	display.remove(rankedGameButton); rankedGameButton = nil
	display.remove(privateGameButton); privateGameButton = nil
	display.remove(homeButton); homeButton = nil
	if resultText ~= nil then display.remove(resultText); resultText = nil end
	LASTGAME_RESULT = nil
	
	
	
end

function scene:destroyScene( event )
	--print( "\n2: destroyScene RoomType")

end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )











return scene