from enum import Enum

from textual.app import App, ComposeResult
from textual.containers import CenterMiddle, Container
from textual.screen import Screen
from textual.widgets import Button, Header

class State(Enum):
    MAIN_MENU = 0,
    CREATE_USER = 1,

class MainMenu(Screen):
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")
        yield Button(label = "New Archive", id = "new_archive")
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "new_archive":
            app.set_state(State.CREATE_USER)
            app.install_screen(CreateUserMenu(), name = "Create User Menu")
            app.switch_screen("Create User Menu")

class CreateUserMenu(Screen):

    class SideBar(Container):
        def compose(self) -> ComposeResult:
            yield Button(label = "Set Name", id = "name")
            yield Button(label = "Set Email", id = "email")
            yield Button(label = "Create", id = "create")
    
    def __init__(self):
        super().__init__()
        self.side_bar = self.SideBar()

    
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")
        yield self.side_bar

class ArchiveGeneratorApp(App):

    def __init__(self):
        super().__init__()
        self.state = State.MAIN_MENU

    BINDINGS = [("d", "toggle_dark", "Toggle dark mode")]        

    def action_toggle_dark(self) -> None:
        """An action to toggle dark mode."""
        self.theme = (
            "textual-dark" if self.theme == "textual-light" else "textual-light"
        )
    
    def set_state(self, new_state: State) -> None:
        self.state = new_state
    
    def on_mount(self) -> None:
        self.install_screen(MainMenu(), name = "Main Menu")
        self.push_screen("Main Menu")

if __name__ == '__main__':
    app = ArchiveGeneratorApp()
    app.run()