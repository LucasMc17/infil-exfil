@tool
class_name TestScript
extends EditorScript

const TEST_OBJS = [1, 2, 3]
const TEST_WEIGHTS : Array[float] = [10.0, 5.0, 8.5]


func _run() -> void:
	var one_count := 0
	var two_count := 0
	var three_count := 0
	for i in range(100):
		var result = Utilities.weighted_pick_random(TEST_OBJS, TEST_WEIGHTS, false)
		if result == 1:
			one_count += 1
		if result == 2:
			two_count += 1
		if result == 3:
			three_count += 1
	
	print("ONE: " + str(one_count))
	print("TWO: " + str(two_count))
	print("THREE: " + str(three_count))
			

