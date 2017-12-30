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

    public Window (Gtk.Application app) {
        Object (
            application: app,
            icon_name: LightsUp.Application.APP_ID,
            title: "Lights-Up"
        );
    }

    construct {
        var settings = new GLib.Settings (LightsUp.Application.APP_ID);
        int x = settings.get_int ("window-x");
        int y = settings.get_int ("window-y");

        if (x != -1 && y != -1) {
            move (x, y);
        }

        var grid = new Gtk.Grid ();
        grid.orientation = Gtk.Orientation.VERTICAL;

        var lights = Api.Lights.get_instance ().get_lights ();
        var rooms = Api.Rooms.get_instance ().get_rooms ();

        foreach (var room in rooms.values) {
            grid.add (new LightsUp.Widgets.RoomWidget (room, lights));
        };

        add (grid);
        show_all ();
    }
}
