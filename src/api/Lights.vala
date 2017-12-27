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

public class LightsUp.Api.Lights : Object {

    private static Lights? instance = null;

    public static Lights get_instance () {
        if (instance == null) {
            instance = new Lights ();
        }

        return instance;
    }

    private Lights () {}

    public List<LightsUp.Model.Light> get_lights () {
        var lights = new List<LightsUp.Model.Light> ();

        try {
            var endpoint = Endpoint.get_instance ();
            var response = endpoint.request ("GET", "lights", null);

            var parser = new Json.Parser ();
			parser.load_from_data (response, -1);

            var root_object = parser.get_root ().get_object ();
            root_object.foreach_member ((i, name, node) => {
                var light = new LightsUp.Model.Light (name, node.get_object ());
                lights.append (light);
            });
        } catch (Error e) {}

        return (owned) lights;
    }
}