package ui;

class LooseLifeScreen extends dn.Process {

	public static var ME : LooseLifeScreen;

	var flow : h2d.Flow;

	public function new(lvlData:Data.Campaign) {
		super(Game.ME); 

		createRoot();

		ME = this;

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.verticalSpacing = 50;
		flow.horizontalAlign = Middle;
        
        var levelLostText = new h2d.Text(Assets.fontPixel, flow);
        levelLostText.text = 'LEVEL LOST';
        levelLostText.scale(2*Const.SCALE);
        
        var lifeLostText = new h2d.Text(Assets.fontPixel, flow);
        lifeLostText.text = 'You loose a life';
		lifeLostText.scale(Const.SCALE);
		
		var restartBtn = new Button("Menu", function() {
			Game.ME.restartLevel(lvlData);
			this.destroy();
		});
		flow.addChild(restartBtn);

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