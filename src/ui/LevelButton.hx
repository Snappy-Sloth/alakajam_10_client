package ui;

class LevelButton extends Button {

    public function new(str:String, onClick:Void->Void) {
		super("levelButton", str, onClick);
    }
}