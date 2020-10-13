package ui;

class Button extends h2d.Layers {

	public var wid(default, null) : Int;
	public var hei(default, null) : Int;

	public function new(idSpr:String, str:String, onClick:Void->Void) {
		super();

		var spr = Assets.tiles.h_get(idSpr + "Idle");
		this.add(spr, 1);
		
		wid = Std.int(spr.tile.width);
		hei = Std.int(spr.tile.height);

		var inter = new h2d.Interactive(wid, hei);
		// inter.backgroundColor = 0xFF888888;
		inter.onClick = (e)->onClick();
		this.add(inter, 0);

		var text = new h2d.Text(Assets.fontOeuf13);
		text.text = str;
		text.textColor = 0xfffbc2;
		text.setPosition(((wid/2)-(text.textWidth/2)), (hei/2)-(text.textHeight/2));
		text.dropShadow = {dx: 0, dy: 1, alpha: 1, color: 0x845034};
		this.add(text, 2);

		inter.onRelease = inter.onOver = function (e) {
			text.y = (hei/2)-(text.textHeight/2);
			spr.set(idSpr + "Over");
			// midSpr.set("buttonOverMid");
			// rightSpr.set("buttonOverRight");
		}
		inter.onReleaseOutside = inter.onOut = function (e) {
			text.y = (hei/2)-(text.textHeight/2);
			spr.set(idSpr + "Idle");
			// midSpr.set("buttonIdleMid");
			// rightSpr.set("buttonIdleRight");
		}
		inter.onPush = function (e) {
			text.y = (hei/2)-(text.textHeight/2) + 3;
			spr.set(idSpr + "Press");
			// midSpr.set("buttonClickMid");
			// rightSpr.set("buttonClickRight");
		}

        // var button = Assets.tiles.h_get(idSpr);
        // this.add(button, 1);
    }
}