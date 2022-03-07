local tab = {}
tab.pos = {x = 0, y = 0, z = 0, dir = 0};

local DIRS = {
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

tab.setHome = function ()
	tab.pos.x = 0
	tab.pos.y = 0
	tab.pos.z = 0
	tab.pos.dir = DIRS.NORTH
end


tab.turnRight = function()
	turtle.turnRight()
	tab.pos.dir = (tab.pos.dir + 1) % 4
end

tab.turnLeft = function ()
	turtle.turnLeft()
	tab.pos.dir = (tab.pos.dir - 1) % 4
end

-- moves forward and increments pos in proper direction
tab.moveForward = function ()
	result,err = turtle.forward() -- bool if true
	if (not result) then
		print("move failed: " .. err)
		return result, err
	end
	-- at this point we have moved
	if (tab.pos.dir == DIRS.NORTH) then
		tab.pos.z = tab.pos.z - 1
	elseif (tab.pos.dir == DIRS.EAST) then
		tab.pos.x = tab.pos.x + 1
	elseif (tab.pos.dir == DIRS.SOUTH) then
		tab.pos.z = tab.pos.z + 1
	elseif (tab.pos.dir == DIRS.WEST) then
		tab.pos.x = tab.pos.x - 1
	end
	return true
end
tab.moveBack = function ()
	result,err = turtle.back() -- bool if true
	if (not result) then
		print("move failed: " .. err)
		return result, err
	end
	-- at this point we have moved
	if (tab.pos.dir == DIRS.NORTH) then
		tab.pos.z = tab.pos.z + 1
	elseif (tab.pos.dir == DIRS.EAST) then
		tab.pos.x = tab.pos.x - 1
	elseif (tab.pos.dir == DIRS.SOUTH) then
		tab.pos.z = tab.pos.z - 1
	elseif (tab.pos.dir == DIRS.WEST) then
		tab.pos.x = tab.pos.x + 1
	end
	return true
end

tab.moveUp = function()
	result, err = turtle.up()
	if (not result) then
		print("up failed: " .. err)
		return result, err
	end
	tab.pos.y = tab.pos.y + 1
	return true
end
tab.moveDown = function()
	result, err = turtle.down()
	if (not result) then
		print("down failed: " .. err)
		return result, err
	end
	tab.pos.y = tab.pos.y - 1
	return true
end


tab.setDirection = function(newDirection)
	while (newDirection ~= tab.pos.dir) do
		tab.turnLeft()
	end
end


tab.moveAbs = function (newPos)
	-- given pos with x,y,z and dir, and our current pos, we want to go there.
	
	-- for x
	while (newPos.x ~= tab.pos.x) do
		if (newPos.x > tab.pos.x) then
			tab.setDirection(DIRS.EAST)
			tab.moveForward()
		else 
			tab.setDirection(DIRS.WEST)
			tab.moveForward()
		end
	end
	while (newPos.z ~= tab.pos.z) do
		if (newPos.z > tab.pos.z) then
			tab.setDirection(DIRS.SOUTH)
			tab.moveForward()
		else 
			tab.setDirection(DIRS.NORTH)
			tab.moveForward()
		end
	end
end

tab.goHome = function()
	tab.moveTo({x = 0, y = 0, z = 0})
end

-- offset is a table of {forward = 0, right = 0, up = 0}
tab.moveRel = function(offset)
	local oldDirection = tab.pos.dir
	
	local fmag = math.abs(offset.forward)
	for i = 1,fmag do
		if (offset.forward > 0) then
			tab.moveForward()
		else
			tab.moveBackward()
		end
	end

	tab.turnRight()
	local rmag = math.abs(offset.right)
	for i = 1, rmag do
		if (offset.right > 0) then
			tab.moveForward()
		else
			tab.moveBackward()
		end
	end
	
	local umag = math.abs(offset.up)
	for i = 1, umag do
		if (offset.up > 0) then
			tab.moveUp()
		else
			tab.moveDown()
		end
	end

	tab.setDirection(oldDirection)

end	




return tab
