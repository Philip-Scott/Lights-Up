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

public class LightsUp.Api.Endpoint : Object {
    public signal void logged_in ();
    public signal void bridge_found (bool value);

    public string bridge_ip { get; set; }
    public string user { get; set; }

    private static Endpoint? instance = null;
    private LightsUp.RateLimitter rate_limitter;

    public static Endpoint get_instance () {
        if (instance == null) {
            instance = new Endpoint ();
        }

        return instance;
    }

    private Endpoint () {}

    construct {
        var settings = new GLib.Settings (LightsUp.Application.APP_ID);
        settings.bind ("host", this, "bridge_ip", GLib.SettingsBindFlags.DEFAULT);
        settings.bind ("user", this, "user", GLib.SettingsBindFlags.DEFAULT);

        rate_limitter = new LightsUp.RateLimitter ();
    }

    public void start_login () {
        new Thread<void*> (null, () => {
            Timeout.add (2000, () => {
                fetch_user ();

                if (user != "") {
                    logged_in ();
                    return GLib.Source.REMOVE;
                } else {
                    return GLib.Source.CONTINUE;
                }
            });
            return null;
        });
    }

    private void fetch_user () {
        var content = """{"devicetype":"lightsUp#%s"}""".printf (Environment.get_user_name ());
        _request ("POST", "http://%s/api/".printf (bridge_ip), content, this.login_callback);
    }

    public void login_callback (string response_) {
        string response = response_.replace ("]", "").replace ("[", "");

        if (response.contains ("success")) {
            var parser = new Json.Parser ();
            parser.load_from_data (response, -1);

            var root_object = parser.get_root ().get_object ();

            if (root_object != null && root_object.has_member ("success")) {
                user = root_object.get_member ("success").get_object ().get_string_member ("username");
            }
        } else if (response.contains ("link button not pressed")) {
            bridge_found (true);
        } else {
            bridge_found (false);
        }
    }

    public void request (string method, string path, string? body, RequestCallback callback_func = empty_request) {
        if (user == "") {
            warning ("Not authenticated");
            return;
        }

        _request (method, "http://%s/api/%s/%s".printf (bridge_ip, user, path), body, callback_func);

        // TOOD: Add error catching
        //  if (response == "") {
        //      bridge_found (false);
        //  }
    }

    public void empty_request (string response) {}

    private void _request (string method, string path, string? body, RequestCallback callback_func) {
        var event = new Request (method, path, body);
        event.callback = callback_func;

        rate_limitter.add (event);
    }
}

public delegate void RequestCallback (string response);
private class Request : QueuedEvent {
    public string method { get; set; }
    public string path { get; set; }
    public string? body { get; set; }
    public unowned RequestCallback callback;

    public Request (string method, string path, string? body) {
        Object (
            id: method + path,
            method: method,
            path: path,
            body: body
        );
    }

    public override void run () {
        debug ("Running request ----------------------------------------- \n");
        var session = new Soup.Session ();
        session.timeout = 1;

        var message = new Soup.Message (method, path);
        debug ("Method: %s\nPath: %s\n", method, path);

        if (body != null) {
            message.set_request ("application/json", Soup.MemoryUse.COPY, body.data);
        }

        session.send_message (message);

        var response_body = message.response_body;

        if (response_body != null) {
            var response_data = (string) response_body.flatten ().data;
            debug ("Response: \n%s", response_data);

            callback (response_data);
        }
    }
}