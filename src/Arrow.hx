import h2d.Interactive;
import h2d.Graphics;

class Arrow extends h2d.Layers {
    public var rightArrow : Bool;
    
    var inter : Interactive;

    public function new(rightArrow:Bool) {
        super();
        this.rightArrow = rightArrow;
        
        var arrow = new h2d.Graphics(this);
		arrow.beginFill(0xff00ff);
		arrow.alpha = 0.5;
        arrow.drawRect(0, 0, Const.ARROW_TILE_WIDTH, Const.ARROW_TILE_HEIGHT);

        inter = new Interactive(Const.ARROW_TILE_WIDTH, Const.ARROW_TILE_HEIGHT, this);
        //inter.backgroundColor = 0x55ff00ff;

        this.visible = false;
    }

    public function show(mapTile:MapTile) {
        this.setPosition((mapTile.cx + (rightArrow ? 1 : 0))*Const.MAP_TILE_SIZE-Const.ARROW_TILE_WIDTH/2-Const.MAP_TILE_SIZE/2,
            mapTile.cy*Const.MAP_TILE_SIZE+Const.ARROW_TILE_HEIGHT/2-Const.MAP_TILE_SIZE/2);
        this.visible = true;

        inter.onClick = function(e) {
            if (rightArrow) {
                mapTile.rotateLeft();
            }
            else {
                mapTile.rotateRight();
            }
        }
    }

    public function hide() {
        this.visible = false;
    }
}