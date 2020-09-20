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

	public var ships : Array<Ship> = [];
	
	public function new(tx:Int, ty:Int, level:Level) {
		super();
		cx = tx;
		cy = ty;
		this.level = level;

		selected = false;
		
		wrapperRotation = new Layers(this);
		wrapper = new Layers(wrapperRotation);
		wrapper.setPosition(-Const.MAP_TILE_SIZE/2, -Const.MAP_TILE_SIZE/2);

		// var bmp = new Graphics(wrapper);
		// bmp.beginFill(0xFFFFFF);
		// bmp.lineStyle(3, 0xcc0000);
		// bmp.drawRect(0, 0, Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE);

		var bg = Assets.tiles.h_get("mapTile");
		wrapper.addChild(bg);

		// var rotationField = new Graphics(wrapper);
		// rotationField.beginFill(0xff00ff, 0.5);
		// rotationField.drawRect(0, 0, 10, 10);

		this.setPosition(cx*Const.MAP_TILE_SIZE, cy*Const.MAP_TILE_SIZE);

		whiteSelection = new Graphics(this);
        whiteSelection.beginFill(0xffffff, 0.3);
		whiteSelection.drawRect(0, 0, Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE);
		whiteSelection.setPosition(-Const.MAP_TILE_SIZE/2, -Const.MAP_TILE_SIZE/2);

        whiteSelection.visible = false;

		inter = new Interactive(Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE, wrapper);
        //inter.backgroundColor = 0x55ff00ff;
        
        inter.onClick = function(e) {
			if (selected) {
				unSelect();
				level.removeArrows(this);
			}
			else {
				// level.unselectAllMapTiles();
				select();

				if (!level.checkOtherTiles(this)) {
					level.addArrows(this);
				}
			}
		}
		
		// createRoads(4);

		// Draw Roads
		
	}

	/* function createRoads(num:Int) {
		roads = [];

		for (i in 0...num)
			createRoad();

		if (roads.length < num)
			createRoads(num);
	} */

	/* function createRoad() {
		var currentlyUsedPE = [];

		for (road in roads) {
			currentlyUsedPE.push(road.pointA);
			currentlyUsedPE.push(road.pointB);
		}

		var from = getRandomEntryPoint(currentlyUsedPE);
		var to = getRandomEntryPoint(from, currentlyUsedPE);

		if (from == null || to == null)
			return;

		var r = new Road(from, to, this);
		roads.push(r);
	} */

	public function createRoad(from:EP, to:EP) {
		var r = new Road(from, to, this);
		roads.push(r);
	}

	public function drawRoads() {
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


		return possibleOut[Std.random(possibleOut.length)];
	}

	public function spawnShipOnEP(ep:EP) {
		var ship = new Ship(level);
		var road = getRoadWith(ep);
		addShipToRoad(ship, road, ep);
	}

	public function addShipToRoad(ship:Ship, road:Road, from:EP) {
		ship.addToRoad(road, from);

		ship.currentMapTile.removeShip(ship);
		ships.push(ship);
	}

	public function removeShip(ship:Ship) {
		ships.remove(ship);
	}

	public function getRoadWith(ep:EP):Road {
		for (r in roads)
			if (ep == r.pointA || ep == r.pointB) {
				return r;
			}

		return null;
	}

	/* public function getRandomExternalEP():Null<EP> {
		var externalEPs = getAllExternalEPs();

		return externalEPs.length == 0 ? null : externalEPs[Std.random(externalEPs.length)];
	} */

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

	public function rotateRight() {
		// Rotate roads

		for (r in roads) {
			r.modifyPoints(getNextRoadWhenRotateRight(r.pointA), getNextRoadWhenRotateRight(r.pointB));
		}

		// Rotate art
		wrapperRotation.rotate(0.5*Math.PI);
	}

	public function rotateLeft() {
		// Rotate roads

		for (r in roads) {
			r.modifyPoints(getNextRoadWhenRotateLeft(r.pointA), getNextRoadWhenRotateLeft(r.pointB));
		}

		// Rotate art
		wrapperRotation.rotate(-0.5*Math.PI);
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