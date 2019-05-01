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

public class LightsUp.Model.Light : JsonObject {
    public LightsState state { get; set; }
    public string type_ { get; set; }

    public string name { get; set; }
    public string uniqueid { get; protected set; }
    private string api_id;

    public Light (Json.Object object, string _api_id) {
        Object (object: object);

        api_id = _api_id;
        connect_signals ();
    }

    protected override string key_override (string key) {
        switch (key) {
            case "type-":
                return "type";
            default:
                return key;
        }
    }

    protected override bool internal_changed (string key) {
        print ("light api: %s %u\n", key, ref_count);
        return true;
    }

    public class LightsState : JsonObject {
        public bool on { get; set; }
        public int bri { get; set; }
        public int ct { get; set; } // Color Temp`
        public string hue { get; set; }
        public string sat { get; set; }
        public string alert { get; set; }
        public string mode { get; set; }
        public string colormode {get; set;}
        public bool reachable { get; set; }

        public LightsState (Json.Object object) {
            Object (object: object);
        }

        protected override bool internal_changed (string key) {
            var endpoint = LightsUp.Api.Endpoint.get_instance ();

            var path = "lights/%s/state".printf (((Light) parent_object).api_id);
            var body = "{\"%s\": %s}".printf (key, get_string_property (key));

            endpoint.request ("PUT", path, body, update_callback);
            print ("light state api: %s\n", key);
            return true;
        }

        public void update_callback (string response) {
            debug ("Light: %s\n", response);
        }
    }

    public string get_css_color () {
        if (!state.reachable || !state.on) {
            return "rgba(40, 40, 40, 0.3)";
        }

        if (state.colormode == "ct") {
            return LightsUp.Utils.ct_to_css ((double) state.ct, (double) state.bri);
        }

        return @"rgba(255, 208, 43, $(((double) state.bri / 255.0).clamp (0.3, 1.0)))";
    }
}