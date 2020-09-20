package ui;

class TitleScreen extends dn.Process {

	public static var ME : TitleScreen;

	var flow : h2d.Flow;

	public function new() {
		super(Main.ME);

		createRoot();

		ME = this;

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.horizontalAlign = Middle;
		flow.verticalSpacing = 20;

		var title = Assets.tiles.h_get("title");
		flow.addChild(title);

		flow.addSpacing(50);

		var campaignBtn = new Button("Campaign", Main.ME.startCampaign);
		flow.addChild(campaignBtn);

		var chooseLevelBtn = new Button("Choose Level", Main.ME.startChooseLevelScreen);
		flow.addChild(chooseLevelBtn);

		#if debug
		/*var level2x2Btn = new Button("2x2", Main.ME.showDebugLevel2x2);
		flow.addChild(level2x2Btn);

		var level2x3Btn = new Button("2x3", Main.ME.showDebugLevel2x3);
		flow.addChild(level2x3Btn);

		var level3x2Btn = new Button("3x2", Main.ME.showDebugLevel3x2);
		flow.addChild(level3x2Btn);

		var level3x3Btn = new Button("3x3", Main.ME.showDebugLevel3x3);
		flow.addChild(level3x3Btn);

		var titaBtn = new Button("Tipyx", Main.ME.showDebugTita);
		flow.addChild(titaBtn);

		var tipyxBtn = new Button("Tipyx", Main.ME.showDebugTipyx);
		flow.addChild(tipyxBtn);*/
		#end

		onResize();
	}

	override function onDispose() {
		super.onDispose();

		ME = null;
	}

	override function onResize() {
		super.onResize();

		root.setScale(Const.SCALE);
		
		flow.reflow();
		flow.setPosition(Std.int((w() / Const.SCALE) - flow.outerWidth) >> 1, Std.int((h() / Const.SCALE) - flow.outerHeight) >> 1);
	}

}