Import evolveordie

Class EvolveOrDieGame Extends App
	
	Field player:Player
	Field cam:Camera
	
	Field plants:List<PlantLife>
	Field max_plants:Int
	Field max_poison:Int
	Field poison_count:Int
	
	Field map_width:Float
	Field map_height:Float
	
	Method OnCreate()
		SetUpdateRate(60)
		
		map_width = 1000
		map_height = 1000
		
		max_plants = 100
		max_poison = 20
		poison_count = 0
		plants = New List<PlantLife>()
		player = New Player("Me", 320, 240, 4.0)
		cam = New Camera( )
		GeneratePlants()
		' Set the random seed for this instance of the game
		Seed = Millisecs()
	End
	
	Method OnUpdate()
		If TouchDown(0)
			player.SetTarget(TouchX(0) - cam.position.x, TouchY(0) - cam.position.y)
		End
		cam.Update(player.velocity)
		player.Update()
		EatPlant()
		GeneratePlants()
	End
	
	Method OnRender()
		Cls(255, 255, 255)
		PushMatrix()
		Translate(cam.position.x, cam.position.y)
		player.Draw()
		
		For Local plant:PlantLife = Eachin plants
			plant.Draw()
		End
		PopMatrix()
	End
	
	Method GeneratePlants()
		Local plant_count:Int = plants.Count()
		If plant_count < max_plants
			For Local i:Int = plant_count Until max_plants
				Local xpos:Float = Rnd(25.0, map_width - 20)
				Local ypos:Float = Rnd(25.0, map_height - 20)
				Local poison_chance:Float = Rnd(1.0, 10.0)
				Local poisonous:Int = 0
				If (poison_chance > 9.0) And (poison_count < max_poison)
					poisonous = 1
					poison_count += 1
				End
				
				plants.AddLast(New PlantLife("plant", xpos, ypos, 1, 1, poisonous))
			End
		End
	End
	
	Method EatPlant()
		For Local plant:PlantLife = Eachin plants
			If player.box.Collide(plant.box)
				plants.Remove(plant)
				If plant.poisonous
					If player.size > 1
						player.size -= 1
						poison_count -= 1
					End
				Else
					player.exp += plant.exp
				End
			End
		End
	End
End

Function Main()
	New EvolveOrDieGame()
End