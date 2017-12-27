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
    public string bridge_ip { get; set; }
    public string user { get; set; }

    private static Endpoint? instance = null;

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

        if (user == "") {
            fetch_user ();
        }
    }

    private void fetch_user () {
        // TODO: Save local user:
        _request ("POST", "", """{"devicetype":"lightsUp#%s"}""".printf (Environment.get_user_name ()));
    }

    public string request (string method, string path, string? body) {
        if (user == "") {
            warning ("Not authenticated");
            return "";
        }

        return _request (method, "%s/%s".printf (user, path), body);
    }

    private string _request (string method, string path, string? body) {
        var session = new Soup.Session ();
        var message = new Soup.Message (method, "http://%s/api/%s".printf (bridge_ip, path));

        if (body != null) {
            message.set_request ("application/json", Soup.MemoryUse.COPY, body.data);
        }

        session.send_message (message);

        return (string) message.response_body.flatten ().data;
    }
}