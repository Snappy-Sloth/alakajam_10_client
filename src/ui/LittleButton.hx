package ui;

class LittleButton extends Button {

    public function new(str:String, onClick:Void->Void) {
		super("littleButton", str, onClick);
    }
}