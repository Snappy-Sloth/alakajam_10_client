package ui;

class ButtonLevel extends Button {

    public function new(str:String, onClick:Void->Void) {
		super("levelButton", str, onClick);
    }
}