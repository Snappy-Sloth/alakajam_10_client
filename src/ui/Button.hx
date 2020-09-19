package ui;

class Button extends h2d.Layers {

	public function new(str:String, onClick:Void->Void) {
		super();

		var inter = new h2d.Interactive(100, 50, this);
		inter.backgroundColor = 0xFF888888;
		inter.onClick = (e)->onClick();

		var text = new h2d.Text(Assets.fontPixel, this);
		text.text = str;
    }
}