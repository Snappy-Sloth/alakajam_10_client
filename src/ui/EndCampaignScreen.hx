package ui;

class EndCampaignScreen extends dn.Process {

	public static var ME : EndCampaignScreen;

	var mainFlow : h2d.Flow;
	var flow : h2d.Flow;
	var mask : h2d.Mask;
	var bgFlow : h2d.ScaleGrid;
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

		mainFlow = new h2d.Flow(root);
		mainFlow.layout = Vertical;
		mainFlow.horizontalAlign = Middle;
		mainFlow.verticalSpacing = 30;

		mask = new h2d.Mask(1, 1, mainFlow);

		flow = new h2d.Flow(mask);
		flow.layout = Vertical;
		flow.verticalSpacing = 10;
		flow.horizontalAlign = Middle;
		flow.padding = 20;
		
		bgFlow = new h2d.ScaleGrid(Assets.tiles.getTile("bgUIsg"), 11, 11, flow);
		flow.getProperties(bgFlow).isAbsolute = true;
        
        congratsText = new h2d.Text(Assets.fontOeuf26, flow);
		congratsText.text = 'Congratulations!';
		congratsText.alpha = 0;
		congratsText.dropShadow = {dx: 0, dy: 2, alpha: 1, color: 0x895515};

		flow.addSpacing(10);

		endCampaignText = new h2d.Text(Assets.fontOeuf13, flow);
		endCampaignText.text = 'You finished the Campaign!';
		endCampaignText.alpha = 0;
		endCampaignText.dropShadow = {dx: 0, dy: 1, alpha: 1, color: 0x895515};

		flow.addSpacing(5);

		var bar = Assets.tiles.h_get("separationBar", flow);
		
		scoreText = new h2d.Text(Assets.fontOeuf13, flow);
		scoreText.text = 'Total Campaign Moves: ${Std.int(Game.ME.score)}';		
		scoreText.dropShadow = {dx: 0, dy: 1, alpha: 1, color: 0x895515};

        menuBtn = new ButtonMenu("Menu", onClickBtn);
		mainFlow.addChild(menuBtn);

		onResize();

		mask.y -= h() / Const.SCALE;
		scoreText.x -= w()/Const.SCALE;
		menuBtn.y += h()/Const.SCALE;
		bar.x -= w()/Const.SCALE;

		cinematic.create({
			250;
			tw.createS(mask.y, mask.y + h() / Const.SCALE, 0.3).end(()->cinematic.signal());
			end;
			100;
			tw.createS(congratsText.alpha, 1, 0.5).end(()->cinematic.signal());
			end;
			200;
			tw.createS(endCampaignText.alpha, 1, 0.5).end(()->cinematic.signal());
			end;
			300;
			tw.createS(bar.x, bar.x+(w()/Const.SCALE), 0.2).end(()->cinematic.signal());
			end;
			200;
			tw.createS(scoreText.x, scoreText.x+(w()/Const.SCALE), 0.3).end(()->cinematic.signal());
			end;
			Assets.CREATE_SOUND(hxd.Res.sfx.popUI, PopUI);
			tw.createS(menuBtn.y, menuBtn.y-(h()/Const.SCALE), 0.5);
		});
	}

	public function onClickBtn() {
		if (controlLock) return;
		controlLock = true;
		cinematic.create({
			tw.createS(mask.y, mask.y-(h()/Const.SCALE), 0.5);
			tw.createS(menuBtn.y, menuBtn.y+(h()/Const.SCALE), 0.5).end(()->cinematic.signal());
			end;
			this.destroy();
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
		
		bgFlow.width = mask.width = flow.outerWidth;
		bgFlow.height = mask.height = flow.outerHeight;

		mainFlow.reflow();
		mainFlow.setPosition(Std.int((w() / Const.SCALE) - mainFlow.outerWidth) >> 1, Std.int((h() / Const.SCALE) - mainFlow.outerHeight) >> 1);
	}

	override function update() {
		super.update();

		cinematic.update(tmod);
	}
}