class MapTile extends h2d.Layers {

	public var cx : Int;
	public var cy : Int;
	
	public function new(tx:Int, ty:Int) {
		super();
		cx = tx;
		cy = ty;
		
		var bmp = new h2d.Graphics(this);
		bmp.beginFill(Color.randomColor());
		bmp.drawRect(0, 0, Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE);

		this.setPosition(cx*Const.MAP_TILE_SIZE, cy*Const.MAP_TILE_SIZE);
	}

}