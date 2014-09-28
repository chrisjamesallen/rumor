SVG = Class()
local pattern = "(%D)(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*)%s?"

function SVG:init()
    self.data_ = {};
    self.pos = { x = 0, y = 0, cx = 0, cy = 0}
    self.startPos = {};
    self.paths = {};
    return self; --
end

function SVG:extractHull(svgStr)
    print("\n\nSvg:Extract Hull:\n", svgStr, "\n")
    self:extractSVGOperations(svgStr)
    self:triangulate()
    return self.data_
end


function SVG:extractSVGOperations(svgStr)
    local operations = {}
    self:openSubPath()
    for command, x1, y1, x2, y2, x3, y3 in string.gmatch(svgStr, pattern) do
        if (command == "z" or command == "Z") then
            self:closeSubPath(operations)
            self:openSubPath()
        end
        local op = {}
        op = { tonumber(x1) or 0, tonumber(y1) or 0, tonumber(x2) or 0, tonumber(y2) or 0, tonumber(x3) or 0, tonumber(y3) or 0 }
        op["command"] = command;
        _.push(operations, op)
    end
    self.data_index = self.data_index - 1
    _.pop(self.paths) --will always have an extra path redundant due to loop
    return operations
end

function SVG:openSubPath(operations)
    local path = {}
    _.push(self.paths, path)
    self.data_ = path
    self.data_index = #self.paths
end

function SVG:closeSubPath(operations)
    if (#operations == 0) then
        return nil
    end
    self:convertSvgToPoints(operations)
    self.data_ = _.flatten(self.data_)
    self.paths[self.data_index] = self.data_
    self:normalizeData(self.data_)
    return self.data_
end

function SVG:convertSvgToPoints(operations)
    _.each(operations, function(i)
        if i.command == 'M' then
            _.push(self.data_, { i[1], i[2], 0 })
            self.pos.x = i[1]
            self.pos.y = i[2]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        --lineto
        if i.command == 'L' then
            _.push(self.data_, { i[1], i[2], 0 })
            self.pos.x = i[1]
            self.pos.y = i[2]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        if i.command == 'l' then
            _.push(self.data_, { self.pos.x + i[1], self.pos.y + i[2], 0 })
            self.pos.x = self.pos.x + i[1]
            self.pos.y = self.pos.y + i[2]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        --h line
        if i.command == 'h' then
            _.push(self.data_, { self.pos.x + i[1], self.pos.y, 0 })
            self.pos.x = self.pos.x + i[1]
            self.pos.y = self.pos.y
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        if i.command == 'H' then
            _.push(self.data_, { i[1], self.pos.y, 0 })
            self.pos.x = i[1]
            self.pos.y = self.pos.y
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end -- y param
        -- v line
        if i.command == 'v' then
            _.push(self.data_, { self.pos.x, self.pos.y + i[1], 0 })
            self.pos.x = self.pos.x
            self.pos.y = self.pos.y + i[1]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        if i.command == 'V' then
            _.push(self.data_, { self.pos.x, i[1], 0 })
            self.pos.x = self.pos.x
            self.pos.y = i[1]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        -- Cubic curveto C (c)
        if i.command == 'c' then
            local sp = vec3(self.pos.x, self.pos.y, 0)
            local cp1 = vec3(self.pos.x + i[1], self.pos.y + i[2], 0)
            local cp2 = vec3(self.pos.x + i[3], self.pos.y + i[4], 0)
            local ep = vec3(self.pos.x + i[5], self.pos.y + i[6], 0)
            local a = self:cubicBezier(sp, cp1, cp2, ep, 0.5)
            self:determineCurveRightSide(a, sp, cp1, cp2)

            _.push(self.data_, { i[5] + self.pos.x, i[6] + self.pos.y, 0 })
            self.pos.x = i[5] + self.pos.x
            self.pos.y = i[6] + self.pos.y
            self.pos.cx = i[3]  + self.pos.x
            self.pos.cy = i[4] + self.pos.y
        end
        if i.command == 'C' then
            local sp = vec3(self.pos.x, self.pos.y, 0)
            local cp1 = vec3(i[1], i[2], 0)
            local cp2 = vec3(i[3], i[4], 0)
            local ep = vec3(i[5], i[6], 0)
            local a = self:cubicBezier(sp, cp1, cp2, ep, 0.5)
            self:determineCurveRightSide(a, sp, cp1, cp2)
            _.push(self.data_, { ep.x, ep.y, 0 })
            self.pos.x = i[5]
            self.pos.y = i[6]
            self.pos.cx = i[3]
            self.pos.cy = i[4]
        end
        -- Cubic shorthand curveto S (s)
        if i.command == 's' then
            -- take the previous control point and mirror
            local c1x, c1y
            c1x = ((self.pos.cx - self.pos.x) * -1) + self.pos.x
            c1y = ((self.pos.cy - self.pos.y) * -1) + self.pos.y
            local sp = vec3(self.pos.x, self.pos.y, 0)
            local cp1 = vec3(c1x, c1y, 0)
            local cp2 = vec3(self.pos.x + i[1], self.pos.y + i[2], 0)
            local ep = vec3(self.pos.x + i[3], self.pos.y + i[4], 0)
            local a = self:cubicBezier(sp, cp1, cp2, ep, 0.5)
            self:determineCurveRightSide(a, sp, cp1, cp2)
            _.push(self.data_, { ep.x, ep.y, 0 })
            self.pos.x = self.pos.x + i[3]
            self.pos.y = self.pos.y + i[4]
            self.pos.cx = self.pos.x + i[1]
            self.pos.cy = self.pos.y + i[2]
        end
        if i.command == 'S' then
            local c1x = ((self.pos.cx - self.pos.x) * -1) + self.pos.x
            local c1y = ((self.pos.cy - self.pos.y) * -1) + self.pos.y
            local sp = vec3(self.pos.x, self.pos.y, 0)
            local cp1 = vec3(c1x, c1y, 0)
            local cp2 = vec3(i[1], i[2], 0)
            local ep = vec3(i[3], i[4], 0)
            local a = self:cubicBezier(sp, cp1, cp2, ep, 0.5)
            self:determineCurveRightSide(a, sp, cp1, cp2)
            _.push(self.data_, { ep.x, ep.y, 0 })
            self.pos.x = i[3]
            self.pos.y = i[4]
            self.pos.cx = i[1]
            self.pos.cy = i[2]
        end
    end)

    return operations
end


function SVG:determineCurveRightSide(midCurve, sp, cp1, cp2)
    -- take the curve and determine from the mid point if curve is concave or convex
    local i = midCurve
    if (i.x < sp.x) then
        --convex (outside)
        --use midpoint
        _.push(self.data_, { i.x, i.y, i.z })
    else
        --concave (inside
        --use two cps
        _.push(self.data_, { cp1.x, cp1.y, cp1.z })
        _.push(self.data_, { cp2.x, cp2.y, cp2.z })
    end
end

function SVG:normalizeData(data)
    local maxX = 500
    local maxY = 500
    local min = 0
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
        --print(k,self.data_[k])
    end
end



function SVG:triangulate()
    local subPath = 0
    local subPaths = {}
    local t
    _.each(self.paths, function(data)
        local data_ = _.flatten(data)
        subPath = subPath + 1
        if (_.is_empty(data) == false) then
            local a = 0
            data_ = _.select(data_, function(i) a = a + 1; return a % 3 ~= 0 end)
            t = gpc.new():add(data_)
            _.push(subPaths, t)
        end
    end)

    local pool = {};
    local p = _.first(subPaths)
    _.each(_.rest(subPaths), function(path)
        p = p * path;
    end)
    self:plottri(pool, p:strip(), 0, 0, 0, 0);
    self.data_ = pool
    self.vertices = math.ceil(#pool / 3) -- this is cause there are three points to each vertex
    self.points = #self.data_
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

return SVG;
