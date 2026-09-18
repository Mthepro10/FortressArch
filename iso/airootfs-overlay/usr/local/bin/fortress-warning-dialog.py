import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk, GLib
import subprocess
import os

COUNTDOWN_SECONDS = 300
PROMPT_FLAG = "/var/lib/fortress-arch/survival-prompt-needed"


def enter_survival_mode():
    subprocess.run(["sudo", "/usr/local/bin/fortress-survival-mode.sh"])
    clear_flag()


def clear_flag():
    if os.path.exists(PROMPT_FLAG):
        os.remove(PROMPT_FLAG)


class WarningWindow(Gtk.ApplicationWindow):
    def __init__(self, application):
        super().__init__(application=application, title="FortressArch Warning")
        self.set_default_size(420, 200)
        self.remaining = COUNTDOWN_SECONDS

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        box.set_margin_top(20)
        box.set_margin_bottom(20)
        box.set_margin_start(20)
        box.set_margin_end(20)

        title = Gtk.Label(label="System integrity issue detected")
        box.append(title)

        self.status_label = Gtk.Label(label=self.status_text())
        box.append(self.status_label)

        button_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)

        confirm_button = Gtk.Button(label="Enter Survival Mode Now")
        confirm_button.connect("clicked", self.on_confirm)
        button_box.append(confirm_button)

        cancel_button = Gtk.Button(label="Cancel")
        cancel_button.connect("clicked", self.on_cancel)
        button_box.append(cancel_button)

        box.append(button_box)
        self.set_child(box)

        GLib.timeout_add_seconds(1, self.on_tick)

    def status_text(self):
        return f"Entering survival mode automatically in {self.remaining} seconds"

    def on_tick(self):
        self.remaining -= 1
        self.status_label.set_text(self.status_text())
        if self.remaining <= 0:
            enter_survival_mode()
            self.get_application().quit()
            return False
        return True

    def on_confirm(self, _button):
        enter_survival_mode()
        self.get_application().quit()

    def on_cancel(self, _button):
        clear_flag()
        self.get_application().quit()


def on_activate(application):
    window = WarningWindow(application)
    window.present()


app = Gtk.Application(application_id="org.fortressarch.warningdialog")
app.connect("activate", on_activate)
app.run(None)
