module noro.app;

import std.stdio;
import noro.types;
import noro.uiManager;
import noro.ui.window;
import noro.terminal.screen;
import noro.terminal.input;

enum AppStatus {
	Standby,
	Command,
	Window
}

class App {
	bool      running;
	Screen    screen;
	UIManager ui;
	AppStatus status;

	this() {
		running = true;
		screen  = new Screen();
		ui      = new UIManager();

		auto window = new UIWindow(100, 30);
		window.pos  = Vec2!ushort(5, 5);
		window.name = "Window!!";
		ui.Add(window);

		status = AppStatus.Standby;
	}

	static App Instance() {
		App app;

		if (!app) {
			app = new App();
		}

		return app;
	}

	void Update() {
		// update
		ui.Update();
		
		auto buffer = screen.buffer;
		buffer.SetBGColour(Colour16.Blue);
		buffer.Clear(' ');

		// render top bar
		buffer.SetBGColour(Colour16.White);
		buffer.SetFGColour(Colour16.Black);
		buffer.HLine(0, 0, buffer.GetSize().x, ' ');
		buffer.caret = Vec2!ushort(0, 0);
		buffer.Printf("noro - %s", status);

		// render UI
		ui.Render(buffer);

		ui.SetCaret(buffer);
		screen.Render();

		auto input = GetKey();

		if ((input.mod == KeyMod.Ctrl) && (input.key == 'q')) {
			running = false;
			return;
		}
		
		final switch (status) {
			case AppStatus.Standby: {
				if ((input.mod == KeyMod.Ctrl) && (input.key == 'k')) {
					status = AppStatus.Command;
				}
				else {
					ui.Input(input);
				}

				break;
			}
			case AppStatus.Command: {
				switch (input.key) {
					case 'm': {
						status = AppStatus.Window;
						break;
					}
					case 'f': {
						ui.Top().pos = Vec2!ushort(0, 1);
						ui.Top().Resize(
							buffer.GetSize().x, cast(ushort) (buffer.GetSize().y - 1)
						);
						break;
					}
					case 'F': {
						ui.Top().pos = Vec2!ushort(0, 0);
						ui.Top.Resize(buffer.GetSize().x, buffer.GetSize().y);
						break;
					}
					default: {
						status = AppStatus.Standby;
						break; // TODO: error
					}
				}

				break;
			}
			case AppStatus.Window: {
				switch (input.key) {
					case 'q': {
						status = AppStatus.Standby;
						break;
					}
					case Key.Up: {
						if (input.mod & KeyMod.Shift) {
							-- ui.Top().pos.y;
						}
						else {
							ui.Top().pos.y -= 4;
						}
						break;
					}
					case Key.Down: {
						if (input.mod & KeyMod.Shift) {
							++ ui.Top().pos.y;
						}
						else {
							ui.Top().pos.y += 4;
						}
						break;
					}
					case Key.Left: {
						if (input.mod & KeyMod.Shift) {
							-- ui.Top().pos.x;
						}
						else {
							ui.Top().pos.x -= 4;
						}
						break;
					}
					case Key.Right: {
						if (input.mod & KeyMod.Shift) {
							++ ui.Top().pos.x;
						}
						else {
							ui.Top().pos.x += 4;
						}
						break;
					}
					case 'w': {
						auto size = ui.Top().GetSize();
						size.y -= 4;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 'a': {
						auto size = ui.Top().GetSize();
						size.x -= 4;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 's': {
						auto size = ui.Top().GetSize();
						size.y += 4;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 'd': {
						auto size = ui.Top().GetSize();
						size.x += 4;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 'W': {
						auto size = ui.Top().GetSize();
						-- size.y;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 'A': {
						auto size = ui.Top().GetSize();
						-- size.x;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 'S': {
						auto size = ui.Top().GetSize();
						++ size.y;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 'D': {
						auto size = ui.Top().GetSize();
						++ size.x;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					default: break; // TODO: error
				}

				break;
			}
		}
	}
}

void main() {
	auto app = App.Instance();

	while (app.running) {
		app.Update();
	}
}
