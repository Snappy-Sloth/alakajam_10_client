

class Ship extends dn.Process {

	public var currentMapTile : Null<MapTile> = null;
	public var currentRoad : Null<Road> = null;
	public var from : EP;
	public var to : EP;
	var currentRoadRatio : Float = 0;

	// var speed = 0.5;
	var speed = 1;

	var level : Level;

	var spr : HSprite;

	// QuestData
	public var start_mp : MapTile;
	public var start_ep : EP;

	public var quest_id : Int = -1;
	public var quest_mp : MapTile;
	public var quest_ep : EP;
	var sprQuestGoal : HSprite;

	public var isEnable = false;

	var rotationWanted = 0.;

	public function new(level:Level) {
		super(level);

		this.level = level;

		createRootInLayers(level.wrapperGameZone, Const.DP_SHIP);

		// var bmp = new h2d.Bitmap(h2d.Tile.fromColor(0x00FF00, 11, 7));
		// root.addChild(bmp);
		spr = Assets.tiles.h_get("ship", 0.5, 0.5, root);
	}

	public function setInitialPosition(mp:MapTile, ep:EP) {
		start_mp = mp;
		start_ep = ep;
		
		currentRoadRatio = 0;

		root.setPosition(	start_mp.x + Road.getEpX(start_ep) - (Const.MAP_TILE_SIZE >> 1) ,
							start_mp.y + Road.getEpY(start_ep) - (Const.MAP_TILE_SIZE >> 1));

		switch (start_ep) {
			case North_1, North_2 :
				rotationWanted = Math.PI / 2;
				// root.y -= 10;
			case South_1, South_2 :
				rotationWanted = -Math.PI / 2;
				// root.y += 10;
			case West_1, West_2 :
				rotationWanted = 0;
				// root.x -= 10;
			case East_1, East_2 :
				rotationWanted = Math.PI;
				// root.x += 10;
		}

		spr.rotation = rotationWanted;

		if (quest_id == -1) {
			for (i in 0...9) {
				var isAvailable = true;
				for (ship in level.ships) {
					if (ship.quest_id == i) {
						isAvailable = false;
						break;
					}
				}
				if (isAvailable) {
					quest_id = i;
					break;
				}	
			}
		}

		var questMarkSprite = Assets.tiles.h_get("questMark", quest_id, 0.5, 1, root);
		questMarkSprite.setPosition(0, -10);
		
		root.alpha = 1;
		isEnable = false;
	}

	public function initQuest(mp:MapTile, ep:EP) {
		quest_mp = mp;
		quest_ep = ep;

		sprQuestGoal = level.addQuestGoal(mp, ep, quest_id);
	}

	@:allow(MapTile)
	function addToRoad(r:Road, from:EP) {
		// Set on Road
		currentRoadRatio = 0;
		currentRoad = r;
		currentMapTile = r.mapTile;
		this.from = from;
		to = from == r.pointA ? r.pointB : r.pointA;
		root.setPosition(Road.getEpX(from) + currentMapTile.x - (Const.MAP_TILE_SIZE >> 1), Road.getEpY(from) + currentMapTile.y - (Const.MAP_TILE_SIZE >> 1));
	}

	function reachEnd() {
		level.onShipReachingEnd(this);
	}

	public function disappear(onEnd:Void->Void) {
		isEnable = false;
		
		level.tw.createS(root.alpha, 0, 0.5).onEnd = onEnd;
		var dist = 5;
		switch (quest_ep) {
			case North_1, North_2: 
				rotationWanted = -Math.PI / 2;
				level.tw.createS(root.y, root.y - dist, 0.5);
			case South_1, South_2:
				rotationWanted = Math.PI / 2;
				level.tw.createS(root.y, root.y + dist, 0.5);
			case West_1, West_2:
				rotationWanted = Math.PI;
				level.tw.createS(root.x, root.x - dist, 0.5);
			case East_1, East_2:
				rotationWanted = 0;
				level.tw.createS(root.x, root.x + dist, 0.5);
		}
	}

	public override function onDispose() {
		super.onDispose();

		sprQuestGoal.remove();

		level.ships.remove(this);
	}

	public override function update() {
		super.update();

		if (currentRoad != null && isEnable) {
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

				rotationWanted = Math.atan2(Road.getEpY(to) - Road.getEpY(from), Road.getEpX(to) - Road.getEpX(from));
			}

			if (!cd.hasSetS("spout", 0.1))
				level.fx.showShipWaterMove(this, rotationWanted);
		}
		
		spr.rotation += (M.radSubstract(rotationWanted, spr.rotation)) * 0.1 * tmod;
	}

}