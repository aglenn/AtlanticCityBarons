Touch = {targets = {}}

function Touch:handle(x, y)
    print("check ("..x..", "..y..")")
    for i,target in ipairs(self.targets) do
        print("against ("..target.x..", "..target.y..", "..target.width..", "..target.height..")")
        if x >= target.x and x <= target.x + target.width and y >= target.y and y <= target.y + target.height then
            target:pressed()
        end
    end
end

function Touch:add(target)
    print("Add target ")
    table.insert(self.targets , target)
end

Touchable = {}
function Touchable:new(name, x, y, w, h)
    newTouchable = {name=name,x=x,y=y,width=w,height=h}
    self.__index = self                      
    return setmetatable(newTouchable, self)
end

function Touchable:pressed()
    print("Pressed "..self.name)
end