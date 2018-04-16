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
* Free Software Foundation, Inc., 59 Temple Place - Suite 330,
* Boston, MA 02111-1307, USA.
*
* Authored by: Felipe Escoto <felescoto95@hotmail.com>
*/

public class LightsUp.Utils {

    public static void set_style (Gtk.Widget widget, string css) {
        try {
            var provider = new Gtk.CssProvider ();
            var context = widget.get_style_context ();

            provider.load_from_data (css, css.length);

            context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (Error e) {
            warning ("Style error: %s", e.message);
            warning ("%s %s", widget.name, css);
        }
    }

    public static void visible (Gtk.Widget widget, bool value) {
        widget.visible = value;
        widget.no_show_all = !value;
    }

    public static string ct_to_css (double color_temperature, double brightness) {
        double percent = (color_temperature - 153.0) / (454.0 - 153.0);

        Gdk.RGBA color1, color2;
        if (percent < 0.5) {
            percent = percent * 2.0;

            color1 = { 135.0 / 255.0, 183.0 / 255.0, 255.0 / 255.0, 1.0 }; // blue
            color2 = { 237.0 / 255.0, 203.0 / 255.0, 175.0 / 255.0, 1.0 }; // light orange
        } else {
            percent = (percent - 0.5) * 2.0;

            color1 = { 237.0 / 255.0, 181.0 / 255.0, 135.0 / 255.0, 1.0 }; // light orange
            color2 = { 249.0 / 255.0, 87.0  / 255.0, 87.0  / 255.0, 1.0 }; // light red
        }

        Gdk.RGBA final_color = {
            (color1.red * (1.0 - percent) + color2.red * percent),
            (color1.green * (1.0 - percent) + color2.green * percent),
            (color1.blue * (1.0 - percent) + color2.blue * percent),
            (brightness / 255.0).clamp (0.3, 1.0)
        };

        return final_color.to_string ();
    }
}