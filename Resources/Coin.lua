Coin = class()
function Coin:ctor(game, color, value)
    self.game = game
    self.color = color
    self.value = value
    self.bg = CCLayer:create()
    self.pic = CCSprite:create("pics/"..value.."n.png")
    self.bg:addChild(self.pic)

    registerTouch(self)
end
--在用户手指下面产生一个 coin
--这个coin 隐藏到 某个地方visible = false
--看不到的coin 不能点击
function Coin:onTouchBegan(x, y)
    if self.game.gameOver then
        return false
    end
    if self.color == Color.RED and self.game.state == 0 then 
        local np = self.pic:convertToNodeSpace(ccp(x, y))
        local size = self.pic:getContentSize()
        if np.x > 0 and np.x < size.width and np.y > 0 and np.y < size.height then
            if #self.game.putList > 0 then
                self.game:showWarn("每回合只能放入1枚硬币")
                return false
            end

            self.game:clearWarn()
            if self.game.curCoin == nil then
                self.game:moveOneCoin(self.value, x, y)
                return true
            end
        end
    --移动回来棋子
    --GameBoard 里面有另外一套程序处理
    elseif self.color == Color.EMPTY and self.game.state == 1 then
        local putCoins = 0
        for k, v in ipairs(self.game.putList) do
            putCoins = putCoins+v.value
        end
        local takeCoins = 0
        for k, v in ipairs(self.game.takeList) do
            takeCoins = takeCoins+v.value
        end

        local np = self.pic:convertToNodeSpace(ccp(x, y))
        local size = self.pic:getContentSize()
        if np.x > 0 and np.x < size.width and np.y > 0 and np.y < size.height then
        
            if self.value+takeCoins >= putCoins then
                self.game:showWarn("要取出的硬币价值不能超过或者等于放入的价值!") 
                return false
            end
            self.game:clearWarn()
            if self.game.curCoin == nil then
                self.game:moveEmptyCoin(self.value, x, y)
                return true
            end
        end
    end
    return false
end

function Coin:onTouchMoved(x, y)
    if self.color == Color.RED then
        self.game:onTouchMoved(x, y)
    elseif self.color == Color.EMPTY then
        self.game:onMoveEmpty(x, y)
    end
end
function Coin:onTouchEnded(x, y)
    if self.color == Color.RED then
        self.game:onTouchEnded(x, y)
    elseif self.color == Color.EMPTY then
        self.game:onEndEmpty(x, y)
    end
end
