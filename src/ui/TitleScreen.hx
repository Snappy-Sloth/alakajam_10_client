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