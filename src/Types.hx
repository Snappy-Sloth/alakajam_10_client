enum EP {
	@x(0.33333) @y(0) North_1;
	@x(0.66666) @y(0) North_2;
	@x(0.33333) @y(1) South_1;
	@x(0.66666) @y(1) South_2;
	@x(0) @y(0.33333) West_1;
	@x(0) @y(0.66666) West_2;
	@x(1) @y(0.33333) East_1;
	@x(1) @y(0.66666) East_2;
}

typedef PlayerData = {
	var scores : Array<Int>;
	var maxLevelReached : Int;
}

enum ExternalEPType {
	Entrance;
	Exit;
	Closed;
}

enum VolumeGroup {
	@volume(1) OverButton;
	@volume(1) ClickButton;
	@volume(1) WavesAmbient;
	@volume(1) FireworkLaunch;
	@volume(0.75) Firework;
	@volume(0.6) WooshExchange;
	@volume(0.75) ShipsMoving;
}