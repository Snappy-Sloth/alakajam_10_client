

class Ship extends dn.Process {

	public var currentMapTile : Null<MapTile> = null;
	public var currentRoad : Null<Road> = null;
	public var from : EP;
	public var to : EP;
	var currentRoadRatio : Float = 0;

	var speed = 0.25;

	var level : Level;

	public function new(level:Level) {
		super(level);

		this.level = level;

		createRootInLayers(@:privateAccess level.wrapperMapTile, Const.DP_FRONT);

		var bmp = new h2d.Bitmap(h2d.Tile.fromColor(0x00FF00, 11, 7));
		root.addChild(bmp);
	}

	@:allow(MapTile)
	function addToRoad(r:Road, from:EP) {
		currentRoadRatio = 0;
		currentRoad = r;
		currentMapTile = r.mapTile;
		this.from = from;
		to = from == r.pointA ? r.pointB : r.pointA;
		root.setPosition(r.getEpX(from) + currentMapTile.x - (Const.MAP_TILE_SIZE >> 1), r.getEpY(from) + currentMapTile.y - (Const.MAP_TILE_SIZE >> 1));
	}

	function reachEnd() {
		level.onShipReachingEnd(this);
	}

	public override function onDispose() {
		super.onDispose();

		currentMapTile.removeShip(this);
	}

	public override function update() {
		super.update();

		currentRoadRatio = currentRoadRatio + (speed / currentRoad.distance) * tmod;
		if (currentRoadRatio >= 1) {
			currentRoadRatio = 1;
			root.setPosition(	currentRoad.getEpX(from) + (currentRoad.getEpX(to) - currentRoad.getEpX(from)) * currentRoadRatio + currentMapTile.x - (Const.MAP_TILE_SIZE >> 1),
								currentRoad.getEpY(from) + (currentRoad.getEpY(to) - currentRoad.getEpY(from)) * currentRoadRatio + currentMapTile.y - (Const.MAP_TILE_SIZE >> 1));
			reachEnd();
		}
		else {
			root.setPosition(	currentRoad.getEpX(from) + (currentRoad.getEpX(to) - currentRoad.getEpX(from)) * currentRoadRatio + currentMapTile.x - (Const.MAP_TILE_SIZE >> 1),
								currentRoad.getEpY(from) + (currentRoad.getEpY(to) - currentRoad.getEpY(from)) * currentRoadRatio + currentMapTile.y - (Const.MAP_TILE_SIZE >> 1));
		}

	}

}