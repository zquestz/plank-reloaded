//
// Copyright (C) 2024 Plank Reloaded Developers
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

using Plank;

namespace Docky {
  public class ApplicationsDockItem : DockletItem {
    private GMenu.Tree apps_menu;
    private Mutex apps_menu_mutex;
    private bool apps_loaded;

    // Cache commonly used strings
    private const string APPLICATIONS_MENU = "applications.menu";
    private const string CINNAMON_APPLICATIONS_MENU = "cinnamon-applications.menu";
    private const string NO_APPS_MESSAGE = "No applications available";

    public ApplicationsDockItem.with_dockitem_file (GLib.File file)
    {
      GLib.Object (Prefs: new DockItemPreferences.with_file (file));
    }

    construct
    {
      Icon = "gnome-applications;;gnome-main-menu";
      Text = _("Applications");

      string menu_name = environment_is_session_desktop (XdgSessionDesktop.CINNAMON)
                ? _(CINNAMON_APPLICATIONS_MENU)
                : _(APPLICATIONS_MENU);

      apps_menu = new GMenu.Tree (menu_name, GMenu.TreeFlags.SORT_DISPLAY_NAME);
      apps_menu.changed.connect (update_menu);
      update_menu.begin ();
    }

    ~ApplicationsDockItem () {
      if (apps_menu != null) {
        apps_menu.changed.disconnect (update_menu);
        apps_menu = null;
      }
    }

    private async void update_menu () {
      try {
        yield Worker.get_default ().add_task_with_result<void*> (() => {
          apps_menu_mutex.lock ();
          try {
            apps_menu.load_sync ();
            apps_loaded = true;
          } catch (Error e) {
            warning ("Failed to load applications (%s)", e.message);
            apps_loaded = false;
          } finally {
            apps_menu_mutex.unlock ();
          }
          return null;
        }, TaskPriority.HIGH);
      } catch (Error e) {
        warning ("Error updating menu: %s", e.message);
      }
    }

    protected override AnimationType on_scrolled (Gdk.ScrollDirection direction,
                                                  Gdk.ModifierType mod, uint32 event_time) {
      return AnimationType.NONE;
    }

    protected override AnimationType on_clicked (PopupButton button,
                                                 Gdk.ModifierType mod, uint32 event_time) {
      return AnimationType.NONE;
    }

    public override Gee.ArrayList<Gtk.MenuItem> get_menu_items () {
      var items = new Gee.ArrayList<Gtk.MenuItem> ();

      apps_menu_mutex.lock ();
      try {
        if (!apps_loaded) {
          items.add (create_menu_item (_(NO_APPS_MESSAGE), null, false));
          return items;
        }

        var root_dir = apps_menu.get_root_directory ();
        if (root_dir == null) {
          items.add (create_menu_item (_(NO_APPS_MESSAGE), null, false));
          return items;
        }

        var iter = root_dir.iter ();
        GMenu.TreeItemType type;
        while ((type = iter.next ()) != GMenu.TreeItemType.INVALID) {
          if (type == GMenu.TreeItemType.DIRECTORY) {
            var submenu_item = get_submenu_item (iter.get_directory ());
            if (submenu_item != null) {
              items.add (submenu_item);
            }
          }
        }
      } finally {
        apps_menu_mutex.unlock ();
      }

      return items;
    }

    private Gtk.MenuItem? get_submenu_item (GMenu.TreeDirectory category)
    {
      if (category == null)return null;

      var icon = DrawingService.get_icon_from_gicon (category.get_icon ()) ?? "";
      var item = create_menu_item (category.get_name (), icon, true);
      var submenu = new Gtk.Menu ();

      item.submenu = submenu;
      submenu.show ();
      item.show ();

      item.activate.connect (() => {
        foreach (var child in submenu.get_children ()) {
          submenu.remove (child);
        }
        add_menu_items (submenu, category);
      });

      return item;
    }

    private void add_menu_items (Gtk.Menu menu, GMenu.TreeDirectory category) {
      if (category == null)return;

      var iter = category.iter ();
      GMenu.TreeItemType type;

      while ((type = iter.next ()) != GMenu.TreeItemType.INVALID) {
        if (type == GMenu.TreeItemType.DIRECTORY) {
          var submenu_item = get_submenu_item (iter.get_directory ());
          if (submenu_item != null) {
            menu.add (submenu_item);
          }
        } else if (type == GMenu.TreeItemType.ENTRY) {
          var entry = iter.get_entry ();
          if (entry == null)continue;

          var info = entry.get_app_info ();
          if (info == null)continue;

          var desktop_path = entry.get_desktop_file_path ();
          var icon = DrawingService.get_icon_from_gicon (info.get_icon ()) ?? "";
          var item = create_menu_item (info.get_display_name (), icon, true);

          item.activate.connect (() => {
            System.get_default ().launch (File.new_for_path (desktop_path));
          });

          item.show ();
          menu.add (item);
        }
      }
    }
  }
}
