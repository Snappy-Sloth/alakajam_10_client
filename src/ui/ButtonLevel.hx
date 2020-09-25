package ui;

class ButtonLevel extends Button {

    public function new(str:String, onClick:Void->Void) {
		super(60, 25, "levelButton", str, onClick);
    }
}