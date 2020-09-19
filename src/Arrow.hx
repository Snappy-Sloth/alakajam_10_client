import h2d.Interactive;
import h2d.Graphics;

class Arrow extends h2d.Layers {
    public var cx : Int;
    public var cy : Int;
    public var mapTile : MapTile;
    public var rightArrow : Bool;
    
    var inter : Interactive;

    public function new(tx:Int, ty:Int, mapTile:MapTile, rightArrow:Bool) {
        super();
        cx = tx;
        cy = ty;
        this.mapTile = mapTile;
        this.rightArrow = rightArrow;
        
        var arrow = new h2d.Graphics(this);
		arrow.beginFill(0xff00ff);
        arrow.drawRect(0, 0, Const.ARROW_TILE_WIDTH, Const.ARROW_TILE_HEIGHT);
        this.setPosition(cx*Const.MAP_TILE_SIZE-Const.ARROW_TILE_WIDTH/2-Const.MAP_TILE_SIZE/2,
                        cy*Const.MAP_TILE_SIZE+Const.ARROW_TILE_HEIGHT/2-Const.MAP_TILE_SIZE/2);

        inter = new Interactive(Const.ARROW_TILE_WIDTH, Const.ARROW_TILE_HEIGHT, this);
        //inter.backgroundColor = 0x55ff00ff;

        inter.onClick = function(e) {
            if (rightArrow) {
                mapTile.rotateLeft();
            }
            else {
                mapTile.rotateRight();
            }
        }
    }
}