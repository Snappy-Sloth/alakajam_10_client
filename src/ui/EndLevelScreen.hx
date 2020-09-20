package ui;

class EndLevelScreen extends dn.Process {

	public static var ME : EndLevelScreen;

    var flow : h2d.Flow;

    var arLife : Array<h2d.Graphics>;

	public function new() {
		super(Game.ME);

		createRoot();

		ME = this;

		arLife = [];

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
		var idLevel = Std.string(Game.ME.level.lvlData.id);
		var splitId = idLevel.split("_");
		var numLevel = splitId[1];
		levelText.text = 'Level: ${numLevel}';
		
		var levelTimeText = new h2d.Text(Assets.fontPixel, flowInfo1);
		levelTimeText.text = 'Level Time: ${Lib.prettyTime(Game.ME.level.ftime)}';
		

		var flowInfo2 = new h2d.Flow(flow);
		flowInfo2.layout = Horizontal;
		flowInfo2.horizontalSpacing = 40;
		
		var scoreText = new h2d.Text(Assets.fontPixel, flowInfo2);
		scoreText.text = 'Score: ${Std.int(Game.ME.level.currentScore)}';
		
		var flowLife = new h2d.Flow(flowInfo2);
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
		scoreText.text = 'Score Maximum: ${Std.int(Game.ME.score)}';
			

		var gameTimeText = new h2d.Text(Assets.fontPixel, flow);
		gameTimeText.text = 'Total Campaign Time: à définir';

		flow.addSpacing(20);

        var nextLevelBtn = new Button("Next Level", function() {
			this.destroy();
			Game.ME.goToNextLevel();
		});
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