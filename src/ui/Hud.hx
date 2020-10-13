package ui;

import h2d.Text;

class Hud extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;

	var mainFlow : h2d.Flow;
	var bgFlow : h2d.ScaleGrid;
	var flowInfos : h2d.Flow;
	var scoreMinText : Text;
	var scoreText : Text;

	var menuButton : MenuButton;
	
	var invalidated = true;

	var width : Int;
	var height : Int;

	public var playBtn(default, null) : PlayButton;

	public function new(wi:Int, he:Int) {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		setRightHud(wi, he);

		menuButton = new MenuButton("", game.level.closeLevel.bind(Main.ME.startTitleScreen));
		root.addChild(menuButton);

		onResize();

		menuButton.y -= 100;
		mainFlow.x += w()/Const.SCALE;
	}
	
	public function appear(duration:Float) {
		// TODO : check duration
		tw.createS(menuButton.y, menuButton.y + 100, 0.5);
		tw.createS(mainFlow.x, mainFlow.x-(w()/Const.SCALE), 0.5);
	}

	public function disappear(duration:Float) {
		tw.createS(menuButton.y, menuButton.y - 100, duration);
		tw.createS(mainFlow.x, mainFlow.x+(w()/Const.SCALE), duration);
	}

	function setRightHud(wi:Int, he:Int) {
		width = wi;
		height = he;

		mainFlow = new h2d.Flow(root);
		mainFlow.layout = Vertical;
		mainFlow.verticalSpacing = 30;
		mainFlow.horizontalAlign = Middle;
		mainFlow.minWidth = mainFlow.maxWidth = Std.int((w() / Const.SCALE) * (2 / 3) - 30 - ((level.wid * Const.MAP_TILE_SIZE) / 2));
		
		flowInfos = new h2d.Flow(mainFlow);
		flowInfos.layout = Vertical;
		flowInfos.horizontalAlign = Middle;
		flowInfos.padding = 15;
		flowInfos.minWidth = 150;
		
		bgFlow = new h2d.ScaleGrid(Assets.tiles.getTile("bgUIsg"), 11, 11, flowInfos);
		flowInfos.getProperties(bgFlow).isAbsolute = true;

		var levelText = new Text(Assets.fontOeuf26, flowInfos);
		levelText.text = 'Level ${Game.ME.level.getLevelNumber()}';
		levelText.dropShadow = {dx: 0, dy: 2, alpha: 1, color: 0x895515};

		flowInfos.addSpacing(30);

		scoreMinText = createSubFlowText("Moves min:");

		flowInfos.addSpacing(10);

		scoreText = createSubFlowText("Moves:");

		playBtn = new PlayButton(level);
		mainFlow.addChild(playBtn);
	}

	inline function createSubFlowText(str:String):h2d.Text {
		flowInfos.reflow();

		var flow = new h2d.Flow(flowInfos);
		flow.minWidth = flow.maxWidth = flowInfos.innerWidth;

		var labelText = new Text(Assets.fontOeuf13, flow);
		flow.getProperties(labelText).horizontalAlign = Left;
		labelText.text = str;
		labelText.dropShadow = {dx: 0, dy: 1, alpha: 1, color: 0x895515};
		
		var valueText = new Text(Assets.fontOeuf13, flow);
		flow.getProperties(valueText).horizontalAlign = Right;
		valueText.dropShadow = {dx: 0, dy: 1, alpha: 1, color: 0x895515};

		return valueText;
	}

	public function onResetShips() {
		playBtn.reset();
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);

		flowInfos.reflow();

		mainFlow.reflow();
		mainFlow.setPosition(	Std.int((w() / Const.SCALE) - mainFlow.outerWidth),
								Std.int((h() / Const.SCALE - mainFlow.outerHeight) / 2));

		bgFlow.width = flowInfos.outerWidth;
		bgFlow.height = flowInfos.outerHeight;

		menuButton.setPosition((w() / Const.SCALE) - menuButton.wid - 10, 10);
	}

	public inline function invalidate() invalidated = true;

	function render() {
		scoreMinText.text = '${level.levelScoreMin}';
		scoreText.text = '${Std.int(level.currentScore)}';
	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}
