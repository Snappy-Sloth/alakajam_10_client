

class Ship extends dn.Process {

	var currentMapTile : Null<MapTile> = null;
	var currentRoad : Null<Road> = null;
	var currentRoadRatio : Float = 0;

	var speed = 0.5;

	public function new(level:Level) {
		super(level);

		createRoot();

		var bmp = new h2d.Bitmap(h2d.Tile.fromColor(0x00FF00, 11, 7));
		root.addChild(bmp);
	}

	public function addToRoad(r:Road) {
		currentRoad = r;
		root.setPosition(r.fromX, r.fromY);
	}

	public override function update() {
		super.update();

		currentRoadRatio = currentRoadRatio + (speed / currentRoad.distance);
		// currentRoadRatio = ((currentRoadRatio * currentRoad.distance) + speed) / currentRoad.distance;
		currentRoadRatio = hxd.Math.clamp(currentRoadRatio, 0, 1);
		root.setPosition(currentRoad.fromX + (currentRoad.toX - currentRoad.fromX) * currentRoadRatio, currentRoad.fromY + (currentRoad.toY - currentRoad.fromY) * currentRoadRatio);
		root.setPosition(root.x - (Const.MAP_TILE_SIZE >> 1), root.y - (Const.MAP_TILE_SIZE >> 1));
	}

}