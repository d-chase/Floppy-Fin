
--
-- singlePlayer.lua
--
---------------------------------------------------------------------------------


local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

--------------------
-- Setup
--------------------


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

--physics.start( )




--GAME VARIABLES

local _W =  display.contentWidth
--print(_W)
local _H =  display.contentHeight
local myFont = native.systemFontBold
local mySize = 70
local gravity = 70
local nextset = 1


local CENTER = 2
local BOTTOM = 3

local wallWidth = 100
local wallHeight = 500 + 100
local scoreAlpha = 0



-----------------------------------



--[Technical Methods]--
local function adMobListener( event )
   if (event.isError ) then
      -- Show ad at the bottom center of the display with no offsets or scale
		tapfortap.createAdView(TOP, CENTER)
		--tapfortap.createAdView(BOTTOM, CENTER)
   end
   return true
end

ads.init( "admob", "ca-app-pub-7586430882121573/6570726843", adMobListener )
tapfortap.initialize("0e0d77b36d6c594f739d0cb3d3e42296")
ads:setCurrentProvider( "admob" )
if isTall then ad_H = 0 else ad_H = _H-50 end
ads.show( "banner", { x=0, y=ad_H } )



local function showGameCenter(e)
	if e.phase == "began" then
		
		gameNetwork.show( "leaderboards", { leaderboard = {timeScope="AllTime"}, listener=nil } )
	end

end

local function tweetCallBack()

	gameScore.tweet = "tweet_v2"
	loadsave.saveTable(gameScore, "gameScore.json")
	MAP_LENGTH = 20

end

function showTwitter(e)
	if e.phase == "began" then
		
		if gameScore.mode == "letMeWin" then 
				msg = "I got a highscore of ".. gameScore.letHigh .. " in #floppyfin"
		elseif gameScore.mode == "normal" then
				msg = "I got a highscore of ".. gameScore.normHigh .. " in #floppyfin"
		elseif gameScore.mode == "pureFrustration" then
				msg = "I got a highscore of ".. gameScore.pureHigh .. " in #floppyfin"
		end
		
	if gameScore.tweet == nil then
		tweetLis = tweetCallBack
	else
		tweetLis = nil
	end
	


	local twitOPS = 
		{
		   message = msg,
		   listener = tweetLis,
		   url = "https://itunes.apple.com/us/app/floppy-fin-flappy-inspiration/id817950936?ls=1&mt=8"---------------------------------PUT APP URL UN LOOOK LOOOK LOOOK DONT FORGET OR YOU WILL BE MAD DAVID DAVID
		}


		native.showPopup( "twitter", twitOPS )
	end
end

local function gameNetworkCall( event )

    -- "showSignIn" is only available on iOS 6+
    if event.type == "showSignIn" then
        -- This is an opportunity to pause your game or do other things you might need to do while the Game Center Sign-In controller is up.
        -- For the iOS 6.0 landscape orientation bug, this is an opportunity to remove native objects so they won't rotate.
        -- This is type "init" for all versions of Game Center.
    elseif event.data then
        loggedIntoGC = true
       -- native.showAlert( "Success!", "", { "OK" } )
    end
end

local function onSystemEvent( event ) 

	
	
    if event.type == "applicationStart" then
        gameNetwork.init( "gamecenter", gameNetworkCall )
        return true
    end
end
--Runtime:addEventListener( "system", onSystemEvent )

---------------------------------------------------






---[Menu Methods]---

function  changeHighScore()
	
	if gameScore.mode == "letMeWin" then
		highScoreTxt.text = "Best: " .. gameScore.letHigh
		
	elseif gameScore.mode == "normal" then
		highScoreTxt.text = "Best: " .. gameScore.normHigh
		
	elseif gameScore.mode == "pureFrustration" then
		highScoreTxt.text = "Best: ".. gameScore.pureHigh
		
	end


	
end

function controlDiffBTN()
	if gameScore.mode == "letMeWin" then
		hardbtnLT.isVisible = false
		hardbtn.isVisible = true
		easybtn.isVisible = false
		easybtnLT.isVisible = true
		mediumbtn.isVisible = true
		mediumbtnLT.isVisible = false
		--print("MODE IS: " .. gameScore.mode)
	elseif gameScore.mode == "normal" then
		hardbtnLT.isVisible = fale
		hardbtn.isVisible = true
		easybtn.isVisible = true
		easybtnLT.isVisible = false
		mediumbtn.isVisible = true
		mediumbtnLT.isVisible = true
		--print("MODE IS: " .. gameScore.mode)
	elseif gameScore.mode == "pureFrustration" then
		hardbtnLT.isVisible = true
		hardbtn.isVisible = false
		easybtn.isVisible = true
		easybtnLT.isVisible = false
		mediumbtn.isVisible = true
		mediumbtnLT.isVisible = false
		--print("MODE IS: " .. gameScore.mode)
	end
end




function shrink(obj)

	obj.trans = nil
	obj.trans = transition.to(obj, {xScale=obj.xScale/1.05, yScale = obj.yScale/1.05, time =750, onComplete=grow})

end

function grow(obj)

	obj.trans = nil
	obj.trans = transition.to(obj, {xScale=obj.xScale*1.05, yScale = obj.yScale*1.05, time =750, onComplete=shrink})

end



function goMultiplayer(event)
	if event.phase == "began" then
		--print("Multiplayer Room")
		
		
		if fishbtn.frame == 1 then FISH_SELECT = "sprite_Fish_Blue.png"
			elseif fishbtn.frame == 2 then FISH_SELECT = "sprite_Fish_Green.png"
			elseif fishbtn.frame == 3 then FISH_SELECT = "sprite_Fish_Black.png"
			elseif fishbtn.frame == 4 then FISH_SELECT = "sprite_Fish_Purple.png"
			elseif fishbtn.frame == 5 then FISH_SELECT = "RANDOM"
			--[[
			fishRand = math.random(1,4)
			if fishRand == 1 then FISH_SELECT = "sprite_Fish_Blue.png"
				elseif fishRand == 2 then FISH_SELECT = "sprite_Fish_Green.png"
				elseif fishRand == 3 then FISH_SELECT = "sprite_Fish_Black.png"
				elseif fishRand == 4 then FISH_SELECT = "sprite_Fish_Purple.png"
			end
			]]
		end
		
		
		if cleanTimer ~= nil then 
		timer.cancel(cleanTimer); cleanTimer = nil 
		--print("TIMER REMOVED")
		else --print("COULDNT FIND TIMER")
		end
		if wallTmr ~= nil then timer.cancel(wallTmr); wallTmr = nil end
		storyboard.gotoScene( "roomType", "slideLeft", 400 )
		
	end
end



function selectFish(event)
	if event.phase == "began" then
	
		if gameScore.rate ~= "rated_v2" then
		
			menu.isVisible = false
			
			
			
			rateMenu = display.newImage("rateMenu.png")
			rateMenu.x = _W/2
			rateMenu.y = _H/2
			rateMenu.xScale = 1.3
			rateMenu.yScale = 1
			
			rateText = display.newText("Rate To Unlock",_W/2, 350, "Helvetica" ,45)
			rateText:setFillColor(0,.5,1)
			
			rateFish = display.newImage("rateFish.png")
			rateFish.x = _W/2
			rateFish.y = _H/2
			rateFish.xScale = 0.6; rateFish.yScale = 0.6
		
			rateNow =  require("widget").newButton
			{
				left = _W/2+100-75,--(display.contentWidth-200)/4,
				top = display.contentHeight*3/4 -100,
				defaultFile = "buttonLight.png",
				font = "Helvetica",
				fontSize = 35,
				label = "Rate",
				width = 150, height = 75,
				cornerRadius = 4,
				onEvent = function(event) 
					if "ended" == event.phase then
					   
						--take to leave review section in app store
						--save file saying they've rated the game
						--timer that removes rate buttons and brings back menu
						--system.openURL( "https://itunes.apple.com/us/app/floppy-fin/id817950936?mt=8" )
						system.openURL( "itms-apps://itunes.apple.com/app/id817950936")
						--system.openURL( "http://www.coronalabs.com" )
						
						gameScore.rate = "rated_v2"
						loadsave.saveTable(gameScore, "gameScore.json")
						
						display.remove(rateMenu); rateMenu = nil
						display.remove(rateText); rateText = nil
						display.remove(rateFish); rateFish = nil
						display.remove(rateNow); rateNow = nil
						display.remove(rateLater); rateLater = nil
						menu.isVisible = true
						
					   
					end
				end
			}  
			
			
			
			rateLater =  require("widget").newButton
			{
				left = _W/2-100-75,
				top = display.contentHeight*3/4-100,
				defaultFile = "buttonLight.png",
				font = "Helvetica",
				fontSize = 35,
				label = "Not Now",
				width = 150, height = 75,
				cornerRadius = 4,
				onEvent = function(event) 
					if "began" == event.phase then
					
						display.remove(rateNow); rateNow = nil
						display.remove(rateLater); rateLater = nil
						display.remove(rateMenu); rateMenu = nil
						display.remove(rateText); rateText = nil
						display.remove(rateFish); rateFish = nil
						menu.isVisible = true
						

					end
				end
			}
		
		else
		
			currentFrame = fishbtn.frame
			if fishbtn.frame == 5 then currentFrame = 0 end
			fishbtn:setFrame(currentFrame + 1)
		
		
		end
	end
end

function createMenu ()
	
	menu = display.newGroup( )
	
	
	
	startbtn = display.newImageRect( "buttonPlayLight.png", _W*.45, 76.8 )
	startbtn.xPos = _W /2
	startbtn.yPos =  331.2 + buff + 30 --+ 100
	startbtn.x = startbtn.xPos
	startbtn.y =  startbtn.yPos
	
	grow(startbtn)
    menu:insert(startbtn)

    titleTXT = display.newImageRect( "title.png", _W +150, 400 )
	titleTXT.xPos = _W / 2
    titleTXT.yPos = 211.2 + buff --+ 100
    titleTXT.x = titleTXT.xPos
    titleTXT.y = titleTXT.yPos
	
   	menu:insert(titleTXT)


    sharebtn = display.newImageRect( "ButtonShareLight.png", _W*.45, 76.8 )
	sharebtn.xPos = _W/2
    sharebtn.yPos = 446.4 + buff + 20 --+ 100
    sharebtn.x = sharebtn.xPos
    sharebtn.y = sharebtn.yPos
	
    menu:insert(sharebtn)
	
	
	--multibtn = display.newImage( "buttonLight.png")
	multibtn = display.newImageRect( "buttonLight.png", _W*.45, 76.8 )
	--multibtn.xScale = .6; multibtn.yScale = .6
	multibtn.xPos = _W/2
    multibtn.yPos = 571.2 + buff --+ 100
    multibtn.x = multibtn.xPos
    multibtn.y = multibtn.yPos
	
    menu:insert(multibtn)
	
	multiBtnText = display.newText("Multiplayer",multibtn.xPos, multibtn.yPos, "Helvetica" ,45)
	multiBtnText:setFillColor(0,.5,1)
	menu:insert(multiBtnText)
	

    gcbtn = display.newImage( "gcLogo.png")
	gcbtn.xScale = .4; gcbtn.yScale = .4
	gcbtn.xPos = _W/2-225 
    gcbtn.yPos = 571.2 + buff + 15 --+ 100
    gcbtn.x = gcbtn.xPos
    gcbtn.y = gcbtn.yPos
	
    menu:insert(gcbtn)
	
	--------------
	log_SheetData = {
			width=283,
			height=283,
			numFrames=5,
			sheetContentWidth=1415,
			sheetContentHeight=283
		}

	log_Sheet = graphics.newImageSheet( "sprite_Fish_Button.png", log_SheetData)

	log_sequenceData = {
		{name = "normal", start = 1,count = 5, time =1200}--,
		}
			
	fishbtn = display.newSprite( log_Sheet, log_sequenceData)
	--fishbtn = display.newImage("buttonLightSmall2.png")
	
	fishbtn.timeScale = 1
	fishbtn.xScale = .4; fishbtn.yScale = .4
	fishbtn.xPos = _W/2+225 
	fishbtn.yPos = 571.2 + buff +15 --+ 100
	fishbtn.x = fishbtn.xPos
	fishbtn.y = fishbtn.yPos
	
	if FISH_SELECT == "sprite_Fish_Blue.png" then fishbtn:setFrame(1)
	elseif FISH_SELECT == "sprite_Fish_Green.png" then fishbtn:setFrame(2)
	elseif FISH_SELECT == "sprite_Fish_Black.png" then fishbtn:setFrame(3)
	elseif FISH_SELECT == "sprite_Fish_Purple.png" then fishbtn:setFrame(4)
	elseif FISH_SELECT == "RANDOM" then fishbtn:setFrame(4)
	else fishbtn:setFrame(1)
	end
	fishbtn:addEventListener("touch",selectFish)
	
	menu:insert(fishbtn)
	------------------

    
	easybtn = display.newImageRect("ButtonLetMeWinDark.png", _W*.3, 76.8 )
	easybtn.xPos = _W * .175
	easybtn.yPos =  715.2 + buff --+ 100
	easybtn.x = easybtn.xPos
	easybtn.y = easybtn.yPos
	
    menu:insert(easybtn)
   
  
	mediumbtn = display.newImageRect( "ButtonGreenNormalDark.png", _W*.3, 76.8 )
	mediumbtn.xPos = _W * .5
	mediumbtn.yPos = 715.2 + buff --+ 100
	mediumbtn.x = mediumbtn.xPos
	mediumbtn.y = mediumbtn.yPos
	
    menu:insert(mediumbtn)
  	--mediumbtn.isVisible = false

    
	hardbtn = display.newImageRect( "ButtonPureFrustrationDark.png", _W*.3, 76.8 )
	hardbtn.xPos = _W * .825
	hardbtn.yPos = 715.2 + buff --+ 100
	hardbtn.x = hardbtn.xPos
	hardbtn.y = hardbtn.yPos
	
    
    menu:insert(hardbtn)



    easybtnLT = display.newImageRect("ButtonLetMeWinLight.png", _W*.3, 76.8 )
	easybtnLT.xPos = _W * .175
	easybtnLT.yPos =  715.2 + buff --+ 100
	easybtnLT.x = easybtnLT.xPos
	easybtnLT.y =  easybtnLT.yPos
	
    menu:insert(easybtnLT)
    easybtnLT.isVisible = false
    
  
	mediumbtnLT = display.newImageRect( "buttonGreenNormalLight.png", _W*.3, 76.8 )
	mediumbtnLT.xPos = _W * .5
	mediumbtnLT.yPos = 715.2 + buff --+ 100
	mediumbtnLT.x = mediumbtnLT.xPos
	mediumbtnLT.y = mediumbtnLT.yPos
	
   menu:insert(mediumbtnLT)
   -- mediumbtnLT.isVisible = true
 

    
	hardbtnLT = display.newImageRect( "ButtonPureFrustration.png", _W*.3, 76.8 )
	hardbtnLT.xPos = _W * .825
	hardbtnLT.yPos = 715.2 + buff --+ 100
	hardbtnLT.x = hardbtnLT.xPos
	hardbtnLT.y = hardbtnLT.yPos
	
    menu:insert(hardbtnLT)
	hardbtnLT.isVisible = false

	
	highScoreTxt = display.newText( "Best:0", 10, 15 + buff , myFont, 60 )
	highScoreTxt.anchorX = 0
	highScoreTxt.anchorY = 0
	

	scoreTxt = display.newText(gameScore.score,_W - 10, 15 + buff , myFont,60)
	scoreTxt.anchorX = 1
	scoreTxt.anchorY = 0

    startbtn:addEventListener( "touch", showGame )
	sharebtn: addEventListener( "touch", showTwitter )
	gcbtn:addEventListener( "touch", showGameCenter )
	multibtn:addEventListener( "touch", goMultiplayer)
	easybtn:addEventListener( "touch", setEasyMode )
	mediumbtn:addEventListener( "touch", setMediumMode )
	hardbtn:addEventListener( "touch", setHardMode )
    


end

local function hideMenu()
	for i=1, #menu do 
		menu[i].isVisible = false
	end
end

local function updateScore()
	gameScore.score = gameScore.score + 1
	scoreTxt.text = gameScore.score

end





function  setHardMode(e)
	if e.phase == "began" then
		gameScore.mode = "pureFrustration"
		loadsave.saveTable(gameScore, "gameScore.json")
		controlDiffBTN()
		changeHighScore()
		

		-- log gamePLy
		--analytics.logEvent( "HardModeSet" )
	end
end

function  setMediumMode(e)
	if e.phase == "began" then
		gameScore.mode = "normal"
		loadsave.saveTable(gameScore, "gameScore.json")
		controlDiffBTN()
		changeHighScore()
		
		-- log gamePLy
		--analytics.logEvent( "RegularModeSet" )

	end
end

function  setEasyMode(e)
	if e.phase == "began" then
		gameScore.mode = "letMeWin"
		loadsave.saveTable(gameScore, "gameScore.json")
		controlDiffBTN()
		changeHighScore()
		
		-- log gamePLy
		--analytics.logEvent( "EasyModeSet" )
	end
end

-------------------------------------------------------




--[Game Methods]--

--local seaweedTable = {}
--local shadowTable = {}


local function createSeaweed()
id = #seaweedTable + 1

log_SheetData = {
	width=288,
	height=162,
	numFrames=34,
	sheetContentWidth=9792,
	sheetContentHeight=162
}

log_Sheet = graphics.newImageSheet( "seaweed_Sprite.png", log_SheetData)

log_sequenceData = {
	{name = "normal", start = 1,count = 34, time =1200}--,
	}
	
seaweedTable[id] = display.newSprite( log_Sheet, log_sequenceData)

seaweedTable[id].x = _W*1.2
	y_rand = math.random(1,3)
	if y_rand == 1 then y_rand = 0.85
	elseif y_rand == 2 then y_rand = 0.9
	elseif y_rand == 3 then y_rand = 0.95
	end
seaweedTable[id].y = _H*y_rand

seaweedTable[id].timeScale = 1
seaweedTable[id].xScale = .4; seaweedTable[id].yScale = .4
seaweedTable[id]:play()

physics.addBody(seaweedTable[id], "kinematic", {isSensor=true})
seaweedTable[id]:setLinearVelocity(-200,0)

seaweedTable[id]:toFront()

menu:toFront()
if rateNow ~= nil then rateNow:toFront(); rateLater:toFront() end

--nil all parts of function
id = nil
y_rand=nil
log_SheetData = nil
log_Sheet = nil
log_sequenceData = nil


end

local function createShadow()
id = #shadowTable + 1

log_SheetData = {
	width=288,
	height=162,
	numFrames=19,
	sheetContentWidth=5472,
	sheetContentHeight=162
}

log_Sheet = graphics.newImageSheet( "shadowFish_Sprite.png", log_SheetData)

log_sequenceData = {
	{name = "normal", start = 1,count = 19, time =1200}--,
	}
	
shadowTable[id] = display.newSprite( log_Sheet, log_sequenceData)
shadowTable[id].timeScale = 1
shadowTable[id]:play()

shadowTable[id]:toBack()
background:toBack()

physics.addBody(shadowTable[id], "kinematic", {isSensor=true})


direct_rand = math.random(1,2)
if direct_rand == 1 then

	shadowTable[id].x = -_W/4
	y_rand = math.random(_H/4,_H*3/4)
	shadowTable[id].y = y_rand
	
	speed_rand = math.random(1,3)
	if speed_rand == 1 then speed_rand = 1
		elseif speed_rand == 2 then speed_rand = 2
		elseif speed_rand == 3 then speed_rand = 3
	end
	shadowTable[id].speed = 50*speed_rand
	shadowTable[id]:setLinearVelocity(50*speed_rand,0)
	
	y_rand=nil
	
	size_rand = math.random(1,3)
	
	if size_rand == 1 then size_rand = 0.3
		elseif size_rand == 2 then size_rand = 0.4
		elseif size_rand == 3 then size_rand = 0.5
	end
	shadowTable[id].xScale = size_rand
	shadowTable[id].yScale = size_rand
	
elseif direct_rand == 2 then

	shadowTable[id].x = _W*5/4
	y_rand = math.random(_H/4,_H*3/4)
	shadowTable[id].y = y_rand
	
	speed_rand = math.random(1,3)
	if speed_rand == 1 then speed_rand = .5
		elseif speed_rand == 2 then speed_rand = .9
		elseif speed_rand == 3 then speed_rand = 1.25
	end
	shadowTable[id].speed = 50*speed_rand
	shadowTable[id]:setLinearVelocity(-300*speed_rand,0)
	
	y=nil
	
	size_rand = math.random(1,3)
	
	if size_rand == 1 then size_rand = 0.3
		elseif size_rand == 2 then size_rand = 0.4
		elseif size_rand == 3 then size_rand = 0.5
	end
	
	shadowTable[id].xScale = -size_rand
	shadowTable[id].yScale = size_rand
end

--nil all parts of function
id = nil
direct_rand = nil
y_rand=nil
speed_rand = nil
size_rand = nil
log_SheetData = nil
log_Sheet = nil
log_sequenceData = nil

end

function createGameScene()
	box = {-_W,96,--_H*.1
	_W,96,--_H*.1
	_W,-43.2,--_H*.045
	-_W,-43.2}--_H*.045

	lightRays = display.newImageRect("LightRays.png",_W, _H)
	lightRays.x = _W/2
	lightRays.y = _H/2
	lightRays:toBack()
	
	background = display.newImageRect("background.png",_W, _H)
	background.x = _W/2
	background.y = _H/2
	background:toBack()
	
	

	ground = display.newImageRect("ground.png", _W *2, 192)--_H*.2
	ground.anchorX = 0
	ground.anchorY = 1
	ground.x = 0
	ground.y = _H
	ground.type = "wall"
	physics.addBody(ground, "kinematic", {shape=box, bounce=0,})
	ground:setLinearVelocity(-200,0)
	
	ground2 = display.newImageRect("ground2.png", _W *2, 192)--_H*.2
	ground2.anchorX = 0
	ground2.anchorY = 1
	ground2.x = _W + _W-10
	ground2.y = _H 
	ground2.type = "wall"
	physics.addBody(ground2, "kinematic", {shape=box, bounce=0})
	ground2:setLinearVelocity(-200,0)
	
	timerTable[#timerTable+1] = timer.performWithDelay(3000,createShadow,0)
	timerTable[#timerTable+1] = timer.performWithDelay(1500,createSeaweed,0)
end
--createGameScene()






local function wallsets()
	id = #wallTable+1

	--250
	if nextset == 1 then
		--wallTable[id] = display.newRect(740,-150,100,500)
		wallTable[id] = display.newImageRect( "wall.png", wallWidth, wallHeight+buff)
		wallTable[id].x = 740
		wallTable[id].y = -150 + buff/2 - 50
		wallTable[id].yScale = -1
		wallTable[id].type = "wall"
		wallTable[id].score = display.newRect(740,200 + (buff),20,200)
		wallTable[id].score.alpha = scoreAlpha
		wallTable[id].score.isHitTestable = true
		
		--wallTable[id].bottom = display.newRect(740,550,100,500)
		wallTable[id].bottom = display.newImageRect( "wall.png", wallWidth, wallHeight)
		wallTable[id].bottom.x = 740
		wallTable[id].bottom.y = 550  + buff + 50
		wallTable[id].bottom.type = "wall"
		
		wallTable[id].score.type = "score"
		
		physics.addBody(wallTable[id], "kinematic", {bounce=0})
		physics.addBody(wallTable[id].score, "kinematic", {isSensor=true})
		physics.addBody(wallTable[id].bottom, "kinematic", {bounce=0})
		wallTable[id]:setLinearVelocity(-200,0)
		wallTable[id].score:setLinearVelocity(-200,0)
		wallTable[id].bottom:setLinearVelocity(-200,0)

	--325
	elseif nextset == 2 then
		--wallTable[id] = display.newRect(740,-50,100,500)
		wallTable[id] = display.newImageRect( "wall.png", wallWidth, wallHeight+buff )
		wallTable[id].x = 740
		wallTable[id].y = -50 + buff/2 - 50
		wallTable[id].yScale = -1
		wallTable[id].type = "wall"
		wallTable[id].score = display.newRect(740,300 + (buff),20,200)
		wallTable[id].score.alpha = scoreAlpha
		wallTable[id].score.isHitTestable = true
		--wallTable[id].bottom = display.newRect(740,650,100,500)
		wallTable[id].bottom = display.newImageRect( "wall.png", wallWidth, wallHeight )
		wallTable[id].bottom.x = 740
		wallTable[id].bottom.y = 650  + buff + 50
		wallTable[id].bottom.type = "wall"
		
		wallTable[id].score.type = "score"
		
		physics.addBody(wallTable[id], "kinematic", {bounce=0})
		physics.addBody(wallTable[id].score, "kinematic", {isSensor=true})
		physics.addBody(wallTable[id].bottom, "kinematic", {bounce=0})
		wallTable[id]:setLinearVelocity(-200,0)
		wallTable[id].score:setLinearVelocity(-200,0)
		wallTable[id].bottom:setLinearVelocity(-200,0)
		
	--400
	elseif nextset == 3 then
		--wallTable[id] = display.newRect(740,50,100,500)
		wallTable[id] = display.newImageRect( "wall.png", wallWidth, wallHeight+buff )
		wallTable[id].x = 740
		wallTable[id].y = 50 + buff/2 - 50
		wallTable[id].yScale = -1
		wallTable[id].type = "wall"
		wallTable[id].score = display.newRect(740,400 + (buff),20,200)
		wallTable[id].score.alpha = scoreAlpha
		wallTable[id].score.isHitTestable = true
		--wallTable[id].bottom = display.newRect(740,750,100,500)
		wallTable[id].bottom = display.newImageRect( "wall.png", wallWidth, wallHeight )
		wallTable[id].bottom.x = 740
		wallTable[id].bottom.y = 750  + buff + 50
		wallTable[id].bottom.type = "wall"
		
		wallTable[id].score.type = "score"
		
		physics.addBody(wallTable[id], "kinematic", {bounce=0})
		physics.addBody(wallTable[id].score, "kinematic", {isSensor=true})
		physics.addBody(wallTable[id].bottom, "kinematic", {bounce=0})
		wallTable[id]:setLinearVelocity(-200,0)
		wallTable[id].score:setLinearVelocity(-200,0)
		wallTable[id].bottom:setLinearVelocity(-200,0)

	--475
	elseif nextset == 4 then
		--wallTable[id] = display.newRect(740,150,100,500)
		wallTable[id] = display.newImageRect( "wall.png", wallWidth, wallHeight+buff )
		wallTable[id].x = 740
		wallTable[id].y = 150 + buff/2 - 50
		wallTable[id].yScale = -1
		wallTable[id].type = "wall"
		wallTable[id].score = display.newRect(740,500 + (buff),20,200)
		wallTable[id].score.alpha = scoreAlpha
		wallTable[id].score.isHitTestable = true
		--wallTable[id].bottom = display.newRect(740,850,100,500)
		wallTable[id].bottom = display.newImageRect( "wall.png", wallWidth, wallHeight )
		wallTable[id].bottom.x = 740
		wallTable[id].bottom.y = 850  + buff + 50
		wallTable[id].bottom.type = "wall"
		
		wallTable[id].score.type = "score"
		
		physics.addBody(wallTable[id], "kinematic", {bounce=0})
		physics.addBody(wallTable[id].score, "kinematic", {isSensor=true})
		physics.addBody(wallTable[id].bottom, "kinematic", {bounce=0})
		wallTable[id]:setLinearVelocity(-200,0)
		wallTable[id].score:setLinearVelocity(-200,0)
		wallTable[id].bottom:setLinearVelocity(-200,0)
		
	--550
	elseif nextset == 5 then
		--wallTable[id] = display.newRect(740,250,100,500)
		wallTable[id] = display.newImageRect( "wall.png", wallWidth, wallHeight+buff )
		wallTable[id].x = 740
		wallTable[id].y = 250 + buff/2 - 50
		wallTable[id].yScale = -1
		wallTable[id].type = "wall"
		wallTable[id].score = display.newRect(740,600 + (buff),20,200)
		wallTable[id].score.alpha = scoreAlpha
		wallTable[id].score.isHitTestable = true
		--wallTable[id].bottom = display.newRect(740,950,100,500)
		wallTable[id].bottom = display.newImageRect( "wall.png", wallWidth, wallHeight )
		wallTable[id].bottom.x = 740
		wallTable[id].bottom.y = 950  + buff + 50
		wallTable[id].bottom.type = "wall"

		
		wallTable[id].score.type = "score"
		
		physics.addBody(wallTable[id], "kinematic", {bounce=0})
		physics.addBody(wallTable[id].score, "kinematic", {isSensor=true})
		physics.addBody(wallTable[id].bottom, "kinematic", {bounce=0})
		wallTable[id]:setLinearVelocity(-200,0)
		wallTable[id].score:setLinearVelocity(-200,0)
		wallTable[id].bottom:setLinearVelocity(-200,0)
		
	else
		--print("NA")
		
	end

	
	wallTable[id]:toBack()
	wallTable[id].bottom:toBack()
	lightRays:toBack()
	for i = 1,#shadowTable do
		shadowTable[i]:toBack()
	end
	background:toBack()
	
	--[[
	
	if ground ~= nil and ground2~= nil then
		ground:toFront()
		ground2:toFront()
		for i = #seaweedTable,1,-1 do
			seaweedTable[i]:toFront()
		end
	end
	]]
	nextset = math.random(1,5)
	id = nil
end

local function sendWalls()
	wallsets()
	wallTmr = timer.performWithDelay(1600,wallsets,0)
end

local function killWalls()
	
	for i = #wallTable,1,-1 do
		display.remove(wallTable[i].bottom)
		table.remove(wallTable[i].bottom,1)
		display.remove(wallTable[i].score)
		table.remove(wallTable[i].score,1)
		display.remove(wallTable[i])
		table.remove(wallTable, i)
		
	end

	
end



local function releaseSound(obj)

	--print(obj)
	audio.dispose(obj)
	obj = nil
	--print(obj)

end

local function stopSound(obj)
audio.stop(obj)
audio.dispose(obj)
obj = nil
end


local function crash(self, event)
	--print(#wallTable)
	
	if event.other.type == "score" and event.other.hit == nil then
	event.other.hit = true
		event.other:setFillColor(1,1,0)
		updateScore()
	elseif event.other.type == "wall" then
		-- check if they set a new high score, if they did set high score to score
				--audio.play( bubbleSound, ({duration=1700}) )
				bubbleChannel = audio.play( bubbleSound,
				{ channel=2, duration=1700, onComplete=releaseSound } )
				
			if gameScore.mode == "letMeWin" then 
				if gameScore.score > gameScore.letHigh then
					--audio.play( newScoreSound )
					newScoreChannel = audio.play( newScoreSound,
				{ channel=3, onComplete=releaseSound } )
				
					newBtn = display.newImageRect("new.png",_W/4,48)
					newBtn.x = _W/3
					newBtn.y = 96 + buff
					gameScore.letHigh = gameScore.score 
					
				 gameNetwork.request( "setHighScore",
					{
			    		localPlayerScore = { category="com.floppyFin.letmewin", value=gameScore.letHigh },
			    		listener=nil
					})

				 	loadsave.saveTable(gameScore, "gameScore.json")
				 		
				 end
			elseif gameScore.mode == "normal" then 

				if gameScore.score > gameScore.normHigh then
					--audio.play( newScoreSound )
					newScoreChannel = audio.play( newScoreSound,
				{ channel=3, onComplete=releaseSound } )
				
					newBtn = display.newImageRect("new.png",_W/4,48)
					newBtn.x = _W/3
					newBtn.y = 96 + buff
					gameScore.normHigh = gameScore.score 
					
					gameNetwork.request( "setHighScore",
						{
				    		localPlayerScore = { category="com.floppyFin.normal", value=gameScore.normHigh },
				    		listener=nil
						})

					loadsave.saveTable(gameScore, "gameScore.json")

				 		
				 	end

			elseif gameScore.mode == "pureFrustration" then
				if gameScore.score > gameScore.pureHigh then
					--audio.play( newScoreSound )
					newScoreChannel = audio.play( newScoreSound,
				{ channel=3, onComplete=releaseSound } )
					
					newBtn = display.newImageRect("new.png",_W/4,48)
					newBtn.x = _W/3
					newBtn.y = 96 + buff
					gameScore.pureHigh = gameScore.score 
					
					gameNetwork.request( "setHighScore",
						{
						    localPlayerScore = { category="com.floppyFin.purefrustration", value=gameScore.pureHigh },
						    listener=nil
						})

					loadsave.saveTable(gameScore, "gameScore.json")

				
				 		
				 	end

			end

			
		--print("LETHIGH" ..  gameScore.letHigh )
			--print( gameScore.score)
		
		stopGame()
		


	end

end

local function jump(event)

	if tapText ~= nil then
		display.remove(tapText)
		tapText.trans = nil
		tapText = nil
	end

	if event.phase == "began" and
	gameTable.start == nil or gameTable.start == false then
		startGame()
		gameTable.start = true
		flappy.bodyType = "dynamic"
		--print("start") 
	end
	
	if gameScore.mode == "letMeWin" then jumpPower = 13
	elseif gameScore.mode == "normal" then jumpPower = 14
	elseif gameScore.mode == "pureFrustration" then jumpPower = 15
	end
	--print(jumpPower)
	if event.phase == "began" then
	
		
		
		
	
		if flappy.y > 75+buff then
		
		if jumpSoundChannel ~= nil then 
		stopSound(jumpSoundChannel) 
		end
		jumpSoundChannel = audio.play( jumpSound,
					{ channel=1, onComplete=releaseSound } )
		--audio.play(jumpSound)
		flappy:setLinearVelocity(0,0)
		flappy:applyForce( 0, -jumpPower, flappy.x, flappy.y )
		
		--print("jump")
		elseif flappy.y <= 100 then
		--flappy:setLinearVelocity(0,0)
		--flappy:applyForce( 0, 0, flappy.x, flappy.y )
		--print("short_jump")
		end
	
	end
end

local function cleanUp()
	--print("the length is " .. #wallTable)
	--print("remove")
	if wallTable ~= nil then
	if wallTable[1] ~=nil then
		if wallTable[1].x < -50 then
			
				display.remove(wallTable[1].score)
				table.remove(wallTable[1].score,1)
				
				display.remove(wallTable[1].bottom)
				table.remove(wallTable[1].bottom,1)
				
				display.remove(wallTable[1])
				table.remove(wallTable,1)

		end
	end
	else
		--print("===========")
	end
	
	if shadowTable ~= nil then
	for i = #shadowTable,1,-1 do
		if shadowTable[i].x < -_W*3 or shadowTable[i].x > _W*4/3 then
		display.remove(shadowTable[i])
		table.remove(shadowTable, i)
		end
	end
	end
	
	if seaweedTable ~= nil then
	for i = #seaweedTable,1,-1 do
		if seaweedTable[i].x < -_W*3 then
			display.remove(seaweedTable[i])
			table.remove(seaweedTable, i)
		end
	end
	end
end

--------------------------------------





--[On EveryFrame]--
function animationRotation()
	scoreTxt:toFront( )

	vx, vy = flappy:getLinearVelocity()
	
	--BOBS HEAD UP
	if vy < 0 and flappy.angle > -30 then
	
		--FAST ROTATION FOR
		if flappy.angle > 10 then
	
			flappy:rotate(-20)
			flappy.angle = flappy.angle - 20
		
		--FAST BUT NOT TO FAST		
		elseif flappy.angle > 0 and flappy.angle <= 10 then
	
			flappy:rotate(-flappy.angle - 10)
			flappy.angle = flappy.angle - flappy.angle -10
			
		--NORMAL ROTATION FOR
		else
			flappy:rotate(-5)
			flappy.angle = flappy.angle - 5
	
		end
	
	--BOBS HEAD DOWN
	elseif vy > 0 and flappy.angle < 55 then
		flappy:rotate(5)
		flappy.angle = flappy.angle + 5
	end
	
end

local function onEveryFrame(event)

	if flappy ~= nil then --NEW
		vx, vy = flappy:getLinearVelocity()
		
		animationRotation()
		if vy > 1000 then physics.setGravity(0,0) --Max Fall Speed
		flappy:setLinearVelocity(0,1000)
		elseif math.abs(vy) < 1000 then physics.setGravity(0,gravity)
		end
	end --NEW
	
	if ground ~= nil and ground2 ~= nil then
		if ground.x ~= nil and ground2.x ~= nil then
			if ground.x + ground.width <=0 then ground.x = ground2.x + ground2.width-10 end
			if ground2.x + ground2.width <=0 then ground2.x = ground.x + ground.width-10 end
		end
	end
	
end
--Runtime:addEventListener("enterFrame", onEveryFrame)





---[Game State Controller]---


local function wallsBack()
	--print("BACK")
end

function showGame(e)
	if e.phase == "ended" then
	
		if newBtn ~= nil then
			display.remove( newBtn )
			newBtn = nil
		end
		
		if flappy ~= nil then
			display.remove( flappy )
			flappy = nil
		end
		killWalls()
		
		local tempTime = 0
		local tempY = -1 * _H
		for i=1, menu.numChildren do
			transition.to( menu[i], { time=tempTime, alpha=1, x=(_W/2), y=(tempY), onComplete=hideMenu } )
		end
		
		highScoreTxt.isVisible = false

		
		gameScore.score = 0
		scoreTxt.text = gameScore.score

		
		-------------------------------------------
		log_SheetData = {
			width=288,
			height=162,
			numFrames=18,
			sheetContentWidth=5184,
			sheetContentHeight=162
		}

		
		if fishbtn.frame == 1 then FISH_SELECT = "sprite_Fish_Blue.png"
			FISH_PICKED = FISH_SELECT
		elseif fishbtn.frame == 2 then FISH_SELECT = "sprite_Fish_Green.png"
			FISH_PICKED = FISH_SELECT
		elseif fishbtn.frame == 3 then FISH_SELECT = "sprite_Fish_Black.png"
			FISH_PICKED = FISH_SELECT
		elseif fishbtn.frame == 4 then FISH_SELECT = "sprite_Fish_Purple.png"
			FISH_PICKED = FISH_SELECT
		elseif fishbtn.frame == 5 then FISH_SELECT = "RANDOM"
			
			fishRand = math.random(1,4)
			if fishRand == 1 then FISH_PICKED = "sprite_Fish_Blue.png"
				elseif fishRand == 2 then FISH_PICKED = "sprite_Fish_Green.png"
				elseif fishRand == 3 then FISH_PICKED = "sprite_Fish_Black.png"
				elseif fishRand == 4 then FISH_PICKED = "sprite_Fish_Purple.png"
			end
			
		end
		
		log_Sheet = graphics.newImageSheet( FISH_PICKED, log_SheetData)

		log_sequenceData = {
			{name = "normal", start = 1,count = 18, time =1200}--,
			}
			
		flappy = display.newSprite( log_Sheet, log_sequenceData)


		flappy.timeScale = 1
		flappy.xScale = .35; flappy.yScale = .35
		flappy:play()
		-------------------------------------------

		
		flappy.x = _W/3
		flappy.y = 300+buff
		flappy.angle = 0
		physics.addBody(flappy, "static",{bounce=0, radius=(24)})

		flappy.collision = crash
		flappy:addEventListener("collision", flappy)
		
		menu:toFront()

		tapText = display.newImage("tapText.png")
		tapText.x = _W/2
		tapText.y = _H/5
		tapText.xScale = 0.3
		tapText.yScale = 0.3
		grow(tapText)

		screen = display.newRect(_W/2,_H/2,_W,_H)
		screen.alpha = 0
		screen.isHitTestable = true
		screen:addEventListener("touch",jump)

	end
end

function  stopGame()

	if wallTmr ~= nil then timer.cancel( wallTmr ) 
	end
	--[[
	if wallTmrInitial ~= nil then
	timer.cancel( wallTmrInitial ) 
	end
	]]
	
	changeHighScore()

	--tempTime = 0
	transition.to( startbtn, { time=tempTime, alpha=1, x=startbtn.xPos, y=startbtn.yPos, onComplete=hideMenu } )
	transition.to( sharebtn, { time=tempTime, alpha=1, x=sharebtn.xPos, y=sharebtn.yPos, onComplete=hideMenu } )
	transition.to( gcbtn, { time=tempTime, alpha=1, x=gcbtn.xPos, y=gcbtn.yPos, onComplete=hideMenu } )
	transition.to( multibtn, { time=tempTime, alpha=1, x=multibtn.xPos, y=multibtn.yPos, onComplete=hideMenu } )
	transition.to( multiBtnText, { time=tempTime, alpha=1, x=multibtn.xPos, y=multibtn.yPos, onComplete=hideMenu } )
	transition.to( easybtn, { time=tempTime, alpha=1, x=easybtn.xPos, y=easybtn.yPos, onComplete=hideMenu } )
	transition.to( mediumbtn, { time=tempTime, alpha=1, x=mediumbtn.xPos, y=mediumbtn.yPos, onComplete=hideMenu } )
	transition.to( hardbtn, { time=tempTime, alpha=1, x=hardbtn.xPos, y=hardbtn.yPos, onComplete=hideMenu } )
	transition.to( easybtnLT, { time=tempTime, alpha=1, x=easybtnLT.xPos, y=easybtnLT.yPos, onComplete=hideMenu } )
	transition.to( mediumbtnLT, { time=tempTime, alpha=1, x=mediumbtnLT.xPos, y=mediumbtnLT.yPos, onComplete=hideMenu } )
	transition.to( hardbtnLT, { time=tempTime, alpha=1, x=hardbtnLT.xPos, y=hardbtnLT.yPos, onComplete=hideMenu } )
	transition.to( titleTXT, { time=tempTime, alpha=1, x=titleTXT.xPos, y=titleTXT.yPos, onComplete=hideMenu } )
	transition.to( fishbtn, { time=tempTime, alpha=1, x=fishbtn.xPos, y=fishbtn.yPos, onComplete=hideMenu } )
	
	
	
	
	highScoreTxt.isVisible = true
	gameTable.start = false

	if flappy ~= nil then
	
	--flappy:gravityScale = 0
	flappy.gravityScale = 0.
	flappy:setLinearVelocity(-200,0)
	
	
		--display.remove( flappy )
		--flappy = nil
	end

		
	if screen ~= nil then
		screen:removeEventListener( "touch", jump )
		display.remove( screen )
		screen = nil
	end

	--audio.dispose( bubbleSound )
	--bubbleSound = audio.loadSound( "bubble.wav" )

	
	--buttonsFront()
	
end

function startGame()
	
	physics.setGravity(0,gravity)
	if cleanTimer == nil then 
	cleanTimer = timer.performWithDelay(1600,cleanUp,0)
	
	elseif cleanTimer ~= nil then --print("TRIED TO CREATE SECOND Timer")
	end
	--wallTmrInitial = timer.performWithDelay(2000,sendWalls,1)
	sendWalls()
	--print("CREATE CLEANTIMER")
end

--createMenu()
--changeHighScore()
--loadsave.saveTable(gameScore, "gameScore.json")












function scene:createScene( event )
	
	--print( "\n2: createScene singlePlayer")
	

end

function scene:enterScene( event )
	
	--print( "2: enterScene singlePlayer")
	
	storyboard.removeAll()
	
	physics.start( )
	
	if isTall then
		buff = 176
	else
		buff = 0
	end


	-----------------------------------




	--[Loading / Saving Scores]--
	gameScore  = {}

	if loadsave.loadTable("gameScore.json") == nil then 
		loadsave.saveTable(gameScore, "gameScore.json")
	end

	gameScore = loadsave.loadTable("gameScore.json")

	if gameScore.score == nil then
		gameScore.score = 0
		score = gameScore.score
	end

	if gameScore.letHigh == nil then 
		gameScore.letHigh = 0
	end

	if gameScore.normHigh == nil then 
		gameScore.normHigh= 0
	end

	if gameScore.pureHigh == nil then 
		gameScore.pureHigh = 0
	end
	
	if gameScore.tweet == nil then
		MAP_LENGTH = 10
	elseif gameScore.tweet ~= nil then
		MAP_LENGTH = 20
	end
	
	--print(gameScore.sdf)
	
	if gameScore.rankedWins == nil then
		gameScore.rankedWins = 0
	end
	
	if gameScore.rankedLosses == nil then
		gameScore.rankedLosses = 0
	end
	
	if gameScore.rankedRatio == nil then
		gameScore.rankedRatio = 0
	end
	
	--print(gameScore.rankedWins)
	--print(gameScore.rankedLosses)
	--print(gameScore.rankedWins/(gameScore.rankedLosses+1))

	gameScore.mode = "normal"
	
	
	
	
	
	wallTable = {}
	wallGroup = display.newGroup( )
	gameTable = {}
	gameTable.start = nil
	
	timerTable = {}
	seaweedTable = {}
	shadowTable = {}
	
	Runtime:addEventListener( "system", onSystemEvent )
	createGameScene()
	Runtime:addEventListener("enterFrame", onEveryFrame)
	
	createMenu()
	changeHighScore()
	loadsave.saveTable(gameScore, "gameScore.json")
	
	
	
	
	
	
end

function scene:exitScene( event )
	
	--print( "2: exitScene singlePlayer" )



	
	
	for i = 1,#timerTable do
		timer.cancel( timerTable[i] )
	end
	timerTable = nil
	--display.remove()
	
	menu.isVisible = false
	titleTXT.isVisible = false
	scoreTxt.isVisible = false
	highScoreTxt.isVisible = false
	if newBtn ~= nil then display.remove(newBtn); newBtn = nil end
	
	for i = 1,#shadowTable do
		display.remove(shadowTable[i])
	end
	shadowTable = nil
	
	for i = 1,#seaweedTable do
		display.remove(seaweedTable[i])
	end
	seaweedTable = nil
	
	display.remove(lightRays); lightRays = nil
	display.remove(background); background = nil
	display.remove(ground); ground = nil
	display.remove(ground2); ground2 = nil
		
	if flappy ~= nil then display.remove( flappy ); flappy = nil end
	
	for i = 1,#wallTable do
		display.remove( wallTable[i] )
		display.remove( wallTable[i].bottom )
		display.remove( wallTable[i].score )
	end
	wallTable = nil
	
	--[[
	local function gameLoop(event)
	appWarpClient.Loop()
	end
	Runtime:addEventListener("enterFrame", gameLoop)
	]]
	
	Runtime:removeEventListener( "system", onSystemEvent )
	Runtime:removeEventListener("enterFrame", onEveryFrame)
	--object:removeEventListener( eventName, listener )
	
end

function scene:destroyScene( event )
	--print( "destroying scene singlePlayer" )

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