pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
 --tells game which screen
 --to draw
	screen=0

	--sets delay for btnp
	poke(0x5f5c,255)
	
	--player
	make_player()
	init_atk()	
	init_life()
	
	--enemy
	init_enemy()
end

function _update()
	if (screen==0 and btnp(❎)) then
		screen=1
	end
	
	update_player()
	update_life()
	spawn_enemy()
	update_enemy()
	
end

function _draw()
	cls()
	map(screen*16,0,0,0,16,16)
	if screen==0 then
		print("dig dug clone",40,64)
		print("press ❎ to start",32,70)
	else
		map(screen*16,0,0,0,16,16)
		draw_enemy()
		draw_player()
		draw_life()
		draw_atk()
	end
	
	
end
-->8
function make_player()
	p={}
	p.x=64 --position
	p.y=16
	p.state=0 --current player state
	p.spr=0 --sprite
	p.dir=1 --direction
	p.sprdir=0 --sprite direction
	p.pat=0 --player state timer
	p.bndx1=-1 --player bounds
	p.bndx2=121
	p.bndy1=15
	p.bndy2=121
	p.tilex=0 --player map tile
	p.tiley=0
	p.atk=false
	p.atkhoriz=true --atk horiz (true) or vert (false)
	
	p.col=false
end

function change_state(s)
	p.state=s
	p.pat=0
end

function update_player()
	b0=btn(0)
	b1=btn(1)
	b2=btn(2)
	b3=btn(3)
	bx=btn(❎)
	
	--player map tiles
	p.tilex=((p.x+7)\8)+(16*screen)
	p.tiley=(p.y+7)\8

	p.pat+=1 --inc state clock
	
	if (not p.atk) then
		--idle state
		if p.state==0 then
			p.spr=0
			p.atkhoriz=true
			--replace tile
			if map_collision(p.tilex,p.tiley,0) then
				map_replace(p.tilex,p.tiley,17)
			end
			if (b0 or b1) change_state(1)
			if (b2)  change_state(2)
			if (b3) change_state(3)
		end
		
		--walk state horiz
		if p.state==1 then
			p.atkhoriz=true
			if (b0) then
				p.dir=-1
				p.sprdir=-1
				p.tilex=((p.x+7)\8)+(16*screen)
			end
			if (b1) then
				p.dir=1
			 p.sprdir=1
			 p.tilex=((p.x)\8)+(16*screen)
			end
			
			--if tile is dirt left
			if b0 and map_collision(p.tilex+p.dir,p.tiley,0) then
				p.col=true
				--check bounds
				if (p.x+p.dir>p.bndx1 and p.x+p.dir<p.bndx2) then
					--move
					p.x+=p.dir			
				end
			--if tile is dirt right
			elseif b1 and map_collision(p.tilex+p.dir,p.tiley,0) then
				p.col=true
				--check bounds
				if (p.x+p.dir>p.bndx1 and p.x+p.dir<p.bndx2) then
					--move
					p.x+=p.dir			
				end							
			else --if tile is not dirt
				p.col=false
				--check bounds
				if (p.x+(p.dir*2)>p.bndx1 and p.x+(p.dir*2)<p.bndx2) then
					--move
					if (not((p.x+(p.dir*2))%8==1)) then
						p.x+=p.dir*2
					else
						p.x+=p.dir
					end
				elseif (p.x+p.dir>p.bndx1 and p.x+p.dir<p.bndx2) then
					p.x+=p.dir
				end
			end
			
			--replace
			if map_collision(p.tilex,p.tiley,0) then
				map_replace(p.tilex,p.tiley,17)			
			end
			
			p.spr=flr(p.pat/2)%2
			
			--check if sprite on whole tile
			if ((p.x)%8==0) then		
				if (not (b0 or b1)) change_state(0)
				if b2 and not (b0 or b1) then
				 change_state(2)
				end
				if b3 and not (b0 or b1) then
				 change_state(3)
				end
			end
		end
		
		--walk state up
		if p.state==2 then
				p.atkhoriz=false
				p.dir=-1
			 p.sprdir=1
				p.tiley=(p.y+7)\8
			
			--if tile is dirt
			if map_collision(p.tilex,p.tiley+p.dir,0) then
				p.col=true
				--check bounds
				if (p.y+p.dir>p.bndy1 and p.y+p.dir<p.bndy2) then
					--move
					p.y+=p.dir
				end
			else --if tile is not dirt
				p.col=false
				--check bounds
				if (p.y+(p.dir*2)>p.bndy1 and p.y+(p.dir*2)<p.bndy2) then
					--move
					p.y+=p.dir*2
				elseif (p.y+p.dir>p.bndy1 and p.y+p.dir<p.bndy2) then
					p.y+=p.dir
				end	
			end
			
			--replace
			if map_collision(p.tilex,p.tiley,0) then
				map_replace(p.tilex,p.tiley,17)
			end
			
			p.spr=(flr(p.pat/2)%2)+2
			
			--check if sprite on whole tile
			if ((p.y)%8==0) then
				if (not b2) then
					p.sprdir=-1
					change_state(0)
				end
				if (b0 or b1) and not b2 then
					change_state(1)
				end
				if b3 and not b2 then
					change_state(3)
				end
			end
		end
		
		--walk state down
		if p.state==3 then
				p.atkhoriz=false
				p.dir=1
			 p.sprdir=1
			 p.tilex=(p.x\8)+(16*screen)
				p.tiley=p.y\8
			
			--if tile is dirt
			if map_collision(p.tilex,p.tiley+p.dir,0) then
				p.col=true
				--check bounds
				if (p.y+p.dir>p.bndy1 and p.y+p.dir<p.bndy2) then
					--move
					p.y+=p.dir
				end
			else --if tile is not dirt
				p.col=false
				--check bounds
				if (p.y+(p.dir*2)>p.bndy1 and p.y+(p.dir*2)<p.bndy2) then
					--move
					p.y+=p.dir*2
				elseif (p.y+p.dir>p.bndy1 and p.y+p.dir<p.bndy2) then
					p.y+=p.dir
				end	
			end
			
			--replace
			if map_collision(p.tilex,p.tiley,0) then
				map_replace(p.tilex,p.tiley,17)
			end
			
			p.spr=(flr(p.pat/2)%2)+4
			
			--check if sprite on whole tile
			if ((p.y)%8==0) then
				if (not b3) change_state(0)
				if (b0 or b1) and not b3 then
					change_state(1)
				end
				if b2 and not b3 then
					change_state(2)
				end
			end
		end
	end
	
	--attack
	if bx then
		p.atk=true
		update_atk()
	else
		p.atk=false
	end
end

function draw_player()
	if screen>0 then
		spr(p.spr,p.x,p.y,1,1,p.sprdir==-1)
	end
	
	print("p.tilex:"..p.tilex,0,32)
	print("p.tiley:"..p.tiley)
	
	if p.col then
		print("col detected",64,64)
	else
		print("no col",64,64)
	end
	
	print("p.x="..p.x)
	print("p.x%8="..(p.x%8))
end
-->8
function map_collision(tile_x, tile_y, flag)
	map_x1=16*screen
	map_x2=map_x1+15
	map_y1=0
	map_y2=map_y1+15
	
	if (tile_x<map_x1 or tile_x>map_x2 or
		tile_y<map_y1 or tile_y>map_y2) then
		return false
	else
	 return fget( mget(tile_x,tile_y), flag)
	end
end

function map_replace(tile_x, tile_y, sprite)
	mset(tile_x,tile_y,sprite)
end
-->8
function init_atk()
	atk={}
	atk.spr=9
	atk.x=0
	atk.y=0
end

function update_atk()
 if p.atkhoriz then
 	atk.x=p.x+(p.dir*8)
 	atk.y=p.y
 	atk.spr=9
 else
		atk.x=p.x
		atk.y=p.y+(p.dir*8)
		atk.spr=10
	end
end

function draw_atk()
	if screen>0 then
		if (p.atk) then
			spr(atk.spr,atk.x,atk.y)
		end
	end
end
-->8
function init_enemy()
	enem={}


end

function spawn_enemy()

	for ix=0+(16*screen),15+(16*screen),1 do
		for iy=0,15,1 do
		
			--spawn red boys
			if map_collision(ix,iy,2) then
				
				red={}
				red.type=1
				red.x=(ix*8)-(128*screen)
				red.y=(iy*8)
				red.dir=1
				red.spr=6
				red.tilex=ix
				red.tiley=iy
				red.exist=true
				red.tag=(ix*1000)+iy
				add(enem,red)
				map_replace(ix,iy,49)
			
			--spawn green boys
			elseif map_collision(ix,iy,3) then
			
				green={}
				green={}
				green.type=2
				green.x=(ix*8)-(128*screen)
				green.y=(iy*8)
				green.dir=1
				green.spr=8
				green.sprdir=1
				green.atkspr=13
				green.atkdir=1
				green.flipy=false
				green.atk=false
				green.atkx=0
				green.atky=0
				green.atktime=0
				green.tilex=ix
				green.tiley=iy
				green.exist=true
				green.tag=(ix*1000)+iy
				add(enem,green)
				map_replace(ix,iy,49)
			end
		
		end
	end

end

function update_enemy()

	--go over all enemies
	foreach(enem,update_enem)
	

end

function update_enem(enemy)
	
	--red boys
	if enemy.type==1 then
	
		if enemy.y==16 then
			--at top of screen
			if enemy.x>-16 then
				enemy.x-=0.5
			else
				enemy.exist=false
			end
		else
			--right
			if enemy.dir==1 then
			
				if (not map_collision((enemy.x+8)\8+(16*screen),
				(enemy.y)\8,0)) and (enemy.x+7<127) then
					enemy.x+=0.5
				elseif not (enemy.x%8==0) then
					enemy.x+=0.5				
				else
					pick_dir(enemy)
				end
			
			--down
			elseif enemy.dir==2 then
			
				if (not map_collision((enemy.x)\8+(16*screen),
				(enemy.y+8)\8,0)) and (enemy.y+7<127) then
					enemy.y+=0.5
				elseif not (enemy.y%8==0) then
					enemy.y+=0.5				
				else
					pick_dir(enemy)
				end
			
			--left
			elseif enemy.dir==3 then
			
				if (not map_collision((enemy.x-8)\8+(16*screen),
				(enemy.y)\8,0)) and (enemy.x-7>0) then
					enemy.x-=0.5
				elseif not (enemy.x%8==0) then
					enemy.x-=0.5				
				else
					pick_dir(enemy)
				end
			
			--up
			elseif enemy.dir==4 then
			
				if (not map_collision((enemy.x)\8+(16*screen),
				(enemy.y-8)\8,0)) and (enemy.y-7>16) then
					enemy.y-=0.5
				elseif not (enemy.y%8==0) then
					enemy.y-=0.5				
				else
					pick_dir(enemy)
				end
			
			end
	
		end
	end
	
	--green boys
	if enemy.type==2 then
	
		--player in range
		if (enemy.dir==1 and ((p.y==enemy.y and p.x>enemy.x and p.x<enemy.x+15) or enemy.atk==true)) then
			--right
			enemy.atkx=enemy.x+8
			enemy.atky=enemy.y
			enemy.atk=true
			enemy.atkdir=1
			enemy.flipy=false
			enemy.atkspr=13
			
		elseif (enemy.dir==2 and ((p.x==enemy.x and p.y>enemy.y and p.y<enemy.y+15) or enemy.atk==true)) then
			--down
			enemy.atkx=enemy.x
			enemy.atky=enemy.y+8
			enemy.atk=true
			enemy.atkdir=-1
			enemy.flipy=true
			enemy.atkspr=14
			
		elseif (enemy.dir==3 and ((p.y==enemy.y and p.x<enemy.x and p.x>enemy.x-15) or enemy.atk==true)) then
			--left
			enemy.atkx=enemy.x-8
			enemy.atky=enemy.y
			enemy.atk=true
			enemy.atkdir=-1
			enemy.flipy=false
			enemy.atkspr=13
			
		elseif (enemy.dir==4 and ((p.x==enemy.x and p.y<enemy.y and p.y>enemy.y-15) or enemy.atk==true)) then
			--up
			enemy.atkx=enemy.x
			enemy.atky=enemy.y-8
			enemy.atk=true
			enemy.atkdir=1
			enemy.flipy=false
			enemy.atkspr=14
		else
			enemy.atk=false
		end
		
		--atk timer
		if enemy.atk then
			enemy.atktimer+=1
			if enemy.atktimer==45 then	
				--player in range
				if (enemy.dir==1 and (p.y==enemy.y and p.x>enemy.x and p.x<enemy.x+15)) then
					--right
					enemy.atktimer=0
				elseif (enemy.dir==2 and (p.x==enemy.x and p.y>enemy.y and p.y<enemy.y+15)) then
					--down
					enemy.atktimer=0
				elseif (enemy.dir==3 and (p.y==enemy.y and p.x<enemy.x and p.x>enemy.x-15)) then
					--left
					enemy.atktimer=0
				elseif (enemy.dir==4 and (p.x==enemy.x and p.y<enemy.y and p.y>enemy.y-15)) then
					--up
					enemy.atktimer=0
				else				
					enemy.atk=false
				end
			end
		else
			enemy.atktimer=0
		end
		
		--movement
		if enemy.atk==false then
		
			if enemy.y==16 then
				--at top of screen
				if enemy.x>-16 then
					enemy.x-=0.5
				else
					enemy.exist=false
				end
			else
				--right
				if enemy.dir==1 then
					enemy.sprdir=1
					enemy.atkdir=1
					enemy.atkspr=13
					
					if (not map_collision((enemy.x+8)\8+(16*screen),
					(enemy.y)\8,0)) and (enemy.x+7<127) then
						enemy.x+=0.5
					elseif not (enemy.x%8==0) then
						enemy.x+=0.5				
					else
						pick_dir(enemy)
					end
				
				--down
				elseif enemy.dir==2 then
					enemy.sprdir=1
					enemy.atkdir=1
					enemy.atkspr=14
					
					if (not map_collision((enemy.x)\8+(16*screen),
					(enemy.y+8)\8,0)) and (enemy.y+7<127) then
						enemy.y+=0.5
					elseif not (enemy.y%8==0) then
						enemy.y+=0.5				
					else
						pick_dir(enemy)
					end
				
				--left
				elseif enemy.dir==3 then
					enemy.sprdir=-1
					enemy.atkdir=-1
					enemy.atkspr=13
					
					if (not map_collision((enemy.x-8)\8+(16*screen),
					(enemy.y)\8,0)) and (enemy.x-7>0) then
						enemy.x-=0.5
					elseif not (enemy.x%8==0) then
						enemy.x-=0.5				
					else
						pick_dir(enemy)
					end
				
				--up
				elseif enemy.dir==4 then
					enemy.sprdir=-1
					enemy.atkdir=-1
					enemy.atkspr=14
					
					if (not map_collision((enemy.x)\8+(16*screen),
					(enemy.y-8)\8,0)) and (enemy.y-7>16) then
						enemy.y-=0.5
					elseif not (enemy.y%8==0) then
						enemy.y-=0.5				
					else
						pick_dir(enemy)
					end
				
				end
		
			end
		
		end
	
	end 
end

function pick_dir(enemy)

	if (abs((enemy.x+8-p.x))<abs(enemy.x-p.x)) and (not map_collision((enemy.x+8)\8+(16*screen),
		(enemy.y)\8,0)) then
		--right
		enemy.dir=1
	elseif (abs((enemy.y+8-p.y))<abs(enemy.y-p.y)) and (not map_collision((enemy.x)\8+(16*screen),
		(enemy.y+8)\8,0)) then
		--down
		enemy.dir=2
	elseif (abs((enemy.x-8-p.x))<abs(enemy.x-p.x)) and (not map_collision((enemy.x-8)\8+(16*screen),
		(enemy.y)\8,0)) then
		--left
		enemy.dir=3
	elseif (not map_collision((enemy.x)\8+(16*screen),
		(enemy.y-8)\8,0)) then
		--up
		enemy.dir=4
	elseif (not map_collision((enemy.x+8)\8+(16*screen),
		(enemy.y)\8,0)) then
		--right
		enemy.dir=1
	elseif (not map_collision((enemy.x)\8+(16*screen),
		(enemy.y+8)\8,0)) then
		--down
		enemy.dir=2
	elseif (not map_collision((enemy.x-8)\8+(16*screen),
		(enemy.y)\8,0)) then
		--left
		enemy.dir=3
	elseif (not map_collision((enemy.x)\8+(16*screen),
		(enemy.y-8)\8,0)) then
		--up
		enemy.dir=4
	end

end

function draw_enemy()
	foreach(enem,draw_enem)
end

function draw_enem(enemy)
	
	if enemy.exist then
		spr(enemy.spr,enemy.x,enemy.y,1,1,enemy.sprdir==-1)
		
		if enemy.type==2 then
			
		end
		
		if (enemy.atk==true and enemy.atktimer<15) then
			spr(enemy.atkspr,enemy.atkx,enemy.atky,1,1,enemy.atkdir==-1,enemy.flipy)
		end
	else
		del(enem,enemy)
	end
end
-->8
function init_life()
	life=2
end

function update_life()

end

function draw_life()
	for i=0,life,1 do
		spr(0,8*i,0)
	end
end
__gfx__
006660000066600000066000006600000006600000006600000000000000000000333330000000000000c0000000000000000000000aa9889000908000000000
0666660006666600006666000666600000666600000666600088880000000000073333330000000000006c0000000088888000000a9888009800808900000000
6666666066666660066666606666660006666660006666660888888000000000717360600000000000006c000000888888880090a88888889808808900000000
666171706661717006666668666666800671176000671176897997980979979007330000000000000000c0000008888889888090aa9888009888889a00000000
066611000666118006666660666666000611116000611116897887980979979088333333000000000000c000008888889988899000a98880a988889000000000
0616668088118888016666101666610001666610001666610888888000900900888333300cc00000000c60000088888979888990000a98880a8889a000000000
881188880666668001666610166661008886661008886661008888000000000038833333c66cc66c000c600008888899778888000000aa990099800000000000
06600680660000600000068006000800086000000080006009900990000000000330033000000cc00000c000088889779888880000000000000a900000000000
44444444bbbbbbbb0000000000333330000000000000000000000000000000000000000000000000000000000888999788888800000000000000000000000000
44444444bbbbbbbb0088880003333333000000000000000000000000000000000000000000000000000000000088888888888000000000000000000000000000
44444444bbbbbbbb0888888030333030000000000000000000000000000000000000000000000000000000000088888888888000000000000000000000000000
44444444bbbbbbbb8000000803330000000000000000000000000000000000000000000000000000000000000008888888880000000000000000000000000000
44444444bbbbbbbb8008800833333333000000000000000000000000000000000000000000000000000000000000088888000000000000000000000000000000
44444444bbbbbbbb0888888033333330000000000000000000000000000000000000000000000000000000000000000990000000000000000000000000000000
44444444bbbbbbbb0088880033333333000000000000000000000000000000000000000000000000000000000000099990000000000000000000000000000000
44444444bbbbbbbb0880088003300330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a411100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00141610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00511110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000404000000000001020408000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030301030103030301030101010303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1030101030101030101030101010303010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1030101030101030101030101010301010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1030101030101030101030303010303010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101000101010101000001310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101012101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101000120000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
