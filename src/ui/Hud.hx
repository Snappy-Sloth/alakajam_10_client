package ui;

import h2d.Graphics;
import h2d.Text;

class Hud extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;

	var flowLife : h2d.Flow;
	var invalidated = true;

	var width : Int;
	var height : Int;

	var arLife : Array<Graphics>;

	public function new(wi:Int, he:Int) {
		super(Game.ME);

		width = wi;
		height = he;
		arLife = [];

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		flowLife = new h2d.Flow(root);
		flowLife.layout = Horizontal;
		flowLife.horizontalSpacing = 10;

		var numberLife = game.numberLife;
		//var numberLifeText = new Text(Assets.fontPixel, flow);
		//numberLifeText.text = 'Nombre de vies : $numberLife';
		for (i in 0...numberLife) {
			var life = new Graphics(flowLife);
			life.beginFill(0xff0000);
			life.drawRect(0, 0, 10, 10);
			arLife.push(life);
		}

		flowLife.reflow();
		//flow.setPosition((w() - flow.outerWidth) >> 1, (h() - flow.outerHeight) >> 1);
		flowLife.setPosition((w()/Const.SCALE+width*Const.MAP_TILE_SIZE)/2+Const.FLOW_MAPTILE_SPACING, (h()/Const.SCALE-height*Const.MAP_TILE_SIZE)/2+10);
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
