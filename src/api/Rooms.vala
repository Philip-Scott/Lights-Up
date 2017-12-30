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

public class LightsUp.Api.Rooms : Object {

    private static Rooms? instance = null;

    public static Rooms get_instance () {
        if (instance == null) {
            instance = new Rooms ();
        }

        return instance;
    }

    private Rooms () {}

    public List<LightsUp.Model.Room> get_rooms () {
        var rooms = new List<LightsUp.Model.Room> ();

        try {
            var endpoint = Endpoint.get_instance ();
            var response = endpoint.request ("GET", "groups", null);

            var parser = new Json.Parser ();
			parser.load_from_data (response, -1);

            var root_object = parser.get_root ().get_object ();
            root_object.foreach_member ((i, name, node) => {
                var room = new LightsUp.Model.Room (name, node.get_object ());
                rooms.append (room);
            });
        } catch (Error e) {}

        return (owned) rooms;
    }
}