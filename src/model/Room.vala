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

public class LightsUp.Model.Room : Object {
    public signal void updated ();

    public string id { get; set; }

    public string name {
        get {
            return object.get_string_member ("name");
        }
    }

    public bool has_temperature {
        get {
            return action.has_member ("ct");
        }
    }

    public int brightness {
        get {
            return (int) action.get_int_member ("bri");
        } set {
            action.set_int_member ("bri", value);
            update_property ("bri", value.to_string ());
        }
    }

    public int color_temperature {
        get {
            return (int) action.get_int_member ("ct");
        } set {
            action.set_int_member ("ct", value);
            update_property ("ct", value.to_string ());
        }
    }

    public bool any_on {
        get {
            return state.get_boolean_member ("any_on");
        }
    }

    public bool all_on {
        get {
            return state.get_boolean_member ("all_on");
        }
    }

    public bool on {
        get {
            return action.get_boolean_member ("on");
        } set {
            action.set_boolean_member ("on", value);
            update_property ("on", value.to_string ());
        }
    }

    public Json.Object state {
        get {
            return object.get_object_member ("state");
        }
    }

    public Json.Object action {
        get {
            return object.get_object_member ("action");
        }
    }

    public Json.Object object { get; construct set; }

    public Room (string _id, Json.Object _object) {
        Object (object: _object, id: _id);
    }

    private void update_property (string property, string value) {
        var endpoint = LightsUp.Api.Endpoint.get_instance ();

        var path = "groups/%s/action".printf (id);

        var body = "{\"%s\": %s}".printf (property, value);

        endpoint.request ("PUT", path, body, update_callback);
        updated ();
    }

    public void update_callback (string response) {
        debug ("Room update: %s\n", response);
    }

    public void update () {
        var endpoint = LightsUp.Api.Endpoint.get_instance ();

        var path = "groups/%s/".printf (id);

        endpoint.request ("GET", path, null, update_callback);
    }

    public Gee.LinkedList<string> get_lights () {
        var list = new Gee.LinkedList<string> ();
        object.get_array_member ("lights").get_elements ().foreach ((node) => {
            list.add (node.get_string ());
        });

        return list;
    }

    public string get_css_color () {
        if (!on) {
            return "rgba(40, 40, 40, 0.3)";
        }

        if (has_temperature) {
            return LightsUp.Utils.ct_to_css ((double) color_temperature, (double) brightness);
        }

        return @"rgba(255, 208, 43, $(((double) brightness / 255.0).clamp (0.3, 1.0)))";
    }
}