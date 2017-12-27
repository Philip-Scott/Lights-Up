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

public class LightsUp.Model.Light : Object {
    public string id { get; set; }

    public string name {
        get {
            return object.get_string_member ("name");
        }
    }

    public string light_type {
        get {
            return object.get_string_member ("type");
        }
    }

    public string color_mode {
        get {
            if (state.has_member ("colormode")) {
                return state.get_string_member ("colormode");
            } else {
                return "none";
            }
        }
    }

    public int brightness {
        get {
            return (int) state.get_int_member ("bri");
        } set {
            update_property ("bri", value.to_string ());
            state.set_int_member ("bri", value);
        }
    }

    public int color_temperature {
        get {
            return (int) state.get_int_member ("ct");
        } set {
            update_property ("ct", value.to_string ());
            state.set_int_member ("ct", value);
        }
    }

    public bool on {
        get {
            return state.get_boolean_member ("on");
        } set {
            update_property ("on", value.to_string ());
            state.set_boolean_member ("on", value);
        }
    }

    public bool reachable {
        get {
            return state.get_boolean_member ("reachable");
        }
    }

    public Json.Object state {
        get {
            return object.get_object_member ("state");
        }
    }

    public Json.Object object { get; construct set; }

    public Light (string _id, Json.Object _object) {
        Object (object: _object, id: _id);
    }

    private void update_property (string property, string value) {
        var endpoint = LightsUp.Api.Endpoint.get_instance ();

        var path = "lights/%s/state".printf (id);

        var body = "{\"%s\": %s}".printf (property, value);

        endpoint.request ("PUT", path, body);
    }
}