class_name Levenshtein

## Takes two [String]s as parameters and returns an [int] representing their distance
## between each other.
##
## If either of the input [String]s have length of 0, the function returns 128.
static func distance(a: String, b: String) -> int:
	var len_a := a.length()
	var len_b := b.length()

	if len_a == 0:
		return 128
	if len_b == 0:
		return 128

	var matrix := []
	for i in range(len_a + 1):
		matrix.append([])
		for j in range(len_b + 1):
			matrix[i].append(0)

	for i in range(len_a + 1):
		matrix[i][0] = i
	for j in range(len_b + 1):
		matrix[0][j] = j

	for i in range(1, len_a + 1):
		for j in range(1, len_b + 1):
			var cost := 0 if a[i - 1] == b[j - 1] else 1
			matrix[i][j] = min(
				matrix[i - 1][j] + 1,
				matrix[i][j - 1] + 1,
				matrix[i - 1][j - 1] + cost
			)
	return matrix[len_a][len_b]
