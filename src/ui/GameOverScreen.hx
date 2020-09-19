package ui;

class GameOverScreen extends dn.Process {

	public static var ME : GameOverScreen;

	public function new() {
		super(Main.ME);

		createRoot();

		ME = this;

		var flow = new h2d.Flow(root);
		flow.layout = Vertical;
        flow.verticalSpacing = 20;
        
        var gameOverText = new h2d.Text(Assets.fontPixel, flow);
        gameOverText.text = 'GAME OVER';
        gameOverText.scale(Const.SCALE);

		flow.reflow();
		flow.setPosition((w() - flow.outerWidth) >> 1, (h() - flow.outerHeight) >> 1);
	}

	override function onDispose() {
		super.onDispose();

		ME = null;
	}

}