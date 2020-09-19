class Level extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	public var wid(get,never) : Int; inline function get_wid() return 16;
	public var hei(get,never) : Int; inline function get_hei() return 16;

	public function new() {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
	}

	public inline function isValid(cx,cy) return cx>=0 && cx<wid && cy>=0 && cy<hei;
	public inline function coordId(cx,cy) return cx + cy*wid;

	override function postUpdate() {
		super.postUpdate();
	}
}