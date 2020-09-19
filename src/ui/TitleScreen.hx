package ui;

class TitleScreen extends dn.Process {

	public static var ME : TitleScreen;

	public function new() {
		super(Main.ME);

		createRoot();

		ME = this;

		var flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.verticalSpacing = 20;

		#if debug
		var level2x2Btn = new Button("2x2", Main.ME.showDebugLevel2x2);
		flow.addChild(level2x2Btn);

		var level2x3Btn = new Button("2x3", Main.ME.showDebugLevel2x3);
		flow.addChild(level2x3Btn);

		var level3x2Btn = new Button("3x2", Main.ME.showDebugLevel3x2);
		flow.addChild(level3x2Btn);

		var level3x3Btn = new Button("3x3", Main.ME.showDebugLevel3x3);
		flow.addChild(level3x3Btn);

		/*var titaBtn = new Button("Tipyx", Main.ME.showDebugTita);
		flow.addChild(titaBtn);*/

		var tipyxBtn = new Button("Tipyx", Main.ME.showDebugTipyx);
		flow.addChild(tipyxBtn);
		#end

		flow.reflow();
		flow.setPosition((w() - flow.outerWidth) >> 1, (h() - flow.outerHeight) >> 1);
	}

	override function onDispose() {
		super.onDispose();

		ME = null;
	}

}

class Button extends h2d.Layers {

	public function new(str:String, onClick:Void->Void) {
		super();

		var inter = new h2d.Interactive(100, 50, this);
		inter.backgroundColor = 0xFF888888;
		inter.onClick = (e)->onClick();

		var text = new h2d.Text(Assets.fontPixel, this);
		text.text = str;
	}

}