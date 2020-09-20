package ui;

class ChooseLevelScreen extends dn.Process {

	public static var ME : ChooseLevelScreen;

	var flow : h2d.Flow;

	var levels : Array<Data.Campaign> = [];

	public function new() {
		super(Main.ME);

		createRoot();

		ME = this;

		levels = [];

		for (lvl in Data.Campaign.all) {
			levels.push(lvl);
		}

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
        flow.verticalSpacing = 20;
		
		var numHorFlow = Math.ceil(levels.length/4);
		trace('$numHorFlow');

		for (j in 0...4) {
			for (i in 0...levels.length) {
				var levelBtn = new Button('Level ${i+1}', Main.ME.startOneLevel.bind(levels[i]));
				flow.addChild(levelBtn);
			}
		}

		flow.maxHeight = Std.int(h() / Const.SCALE) - 2 * Const.FLOW_MAPTILE_SPACING;

        /*var level1Btn = new Button("Level 1", Main.ME.showDebugLevel2x2);
		flow.addChild(level1Btn);

		var level2Btn = new Button("Level 2", Main.ME.showDebugLevel2x3);
		flow.addChild(level2Btn);

		var level3Btn = new Button("Level 3", Main.ME.showDebugLevel3x2);
		flow.addChild(level3Btn);

		var level4Btn = new Button("Level 4", Main.ME.showDebugLevel3x3);
		flow.addChild(level4Btn);*/

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