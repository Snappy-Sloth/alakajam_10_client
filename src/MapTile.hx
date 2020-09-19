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
		wrapperRotation.rotate(0.5*Math.PI);
	}

	public function rotateLeft() {
		wrapperRotation.rotate(-0.5*Math.PI);
	}

}