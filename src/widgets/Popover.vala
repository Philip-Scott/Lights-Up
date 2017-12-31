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

public class LightsUp.Widgets.Popover : Gtk.Popover {
    public LightsUp.Model.Light light { get; set; }
    public LightsUp.Model.Room room { get; set; }

    private Gtk.Scale brightness;
    private Gtk.Scale temp_scale;
    private Gtk.Separator temp_separator;
    private Gtk.Label temp_label;
    private Gtk.Label brightness_label;

    public Popover.for_light (LightsUp.Model.Light light) {
        Object (light: light);

        if (light.color_mode == "ct") {
            temp_scale.set_value (454 - light.color_temperature);
            temp_scale.value_changed.connect (() => {
                light.color_temperature = 454 - (int) temp_scale.get_value ();
            });
        } else {
            LightsUp.Utils.visible (temp_scale, false);
            LightsUp.Utils.visible (temp_label, false);
            LightsUp.Utils.visible (temp_separator, false);
        }

        brightness.set_value (255 - light.brightness);
        brightness.value_changed.connect (() => {
            light.brightness = 255 - (int) brightness.get_value ();
        });
    }

    public Popover.for_room (LightsUp.Model.Room room) {
        Object (room: room);
    }

    construct {
        position = Gtk.PositionType.RIGHT;

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;
        grid.margin = 6;

        temp_label = new Gtk.Label (_("Temperature"));
        temp_label.get_style_context ().add_class ("h4");
        temp_label.halign = Gtk.Align.START;

        temp_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 454, 10);
        temp_scale.draw_value = false;
        temp_scale.has_origin = false;
        temp_scale.hexpand = true;
        temp_scale.inverted = true;
        temp_scale.width_request = 200;
        temp_scale.get_style_context ().add_class ("temperature");
        temp_scale.margin_bottom = 6;

        temp_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

        brightness_label = new Gtk.Label (_("Brightness"));
        brightness_label.get_style_context ().add_class ("h4");
        brightness_label.halign = Gtk.Align.START;

        brightness = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 255, 10);
        brightness.draw_value = false;
        brightness.has_origin = false;
        brightness.hexpand = true;
        brightness.inverted = true;
        brightness.width_request = 200;
        brightness.get_style_context ().add_class ("color");

        grid.add (temp_label);
        grid.add (temp_scale);
        grid.add (temp_separator);
        grid.add (brightness_label);
        grid.add (brightness);

        add (grid);
    }
}