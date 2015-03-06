Import Mojo

Const BASE_SIZE:Int = 5

Class Vec2D
	Field x:Float
	Field y:Float
	
	Method New(x:Float, y:Float)
		Set(x, y)
	End
	
	Method Set(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End
	
	Method Distance(point:Vec2D)
		Local xdelta:Float = point.x - Self.x
		Local ydelta:Float = point.y - Self.y
		
		Return Sqrt(xdelta * xdelta + ydelta * ydelta)		
	End
	
End

Class Player

	Field name:String
	Field position:Vec2D
	Field old_position:Vec2D
	Field velocity:Vec2D
	Field target:Vec2D
	Field distance:Float

	Field size:Int
	Field exp:Int
	Field speed:Float
	Field rotation:Float
	
	Method New(name:String, position:Vec2D, speed:Float)
		Self.name = name
		Self.position = position
		Self.old_position = New Vec2D(position.x, position.y)
		Self.speed = speed
		
		Self.velocity = New Vec2D(0, 0)
		Self.size = 1
		Self.exp = 0
		Self.rotation = 0
		Self.distance = 0
	End
	
	Method Draw()
		SetColor(0, 255, 0)
		DrawRect(position.x, position.y, size * BASE_SIZE, size * BASE_SIZE)
		SetColor(255, 255, 255)
	End
	
	Method Update()
		Self.old_position.Set(position.x, position.y)
		Self.position.Set(position.x + velocity.x, position.y + velocity.y)
		If (target <> Null)
			If (position.Distance(target)) < distance
				distance = position.Distance(target)
			Else
				' we are not getting closer to the target anymore so stop moving
				velocity.Set(0, 0)
			End
		End
	End
	
	Method SetTarget(x:Float, y:Float)
		Self.target = New Vec2D(x, y)
		
		If (target.x > position.x)
			velocity.x = speed
		Else If (target.x < position.x)
			velocity.x = -speed
		End
		
		If (target.y > position.y)
			velocity.y = speed
		Else If (target.y < position.y)
			velocity.y = -speed
		End
		
		distance = position.Distance(target)
		
	End

End