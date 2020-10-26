package ui;

class Options extends dn.Process {

	var mainFlow : h2d.Flow;
	var flow : h2d.Flow;
	var bgFlow : h2d.ScaleGrid;
	var nextLevelBtn : ButtonMenu;

	var controlLock(default, null) = false;
	
	var cinematic : dn.Cinematic;

	public function new() {
		super(Main.ME);

		createRoot();

		cinematic = new dn.Cinematic(Const.FPS);

		mainFlow = new h2d.Flow(root);
		mainFlow.layout = Vertical;
		mainFlow.horizontalAlign = Middle;
		mainFlow.verticalSpacing = 30;

		flow = new h2d.Flow(mainFlow);
		flow.layout = Vertical;
		// flow.debug = true;
		flow.horizontalAlign = Middle;
		flow.verticalSpacing = 15;
		flow.padding = 20;

		bgFlow = new h2d.ScaleGrid(Assets.tiles.getTile("bgUIsg"), 11, 11, flow);
		flow.getProperties(bgFlow).isAbsolute = true;

		var optionsText = new h2d.Text(Assets.fontOeuf26, flow);
		optionsText.text = 'OPTIONS';
		// optionsText.alpha = 0;
		optionsText.dropShadow = {dx: 0, dy: 2, alpha: 1, color: 0x895515};

		Assets.tiles.h_get("separationBar", flow);

		trace(Const.OPTIONS_DATA.SFX_VOLUME);

		createSliderFlow("SFX", Const.OPTIONS_DATA.SFX_VOLUME, function (v) {
			Const.OPTIONS_DATA.SFX_VOLUME = v;
			Assets.UPDATE_SFX_VOLUME();
		});
		createSliderFlow("Music", Const.OPTIONS_DATA.MUSIC_VOLUME, function (v) {
			Const.OPTIONS_DATA.MUSIC_VOLUME = v;
			Assets.UPDATE_MUSIC_VOLUME();
		});

		Assets.tiles.h_get("separationBar", flow);

		var creditsText = new h2d.Text(Assets.fontOeuf13, flow);
		creditsText.lineSpacing = 10;
		// creditsText.textColor = 0x404040;
		creditsText.text = "- A game developed by Titaninette and Tipyx\n- SFXs by FreeSounds\n- Initially done for the Alakajam #10";
		creditsText.dropShadow = {dx: 0, dy: 1, alpha: 1, color: 0x895515};

		nextLevelBtn = new ButtonMenu("Back", onClickBtn);
		mainFlow.addChild(nextLevelBtn);

		onResize();

		flow.y -= (h()/Const.SCALE);
		nextLevelBtn.y += (h()/Const.SCALE);
		
		tw.createS(flow.y, flow.y + (h()/Const.SCALE), 0.5);
		tw.createS(nextLevelBtn.y, nextLevelBtn.y - (h()/Const.SCALE), 0.5).end(()->cinematic.signal());
	}

	public function onClickBtn() {
		if (controlLock) return;
		controlLock = true;
		cinematic.create({
			tw.createS(flow.y, flow.y-(h()/Const.SCALE), 0.5);
			tw.createS(nextLevelBtn.y, nextLevelBtn.y+(h()/Const.SCALE), 0.5).end(()->cinematic.signal());
			end;
			this.destroy();
			Main.ME.startTitleScreen();
		});
	}

	function createSliderFlow(name:String, initialValue:Float, onChange:Float->Void) {
		var subFlow = new h2d.Flow(flow);
		subFlow.layout = Horizontal;
		subFlow.verticalAlign = Middle;
		subFlow.horizontalSpacing = 20;
		subFlow.minWidth = subFlow.maxWidth = flow.innerWidth;

		var text = new h2d.Text(Assets.fontOeuf13, subFlow);
		text.text = name;
		text.textColor = 0xFFFFFF;
		text.dropShadow = {dx: 0, dy: 1, alpha: 1, color: 0x895515};
		subFlow.getProperties(text).horizontalAlign = Left;
		subFlow.getProperties(text).minWidth = 50;
		subFlow.getProperties(text).paddingLeft = 10;
		
		var slider = new Slider(initialValue, onChange);
		subFlow.addChild(slider);
		subFlow.getProperties(slider).horizontalAlign = Right;
	}

	override function onResize() {
		super.onResize();
		
		root.setScale(Const.SCALE);

		flow.reflow();

		bgFlow.width = flow.outerWidth;
		bgFlow.height = flow.outerHeight;

		mainFlow.reflow();
		mainFlow.setPosition(Std.int((w() / Const.SCALE) - mainFlow.outerWidth) >> 1, Std.int((h() / Const.SCALE) - mainFlow.outerHeight) >> 1);
	}

	override function update() {
		super.update();

		cinematic.update(tmod);
	}

}