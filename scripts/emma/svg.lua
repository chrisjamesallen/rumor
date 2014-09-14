SVG = Class()
local test = "M276.8,226.6 h-180 V112.3C96.8,112.3,275.2,91.7,276.8,226.6z";
test = "M96.8,112.3c74-33.6,163.3-21.6,180,114.2h-180V112.3";
test = "M96.8,112.3c267.3,19.8,163.3-21.6,180,114.2h-180V112.3"
--test = "M105.4,272c0.4,25.7,16.9,36.3,35.9,36.3c13.6,0,21.8-2.4,29-5.4l3.2,13.6c-6.7,3-18.2,6.5-34.8,6.5c-32.2,0-51.4-21.2-51.4-52.7s18.6-56.4,49.1-56.4c34.2,0,43.2,30,43.2,49.3c0,3.9-0.4,6.9-0.7,8.9H105.4z M161.2,258.4c0.2-12.1-5-30.9-26.4-30.9c-19.2,0-27.7,17.7-29.2,30.9H161.2z"
test = "M47.8,110.8l25.3-40.4c0,0,93.9,22.6,52,37.8c-43.1,15.7-7.1,69.3-7.1,69.3l-65.3-2.7L47.8,110.8z"


function SVG:init()
    self.data_ = {};
    self.pos = {};
    self.pos.x = 0
    self.pos.y = 0
    self.startPos = {};
    self.paths = {};
    return self; --
end

function SVG:extractToPoints(svgStr)
    return self:extract(svgStr)
end

function SVG:extract(svgStr)
    print("\n\nSvg:Extract:\n", svgStr, "\n")
    local operations = {}
    local pattern = "(%D)(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*)%s?"
    self:openSubPath()
    for command, x1, y1, x2, y2, x3, y3 in string.gmatch(svgStr, pattern) do
        if (command == "z" or command == "Z") then
            self:closeSubPath(operations)
            self:openSubPath()
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

    self.data_index = self.data_index -1
    _.pop(self.paths)
    self:triangulate()
    return self.data_
end


function SVG:createBasicFill()
    -- just take the points and render  and triangulate into on set of data


end

function SVG:openSubPath(operations)
    --add to paths array
    print("open subpath")
    local path = {}
    _.push(self.paths, path)
    self.data_ = path
    self.data_index = #self.paths
end

function SVG:closeSubPath(operations)
    if (#operations == 0) then
        return nil
    end
    self:convertSvgCommands(operations)
    self:lineTo(self.startPos.x, self.startPos.y)
    self.data_ = _.flatten(self.data_)
    self.paths[self.data_index] = self.data_
    local maxX = 500
    local maxY = 500
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
    print('\ndata>>>', inspect(self.data_))
    return self.data_
end

function SVG:convertSvgCommands(operations)

    _.each(operations, function(i)
        if i.command == 'M' then self:moveTo(i[1], i[2]) end
        --lineto
        if i.command == 'L' then self:lineTo(i[1], i[2], i.command) end
        if i.command == 'l' then self:lineToRelative(i[1], i[2], i.command) end
        --h line
        if i.command == 'h' then self:lineToRelative(i[1], 0, i.command) end
        if i.command == 'H' then self:lineTo(i[1], self.pos.y, i.command) end -- y param
        -- v line
        if i.command == 'v' then self:lineToRelative(0, i[1], i.command) end
        if i.command == 'V' then self:lineTo(self.pos.x, i[1], i.command) end -- x param
        -- Cubic curveto C (c)
        if i.command == 'c' then self:plotCurveRel(i[1], i[2], i[3], i[4], i[5], i[6]) end
        if i.command == 'C' then self:plotCurve(i[1], i[2], i[3], i[4], i[5], i[6]) end
        -- Cubic shorthand curveto S (s)
        if i.command == 's' then self:smoothCurveToRelative(i[1], i[2], i[3], i[4]) end
        if i.command == 'S' then self:smoothCurveTo(i[1], i[2], i[3], i[4]) end
    end)
end

function SVG:triangulate()
    local subPath = 0
    local subPaths = {}
    local t
    _.each(self.paths , function(data)
        local data_ = _.flatten(data)
        subPath = subPath + 1
        if (_.is_empty(data) == false) then
            local a = 0
            data_ = _.select(data_, function(i) a = a + 1; return a % 3 ~= 0 end)
            t = gpc.new():add(data_)
            _.push(subPaths,t)
        end
    end)

    local pool = {};
    local p = _.first(subPaths)
    _.each(_.rest(subPaths), function(path)
        p =  p*path;
    end)

    --[[
    local b = gpc.new():add({
        -0.77494718933105, 0.44803033447266,
        0, 0,
        1, 1
    })

    p = p-b  --]]
    self:plottri(pool, p:strip(), 0, 0, 0, 0);
    self.data_ = pool
    self.vertices = math.ceil(#pool / 3) -- this is cause there are three points to each vertex
    self.points = #self.data_
end

--[[
  Plot functions
-- --]]

function SVG:moveTo(x, y)
    print("moveto", x, y)
    if (self.pos.started == nil) then
        self.pos.started = true
        self.startPos.x = x;
        self.startPos.y = y;
    end
    self.pos.x = x;
    self.pos.y = y;
    self.pos.cx = x
    self.pos.cy = y
end

function SVG:lineTo(x, y, r)
    print("L--lineTo result:", x, y)
    _.push(self.data_, { x, y, 0 })
    self.pos.x = x;
    self.pos.y = y;
    self.pos.cx = x
    self.pos.cy = y
end


function SVG:lineToRelative(x, y, r)
    print("l--lineToRelative:", x, y,
        "\n ~ start pos", self.pos.x, self.pos.y,
        "result:", self.pos.x + x, self.pos.y + y)
    self.pos.x = self.pos.x + x
    self.pos.y = self.pos.y + y
    self.pos.cx = self.pos.x
    self.pos.cy = self.pos.y
    _.push(self.data_, { self.pos.x, self.pos.y, 0 })
end



function SVG:plotCurve(x1, y1, x2, y2, x3, y3)
    -- use mix formula with time segment to create multiple points
    print("C--plot curve abs ~ bezier:", x1, y1, x2, y2, x3, y3)
    local segments = 10
    local a, b = 0, 0
    while a < segments do
        a = a + 1
        b = b + 1 / segments
        local a = self:quadBezier(vec3(x1, y1, 0), vec3(x2, y2, 0), vec3(x3, y3, 0), b)
        _.push(self.data_, { a.x, a.y, a.z })
        print("quad", a.x, a.y, a.z)
    end
    self.pos.x = x3;
    self.pos.y = y3;
    self.pos.cx = x2
    self.pos.cy = y2
end



function SVG:plotCurveRel(x1, y1, x2, y2, x3, y3)
    -- use mix formula with time segment to create multiple points
    print("c--plot curve ~ cubic:", x1, y1, x2, y2, x3, y3)
    print(" ~ start pos", self.pos.x, self.pos.y,
        "converted to abs:", (self.pos.x + x1), (self.pos.y + y1),
        (self.pos.x + x2), (self.pos.y + y2),
        (self.pos.x + x3), self.pos.y + y3)

    local segments = 10
    local a, b = 0, 0
    while a < segments do
        a = a + 1
        b = b + 1 / segments
        local a = self:cubicBezier(vec3(self.pos.x, self.pos.y, 0), vec3(self.pos.x + x1, self.pos.y + y1, 0), vec3(self.pos.x + x2, self.pos.y + y2, 0), vec3(self.pos.x + x3, self.pos.y + y3, 0), b)
        _.push(self.data_, { a.x, a.y, a.z })
        print("cubic", a.x, a.y, a.z)
    end
    self.pos.cx = self.pos.x + x2
    self.pos.cy = self.pos.y + y2
    self.pos.x = self.pos.x + x3
    self.pos.y = self.pos.y + y3
end


function SVG:smoothCurveTo(x1, y1, x2, y2)
    print("\nS--plot smooth curve ~ cubic:", x1, y1, x2, y2)


    -- take the last control point and mirror
    local c1x, c1y
    c1x = ((self.pos.cx - self.pos.x) * -1) + self.pos.x
    c1y = ((self.pos.cy - self.pos.y) * -1) + self.pos.y
    print("mirror first control point ", self.pos.cx, self.pos.cy, "to", c1x, c1y)

    print(" ~ start pos", self.pos.x, self.pos.y,
        "converted to abs:",
        self.pos.x, self.pos.y,
        c1x, c1y,
        (x1), (y1),
        (x2), (y2))

    local sp = vec3(self.pos.x, self.pos.y, 0)
    local cp1 = vec3(c1x, c1y, 0)
    local cp2 = vec3(x1, y1, 0)
    local ep = vec3(x2, y2, 0)

    local segments = 10
    local a, b = 0, 0
    while a < segments do
        a = a + 1
        b = b + 1 / segments
        local a = self:cubicBezier(sp, cp1, cp2, ep, b)
        _.push(self.data_, { a.x, a.y, a.z })
        print("cubic", a.x, a.y, a.z)
    end

    self.pos.cx = x1
    self.pos.cy = y1
    self.pos.x = x2
    self.pos.y = y2
end


function SVG:smoothCurveToRelative(x1, y1, x2, y2)
    print("\ns--plot smooth curve ~ cubic:", x1, y1, x2, y2)


    -- take the last control point and mirror
    local c1x, c1y
    c1x = ((self.pos.cx - self.pos.x) * -1) + self.pos.x
    c1y = ((self.pos.cy - self.pos.y) * -1) + self.pos.y
    print("mirror first control point ", self.pos.cx, self.pos.cy, "to", c1x, c1y)

    print(" ~ start pos", self.pos.x, self.pos.y,
        "converted to abs:",
        self.pos.x, self.pos.y,
        c1x, c1y,
        (self.pos.x + x1), (self.pos.y + y1),
        (self.pos.x + x2), (self.pos.y + y2))

    local sp = vec3(self.pos.x, self.pos.y, 0)
    local cp1 = vec3(c1x, c1y, 0)
    local cp2 = vec3(self.pos.x + x1, self.pos.y + y1, 0)
    local ep = vec3(self.pos.x + x2, self.pos.y + y2, 0)

    local segments = 10
    local a, b = 0, 0
    while a < segments do
        a = a + 1
        b = b + 1 / segments
        local a = self:cubicBezier(sp, cp1, cp2, ep, b)
        _.push(self.data_, { a.x, a.y, a.z })
        print("cubic", a.x, a.y, a.z, b)
    end

    self.pos.cx = self.pos.x + x1
    self.pos.cy = self.pos.y + y1
    self.pos.x = self.pos.x + x2
    self.pos.y = self.pos.y + y2
end




-- formula helpers

function SVG:cubicBezier(A, B, C, D, t)
    local E = A:mix(B, t)
    local F = B:mix(C, t)
    local G = C:mix(D, t)
    return self:quadBezier(E, F, G, t)
end


function SVG:quadBezier(A, B, C, t)
    local D = A:mix(B, t)
    local E = B:mix(C, t)
    local P = D:mix(E, t)
    return P
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

    local obj = gpc.new():add(verts);
    local data = {};
    self:plottri(data, obj:strip(), 0, 0, 0, 0);
    self:normalizeOutput(data, 2000, 2000);
    print('fofof');
    return data, obj;
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


return SVG;
