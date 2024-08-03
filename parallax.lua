local info = Dialog("INFO")
    :label { text = "for more info & tutorial video:" }
    :label { text = "https://github.com/busra-nur-bahadir" }
    :newrow()

local dlg = Dialog { title = "Parallax Animation" }
local selectedDirection = nil
local directionMap = {
    [utf8.char(0x2196)] = { x = -1, y = -1 },
    ["↑"] = { x = 0, y = -1 },
    [utf8.char(0x2197)] = { x = 1, y = -1 },
    ["←"] = { x = -1, y = 0 },
    ["0"] = { x = 0, y = 0 },
    ["→"] = { x = 1, y = 0 },
    [utf8.char(0x2199)] = { x = -1, y = 1 },
    ["↓"] = { x = 0, y = 1 },
    [utf8.char(0x2198)] = { x = 1, y = 1 }
}

local buttonWidth = 60
local buttonHeight = 30

dlg:button {
    id = "info",
    text = "?",
    width = buttonWidth,
    height = buttonHeight,
    onclick = function()
        info:show()
    end
}

dlg:newrow()
dlg:label { text = "Frame Number to Animate:" }
dlg:newrow()
dlg:number {
    id = "frameNum",
    text = "10",
    width = 200,
    height = 30,
}

dlg:label { text = "Frame Speed for loop: " }
dlg:newrow()
dlg:number {
    id = "frameSpeed",
    text = "10",
    width = 200,
    height = 30,
}

local directionOrder = {
    utf8.char(0x2196), "↑", utf8.char(0x2197),
    "←", "0", "→",
    utf8.char(0x2199), "↓", utf8.char(0x2198)
}

function createDirectionButtons()
    local buttonsPerRow = 3
    local buttonIndex = 0

    for _, dir in ipairs(directionOrder) do
        dlg:button {
            id = dir,
            text = dir,
            width = buttonWidth,
            height = buttonHeight,
            onclick = function()
                selectedDirection = dir
            end
        }

        buttonIndex = buttonIndex + 1

        if buttonIndex % buttonsPerRow == 0 then
            dlg:newrow()
        end
    end
end

createDirectionButtons()
dlg:newrow()

dlg:button {
    id = "createFrames",
    text = "Create Animation",
    focus = false,
    onclick = function()
        local frameSpeed = dlg.data.frameSpeed
        local directionVec = directionMap[selectedDirection]

        if not selectedDirection then
            app.alert("No direction selected.")
            return
        end

        if not app.activeSprite then
            app.alert("No active sprite.")
            return
        end

        local sprite = app.activeSprite
        local layer = app.layer

        if not layer then
            app.alert("No layer selected.")
            return
        end


        local currentFrameIndex = app.activeFrame.frameNumber
        local cel = layer:cel(currentFrameIndex)

        if not cel then
            app.alert("No cel found in the current frame.")
            return
        end

        local spriteWidth = sprite.width
        local spriteHeight = sprite.height
        local imageWidth = cel.image.width
        local imageHeight = cel.image.height

        local newFrames = {}
        local cels = {}

        for i = 1, dlg.data.frameNum do
            local frameIndex = currentFrameIndex + i
            local newFrame = sprite.frames[frameIndex]


            if not newFrame then
                newFrame = sprite:newFrame()
                table.insert(newFrames, newFrame)
            end

            local newX = (cel.position.x + frameSpeed * i * directionVec.x) % spriteWidth
            local newY = (cel.position.y + frameSpeed * i * directionVec.y) % spriteHeight

            if newX < 0 then
                newX = newX + spriteWidth
            end
            if newY < 0 then
                newY = newY + spriteHeight
            end

            local newImage = Image(spriteWidth * 2, spriteHeight * 2)
            newImage:drawImage(cel.image, Point(newX, newY))


            if newX + imageWidth > spriteWidth then
                newImage:drawImage(cel.image, Point(newX - spriteWidth, newY))
            end

            if newY + imageHeight > spriteHeight then
                newImage:drawImage(cel.image, Point(newX, newY - spriteHeight))
            end


            if newX + imageWidth > spriteWidth and newY + imageHeight > spriteHeight then
                newImage:drawImage(cel.image, Point(newX - spriteWidth, newY - spriteHeight))
            end

            local newCel = sprite:newCel(layer, newFrame, newImage, Point(0, 0))
            table.insert(cels, newCel)
        end
        app.refresh()
        dlg:close()
    end
}

dlg:button {
    id = "cancel",
    text = "CANCEL",
    onclick = function()
        dlg:close()
    end
}

dlg:show { wait = false }
