function GameBoard:ctor(kind)
    local function onButton()
    local function onCancel()
function GameBoard:update(diff)
function GameBoard:getAllColorCoins(color, value)
    local function cmp(a, b)
function GameBoard:putRed(value)
function GameBoard:getAllPotValue(value)
    local function cmp(a, b)
function GameBoard:takeEmpty(value)
function GameBoard:takeRed(value)
function GameBoard:putEmpty(value)
function GameBoard:checkEnd()
function GameBoard:doAI()
        local function cmp(a, b)
        local function cmp(a, b)
function GameBoard:getPutValue()
function GameBoard:moveEmptyCoin(value, x, y)
    local function cmp(a, b)
function GameBoard:moveOneCoin(value, x, y)
    local function cmp(a, b)
function GameBoard:onMoveEmpty(x, y)
function GameBoard:onTouchMoved(x, y)
function GameBoard:updateValue()
function GameBoard:takeCoinFromPotValue(color, value)
        local function cmp(a, b)
function GameBoard:takeCoinFromPot(color, list)
            local function cmp(a, b)
function GameBoard:onEndEmpty(x, y)
function GameBoard:putValueIntoPot(color, value)
function GameBoard:onTouchEnded(x, y)
function GameBoard:clearWarn()
function GameBoard:showWarn(s)