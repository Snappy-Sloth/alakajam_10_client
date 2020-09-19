class MapTile extends h2d.Layers {

	public function new() {
		super();
		
		var bmp = new h2d.Graphics(this);
		bmp.beginFill(Color.randomColor());
		bmp.drawRect(0, 0, Const.MAP_TILE_SIZE, Const.MAP_TILE_SIZE);
	}

}