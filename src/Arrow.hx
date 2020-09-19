class Arrow extends h2d.Layers {
    public var cx : Int;
	public var cy : Int;

    public function new(tx:Int, ty:Int) {
        super();
        cx = tx;
        cy = ty;
        
        var arrow = new h2d.Graphics(this);
		arrow.beginFill(0xff00ff);
        arrow.drawRect(0, 0, Const.ARROW_TILE_WIDTH, Const.ARROW_TILE_HEIGHT);
        this.setPosition(cx*Const.MAP_TILE_SIZE-Const.ARROW_TILE_WIDTH/2, cy*Const.MAP_TILE_SIZE+Const.ARROW_TILE_HEIGHT/2);
    }
}