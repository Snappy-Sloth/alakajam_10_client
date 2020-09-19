import h2d.Interactive;
import h2d.Graphics;

class MapTile extends h2d.Layers {

	public var cx : Int;
	public var cy : Int;
	public var level : Level;

	var whiteSelection : Graphics;
	var inter : Interactive;

	public var selected : Bool;
	
	public function new(tx:Int, ty:Int, level:Level) {
		super();
		cx = tx;
		cy = ty;
		this.level = level;

		selected = false;
		
		var bmp = new h2d.Graphics(this);
		bmp.beginFill(Color.randomColor());
		bmp.drawRect(0, 0, Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE);

		this.setPosition(cx*Const.MAP_TILE_SIZE, cy*Const.MAP_TILE_SIZE);

		whiteSelection = new h2d.Graphics(this);
        whiteSelection.beginFill(0xffffff, 0.3);
        whiteSelection.drawRect(0, 0, Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE);

        whiteSelection.visible = false;

		inter = new Interactive(Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE, this);
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

}