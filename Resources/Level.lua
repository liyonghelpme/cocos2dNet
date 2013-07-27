require "GameBoard"
Level = class()
function Level:ctor(lid)
    self.bg = CCLayer:create()
    self.levelId = lid
    self.pic = CCSprite:create("pics/coin"..lid..".png")
    self.bg:addChild(self.pic)
    self.pic:setAnchorPoint(ccp(0.5, 0.5))
    local size = self.pic:getContentSize()
    self.pic:setPosition(ccp(size.width/2, size.height/2))
    self.bg:setContentSize(self.pic:getContentSize())

    registerTouch(self)
end
function Level:onTouchBegan(x, y)
    local np = self.pic:convertToNodeSpace(ccp(x, y))
    local size = self.pic:getContentSize()
    if np.x > 0 and np.x < size.width and np.y > 0 and np.y < size.height then
        self.pic:setScale(1.2)
        return true
    end
    return false
end
function Level:onTouchMoved(x, y)
end
function Level:onTouchEnded(x, y)
    self.pic:setScale(1)

    local game = GameBoard.new(self.levelId)
    local scene = CCScene:create()
    scene:addChild(game.bg)
    CCDirector:sharedDirector():replaceScene(scene)
end
