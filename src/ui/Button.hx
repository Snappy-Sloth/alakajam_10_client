package ui;

class Button extends h2d.Layers {

	public function new(wid:Int, hei:Int, str:String, onClick:Void->Void) {
		super();

		// var button = new Graphics(this);
		// button.beginFill(0xFF888888);
		// button.drawRect(0, 0, Const.BUTTON_WIDTH, Const.BUTTON_HEIGHT);

		//Assets.tiles.h_get("button", this);

		var inter = new h2d.Interactive(wid, hei);
		inter.backgroundColor = 0xFF888888;
		inter.onClick = (e)->onClick();
		this.add(inter, 0);

		var text = new h2d.Text(Assets.fontPixel);
		text.text = str;
		text.setPosition(((wid/2)-(text.textWidth/2)), ((hei/2)-(text.textHeight/2)));
		this.add(text, 2);
    }
}