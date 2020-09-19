package ui;

class EndLevelScreen extends dn.Process {

	public static var ME : EndLevelScreen;

    var flow : h2d.Flow;

    var arLife : Array<h2d.Graphics>;

	public function new() {
		super(Main.ME);

		createRoot();

		ME = this;

		arLife = [];

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
        flow.verticalSpacing = 20;
        
        var endLevelText = new h2d.Text(Assets.fontPixel, flow);
        endLevelText.text = 'Victory!';

        var levelText = new h2d.Text(Assets.fontPixel, flow);
        levelText.text = 'Level: 1';
        
        var flowLife = new h2d.Flow(flow);
		flowLife.layout = Horizontal;
        flowLife.horizontalSpacing = 10;
        
        var numberLife = Game.ME.numberLife;
		for (i in 0...numberLife) {
			var life = new h2d.Graphics(flowLife);
			life.beginFill(0xff0000);
			life.drawRect(0, 0, 10, 10);
			arLife.push(life);
        }

        var scoreText = new h2d.Text(Assets.fontPixel, flow);
		scoreText.text = 'Score: ${Game.ME.score}';
		
		var levelTimeText = new h2d.Text(Assets.fontPixel, flow);
		levelTimeText.text = 'Level Time: ${Lib.prettyTime(Game.ME.level.ftime)}';

		var gameTimeText = new h2d.Text(Assets.fontPixel, flow);
		gameTimeText.text = 'Total Campaign Time: à définir';

        var nextLevelBtn = new Button("Next Level", Main.ME.showDebugLevel2x2);
		flow.addChild(nextLevelBtn);

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