tool class_name Note extends Resource

const OCTAVE_FACTOR = pow(2, 1.0/12)

enum WAVES {
	SINE,TRIANGLE,SQUARE,SAW,NOISE
}

var key:int = -1 setget set_key, get_key
var pulse_hz:float
var phase:float = 0.0
var increment:float
var wave = WAVES.SINE


static func to_hertz(key):
	# 0 = C1
	return pow(OCTAVE_FACTOR, (key - 45)) * 440


func set_key(k):
	key = k
	pulse_hz = to_hertz(key)
	increment = pulse_hz / 11025


func get_key() -> int:
	return key


func frame() -> float:
	if key == -1:
		return 0.0
	
	var result:float
	
	match wave:
		WAVES.SINE:
			result = sin(phase * TAU)
		WAVES.TRIANGLE:
			result = abs(2 * (fmod(phase, 2) - 1)) - 1
		WAVES.SQUARE:
			result = sign(sin(phase * TAU))
		WAVES.SAW:
			result = fmod(phase, 2) - 1
		WAVES.NOISE:
			result = rand_range(0, 1)
		_:
			return 0.0
	
	phase = fmod(phase + increment, 1.0)
	return result

#sign(sin(phase * TAU))
#saw = fmod(2 * freq * t + phase, 2) - 1
