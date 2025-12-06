extends Node2D

@onready var car: AnimatableBody2D = $Car
var screen_size: Vector2
var screen_height: int
var screen_width: int
const car_speed: int = 1
var car_range: int = 0


func _ready() -> void:
	screen_size = get_viewport_rect().size
	screen_height = screen_size.y / 2
	screen_width = screen_size.x

func _draw() -> void:
	for i in range(screen_height):
		# Handle calculating the y from top to down of the screen
		# Because using draw polygon then need 2 separate y
		var y1 = i + 1
		var y2 = y1 + 1
		
		# handle perspective percentage each y
		var perspective1: float =  0.1 + float(y1) / screen_height
		var perspective2: float = 0.1 + float(y2) / screen_height 
		
		# The percentage of the road 
		var middle_point = 0.5
		var road_half_base_width = 0.3
		var road_half_perspective_width = [road_half_base_width * perspective1, road_half_base_width * perspective2]
		var clip_base_width = road_half_base_width * 0.15
		var clip_perspective_width = [clip_base_width * perspective1, clip_base_width * perspective2]
		
		# each parts place on screen base from the percentage * screen
		# not in form like a range but rather the furthest point of the part
		var left_grass = [
			(middle_point - clip_perspective_width[0] - road_half_perspective_width[0]) * screen_width,
			(middle_point - clip_perspective_width[1] - road_half_perspective_width[1]) * screen_width
			]
		var left_clip = [
			(middle_point - road_half_perspective_width[0]) * screen_width,
			(middle_point - road_half_perspective_width[1]) * screen_width
			]
		var right_grass = [
			(middle_point + clip_perspective_width[0] + road_half_perspective_width[0]) * screen_width,
			(middle_point + clip_perspective_width[1] + road_half_perspective_width[1]) * screen_width
			]
		var right_clip = [
			(middle_point + road_half_perspective_width[0]) * screen_width,
			(middle_point + road_half_perspective_width[1]) * screen_width
			]
		
		# Polygon point for each layer of y
		var road_point: PackedVector2Array = ([
			Vector2(left_clip[0], screen_height + y1),
			Vector2(right_clip[0], screen_height + y1),
			Vector2(right_clip[1], screen_height + y2),
			Vector2(left_clip[1], screen_height + y2),
		])
		var left_grass_point: PackedVector2Array = ([
			Vector2(0, screen_height + y1),
			Vector2(left_grass[0], screen_height + y1),
			Vector2(left_grass[1], screen_height + y2),
			Vector2(0, screen_height + y2)
			])
			
		var right_grass_point: PackedVector2Array = ([
			Vector2(screen_width, screen_height + y1),
			Vector2(right_grass[0], screen_height + y1),
			Vector2(right_grass[1], screen_height + y2),
			Vector2(screen_width, screen_height + y2)
			])
			
		# we start the x from the right grass furthest point 
		var left_clip_point: PackedVector2Array = ([
			Vector2(left_grass[0], screen_height + y1),
			Vector2(left_clip[0], screen_height + y1),
			Vector2(left_clip[1], screen_height + y2),
			Vector2(left_grass[0], screen_height + y2)
			])
			
		var right_clip_point: PackedVector2Array = ([
			Vector2(right_grass[0], screen_height + y1),
			Vector2(right_clip[0], screen_height + y1),
			Vector2(right_clip[1], screen_height + y2),
			Vector2(right_grass[0], screen_height + y2)
			])

		# Color pallette
		var colors: PackedColorArray =[
			Color(0.5, 0.5, 0.5),
			Color(0, 1, 0),
			Color(0, 0.5, 0),
			Color(1, 0, 0)
			]
		
		var f_perspective: float = float(y1) / screen_height
		# distance travelled (your car_range)
		var f_distance: float = car_range
		# Grass color oscillation
		var grass_wave: float = sin(20.0 * pow(1.0 - f_perspective, 3) + f_distance)
		var grass_color
		if grass_wave > 0.0:
			grass_color = colors[2]
		else:
			grass_color = colors[1]

		# Clip (curb) color oscillation
		var clip_wave: float = sin(80.0 * pow(1.0 - f_perspective, 2) + f_distance)
		var clip_color
		if clip_wave > 0.0:
			clip_color = Color(1, 0, 0)
		else:
			clip_color = Color(1, 1, 1)


		draw_colored_polygon(road_point, colors[0])
		draw_colored_polygon(left_grass_point, grass_color)
		draw_colored_polygon(right_grass_point, grass_color)
		draw_colored_polygon(left_clip_point, clip_color)
		draw_colored_polygon(right_clip_point, clip_color)
		
		handle_car()


func _process(delta: float) -> void:
	queue_redraw()
	car_range += car_speed + delta
	print(car_range)

func handle_car() -> void:
	car.global_position = Vector2(screen_width / 2, 270)
