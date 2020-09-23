package ui;

class EndLevelScreen extends dn.Process {

	public static var ME : EndLevelScreen;

    var flow : h2d.Flow;

	public function new() {
		super(Game.ME);

		createRoot();

		ME = this;

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.verticalSpacing = 20;
		flow.horizontalAlign = Middle;
        
        var endLevelText = new h2d.Text(Assets.fontPixel, flow);
		endLevelText.text = 'Victory!';
		endLevelText.setScale(Const.SCALE);

		flow.addSpacing(20);
		
		var flowInfo1 = new h2d.Flow(flow);
		flowInfo1.layout = Horizontal;
		flowInfo1.horizontalSpacing = 40;

		var levelText = new h2d.Text(Assets.fontPixel, flowInfo1);
		levelText.text = 'Level: ${Game.ME.level.getLevelNumber()}';
		
		var scoreText = new h2d.Text(Assets.fontPixel, flow);
		scoreText.text = 'Moves: ${Std.int(Game.ME.level.currentScore)}';
		
		var previousScoreText = new h2d.Text(Assets.fontPixel, flow);
		if (Const.GET_HIGHSCORE_ON_LEVEL(Game.ME.level.getLevelNumber()) > Game.ME.level.currentScore)
			previousScoreText.text = 'Current highscore: ${Const.GET_HIGHSCORE_ON_LEVEL(Game.ME.level.getLevelNumber())}';
		else
			previousScoreText.text = 'New level highscore!';

		var flowInfo2 = new h2d.Flow(flow);
		flowInfo2.layout = Horizontal;
		flowInfo2.verticalAlign = Middle;
		flowInfo2.horizontalSpacing = 40;
		
		var scoreText = new h2d.Text(Assets.fontPixel, flow);
		scoreText.text = 'Total Moves: ${Std.int(Game.ME.score)}';
		scoreText.scale(Const.SCALE);

		flow.addSpacing(20);

        var nextLevelBtn = new ButtonMenu("Next Level", function() {
			this.destroy();
			Game.ME.goToNextLevel();
		});
		flow.addChild(nextLevelBtn);

		Const.PLAYER_DATA.scores[Game.ME.level.getLevelNumber()] = Std.int(Game.ME.level.currentScore);
		Const.SAVE_PROGRESS();

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