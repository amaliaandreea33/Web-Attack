-- player spider setup
function _init()
	x = 56
	y = 100
	bullets = {}
	flies = {}
	level = 1
	flies_spawned = 0
	flies_caught = 0
	webs_left = 10
end

function _update()
	-- movement
	if btn(0) then -- left arrow
		x -= 2
	end
	if btn(1) then -- right arrow
		x += 2
	end

	-- shooting (z or x)
	if (btnp(4) or btnp(5)) and webs_left > 0 then 
		add(bullets, {bx = x + 4, by = y - 4})
		webs_left -= 1
	end

	-- update bullets
	for b in all(bullets) do
		b.by -= 3
		if b.by < -8 then
			del(bullets, b)
		end
	end

	-- spawn and update flies
	if flies_spawned < 5 and rnd(100) < 3 then
		local start_x = 120
		local speed = -0.6 - (level * 0.1)
		if rnd(2) < 1 then
			start_x = 0
			speed = 0.6 + (level * 0.1)
		end
		add(flies, {fx = start_x, fy = rnd(80), dead = false, timer = 0, speed = speed})
		flies_spawned += 1
	end

	for f in all(flies) do
		if not f.dead then
			f.fx += f.speed
			f.fy += cos(t()) * 0.5
			f.timer += 1
			for b in all(bullets) do
				if abs(f.fx - b.bx) < 6 and abs(f.fy - b.by) < 6 then
					f.dead = true
					del(bullets, b)
					flies_caught += 1
				end
			end
			-- remain on screen by bouncing
			if f.fx < 0 then
				f.fx = 0
				f.speed = abs(f.speed)
			elseif f.fx > 120 then
				f.fx = 120
				f.speed = -abs(f.speed)
			end
		end
	end

	if flies_caught >= 5 then
		level += 1
		flies_spawned = 0
		flies_caught = 0
		flies = {}
		bullets = {}
		webs_left = 10
	end

	-- game over condition: out of webs, no active bullets, and haven't won
	if webs_left == 0 and #bullets == 0 and flies_caught < 5 then
		_init()
	end

	-- clamp to screen with a 1-tile (8px) margin on left and right
	-- spider is 16px wide, screen is 128px wide
	if x < 8 then x = 8 end
	if x > 104 then x = 104 end
end

function _draw()
	cls(0)
	map(0, 0, 0, 0, 16, 16)
	
	print("LVL " .. level, 88, 2, 7)
	print("WEBS " .. webs_left, 2, 2, 7)

	-- draw bullets
	for b in all(bullets) do
		spr(4, b.bx, b.by)
	end

	-- draw flies
	for f in all(flies) do
		local fly_sp = 2
		if not f.dead then
			fly_sp = 2 + flr((f.timer % 20) / 10)
		end
		spr(fly_sp, f.fx, f.fy)
		if f.dead then
			spr(5, f.fx, f.fy)
		end
	end

	-- spr(sprite_id, x, y, width_in_tiles, height_in_tiles)
	-- we start drawing at tile 0 (top-left of the spider)
	local sp_id = 0
	if btn(0) or btn(1) then
		if flr(t() * 8) % 2 == 0 then
			sp_id = 6
		end
	end
	spr(sp_id, x, y, 2, 2)
end

