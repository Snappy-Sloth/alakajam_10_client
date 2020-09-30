class Const {
	public static var FPS = 60;
	public static var FIXED_FPS = 30;
	public static var AUTO_SCALE_TARGET_WID = 640; // -1 to disable auto-scaling on width
	public static var AUTO_SCALE_TARGET_HEI = 360; // -1 to disable auto-scaling on height
	// public static var SCALE = 2.0; // ignored if auto-scaling
	public static var SCALE = 1.0; // ignored if auto-scaling
	public static var UI_SCALE = 1.0;
	public static var GRID = 16;

	static var _uniq = 0;
	public static var NEXT_UNIQ(get,never) : Int; static inline function get_NEXT_UNIQ() return _uniq++;
	public static var INFINITE = 999999;

	static var _inc = 0;
	public static var DP_BG = _inc++;
	public static var DP_FX_BG = _inc++;
	public static var DP_MAIN = _inc++;
	public static var DP_EXTERNAL = _inc++;
	public static var DP_FRONT = _inc++;
	public static var DP_FX_FRONT = _inc++;
	public static var DP_TOP = _inc++;
	public static var DP_UI = _inc++;

	public static var MAP_TILE_SIZE = 100;
	public static var ARROW_TILE_WIDTH = 25;
	public static var ARROW_TILE_HEIGHT = 50;
	public static var FLOW_MAPTILE_SPACING = 60;

	public static var BUTTON_WIDTH = 100;
	public static var BUTTON_HEIGHT = 50;

	public static var PLAYER_DATA : PlayerData;
	
	public static function INIT() {
		PLAYER_DATA = dn.LocalStorage.readObject("playerData", {scores:[], maxLevelReached:1});
	}

	public static function SAVE_PROGRESS() {
		dn.LocalStorage.writeObject("playerData", PLAYER_DATA);
	}

	public static function GET_HIGHSCORE_ON_LEVEL(numLevel:Int) {
		return PLAYER_DATA.scores[numLevel];
	}

	public static function mapTilesHasSameRoads(mt1:MapTile, mt2:MapTile) {
		if (mt1.roads.length != mt2.roads.length)
			return false;

		var nIdentical = 0;
		for (r1 in mt1.roads) {
			for (r2 in mt2.roads) {
				if ((r1.pointA == r2.pointA && r1.pointB == r2.pointB)
				||	(r1.pointB == r2.pointA && r1.pointA == r2.pointB))
					nIdentical++;
			}
		}

		return mt1.roads.length == nIdentical;
	}
}
