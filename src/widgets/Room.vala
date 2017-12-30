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
    private Gtk.Scale brightness;
    private Gtk.Grid childs;
    private Gtk.Image image;

    public bool active {
        set {
            brightness.sensitive = value;
        }
    }

    public RoomWidget (LightsUp.Model.Room room, Gee.HashMap<string, LightsUp.Model.Light> _lights) {
        Object (room: room);

        var light_ids = room.get_lights ();
        this.lights = new Gee.LinkedList<LightsUp.Model.Light> ();

        foreach (var id in light_ids) {
            childs.add (new LightsUp.Widgets.LightWidget (_lights.get (id)));
            this.lights.add (_lights.get (id));
        }

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

        var light_switch = new Gtk.Switch ();
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

        attach (image, 0, 0, 1, 2);
        attach (label, 1, 0, 1, 1);
        attach (brightness, 1, 1, 1, 1);
        attach (light_switch, 2, 0, 1, 2);
        attach (childs, 0, 2, 3, 1);

        show_all ();
    }

    private void set_color () {
        string color = "none";
        // TODO: Make gradient if more than one color
        foreach (var light in lights) {
            color = light.get_css_color ();
        }

        var CSS = ".room-icon {color: %s; }";
        LightsUp.Utils.set_style (image, CSS.printf (color));
    }
}