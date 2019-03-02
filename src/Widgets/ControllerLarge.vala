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

public abstract class LightsUp.Widgets.ControllerLarge : Gtk.Grid {
    protected Gtk.Label title_label;
    protected Gtk.Scale brightness;
    protected Gtk.Image image;
    protected Gtk.Switch light_switch;
    protected Gtk.Stack reachable_stack;
    protected Gtk.Grid childs;
    protected Gtk.EventBox image_event_box;

    construct {
        column_spacing = 6;
        margin = 6;

        title_label = new Gtk.Label ("");
        title_label.get_style_context ().add_class ("h3");
        title_label.get_style_context ().add_class ("h4");
        title_label.halign = Gtk.Align.START;

        light_switch = new Gtk.Switch ();
        light_switch.valign = Gtk.Align.CENTER;

        image = new Gtk.Image.from_icon_name ("room-icon-symbolic", Gtk.IconSize.DIALOG);
        image.get_style_context ().add_class ("room-icon");

        image_event_box = new Gtk.EventBox ();
        image_event_box.events += Gdk.EventMask.BUTTON_PRESS_MASK;
        image_event_box.add (image);

        childs = new Gtk.Grid ();
        childs.orientation = Gtk.Orientation.VERTICAL;

        var no_lights_label = new Gtk.Label ("<small>%s</small>".printf (_("Unreachable")));
        no_lights_label.halign = Gtk.Align.START;
        no_lights_label.use_markup = true;
        no_lights_label.sensitive = false;

        reachable_stack = new Gtk.Stack ();
        reachable_stack.add_named (no_lights_label, "non_reachable");

        attach (image_event_box, 0, 0, 1, 2);
        attach (title_label, 1, 0, 1, 1);
        attach (reachable_stack, 1, 1, 1, 1);
        attach (light_switch, 2, 0, 1, 2);
        attach (childs, 0, 2, 3, 1);

        show_all ();
    }
}