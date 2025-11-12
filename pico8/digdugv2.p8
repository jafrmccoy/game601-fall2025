pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--dig-dug simple digging demo
function _init()
--fill the map with dirt tiles (1)
 for y=0,15 do
 for x=0,15 do
  mset(x,y,1)
 end
end

-- place a few animals (tile 4)
 mset(4,4,4)
 mset(10,8,4)
 mset(6,13,4)

--player start position
 px=7
 py=7
 score=0
 rescued=0
-- put initial tunnel where player starts
 mset(px, py, 2)
end

function _update()
 local moved = false
 local nx,ny=px,py --next x and y
 if btnp(0) 
 	then px-=1 moved=true 
 end -- left
 if btnp(1) 
 	then px+=1 moved=true 
 end -- right
 if btnp(2) 
 	then py-=1 moved=true 
 end -- up
 if btnp(3) 
 	then py+=1 moved=true 
 end -- down

-- bounds check
	if px<0 then 
		px=0 
	end
 if px>15 then 
 	px=15 
 end
 if py<0 then
 	py=0 
 end
 if py>15 then
 	py=15 
 end

--when moved, dig (change tile to tunnel)
 if moved then
 	local tile=mget(nx, ny) --chck what's at the next position first
--if it's an animal
 	if tile==4 then
  rescued+=1
  score+=10
 end
 
 	mset(nx,ny,2) --dig(change tile color)
 end
end

function _draw()
 cls()
 map(0,0) --draw map
 spr(3,px*8,py*8) --draw player
 print("score:"..score,90,2,7) --score
  for i=1,rescued do -- draw rescued animal icons in top-left corner
   spr(4, (i-1)*9,0)
  end
end

__gfx__
00000000633533335555555500fffff033f333f30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333353335555575500f1f1f03fef3fef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700333336365655555500fffff03fef3fef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000353333335555655500fffff03fffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770003333333557555555008888803ff0f0ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007006335333355555555008888803fffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000003336335355565575000202003fffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000035333333555555550022022033fffff30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
