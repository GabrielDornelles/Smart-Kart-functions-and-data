function new_genome()
local genome = {}
genome.genes = {}
genome.network = {}
genome.num_neurons = num_inputs
genome.fitness = 0
genome.shared_fitness = 0
return genome
end

function new_gene(in_value, out_value, weight, enable, innovation_number)
local gene = {}
gene.in_node = in_value
gene.out_node = out_value
gene.weight = weight
gene.enable = enable
gene.innovation = innovation_number
return gene
end

function new_pop()
local pop = {}
pop.size = 200
pop.species = {}
pop.generation = 1
pop.current_species = 1
pop.current_genome = 0
pop.member = 0
pop.frame_count = 0
return pop
end

function new_species()
local species = {}
species.genomes = {}
species.age = 0
species.fitness = 0
species.last_fitness = 0
return species
end

function copy_genome(genome)
  copied_genome = new_genome()
    for i = 1, #genome.genes do
      table.insert(copied_genome.genes, copy_gene(genome.genes[i]))
    end
  copied_genome.num_neurons = genome.num_neurons
  copied_genome.fitness = genome.fitness
  copied_genome.shared_fitness = genome.shared_fitness
  return g2
end

function copy_gene(gene)
  local g2 = {}
  g2.in_node = gene.in_node
  g2.out_node = gene.out_node
  g2.weight = gene.weight
  g2.enable = gene.enable
  g2.innovation = gene.innovation
  return g2
end

function copy_all_species()
  local copied_species = {}
  for s = 1, #pop.species do
    local species = new_species()
    for g = 1, #pop.species[s].genomes do
      table.insert(species.genomes, copy_genome(pop.species[s].genomes[g]) )
    end
    table.insert(copied_species, species)
  end
  return copied_species
end

function mutate_weights(genome)
  for i = 1, #genome.genes do
    local n = math.random(-1,1)
    while n == 0 do
      n = math.random(-1,1)
  end
    genome.genes[i].weight = (genome.genes[i].weight + n * math.random() * 0.9)
end


function mutate_connection(genome)
  local n1 --in node
  local n2-- out node
  n1, n2 = random_neurons(genome)
  -- generate a new gene with a random weight 
  local new_gene = new_gene(n1, n2, math.random(),true, new_innovation(n1, n2))

  for k, gene in pairs(genome.genes) do
    if (gene.in_node == new_gene.in_node and
      gene.out_node == new_gene.out_node) then
      return
    end
  end
  table.insert(genome.genes, new_gene)
end

function mutate_node(genome)
  if #genome.genes == 0 then
    return
  end
  -- pick a "old" connection to split, its now old since there's a new connection
  local old_connection = genome.genes[math.random(1, #genome.genes)]
  old_connection.enable = false
  local n1 = old_connection.in_node
  local n2 = old_connection.out_node
  local new_node_ = new_neuron(genome)
  -- create two new connections where we had one, since the old connection has been splited
  local new_connection_1 = new_gene(n1, new_node, 1.0, true, new_innovation(n1, new_node))
  local new_connection_2 = new_gene(new_node, n2, old_connection.weight, true, new_innovation(new_node, n2))
  genome.num_neurons = genome.num_neurons + 1 -- the genome receive + 1 neuron, the node, so update it 
  table.insert(genome.genes, new_connection_1)
  table.insert(genome.genes, new_connection_2)
end

function mutate(genome)
  if math.random() < mutate_weights_chance then
    mutate_weights(genome)
  end
  --Adiciona 1 ou 2 conexoes ao genoma
  -- if you want to ACM just make math.random (2,4). It shows faster results, but that doesnt mean its good results. If you want to make a better random connection generation try
  -- to make a function that kind of "calculate" the out_node of the gene, if they are the same mutate more connections, that way you will have the same output depending of those connections.
  -- just in case I didnt developed this algorithm yet unfortunatelly for you reading.

  --for i = 1, math.random(1, 2) do
    mutate_connection(genome) -- only one connection, that way the topologie gets cleaner through the time 
  --end

  if math.random() < mutate_node_chance then
    for i = 1, math.random(1,1) do
      mutate_node(genome)
    end
  end

end

function excess_genes(genes1, genes2)
-- Calculate E(Excess) to the compatibility_distance
  local excess = 0
  local highest_1 = 0
  for i = 1, #genes1 do
    if genes1[i].innovation > highest_1 then
      highest_1 = genes1[i].innovation
    end
  end

  local highest_2 = 0
  for i = 1, #genes2 do
    if genes2[i].innovation > highest_2 then
      highest_2 = genes2[i].innovation
    end
  end
  if highest_1 > highest_2 then
    for i = 1, #genes1 do
      if genes1[i].innovation > highest_2 then
        excess = excess + 1

      end
    end
  else
    for i = 1, #genes2 do
      if genes2[i].innovation > highest_1 then
        excess = excess + 1
      end
    end
  end
  return excess
end

function disjoint_genes(genes1, genes2)
-- calculate D(Disjoint) to the compatibility_distance

  local disjoint = 0
  
  for i = 1, #genes1 do -- checking the first gene
    local found = false
    for j = 1, #genes2 do
      if genes1[i].innovation == genes2[j].innovation then
        found = true
        break
      end
    end
    if not found then
      disjoint = disjoint + 1
    end
  end

  for i = 1, #genes2 do --checking the second gene
    local found = false
    for j = 1, #genes1 do
      if genes2[i].innovation == genes2[j].innovation then
        found = true
        break
      end
    end
    if not found then
      disjoint = disjoint + 1
    end
  end
  return disjoint
end

function sum_of_weight_differences(genes1, genes2)
-- calculate the W(weight difference) to the compatibility_distance
  local sum_of_differences = 0
  for i = 1, #genes1 do
    for j = 1, #genes1 do
      if genes1[i].innovation == genes2[j].innovation then
        sum_of_differences = sum_of_differences + math.abs(genes1[i].weight - genes2[j].weight)
      end
    end
  end
  return sum_of_differences
end

function compatibility_distance(genes1, genes2)
  local E = excess_genes(genes1, genes2)
  local D = disjoint_genes(genes1, genes2)
  local N = math.max(#genes1, #genes2)
  if N < 20 then N = 1 end -- described on neat paper, that way it gets more demanding to small networks
  local W = sum_of_weight_differences(genes1, genes2)
  return c1*E/N + c2*D/N + c3*W
end

function artificial_selection()
  for s = 1, #old_pop.species do
    table.sort(old_pop.species[s].genomes, function(a,b)return (a.fitness > b.fitness) end)
    local stop = round(#old_pop.species[s].genomes * 0.2) -- select here how much you want to retain with artificial selection, with 0.2 it retains 20%
    if stop < 2 then stop = 2 end
    for g = #old_pop.species[s].genomes, stop, -1 do
      table.remove(old_pop.species[s].genomes)
    end
  end
end

 function refresh()
  --data to be refresh, velocites and kart current angle
  kart_x      = mainmemory.readfloat(0x0F69A4,true)
  kart_xv     = mainmemory.readfloat(0x0F69C4,true) * 12
  kart_z      = mainmemory.readfloat(0xF69AC,true)
  kart_zv     = mainmemory.readfloat(0x0F69CC,true) * 12
  kart_speed  = math.sqrt(kart_xv^2+kart_zv^2)
  kart_y      = mainmemory.readfloat(0xF69A8,true)
  kart_sen    = mainmemory.readfloat(0xF6B04,true)
  kart_cos    = mainmemory.readfloat(0xF6B0C,true)
  pop.frame_count = pop.frame_count + 1
  distance    = mainmemory.read_s16_be(0x16328A)
  real_time_y_map = math.abs(round(kart_y))
 end

--[[
           0xDC5A0 Values (fixed point 16:16 view)
          Mario Raceway = 0                
          Choco Mountain = 1
          Bowser Castle = 2
          Banshee Boardwalk = 3
          Yoshi Valley = 4
          Frappe Snowland = 5
          Koopa Troopa Beach = 6
          Royal Raceway = 7
          Luigi Raceway = 8
          Moo Moo Farm = 9
          Toad Turnpike = 10
          Kalamari Desert = 11   
          Sherbet Land = 12
          Rainbow Road = 13
          Wario Stadium = 14
          Donkey Kong Jungle parkway = 18   
          --]] 

       stage.present = mainmemory.read_u16_be(0xDC5A0) -- read the current track running in the game
       -- Address that shows us where the track starts : 0x11799C, i've mapped them on "signed" view, so make sure to display it on signed to look the values for other tracks
       
       if stage.present == 0 then  -- Mario Raceway
       stage.init = 1926560
       stage.ground_type = 1
       state_file = "SK_Mario_Raceway.state"
       end

       if stage.present == 1 then  -- Choco Mountain
       stage.init = 1917568
       stage.ground_type = 2
       state_file = "SK_Choco_Mountain.state"
       end

        if stage.present == 5 then -- Frappe Snowland
       stage.init = 1918544
       stage.ground_type = 0x5
       state_file = "SK_Frappe_Snowland.state"
       end
       
       if stage.present == 6 then -- Koopa Troopa Beach
       stage.init = 1991552
       stage.ground_type = 3
       end

       if stage.present == 7 then -- royal raceway
       stage.init = 1945424
       stage.ground_type = 0x1
       state_file = "SK_Royal_Raceway.state"
       end

       if stage.present == 12 then -- sherbet land
       stage.init = 1927792‬
       stage.ground_type = 9
       state_file = "SK_Sherbet_Land.state"
       end
       
       if stage.present == 8 then -- Luigi Raceway 
       stage.init = 1954240
       stage.ground_type = 1
       state_file = "SK_Luigi_Raceway.state"
       end
       
       if stage.present == 9 then -- Moo Moo farm 
       stage.init = 1971456
       stage.ground_type = 2
       state_file = "SK_Moo_Moo_Farm.state"
       end
       
       if stage.present == 11 then -- kalamari Desert 
       stage.init = 2031904
       stage.ground_type = 2
       state_file = "SK_Kalamari_Desert.state"
       end

       if stage.present == 13 then -- Rainbow Road 
       stage.init = 1978496
       stage.ground_type = 1
       state_file = "SK_Rainbow_Road.state"
       end

--[[
Map for colisions in the game, the ground_type above are using the main texture in the track, but you can change it as long as u create a good function to read the screen and map it

0x01: Solid. Used for pavement, tunnel walls and floor in Koopa Troopa Beach, and the track in Rainbow Road.
0x02: Dirt track in several courses, edge of water pools in Royal Raceway.
0x03: Dirt track used in Koopa Troopa Beach. Also used for the out-of-bounds beach sand.
0x04: Cement.
0x05: Snow track used in Frappe Snowland, and ice cave interior (except pillars) in Sherbet Land.
0x06: Wooden bridges and guardrails, and the bridge to the castle in Royal Raceway.
0x07: Dirt, off-road.
0x08: Grass, both in and out of bounds.
0x09: Ice, both in and out of bounds, used in Sherbet Land.
0x0A: Beach sand used in Koopa Troopa Beach, that is sometimes underwater.
0x0B: Snow, off-road.
0x0C: Rock walls. Also used for the chocolate walls (and not the rock ones) in Choco Mountain.
0x0D: Dirt, off road, used in Kalimari Desert.
0x0E: Train tracks and the dirt surrounding them.
0x0F: Interior of the cave in DK's Jungle Parkway.
0x10: Rickety wood/rope bridges.
0x11: Solid wooden bridges, like the bridge in Frappe Snowland(actually that's the only thing I found using it).
0xFC: Boost ramp used in DK's Jungle Parkway. When driving on this surface your speed is locked to about 60km/h.
0xFD: Out of bounds. Lakitu will pick you up when you land on this. Only used by the island in DK's Jungle Parkway.
0xFE: Boost ramp used in Royal Raceway. When driving on this surface your speed is locked and gravity is reduced.
0xFF: Solid, used for walls and the ramps in Koopa Troopa Beach.

reference for more: https://github.com/RenaKunisaki/mariokart64/wiki
]]

 track_scale = 0x0DC608 -- the Address that make it possible to scale the game to 10x or whatever

 function adjust_fitnesses()
  --calculate average by species in order to dont let any species grow too big
  for s = 1, #old_pop.species do
    for g = 1, #old_pop.species[s].genomes do
      local species = old_pop.species[s]
      local genome = species.genomes[g]
      genome.fitness = genome.fitness / #species.genomes
    end
  end

  function over_population()
  -- for now its pretty manual, and it needs to set the current_gen value to the current gen in the algorithm, also the decrease is set to take 3 generations to get back to 200
  -- taking 20% worst genomes to remove: 1gen> 400-80=320   2gen> 320-64=256  3gen> 256-51= 205
    local current_gen = 0
    local keep_tracking = 1
    flag_is_called = 1
  if flag_is_called == 1 then
    population = 400
    current_gen = current_gen + 1
  end
  local current_pop = population
  local over_population_decrease = round(current_pop * 0.2)
  if current_gen == pop.generation and keep_tracking < 4 then
  current_pop = current_pop - over_population_decrease
  keep_tracking = keep_tracking + 1 
  end
  if keep_tracking == 4 then
    current_pop = current_pop - 5 -- 205 to 200
    keep_tracking = keep_tracking + 1 -- keep_tracking at 5 and the over_population is over
    end 
  return current_pop 
end
