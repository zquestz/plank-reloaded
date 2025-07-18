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
    private uint update_timer_id = 0;
    private GMenu.Tree apps_menu;
    private Gtk.Menu? app_menu = null;
    private Gee.ArrayList<Gtk.MenuItem>? app_menu_items = null;
    private Object apps_menu_lock = new Object();
    private bool apps_loaded;
    private Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default();

    private const string APPLICATIONS_MENU = "applications.menu";
    private const string CINNAMON_APPLICATIONS_MENU = "cinnamon-applications.menu";
    private const string MATE_APPLICATIONS_MENU = "mate-applications.menu";
    private const string NO_APPS_MESSAGE = _("No applications available");

    private ApplicationsPreferences prefs {
      get { return (ApplicationsPreferences) Prefs; }
    }

    public ApplicationsDockItem.with_dockitem_file(GLib.File file)
    {
      GLib.Object(Prefs : new ApplicationsPreferences.with_file(file));
    }

    construct
    {
      update_icon();

      ((ApplicationsPreferences) Prefs).notify["CustomIcon"].connect(() => {
        update_icon();
      });

      Text = _("Applications");

      string menu_name = APPLICATIONS_MENU;

      switch (environment_session_desktop()) {
      case XdgSessionDesktop.CINNAMON :
        menu_name = CINNAMON_APPLICATIONS_MENU;
        break;
      case XdgSessionDesktop.MATE:
        menu_name = MATE_APPLICATIONS_MENU;
        break;
      }

      lock (apps_menu_lock) {
        apps_menu = new GMenu.Tree(menu_name, GMenu.TreeFlags.SORT_DISPLAY_NAME);
        apps_menu.changed.connect(update_menu);
      }

      icon_theme.changed.connect(update_menu);
      update_menu.begin();
    }

    private void update_icon() {
      string custom_icon = prefs.CustomIcon;
      if (custom_icon != null && custom_icon != "") {
        Icon = custom_icon;
      } else {
        Icon = ApplicationsDocklet.ICON;
      }
    }

    ~ApplicationsDockItem() {
      if (update_timer_id > 0) {
        Source.remove(update_timer_id);
        update_timer_id = 0;
      }

      lock (apps_menu_lock) {
        if (apps_menu != null) {
          apps_menu.changed.disconnect(update_menu);
          apps_menu = null;
        }
      }

      if (app_menu != null) {
        app_menu.show.disconnect(on_menu_show);
        app_menu.hide.disconnect(on_menu_hide);
        app_menu = null;
      }

      icon_theme.changed.disconnect(update_menu);
    }

    private async void update_menu() {
      try {
        yield Worker.get_default().add_task_with_result<void*> (() => {
          lock (apps_menu_lock) {
            try {
              apps_menu.load_sync();
              apps_loaded = true;
            } catch (Error e) {
              warning("Failed to load applications (%s)", e.message);
              apps_loaded = false;
            }
          }
          return null;
        }, TaskPriority.HIGH);

        if (apps_loaded) {
          uint old_timer_id = update_timer_id;

          if (old_timer_id > 0) {
            update_timer_id = 0;
            Source.remove(old_timer_id);
          }

          update_timer_id = Timeout.add(2000, () => {
            build_applications_menu();
            update_timer_id = 0;
            return false;
          });
        }
      } catch (Error e) {
        warning("Error updating menu: %s", e.message);
      }
    }

    private void on_menu_show() {
      DockController? controller = get_dock();
      if (controller == null) {
        return;
      }

      controller.window.update_hovered(0, 0);
      controller.renderer.animated_draw();
    }

    private void on_menu_hide() {
      DockController? controller = get_dock();
      if (controller == null) {
        return;
      }

      controller.renderer.animated_draw();

      controller.hide_manager.update_hovered();
      if (!controller.hide_manager.Hovered) {
        controller.window.update_hovered(0, 0);
      }
    }

    protected override AnimationType on_scrolled(Gdk.ScrollDirection direction,
                                                 Gdk.ModifierType mod, uint32 event_time) {
      return AnimationType.NONE;
    }

    protected override AnimationType on_clicked(PopupButton button,
                                                Gdk.ModifierType mod, uint32 event_time) {
      if ((button & PopupButton.LEFT) != 0) {
        show_applications_menu();
        return AnimationType.NONE;
      }

      return AnimationType.NONE;
    }

    private void build_applications_menu() {
      DockController? controller = get_dock();
      if (controller == null) {
        return;
      }

      app_menu_items = get_applications_menu_items();

      if (app_menu_items == null || app_menu_items.size == 0) {
        return;
      }

      if (app_menu == null) {
        app_menu = new Gtk.Menu();
        app_menu.reserve_toggle_size = false;

        app_menu.show.connect(on_menu_show);
        app_menu.hide.connect(on_menu_hide);
        app_menu.attach_to_widget(controller.window, null);
      } else {
        foreach (var w in app_menu.get_children()) {
          app_menu.remove(w);
        }
      }

      foreach (var menu_item in app_menu_items) {
        menu_item.show();
        app_menu.append(menu_item);
      }
    }

    private void show_applications_menu() {
      DockController? controller = get_dock();
      if (controller == null) {
        return;
      }

      if (app_menu == null || app_menu_items == null || app_menu_items.size == 0) {
        return;
      }

      Gtk.Requisition requisition;
      app_menu.get_preferred_size(null, out requisition);

      int x, y;
      controller.position_manager.get_menu_position(this, requisition, out x, out y);

      Gdk.Gravity gravity;
      Gdk.Gravity flipped_gravity;

      switch (controller.position_manager.Position) {
      case Gtk.PositionType.BOTTOM :
        gravity = Gdk.Gravity.NORTH;
        flipped_gravity = Gdk.Gravity.SOUTH;
        break;
      case Gtk.PositionType.TOP :
        gravity = Gdk.Gravity.SOUTH;
        flipped_gravity = Gdk.Gravity.NORTH;
        break;
      case Gtk.PositionType.LEFT :
        gravity = Gdk.Gravity.EAST;
        flipped_gravity = Gdk.Gravity.WEST;
        break;
      case Gtk.PositionType.RIGHT :
        gravity = Gdk.Gravity.WEST;
        flipped_gravity = Gdk.Gravity.EAST;
        break;
      default:
        gravity = Gdk.Gravity.NORTH;
        flipped_gravity = Gdk.Gravity.SOUTH;
        break;
      }

      app_menu.popup_at_rect(
                             controller.window.get_screen().get_root_window(),
                             Gdk.Rectangle() {
        x = x,
        y = y,
        width = 1,
        height = 1,
      },
                             gravity,
                             flipped_gravity,
                             null
      );
    }

    public override Gee.ArrayList<Gtk.MenuItem> get_menu_items() {
      var items = new Gee.ArrayList<Gtk.MenuItem> ();

      var desktop = environment_session_desktop();

      string? editor_desktop_file = null;
      string? editor_command = null;

      switch (desktop) {
      case XdgSessionDesktop.CINNAMON:
        editor_desktop_file = "cinnamon-menu-editor.desktop";
        editor_command = "cinnamon-menu-editor";
        break;

      case XdgSessionDesktop.MATE:
        editor_desktop_file = "mozo.desktop";
        editor_command = "mozo";
        break;

      case XdgSessionDesktop.XFCE:
        editor_desktop_file = "menulibre.desktop";
        editor_command = "menulibre";
        break;

      case XdgSessionDesktop.GNOME:
        editor_desktop_file = "alacarte.desktop";
        editor_command = "alacarte";
        break;

      case XdgSessionDesktop.KDE:
        editor_desktop_file = "kmenuedit.desktop";
        editor_command = "kmenuedit";
        break;

      default:
        break;
      }

      if (editor_desktop_file != null && editor_command != null) {
        var menu_editor_item = create_menu_item(_("Edit Menu"), "document-edit", false);
        menu_editor_item.activate.connect(() => {
          try {
            var app_info = new DesktopAppInfo(editor_desktop_file);
            if (app_info != null) {
              app_info.launch(null, null);
            } else {
              Process.spawn_command_line_async(editor_command);
            }
          } catch (Error e) {
            warning("Failed to launch menu editor (%s): %s", editor_command, e.message);
          }
        });
        items.add(menu_editor_item);

        var separator_item = new Gtk.SeparatorMenuItem();
        items.add(separator_item);
      }

      var custom_icon_item = create_menu_item(_("Choose Custom Icon"), "document-properties", false);
      custom_icon_item.activate.connect(() => {
        show_icon_picker();
      });
      items.add(custom_icon_item);

      // If custom icon is set, add option to reset to default
      if (prefs.CustomIcon != "") {
        var reset_icon_item = create_menu_item(_("Reset to Default Icon"), "edit-clear", false);
        reset_icon_item.activate.connect(() => {
          prefs.CustomIcon = "";
        });
        items.add(reset_icon_item);
      }

      var separator_item = new Gtk.SeparatorMenuItem();
      items.add(separator_item);

      var large_icons_item = new Gtk.CheckMenuItem.with_mnemonic(_("Large Icons"));
      large_icons_item.active = prefs.LargeIcons;
      large_icons_item.activate.connect(() => {
        prefs.LargeIcons = !prefs.LargeIcons;
        build_applications_menu();
      });
      items.add(large_icons_item);

      return items;
    }

    private void show_icon_picker() {
      var file_chooser = new Gtk.FileChooserDialog(
                                                   _("Select Custom Icon"),
                                                   null,
                                                   Gtk.FileChooserAction.OPEN,
                                                   _("Cancel"), Gtk.ResponseType.CANCEL,
                                                   _("Select"), Gtk.ResponseType.ACCEPT
      );

      string[] icon_paths = {
        "/usr/share/icons",
        "/usr/share/pixmaps",
        GLib.Environment.get_home_dir() + "/.local/share/icons"
      };

      foreach (var path in icon_paths) {
        var dir = File.new_for_path(path);
        if (dir.query_exists()) {
          file_chooser.set_current_folder(path);
          break;
        }
      }

      var filter = new Gtk.FileFilter();
      filter.set_name(_("Image Files"));
      filter.add_mime_type("image/png");
      filter.add_mime_type("image/jpeg");
      filter.add_mime_type("image/svg+xml");
      filter.add_mime_type("image/webp");
      filter.add_pattern("*.png");
      filter.add_pattern("*.jpg");
      filter.add_pattern("*.jpeg");
      filter.add_pattern("*.svg");
      filter.add_pattern("*.xpm");
      filter.add_pattern("*.webp");
      file_chooser.add_filter(filter);

      var preview = new Gtk.Image();
      preview.set_size_request(128, 128);
      file_chooser.set_preview_widget(preview);
      file_chooser.set_use_preview_label(false);

      file_chooser.update_preview.connect(() => {
        string? filename = file_chooser.get_preview_filename();
        if (filename == null) {
          file_chooser.set_preview_widget_active(false);
          return;
        }

        try {
          var pixbuf = new Gdk.Pixbuf.from_file_at_scale(filename, 128, 128, true);
          preview.set_from_pixbuf(pixbuf);
          file_chooser.set_preview_widget_active(true);
        } catch (Error e) {
          file_chooser.set_preview_widget_active(false);
        }
      });

      if (file_chooser.run() == Gtk.ResponseType.ACCEPT) {
        string uri = file_chooser.get_uri();
        prefs.CustomIcon = uri;
      }

      file_chooser.destroy();
    }

    private Gtk.MenuItem create_applications_menu_item(string title, string? icon, bool force_show_icon) {
      if (icon == null || icon == "") {
        icon = "application-x-executable";
      }

      int width, height;
      if (prefs.LargeIcons) {
        Gtk.icon_size_lookup(Gtk.IconSize.LARGE_TOOLBAR, out width, out height);
      } else {
        Gtk.icon_size_lookup(Gtk.IconSize.MENU, out width, out height);
      }

      var item = new Gtk.MenuItem();
      var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);

      var image = new Gtk.Image.from_pixbuf(DrawingService.load_icon(icon, width, height));
      var label = new Gtk.Label.with_mnemonic(title);

      label.halign = Gtk.Align.START;
      label.valign = Gtk.Align.CENTER;

      if (force_show_icon) {
        box.pack_start(image, false, false, 0);
      }
      box.pack_start(label, true, true, 0);

      item.add(box);
      item.show_all();

      return item;
    }

    private Gee.ArrayList<Gtk.MenuItem> get_applications_menu_items() {
      var items = new Gee.ArrayList<Gtk.MenuItem> ();

      lock (apps_menu_lock) {
        if (!apps_loaded) {
          items.add(create_applications_menu_item(NO_APPS_MESSAGE, null, false));
          return items;
        }

        var root_dir = apps_menu.get_root_directory();
        if (root_dir == null) {
          items.add(create_applications_menu_item(NO_APPS_MESSAGE, null, false));
          return items;
        }

        var iter = root_dir.iter();
        GMenu.TreeItemType type;
        while ((type = iter.next()) != GMenu.TreeItemType.INVALID) {
          if (type == GMenu.TreeItemType.DIRECTORY) {
            var submenu_item = get_submenu_item(iter.get_directory());
            if (submenu_item != null) {
              items.add(submenu_item);
            }
          }
        }
      }

      return items;
    }

    private Gtk.MenuItem? get_submenu_item(GMenu.TreeDirectory category) {
      if (category == null)return null;

      var icon = DrawingService.get_icon_from_gicon(category.get_icon()) ?? "";
      var item = create_applications_menu_item(category.get_name(), icon, true);
      var submenu = new Gtk.Menu();
      submenu.reserve_toggle_size = false;

      add_menu_items(submenu, category);

      item.submenu = submenu;
      submenu.show();
      item.show();

      return item;
    }

    private void add_menu_items(Gtk.Menu menu, GMenu.TreeDirectory category) {
      if (category == null)return;

      var iter = category.iter();
      GMenu.TreeItemType type;

      while ((type = iter.next()) != GMenu.TreeItemType.INVALID) {
        if (type == GMenu.TreeItemType.DIRECTORY) {
          var submenu_item = get_submenu_item(iter.get_directory());
          if (submenu_item != null) {
            menu.add(submenu_item);
          }
        } else if (type == GMenu.TreeItemType.ENTRY) {
          var entry = iter.get_entry();
          if (entry == null)continue;

          var info = entry.get_app_info();
          if (info == null)continue;

          var desktop_path = entry.get_desktop_file_path();
          var icon = DrawingService.get_icon_from_gicon(info.get_icon()) ?? "";
          var item = create_applications_menu_item(info.get_display_name(), icon, true);

          item.activate.connect(() => {
            System.get_default().launch(File.new_for_path(desktop_path));
          });

          item.show();
          menu.add(item);
        }
      }
    }
  }
}
