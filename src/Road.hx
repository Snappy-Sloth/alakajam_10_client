class Road {

	public var from(default, null) : EP;
	public var to(default, null) : EP;

	public var fromX(get, never) : Float; inline function get_fromX() return dn.Lib.getEnumMetaFloat(from, "x") * Const.MAP_TILE_SIZE;
	public var fromY(get, never) : Float; inline function get_fromY() return dn.Lib.getEnumMetaFloat(from, "y") * Const.MAP_TILE_SIZE;
	public var toX(get, never) : Float; inline function get_toX() return dn.Lib.getEnumMetaFloat(to, "x") * Const.MAP_TILE_SIZE;
	public var toY(get, never) : Float; inline function get_toY() return dn.Lib.getEnumMetaFloat(to, "y") * Const.MAP_TILE_SIZE;

	public var mapTile : MapTile;

	public function new(from:EP, to:EP, mapTile:MapTile) {
		this.from = from;
		this.to = to;

		this.mapTile = mapTile;
	}

	public function onRotation(newFrom:EP, newTo:EP) {
		from = newFrom;
		to = newTo;
	}
}