package ui;

class EndCampaignScreen extends dn.Process {

	public static var ME : EndCampaignScreen;

	var flow : h2d.Flow;
	var congratsText : h2d.Text;
	var endCampaignText : h2d.Text;
	var scoreText : h2d.Text;
	var menuBtn : ButtonMenu;
	
	var controlLock(default, null) = false;

	var cinematic : dn.Cinematic;

	public function new() {
		super(Main.ME);

		createRoot();

		ME = this;

		cinematic = new dn.Cinematic(Const.FPS);

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.verticalSpacing = 20;
		flow.horizontalAlign = Middle;
        
        congratsText = new h2d.Text(Assets.fontPixel, flow);
		congratsText.text = 'Congratulations!';
		congratsText.setScale(Const.SCALE);
		congratsText.alpha = 0;

		endCampaignText = new h2d.Text(Assets.fontPixel, flow);
		endCampaignText.text = 'You finished the Campaign!';
		endCampaignText.setScale(Const.SCALE);
		endCampaignText.alpha = 0;

		flow.addSpacing(20);
		
		scoreText = new h2d.Text(Assets.fontPixel, flow);
		scoreText.text = 'Total Moves: ${Std.int(Game.ME.score)}';			

		flow.addSpacing(20);

        menuBtn = new ButtonMenu("Menu", onClickBtn);
		flow.addChild(menuBtn);

		onResize();

		scoreText.x -= w()/Const.SCALE;
		menuBtn.y += h()/Const.SCALE;

		cinematic.create({
			250;
			tw.createS(congratsText.alpha, 1, 0.5).end(()->cinematic.signal());
			end;
			200;
			tw.createS(endCampaignText.alpha, 1, 0.5).end(()->cinematic.signal());
			end;
			400;
			tw.createS(scoreText.x, scoreText.x+(w()/Const.SCALE), 0.3).end(()->cinematic.signal());
			end;
			tw.createS(menuBtn.y, menuBtn.y-(h()/Const.SCALE), 0.5);
		});
	}

	public function onClickBtn() {
		if (controlLock) return;
		controlLock = true;
		cinematic.create({
			tw.createS(congratsText.x, congratsText.x+(w()/Const.SCALE), 0.3);
			tw.createS(endCampaignText.x, endCampaignText.x+(w()/Const.SCALE), 0.3);
			tw.createS(scoreText.x, scoreText.x+(w()/Const.SCALE), 0.3);
			tw.createS(menuBtn.y, menuBtn.y+(h()/Const.SCALE), 0.5).end(()->cinematic.signal());
			end;
			Main.ME.startTitleScreen();
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