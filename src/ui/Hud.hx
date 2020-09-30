package ui;

import h2d.Text;

class Hud extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;

	var flowRight : h2d.Flow;
	var levelText : h2d.Text;
	var scoreMinText : Text;
	var scoreText : Text;

	var flowLeft : h2d.Flow;
	var menuButton : ButtonMenu;

	
	var invalidated = true;

	var width : Int;
	var height : Int;

	public var playBtn(default, null) : PlayButton;

	public function new(wi:Int, he:Int) {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		setRightHud(wi, he);
		setLeftHud(wi, he);

		onResize();

		flowRight.x += w()/Const.SCALE;
		flowLeft.x -= w()/Const.SCALE;

		tw.createS(flowRight.x, flowRight.x-(w()/Const.SCALE), 0.5);
		tw.createS(flowLeft.x, flowLeft.x+(w()/Const.SCALE), 0.5);
	}

	function disappear() {
		tw.createS(flowRight.x, flowRight.x+(w()/Const.SCALE), 0.5);
		tw.createS(flowLeft.x, flowLeft.x-(w()/Const.SCALE), 0.5);
	}

	function setRightHud(wi:Int, he:Int) {
		width = wi;
		height = he;

		flowRight = new h2d.Flow(root);
		flowRight.layout = Vertical;
		flowRight.verticalSpacing = 20;
		
		levelText = new Text(Assets.fontPixel, flowRight);
		levelText.text = 'Level: ${Game.ME.level.getLevelNumber()}';

		flowRight.addSpacing(30);

		scoreMinText = new Text(Assets.fontPixel, flowRight);
		scoreMinText.text = 'Moves min: ${level.levelScoreMin}';

		flowRight.addSpacing(10);

		scoreText = new Text(Assets.fontPixel, flowRight);
		scoreText.text = 'Moves: ${level.currentScore}';

		flowRight.addSpacing(30);

		playBtn = new PlayButton(level);
		flowRight.addChild(playBtn);
	}

	function setLeftHud(wi:Int, he:Int) {
		width = wi;
		height = he;

		flowLeft = new h2d.Flow(root);
		flowLeft.layout = Vertical;
		flowLeft.verticalSpacing = 20;

		menuButton = new ButtonMenu("Menu", Main.ME.startTitleScreen);
		flowLeft.addChild(menuButton);
	}

	public function onResetShips() {
		playBtn.reset();
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);

		flowRight.reflow();
		flowRight.setPosition(Std.int((w() / Const.SCALE + width * Const.MAP_TILE_SIZE) / 2) + Const.FLOW_MAPTILE_SPACING,
							Std.int((h() / Const.SCALE - height * Const.MAP_TILE_SIZE) / 2));

		flowLeft.reflow();
		flowLeft.setPosition(Std.int(((w() / Const.SCALE - width * Const.MAP_TILE_SIZE) / 2) - flowLeft.outerWidth) - Const.FLOW_MAPTILE_SPACING,
								Std.int((h() / Const.SCALE - height * Const.MAP_TILE_SIZE) / 2));
	}

	public inline function invalidate() invalidated = true;

	function render() {}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}

		scoreText.text = 'Moves: ${Std.int(level.currentScore)}';
	}
}
