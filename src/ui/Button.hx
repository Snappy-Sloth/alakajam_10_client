package ui;

import h2d.Graphics;

class Button extends h2d.Layers {

	public function new(str:String, onClick:Void->Void) {
		super();

		var button = new Graphics(this);
		button.beginFill(0xFF888888);
		button.drawRect(0, 0, Const.BUTTON_WIDTH, Const.BUTTON_HEIGHT);

		var inter = new h2d.Interactive(Const.BUTTON_WIDTH, Const.BUTTON_HEIGHT, this);
		//inter.backgroundColor = 0xFF888888;
		inter.onClick = (e)->onClick();

		var text = new h2d.Text(Assets.fontPixel, this);
		text.text = str;
		text.setPosition(((Const.BUTTON_WIDTH/2)-(text.textWidth/2)), ((Const.BUTTON_HEIGHT/2)-(text.textHeight/2)));
    }
}