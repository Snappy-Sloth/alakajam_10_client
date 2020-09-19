package ui;

import h2d.Text;

class Hud extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;

	var flow : h2d.Flow;
	var invalidated = true;

	var width : Int;
	var height : Int;

	public function new(wi:Int, he:Int) {
		super(Game.ME);

		width = wi;
		height = he;

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.verticalSpacing = 20;

		var numberLife = game.numberLife;
		var numberLifeText = new Text(Assets.fontPixel, flow);
		numberLifeText.text = 'Nombre de vies : $numberLife';
		
		flow.addChild(numberLifeText);

		flow.reflow();
		//flow.setPosition((w() - flow.outerWidth) >> 1, (h() - flow.outerHeight) >> 1);
		flow.setPosition((w()/Const.SCALE+width*Const.MAP_TILE_SIZE)/2+Const.FLOW_MAPTILE_SPACING, (h()/Const.SCALE-height*Const.MAP_TILE_SIZE)/2);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}

	public inline function invalidate() invalidated = true;

	function render() {}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}
