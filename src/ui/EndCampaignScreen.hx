package ui;

class EndCampaignScreen extends dn.Process {

	public static var ME : EndCampaignScreen;

    var flow : h2d.Flow;

	public function new() {
		super(Main.ME);

		createRoot();

		ME = this;

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.verticalSpacing = 20;
		flow.horizontalAlign = Middle;
        
        var congratsText = new h2d.Text(Assets.fontPixel, flow);
		congratsText.text = 'Congratulations!';
		congratsText.setScale(Const.SCALE);

		var endCampaignText = new h2d.Text(Assets.fontPixel, flow);
		endCampaignText.text = 'You finished the Campaign!';
		endCampaignText.setScale(Const.SCALE);

		flow.addSpacing(20);
		
		var scoreText = new h2d.Text(Assets.fontPixel, flow);
		scoreText.text = 'Total Moves: ${Std.int(Game.ME.score)}';			

		flow.addSpacing(20);

        var menuBtn = new ButtonMenu("Menu", Main.ME.startTitleScreen);
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