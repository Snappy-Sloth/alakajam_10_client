

class Ship extends dn.Process {

	public var currentMapTile : Null<MapTile> = null;
	public var currentRoad : Null<Road> = null;
	public var from : EP;
	public var to : EP;
	var currentRoadRatio : Float = 0;

	var speed = 0.1;

	var level : Level;

	var spr : HSprite;

	// QuestData
	var qd_id : Int;
	var qd_cx : Int;
	var qd_cy : Int;
	var qd_ep : EP;

	public function new(level:Level) {
		super(level);

		this.level = level;

		createRootInLayers(@:privateAccess level.wrapperMapTile, Const.DP_FRONT);

		// var bmp = new h2d.Bitmap(h2d.Tile.fromColor(0x00FF00, 11, 7));
		// root.addChild(bmp);
		spr = Assets.tiles.h_get("ship", 0.5, 0.5, root);
	}

	@:allow(MapTile)
	function addToRoad(r:Road, from:EP) {
		var alreadyExist = currentMapTile != null;

		// Set on Road
		currentRoadRatio = 0;
		currentRoad = r;
		currentMapTile = r.mapTile;
		this.from = from;
		to = from == r.pointA ? r.pointB : r.pointA;
		root.setPosition(Road.getEpX(from) + currentMapTile.x - (Const.MAP_TILE_SIZE >> 1), Road.getEpY(from) + currentMapTile.y - (Const.MAP_TILE_SIZE >> 1));

		// Set quest
		if (!alreadyExist) {
			do {
				qd_cx = Std.random(level.wid);
				qd_cy = Std.random(level.hei);
			} while (qd_cx == currentMapTile.cx && qd_cy == currentMapTile.cy);
	
			var mpQuest = level.getMapTileAt(qd_cx, qd_cy);
			qd_ep = mpQuest.getRandomExternalEP();
	
			for (i in 0...9) {
				var isAvailable = true;
				for (ship in level.allShipsOnScreen) {
					if (ship.qd_id == i) {
						isAvailable = false;
						break;
					}
				}
				if (isAvailable) {
					qd_id = i;
					break;
				}
			}
	
			var questMarkSprite = Assets.tiles.h_get("questMark", qd_id, 0.5, 1, root);
			questMarkSprite.setPosition(0, -10);
	
			level.addQuestGoal(qd_cx, qd_cy, qd_ep, qd_id);
		}
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
			root.setPosition(	Road.getEpX(from) + (Road.getEpX(to) - Road.getEpX(from)) * currentRoadRatio + currentMapTile.x - (Const.MAP_TILE_SIZE >> 1),
			Road.getEpY(from) + (Road.getEpY(to) - Road.getEpY(from)) * currentRoadRatio + currentMapTile.y - (Const.MAP_TILE_SIZE >> 1));
			reachEnd();
		}
		else {
			root.setPosition(	Road.getEpX(from) + (Road.getEpX(to) - Road.getEpX(from)) * currentRoadRatio + currentMapTile.x - (Const.MAP_TILE_SIZE >> 1),
			Road.getEpY(from) + (Road.getEpY(to) - Road.getEpY(from)) * currentRoadRatio + currentMapTile.y - (Const.MAP_TILE_SIZE >> 1));
		}

		spr.rotation = Math.atan2(Road.getEpY(to) - Road.getEpY(from), Road.getEpX(to) - Road.getEpX(from));
	}

}