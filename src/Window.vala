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
        int w = settings.get_int ("window-w");
        int h = settings.get_int ("window-h");

        if (x != -1 && y != -1) {
            move (x, y);
        }

        resize (w, h);

        main_stack = new Gtk.Stack ();
        main_stack.homogeneous = false;
        add (main_stack);

        if (settings.get_string ("user") == "" || settings.get_string ("host") == "") {
            show_login ();
        } else {
            show_app ();
        }
    }

    protected override bool delete_event (Gdk.EventAny event) {
        int width, height, x, y;

        get_size (out width, out height);
        get_position (out x, out y);

        settings.set_int ("window-x", x);
        settings.set_int ("window-y", y);
        settings.set_int ("window-w", width);
        settings.set_int ("window-h", height);

        return false;
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

    public void show_app () {
        var app_stack = new Gtk.Stack ();
        app_stack.homogeneous = false;
        app_stack.expand = true;

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.HORIZONTAL;
        grid.expand = true;

        var view_selector = new LightsUp.Widget.ViewSelector ();
        view_selector.view_requested.connect ((view) => {
            app_stack.set_visible_child_full (view, Gtk.StackTransitionType.OVER_DOWN);
        });

        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        separator.vexpand = true;

        grid.add (view_selector);
        grid.add (separator);
        grid.add (app_stack);

        main_stack.add_named (grid, "main-view");

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

        var lights_api = Api.Lights.get_instance ();
        lights_api.lights_obtained.connect (() => {
            print ("Lights obtained signal\n");

            var lights = lights_api.lights;
            if (lights.size < 0) {
                show_error (_("No lights found"), _("Setup your lights from the official app"));
                return;
            }

            var groups_view = new LightsUp.Views.GroupsView ();
            app_stack.add_named (groups_view, "groups");
            app_stack.set_visible_child_full ("groups", Gtk.StackTransitionType.OVER_DOWN);

            var lights_view = new LightsUp.Views.LightsView ();
            app_stack.add_named (lights_view, "lights");
            app_stack.set_visible_child_full ("lights", Gtk.StackTransitionType.OVER_DOWN);

            main_stack.set_visible_child_full ("main-view", Gtk.StackTransitionType.OVER_DOWN);
            show_all ();
        });

        lights_api.get_lights ();
    }
}
