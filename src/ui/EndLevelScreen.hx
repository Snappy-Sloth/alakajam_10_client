package ui;

class EndLevelScreen extends dn.Process {

	public static var ME : EndLevelScreen;

	var flow : h2d.Flow;
	var endLevelText : h2d.Text;
	var levelText : h2d.Text;
	var scoreText : h2d.Text;
	var previousScoreText : h2d.Text;
	var totalScoreText : h2d.Text;
	var nextLevelBtn : ButtonMenu;
	
	var cinematic : dn.Cinematic;

	public function new() {
		super(Game.ME);

		createRoot();

		ME = this;

		cinematic = new dn.Cinematic(Const.FPS);

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.verticalSpacing = 10;
		flow.horizontalAlign = Middle;
        
        endLevelText = new h2d.Text(Assets.fontPixel, flow);
		endLevelText.text = 'Victory!';
		endLevelText.setScale(Const.SCALE);
		endLevelText.alpha = 0;

		flow.addSpacing(30);
		
		levelText = new h2d.Text(Assets.fontPixel, flow);
		levelText.text = 'Level: ${Game.ME.level.getLevelNumber()}';
		
		scoreText = new h2d.Text(Assets.fontPixel, flow);
		scoreText.text = 'Moves: ${Std.int(Game.ME.level.currentScore)}';
		
		flow.addSpacing(10);

		previousScoreText = new h2d.Text(Assets.fontPixel, flow);
		if (Const.GET_HIGHSCORE_ON_LEVEL(Game.ME.level.getLevelNumber()) > Game.ME.level.currentScore)
			previousScoreText.text = 'Current highscore: ${Const.GET_HIGHSCORE_ON_LEVEL(Game.ME.level.getLevelNumber())}';
		else
			previousScoreText.text = 'New level highscore!';
		previousScoreText.alpha = 0;
		
		totalScoreText = new h2d.Text(Assets.fontPixel, flow);
		totalScoreText.text = 'Total Moves: ${Std.int(Game.ME.score)}';
		totalScoreText.scale(Const.SCALE);

		flow.addSpacing(20);

        /* var nextLevelBtn = new ButtonMenu("Next Level", function() {
			this.destroy();
			Game.ME.goToNextLevel();
		}); */
		nextLevelBtn = new ButtonMenu("Next Level", onClickBtn);
		flow.addChild(nextLevelBtn);

		Const.PLAYER_DATA.scores[Game.ME.level.getLevelNumber()] = Std.int(Game.ME.level.currentScore);
		Const.SAVE_PROGRESS();

		onResize();

		levelText.x -= w()/Const.SCALE;
		scoreText.x -= w()/Const.SCALE;
		totalScoreText.x -= w()/Const.SCALE;
		nextLevelBtn.y += h()/Const.SCALE;

		cinematic.create({
			250;
			tw.createS(endLevelText.alpha, 1, 0.5).end(()->cinematic.signal());
			end;
			tw.createS(levelText.x, levelText.x+(w()/Const.SCALE), 0.2).end(()->cinematic.signal());
			end;
			tw.createS(scoreText.x, scoreText.x+(w()/Const.SCALE), 0.2).end(()->cinematic.signal());
			end;
			400;
			tw.createS(previousScoreText.alpha, 1, 0.4).end(()->cinematic.signal());
			end;
			200;
			tw.createS(totalScoreText.x, totalScoreText.x+(w()/Const.SCALE), 0.2).end(()->cinematic.signal());
			end;
			tw.createS(nextLevelBtn.y, nextLevelBtn.y-(h()/Const.SCALE), 0.5);
		});
	}

	public function onClickBtn() {
		cinematic.create({
			tw.createS(endLevelText.x, endLevelText.x+(w()/Const.SCALE), 0.3);
			tw.createS(levelText.x, levelText.x+(w()/Const.SCALE), 0.3);
			tw.createS(scoreText.x, scoreText.x+(w()/Const.SCALE), 0.3);
			tw.createS(previousScoreText.x, previousScoreText.x+(w()/Const.SCALE), 0.3);
			tw.createS(totalScoreText.x, totalScoreText.x+(w()/Const.SCALE), 0.3);
			tw.createS(nextLevelBtn.y, nextLevelBtn.y+(h()/Const.SCALE), 0.5).end(()->cinematic.signal());
			end;
			this.destroy();
			Game.ME.goToNextLevel();
		});
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

	override function update() {
		super.update();

		cinematic.update(tmod);
	}
}