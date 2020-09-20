package ui;

class GameOverScreen extends dn.Process {

	public static var ME : GameOverScreen;

	var flow : h2d.Flow;

	public function new() {
		super(Game.ME);

		createRoot();

		ME = this;

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.verticalSpacing = 50;
		flow.horizontalAlign = Middle;
        
        var gameOverText = new h2d.Text(Assets.fontPixel, flow);
        gameOverText.text = 'GAME OVER';
		gameOverText.scale(2*Const.SCALE);
		
		var menuBtn = new Button("Menu", Main.ME.startTitleScreen);
		flow.addChild(menuBtn);

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