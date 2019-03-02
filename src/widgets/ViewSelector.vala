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

public class LightsUp.Widget.ViewSelector : Gtk.Grid {
    public signal void view_requested (string view);

    public ViewSelector () {

    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        row_spacing = 8;

        //  build_button ("non-starred-symbolic", "groups");
        build_button ("emblem-shared-symbolic", "groups");
        build_button ("preferences-system-power-symbolic", "lights");
    }

    private void build_button (string icon, string view) {
        var button = new Gtk.Button.from_icon_name (icon, Gtk.IconSize.DIALOG);
        button.get_style_context ().add_class ("flat");

        button.clicked.connect (() => {
            view_requested (view);
        });

        add (button);
    }
}