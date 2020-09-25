package ui;

import h2d.Text;

class ChooseLevelScreen extends dn.Process {

	public static var ME : ChooseLevelScreen;

	var flowVer : h2d.Flow;
	var flowHor : h2d.Flow;
	var returnMenuBtn : ButtonMenu;
	var arLevelBtn : Array<ButtonLevel>;

	var cinematic : dn.Cinematic;

	var levels : Array<Data.Campaign> = [];

	public function new() {
		super(Main.ME);

		createRoot();

		ME = this;

		arLevelBtn = [];

		cinematic = new dn.Cinematic(Const.FPS);

		levels = [];

		for (lvl in Data.Campaign.all) {
			levels.push(lvl);
		}

		flowVer = new h2d.Flow(root);
		flowVer.layout = Vertical;
		flowVer.horizontalAlign = Middle;
		flowVer.verticalSpacing = 20;
		
		var numHorFlow = Math.ceil(levels.length/5);

		for (j in 0...numHorFlow) {
			flowHor = new h2d.Flow(flowVer);
			flowHor.layout = Horizontal;
        	flowHor.horizontalSpacing = 20;
			
			if (5*(j+1) < levels.length) {
				for (i in 5*j...5*(j+1)) {
					var levelBtn = new ButtonLevel('Level ${i+1}', onClickBtn.bind(Main.ME.startOneLevel.bind(levels[i])));
					flowHor.addChild(levelBtn);
					levelBtn.alpha = 0;
					arLevelBtn.push(levelBtn);
				}
			}
			else {
				for (i in 5*j...levels.length) {
					var levelBtn = new ButtonLevel('Level ${i+1}', onClickBtn.bind(Main.ME.startOneLevel.bind(levels[i])));
					flowHor.addChild(levelBtn);
					levelBtn.alpha = 0;
					arLevelBtn.push(levelBtn);
				}
			}
		}

		returnMenuBtn = new ButtonMenu("Menu", onClickBtn.bind(Main.ME.startTitleScreen));
		flowVer.addChild(returnMenuBtn);

		onResize();

		returnMenuBtn.y += h()/Const.SCALE;

		cinematic.create({
			tw.createS(returnMenuBtn.y, returnMenuBtn.y-(h()/Const.SCALE), 0.5);
			for (b in arLevelBtn) {
				tw.createS(b.alpha, 1, 0.5);
				10;
			}
		});
	}

	public function onClickBtn(onEnd:Void->Void) {
		cinematic.create({
			for (b in arLevelBtn) {
				tw.createS(b.alpha, 0, 0.5);
				10;
			}
			tw.createS(returnMenuBtn.y, returnMenuBtn.y+(h()/Const.SCALE), 0.5).end(()->cinematic.signal());
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

		flowVer.reflow();
		flowVer.setPosition(Std.int((w() / Const.SCALE) - flowVer.outerWidth) >> 1, Std.int((h() / Const.SCALE) - flowVer.outerHeight) >> 1);
	}

	override function update() {
		super.update();

		cinematic.update(tmod);
	}
}