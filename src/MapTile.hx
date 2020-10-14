import h2d.Layers;
import h2d.Interactive;
import h2d.Graphics;

class MapTile extends h2d.Layers {

	static var num = 0;
	static var DP_W_BG = num++;
	static var DP_W_ROADS = num++;
	static var DP_W_DOORS = num++;
	static var DP_W_INTER = num++;

	public var cx : Int;
	public var cy : Int;
	public var level : Level;

	var whiteSelection : Graphics;
	var inter : Interactive;
	
	public var selected : Bool;
	
	var wrapperShadow : h2d.Object;
	var shadow : h2d.Bitmap;
	var wrapper : Layers;
	var wrapperRotation : Layers;

	public var roads(default, null) : Array<Road> = [];

	public var doors : Array<{spr:HSprite, ep:EP}> = [];
	
	public function new(tx:Int, ty:Int, level:Level) {
		super();
		cx = tx;
		cy = ty;
		this.level = level;

		selected = false;

		wrapperShadow = new h2d.Object(this);
		wrapperShadow.scaleX = wrapperShadow.scaleY = 0;

		shadow = new h2d.Bitmap(h2d.Tile.fromColor(0, Std.int(Const.MAP_TILE_SIZE), Std.int(Const.MAP_TILE_SIZE), 0.1));
		shadow.setPosition(-shadow.tile.width * 0.5, -shadow.tile.height * 0.5);
		wrapperShadow.addChild(shadow);
		
		wrapperRotation = new Layers(this);
		wrapper = new Layers(wrapperRotation);
		wrapper.setPosition(-Const.MAP_TILE_SIZE/2, -Const.MAP_TILE_SIZE/2);

		var bg = Assets.tiles.h_get("mapTile");
		wrapper.add(bg, DP_W_BG);

		this.setPosition(cx*Const.MAP_TILE_SIZE, cy*Const.MAP_TILE_SIZE);

		whiteSelection = new Graphics(this);
        whiteSelection.beginFill(0xffffff, 0.3);
		whiteSelection.drawRect(0, 0, Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE);
		whiteSelection.setPosition(-Const.MAP_TILE_SIZE/2, -Const.MAP_TILE_SIZE/2);

        whiteSelection.visible = false;

		inter = new Interactive(Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE);
		wrapper.add(inter, DP_W_INTER);
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

	public function drawDoors() {
		for (ep in EP.createAll()) {
			var door = Assets.tiles.h_get("door");
			wrapper.add(door, DP_W_DOORS);
			door.setPosition(Road.getEpX(ep), Road.getEpY(ep));

			doors.push({spr: door, ep: ep});

			switch ep {
				case North_1, North_2:
					door.x -= door.tile.width * 0.5;
				case South_1, South_2:
					door.rotation = Math.PI;
					door.x += door.tile.width * 0.5;
				case West_1, West_2:
					door.rotation = -Math.PI / 2;
					door.y += door.tile.width * 0.5;
				case East_1, East_2:
					door.rotation = Math.PI / 2;
					door.y -= door.tile.width * 0.5;
			}

			door.x = Std.int(door.x);
			door.y = Std.int(door.y);
		}

		updateDoors();
	}

	public function openAllDoors() {
		for (d in doors) {
			level.tw.createS(d.spr.scaleX, 0, 0.1);
		}
	}

	public function updateDoors() {
		for (d in doors) {
			var nextMT = switch (d.ep) {
				case North_1, North_2: level.getMapTileAt(cx, cy - 1);
				case South_1, South_2: level.getMapTileAt(cx, cy + 1);
				case West_1, West_2: level.getMapTileAt(cx - 1, cy);
				case East_1, East_2: level.getMapTileAt(cx + 1, cy);
			}

			if (!isEPExternal(d.ep) && (nextMT.getRoadWith(Const.GET_NEIGHBOOR_MATCHING_EP(d.ep)) == null || getRoadWith(d.ep) == null))
				level.tw.createS(d.spr.scaleX, 1, 0.1);
			else
				level.tw.createS(d.spr.scaleX, 0, 0.1);
		}
	}

	public function showShadow() {
		level.tw.createS(wrapperShadow.scaleX, 1.1, 0.1);
		level.tw.createS(wrapperShadow.scaleY, 1.1, 0.1);
	}
	
	public function hideShadow() {
		level.tw.createS(wrapperShadow.scaleX, 1, 0.1);
		level.tw.createS(wrapperShadow.scaleY, 1, 0.1);
	}

	public function createRoad(from:EP, to:EP) {
		var r = new Road(from, to, this);
		roads.push(r);
	}

	public function drawRoads() {
		var spriteBatch = new HSpriteBatch(Assets.tiles.tile);
		wrapper.add(spriteBatch, DP_W_ROADS);
		var step = 1;
		// var step = 5;

		/* for (r in roads) {
			// for (i in 0...Std.int((r.distance) / step)) {
			// 	var be = new HSpriteBE(spriteBatch, Assets.tiles, "roadStep");
			// 	var ratio = (i * step) / r.distance;
			// 	be.setPosition(r.pointAX + (r.pointBX - r.pointAX) * ratio, r.pointAY + (r.pointBY - r.pointAY) * ratio);
			// }
			// var pointX = r.pointAX;
			// var pointY = r.pointAY;
			// var ang = Math.atan2(r.pointBY - r.pointAY, r.pointBX - r.pointAX);
			// for (i in 0...Std.int((r.distance) / step)) {
			// 	var be = new HSpriteBE(spriteBatch, Assets.tiles, "roadStep");
			// 	be.setPosition(pointX, pointY);
			// 	pointX += Math.cos(ang) * step;
			// 	pointY += Math.sin(ang) * step;
			// }
		} */

		/* for (r in roads) {
			var i = 0;
			for (p in dn.Bresenham.getThinLine(M.round(r.pointAX), M.round(r.pointAY), M.round(r.pointBX), M.round(r.pointBY))) {
				// if (i++ % 2 == 0) {
					var be = new HSpriteBE(spriteBatch, Assets.tiles, "roadStep");
					be.setPosition(hxd.Math.iclamp(p.x, 0, Const.MAP_TILE_SIZE - 1), hxd.Math.iclamp(p.y, 0, Const.MAP_TILE_SIZE - 1));
				// }
				
			}
		} */

		for (r in roads) {
			var gr = new h2d.Graphics();
			wrapper.add(gr, DP_W_ROADS);
			gr.lineStyle(1, 0xFF2a6e83);
			gr.moveTo(r.pointAX, r.pointAY);
			gr.lineTo(r.pointBX, r.pointBY);
			// gr.curveTo(Const.MAP_TILE_SIZE >> 1, Const.MAP_TILE_SIZE >> 1, r.pointBX, r.pointBY);
			// trace("----");
			// trace(r.pointAX + " " + r.pointAY);
			// trace(r.pointBX + " " + r.pointBY);
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

		// Rotate doors
		for (d in doors) {
			d.ep = getNextRoadWhenRotateRight(d.ep);
		}

		// Rotate art
		if (instant)
			wrapperRotation.rotate(0.5*Math.PI);
		else {
			level.cm.create({
				level.lockControl();
				level.tw.createS(wrapperRotation.scaleY, 0.9, 0.1);
				level.tw.createS(wrapperRotation.scaleX, 0.9, 0.1).end(()->level.cm.signal());
				end;
				level.tw.createS(wrapperRotation.rotation, wrapperRotation.rotation + 0.5*Math.PI, 0.1).end(()->level.cm.signal());
				end;
				level.tw.createS(wrapperRotation.scaleY, 1, 0.1);
				level.tw.createS(wrapperRotation.scaleX, 1, 0.1).end(()->level.cm.signal());
				end;
				level.unlockControl();
				for (tile in level.arMapTile) {
					tile.updateDoors();
				}
			});
		}

		if (level.game.hud != null)
			level.game.hud.invalidate();
	}

	public function rotateLeft(instant:Bool) {
		level.currentScore++;

		// Rotate roads
		for (r in roads) {
			r.modifyPoints(getNextRoadWhenRotateLeft(r.pointA), getNextRoadWhenRotateLeft(r.pointB));
		}

		// Rotate doors
		for (d in doors) {
			d.ep = getNextRoadWhenRotateLeft(d.ep);
		}

		// Rotate art
		if (instant)
			wrapperRotation.rotate(-0.5*Math.PI);
		else {
			level.cm.create({
				level.lockControl();
				level.tw.createS(wrapperRotation.scaleY, 0.9, 0.1);
				level.tw.createS(wrapperRotation.scaleX, 0.9, 0.1).end(()->level.cm.signal());
				end;
				level.tw.createS(wrapperRotation.rotation, wrapperRotation.rotation - 0.5*Math.PI, 0.1).end(()->level.cm.signal());
				end;
				level.tw.createS(wrapperRotation.scaleY, 1, 0.1);
				level.tw.createS(wrapperRotation.scaleX, 1, 0.1).end(()->level.cm.signal());
				end;
				level.unlockControl();
				for (tile in level.arMapTile) {
					tile.updateDoors();
				}
			});
		}

		if (level.game.hud != null)
			level.game.hud.invalidate();
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