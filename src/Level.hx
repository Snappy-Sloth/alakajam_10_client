import hxd.Key;

class Level extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	public var wid(get,never) : Int; inline function get_wid() return width;
	public var hei(get,never) : Int; inline function get_hei() return height;

	var arMapTile : Array<MapTile>;
	var wrapperMapTile : h2d.Layers;

	var width : Int;
	var height : Int;

	var rightArrow : Arrow;
	var leftArrow : Arrow;

	var shipOnScreen(get, never) : Int; inline function get_shipOnScreen() {
		var i = 0;
		for (tile in arMapTile) {
			i += tile.ships.length;
		}
		return i;
	}

	var shipToSpawn = 3;
	var nextSpawnTiming : Float = 0;
	var spawnTiming : Float = 3;

	public function new(w, h) {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		createLevel(w, h);
	}

	override function onResize() {
		super.onResize();
		
		wrapperMapTile.setPosition(((w()/Const.SCALE-width*Const.MAP_TILE_SIZE)/2)+Const.MAP_TILE_SIZE/2,
									((h()/Const.SCALE-height*Const.MAP_TILE_SIZE)/2)+Const.MAP_TILE_SIZE/2);
	}

	public function createLevel(w, h) {
		arMapTile = [];
		width = w;
		height = h;

		wrapperMapTile = new h2d.Layers(root);
		
		var bg = Assets.tiles.h_get("bg", 0.5, 0.5);
		wrapperMapTile.add(bg, Const.DP_BG);
		bg.setPosition(Const.MAP_TILE_SIZE >> 1, Const.MAP_TILE_SIZE >> 1);

		for (i in 0...width) {
			for (j in 0...height) {
				var mapTile = new MapTile(i, j, this);
				wrapperMapTile.add(mapTile, Const.DP_MAIN);
				arMapTile.push(mapTile);
			}
		}

		rightArrow = new Arrow(true);
		leftArrow = new Arrow(false);
		wrapperMapTile.add(rightArrow, Const.DP_UI);
		wrapperMapTile.add(leftArrow, Const.DP_UI);
	}

	public function addArrows(mapTile:MapTile) {
		rightArrow.show(mapTile);
		leftArrow.show(mapTile);
	}

	public function removeArrows(mapTile:MapTile) {
		rightArrow.hide();
		leftArrow.hide();
	}

	public function spawnShip() {
		shipToSpawn--;
		var shuffleArMapTile = arMapTile.copy();
		Lib.shuffleArray(shuffleArMapTile, Std.random);

		for (tile in shuffleArMapTile) {
			var ep = tile.hasAnExternalEP();
			if (ep != null) {
				tile.spawnShipOnEP(ep);
				return;
			}
		}
	}

	public function onShipReachingEnd(s:Ship) {
		var nextTile = null;
		nextTile = switch (s.to) {
			case North_1, North_2: getMapTile(s.currentMapTile.cx, s.currentMapTile.cy - 1);
			case South_1, South_2: getMapTile(s.currentMapTile.cx, s.currentMapTile.cy + 1);
			case West_1, West_2: getMapTile(s.currentMapTile.cx - 1, s.currentMapTile.cy);
			case East_1, East_2: getMapTile(s.currentMapTile.cx + 1, s.currentMapTile.cy);
		}

		if (nextTile == null) {
			s.destroy();
			if (shipToSpawn == 0 && shipOnScreen == 0) {
				// TODO : SHOW VICTORY
			}
		}
		else {
			var nextEP = switch s.to {
				case North_1: South_1;
				case North_2: South_2;
				case South_1: North_1;
				case South_2: North_2;
				case West_1: East_1;
				case West_2: East_2;
				case East_1: West_1;
				case East_2: West_2;
			}

			var nextRoad = nextTile.getRoadWith(nextEP);

			if (nextRoad != null) {
				nextTile.addShipToRoad(s, nextRoad, nextEP);
			}
			else {
				shipToSpawn++;
				game.looseLife();
				s.destroy();
				spawnShip();
			}
		} 
	}

	public function checkOtherTiles(mapTile:MapTile) {
		for (mt in arMapTile) {
			if (mt != mapTile && mt.selected) {
				exchangeTiles(mt, mapTile);
				removeArrows(mapTile);
				return true;
			}
		}
		return false;
	}

	public function getMapTile(cx:Int, cy:Int):MapTile {
		if (!isValid(cx, cy))
			return null;

		for (tile in arMapTile) {
			if (tile.cx == cx && tile.cy == cy)
				return tile;
		}

		return null;
	}

	public function exchangeTiles(mt1:MapTile, mt2:MapTile) {
		var mapTile1cx = mt1.cx;
		var mapTile1cy = mt1.cy;

		mt1.cx = mt2.cx;
		mt1.cy = mt2.cy;
		mt2.cx = mapTile1cx;
		mt2.cy = mapTile1cy;

		mt1.setPosition(mt1.cx*Const.MAP_TILE_SIZE, mt1.cy*Const.MAP_TILE_SIZE);
		mt2.setPosition(mt2.cx*Const.MAP_TILE_SIZE, mt2.cy*Const.MAP_TILE_SIZE);

		mt1.unSelect();
		mt2.unSelect();
	}

	public inline function isValid(cx,cy) return cx>=0 && cx<wid && cy>=0 && cy<hei;
	public inline function coordId(cx,cy) return cx + cy*wid;

	override function update() {
		super.update();

		#if debug
		if (hxd.Key.isPressed(Key.A)) {
			game.looseLife();
		}
		
		if (hxd.Key.isPressed(Key.F1)) {
			spawnShip();
		}
		#end

		if (shipToSpawn > 0 && ftime >= nextSpawnTiming) {
			spawnShip();
			nextSpawnTiming += spawnTiming * Const.FPS;
		}
	}
}