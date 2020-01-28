-- for loops in lua:
-- ipairs starts at element 1, goes up 1 at a time and stops when it finds a nil
-- pairs goes through all the elements with values
-- and of course also the standanrd loop: for i=1,10 do print(i) end

buttons_machine = {"P1 A","P1 B","P1 Z","P1 A Up","P1 A Down","P1 A Left","P1 A Right","P1 L","P1 R"} 
-- just call them P1 x, and A for analogic directions, the emulator associate it to the real button 
button_show = {"Accelerate","Brake","Item","Up","Down","Left","Right","L","Drift"}   -- those are the buttons that we will see at the screen
number_of_buttons = #buttons_machine

--some colors
white  = 0xFFFFFFFF
twhite = 0x35FFFFFF
bwhite = 0x60FFFFFF
black  = 0xFF000000
purple = 0xFF9B30FF
red    = 0xFFFF0000
none   = 0x00000000
transparent_off  = 0x90000000

function round(num)
  return math.floor(num + 0.5)
end

--adapted functions from Nick Nelson
function load_track() -- carrega a pista
        the_stage = {}
        for ground = stage.init,stage.init + 81920, 44 do
        -- I tried different values for the end of this for loop, and I find out that it dont load the tracks entirely with 70000(like rainbow road and koopa troopa beach). So Im using 81920, works fine
         -- here it is fragmented in three parts, so it reads the x y z axis with an offset compared to the last part, for example sec2 go to 0x15+0x4(0x19) in Z axis, so the sec3 will start at 0x19
         --why this function exists? A:That's because I didnt find the address that shows us where the colisions ends
        local div = {}
        div.p1 = {}
        div.p2 = {}
        div.p3 = {}
      
        local the_attribute = mainmemory.read_s16_be(ground + 0x2)--0x2

        if (the_attribute == stage.ground_type) then
        div.attribute = the_attribute 

      
        local p1_addr = mainmemory.read_s24_be(ground + 0x11)
        local p2_addr = mainmemory.read_s24_be(ground + 0x15)
        local p3_addr = mainmemory.read_s24_be(ground + 0x19)

          div.p1.x = mainmemory.read_s16_be(p1_addr)
          div.p1.y = mainmemory.read_s16_be(p1_addr + 0x2)
          div.p1.z = mainmemory.read_s16_be(p1_addr + 0x4)
          div.p2.x = mainmemory.read_s16_be(p2_addr)
          div.p2.y = mainmemory.read_s16_be(p2_addr + 0x2)
          div.p2.z = mainmemory.read_s16_be(p2_addr + 0x4)
          div.p3.x = mainmemory.read_s16_be(p3_addr)
          div.p3.y = mainmemory.read_s16_be(p3_addr + 0x2)
          div.p3.z = mainmemory.read_s16_be(p3_addr + 0x4)

      the_stage[#the_stage + 1] = div
        end 
        --can map other textures at the same time, even though the div is the same, it allows
        --get tile attribute to map it
        if (the_attribute == stage.second_ground_type) then
          div.attribute = stage.second_ground_type
  
        
          local p1_addr = mainmemory.read_s24_be(ground + 0x11)
          local p2_addr = mainmemory.read_s24_be(ground + 0x15)
          local p3_addr = mainmemory.read_s24_be(ground + 0x19)
  
            div.p1.x = mainmemory.read_s16_be(p1_addr)
            div.p1.y = mainmemory.read_s16_be(p1_addr + 0x2)
            div.p1.z = mainmemory.read_s16_be(p1_addr + 0x4)
            div.p2.x = mainmemory.read_s16_be(p2_addr)
            div.p2.y = mainmemory.read_s16_be(p2_addr + 0x2)
            div.p2.z = mainmemory.read_s16_be(p2_addr + 0x4)
            div.p3.x = mainmemory.read_s16_be(p3_addr)
            div.p3.y = mainmemory.read_s16_be(p3_addr + 0x2)
            div.p3.z = mainmemory.read_s16_be(p3_addr + 0x4)
  
        the_stage[#the_stage + 1] = div
          end 
        end 
end
function get_tiles()
  tiles = {}
-- x and z are the axis to be mapped
-- in tracks like Choco mountain its good to control from where to where you want to map, because it picks the track above you
-- before the big curve, since its really low height. You can also control that in the in_div function by height, using the real_time_y_map.
  for z = -165, 165, 30 do
    for x = 344, 0, -30 do
      local tile = {}
      tile.n = #tiles + 1
      tile.x = x * kart_cos - z * kart_sen + kart_x
      tile.z = x * kart_sen + z * kart_cos + kart_z
      tile.t = get_tile_attribute(tile.x, tile.z)
      tiles[#tiles + 1] = tile
    end
  end
end

function get_tile_attribute(x, z)
  --goes through every part of the track and return its value on x and z
 local cont = 1
    for cont, div in ipairs(the_stage) do
    if in_div(x, z, div) then
      return div.attribute
    end 
  end 
return -1
end 

function in_div(x, z, s)
  -- the Y_map variable is the value of the Y axis that will be mapped, dont forget that if you set it as a high value it will map the track above you.
  -- Rainbow road can't take 70, as far as I remember it works fine with 100, but don't do that in other tracks.
  local y_map = 70
  local b1 = track_sign(x, z, s.p1,   s.p2)  < 0
  local b2 = track_sign(x, z, s.p2,   s.p3)  < 0
  local b3 = track_sign(x, z, s.p3, s.p1)    < 0
  local b4 = s.p1.y   > kart_y - y_map and s.p1.y   < kart_y + y_map
  local b5 = s.p2.y   > kart_y - y_map and s.p2.y   < kart_y + y_map
  local b6 = s.p3.y > kart_y - y_map and s.p3.y < kart_y + y_map
  local b7 = ((b1 == b2) and (b2 == b3)) and b4 and b5 and b6
  return b7
end

function track_sign(x, z, p2, p3)
  return (x - p3.x) * (p2.z - p3.z) - (p2.x - p3.x) * (z - p3.z)
end

-- showing data in the emulator screen while playing, and the control system with a really simple form

function display_info()
  gui.drawBox(-1, 152, 170, 270, none, twhite)
  gui.drawText(-2, 152, "Generation:"..pop.generation, black, none)
  gui.drawText(-1, 212, "Desempenho:".. round(fitness), black, none)
  gui.drawText(-1, 224, "Melhor desempenho:"..round(global_max_fitness), black, none)
  gui.drawText(-1, 188, "Genoma.pop:"..pop.member.."/"..population, black, none)
  gui.drawText(-1, 200,"Velocidade:".. round(kart_speed).."km/h",black, none)
  gui.drawText(-1, 164,"Especie:"..pop.current_species,black,none)
  gui.drawText(-1, 176,"Genoma.esp:"..pop.current_genome,black,none)
end

function create_form() -- Botões do form
  form = forms.newform(250, 200, "Smart Kart Setup")
  display_interface = forms.checkbox(form, "Display interface", 5, 5)
  display_pop_info = forms.checkbox(form, "Display pop info", 5, 25)
  hide_phosu = forms.checkbox(form,"Hide Phosu",5, 45)
  load_save_backup = forms.textbox(form, "Coloque o nome do arquivo aqui.txt", 180, 30, nil, 5, 73)
  save_button = forms.button(form, "Save", save_data, 5, 95)
  load_button = forms.button(form, "Load", load_data, 85, 95)
  replay_best_button = forms.button(form, "Replay Best", replay_best, 5, 125)
  next_genome_button = forms.button(form, "Skip genome", skip_current_genome, 85, 125)

end

function forms_checkbox()
  if  forms.ischecked(display_interface) then
  show_network()
  end

  if not forms.ischecked(hide_phosu) then --if you are curious that only draw phos from houseki no kuni in the screen,if the image is at your local c.
  gui.drawImage("C:\\phos.png",170, 90, 155, 150)
  end

  if forms.ischecked(display_pop_info) then
  display_info()
  end
end

function clear_controller()
  controller = {}
  for i = 1, #buttons_machine do
    local button = buttons_machine[i]
    controller[button] = false
  end
end

function skip_current_genome()
  next_genome(true)
  initialize_run(false)
end

function next_genome()
  pop.member = pop.member + 1
  pop.current_genome = pop.current_genome + 1
end


function show_network()
  --the neural network track sight
  local cell_border = black
  local cell_fill = white

  gui.drawBox(92-box_radius*5-1, 80-box_radius*5-1, 92+box_radius*5+1, 80+box_radius*5+1,black, bwhite)--the big 12x12 box

  for x = -box_radius, box_radius - 1 do -- tiles
    for z = -box_radius, box_radius - 1 do
      cell_border = black
    -- for cont, 50, 1 do 
    --if tiles[i].t == cont then -- trying to find the values of textures like grass and sand
    --  cell_fill = white
    --end
    --end

    -- making it red everytime it gets higher than 50km/h
    -- elseif tiles[i].t == stage.ground_type and kart_speed > 50 then 
    --cell_fill = red
    -- controller[1] = false -- stop accelerating when it reachs 50km/h even if it wants to keep accelerating
      if tiles[i].t == stage.ground_type then
          cell_fill = 0xFFFFDEAD --navajowhite, you can put the color you want of course  
        else
          cell_border = none
          cell_fill = none
      end
 

     gui.drawBox(92+x*5, 80+z*5, 92+x*5+5, 80+z*5+5, cell_border, cell_fill) --draw the "pixel" in the 12x12 box
    end
  end
  gui.drawBox(90,106,94,110,none,red)--draw your character at the center, since it will be always on center and 
   -- remap the track by sine and cosine
 end

function update_ground_type()
  --Examples of recalling the load_track to change the kind of ground being mapped
  --Sherbet land 666 distance per lap, 12 in ram address, check the other .lua file in this repository
  if stage.present == 12 then
  if (distance > 270 and distance < 508) or (distance > 936 and distance < 1174) or (distance > 1602 and distance < 1840)then
  stage.ground_type = 5 -- in cave
  else stage.ground_type = 9 --out of cave
  end
  end

  --Frappe Snowland 648 distance per lap, 5 in ram address
  if stage.present == 5 then
  if (distance > 598 and distance < 625) or (distance > 1240 and distance < 1260) or (distance > 1890 and distance < 1921)  then
    load_track()
    stage.ground_type = 0x11 -- in bridge
  else stage.ground_type = 0x5 -- out of bridge
  end 
  if (distance > 625 and distance < 630) or (distance > 1260 and distance < 1270) or (distance > 1921 and distance < 1926)  then
      load_track() --reload the track when its passing through the bridge with the new ground_type refreshed above.
  end
  end
end
 
