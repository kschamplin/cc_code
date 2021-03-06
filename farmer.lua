local tg = require("turtlego")

-- assume we are at the home and orient ourself

for i = 0,4 do
	res, detail = turtle.inspect()
	if (res) then
		if detail.name == "minecraft:bricks" then
			turtle.turnRight()
			tg.setHome()
			break
		end
	end
	turtle.turnRight()
end

-- now we are oriented.

function depositWood()
	for i = 1,16 do
		local tab = turtle.getItemDetail(i)
		if tab and tab.name == "minecraft:birch_log" then
			turtle.select(i)
			assert(turtle.dropUp())
		end
	end
end

function getItemFromNetwork(item_name, amt)
	amt = amt or 64
	if amt <= 0 then return true end
	local item_counter = 0

	local modem = assert(peripheral.find("modem"), "could not find modem")
	local chest_names = assert(modem.getNamesRemote(), "could not get chests")
	local turtle_name = assert(modem.getNameLocal(), "could not get turtle name")
	repeat
		turtle_name = modem.getNameLocal()
		os.sleep(0.5)
		print("getting turtle name")
	until turtle_name

	for _,name in ipairs(chest_names) do
		local chest = assert(peripheral.wrap(name), "could not wrap chest")
		local chest_inventory = chest.list()

		for i,chest_item in pairs(chest_inventory) do
			if chest_item.name == item_name then
        			amt = amt - chest.pushItems(turtle_name, i, amt)
				if amt <= 0 then return true end
			end
		end
	end

	return false
end
function fellTree()
	-- chop in front, move forward
	turtle.dig()
	tg.moveForward()
	while true do
		local block, data = turtle.inspectUp()
		if (block and data.name == "minecraft:birch_log") then
			turtle.digUp()
			tg.moveUp()
		else
			break
		end
	end
	while tg.moveDown() do end
	tg.moveBack()

	-- place birch
	assert(selectItem("minecraft:birch_sapling"), "could not find birch sapling")
	turtle.place()
end

function selectItem(name)
	for i = 1,16 do
		local item = turtle.getItemDetail(i)
		if item and item.name == name then
			turtle.select(i)
			return true
		end
	end
	return false
end
function getTotal(name)
	local total = 0
	for i = 1,16 do
		local item = turtle.getItemDetail(i)
		if item and item.name == name then
			total = total + item.count
		end
	end
	return total
end
-- begin big loop
-- 1. go to first tree
-- 2. check if tree is there (minecraft:birch_log)
-- if tree is there, begin felling routine
-- after felling, replant.
-- go to next tree
-- if no more trees (hit wall or smth) then go to collection
-- wait for leaves to decay, collect loot
-- deposit wood, apples, sticks.
-- refuel if necessary (check fuel)
while true do
	tg.moveAbs({ z = 5, x = 0, y = 0})

	tg.moveAbs({x = 1})
	tg.setDirection(2)

	while true do
		-- do we have tree?
		tg.setDirection(tg.DIRS.SOUTH)
  		res, detail = turtle.inspect()
		if (res) then
			if (detail.name == "minecraft:birch_log") then
				-- felling routine
				print("chop chop")
				fellTree()
			end
		end

		-- goto next tree
		result = tg.moveRel({right = -2})
		if (not result) then
			print("hit end of row")
			-- try next row
			tg.setDirection(2)
			result = tg.moveRel({forward = -3})
			if (not result) then
				print("hit end of farm, collecting")
				break
			end
			-- else we go back to x = 1
			tg.moveAbs({x = 1})
			tg.setDirection(2)
		end
	end

	tg.goHome()

	-- deposit
	depositWood()

	-- replenish saplings
	local total_saplings = getTotal("minecraft:birch_sapling")
	getItemFromNetwork("minecraft:birch_sapling", math.max(64 - total_saplings, 0))
	-- refuel
	if (turtle.getFuelLevel() < 1000) then
		print("refueling")
		getItemFromNetwork("minecraft:charcoal", 20)
		selectItem("minecraft:charcoal")
		turtle.refuel()
	end

	os.sleep(10 * 60)
end
print("end of program")
