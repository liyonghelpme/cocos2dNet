require "Coin"
local simple = require "SimpleJson"
GameBoard = class()
function GameBoard:ctor(kind)
    self.kind = kind
    self.bg = CCLayer:create()


    self.state = 0 
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

    local temp = CCSprite:create("pics/gameboard.png")
    temp:setPosition(ccp(visibleSize.width/2, visibleSize.height/2))
    self.bg:addChild(temp)
    self.gameboard = temp

    self.coinLayer = CCLayer:create()
    self.bg:addChild(self.coinLayer)

    local totalWidth = 623
    local leftMargin = (visibleSize.width-totalWidth)/2
    local margin = 177
    local db 
    local bottomMargin = 5 
    local smallMargin = 23
    local coinSize = {46, 46}

    if kind == 1 then
        db = BoardNum1
    elseif kind == 2 then
        db = BoardNum2
    elseif kind == 3 then
        db = BoardNum3
    else
        db = BoardNum4
    end
    
    --self.userCoins = {}
    --计算机当前持有的银币
    --self.computerCoins = {}
    self.potCoins = {}
    self.potNum = {}
    self.computerNum = {}

    self.allCoins = {}
    self.coinOrder = {}
    self.coinNum = {}
    for k, v in ipairs(db) do
        --table.insert(self.userCoins, {v[1], v[2]})
        --table.insert(self.computerCoins, {v[1], v[2]})
        --硬币的编号
        self.coinOrder[v[1]] = k
        self.potNum[v[1]] = 0
        self.computerNum[v[1]] = v[2]
        table.insert(self.coinNum, v[1])
        for i =1, v[2], 1 do
            local coin = Coin.new(self, Color.RED, v[1])
            table.insert(self.allCoins, coin)
            self.coinLayer:addChild(coin.bg)
            coin.bg:setPosition(ccp(leftMargin+(k-1)*margin+(i-1)*smallMargin+coinSize[1], 5+coinSize[2]))
            --coin.bg:setAnchorPoint(ccp(0, 0))
        end

        for i=1, v[2], 1 do
            local coin = Coin.new(self, Color.BLUE, v[1])
            table.insert(self.allCoins, coin)
            self.coinLayer:addChild(coin.bg)
            coin.bg:setPosition(ccp(leftMargin+(k-1)*margin+(i-1)*smallMargin+coinSize[1], visibleSize.height-5-coinSize[2]))
            --coin.bg:setAnchorPoint(ccp(0, 1))
        end
    end

    --玩家当前回合放置的硬币
    self.putList = {}
    self.takeList = {}

    local function onButton()
        --当前用户移动棋子到中心
        if self.gameOver then
            local scene = CCScene:create()
            local game = Board.new()
            scene:addChild(game.bg)
            CCDirector:sharedDirector():replaceScene(scene)
            return
        end
        if self.state == 0 then
            local pv = self:getPutValue()
            if pv == 0 then
                self:showWarn("至少需要放入一枚硬币")
                return
            end
            self.state = 1
            self.takeList = {}
            self.word:setString("取出")
            self:updateValue()
            --可以不取出
            --self.okBut:setColor(ccc3(125, 125, 125))
            self.cancel:setColor(ccc3(125, 125, 125))
            if not self.hintYet then
                self.hintYet = true
                self:showWarn("从黑框中取出0枚或者几枚硬币，总值要小于放入的值！点击按钮确认！")
            end

        elseif self.state == 1 then
            self.state = 0
            self.putList = {}
            self.word:setString("放入")
            self.okBut:setColor(ccc3(125, 125, 125))
            self.cancel:setColor(ccc3(125, 125, 125))

            self:clearWarn()
            self:updateValue()

            --进入AI 计算模式
            --self.word:setString("电脑决策中")
            self:doAI() 
            self.state = 2
            --self:checkEnd()
        elseif self.state == 2 then

        end
    end
    self.hud = CCLayer:create()
    self.bg:addChild(self.hud)
    local but = CCMenuItemImage:create("pics/button.png", "pics/buttonOn.png")
    but:registerScriptTapHandler(onButton)
    self.okBut = but

    local label = CCLabelTTF:create("放入", "", 30)
    label:setAnchorPoint(ccp(0.5, 0.5))
    label:setColor(ccc3(0, 0, 0))
    label:setPosition(ccp(70, 30))
    self.word = label
    but:addChild(label)

    --可以反悔放入 或者取出
    local function onCancel()
        if self.gameOver then
            return
        end
        --反悔放入的硬币
        if self.state == 0 then
            for k, v in ipairs(self.putList) do
                self:putRed(v.value)
                self:takeEmpty(v.value)
            end
            self.putList = {}

            self.okBut:setColor(ccc3(125, 125, 125))
            self.cancel:setColor(ccc3(125, 125, 125))
        elseif self.state == 1 then
            for k, v in ipairs(self.takeList) do
                self:putEmpty(v.value)
                self:takeRed(v.value)
            end
            self.takeList = {}

            self.okBut:setColor(ccc3(125, 125, 125))
            self.cancel:setColor(ccc3(125, 125, 125))
        end
    end

    local cancel = CCMenuItemImage:create("pics/button.png", "pics/buttonOn.png")
    cancel:registerScriptTapHandler(onCancel)
    self.cancel = cancel
    local label = CCLabelTTF:create("反悔", "", 30)
    label:setAnchorPoint(ccp(0.5, 0.5))
    label:setColor(ccc3(255, 0, 0))
    label:setPosition(ccp(70, 30))
    cancel:addChild(label)

    but:setPosition(ccp(visibleSize.width-10-70, 160))
    cancel:setPosition(ccp(10+70, 160))

    local menu = CCMenu:create()
    menu:setPosition(ccp(0, 0))
    menu:addChild(but)
    menu:addChild(cancel)
    self.okBut:setColor(ccc3(125, 125, 125))
    self.cancel:setColor(ccc3(125, 125, 125))
    self.hud:addChild(menu)

    local putValue = CCLabelTTF:create("放入:0", "", 30)
    putValue:setPosition(ccp(visibleSize.width-10, visibleSize.height-20))
    putValue:setAnchorPoint(ccp(1, 1))
    putValue:setColor(ccc3(230, 10, 20))
    self.hud:addChild(putValue)
    self.putValue = putValue

    local takeValue = CCLabelTTF:create("取出:0", "", 30)
    takeValue:setPosition(ccp(visibleSize.width-10, visibleSize.height-60))
    takeValue:setAnchorPoint(ccp(1, 1))
    takeValue:setColor(ccc3(10, 230, 20))
    self.hud:addChild(takeValue)
    self.takeValue = takeValue

    self.inAi = false
    self.aiState = 0
    self.passTime = 0
    registerUpdate(self)
    self.hintYet = false
    self:showWarn("从下方选择一枚硬币放入黑框中")
end
function GameBoard:update(diff)
    if self.inAi then
        local moveTime = 0.5
        if self.aiState == 0 then
            self:putValueIntoPot(Color.BLUE, self.aiPut)
            self.flyCoin.bg:setPosition(ccp(self.startPosition[1], self.startPosition[2]))
            self.flyCoin.bg:runAction(CCMoveTo:create(moveTime, ccp(self.targetPosition[1], self.targetPosition[2])))
            self.aiState = 1
            self.passTime = 0
        elseif self.aiState == 1 then
            self.passTime = self.passTime + diff
            if self.passTime >= moveTime then
                self.aiState = 2
                self.passTime = 1
            end
        elseif self.aiState == 2 then
            if self.passTime >= moveTime then
                if #self.aiTake > 0 then
                    self.passTime = 0
                    local nextValue = self.aiTake[1]
                    table.remove(self.aiTake, 1)
                    if nextValue > 0 then
                        self:takeCoinFromPotValue(Color.BLUE, nextValue)
                        self.flyCoin.bg:setPosition(ccp(self.startPosition[1], self.startPosition[2]))
                        self.flyCoin.bg:runAction(CCMoveTo:create(moveTime, ccp(self.targetPosition[1], self.targetPosition[2])))
                        self.passTime = 0
                    end
                else
                    self.aiState = 3
                end
            else
                self.passTime = self.passTime + diff
            end
        elseif self.aiState == 3 then
            self.inAi = false
            self.state = 0
            self:checkEnd()
        end

    end
end

function GameBoard:getAllColorCoins(color, value)
    local allPossible = {}
    for k, v in ipairs(self.allCoins) do
        if v.value == value and v.color == color then
            table.insert(allPossible, v)
        end
    end
    --不用排序 如果需要则返回最后一个即可
    --堆栈
    --[[
    local function cmp(a, b)
        local ax, ay = a.bg:getPosition()
        local bx, by = b.bg:getPosition()
        if ay < by then
            return true
        end
        if ax > bx then
            return true
        end
        return false
    end
    table.sort(allPossible, cmp)
    --]]
    return allPossible
end

--反悔
function GameBoard:putRed(value)
    local coin = Coin.new(self, Color.RED, value)
    self.coinLayer:addChild(coin.bg)

    local allPossible = self:getAllColorCoins(Color.RED, value)
    local cr = self.coinOrder[value]

    local totalWidth = 623
    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local leftMargin = (visibleSize.width-totalWidth)/2
    local bigMargin = 177
    local bottomMargin = 5 
    local smallMargin = 23
    local startX = leftMargin+46+(cr-1)*bigMargin
    local startY = bottomMargin+46
    
    if #allPossible < 4 then 
        startX = startX + #allPossible*smallMargin
    else
        startX = startX + (#allPossible-4)*smallMargin
        startY = startY+70
    end

    coin.bg:setPosition(ccp(startX, startY))
    table.insert(self.allCoins, coin)
end

function GameBoard:getAllPotValue(value)
    local allPossible = {}
    for k, v in pairs(self.potCoins) do
        if v.value == value then
            table.insert(allPossible, v)
        end
    end

    --[[
    local function cmp(a, b)
        local ax, ay = a.bg:getPosition()
        local bx, by = b.bg:getPosition()
        if ay < by then
            return true
        end
        if ax > bx then
            return true
        end
        return false
    end
    table.sort(allPossible, cmp)
    --]]

    return allPossible
end

--反悔
function GameBoard:takeEmpty(value)
    --移除空coin
    local allPossible = self:getAllPotValue(value)
    local remove = allPossible[#allPossible]
    for k, v in ipairs(self.potCoins) do
        if v == remove then
            table.remove(self.potCoins, k)
            break
        end
    end

    self.potNum[value] = self.potNum[value]-1
    remove.bg:removeFromParentAndCleanup(true)
end
--反悔
function GameBoard:takeRed(value)
    local allPossible = self:getAllColorCoins(Color.RED, value)

    for k, v in ipairs(self.allCoins) do
        if v == allPossible[#allPossible] then
            table.remove(self.allCoins, k)
            break
        end
    end
    allPossible[#allPossible].bg:removeFromParentAndCleanup(true)
end

--反悔
function GameBoard:putEmpty(value)
    local size = self.gameboard:getContentSize()
    local px, py = self.gameboard:getPosition()
    local left = px-size.width/2
    local bottom = py-size.height/2
    local right = px+size.width/2
    local top = py+size.height/2
    
    local smallMargin = 20
    local bigMargin = 170
    local coin = Coin.new(self, Color.EMPTY, value)
    self.coinLayer:addChild(coin.bg)

    local allPossible = self:getAllPotValue(value)
    local cr = self.coinOrder[value]
    local startX = left+46+(cr-1)*bigMargin 
    local startY = top-60
        --第一行有空位可以放置
    if #allPossible < 4 then
        local cx = startX+#allPossible*smallMargin
        local cy = startY
        coin.bg:setPosition(ccp(cx, cy))
        table.insert(self.potCoins, coin)
    else
        local cx = startX+(#allPossible-4)*smallMargin
        local cy = bottom+60
        coin.bg:setPosition(ccp(cx, cy))
        table.insert(self.potCoins, coin)
    end
    self.potNum[value] = self.potNum[value]+1
end

function GameBoard:checkEnd()
    local redCount = 0
    local blueCount = 0
    for k, v in ipairs(self.allCoins) do
        if v.color == Color.RED then
            redCount = redCount+1
        elseif v.color == Color.BLUE then
            blueCount = blueCount+1
        end
    end
    if redCount == 0 then
        self.gameOver = true
        self:showWarn("你失败了！")
        self.word:setString("重新开始")
        self.okBut:setColor(ccc3(255, 255, 255))
    elseif blueCount == 0 then
        self.gameOver = true
        self:showWarn("你获胜了！")
        self.word:setString("重新开始")
        self.okBut:setColor(ccc3(255, 255, 255))
    end
end
function GameBoard:doAI()
    --计算机此类硬币还有剩余
    --putValue ---> pickValue{} 组合
    --对所有potCoins 做任意的组合 
    --sum < put
    --且sum最大的结果
    --搜索所有可能性
    --减去分支
    local allSum = {}
    --和列表
    local sumList = {}
    local res = ''
    for k, v in ipairs(self.potCoins) do
        res = res..v.value..','
    end
    print(res)
    --3种硬币  4种硬币
    --寻找最大值的组合
    if #self.coinNum == 3 then
        local v1 = self.coinNum[1]
        local v2 = self.coinNum[2]
        local v3 = self.coinNum[3]

        local n1 = self.potNum[v1]
        local n2 = self.potNum[v2]
        local n3 = self.potNum[v3]
        for i=0, n1, 1 do
            for j=0, n2, 1 do
                for k = 0, n3, 1 do
                    local sum = v1*i+v2*j+v3*k
                    if allSum[sum] == nil then
                        table.insert(sumList, sum)
                    end
                    local temp = allSum[sum] or {}
                    --v1 数量 v2 数量 v3 数量
                    local pureList = {}
                    for t1=1, i, 1 do
                        table.insert(pureList, v1)
                    end
                    for t1=1, j, 1 do
                        table.insert(pureList, v2)
                    end
                    for t1=1, k, 1 do
                        table.insert(pureList, v3)
                    end
                    table.insert(temp, pureList)
                    allSum[sum] = temp
                end
            end
        end
        --寻找一个硬币和所有和中 差值最小的对
        --A coin - B sum > 0  
        local function cmp(a, b)
            return a > b
        end
        --对于所有的和 从大到小 检测所有银币从小到大 
        --如果大于则可以取出这些硬币
        local put = nil
        local take = nil
        table.sort(sumList, cmp)
        local c1 = self.computerNum[v1]
        local c2 = self.computerNum[v2]
        local c3 = self.computerNum[v3]
        for k, v in ipairs(sumList) do
            print("check", v1, v, c1)
            print("check", v2, v, c2)
            print("check", v3, v, c3)
            if v1 > v and c1 > 0 then
                put = v1
                take = v
                break
            elseif v2 > v and c2 > 0 then
                put = v2
                take = v
                break
            elseif v3 > v and c3 > 0 then
                put = v3
                take = v
                break
            end
        end

        --从计算机中放入一个 棋子
        --从池子中拿出若干个棋子
        local takeList = allSum[take]
        local rd = math.random(#takeList)
        rd = takeList[rd]

        print("sumList", simple:encode(sumList))
        print("allSum", simple:encode(allSum))
        print("put take", put, take)
        print(simple:encode(takeList))
        print(simple:encode(rd))
        --放入
        
        self.aiPut = put
        self.aiTake = rd
        self.inAi = true
        self.aiState = 0
        --[[
        self:putValueIntoPot(Color.BLUE, put)
        self:takeCoinFromPot(Color.BLUE, rd)
        --]]

    --4 种硬币
    else
        local v1 = self.coinNum[1]
        local v2 = self.coinNum[2]
        local v3 = self.coinNum[3]
        local v4 = self.coinNum[4]

        local n1 = self.potNum[v1]
        local n2 = self.potNum[v2]
        local n3 = self.potNum[v3]
        local n4 = self.potNum[v4]
        

        for i=0, n1, 1 do
            for j=0, n2, 1 do
                for k = 0, n3, 1 do
                    for l=0, n4, 1 do
                        local sum = v1*i+v2*j+v3*k+v4*l
                        if allSum[sum] == nil then
                            table.insert(sumList, sum)
                        end
                        local temp = allSum[sum] or {}

                        local pureList = {}
                        for t1=1, i, 1 do
                            table.insert(pureList, v1)
                        end
                        for t1=1, j, 1 do
                            table.insert(pureList, v2)
                        end
                        for t1=1, k, 1 do
                            table.insert(pureList, v3)
                        end
                        for t1=1, l, 1 do
                            table.insert(pureList, v4)
                        end
                        table.insert(temp, pureList)
                        allSum[sum] = temp
                    end
                end
            end
        end

        local function cmp(a, b)
            return a > b
        end
        --对于所有的和 从大到小 检测所有银币从小到大 
        --如果大于则可以取出这些硬币
        local put = nil
        local take = nil
        table.sort(sumList, cmp)

        local c1 = self.computerNum[v1]
        local c2 = self.computerNum[v2]
        local c3 = self.computerNum[v3]
        local c4 = self.computerNum[v4]
        for k, v in ipairs(sumList) do
            if v1 > v and c1 > 0 then
                put = v1
                take = v
                break
            elseif v2 > v and c2 > 0 then
                put = v2
                take = v
                break
            elseif v3 > v and c3 > 0 then
                put = v3
                take = v
                break
            elseif v4 > v and c4 > 0 then
                put = v4
                take = v
                break
            end
        end

        local takeList = allSum[take]
        local rd = math.random(#takeList)
        rd = takeList[rd]
        --放入
        self.aiPut = put
        self.aiTake = rd
        self.inAi = true
        self.aiState = 0

        --根据响应的 coin 做一个move动作
        --[[
        self:putValueIntoPot(Color.BLUE, put)
        self:takeCoinFromPot(Color.BLUE, rd)
        --]]
    end
end

function GameBoard:getPutValue()
    local putCoins = 0
    for k, v in ipairs(self.putList) do
        putCoins = putCoins+v.value
    end
    return putCoins
end
function GameBoard:moveEmptyCoin(value, x, y)
    local allPossible = self:getAllPotValue(value)
    local temp = allPossible[#allPossible]

    temp.bg:setVisible(false)
    self.lastDisappear = temp

    self.curCoin = Coin.new(self, Color.MOVE, value)
    self.coinLayer:addChild(self.curCoin.bg)
    self.curCoin.bg:setPosition(ccp(x, y))
end
function GameBoard:moveOneCoin(value, x, y)
    local allPossible = self:getAllColorCoins(Color.RED, value)
    local temp = allPossible[#allPossible]
    temp.bg:setVisible(false)

    self.lastDisappear = temp

    self.curCoin = Coin.new(self, Color.MOVE, value)
    self.coinLayer:addChild(self.curCoin.bg)
    self.curCoin.bg:setPosition(ccp(x, y))
end
function GameBoard:onMoveEmpty(x, y)
    self.curCoin.bg:setPosition(ccp(x, y))
end
function GameBoard:onTouchMoved(x, y)
    self.curCoin.bg:setPosition(ccp(x, y))
end

function GameBoard:updateValue()
    local putCoins = 0
    for k, v in ipairs(self.putList) do
        putCoins = putCoins+v.value
    end
    local takeCoins = 0
    for k, v in ipairs(self.takeList) do
        takeCoins = takeCoins+v.value
    end
    self.putValue:setString("放入:"..putCoins)
    self.takeValue:setString("取出:"..takeCoins)
end

function GameBoard:takeCoinFromPotValue(color, value)
    if value > 0 then
        local coin = Coin.new(self, color, value)
        self.coinLayer:addChild(coin.bg)

        local allPossible = self:getAllColorCoins(color, value)
        local cr = self.coinOrder[value]
        
        local totalWidth = 623
        local visibleSize = CCDirector:sharedDirector():getVisibleSize()
        local leftMargin = (visibleSize.width-totalWidth)/2
        local bigMargin = 177
        local bottomMargin = 5 
        local smallMargin = 23
        local startX = leftMargin+46+(cr-1)*bigMargin
        local startY = visibleSize.height-(bottomMargin+46)
        if #allPossible < 4 then
            startX = startX + #allPossible*smallMargin
        else
            startX = startX+(#allPossible-4)*smallMargin
            startY = startY-60 
        end
        coin.bg:setPosition(ccp(startX, startY))
        table.insert(self.allCoins, coin)

        self.flyCoin = coin
        self.targetPosition = {startX, startY}

        --移除空coin
        local allPossible = self:getAllPotValue(value)
        local remove = allPossible[#allPossible]
        local x, y = remove.bg:getPosition()
        self.startPosition = {x, y}

        for k, v in ipairs(self.potCoins) do
            if v == remove then
                table.remove(self.potCoins, k)
                break
            end
        end

        self.potNum[value] = self.potNum[value]-1
        remove.bg:removeFromParentAndCleanup(true)
        self.computerNum[value] = self.computerNum[value]+1
    end
end

--使用堆栈保存这些硬币
function GameBoard:takeCoinFromPot(color, list)
    --移除potCoin中的硬币
    --potCoint
    --potNum
    --放入allCoin 硬币
    for k, v in ipairs(list) do
        local value = v
        self:takeCoinFromPotValue(color, value)
    end
end
--如果棋子从框中拿出来了
--放到我方的槽中
function GameBoard:onEndEmpty(x, y)
    local size = self.gameboard:getContentSize()
    local px, py = self.gameboard:getPosition()

    local left = px-size.width/2
    local bottom = py-size.height/2
    local right = px+size.width/2
    local top = py+size.height/2
    
    if x < left or x > right or y < bottom or y > top then
        self.curCoin.color = Color.RED
        local cr = self.coinOrder[self.curCoin.value]
        local allPossible = self:getAllColorCoins(Color.RED, self.curCoin.value)

        local totalWidth = 623
        local visibleSize = CCDirector:sharedDirector():getVisibleSize()
        local leftMargin = (visibleSize.width-totalWidth)/2
        local bigMargin = 177
        local bottomMargin = 5 
        local smallMargin = 23
        local startX = leftMargin+46+(cr-1)*bigMargin
        local startY = bottomMargin+46
        if #allPossible < 4 then
            startX = startX + #allPossible*smallMargin
        else
            startX = startX + (#allPossible-4)*smallMargin
            startY = startY+60
        end
        self.curCoin.bg:setPosition(ccp(startX, startY))
        table.insert(self.allCoins, self.curCoin)
        for k, v in ipairs(self.potCoins) do
            if v == self.lastDisappear then
                table.remove(self.potCoins, k)
                break
            end
        end
        self.potNum[self.curCoin.value] = self.potNum[self.curCoin.value]-1
        self.lastDisappear.bg:removeFromParentAndCleanup(true)
        table.insert(self.takeList, self.curCoin)
        self:updateValue()

        self.okBut:setColor(ccc3(255, 255, 255))
        self.cancel:setColor(ccc3(255, 255, 255))
    else
        self.curCoin.bg:removeFromParentAndCleanup(true)
        self.lastDisappear.bg:setVisible(true)
    end
    self.curCoin = nil
    self.lastDisappear = nil
end
--computer 
function GameBoard:putValueIntoPot(color, value)
    --选择合适的位置 放入新的硬币
    --potNum
    --potCoins
    --移除allCoins 中旧的颜色的硬币
    --allCoins
    --view


    local coin = Coin.new(self, Color.EMPTY, value)
    self.coinLayer:addChild(coin.bg)
    self.flyCoin = coin

    local cr = self.coinOrder[value]
    local allPossible = self:getAllPotValue(value)
    
    local size = self.gameboard:getContentSize()
    local px, py = self.gameboard:getPosition()
    local left = px-size.width/2
    local bottom = py-size.height/2
    local right = px+size.width/2
    local top = py+size.height/2
    local smallMargin = 20
    local bigMargin = 170

    local startX = left+46+(cr-1)*bigMargin 
    local startY = top-60

    if #allPossible < 4 then
        local cx = startX+#allPossible*smallMargin
        local cy = startY
        self.targetPosition = {cx, cy}

        --coin.bg:setPosition(ccp(cx, cy))
        table.insert(self.potCoins, coin)
    else
        local cx = startX+(#allPossible-4)*smallMargin
        local cy = bottom+60
        self.targetPosition = {cx, cy}

        --coin.bg:setPosition(ccp(cx, cy))
        table.insert(self.potCoins, coin)
    end

    self.potNum[value] = self.potNum[value]+1

    --移除这个价值的最后一个
    local lastOne= {}
    for k, v in ipairs(self.allCoins) do
        if v.color == color and v.value == value then
            table.insert(lastOne, v)
        end
    end
    
    --最后一个加入的硬币
    --大堆栈
    local remove = lastOne[#lastOne]
    
    local x, y = remove.bg:getPosition()
    self.startPosition = {x, y}
    for k, v in ipairs(self.allCoins) do
        if v == remove then
            table.remove(self.allCoins, k)
            break
        end
    end
    remove.bg:removeFromParentAndCleanup(true)

    self.computerNum[value] = self.computerNum[value]-1
end




function GameBoard:onTouchEnded(x, y)
    local size = self.gameboard:getContentSize()
    local px, py = self.gameboard:getPosition()
    local left = px-size.width/2
    local bottom = py-size.height/2
    local right = px+size.width/2
    local top = py+size.height/2
    
    local smallMargin = 20
    local bigMargin = 170
    --放下硬币 pot 中硬币增加一个
    --放下的位置
    if x > left and x < right and y > bottom and y < top then
        self.curCoin.color = Color.EMPTY
        local allPossible = self:getAllPotValue(self.curCoin.value)
        local cr = self.coinOrder[self.curCoin.value]

        local startX = left+46+(cr-1)*bigMargin 
        local startY = top-60
        --第一行有空位可以放置
        if #allPossible < 4 then
            local cx = startX+#allPossible*smallMargin
            local cy = startY
            self.curCoin.bg:setPosition(ccp(cx, cy))
            table.insert(self.potCoins, self.curCoin)
        else
            local cx = startX+(#allPossible-4)*smallMargin
            local cy = bottom+60
            self.curCoin.bg:setPosition(ccp(cx, cy))
            table.insert(self.potCoins, self.curCoin)
        end
        self.potNum[self.curCoin.value] = self.potNum[self.curCoin.value]+1
        for k, v in ipairs(self.allCoins) do
            if v == self.lastDisappear then
                table.remove(self.allCoins, k)
                break
            end
        end
        --当前放置列表里面的硬币
        table.insert(self.putList, self.curCoin)
        self:updateValue()

        self.lastDisappear.bg:removeFromParentAndCleanup(true)
        self.lastDisappear = nil

        self.okBut:setColor(ccc3(255, 255, 255))
        self.cancel:setColor(ccc3(255, 255, 255))
    --士兵返回到刚才的位置
    else
        self.curCoin.bg:removeFromParentAndCleanup(true)
        self.curCoin = nil
        self.lastDisappear.bg:setVisible(true)
    end
    self.curCoin = nil
    self.lastDisappear = nil
end
function GameBoard:clearWarn()
    if self.warn ~= nil then
        self.warn:removeFromParentAndCleanup(true)
        self.warn = nil
    end
    print("clear Warn")
end
function GameBoard:showWarn(s)
    self:clearWarn()

    print("showWarn", s)
    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    self.warn = CCLabelTTF:create(s, "", 30, CCSizeMake(500, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    self.hud:addChild(self.warn)
    self.warn:setPosition(ccp(visibleSize.width/2, visibleSize.height/2))
    self.warn:setColor(ccc3(255, 125, 100))
end
