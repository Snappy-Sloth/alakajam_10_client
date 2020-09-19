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

	var roads : Array<Road> = [];
	
	public function new(tx:Int, ty:Int, level:Level) {
		super();
		cx = tx;
		cy = ty;
		this.level = level;

		selected = false;
		
		wrapperRotation = new Layers(this);
		wrapper = new Layers(wrapperRotation);
		wrapper.setPosition(-Const.MAP_TILE_SIZE/2, -Const.MAP_TILE_SIZE/2);

		var bmp = new Graphics(wrapper);
		bmp.beginFill(Color.randomColor());
		bmp.drawRect(0, 0, Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE);

		var rotationField = new Graphics(wrapper);
		rotationField.beginFill(0xff00ff, 0.5);
		rotationField.drawRect(0, 0, 10, 10);

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
				select();
				if (!level.checkOtherTiles(this)) {
					level.addArrows(this);
				}
			}
		}
		
		createRoad();
	}

	function createRoad() {
		var from = getRandomEntryPoint();
		var to = getRandomEntryPoint(from);

		var r = new Road(from, to, this);
		roads.push(r);

		var gr = new h2d.Graphics(wrapper);
		gr.lineStyle(1);
		gr.moveTo(r.fromX, r.fromY);
		gr.lineTo(r.toX, r.toY);
	}

	function getRandomEntryPoint(differentFrom:Null<EP> = null) {
		var out : EP = null;
		while (out == null || (differentFrom != null && out.getName().split("_")[0] == differentFrom.getName().split("_")[0] )) {
			out = EP.createByIndex(Std.random(EP.createAll().length));
		}

		return out;
	}

	public function addShipToRoad(ship:Ship) {
		ship.addToRoad(roads[0]);

		wrapper.addChild(ship.root);
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
			r.onRotation(getNextRoadWhenRotateRight(r.from), getNextRoadWhenRotateRight(r.to));
		}

		// Rotate art
		wrapperRotation.rotate(0.5*Math.PI);
	}

	public function rotateLeft() {
		// Rotate roads

		for (r in roads) {
			r.onRotation(getNextRoadWhenRotateLeft(r.from), getNextRoadWhenRotateLeft(r.to));
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