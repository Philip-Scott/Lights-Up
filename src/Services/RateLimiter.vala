/*
* Copyright (c) 2018
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

public class LightsUp.RateLimitter : Object {
    /**
     * Time in ms between the execution of events
     */
    public int timeout { get; set; default = 350; }

    private Queue<QueuedEvent> event_queue;
    private HashTable<string, QueuedEvent> event_set;
    private uint? timeout_id = null;

    Mutex mutex = Mutex ();

    construct {
        event_queue = new Queue<QueuedEvent>();
        event_set = new HashTable<string, QueuedEvent>(str_hash, str_equal);
    }

    public void add (QueuedEvent event) {
        mutex.lock ();

        if (event_set.contains (event.id)) {
            event_queue.remove (event_set.get (event.id));
            event_set.remove (event.id);
        }

        event_set.set (event.id, event);
        event_queue.push_tail (event);

        mutex.unlock ();

        run_event_loop ();
    }

    private void run_event_loop () {
        if (timeout_id != null) {
            return;
        }

        mutex.lock ();

        QueuedEvent? event = null;
        if (event_queue.length > 0) {
            event = event_queue.pop_head ();
            event_set.remove (event.id);
        }

        mutex.unlock ();

        if (event != null) {
            event.run ();
        }

        timeout_id = Timeout.add (timeout, () => {
            timeout_id = null;

            mutex.lock ();
            var length = event_queue.length;
            mutex.unlock ();

            if (length > 0) {
                run_event_loop ();
            }

            return false;
        });
    }
}

public abstract class QueuedEvent : Object {
    public string id { get; construct set; }

    protected QueuedEvent (string id) {
        Object (id: id);
    }

    public abstract void run ();
}