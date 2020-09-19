

class Ship extends dn.Process {

	var currentMapTile : Null<MapTile> = null;
	var currentRoad : Null<Road> = null;

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

}