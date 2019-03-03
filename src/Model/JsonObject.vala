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
public abstract class LightsUp.Model.JsonObject : GLib.Object {

    [Signal (no_recurse = true, run = "first", action = true, no_hooks = true, detailed = true)]
    public signal void changed (string changed_property);

    public Json.Object object { get; construct; }
    public JsonObject? parent_object { get; construct; default = null; }

    public JsonObject.from_object (Json.Object object) {
        Object (object: object);
    }

    construct {
        debug ("Loading json object settings");

        var obj_class = (ObjectClass) get_type ().class_ref ();
        var properties = obj_class.list_properties ();
        foreach (var prop in properties) {
            load_key (prop.name);
        }
    }

    public void connect_to_api () {
        notify.connect (handle_notify);
    }

    void handle_notify (Object sender, ParamSpec property) {
        notify.disconnect (handle_notify);
        save_on_object (property.name);
        call_verify (property.name);
        notify.connect (handle_notify);
    }

    private void call_verify (string key) {
        if (key == "object" || key == "parent-object") {
            return;
        }

        api_call (key);
        changed (key);
    }

    protected virtual void api_call (string key)    {

    }

    private void load_key (string key) {
        if (key == "object" || key == "parent-object") {
            return;
        }

        string get_key = key;
        switch (key) {
            case "type-":
                get_key = "type";
                break;
            case "any-on":
                get_key = "any_on";
                break;
            case "all-on":
                get_key = "all_on";
                break;
        }

        if (!object.has_member (get_key)) {
            return;
        }

        var obj_class = (ObjectClass) get_type ().class_ref ();
        var prop = obj_class.find_property (key);

        var type = prop.value_type;
        var val = Value (type);
        this.get_property (prop.name.down (), ref val);


        if (val.type () == prop.value_type) {
            if (type == typeof (int))
                set_property (prop.name, (int) object.get_int_member (get_key));
            else if (type == typeof (uint))
                set_property (prop.name, (uint) object.get_int_member (get_key));
            else if (type == typeof (double))
                set_property (prop.name, object.get_double_member (get_key));
            else if (type == typeof (string))
                set_property (prop.name, object.get_string_member (get_key));
            else if (type == typeof (bool))
                set_property (prop.name, object.get_boolean_member (get_key));
            else if (type == typeof (int64))
                set_property (prop.name, object.get_int_member (get_key));
            else if (type.is_a (typeof (JsonObject))) {
                var object = object.get_object_member (get_key);
                set_property (prop.name, Object.new (type, "object", object, "parent-object", this));
            } else if (type == typeof (string[])) {
                var list = new Gee.LinkedList<string> ();
                object.get_array_member (get_key).get_elements ().foreach ((node) => {
                    list.add (node.get_string ());
                });
                set_property (prop.name, list.to_array ());
            }
        } else {
            print ("Unsupported settings type '%s' in object\n", type.name ());
        }
    }

    protected string get_string_property (string key) {
        var obj_class = (ObjectClass) get_type ().class_ref ();
        var prop = obj_class.find_property (key);

        var type = prop.value_type;
        var val = Value (type);
        this.get_property (prop.name.down (), ref val);

        if (val.type () == prop.value_type) {
            if (type == typeof (int))
                return ((int) val).to_string ();
            else if (type == typeof (uint))
                return ((uint) val).to_string ();
            else if (type == typeof (double))
                return ((double) val).to_string ();
            else if (type == typeof (string))
                return ((string) val).to_string ();
            else if (type == typeof (bool))
                return ((bool) val).to_string ();
            else if (type == typeof (int64))
                return ((int64) val).to_string ();
        }

        assert_not_reached ();
    }

    private void save_on_object (string key) {
        if (key == "object" || key == "parent-object") {
            return;
        }

        string get_key = key;
        switch (key) {
            case "type-":
                get_key = "type";
                break;
            case "any-on":
                get_key = "any_on";
                break;
            case "all-on":
                get_key = "all_on";
                break;
        }

        var obj_class = (ObjectClass) get_type ().class_ref ();
        var prop = obj_class.find_property (key);

        // Do not attempt to save a non-mapped key
        if (prop == null)
            return;

        var type = prop.value_type;
        var val = Value (type);
        this.get_property (prop.name, ref val);

        if (val.type () == prop.value_type) {
            if (type == typeof (int)) {
                if (val.get_int () != object.get_int_member (key)) {
                    object.set_int_member (get_key, val.get_int ());
                }
            } else if (type == typeof (uint)) {
                if (val.get_uint () != object.get_int_member (key)) {
                    object.set_int_member (get_key, val.get_uint ());
                }
            } else if (type == typeof (int64)) {
                if (val.get_int64 () != object.get_int_member (key)) {
                    object.set_int_member (get_key, val.get_int64 ());
                }
            } else if (type == typeof (double)) {
                if (val.get_double () != object.get_double_member (key)) {
                    object.set_double_member (key, val.get_double ());
                }
            } else if (type == typeof (string)) {
                if (val.get_string () != object.get_string_member (key)) {
                    object.set_string_member (key, val.get_string ());
                }
            } else if (type == typeof (string[])) {
                //  string[] strings = null;
                //  this.get (key, &strings);
                //  if (strings != schema.get_strv (key)) {
                //      schema.set_strv (key, strings);
                //  }
            } else if (type == typeof (bool)) {
                if (val.get_boolean () != object.get_boolean_member (key)) {
                    object.set_boolean_member (key, val.get_boolean ());
                }
            }
        }
    }

    public string to_string (bool prettyfied) {
        var node = new Json.Node.alloc ();
        node.set_object (object);

        return Json.to_string (node, prettyfied);
    }
}