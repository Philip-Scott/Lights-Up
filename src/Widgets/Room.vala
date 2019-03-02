/*
* Copyright (c) 2019
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

public class LightsUp.Widgets.RoomWidget : LightsUp.Widgets.ControllerLarge {
    private string id {
        get {
            return room.api_id;
        }
    }

    public LightsUp.Model.Room room { get; construct set; }

    private Gee.LinkedList<LightsUp.Model.Light> lights;

    public bool active {
        set {
            brightness.sensitive = value;
        }
    }

    public bool any_reachable {
        get {
            return light_switch.sensitive;
        }
        set {
            if (value) {
                reachable_stack.set_visible_child_name ("brightness");
            } else {
                reachable_stack.set_visible_child_name ("non_reachable");
            }

            light_switch.sensitive = value;
        }
    }

    public RoomWidget (LightsUp.Model.Room room, Gee.HashMap<string, LightsUp.Model.Light> _lights) {
        Object (room: room);

        room.action.changed.connect (set_color);

        var light_ids = room.lights;
        this.lights = new Gee.LinkedList<LightsUp.Model.Light> ();

        bool any_reach = false;
        foreach (var id in light_ids) {
            var light = _lights.get (id);
            this.lights.add (light);

            if (light_ids.length > 1) {
                childs.add (new LightsUp.Widgets.LightWidget (light));
            }

            if (light.state.reachable) {
                any_reach = true;
            }
        }

        brightness = new LightsUp.Widgets.Scale.room_brightness (room);
        reachable_stack.add_named (brightness, "brightness");

        title_label.label = room.name;

        light_switch.set_active (room.state.any_on);
        light_switch.state_set.connect ((state) => {
            room.action.on = state;
            active = state;
            return false;
        });

        image_event_box.button_press_event.connect (() => {
            var popover = new Popover.for_room (room);
            popover.relative_to = image;

            popover.show_all ();
            return false;
        });

        show_all ();

        any_reachable = any_reach;
        active = room.state.any_on;

        set_color ();
    }

    private void set_color () {
        string color;

        if (any_reachable) {
            color = room.get_css_color ();
        } else {
            color = "rgba(40, 40, 40, 0.3)";
        }

        // TODO: Make gradient if more than one color
        //  foreach (var light in lights) {
        //      color = light.get_css_color ();
        //  }

        var CSS = ".room-icon {color: %s; }";
        LightsUp.Utils.set_style (image, CSS.printf (color));
    }
}