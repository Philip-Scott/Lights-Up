/*
* Copyright (c) 2017
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

public class LightsUp.Window : Gtk.ApplicationWindow {
    private Granite.Widgets.AlertView? error = null;

    private Gtk.Stack main_stack;
    private GLib.Settings settings;

    public Window (Gtk.Application app) {
        Object (
            application: app,
            icon_name: LightsUp.Application.APP_ID,
            title: "Lights-Up"
        );
    }

    construct {
        settings = new GLib.Settings (LightsUp.Application.APP_ID);
        int x = settings.get_int ("window-x");
        int y = settings.get_int ("window-y");

        if (x != -1 && y != -1) {
            move (x, y);
        }

        main_stack = new Gtk.Stack ();
        main_stack.homogeneous = false;
        add (main_stack);

        if (settings.get_string ("user") == "" || settings.get_string ("host") == "") {
            show_login ();
        } else {
            show_app ();
        }
    }

    private void show_login () {
        var grid = new Gtk.Grid ();
        grid.get_style_context ().add_class ("view");
        grid.orientation = Gtk.Orientation.VERTICAL;

        var alert = new Granite.Widgets.AlertView (_("Paring with Hue…"), _("Enter the Bridge IP and press the Center Button in your Hue Bridge"), Application.APP_ID);
        alert.valign = Gtk.Align.END;

        var entry = new Gtk.Entry ();
        entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "dialog-information-symbolic");
        entry.set_icon_tooltip_text (Gtk.EntryIconPosition.SECONDARY, _("To find the bridge IP, open the official app:\nSettings → Hue Bridges → Your Bridge"));
        entry.get_style_context ().add_class ("error");
        entry.placeholder_text = "192.168.1.10";
        entry.expand = true;
        entry.halign = Gtk.Align.CENTER;
        entry.valign = Gtk.Align.START;

        settings.bind ("host", entry, "text", SettingsBindFlags.SET);

        grid.add (alert);
        grid.add (entry);

        main_stack.add_named (grid, "pair");
        main_stack.set_visible_child_full ("pair", Gtk.StackTransitionType.OVER_DOWN);

        var endpoint = LightsUp.Api.Endpoint.get_instance ();

        endpoint.logged_in.connect (show_app);
        endpoint.bridge_found.connect ((value) => {
            if (value) {
                entry.get_style_context ().remove_class ("error");
                alert.description = _("Press the Center Button in your Hue Bridge");
            } else {
                entry.get_style_context ().add_class ("error");
                alert.description = _("Enter the Bridge IP and press the Center Button in your Hue Bridge");
            }
        });

        endpoint.start_login ();
        show_all ();
    }

    private void show_error (string title, string description) {
        if (error == null) {
            error = new Granite.Widgets.AlertView (title, description, Application.APP_ID);
            main_stack.add_named (error, "error");
        }

        main_stack.set_visible_child_full ("error", Gtk.StackTransitionType.OVER_DOWN);
        show_all ();
    }

    private void show_app () {
        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;

        var endpoint = LightsUp.Api.Endpoint.get_instance ();
        endpoint.bridge_found.connect ((value) => {
            if (!value) {
                show_error (_("Hue Bridge not found"), _("Make sure you're connected to your network"));
                error.show_action (_("Forget Bridge"));
                error.action_activated.connect (() => {
                    settings.set_string ("host", "");
                    settings.set_string ("user", "");
                    this.destroy ();
                });
            }
        });

        var lights = Api.Lights.get_instance ().get_lights ();

        if (lights.size < 0) {
            show_error (_("No lights found"), _("Setup your lights from the official app"));
            return;
        }

        var rooms = Api.Rooms.get_instance ().get_rooms ();

        bool found = false;
        foreach (var room in rooms.values) {
            grid.add (new LightsUp.Widgets.RoomWidget (room, lights));
            found = true;
        };

        if (!found) return;

        main_stack.add_named (grid, "main");
        show_all ();

        main_stack.set_visible_child_full ("main", Gtk.StackTransitionType.OVER_DOWN);
    }
}
