package ui;

class TitleScreen extends dn.Process {

	public static var ME : TitleScreen;

	var flow : h2d.Flow;
	var title : HSprite;
	var campaignBtn : ButtonMenu;
	var chooseLevelBtn : ButtonMenu;

	var cinematic : dn.Cinematic;

	public function new() {
		super(Main.ME);

		createRoot();

		ME = this;

		cinematic = new dn.Cinematic(Const.FPS);

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.horizontalAlign = Middle;
		flow.verticalSpacing = 20;

		title = Assets.tiles.h_get("title");
		flow.addChild(title);

		flow.addSpacing(50);

		campaignBtn = new ButtonMenu("Campaign", onClickBtn.bind(Main.ME.startCampaign));
		flow.addChild(campaignBtn);

		chooseLevelBtn = new ButtonMenu("Choose Level", onClickBtn.bind(Main.ME.startChooseLevelScreen));
		flow.addChild(chooseLevelBtn);

		onResize();

		campaignBtn.x += w()/2;
		chooseLevelBtn.x -= w()/2;

		cinematic.create({
			tw.createS(title.alpha, 0>1, 0.5).end(()->cinematic.signal());
			tw.createS(campaignBtn.x, campaignBtn.x-(w()/2), 0.5);
			tw.createS(chooseLevelBtn.x, chooseLevelBtn.x+(w()/2), 0.5);
		});
	}

	public function onClickBtn(onEnd:Void->Void) {
		cinematic.create({
			tw.createS(title.alpha, 0, 0.5);
			tw.createS(campaignBtn.x, campaignBtn.x-(w()/2), 0.5);
			tw.createS(chooseLevelBtn.x, chooseLevelBtn.x+(w()/2), 0.5).end(()->cinematic.signal());
			end;
			onEnd();
		});
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

	override function update() {
		super.update();

		cinematic.update(tmod);
	}
}