import h2d.Interactive;
import h2d.Graphics;

class Arrow extends h2d.Layers {
    public var rightArrow : Bool;
    
    var inter : Interactive;
    var level : Level;

    public function new(rightArrow:Bool, level:Level) {
        super();
        this.rightArrow = rightArrow;
        this.level = level;
        
		var arrow = Assets.tiles.h_get("arrow", 0.5, 0.5, this);
		if (!rightArrow)
			arrow.scaleX = -1;
		arrow.scaleY = -1;
		arrow.setPosition(Const.ARROW_TILE_WIDTH >> 1, Const.ARROW_TILE_HEIGHT >> 1);

        inter = new Interactive(Const.ARROW_TILE_WIDTH, Const.ARROW_TILE_HEIGHT, this);
        // inter.backgroundColor = 0x55ff00ff;

        this.visible = false;
    }

    public function show(mapTile:MapTile) {
        this.setPosition(	Std.int((mapTile.cx + (rightArrow ? 1 : 0))*Const.MAP_TILE_SIZE-Const.ARROW_TILE_WIDTH/2-Const.MAP_TILE_SIZE/2),
							Std.int(mapTile.cy*Const.MAP_TILE_SIZE+(Const.ARROW_TILE_HEIGHT-Const.MAP_TILE_SIZE)/2));
        this.visible = true;

        inter.onClick = function(e) {
            if (level.controlLock) return;
            
            if (rightArrow) {
                // mapTile.rotateLeft();
				mapTile.rotateRight(false);
            }
            else {
				mapTile.rotateLeft(false);
                // mapTile.rotateRight();
            }
        }
    }

    public function hide() {
        this.visible = false;
    }
}