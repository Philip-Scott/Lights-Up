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

public class LightsUp.Widgets.Scale : Gtk.Scale {

    public Scale.room_temp (LightsUp.Model.Room room) {
        set_range (153, 454);

        get_style_context ().add_class ("temperature");
        set_value (room.color_temperature);
        value_changed.connect (() => {
            room.color_temperature = (int) get_value ();
        });
    }

    public Scale.light_temp (LightsUp.Model.Light light) {
        set_range (153, 454);

        get_style_context ().add_class ("temperature");
        set_value (light.color_temperature);
        value_changed.connect (() => {
            light.color_temperature = (int) get_value ();
        });
    }

    public Scale.room_brightness (LightsUp.Model.Room room) {
        set_range (0, 255);

        set_value (room.brightness);
        value_changed.connect (() => {
            room.brightness = (int) get_value ();
        });
    }

    public Scale.light_brightness (LightsUp.Model.Light light) {
        set_range (0, 255);

        set_value (light.brightness);
        value_changed.connect (() => {
            light.brightness = (int) get_value ();
        });
    }

    construct {
        orientation = Gtk.Orientation.HORIZONTAL;
        set_increments (10, 10);
        width_request = 200;
        draw_value = false;
        has_origin = false;
        hexpand = true;
    }
}