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

public class LightsUp.Widgets.LightWidget : Gtk.Grid {

    public LightsUp.Model.Light light { get; construct set; }

    private Gtk.Scale brightness;
    private Gtk.Scale temp_scale;

    public bool active {
        set {
            if (temp_scale != null) {
                temp_scale.sensitive = value;
            }

            brightness.sensitive = value;
        }
    }

    public LightWidget (LightsUp.Model.Light light) {
        Object (light: light);
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        margin = 6;

        var label = new Gtk.Label (light.name);
        label.get_style_context ().add_class ("h4");
        label.halign = Gtk.Align.START;

        add (label);

        if (light.color_mode == "ct") {
            temp_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 454, 10);
            temp_scale.draw_value = false;
            temp_scale.has_origin = false;
            temp_scale.hexpand = true;
            temp_scale.inverted = true;
            temp_scale.width_request = 200;
            temp_scale.get_style_context ().add_class ("temperature");

            add (temp_scale);

            temp_scale.set_value (454 - light.color_temperature);
            temp_scale.value_changed.connect (() => {
                light.color_temperature = 454 - (int) temp_scale.get_value ();
            });
        }

        brightness = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 255, 10);
        brightness.draw_value = false;
        brightness.has_origin = false;
        brightness.hexpand = true;
        brightness.inverted = true;
        brightness.width_request = 200;
        brightness.get_style_context ().add_class ("color");

        add (brightness);

        brightness.set_value (255 - light.brightness);
        brightness.value_changed.connect (() => {
            light.brightness = 255 - (int) brightness.get_value ();
        });

        active = light.reachable && light.on;

        add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        show_all ();
    }
}