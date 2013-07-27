require "Level"
Board = class()
function Board:ctor()
    self.bg = CCLayer:create()
    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local col = math.ceil(visibleSize.width/440)
    local row = math.ceil(visibleSize.height/440)
    for i=1, col, 1 do
        for j=1, row, 1 do
            local temp = CCSprite:create("pics/newback2.png")
            temp:setPosition(ccp((i-1)*440, (j-1)*440))
            temp:setAnchorPoint(ccp(0, 0))
            self.bg:addChild(temp)
        end
    end

    local margin = 16
    local totalWidth = 720+16*3
    local leftMargin = (visibleSize.width-totalWidth)/2

    local temp = Level.new(1)
    local level1 = temp.bg
    level1:setPosition(ccp(leftMargin, visibleSize.height/2))
    level1:setAnchorPoint(ccp(0, 0.5))
    
    local temp = Level.new(2)
    local level2 = temp.bg
    level2:setPosition(ccp(leftMargin+level1:getContentSize().width+margin, visibleSize.height/2))
    level2:setAnchorPoint(ccp(0, 0.5))

    local l2x, l2y = level2:getPosition()
    local l2size = level2:getContentSize()

    local temp = Level.new(3)
    local level3 = temp.bg
    level3:setPosition(ccp(l2x+l2size.width+margin, visibleSize.height/2))
    level3:setAnchorPoint(ccp(0, 0.5))

    local l3x, l3y = level3:getPosition()
    local l3size = level3:getContentSize()
    local temp = Level.new(4)
    local level4 = temp.bg
    level4:setPosition(ccp(l3x+l3size.width+margin, visibleSize.height/2))
    level4:setAnchorPoint(ccp(0, 0.5))

    self.bg:addChild(level1)
    self.bg:addChild(level2)
    self.bg:addChild(level3)
    self.bg:addChild(level4)

    local title = CCLabelTTF:create("帮助", "", 40)
    title:setColor(ccc3(0, 0, 0))
    title:setPosition(ccp(visibleSize.width/2, visibleSize.height/2-25))
    self.bg:addChild(title)

    local help = CCLabelTTF:create("1.从上面选择一种硬币组合\n2.进入游戏后下方是你的硬币\n3.拖动1枚硬币到中间的黑框里面,点击\"放入\"按钮\n4.从黑框中取出几枚硬币，总值小于放入的硬币，点击\"取出按钮\"\n5.等待电脑操作\n5.最后仍有硬币剩余的用户胜利！", "", 20,  CCSizeMake(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    self.bg:addChild(help)
    help:setPosition(ccp(visibleSize.width/2, visibleSize.height/2-40))
    help:setAnchorPoint(ccp(0.5, 1))
end
