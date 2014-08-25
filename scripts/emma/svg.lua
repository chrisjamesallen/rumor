SVG = Class()


function SVG:init()
    self.data_ = {};
    self.pos = {};
    self.pos.x = 0
    self.pos.y = 0
    self.startPos = {};
    print('svg init');
--    local svg = self:extractSvg();
--    self:convertSvg(svg);
    return self;
end





function SVG:useGPC()
    local verts = {
        1315, 1282,
        1315, 1329,
        1300, 1314,
        1284, 1345,
        1253, 1312,
        1284, 1298,
        1268, 1282,
        1315, 1282
    };
    self:extractSvg()
    local obj = gpc.new():add(verts);
    local data = {};
    self:plottri(data, obj:strip(), 0, 0, 0, 0);
    self:normalizeOutput(data, 2000, 2000);
    print('fofof')
    return data, obj;
end



function SVG:extractSvg()

    -- Mesh: letter H
    local str = "M63.6,0 v206h238.2V0 h64.3v492.4h-64.3V261.5H63.6v230.9H0V0H63.6z"
    -- Mesh: Circle
    str = "M137.6,0c0,0,-110.1,298.9,-20.1,352.1 C229.1,418.1,419.6,193.9,137.6,0z"
    -- Mesh: wierd blob
    str = "M597.3,561.9l-213.9-62.1 l-172.5,141 l-7-222.7 L16.5,297.6 l209.6-75.5 L282.7,6.7 c0,0,70.2,125.1,136.6,176 L641.7,170 L516.5,354.3 L597.3,561.9z"

    --split operations by spliting by letters
    local pattern = "(%D)(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*)%s?"

    local operations = {}
    for command, x1, y1, x2, y2, x3, y3 in string.gmatch(str, pattern) do
        if (command == "z" or command == "Z") then
            break
        end
        local d = {}
        d = {
            tonumber(x1) or 0,
            tonumber(y1) or 0,
            tonumber(x2) or 0,
            tonumber(y2) or 0,
            tonumber(x3) or 0,
            tonumber(y3) or 0
        }
        d["command"] = command;
        _.push(operations, d)
    end
    print(inspect(operations))

    return operations;
end


function SVG:plottri(f, p, r, g, b, command)
    --if command=="stroke" then output(f,0,"setlinewidth") end
    for c = 1, p:get() do

        local n = p:get(c)
        local x1, y1 = p:get(c, 1)
        local x2, y2 = p:get(c, 2)
        for i = 3, n do
            local x, y = p:get(c, i)
            output(f, x1, y1, "moveto")
            output(f, x2, y2, "lineto")
            output(f, x, y, "lineto")
            --output(f,"closepath")
            x1, y1, x2, y2 = x2, y2, x, y
        end
    end
end

function output(data, x, y, command)
    _.push(data, x)
    _.push(data, y)
    _.push(data, 0)
end

function SVG:normalizeOutput(data, w, h)
    -- normalize here
    local maxX = w or 800
    local maxY = h or 800
    local min = 0
    -- inverse to follow top left origin
    for k, v in pairs(data) do
        local n = v --between 0 and 1
        if (k % 3 == 1) then
            n = (v - min) / (maxX - min)
            n = ((n * 2) - 1)
            -- so zero x should be -1
        end
        if (k % 3 == 2) then
            n = (v - min) / (maxY - min)
            n = -((n * 2) - 1)
            -- so zero y should be -1
        end

        data[k] = n
    end
end



function SVG:convertSvg(operations)
    _.each(operations, function(i)
        if i.command == 'M' then self:moveTo(i[1], i[2]) end
        --lineto
        if i.command == 'L' then self:lineTo(i[1], i[2], i.command) end
        if i.command == 'i' then self:lineToRelative(i[1], i[2], i.command) end
        --h line
        if i.command == 'h' then self:lineToRelative(i[1], 0, i.command) end
        if i.command == 'H' then self:lineTo(i[1], self.pos.y, i.command) end -- y param
        -- v line
        if i.command == 'v' then self:lineToRelative(0, i[1], i.command) end
        if i.command == 'V' then self:lineTo(self.pos.x, i[1], i.command) end -- x param
        -- Cubic curveto C (c)
        if i.command == 'c' then self:curveToRelative(i[1], i[2], i[3], i[4], i[5], i[6]) end
        if i.command == 'C' then self:curveTo(i[1], i[2], i[3], i[4], i[5], i[6]) end
        -- Cubic shorthand curveto S (s)
        if i.command == 's' then self:smoothCurveToRelative(0, i[1], i.command) end
        if i.command == 'S' then self:smoothCurveTo(self.pos.x, i[1], i.command) end
    end)

    self:closePath();
end

-- convert svg to points at first
-- create triangles for each quadratic curve

function SVG:curveTo(x1, y1, x2, y2, x3, y3)
    local x, y = 0
    _.push(self.data_, { self.pos.x, self.pos.y, 0 })
    x = x1
    y = y1
    _.push(self.data_, { x, y, 0 })
    x = x2
    y = y2
    _.push(self.data_, { x, y, 0 })
    x = x3
    y = y3
    _.push(self.data_, { x, y, 0 })
    self.pos.x = x3
    self.pos.y = y3
end

function SVG:curveToRelative(x1, y1, x2, y2, x3, y3)
    local x, y = 0
    -- end point 1
    _.push(self.data_, { self.pos.x, self.pos.y, 0 })

    -- control point 1
    x = self.pos.x + x1
    y = self.pos.y + y1
    _.push(self.data_, { x, y, 0 })

    -- control point 2
    x = self.pos.x + x2
    y = self.pos.y + y2
    _.push(self.data_, { x, y, 0 })

    -- end point 2
    x = self.pos.x + x3
    y = self.pos.y + y3
    _.push(self.data_, { x, y, 0 })

    self.pos.x = x3
    self.pos.y = y3
end

function SVG:smoothToRelative(x1, y1, x2, y2, x3, y3, x4, y4)
    local x, y = 0
    -- end point 1
    _.push(self.data_, { self.pos.x, self.pos.y, 0 })

    -- control point 1
    x = self.pos.x + x1
    y = self.pos.y + y1
    _.push(self.data_, { x, y, 0 })

    -- control point 2
    x = self.pos.x + x1
    y = self.pos.y + y1
    _.push(self.data_, { x, y, 0 })

    -- end point 2
    x = self.pos.x + x3
    y = self.pos.y + y3
    _.push(self.data_, { x, y, 0 })

    self.pos.x = x2
    self.pos.y = y2
end


function SVG:moveTo(x, y)
    if (self.pos.started == nil) then
        self.pos.started = true
        self.startPos.x = x;
        self.startPos.y = y;
    end
    self.pos.x = x;
    self.pos.y = y;
    self:lineTo(x, y)
end

function SVG:lineTo(x, y, r)
    --print(r,x,y)
    --print('\npoint',r,x,y)
    _.push(self.data_, { x, y, 0 })
    self.pos.x = x;
    self.pos.y = y;
end

function SVG:lineToRelative(x, y, r)
    -- print('\nrel',r,x,y)
    --print(r,x,y)
    self.pos.x = self.pos.x + x
    self.pos.y = self.pos.y + y
    _.push(self.data_, { self.pos.x, self.pos.y, 0 })
end



function SVG:smoothCurveToRelative(x1, y1, x2, y2, x3, y3, x4, y4)
end

function SVG:smoothCurveTo(x1, y1, x2, y2, x3, y3, x4, y4)
end


function SVG:closePath()
    --close path
    self:lineTo(self.startPos.x, self.startPos.y)
    print('data before normalize:', inspect(self.data_))
    self.data_ = _.flatten(self.data_)
    local maxX = 800
    local maxY = 800
    local min = 0
    -- inverse to follow top left origin
    for k, v in pairs(self.data_) do
        local n = v --between 0 and 1
        if (k % 3 == 1) then
            n = (v - min) / (maxX - min)
            n = ((n * 2) - 1)
            -- so zero x should be -1
        end
        if (k % 3 == 2) then
            n = (v - min) / (maxY - min)
            n = -((n * 2) - 1)
            -- so zero y should be -1
        end

        self.data_[k] = n
        --print(k,self.data_[k])
    end
    print('data>>>')
end
