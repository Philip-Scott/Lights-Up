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

public class LightsUp.Widgets.LightWidget : Gtk.Grid {

    public LightsUp.Model.Light light { get; construct set; }

    public bool reachable {
        set {
            light_switch.visible = value;
            light_switch.no_show_all = !value;
            label.sensitive = value;
            image.sensitive = value;
        }
    }

    private Gtk.Switch light_switch;
    private Gtk.Label label;
    private Gtk.Image image;

    public LightWidget (LightsUp.Model.Light light) {
        Object (light: light);
    }

    construct {
        orientation = Gtk.Orientation.HORIZONTAL;
        column_spacing = 6;
        margin_start = 12;

        label = new Gtk.Label (light.name);
        label.get_style_context ().add_class ("h4");
        label.halign = Gtk.Align.START;
        label.margin_start = 12;
        label.hexpand = true;

        light_switch = new Gtk.Switch ();
        light_switch.valign = Gtk.Align.CENTER;
        light_switch.set_active (light.on);

        light_switch.state_set.connect ((state) => {
            light.on = state;
        });

        var event_box = new Gtk.EventBox ();
        event_box.events += Gdk.EventMask.BUTTON_PRESS_MASK;

        image = new Gtk.Image.from_icon_name ("light-icon-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        image.get_style_context ().add_class ("light-icon");

        event_box.button_press_event.connect (() => {
            var popover = new Popover.for_light (light);
            popover.relative_to = image;

            popover.show_all ();
            return false;
        });

        event_box.add (image);

        add (event_box);
        add (label);
        add (light_switch);

        reachable = light.reachable;
        show_all ();
        set_color ();

        light.updated.connect (set_color);
    }

    private void set_color () {
        var color = light.get_css_color ();
        var CSS = ".light-icon {color: %s; }";

        LightsUp.Utils.set_style (image, CSS.printf (color));
    }
}