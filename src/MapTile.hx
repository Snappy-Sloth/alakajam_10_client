import h2d.Layers;
import h2d.Interactive;
import h2d.Graphics;

class MapTile extends h2d.Layers {

	public var cx : Int;
	public var cy : Int;
	public var level : Level;

	var whiteSelection : Graphics;
	var inter : Interactive;

	public var selected : Bool;

	var wrapper : Layers;
	var wrapperRotation : Layers;

	public var roads(default, null) : Array<Road> = [];

	//public var ships : Array<Ship> = [];
	
	public function new(tx:Int, ty:Int, level:Level) {
		super();
		cx = tx;
		cy = ty;
		this.level = level;

		selected = false;
		
		wrapperRotation = new Layers(this);
		wrapper = new Layers(wrapperRotation);
		wrapper.setPosition(-Const.MAP_TILE_SIZE/2, -Const.MAP_TILE_SIZE/2);

		var bg = Assets.tiles.h_get("mapTile");
		wrapper.addChild(bg);

		this.setPosition(cx*Const.MAP_TILE_SIZE, cy*Const.MAP_TILE_SIZE);

		whiteSelection = new Graphics(this);
        whiteSelection.beginFill(0xffffff, 0.3);
		whiteSelection.drawRect(0, 0, Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE);
		whiteSelection.setPosition(-Const.MAP_TILE_SIZE/2, -Const.MAP_TILE_SIZE/2);

        whiteSelection.visible = false;

		inter = new Interactive(Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE, wrapper);
		//inter.backgroundColor = 0x55ff00ff;
		
		inter.onPush = function (e) {
			if (level.shipAreGone || level.controlLock)
				return;
			
			// if (!selected) {
				level.unselectAllMapTiles();
				level.swapFrom = this;
				select();
			// }
			// else {
			// 	unSelect();
			// 	level.removeArrows();
			// }
		}

		inter.onMove = function(e) {
			if (level.shipAreGone || level.controlLock)
				return;

			level.showPossibleSwap(this);
		}

		inter.onRelease = function (e) {
			if (level.shipAreGone || level.controlLock)
				return;

			if (level.swapFrom == this) {
				level.swapFrom = null;
				if (level.lvlData.numRotation > 0) {
					level.unselectAllMapTiles();
					select();
					level.addArrows(this);
				}
			}
			else if (level.swapFrom != null) {
				level.unselectAllMapTiles();
				level.doSwap();
			}
		}
	}

	public function createRoad(from:EP, to:EP) {
		var r = new Road(from, to, this);
		roads.push(r);
	}

	public function drawRoads() {
		/* var spriteBatch = new HSpriteBatch(Assets.tiles.tile, wrapper);
		var step = 5;

		for (r in roads) {
			// for (i in 0...Std.int((r.distance) / step)) {
			// 	var be = new HSpriteBE(spriteBatch, Assets.tiles, "roadStep");
			// 	var ratio = (i * step) / r.distance;
			// 	be.setPosition(r.pointAX + (r.pointBX - r.pointAX) * ratio, r.pointAY + (r.pointBY - r.pointAY) * ratio);
			// }
			// while ()
		} */

		for (r in roads) {
			var gr = new h2d.Graphics(wrapper);
			gr.lineStyle(1);
			gr.moveTo(r.pointAX, r.pointAY);
			gr.lineTo(r.pointBX, r.pointBY);
		}
	}

	public function removeAllRoads() {
		roads = [];
	}

	function getRandomEntryPoint(fromSide:EP = null, differentFrom:Array<EP>) {
		var possibleOut : Array<EP> = [];

		for (ep in EP.createAll()) {
			if (fromSide != null && ep.getName().split("_")[0] == fromSide.getName().split("_")[0])
				continue;

			var canAdd = true;
			for (epf in differentFrom)
				if (epf == ep) {
					canAdd = false;
					break;
				}
			
			if (canAdd)
				possibleOut.push(ep);
		}


		return possibleOut[level.rand.random(possibleOut.length)];
	}

	public function spawnShipOnEP(ep:EP) {
		var ship = new Ship(level);
		var road = getRoadWith(ep);
		addShipToRoad(ship, road, ep);
	}

	public function addShipToRoad(ship:Ship, road:Road, from:EP) {
		ship.addToRoad(road, from);
	}

	public function getRoadWith(ep:EP):Road {
		for (r in roads)
			if (ep == r.pointA || ep == r.pointB) {
				return r;
			}

		return null;
	}

	public function getAllExternalEPs():Array<EP> {
		var externalEPs = [];

		for (ep in EP.createAll()) {
			if (isEPExternal(ep) /* && getRoadOnEP(ep) != null */)
				externalEPs.push(ep);
		}

		return externalEPs;
	}

	function isEPExternal(ep:EP):Bool {
		return switch ep {
			case North_1, North_2: cy == 0;
			case South_1, South_2: cy == level.hei - 1;
			case West_1, West_2: cx == 0;
			case East_1, East_2: cx == level.wid - 1;
		}
	}

	public function select() {
		selected = true;
		whiteSelection.visible = true;
	}

	public function unSelect() {
		selected = false;
		whiteSelection.visible = false;
	}

	public function rotateRight(instant:Bool) {
		level.currentScore++;

		// Rotate roads
		for (r in roads) {
			r.modifyPoints(getNextRoadWhenRotateRight(r.pointA), getNextRoadWhenRotateRight(r.pointB));
		}

		// Rotate art
		if (instant)
			wrapperRotation.rotate(0.5*Math.PI);
		else {
			level.lockControl(0.2);
			level.tw.createS(wrapperRotation.rotation, wrapperRotation.rotation + 0.5*Math.PI, 0.2);
		}
	}

	public function rotateLeft(instant:Bool) {
		level.currentScore++;

		// Rotate roads
		for (r in roads) {
			r.modifyPoints(getNextRoadWhenRotateLeft(r.pointA), getNextRoadWhenRotateLeft(r.pointB));
		}

		// Rotate art
		if (instant)
			wrapperRotation.rotate(-0.5*Math.PI);
		else {
			level.lockControl(0.2);
			level.tw.createS(wrapperRotation.rotation, wrapperRotation.rotation - 0.5*Math.PI, 0.2);
		}
	}

	function getNextRoadWhenRotateRight(ep:EP):EP {
		return switch (ep) {
			case North_1:East_1;
			case North_2:East_2;
			case South_1:West_1;
			case South_2:West_2;
			case West_1:North_2;
			case West_2:North_1;
			case East_1:South_2;
			case East_2:South_1;
		}
	}

	function getNextRoadWhenRotateLeft(ep:EP):EP {
		return switch (ep) {
			case North_1:West_2;
			case North_2:West_1;
			case South_1:East_2;
			case South_2:East_1;
			case West_1:South_1;
			case West_2:South_2;
			case East_1:North_1;
			case East_2:North_2;
		}
	}

}