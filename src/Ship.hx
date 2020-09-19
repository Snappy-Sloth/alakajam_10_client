

class Ship extends dn.Process {

	public var currentMapTile : Null<MapTile> = null;
	public var currentRoad : Null<Road> = null;
	public var from : EP;
	public var to : EP;
	var currentRoadRatio : Float = 0;

	var speed = 0.5;

	var level : Level;

	public function new(level:Level) {
		super(level);

		this.level = level;

		createRootInLayers(@:privateAccess level.wrapperMapTile, Const.DP_FRONT);

		var bmp = new h2d.Bitmap(h2d.Tile.fromColor(0x00FF00, 11, 7));
		root.addChild(bmp);
	}

	public function addToRoad(r:Road, from:EP) {
		currentRoad = r;
		currentMapTile = r.mapTile;
		this.from = from;
		to = from == r.pointA ? r.pointB : r.pointA;
		root.setPosition(r.getEpX(from), r.getEpY(from));
	}

	function reachEnd() {
		level.moveShip(this);
	}

	public override function update() {
		super.update();

		currentRoadRatio = currentRoadRatio + (speed / currentRoad.distance);
		if (currentRoadRatio >= 1) {
			reachEnd();
			currentRoadRatio = 1;
		}
		
		root.setPosition(currentRoad.getEpX(from) + (currentRoad.getEpX(to) - currentRoad.getEpX(from)) * currentRoadRatio, currentRoad.getEpY(from) + (currentRoad.getEpY(to) - currentRoad.getEpY(from)) * currentRoadRatio);
		root.setPosition(root.x - (Const.MAP_TILE_SIZE >> 1), root.y - (Const.MAP_TILE_SIZE >> 1));
	}

}