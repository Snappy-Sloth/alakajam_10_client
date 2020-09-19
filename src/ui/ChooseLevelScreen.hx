package ui;

class ChooseLevelScreen extends dn.Process {

	public static var ME : ChooseLevelScreen;

	public function new() {
		super(Main.ME);

		createRoot();

		ME = this;

		var flow = new h2d.Flow(root);
		flow.layout = Vertical;
        flow.verticalSpacing = 20;
        
        var level1Btn = new Button("Level 1", Main.ME.showDebugLevel2x2);
		flow.addChild(level1Btn);

		var level2Btn = new Button("Level 2", Main.ME.showDebugLevel2x3);
		flow.addChild(level2Btn);

		var level3Btn = new Button("Level 3", Main.ME.showDebugLevel3x2);
		flow.addChild(level3Btn);

		var level4Btn = new Button("Level 4", Main.ME.showDebugLevel3x3);
		flow.addChild(level4Btn);

		flow.reflow();
		flow.setPosition((w() - flow.outerWidth) >> 1, (h() - flow.outerHeight) >> 1);
	}

	override function onDispose() {
		super.onDispose();

		ME = null;
    }
    
    override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
	}

}