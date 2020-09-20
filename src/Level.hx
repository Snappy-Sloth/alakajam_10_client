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

	public var ships : Array<Ship> = [];

	// var shipToSpawn = 1;
	// var shipToSpawn = 5;
	var shipToSpawn = 3;
	var shipsOver = 0;
	var nextSpawnTiming : Float = 0;
	var spawnTiming : Float = 3;
	var shipAreGone : Bool = false;

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

		// Create MapTiles
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

		var numTry = 0;
		generateShipsAndRoad(numTry);

		for (tile in arMapTile) {
			tile.drawRoads();
		}

		// Randomize mapTiles position
		/* var rnd = new dn.Rand(Std.random(99999));
		for (i in 0...arMapTile.length) {
			var arMP = arMapTile.copy();
			var mp1 = rnd.arraySplice(arMP);
			var mp2 = rnd.arraySplice(arMP);

			exchangeTiles(mp1, mp2);
		}

		for (i in 0...arMapTile.length * 2) {
			var mp = rnd.arrayPick(arMapTile);
			rnd.random(2) == 0 ? mp.rotateLeft() : mp.rotateRight();
		} */
	}

	function generateShipsAndRoad(numTry:Int) {
		numTry++;

		for (i in 0...ships.length) {
			ships[i].destroy();
		}
		ships = [];
		
		for (tile in arMapTile) {
			tile.removeAllRoads();
		}

		var rnd = new dn.Rand(Std.random(99999));

		var availablesExternalEP : Array<{mapTile:MapTile, eps:Array<EP>}> = [];
		for (tile in arMapTile) {
			var eps = tile.getAllExternalEPs();
			if (eps.length == 0)
				continue;
			availablesExternalEP.push({mapTile:tile, eps: eps});
		}

			// Spawn Ships
		for (i in 0...shipToSpawn) {
			var randomAEEP = rnd.arrayPick(availablesExternalEP);
			var randomEP = rnd.arraySplice(randomAEEP.eps);

			if (randomAEEP.eps.length == 0)
				availablesExternalEP.remove(randomAEEP);

			var ship = new Ship(this);
			ship.setInitialPosition(randomAEEP.mapTile, randomEP);
			ships.push(ship);
		}

			// Set ships quest goal
		for (ship in ships) {
			var randomAEEP = rnd.arrayPick(availablesExternalEP);
			while (randomAEEP == null || randomAEEP.mapTile == ship.start_mp)
				randomAEEP = rnd.arrayPick(availablesExternalEP);
			var randomEP = rnd.arraySplice(randomAEEP.eps);

			if (randomAEEP.eps.length == 0)
				availablesExternalEP.remove(randomAEEP);

			ship.initQuest(randomAEEP.mapTile, randomEP);
		}

			// Create Roads
		for (ship in ships) {
			var path = dn.Bresenham.getThickLine(ship.start_mp.cx, ship.start_mp.cy, ship.quest_mp.cx, ship.quest_mp.cy, true);
			var prevDist = -1.;
			var newPath = [];
			for (p in path) {
				if (M.distSqr(ship.start_mp.cx, ship.start_mp.cy, p.x, p.y) > prevDist) {
					prevDist = M.distSqr(ship.start_mp.cx, ship.start_mp.cy, p.x, p.y);
					newPath.push(getMapTileAt(p.x, p.y));
				}
			}

			var from = ship.start_ep;
			var to = null;

			for (i in 0...newPath.length - 1) {
				var possibleExit = [];
				var currentMP = newPath[i];
				var nextMP = newPath[i + 1];
				to = null;

				if (nextMP.cx == currentMP.cx + 1)
					possibleExit = [East_1, East_2];
				else if (nextMP.cx == currentMP.cx - 1)
					possibleExit = [West_1, West_2];
				else if (nextMP.cy == currentMP.cy + 1)
					possibleExit = [South_1, South_2];
				else if (nextMP.cy == currentMP.cy - 1)
					possibleExit = [North_1, North_2];
				
				for (p in possibleExit.copy()) {
					if (currentMP.getRoadWith(p) != null)
						possibleExit.remove(p);
				}

				if (possibleExit.length == 0) {
					generateShipsAndRoad(numTry);
					return;
				}

				to = rnd.arrayPick(possibleExit);
				currentMP.createRoad(from, to);

				from = switch (to) {
					case North_1: South_1;
					case North_2: South_2;
					case South_1: North_1;
					case South_2: North_2;
					case West_1: East_1;
					case West_2: East_2;
					case East_1: West_1;
					case East_2: West_2;
				}
			}
			ship.quest_mp.createRoad(from, ship.quest_ep);
		}

		trace("numTry : " + numTry);
	}

	public function addArrows(mapTile:MapTile) {
		rightArrow.show(mapTile);
		leftArrow.show(mapTile);
	}

	public function removeArrows(mapTile:MapTile) {
		rightArrow.hide();
		leftArrow.hide();
	}

	public function onShipReachingEnd(s:Ship) {
		var nextTile = null;
		nextTile = switch (s.to) {
			case North_1, North_2: getMapTileAt(s.currentMapTile.cx, s.currentMapTile.cy - 1);
			case South_1, South_2: getMapTileAt(s.currentMapTile.cx, s.currentMapTile.cy + 1);
			case West_1, West_2: getMapTileAt(s.currentMapTile.cx - 1, s.currentMapTile.cy);
			case East_1, East_2: getMapTileAt(s.currentMapTile.cx + 1, s.currentMapTile.cy);
		}

		if (nextTile == null) {
			if (s.currentMapTile == s.quest_mp && s.to == s.quest_ep)
				shipsOver++;
			s.destroy();

			if (shipToSpawn == shipsOver) {
				game.levelVictory();
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
				game.looseLife();
				s.destroy();
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

	public function unselectAllMapTiles() {
		for (tile in arMapTile) {
			tile.unSelect();
		}
	}

	public function getMapTileAt(cx:Int, cy:Int):MapTile {
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

	public function addQuestGoal(mp:MapTile, ep:EP, id:Int):HSprite {
		var spr = Assets.tiles.h_get("questMark", id, 0.5, 0.5);
		wrapperMapTile.add(spr, Const.DP_UI);
		var tile = getMapTileAt(mp.cx, mp.cy);

		spr.setPos(tile.x + Road.getEpX(ep) - (Const.MAP_TILE_SIZE >> 1) , tile.y + Road.getEpY(ep) - (Const.MAP_TILE_SIZE >> 1));

		switch (ep) {
			case North_1, North_2 : spr.y -= 10;
			case South_1, South_2 : spr.y += 10;
			case West_1, West_2 : spr.x -= 10;
			case East_1, East_2 : spr.x += 10;
		}

		return spr;
	}

	public function playBtnPressed() {
		setTimeMultiplier(1);
		
		if (!shipAreGone)
			for (ship in ships) {
				var mp = ship.start_mp;
				mp.addShipToRoad(ship, mp.getRoadWith(ship.start_ep), ship.start_ep);
			}
		
		shipAreGone = true;
	}

	public function forwardBtnPressed() {
		setTimeMultiplier(5);
	}

	public inline function isValid(cx,cy) return cx>=0 && cx<wid && cy>=0 && cy<hei;
	public inline function coordId(cx,cy) return cx + cy*wid;

	override function update() {		
		super.update();

		#if debug
		if (hxd.Key.isPressed(Key.A)) {
			game.looseLife();
		}
		
		/* if (hxd.Key.isPressed(Key.F1)) {
			spawnShip();
		} */

		if (hxd.Key.isPressed(Key.F3)) {
			game.levelVictory();
		}

		if (hxd.Key.isPressed(Key.F4)) {
			game.campaignVictory();
		}
		#end
	}
}