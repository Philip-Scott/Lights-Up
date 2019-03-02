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

public class LightsUp.Views.LightsView : Gtk.ScrolledWindow {

    public LightsView () {
        Object (hscrollbar_policy: Gtk.PolicyType.NEVER);
    }

    construct {
        expand = true;

        get_style_context ().add_class ("view");

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;

        var lights_api = Api.Lights.get_instance ();
        var lights = lights_api.lights;

        foreach (var light in lights.values) {
            grid.add (new LightsUp.Widgets.LightWidget (light));
        };

        show_all ();
        add (grid);
    }
}