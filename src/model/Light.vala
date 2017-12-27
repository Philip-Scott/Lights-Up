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

    public string id { get; construct set; }

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

    public bool on {
        set {
            update_property ("on", value.to_string ());
            state.set_boolean_member ("on", value);
        } get {
            return state.get_boolean_member ("on");
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

    public Light (string id, Json.Object _object) {
        Object (object: _object, id: id);
    }

    private void update_property (string property, string value) {
        var endpoint = LightsUp.Api.Endpoint.get_instance ();
        var response = endpoint.request ("PUT", "lights/%s/state".printf (id), "{\"%s\": %s}".printf (property, value));
    }
}