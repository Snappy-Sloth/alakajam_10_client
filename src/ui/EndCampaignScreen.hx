package ui;

class EndCampaignScreen extends dn.Process {

	public static var ME : EndCampaignScreen;

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
		flow.horizontalAlign = Middle;
        
        var endCampaignText = new h2d.Text(Assets.fontPixel, flow);
		endCampaignText.text = 'Congratulations!';
		endCampaignText.setScale(Const.SCALE);

		flow.addSpacing(20);
		
		var scoreText = new h2d.Text(Assets.fontPixel, flow);
		scoreText.text = 'Score: ${Game.ME.score}';			

		var gameTimeText = new h2d.Text(Assets.fontPixel, flow);
		gameTimeText.text = 'Total Campaign Time: à définir';

		flow.addSpacing(20);

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