//
//  Copyright (C) 2024 Plank Reloaded Developers
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using Plank;

namespace Docky
{
    public class ClippyDockItem : DockletItem
    {
        private const string ICON_NAME = "edit-cut";
        private const string EMPTY_CLIPBOARD_TEXT = N_("Clipboard is currently empty.");
        private const string CLEAR_MENU_LABEL = N_("_Clear");

        private Gtk.Clipboard clipboard;
        private Gee.ArrayList<string> clips;
        private int cur_position = 0;
        private ulong handler_id = 0U;

        public ClippyDockItem.with_dockitem_file (GLib.File file)
        {
            GLib.Object (Prefs: new ClippyPreferences.with_file (file));
        }

        construct
        {
            Icon = ICON_NAME;
            clips = new Gee.ArrayList<string> ();
            initialize_clipboard();
            update_display();
        }

        ~ClippyDockItem ()
        {
            disconnect_clipboard();
        }

        private void initialize_clipboard()
        {
            unowned ClippyPreferences prefs = (ClippyPreferences) Prefs;
            var atom_name = prefs.TrackMouseSelections ? "PRIMARY" : "CLIPBOARD";
            clipboard = Gtk.Clipboard.get(Gdk.Atom.intern(atom_name, true));
            connect_clipboard();
        }

        private void connect_clipboard()
        {
            handler_id = clipboard.owner_change.connect((clipboard, ev) => {
                request_clipboard_text();
            });
        }

        private void disconnect_clipboard()
        {
            if (handler_id > 0U) {
                clipboard.disconnect(handler_id);
                handler_id = 0U;
            }
        }

        private void request_clipboard_text()
        {
            clipboard.request_text((cb, text) => {
                if (text != null && text != "") {
                    process_clipboard_text(text);
                }
            });
        }

        private void process_clipboard_text(string text)
        {
            unowned ClippyPreferences prefs = (ClippyPreferences) Prefs;

            clips.remove(text);
            clips.add(text);

            while (clips.size > prefs.MaxEntries) {
                clips.remove_at(0);
            }

            cur_position = clips.size;
            update_display();
        }

        private void update_display()
        {
            if (clips.size == 0) {
                Text = _(EMPTY_CLIPBOARD_TEXT);
            } else {
                Text = get_entry_text(cur_position == 0 ? clips.size : cur_position);
            }
        }

        private string get_entry_text(int pos)
        {
            return clips.get(pos - 1).replace("\n", "").replace("\t", "");
        }

        private void copy_entry_at(int pos)
        {
            if (pos < 1 || pos > clips.size)
                return;

            var text = clips.get(pos - 1);
            clipboard.set_text(text, text.length);
            update_display();
        }

        private void copy_current_entry()
        {
            copy_entry_at(cur_position == 0 ? clips.size : cur_position);
        }

        private void clear_clipboard()
        {
            clipboard.set_text("", 0);
            clipboard.clear();
            clips.clear();
            cur_position = 0;
            update_display();
        }

        protected override AnimationType on_scrolled(Gdk.ScrollDirection direction,
                                                   Gdk.ModifierType mod,
                                                   uint32 event_time)
        {
            if (clips.size == 0)
                return AnimationType.NONE;

            if (direction == Gdk.ScrollDirection.UP)
                cur_position++;
            else
                cur_position--;

            if (cur_position < 1)
                cur_position = clips.size;
            else if (cur_position > clips.size)
                cur_position = 1;

            update_display();
            return AnimationType.NONE;
        }

        protected override AnimationType on_clicked(PopupButton button,
                                                  Gdk.ModifierType mod,
                                                  uint32 event_time)
        {
            if (button == PopupButton.LEFT && clips.size > 0) {
                copy_current_entry();
                return AnimationType.BOUNCE;
            }
            return AnimationType.NONE;
        }

        public override Gee.ArrayList<Gtk.MenuItem> get_menu_items()
        {
            var items = new Gee.ArrayList<Gtk.MenuItem>();

            // Add clipboard entries
            for (var i = clips.size; i > 0; i--) {
                var pos = i;
                var item = create_literal_menu_item(clips.get(pos - 1), ICON_NAME);
                item.activate.connect(() => {
                    copy_entry_at(pos);
                });
                items.add(item);
            }

            // Add clear button if there are entries
            if (clips.size > 0) {
                var clear_item = create_menu_item(_(CLEAR_MENU_LABEL), "edit-clear-all", true);
                clear_item.activate.connect(clear_clipboard);
                items.add(clear_item);
            }

            return items;
        }
    }
}
