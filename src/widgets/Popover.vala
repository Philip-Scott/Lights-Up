/*
 *  Copyright (C) 2019 Felipe Escoto <felescoto95@hotmail.com>
 *
 *  This program or library is free software; you can redistribute it
 *  and/or modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General
 *  Public License along with this library; if not, write to the
 *  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301 USA.
 */

public class LightsUp.Widgets.Popover : Gtk.Popover {
    public LightsUp.Model.Light light { get; construct set; }
    public LightsUp.Model.Room room { get; construct set; }

    private Gtk.Scale brightness;
    private Gtk.Scale temp_scale;
    private Gtk.Separator temp_separator;
    private Gtk.Label temp_label;
    private Gtk.Label brightness_label;

    public Popover.for_light (LightsUp.Model.Light light) {
        Object (light: light);
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

        temp_separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

        brightness_label = new Gtk.Label (_("Brightness"));
        brightness_label.get_style_context ().add_class ("h4");
        brightness_label.halign = Gtk.Align.START;

        if (light != null) {
            brightness = new LightsUp.Widgets.Scale.light_brightness (light);

            if (light.state.colormode == "ct") {
                temp_scale = new LightsUp.Widgets.Scale.light_temp (light);
                temp_scale.margin_bottom = 6;

                grid.add (temp_label);
                grid.add (temp_scale);
                grid.add (temp_separator);
            }
        } else {
            brightness = new LightsUp.Widgets.Scale.room_brightness (room);

            if (room.action.colormode == "ct") {
                temp_scale = new LightsUp.Widgets.Scale.room_temp (room);
                temp_scale.margin_bottom = 6;

                grid.add (temp_label);
                grid.add (temp_scale);
                grid.add (temp_separator);
            }
        }

        grid.add (brightness_label);
        grid.add (brightness);

        add (grid);

        hide.connect (() => {
            destroy ();
        });
    }
}