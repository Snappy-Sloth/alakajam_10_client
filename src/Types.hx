enum EP {
	@x(0.33) @y(0) North_1;
	@x(0.66) @y(0) North_2;
	@x(0.33) @y(1) South_1;
	@x(0.66) @y(1) South_2;
	@x(0) @y(0.33) West_1;
	@x(0) @y(0.66) West_2;
	@x(1) @y(0.33) East_1;
	@x(1) @y(0.66) East_2;
}

typedef PlayerData = {
	var scores : Array<Int>;
	var maxLevelReached : Int;
}