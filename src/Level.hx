import dn.Rand;
import hxd.Key;

class Level extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	public var wid(get,never) : Int; inline function get_wid() return lvlData.width;
	public var hei(get,never) : Int; inline function get_hei() return lvlData.height;

	var arMapTile : Array<MapTile>;
	var wrapperMapTile : h2d.Layers;

	var rightArrow : Arrow;
	var leftArrow : Arrow;

	public var ships : Array<Ship> = [];

	var shipsOver = 0;
	//var nextSpawnTiming : Float = 0;
	//var spawnTiming : Float = 3;
	public var shipAreGone(default, null) : Bool = false;

	public var currentScore : Int;
	public var levelScoreMin(default, null) : Int;

	public var lvlData(default, null) : Data.Campaign;

	public var controlLock(default, null) = false;

	public var rand : dn.Rand;

	public var swapFrom : MapTile = null;
	public var swapTo : MapTile = null;
	var lineSwap : h2d.Graphics;
	var arrowSwap : HSprite;

	public function new(lvlData:Data.Campaign) {
		super(Game.ME);

		rand = new dn.Rand(Std.random(999999));
		// rand = new dn.Rand(885636);
		trace("Seed : " + rand.getSeed());

		this.lvlData = lvlData;

		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		createLevel(wid, hei);

		levelScoreMin = lvlData.numSwap + lvlData.numRotation;
		currentScore = 0;

		onResize();
	}

	public inline function getLevelNumber():Int {
		var idLevel = Std.string(lvlData.id);
		var splitId = idLevel.split("_");
		return Std.parseInt(splitId[1]);
	}

	override function onResize() {
		super.onResize();
		
		wrapperMapTile.setPosition(((w()/Const.SCALE-wid*Const.MAP_TILE_SIZE)/2)+Const.MAP_TILE_SIZE/2,
									((h()/Const.SCALE-hei*Const.MAP_TILE_SIZE)/2)+Const.MAP_TILE_SIZE/2);
	}

	public function createLevel(w, h) {
		arMapTile = [];

		wrapperMapTile = new h2d.Layers(root);
		
		// var bg = Assets.tiles.h_get("bg", 0.5, 0.5);
		// wrapperMapTile.add(bg, Const.DP_BG);
		var bg = new h2d.Bitmap(h2d.Tile.fromColor(0x957d56, Const.MAP_TILE_SIZE * (wid + 1), Const.MAP_TILE_SIZE * (hei + 1)));
		bg.setPosition(-Const.MAP_TILE_SIZE, -Const.MAP_TILE_SIZE);
		wrapperMapTile.add(bg, Const.DP_BG);
		var inter = new h2d.Interactive(bg.tile.width, bg.tile.height, bg);
		inter.onMove = function (e) {
			if (swapTo != null) {
				swapTo.unSelect();
				swapTo = null;
			}
			if (swapFrom != null)
				drawLineSwap(Std.int(e.relX) - Const.MAP_TILE_SIZE, Std.int(e.relY) - Const.MAP_TILE_SIZE);
		}

		inter.onRelease = function (e) {
			cancelSwap();
			unselectAllMapTiles();
		}

		// Create MapTiles
		for (i in 0...wid) {
			for (j in 0...hei) {
				var mapTile = new MapTile(i, j, this);
				wrapperMapTile.add(mapTile, Const.DP_MAIN);
				arMapTile.push(mapTile);
			}
		}

		rightArrow = new Arrow(true, this);
		leftArrow = new Arrow(false, this);
		wrapperMapTile.add(rightArrow, Const.DP_UI);
		wrapperMapTile.add(leftArrow, Const.DP_UI);

		var numTry = 0;
		generateShipsAndRoad(numTry);

		for (tile in arMapTile) {
			tile.drawRoads();
		}

		// Randomize mapTiles position
		if (lvlData.numSwap > 0) { // Swapping
			var isGood = false;
			var previous = [];
			for (tile in arMapTile) {
				previous.push({mapTile:tile, cx:tile.cx, cy:tile.cy});
			}
			var deck = new dn.RandDeck(Std.random);
			for (tile in arMapTile) {
				deck.push(tile);
			}
			while (!isGood) {
				var swaps = [];
				isGood = true;
				var n = lvlData.numSwap;
				while (n-- > 0) {
					var mp1 = deck.draw();
					var mp2 = deck.draw();

					if (mp1.roads.length == 0 && mp2.roads.length == 0)
						n++;
					else {
						swaps.push({mp1:mp1, mp2:mp2});
						exchangeTiles(mp1, mp2);
					}
				}
	
				var samePlace = 0;
				for (tile in arMapTile) {
					for (t in previous) {
						if (tile == t.mapTile && tile.cx == t.cx && tile.cy == t.cy) {
							samePlace++;
						}
					}
				}
	
				isGood = samePlace < arMapTile.length;
	
				if (!isGood) {
					#if debug
					trace("retry swap");
					#end
				}
			}
		}

		if (lvlData.numRotation > 0) { // Rotation
			var goLeft = rand.sign() == 1;
			var deck = new dn.RandDeck(Std.random);
			for (tile in arMapTile) {
				deck.push(tile);
			}
			var n = lvlData.numRotation;
			while (n-- > 0) {
				var mt = deck.draw();
				if (mt.roads.length == 0)
					n++;
				else
					goLeft ? mt.rotateLeft(true) : mt.rotateRight(true);
			}
		}

		// Tuto Popup
		if (lvlData.id == level_1)
			game.showPopup("You need to connect each ship to it destination. Do it by swapping the tiles, and press the Play button when you think you're done!");
		else if (lvlData.id == level_3)
			game.showPopup("From now, you can rotate each tile. \nGood luck!");
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

		var availablesExternalEP : Array<{mapTile:MapTile, eps:Array<EP>}> = [];
		for (tile in arMapTile) {
			var eps = tile.getAllExternalEPs();
			if (eps.length == 0)
				continue;
			availablesExternalEP.push({mapTile:tile, eps: eps});
		}

			// Spawn Ships
		for (i in 0...lvlData.numShips) {
			var randomAEEP = rand.arrayPick(availablesExternalEP);
			var randomEP = rand.arraySplice(randomAEEP.eps);

			if (randomAEEP.eps.length == 0)
				availablesExternalEP.remove(randomAEEP);

			var ship = new Ship(this);
			ship.setInitialPosition(randomAEEP.mapTile, randomEP);
			ships.push(ship);
		}

			// Set ships quest goal
		for (ship in ships) {
			var randomAEEP = rand.arrayPick(availablesExternalEP);
			while (randomAEEP == null || randomAEEP.mapTile == ship.start_mp)
				randomAEEP = rand.arrayPick(availablesExternalEP);
			var randomEP = rand.arraySplice(randomAEEP.eps);

			if (randomAEEP.eps.length == 0)
				availablesExternalEP.remove(randomAEEP);

			ship.initQuest(randomAEEP.mapTile, randomEP);
		}

			// Create Roads
		for (ship in ships) {
			var path = dn.Bresenham.getThickLine(ship.start_mp.cx, ship.start_mp.cy, ship.quest_mp.cx, ship.quest_mp.cy, true);
			var newPath :Array<MapTile> = [];
			var lastAddedToPath : MapTile = null;
			for (p in path) {
				if (lastAddedToPath == null || areNearEachOther(lastAddedToPath.cx, lastAddedToPath.cy, p.x, p.y) ) {
					lastAddedToPath = getMapTileAt(p.x, p.y);
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

				to = rand.arrayPick(possibleExit);
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

	public function removeArrows() {
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
			if (s.currentMapTile == s.quest_mp && s.to == s.quest_ep) {
				shipsOver++;
				
				s.disappear(function () {
					if (shipsOver == lvlData.numShips) game.levelVictory();					
				});
			}
			else {
				resetShips();
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
				resetShips();
			}
		}
	}

	public function resetShips() {
		for (s in ships) {
			s.setInitialPosition(s.start_mp, s.start_ep);
		}
		shipAreGone = false;
		shipsOver = 0;
	}

	public function checkOtherTiles(mapTile:MapTile) {
		for (mt in arMapTile) {
			if (mt != mapTile && mt.selected) {
				exchangeTiles(mt, mapTile, false);
				removeArrows();
				return true;
			}
		}
		return false;
	}

	public function unselectAllMapTiles() {
		for (tile in arMapTile) {
			tile.unSelect();
		}
		removeArrows();
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

	public function exchangeTiles(mt1:MapTile, mt2:MapTile, instant:Bool = true) {
		currentScore++;
		var mapTile1cx = mt1.cx;
		var mapTile1cy = mt1.cy;

		mt1.cx = mt2.cx;
		mt1.cy = mt2.cy;
		mt2.cx = mapTile1cx;
		mt2.cy = mapTile1cy;

		if (instant) {
			mt1.setPosition(mt1.cx*Const.MAP_TILE_SIZE, mt1.cy*Const.MAP_TILE_SIZE);
			mt2.setPosition(mt2.cx*Const.MAP_TILE_SIZE, mt2.cy*Const.MAP_TILE_SIZE);
		}
		else {
			controlLock = true;
			var t = 0.2;
			tw.createS(mt1.x, mt1.cx*Const.MAP_TILE_SIZE, t);
			tw.createS(mt1.y, mt1.cy*Const.MAP_TILE_SIZE, t);
			tw.createS(mt2.x, mt2.cx*Const.MAP_TILE_SIZE, t);
			tw.createS(mt2.y, mt2.cy*Const.MAP_TILE_SIZE, t);
			delayer.addS(()->controlLock = false, t);
		}

		mt1.unSelect();
		mt2.unSelect();

		for (s in ships) {
			if (s.start_mp == mt1)
				s.start_mp = mt2;
			else if (s.start_mp == mt2)
				s.start_mp = mt1;

			if (s.quest_mp == mt1)
				s.quest_mp = mt2;
			else if (s.quest_mp == mt2)
				s.quest_mp = mt1;
		}

		wrapperMapTile.add(mt1, Const.DP_MAIN);
		wrapperMapTile.add(mt2, Const.DP_MAIN);
	}

	public function showPossibleSwap(to:Null<MapTile>) {
		if (swapFrom == null || swapTo == to)
			return;

		if (to == swapFrom) {
			if (swapTo != null) {
				swapTo.unSelect();
				swapTo = null;
			}
			
			if (lineSwap != null) lineSwap.visible = false;
			if (arrowSwap != null) arrowSwap.visible = false;

			return;
		}
		
		swapTo = to;

		unselectAllMapTiles();
		swapFrom.select();
		swapTo.select();

		drawLineSwap(Std.int(swapTo.x), Std.int(swapTo.y));
	}

	inline function drawLineSwap(x:Int, y:Int) {
		if (lineSwap == null) {
			lineSwap = new h2d.Graphics();
			lineSwap.alpha = 0.75;
			wrapperMapTile.add(lineSwap, Const.DP_UI);
		}
		lineSwap.visible = true;
		lineSwap.clear();
		lineSwap.lineStyle(5, 0x282e33);
		lineSwap.moveTo(Std.int(swapFrom.x), Std.int(swapFrom.y));
		lineSwap.lineTo(x, y);
		lineSwap.beginFill(0x282e33);
		lineSwap.drawCircle(Std.int(swapFrom.x), Std.int(swapFrom.y), 5);
		lineSwap.drawCircle(x, y, 5);
		lineSwap.endFill();
		
		if (arrowSwap == null) {
			arrowSwap = Assets.tiles.h_get("arrowSwap", 0.5, 0.5);
			wrapperMapTile.add(arrowSwap, Const.DP_UI);
		}
		arrowSwap.visible = true;
		arrowSwap.setPosition((swapFrom.x + x) * 0.5, (swapFrom.y + y) * 0.5);
	}

	public function cancelSwap() {
		if (swapTo != null) {
			swapTo.unSelect();
			swapTo = null;
		}
		if (swapFrom != null) {
			swapFrom.unSelect();
			swapFrom = null;
		}

		if (lineSwap != null) lineSwap.visible = false;
		if (arrowSwap != null) arrowSwap.visible = false;
	}

	public function doSwap() {
		if (swapFrom == null || swapTo == null)
			return;

		exchangeTiles(swapFrom, swapTo, false);

		cancelSwap();
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

	public function canPlay():Bool {
		if (shipAreGone)
			return false;

		for (ship in ships)
			if (ship.start_mp.getRoadWith(ship.start_ep) == null) {
				game.showPopup("Each ship must be connected to a road at least!");
				return false;
			}

		return true;
	}

	public function playBtnPressed() {
		if (canPlay()) {
			for (ship in ships) {
				ship.isEnable = true;
				var mp = ship.start_mp;
				mp.addShipToRoad(ship, mp.getRoadWith(ship.start_ep), ship.start_ep);
			}

			for (tile in arMapTile) {
				tile.unSelect();
			}
			
			shipAreGone = true;

			removeArrows();
		}
	}

	inline function areNearEachOther(x1:Int, y1:Int, x2:Int, y2:Int):Bool {
		return ((x1 == x2 && (y1 == y2 + 1 || y1 == y2 - 1))
			||	(y1 == y2 && (x1 == x2 + 1 || x1 == x2 - 1)));
	}

	public inline function lockControl(duration:Float = -1) {
		controlLock = true;
		if (duration > 0)
			delayer.addS("lockControl", ()->controlLock = false, duration);
	}
	public inline function unlockControl() {
		controlLock = false;
		delayer.cancelById("lockControl");
	}

	/* public function forwardBtnPressed() {
		setTimeMultiplier(5);
	} */

	public inline function isValid(cx,cy) return cx>=0 && cx<wid && cy>=0 && cy<hei;
	public inline function coordId(cx,cy) return cx + cy*wid;

	override function update() {		
		super.update();

		#if debug
		if (hxd.Key.isPressed(Key.F3)) {
			game.levelVictory();
		}
		#end
	}
}