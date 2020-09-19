import h2d.Interactive;
import h2d.Graphics;

class Arrow extends h2d.Layers {
    public var cx : Int;
    public var cy : Int;
    
    var inter : Interactive;

    public function new(tx:Int, ty:Int) {
        super();
        cx = tx;
        cy = ty;
        
        var arrow = new h2d.Graphics(this);
		arrow.beginFill(0xff00ff);
        arrow.drawRect(0, 0, Const.ARROW_TILE_WIDTH, Const.ARROW_TILE_HEIGHT);
        this.setPosition(cx*Const.MAP_TILE_SIZE-Const.ARROW_TILE_WIDTH/2, cy*Const.MAP_TILE_SIZE+Const.ARROW_TILE_HEIGHT/2);

        /*inter = new Interactive(Const.ARROW_TILE_WIDTH, Const.ARROW_TILE_HEIGHT, this);
        inter.backgroundColor = 0x55ff00ff;

        inter.onClick = function(e) {

        }*/
    }
}