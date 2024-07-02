-- MCM
local modName = "Goals"

local defaultConfig = {
    enabled = true,
    popupAfterChargen = true
}
local configFile = modName
local config = mwse.loadConfig(configFile, defaultConfig)

local goalsMenuId = tes3ui.registerID("goalsMenu")
local descriptionHeaderId = tes3ui.registerID("goalDescriptionHeaderText")
local descriptionTextId = tes3ui.registerID("goalDescriptionText")

-- Store goals data 
-- per character/save
local tempGoalsList = { 
    { name = "Fish 50 boots", 
      description = "Be unlucky enough to fish 50 pairs of boots using Ultimate Fishing. Relax and enjoy the old school experience." 
    },
    { name = "Make friends with M'aiq", 
      description = "M'aiq seems like he could use a friend. Maybe you could be that friend." 
    },
 }

local goalData

local function registerModConfig()
    local template = mwse.mcm.createTemplate({ name = modName, config = config, defaultConfig = defaultConfig, showDefaultSetting = true })
    template:saveOnClose(configFile, config)

    local settings = template:createSideBarPage({ label = "Settings" })

    settings:createYesNoButton({ label = "Enable mod", configKey = "enabled" })

    settings:createYesNoButton({ label = "Show menu after chargen", configKey = "popupAfterChargen" })

    template:register()
end
event.register(tes3.event.modConfigReady, registerModConfig)

-- Create goals menu
local okayButton

local function clickedOkay(goalsMenu)
    -- if data.currentBackground then
    --     event.unregister("simulate", startBackgroundWhenChargenFinished)
    --     event.register("simulate", startBackgroundWhenChargenFinished)
    -- end
    goalsMenu:destroy()
    tes3ui.leaveMenuMode()
    --data.inBGMenu = false
    --event.trigger("Goals:OkayMenuClicked")
end

local function clickedGoal(goal)
    -- data.currentSelectedGoal = goal.name
    local header = tes3ui.findMenu(goalsMenuId):findChild(descriptionHeaderId)
    header.text = goal.name

    local description = tes3ui.findMenu(goalsMenuId):findChild(descriptionTextId)
    description.text = goal.description
    description:updateLayout()

    -- if not backgroundsList[data.currentBackground] then
    --     return
    -- end

    -- if backgroundsList[data.currentBackground].checkDisabled and backgroundsList[data.currentBackground].checkDisabled() then
    --     header.color = tes3ui.getPalette("disabled_color")
    --     okayButton.widget.state = 2
    --     okayButton.disabled = true
    -- else
    --     header.color = tes3ui.getPalette("header_color")
    --     okayButton.widget.state = 1
    --     okayButton.disabled = false
    -- end

end

local function createGoalsMenu()
    local goalsMenu = tes3ui.createMenu{ id = goalsMenuId, fixedFrame = true }
    local outerBlock = goalsMenu:createBlock()
    outerBlock.flowDirection = "top_to_bottom"
    outerBlock.autoHeight = true
    outerBlock.autoWidth = true

    local title = outerBlock:createLabel{ text = "Choose a goal"}
    title.absolutePosAlignX = 0.5
    title.borderTop = 4
    title.borderBottom = 4
    title.color = tes3ui.getPalette("header_color")

    local navigationBlock = outerBlock:createBlock()
    navigationBlock.minWidth = 500
    navigationBlock.flowDirection = "left_to_right"
    navigationBlock.widthProportional = 1.0
    navigationBlock.autoHeight = true

    local activeGoalsButton = navigationBlock:createButton{ text = "Active Goals" }
    local addGoalButton = navigationBlock:createButton{ text = "Add Goal" }
    local goalListsButton = navigationBlock:createButton{ text = "Goal Lists" }
    local randomGoalButton = navigationBlock:createButton{ text = "Random Goal" }

    local innerBlock = outerBlock:createBlock()
    innerBlock.height = 350
    innerBlock.autoWidth = true
    innerBlock.flowDirection = "left_to_right"

    local activeGoalListBlock = innerBlock:createVerticalScrollPane{}
    activeGoalListBlock.minWidth = 300
    activeGoalListBlock.autoWidth = true
    activeGoalListBlock.paddingAllSides = 4
    activeGoalListBlock.borderRight = 6

    for i, goal in ipairs(tempGoalsList) do
        local goalButton = activeGoalListBlock:createTextSelect{ text = goal.name }
        goalButton.autoHeight = true
        goalButton.layoutWidthFraction = 1.0
        goalButton.paddingAllSides = 2
        goalButton.borderAllSides = 2

        goalButton:register("mouseClick", function()
            clickedGoal(goal)
        end )

    end

    local descriptionBlock = innerBlock:createThinBorder()
    descriptionBlock.layoutHeightFraction = 1.0
    descriptionBlock.width = 300
    descriptionBlock.borderRight = 10
    descriptionBlock.flowDirection = "top_to_bottom"
    descriptionBlock.paddingAllSides = 10

    local descriptionHeader = descriptionBlock:createLabel{ id = descriptionHeaderId, text = ""}
    descriptionHeader.color = tes3ui.getPalette("header_color")

    local descriptionText = descriptionBlock:createLabel{ id = descriptionTextId, text = "" }
    descriptionText.wrapText = true

    -- Bottom button block
    local bottomButtonBlock = outerBlock:createBlock()
    bottomButtonBlock.flowDirection = "left_to_right"
    bottomButtonBlock.widthProportional = 1.0
    bottomButtonBlock.autoHeight = true
    bottomButtonBlock.childAlignX = 1.0

    --OKAY
    okayButton = bottomButtonBlock:createButton{ id = tes3ui.registerID("goalOkayButton"), text = tes3.findGMST(tes3.gmst.sOK).value }
    okayButton.alignX = 1.0
    okayButton:register("mouseClick", function()
            clickedOkay(goalsMenu)
    end)

    goalsMenu:updateLayout()
    tes3ui.enterMenuMode(goalsMenuId)
end
event.register("Goals:OpenGoalsMenu", function() createGoalsMenu() end)

-- Add Goals section to character sheet
-- Get and display goal summary
local goalStatUID = tes3ui.registerID("GoalNameStatUI")

local function updateGoalStat()
    local menu = tes3ui.findMenu(tes3ui.registerID("MenuStat"))

    if menu then
        local goalLabel = menu:findChild(goalStatUID)
        --if data and data.currentGoal then
          goalLabel.text = "Fish 50 pairs of boots"
        --else
            -- goalLabel.text = "None"
        --end
        menu:updateLayout()
    end
end
event.register("menuEnter", updateGoalStat)

-- Create the tooltip when hovering over the active goal
local function createGoalTooltip()
    --if data.currentGoal then
        local tooltip = tes3ui.createTooltipMenu()
        local outerBlock = tooltip:createBlock()
        outerBlock.flowDirection = "top_to_bottom"
        outerBlock.paddingTop = 6
        outerBlock.paddingBottom = 12
        outerBlock.paddingLeft = 6
        outerBlock.paddingRight = 6
        outerBlock.width = 400
        outerBlock.autoHeight = true

        local header = outerBlock:createLabel{
            --text = goal.name
            text = "Fish 50 pairs of boots"
        }
        header.absolutePosAlignX = 0.5
        header.color = tes3ui.getPalette("header_color")


        local description = outerBlock:createLabel{
            --text = getDescription(goal)
            text = "Be unlucky enough to fish 50 pairs of boots using Ultimate Fishing. Relax and enjoy the old school experience."
        }
        description.autoHeight = true
        description.width = 285
        description.wrapText = true

        tooltip:updateLayout()
    --end
end


-- Create the goal block on the stats menu ui
local function createGoalStat(e)
    local goalHeadingText = "Goal"

    local GUI_Goal_Stat = tes3ui.registerID(GUI_MenuStat_Goal_Stat)

    local menu = e.element
    local charBlock = menu:findChild(tes3ui.registerID("MenuStat_level_layout")).parent

    local goalBlock = charBlock:findChild(GUI_Goal_Stat)
    if goalBlock then goalBlock:destroy() end

    goalBlock = charBlock:createBlock({ id = GUI_Goal_Stat })
    goalBlock.widthProportional = 1.0
    goalBlock.autoHeight = true
    
    local goalHeadingLabel = goalBlock:createLabel{ text = goalHeadingText }
    goalHeadingLabel.color = tes3ui.getPalette("header_color")

    local nameBlock = goalBlock:createBlock()
    nameBlock.paddingLeft = 5
    nameBlock.autoHeight = true
    nameBlock.widthProportional = 1.0

    local nameLabel = nameBlock:createLabel{ id = goalStatUID, text = "None" }
    nameLabel.wrapText = true
    nameLabel.widthProportional = 1.0
    nameLabel.justifyText = "right"

    goalHeadingLabel:register("help", createGoalTooltip )
    nameBlock:register("help", createGoalTooltip )
    nameLabel:register("help", createGoalTooltip )
    nameLabel:register("mouseClick", createGoalsMenu )

    menu:updateLayout()

end
event.register("uiActivated", createGoalStat, { filter = "MenuStat" })

-- New menu to set Goals text

-- popup after chargen

-- Randomly generate x
-- Copy to clipboard