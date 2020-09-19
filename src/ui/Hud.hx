package ui;

import h2d.Graphics;
import h2d.Text;

class Hud extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;

	var flowRight : h2d.Flow;
	var flowLife : h2d.Flow;
	var flowLevel : h2d.Flow;
	var flowScore : h2d.Flow;
	var flowTime : h2d.Flow;

	var flowLeft : h2d.Flow;

	var scoreText : Text;

	var timeText : Text;
	var invalidated = true;

	var width : Int;
	var height : Int;

	var arLife : Array<Graphics>;

	public function new(wi:Int, he:Int) {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		setrightHud(wi, he);
		setLeftHud(wi, he);
	}

	public function setrightHud(wi:Int, he:Int) {
		width = wi;
		height = he;
		arLife = [];

		flowRight = new h2d.Flow(root);
		flowRight.layout = Vertical;
		flowRight.verticalSpacing = 20;
		flowRight.setPosition(((w() / Const.SCALE + width * Const.MAP_TILE_SIZE) / 2) + Const.FLOW_MAPTILE_SPACING,
							((h() / Const.SCALE - height * Const.MAP_TILE_SIZE) / 2));

		flowLevel = new h2d.Flow(flowRight);
		flowLevel.layout = Horizontal;
		flowLevel.horizontalSpacing = 10;
		
		var levelText = new Text(Assets.fontPixel, flowLevel);
		levelText.text = 'Level : 1';
		
		flowLife = new h2d.Flow(flowRight);
		flowLife.layout = Horizontal;
		flowLife.horizontalSpacing = 10;

		var numberLife = game.numberLife;
		for (i in 0...numberLife) {
			var life = new Graphics(flowLife);
			life.beginFill(0xff0000);
			life.drawRect(0, 0, 10, 10);
			arLife.push(life);
		}

		//flow.setPosition((w() - flow.outerWidth) >> 1, (h() - flow.outerHeight) >> 1);
		
		flowScore = new h2d.Flow(flowRight);
		flowScore.layout = Horizontal;
		flowScore.horizontalSpacing = 10;

		scoreText = new Text(Assets.fontPixel, flowScore);

		flowTime = new h2d.Flow(flowRight);
		flowTime.layout = Horizontal;
		flowTime.horizontalSpacing = 10;
		
		timeText = new Text(Assets.fontPixel, flowTime);
		timeText.text = 'Time : ${Lib.prettyTime(level.ftime)}';

		flowRight.reflow();
	}

	public function setLeftHud(wi:Int, he:Int) {
		width = wi;
		height = he;

		flowLeft = new h2d.Flow(root);
		flowLeft.layout = Vertical;
		flowLeft.verticalSpacing = 20;

		var menuButton = new Button("Menu", Main.ME.startTitleScreen);
		flowLeft.addChild(menuButton);

		flowLeft.reflow();
		flowLeft.setPosition(((w() / Const.SCALE - width * Const.MAP_TILE_SIZE) / 2) - flowLeft.outerWidth - Const.FLOW_MAPTILE_SPACING,
								((h() / Const.SCALE - height * Const.MAP_TILE_SIZE) / 2));
	}

	public function looseLife() {
		arLife[game.numberLife].visible = false;
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
		timeText.text = 'Time : ${Lib.prettyTime((level.ftime/Const.FPS)*1000)}';
		scoreText.text = 'Score : ${game.score}';
	}
}
