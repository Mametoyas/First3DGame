extends Label
var rainbow_hue: float = 0.0  # stores hue value

func _process(delta: float) -> void:
	rainbow_hue += delta * 0.5  # Adjust speed here
	if rainbow_hue > 1.0:
		rainbow_hue -= 1.0

	# Convert HSV to RGB
	var rainbow_color = Color.from_hsv(rainbow_hue, 1.0, 1.0)
	label_settings.font_color = rainbow_color
