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

public class LightsUp.Widgets.RoomWidget : Gtk.Grid {
    public string id {
        get {
            return room.id;
        }
    }

    public LightsUp.Model.Room room { get; construct set; }

    private Gee.LinkedList<LightsUp.Model.Light> lights;

    private Gtk.Stack reachable_stack;

    private Gtk.Scale brightness;
    private Gtk.Grid childs;
    private Gtk.Image image;
    private Gtk.Switch light_switch;

    public bool active {
        set {
            brightness.sensitive = value;
        }
    }

    public bool any_reachable {
        set {
            if (value) {
                reachable_stack.set_visible_child_name ("brightness");
            } else {
                reachable_stack.set_visible_child_name ("non_reachable");
            }

            light_switch.sensitive = value;
        }
    }

    public RoomWidget (LightsUp.Model.Room room, Gee.HashMap<string, LightsUp.Model.Light> _lights) {
        Object (room: room);

        var light_ids = room.get_lights ();
        this.lights = new Gee.LinkedList<LightsUp.Model.Light> ();

        bool any_reach = false;
        foreach (var id in light_ids) {
            var light = _lights.get (id);
            childs.add (new LightsUp.Widgets.LightWidget (light));
            this.lights.add (light);

            if (light.reachable) {
                any_reach = true;
            }
        }

        any_reachable = any_reach;
        set_color ();
    }

    construct {
        column_spacing = 6;
        margin = 6;

        var label = new Gtk.Label (room.name);
        label.get_style_context ().add_class ("h3");
        label.get_style_context ().add_class ("h4");
        label.halign = Gtk.Align.START;

        brightness = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 255, 10);
        brightness.draw_value = false;
        brightness.has_origin = false;
        brightness.hexpand = true;
        brightness.inverted = true;
        brightness.width_request = 200;
        brightness.get_style_context ().add_class ("color");

        brightness.set_value (255 - room.brightness);
        brightness.value_changed.connect (() => {
            room.brightness = 255 - (int) brightness.get_value ();
        });

        light_switch = new Gtk.Switch ();
        light_switch.set_active (room.on);
        light_switch.valign = Gtk.Align.CENTER;

        light_switch.state_set.connect ((state) => {
            room.on = state;
            active =  state;
        });

        active = room.on;

        image = new Gtk.Image.from_icon_name ("room-icon-symbolic", Gtk.IconSize.DIALOG);
        image.get_style_context ().add_class ("room-icon");

        childs = new Gtk.Grid ();
        childs.orientation = Gtk.Orientation.VERTICAL;

        var no_lights_label = new Gtk.Label ("<small>Unreachable</small>");
        no_lights_label.halign = Gtk.Align.START;
        no_lights_label.use_markup = true;
        no_lights_label.sensitive = false;

        reachable_stack = new Gtk.Stack ();
        reachable_stack.add_named (brightness, "brightness");
        reachable_stack.add_named (no_lights_label, "non_reachable");

        attach (image, 0, 0, 1, 2);
        attach (label, 1, 0, 1, 1);
        attach (reachable_stack, 1, 1, 1, 1);
        attach (light_switch, 2, 0, 1, 2);
        attach (childs, 0, 2, 3, 1);

        show_all ();
    }

    private void set_color () {
        string color = "#aaa";
        // TODO: Make gradient if more than one color
        foreach (var light in lights) {
            color = light.get_css_color ();
        }

        var CSS = ".room-icon {color: %s; }";
        LightsUp.Utils.set_style (image, CSS.printf (color));
    }
}