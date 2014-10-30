SVGCurves = SVGShape:extend()
local pattern = "(%D)(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*)%s?"



function SVGCurves:extract(svgStr)
    print("\n\nSvg:Extract Curve:\n", svgStr, "\n")
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
    self:triangulate()
    return self
end

function SVGCurves:triangulate()
    local data = {}
    _.each(self.paths, function(path)
         _.push(data, path)
    end)
    self.data_ = _.flatten(self.paths);
      self.count = math.ceil(#self.data_ / 3) -- this is cause there are three points to each vertex
    -- for every three floats, create {0.0,0.0, 0.0,0.5, 1.0,1.0}
    local texCoordsStride = math.ceil(self.count / 3)
    local texCoords = {}
    _.each(_.range(texCoordsStride), function(a)
         _.push(texCoords, {1.0,1.0, 0.5,0,0,0})  
     end)
     inspect(self.texData);
     texCoords = _.flatten(self.texData);
      self.points = #self.data_
      self.texCoords = texCoords
      self.vertices = self.data_
end



function SVGCurves:convertSvgToPoints(operations)
    --inspect(operations)
    _.each(operations, function(i)
        if i.command == 'M' then
            self.pos.x = i[1]
            self.pos.y = i[2]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        --lineto
        if i.command == 'L' then
            self.pos.x = i[1]
            self.pos.y = i[2]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        if i.command == 'l' then
            self.pos.x = self.pos.x + i[1]
            self.pos.y = self.pos.y + i[2]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        --h line
        if i.command == 'h' then
            self.pos.x = self.pos.x + i[1]
            self.pos.y = self.pos.y
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        if i.command == 'H' then
            self.pos.x = i[1]
            self.pos.y = self.pos.y
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end -- y param
        -- v line
        if i.command == 'v' then
            self.pos.x = self.pos.x
            self.pos.y = self.pos.y + i[1]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        if i.command == 'V' then
            self.pos.x = self.pos.x
            self.pos.y = i[1]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        -- Cubic curveto C (c)
        if i.command == 'c' then
           print("c")
            local sp = vec3(self.pos.x, self.pos.y, 0)
            local cp1 = vec3(self.pos.x + i[1], self.pos.y + i[2], 0)
            local cp2 = vec3(self.pos.x + i[3], self.pos.y + i[4], 0)
            local ep = vec3(self.pos.x + i[5], self.pos.y + i[6], 0)
            local a = self:cubicBezier(sp, cp1, cp2, ep, 0.5)
            local b = cp2:mix(cp1, 0.5)
            self:determineCurveRightSide(a, sp, cp1, cp2, ep)
            self.pos.x = i[5] + self.pos.x
            self.pos.y = i[6] + self.pos.y
            self.pos.cx = i[3]  + self.pos.x
            self.pos.cy = i[4] + self.pos.y
        end
        if i.command == 'C' then
           print("C")
            local sp = vec3(self.pos.x, self.pos.y, 0)
            local cp1 = vec3(i[1], i[2], 0)
            local cp2 = vec3(i[3], i[4], 0)
            local ep = vec3(i[5], i[6], 0)
            local a = self:cubicBezier(sp, cp1, cp2, ep, 0.5)
            local b = cp2:mix(cp1, 0.5)
            self:determineCurveRightSide(a, sp, cp1, cp2, ep)
            self.pos.x = i[5]
            self.pos.y = i[6]
            self.pos.cx = i[3]
            self.pos.cy = i[4]
        end
        -- Cubic shorthand curveto S (s)
        if i.command == 's' then
           print("s")
            -- take the previous control point and mirror
            local c1x, c1y
            c1x = ((self.pos.cx - self.pos.x) * -1) + self.pos.x
            c1y = ((self.pos.cy - self.pos.y) * -1) + self.pos.y
            local sp = vec3(self.pos.x, self.pos.y, 0)
            local cp1 = vec3(c1x, c1y, 0)
            local cp2 = vec3(self.pos.x + i[1], self.pos.y + i[2], 0)
            local ep = vec3(self.pos.x + i[3], self.pos.y + i[4], 0)
            local a = self:cubicBezier(sp, cp1, cp2, ep, 0.5)
            self:determineCurveRightSide(a, sp, cp1, cp2, ep)
           
            self.pos.x = self.pos.x + i[3]
            self.pos.y = self.pos.y + i[4]
            self.pos.cx = self.pos.x + i[1]
            self.pos.cy = self.pos.y + i[2]
        end
        if i.command == 'S' then
           print("S")
            local c1x = ((self.pos.cx - self.pos.x) * -1) + self.pos.x
            local c1y = ((self.pos.cy - self.pos.y) * -1) + self.pos.y
            local sp = vec3(self.pos.x, self.pos.y, 0)
            local cp1 = vec3(c1x, c1y, 0)
            local cp2 = vec3(i[1], i[2], 0)
            local ep = vec3(i[3], i[4], 0)
            local a = self:cubicBezier(sp, cp1, cp2, ep, 0.5)
            self:determineCurveRightSide(a, sp, cp1, cp2, ep)
            _.push(self.data_, { ep.x, ep.y, 0 })
            self.pos.x = i[3]
            self.pos.y = i[4]
            self.pos.cx = i[1]
            self.pos.cy = i[2]
        end
    end)

    return operations
end



function SVGCurves:determineCurveRightSide(midCurve, sp, cp1, cp2, ep)
    -- take the curve and determine from the mid point if curve is concave or convex
    local i = midCurve
    if (i.x < sp.x) then
        --convex (outside)
        --use midpoint
        --print("out side ~ left!")
        -- first triangle
        _.push(self.data_, { sp.x, sp.y, sp.z })
        _.push(self.data_, { cp1.x, cp1.y, cp1.z })
        _.push(self.data_, { i.x, i.y, i.z })
        self:tex(1)

        -- second triangle
        _.push(self.data_, { i.x, i.y, i.z })
        _.push(self.data_, { cp2.x, cp2.y, cp2.z })
        _.push(self.data_, { ep.x, ep.y, ep.z })
        self:tex(1)

    else
        --concave (inside
        --use two cps
        print("inside side ~ right")
        -- first triangle
        _.push(self.data_, { sp.x, sp.y, sp.z })
        _.push(self.data_, { cp1.x, cp1.y, cp1.z })
        _.push(self.data_, { i.x, i.y, i.z })
        self:tex(0)
        -- second triangle
        _.push(self.data_, { i.x, i.y, i.z })
        _.push(self.data_, { cp2.x, cp2.y, cp2.z })
        _.push(self.data_, { ep.x, ep.y, ep.z })
        self:tex(0)
    end
end


function SVGCurves:tex(side)
    if(side==1) then
        _.push(self.texData, {1,1,0,  0.5,0,0, 0,0,0})
    else
        _.push(self.texData, {1,1,1,  0.5,0,1, 0,0,1})
    end
end

return SVGCurves;
