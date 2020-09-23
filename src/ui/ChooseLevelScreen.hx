package ui;

class ChooseLevelScreen extends dn.Process {

	public static var ME : ChooseLevelScreen;

	var flowVer : h2d.Flow;

	var levels : Array<Data.Campaign> = [];

	public function new() {
		super(Main.ME);

		createRoot();

		ME = this;

		levels = [];

		for (lvl in Data.Campaign.all) {
			levels.push(lvl);
		}

		flowVer = new h2d.Flow(root);
		flowVer.layout = Vertical;
        flowVer.verticalSpacing = 20;
		
		var numHorFlow = Math.ceil(levels.length/5);

		for (j in 0...numHorFlow) {
			var flowHor = new h2d.Flow(flowVer);
			flowHor.layout = Horizontal;
        	flowHor.horizontalSpacing = 20;
			
			if (5*(j+1) < levels.length) {
				for (i in 5*j...5*(j+1)) {
					var levelBtn = new ButtonLevel('Level ${i+1}', Main.ME.startOneLevel.bind(levels[i]));
					flowHor.addChild(levelBtn);
				}
			}
			else {
				for (i in 5*j...levels.length) {
					var levelBtn = new ButtonLevel('Level ${i+1}', Main.ME.startOneLevel.bind(levels[i]));
					flowHor.addChild(levelBtn);
				}
			}
		}

		onResize();
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

}