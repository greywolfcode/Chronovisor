from enum import Enum

from textual.app import App, ComposeResult
from textual.containers import CenterMiddle, Container, Horizontal, Vertical
from textual.screen import ModalScreen, Screen
from textual.widgets import Button, ContentSwitcher, Footer, Header, Input, Label

from scripts.id_handeler import IdType

from scripts.archive_handeling import Archive, Message

data = {
    "spaces": {},
    "groups": {}
}

class State(Enum):
    MAIN_MENU = 0,
    CREATE_USER = 1,
    HUB = 2,
    CREATE_DM = 3,

class MainMenu(Screen):
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")
        yield CenterMiddle(Button(label = "New Archive", id = "new_archive"))
        yield Footer()    
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "new_archive":
            app.set_state(State.CREATE_USER)
            app.install_screen(CreateUserMenu(), name = "Create User Menu")
            app.switch_screen("Create User Menu")

class CreateUserMenu(Horizontal, Screen):

    CSS_PATH = "styles/create_user_menu.tcss"

    class CreateState(Enum):
        NAME = 0,
        EMAIL = 1,

    class SideBar(Container):

        id = "sidebar"

        def __init__(self, bar_parent: Screen):
            super().__init__()
            self._parent = bar_parent

        def compose(self) -> ComposeResult:
            yield Button(label = "Set Name", id = "name")
            yield Button(label = "Set Email", id = "email")
            yield Button(label = "Create", id = "create")
        
        def on_button_pressed(self, event: Button.Pressed) -> None:
            if event.button.id == "name":
                self._parent.set_state(self._parent.CreateState.NAME)
            elif event.button.id == "email":
                self._parent.set_state(self._parent.CreateState.EMAIL)
            elif event.button.id == "create":
                app.set_state(State.HUB)
                app.install_screen(HubMenu(), name = "Hub Menu")
                app.switch_screen("Hub Menu")

    
    def __init__(self):
        super().__init__()
        self.state = self.CreateState.NAME
        self.side_bar = self.SideBar(self)

        self._name = "Temp Temp"
        self._email = "Temp@temp.temp"
    
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")

        yield self.side_bar

        with ContentSwitcher(initial="name", id="label_switcher"):
            yield Label("Name:", id="name")
            yield Label("Email:", id="email")

        with ContentSwitcher(initial="name", id="input_switcher"):
            yield Input(placeholder=self._name, id="name")
            yield Input(placeholder=self._email, id="email")
        
        yield Footer()

    def on_input_changed(self, event: Input.Changed):
        if (event.input.id == "name"):
            self._name = event.input.value
        else:
            self._email = event.input.value

    def set_state(self, new_state: CreateState):
        self.state = new_state
        if (self.state == self.CreateState.NAME):
            self.query_one("#label_switcher", ContentSwitcher).current = "name"
            self.query_one("#input_switcher", ContentSwitcher).current = "name"
        else:
            self.query_one("#label_switcher", ContentSwitcher).current = "email"
            self.query_one("#input_switcher", ContentSwitcher).current = "email"

class HubMenu(Screen):

    CSS_PATH = "styles/hub_menu.tcss"

    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")

        yield Button(label = "New Space", id = "new_space")
        yield Button(label = "New DM", id = "new_dm")
        yield Button(label = "Export", id = "export")

        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "new_dm":
            app.set_state(State.CREATE_DM)
            app.install_screen(DMCreationMenu(), name = "DM Creation Menu")
            app.switch_screen("DM Creation Menu")

class DMCreationMenu(Screen):

    CSS_PATH = "styles/create_message_group_menus.tcss"

    class SideBar(Vertical):
        def compose(self) -> ComposeResult:
            yield Button(label = "Edit People", id = "edit_people")
            yield Button(label = "Add Message", id = "add_message")
            yield Button(label = "Finish", id = "finish")

    def __init__(self):
        super().__init__()
        self.uuid = IdType.gen_id(IdType.DM)
        self.sidebar = self.SideBar()

        data["spaces"][self.uuid] = Archive(self.uuid)
    
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")

        yield self.sidebar 

        yield Footer()

class SpaceCreationMenu(Screen):
    def __init__(self):
        super().__init__()
        self.uuid = IdType.gen_id(IdType.Space)

class LicenceScreen(ModalScreen):

    CSS_PATH = "styles\licence_screen.tcss"

    LICENCE_TEXT = """
    Chronovisor archive generator tool.
    Copyright (C) 2026  greywolfcode

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published byl
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA."""

    def compose(self) -> ComposeResult:
        yield Label(self.LICENCE_TEXT)
        yield Button(label = "Done", id = "done")
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "done":
            app.pop_screen()

class ArchiveGeneratorApp(App):

    def __init__(self):
        super().__init__()
        self.state = State.MAIN_MENU

    BINDINGS = [("d", "toggle_dark", "Toggle dark mode"), ("l", "show_licence", "Show Licence")]        

    def action_toggle_dark(self) -> None:
        """An action to toggle dark mode."""
        self.theme = (
            "textual-dark" if self.theme == "textual-light" else "textual-light"
        )
    
    def action_show_licence(self):
        self.push_screen(LicenceScreen())
    
    def set_state(self, new_state: State) -> None:
        self.state = new_state
    
    def on_mount(self) -> None:
        self.install_screen(MainMenu(), name = "Main Menu")
        self.push_screen("Main Menu")

if __name__ == '__main__':
    app = ArchiveGeneratorApp()
    app.run()