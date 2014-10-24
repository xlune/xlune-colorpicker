class Main
    constructor: (root) ->
        @root = root or document;
        @_initVars();
        @_initObject()
        @_setControllEvents()
        @_setColorEvents()
        @_setBrightnesEvents()
        @_changeDisplay()

    _initVars: =>
        @_colorHSB = [0, 255, 255]
        @_colorRGB = [255, 0, 0]

    _initObject: =>
        @_window = $(window)
        @_colorBase = $(@root.querySelector('#colorBase'))
        @_colorPallet = $(@root.querySelector('#colorPalette'))
        @_brightnessSelector = $(@root.querySelector('#brightnessSelector'))
        @_colorSelector = $(@root.querySelector('#colorSelector'))
        @_colorBrightnes = $(@root.querySelector('#brightnessBox'))
        @_colorSelected = $(@root.querySelector('#selectColor'))
        @_colorCurrent = $(@root.querySelector('#currentColor'))
        @_textR = $(@root.querySelector('#colorR'))
        @_textG = $(@root.querySelector('#colorG'))
        @_textB = $(@root.querySelector('#colorB'))
        @_textHex = $(@root.querySelector('#colorHex'))
        @_colorButton = $(@root.querySelector('#colorButton'))
        @_closeButton = $(@root.querySelector('#closeButton'))
        @_inputs = $(@root.querySelector('#inputForm input'))

    _setControllEvents: =>
        @_colorButton.on 'click', @_open
        @_inputs.on 'change', (e) =>
            @_editTarget = e.target.id
            @_updateInputToDisplay()
            @_resetInput()
            @_editTarget = null
        isInDown = false
        @_colorPallet.on 'mousedown', (e) =>
            isInDown = true
        @_colorPallet.on 'click', (e) =>
            e.preventDefault()
            e.stopPropagation()
            isInDown = false
        @_window.on 'click', (e) =>
            unless isInDown
                @_close()
            isInDown = false
        @_colorCurrent.on 'click', (e) =>
            @_textHex.val(@_colorCurrent.data('val'))
            @_editTarget = 'colorHex'
            @_updateInputToDisplay()
            @_resetInput()
            @_editTarget = null
        @_closeButton.on 'click', (e) =>
            @_close()


    _setColorEvents: =>
        @_colorSelector
            .on 'mousedown', (e) =>
                e.preventDefault()
        isMouseDown = false
        activeIds = ['baseColorImage', 'selectorColorImage']
        @_colorBase
            .on 'mousedown', (e) =>
                e.preventDefault()
                @_changeBaseColor(e.offsetY)
                isMouseDown = true
            .on 'mousemove', (e) =>
                e.preventDefault()
                if isMouseDown and e.target.id in activeIds
                    @_changeBaseColor(e.offsetY)
        @_window.on 'mouseup', (e) =>
            e.preventDefault()
            isMouseDown = false

    _setBrightnesEvents: =>
        isMouseDown = false
        activeIds = ['baseImage', 'selectorImage']
        @_brightnessSelector
            .on 'mousedown', (e) =>
                e.preventDefault()
            .on 'mousemove', (e) =>
                e.preventDefault()
            .on 'mouseup', (e) =>
                e.preventDefault()
        @_colorBrightnes
            .on 'mousedown', (e) =>
                e.preventDefault()
                if e.target.id is 'selectorImage'
                    e.offsetX += parseInt(@_brightnessSelector.css('left'), 10) - 8
                    e.offsetY += parseInt(@_brightnessSelector.css('top'), 10) - 8
                @_changeBrightnes(e.offsetX, e.offsetY)
                isMouseDown = true
            .on 'mousemove', (e) =>
                e.preventDefault()
                if e.target.id is 'selectorImage'
                    e.offsetX += parseInt(@_brightnessSelector.css('left'), 10) - 8
                    e.offsetY += parseInt(@_brightnessSelector.css('top'), 10) - 8
                if isMouseDown and e.target.id in activeIds
                    @_changeBrightnes(e.offsetX, e.offsetY)
        @_window.on 'mouseup', (e) =>
            e.preventDefault()
            isMouseDown = false
        return

    _listenForm: =>
        r = @_textR.val()
        g = @_textR.val()
        b = @_textR.val()
        unless 0 <= r <= 255 then return
        unless 0 <= g <= 255 then return
        unless 0 <= b <= 255 then return
        return

    _startFormCycle: =>
        @_timer = setInterval @_listenForm, 300
        return

    _stopFormCycle: =>
        clearInterval @_timer
        return

    _changeBaseColor: (num) =>
        colorNum = Math.max(Math.min(num, 255), 0)
        @_colorSelector.css('top', colorNum)
        @_colorHSB[0] = (360 - (colorNum / 255 * 360)) % 360
        @_changeDisplay()

    _changeBrightnes: (xx ,yy) =>
        @_colorHSB[1] = Math.max(Math.min(xx, 255), 0)
        @_colorHSB[2] = 255 - Math.max(Math.min(yy, 255), 0)
        @_changeDisplay()

    _changeDisplay: =>
        @_colorRGB = @_hsbToRgb(@_colorHSB)
        hex = @_getHexString(@_colorRGB)
        rgb = @_hsbToRgb([@_colorHSB[0], 255, 255])
        @_colorBrightnes.css 'background-color', "##{@_getHexString(rgb)}"
        @_colorSelected.css 'background-color', "##{hex}"
        @_colorButton.css 'background-color', "##{hex}"
        @_colorButton.data 'val', hex

        @_textR.val parseInt(@_colorRGB[0], 10)
        @_textG.val parseInt(@_colorRGB[1], 10)
        @_textB.val parseInt(@_colorRGB[2], 10)
        @_textHex.val hex
        @_textR.data 'val', @_textR.val()
        @_textG.data 'val', @_textG.val()
        @_textB.data 'val', @_textB.val()
        @_textHex.data 'val', hex

        hPos = ((360 - @_colorHSB[0]) / 360 * 255) % 255
        if hPos is 0 and parseInt(@_colorSelector.css('top'), 10) >= 128
            hPos = 255
        @_colorSelector.css 'top', "#{hPos}px"
        @_brightnessSelector.css 'left', "#{@_colorHSB[1]}px"
        @_brightnessSelector.css 'top', "#{255 - @_colorHSB[2]}px"

    getCurrentHex: =>
        return @_getHexString(@_colorRGB)

    _getHexString: (rgb) =>
        r = parseInt(rgb[0], 10).toString(16)
        r = '0' + r if r.length is 1
        g = parseInt(rgb[1], 10).toString(16)
        g = '0' + g if g.length is 1
        b = parseInt(rgb[2], 10).toString(16)
        b = '0' + b if b.length is 1
        return "#{r}#{g}#{b}"

    _updateInputToDisplay: =>
        switch @_editTarget
            when 'colorR'
                val = parseInt(@_textR.val(), 10)
                if !isNaN(val) and 0 <= val <= 255
                    @_textR.data 'val', val
            when 'colorG'
                val = parseInt(@_textG.val(), 10)
                if !isNaN(val) and 0 <= val <= 255
                    @_textG.data 'val', val
            when 'colorB'
                val = parseInt(@_textB.val(), 10)
                if !isNaN(val) and 0 <= val <= 255
                    @_textB.data 'val', val
            when 'colorHex'
                val = @_textHex.val()
                if val.match(/^([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/)
                    arr = val.split('')
                    if arr.length is 3
                        arr.splice 1, 0, arr[0]
                        arr.splice 3, 0, arr[2]
                        arr.splice 5, 0, arr[4]
                    @_textR.data 'val', parseInt("#{arr[0]}#{arr[1]}", 16)
                    @_textG.data 'val', parseInt("#{arr[2]}#{arr[3]}", 16)
                    @_textB.data 'val', parseInt("#{arr[4]}#{arr[5]}", 16)
        rgb = [
            parseInt(@_textR.data('val'), 10)
            parseInt(@_textG.data('val'), 10)
            parseInt(@_textB.data('val'), 10)
        ]
        @_colorHSB = @_rgbToHsb rgb
        @_changeDisplay()
        return

    _resetInput: =>
        @_textR.val(@_textR.data('val'))
        @_textG.val(@_textG.data('val'))
        @_textB.val(@_textB.data('val'))
        @_textHex.val(@_textHex.data('val'))

    _hsbToRgb: (hsb) =>
        rgb = [0, 0, 0]
        max = hsb[2]
        min = max - ((hsb[1] / 255) * max)
        h = hsb[0]
        switch true
            when h <= 60
                rgb[0] = max
                rgb[1] = (h / 60) * (max - min) + min
                rgb[2] = min
            when h <= 120
                rgb[0] = ((120 - h) / 60) * (max - min) + min
                rgb[1] = max
                rgb[2] = min
            when h <= 180
                rgb[0] = min
                rgb[1] = max
                rgb[2] = ((h - 120) / 60) * (max - min) + min
            when h <= 240
                rgb[0] = min
                rgb[1] = ((240 - h) / 60) * (max - min) + min
                rgb[2] = max
            when h <= 300
                rgb[0] = ((h - 240) / 60) * (max - min) + min
                rgb[1] = min
                rgb[2] = max
            when h <= 360
                rgb[0] = max
                rgb[1] = min
                rgb[2] = ((360 - h) / 60) * (max - min) + min
        return rgb

    _rgbToHsb: (rgb) =>
        hsb = [0, 0, 0]
        min = Math.min.apply(null, rgb)
        max = Math.max.apply(null, rgb)
        if rgb[0] == rgb[1] == rgb[2]
            hsb[0] = 0
        else
            for val,i in rgb
                if val is max
                    switch i
                        when 0
                            hsb[0] = 60 * ((rgb[1] - rgb[2]) / (max - min))
                        when 1
                            hsb[0] = 60 * ((rgb[2] - rgb[0]) / (max - min)) + 120
                        when 2
                            hsb[0] = 60 * ((rgb[0] - rgb[1]) / (max - min)) + 240
                    break
        hsb[0] = (hsb[0] + 360) % 360
        hsb[1] = (max - min) / max * 255
        hsb[2] = max
        return hsb

    _open: (e) =>
        if e
            e.preventDefault()
            e.stopPropagation()
        if @_colorPallet.is(':visible')
            @_close()
        else
            @_colorCurrent.data 'val', @_colorButton.data('val')
            @_colorCurrent.css 'background-color', "##{@_colorCurrent.data('val')}"
            @_colorPallet.show()
        return

    _close: =>
        @_colorPallet.hide()
        return


new Main()
